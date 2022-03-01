PREFIX?=/usr/local

install:
		@install -Dm755 reboot-fbx.sh ${PREFIX}/bin/reboot-fbx

uninstall:
		@rm ${PREFIX}/bin/reboot-fbx
