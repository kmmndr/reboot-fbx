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

Par défaut, la configuration est enregistrée dans le fichier `config`, dans le
dossier courant. Il est possible de changer ce comportement en renseignant la
variable d'environnement `CONFIG`.
