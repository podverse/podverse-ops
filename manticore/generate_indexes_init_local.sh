PGPASSWORD='mysecretpw' psql -h 0.0.0.0 -p 5432 -U postgres -c "COPY episodes(id, title, "\"pastHourTotalUniquePageviews\"", "\"pastDayTotalUniquePageviews\"", "\"pastWeekTotalUniquePageviews\"", "\"pastMonthTotalUniquePageviews\"", "\"pastYearTotalUniquePageviews\"", "\"pastAllTimeTotalUniquePageviews\"") TO stdout DELIMITER ',' CSV;" > /Users/Mitch/Repos/podverse-ops/manticore/episode_export.csv;
awk '{printf "%s,%s\n", NR,$0}' /Users/Mitch/Repos/podverse-ops/manticore/episode_export.csv > /Users/Mitch/Repos/podverse-ops/manticore/episode_export_with_serial_column.csv;
rm /Users/Mitch/Repos/podverse-ops/manticore/episode_export.csv;
mv /Users/Mitch/Repos/podverse-ops/manticore/episode_export_with_serial_column.csv /Users/Mitch/Repos/podverse-ops/manticore/episode_export_csvs/episode_export_00.csv;
docker exec -it podverse_manticore_local gosu manticore indexer idx_author --verbose;
docker exec -it podverse_manticore_local gosu manticore indexer idx_media_ref --verbose;
docker exec -it podverse_manticore_local gosu manticore indexer idx_playlist --verbose;
docker exec -it podverse_manticore_local gosu manticore indexer idx_podcast --verbose;
docker exec -it podverse_manticore_local gosu manticore indexer idx_episode_00 --verbose;
