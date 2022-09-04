#!/bin/bash

[ -z "${1}" ] && exit 1

cd "${1}/podverse-api" || eixt 2
git pull origin develop

cd "$1/podverse-fdroid" || eixt 2
git pull origin develop

cd "$1/podverse-ops" || eixt 2
git pull origin master

cd "$1/podverse-rn" || eixt 2
git pull origin develop

cd "$1/podverse-web" || eixt 2
git pull origin develop

cd "$1/v4v-wallet-browser-extension" || eixt 2
git pull origin main
