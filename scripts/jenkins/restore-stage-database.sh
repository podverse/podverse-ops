#!/bin/bash

docker stop podverse_db_stage;
docker rm podverse_db_stage;
docker-compose -f ./podverse-ops/docker-compose.stage.yml up -d podverse_db;
sleep 10;
PGPASSWORD='<password here>' psql -h localhost -U postgres -d postgres -f old-sample-database.sql;