#!/bin/bash

docker-compose -f docker-compose.prod.yml up -d podverse_nginx_proxy podverse_letsencrypt_nginx podverse_db podverse_api podverse_web

docker exec -d podverse_api_prod npm --prefix /tmp run seeds:categories

docker exec -d podverse_api_prod npm --prefix /tmp run scripts:addAllOrphanFeedUrlsToPriorityQueue
