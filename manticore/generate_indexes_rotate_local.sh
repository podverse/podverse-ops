docker exec -it podverse_manticore_local gosu manticore indexer idx_author --rotate --verbose;
docker exec -it podverse_manticore_local gosu manticore indexer idx_media_ref --rotate --verbose;
docker exec -it podverse_manticore_local gosu manticore indexer idx_playlist --rotate --verbose;
docker exec -it podverse_manticore_local gosu manticore indexer idx_podcast --rotate --verbose;
docker exec -it podverse_manticore_local gosu manticore indexer idx_episode --rotate --verbose;
