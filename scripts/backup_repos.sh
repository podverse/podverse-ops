#!/bin/bash

[ -z "${1}" ] && exit 1

cd "${1}/podverse-api" || exit 33
git pull origin develop

cd "$1/podverse-fdroid" || exit 33
git pull origin develop

cd "$1/podverse-ops" || exit 33
git pull origin master

cd "$1/podverse-rn" || exit 33
git pull origin develop

cd "$1/podverse-web" || exit 33
git pull origin develop

cd "$1/v4v-wallet-browser-extension" || exit 33
git pull origin main
