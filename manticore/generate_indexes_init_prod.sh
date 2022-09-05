#!/bin/bash

docker exec -i podverse_manticore_prod gosu manticore indexer idx_author --verbose;
docker exec -i podverse_manticore_prod gosu manticore indexer idx_media_ref --verbose;
docker exec -i podverse_manticore_prod gosu manticore indexer idx_playlist --verbose;
docker exec -i podverse_manticore_prod gosu manticore indexer idx_podcast --verbose;
docker exec -i podverse_manticore_prod gosu manticore indexer idx_episode_01 --verbose;
docker exec -i podverse_manticore_prod gosu manticore indexer idx_episode_02 --verbose;
docker exec -i podverse_manticore_prod gosu manticore indexer idx_episode_03 --verbose;
docker exec -i podverse_manticore_prod gosu manticore indexer idx_episode_04 --verbose;
docker exec -i podverse_manticore_prod gosu manticore indexer idx_episode_05 --verbose;
docker exec -i podverse_manticore_prod gosu manticore indexer idx_episode_06 --verbose;
docker exec -i podverse_manticore_prod gosu manticore indexer idx_episode_07 --verbose;
docker exec -i podverse_manticore_prod gosu manticore indexer idx_episode_08 --verbose;
docker exec -i podverse_manticore_prod gosu manticore indexer idx_episode_09 --verbose;
docker exec -i podverse_manticore_prod gosu manticore indexer idx_episode_10 --verbose;
