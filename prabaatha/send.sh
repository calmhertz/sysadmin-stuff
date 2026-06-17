#!/bin/bash

if [[ -f "./config" ]]; then
	source "./config"
else
	echo "[E] - Config not found."
	exit
fi

echo "[I] - Attempting to send:"
echo "${1}"
echo "to -> ntfy.sh/${NTFY_TOPIC}"

if [[ ! -z "${1}" ]]; then
	curl -d "${1}" "ntfy.sh/${NTFY_TOPIC}"
fi

echo ""
