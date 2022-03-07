PGPASSWORD='mysecretpw' psql -h 0.0.0.0 -p 5432 -U postgres -c "COPY (SELECT id, title, "\"pastHourTotalUniquePageviews\"", "\"pastDayTotalUniquePageviews\"", "\"pastWeekTotalUniquePageviews\"", "\"pastMonthTotalUniquePageviews\"", "\"pastYearTotalUniquePageviews\"", "\"pastAllTimeTotalUniquePageviews\"", extract(epoch from "\"pubDate\"") FROM episodes) TO stdout DELIMITER ',' CSV;" > /Users/Mitch/Repos/podverse-ops/manticore/episode_export.csv;
awk '{printf "%s,%s\n", NR,$0}' /Users/Mitch/Repos/podverse-ops/manticore/episode_export.csv > /Users/Mitch/Repos/podverse-ops/manticore/episode_export_with_serial_column.csv;
rm /Users/Mitch/Repos/podverse-ops/manticore/episode_export.csv;
docker exec -it podverse_manticore_local gosu manticore indexer idx_author --verbose;
docker exec -it podverse_manticore_local gosu manticore indexer idx_media_ref --verbose;
docker exec -it podverse_manticore_local gosu manticore indexer idx_playlist --verbose;
docker exec -it podverse_manticore_local gosu manticore indexer idx_podcast --verbose;
docker exec -it podverse_manticore_local gosu manticore indexer idx_episode --rotate --verbose;
