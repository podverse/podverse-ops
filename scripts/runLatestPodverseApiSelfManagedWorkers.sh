#!/bin/bash

docker rm $(docker stop $(docker ps -a -q --filter ancestor=podverse/podverse_api))
docker image rm podverse/podverse_api
/usr/local/bin/docker-compose -f "/home/mitch/podverse-ops/docker-compose.${1}.worker.yml" run -d --name podverse_api_self_managed_parser_worker_1 podverse_api_parser_worker npm run scripts:parseFeedUrlsFromQueue -- 60000 selfManaged
/usr/local/bin/docker-compose -f "/home/mitch/podverse-ops/docker-compose.${1}.worker.yml" run -d --name podverse_api_self_managed_parser_worker_2 podverse_api_parser_worker npm run scripts:parseFeedUrlsFromQueue -- 60000 selfManaged
/usr/local/bin/docker-compose -f "/home/mitch/podverse-ops/docker-compose.${1}.worker.yml" run -d --name podverse_api_self_managed_parser_worker_3 podverse_api_parser_worker npm run scripts:parseFeedUrlsFromQueue -- 60000 selfManaged
