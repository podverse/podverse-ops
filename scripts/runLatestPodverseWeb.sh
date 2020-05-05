#!/bin/bash
docker rm $(docker stop $(docker ps -a -q --filter ancestor=podverse/podverse_web))
docker image rm podverse/podverse_web
docker-compose -f /home/mitch/podverse-ops/docker-compose.$1.yml up -d podverse_web
