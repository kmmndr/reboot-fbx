#!/bin/bash

APP_ID="reboot-fbx.sh"
APP_NAME="Reboot"
APP_VERSION="0.0.2"
DEVICE_NAME="$(hostname -s)"
FREEBOX_BASE_URL=${FREEBOX_BASE_URL:-'http://mafreebox.freebox.fr'}

[ -z $DEBUG ] && exec 2>/dev/null || set -x
echo "***DEBUG***" >&2

config=${CONFIG:-"$HOME/.reboot-fbx.conf"}

freebox_tls_cert=${FREEBOX_TLS_CERT:-"$HOME/.reboot-fbx.cert"}
cacert_params=''

# set -eu
set -e
set -o pipefail

function get_tls_cert() {
  if ! echo "$FREEBOX_BASE_URL" | grep '^https://' > /dev/null; then
    return
  fi

  cacert_params="--cacert $freebox_tls_cert"
  fbx_hostname=$(echo $FREEBOX_BASE_URL | awk -F/ '{print $3}')
  if [ ! -f $freebox_tls_cert ]; then
    echo 'quit' | openssl s_client \
      -showcerts \
      -servername $fbx_hostname \
      -connect $fbx_hostname:443 > $freebox_tls_cert 2> /dev/null
  fi
}

function read_config() {
  set -a
  . $config
  set +a
}

function set_param() {
  param=$1
  value=$2
  grep "$param" $config > /dev/null || echo "$param=$value" >> $config
  read_config
}

function post() {
  url=$1
  data=$2
  session_token=$3

  echo "POST $url" >&2
  echo "$data" >&2

  if [ "$session_token" != "" ]; then
    session_token_header="X-Fbx-App-Auth: $session_token"
  fi

  result=$(curl -s \
                $cacert_params \
                -X POST \
                -H "Content-Type: application/json" \
                -H "$session_token_header" \
                -d "$data" \
                ${FREEBOX_BASE_URL}${url} | jq .)

  echo "RESULT:" >&2
  echo "$result" >&2

  echo $result
}

function get() {
  url=$1

  echo "GET $url" >&2

  result=$(curl -s \
                $cacert_params \
       ${FREEBOX_BASE_URL}${url} \
       | jq .)

  echo "RESULT:" >&2
  echo "$result" >&2

  echo $result
}

function hmac_sha1() {
  app_token=$1
  challenge=$2
  echo -n "$challenge" | openssl sha1 -hmac "$app_token" | awk '{print $2}'
}

echo "$APP_ID" >&2
echo "- config file: $config" >&2
[ -f $config ] || touch $config

read_config
get_tls_cert

api_version=$(get '/api_version' | jq -r '.api_version')
echo "api_version: $api_version"

if [ "$app_token" == "" ]; then
  data="{
    \"app_id\": \"$APP_ID\",
    \"app_name\": \"$APP_NAME\",
    \"app_version\": \"$APP_VERSION\",
    \"device_name\": \"$DEVICE_NAME\"
  }"
  result=$(post "/api/v4/login/authorize" "$data")

  app_token=$(echo $result| jq -r '.result.app_token')
  set_param 'app_token' "'$app_token'"

  track_id=$(echo $result| jq -r '.result.track_id')
  set_param 'track_id' "$track_id"
fi

echo "app_token $app_token" >&2
echo "track_id: $track_id"

status='pending'
echo -n 'waiting'
while [ $status == 'pending' ]
do
  sleep 1
  result=$(get "/api/v4/login/authorize/$track_id")
  status=$(echo $result | jq -r '.result.status')
  challenge=$(echo $result | jq -r '.result.challenge')
  password_salt=$(echo $result | jq -r '.result.password_salt')
  echo -n '.'
done
echo ""

if [ "$status" != "granted" ]; then
  echo "Error: status $status"
  exit 1
fi

password=$(hmac_sha1 $app_token $challenge)
echo "password: $password" >&2

data="{
  \"app_id\": \"$APP_ID\",
  \"password\": \"$password\"
}"
result=$(post "/api/v4/login/session" "$data")
session_token=$(echo $result | jq -r '.result.session_token')

echo "session_token: $session_token" >&2

result=$(post "/api/v4/system/reboot" "$data" "$session_token")
success=$(echo $result | jq -r '.success')
if [ "$success" != "true" ]; then
  echo 'Error: You must grant reboot permission'
  exit 1
fi

echo 'Reboot initiated'
