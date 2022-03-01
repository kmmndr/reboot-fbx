# reboot-fbx

This script will reboot the modem of the french isp Free.

Ce script sert à redémarrer la freebox.

## Elements requis

Il faut être client Free et posséder une Freebox compatible.  Il a été testé
avec la freebox mini 4k.

Le programme nécéssite les applications suivantes:
- bash
- curl
- jq
- openssl
- awk

## Utilisation

L'utilisation est très simple, il suffit de démarrer une première fois le
programme, d'aller appuyer sur les boutons de la freebox pour autoriser
l'application à y accéder.

Le premier démarrage s'arrêtera là en indiquant un message d'erreur mentionnant
que les permissions sont insuffisantes.

```
$ ./reboot-fbx.sh
reboot-fbx.sh
- config file: config
api_version: 6.0
waiting............
Error: You must grant reboot permission
```

Ensuite, aller dans l'interface de configuration
[mafreebox](http://mafreebox.freebox.fr), dans la rubrique `Paramètre de la
Freebox`>`Gestion des accès`, puis dans l'onglet `Applications` et ajouter à
l'application la permission `Modification des réglages de la Freebox`.

Les prochains démarrages du programme redémarreront la Freebox.

```
$ ./reboot-fbx.sh
reboot-fbx.sh
- config file: config
api_version: 6.0
waiting.
Reboot initiated
```

Par défaut, la configuration est enregistrée dans le fichier
`~/reboot-fbx.conf`, dans le dossier utilisateur. Il est possible de changer ce
comportement en renseignant la variable d'environnement `CONFIG`.

## Connexion https

Il est désormais possible de se connecter à la Freebox via une connection
https. Pour utiliser ce protocole, il suffira de définir une variable
d'environnement `FREEBOX_BASE_URL` comme ci-dessous. Ce comportement sera
peut-être adopté par défaut lors d'une prochaine version.

```
env FREEBOX_BASE_URL=https://mafreebox.freebox.fr ./reboot-fbx.sh
```

Puisqu'il s'agit d'un certificat auto-signé, il sera enregistré dans
`~/.reboot-fbx.cert` lors de la première connexion. Ce fichier servira de
référence pour les prochaines connexions.
