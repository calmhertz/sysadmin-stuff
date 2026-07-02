#!/bin/bash

echo "FileBrowser Server Init"
echo

if [[ -f "./db/filebrowser.db" ]]; then
	printf -- "[E] - Already initialized!\n"
	exit
fi

mkdir -p db srv config
setfacl -R -m u:525287:rwx db srv config
setfacl -R -m g:525287:rwx db srv config

printf -- "[I] - Making sure Pod is not running.\n"
podman kube down ./play.yaml > /dev/null 2>&1

if podman kube play ./play.yaml > /dev/null 2>&1; then
	printf -- "[I] - Extracting user credentials. Please wait....\n"
	sleep 5
	fbpwd=$(podman logs filebrowser-main 2>&1 | awk '/initialized with randomly generated password:/ {print $NF}')
	printf -- "User: admin\nPassword: %s\n" "${fbpwd}" > passwd_flebrw.txt
	printf -- "[I] - Extracted. Please wait....\n"
	podman kube down ./play.yaml > /dev/null 2>&1
	printf -- "[I] - Check passwd_flwbrw.txt for login credentials.\n"
fi

