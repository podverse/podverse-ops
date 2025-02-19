#!/usr/bin/env bash

docker-compose -f ./docker-compose/local/docker-compose.yml up podverse_db -d;
sleep 10;
rm -rf ./manticore/data;
docker-compose -f ./docker-compose/local/docker-compose.yml up podverse_manticore -d;
sleep 5;
./manticore/generate_indexes_init_local.sh;
docker restart podverse_manticore_local;
docker-compose -f ./docker-compose/local/docker-compose.yml up podverse_api -d;
docker-compose -f ./docker-compose/local/docker-compose.yml up podverse_web -d;
