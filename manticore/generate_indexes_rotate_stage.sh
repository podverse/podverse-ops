#!/usr/bin/env bash
    
docker exec -i podverse_manticore_stage gosu manticore indexer idx_author --rotate --verbose;
docker exec -i podverse_manticore_stage gosu manticore indexer idx_media_ref --rotate --verbose;
docker exec -i podverse_manticore_stage gosu manticore indexer idx_playlist --rotate --verbose;
docker exec -i podverse_manticore_stage gosu manticore indexer idx_podcast --rotate --verbose;
docker exec -i podverse_manticore_stage gosu manticore indexer idx_episode_01 --rotate --verbose;
docker exec -i podverse_manticore_stage gosu manticore indexer idx_episode_02 --rotate --verbose;
docker exec -i podverse_manticore_stage gosu manticore indexer idx_episode_03 --rotate --verbose;
docker exec -i podverse_manticore_stage gosu manticore indexer idx_episode_04 --rotate --verbose;
docker exec -i podverse_manticore_stage gosu manticore indexer idx_episode_05 --rotate --verbose;
docker exec -i podverse_manticore_stage gosu manticore indexer idx_episode_06 --rotate --verbose;
docker exec -i podverse_manticore_stage gosu manticore indexer idx_episode_07 --rotate --verbose;
docker exec -i podverse_manticore_stage gosu manticore indexer idx_episode_08 --rotate --verbose;
docker exec -i podverse_manticore_stage gosu manticore indexer idx_episode_09 --rotate --verbose;
docker exec -i podverse_manticore_stage gosu manticore indexer idx_episode_10 --rotate --verbose;
