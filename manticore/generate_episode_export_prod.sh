PGPASSWORD='mysecretpw' psql -h 0.0.0.0 -p 5432 -U postgres -c "COPY episodes(id, title, "\"pastHourTotalUniquePageviews\"", "\"pastDayTotalUniquePageviews\"", "\"pastWeekTotalUniquePageviews\"", "\"pastMonthTotalUniquePageviews\"", "\"pastYearTotalUniquePageviews\"", "\"pastAllTimeTotalUniquePageviews\"") TO stdout DELIMITER ',' CSV;" > /home/mitch/podverse-ops/manticore/episode_export.csv;
awk '{printf "%s,%s\n", NR,$0}' /home/mitch/podverse-ops/manticore/episode_export.csv > /home/mitch/podverse-ops/manticore/episode_export_with_serial_column.csv;
rm /home/mitch/podverse-ops/manticore/episode_export.csv;
split -l 10000000 /home/mitch/podverse-ops/manticore/episode_export_with_serial_column.csv /home/mitch/podverse-ops/manticore/episode_export_ -d --additional-suffix=.csv
docker exec -it podverse_manticore_prod gosu manticore idx_author --rotate;
docker exec -it podverse_manticore_prod gosu manticore idx_media_ref --rotate;
docker exec -it podverse_manticore_prod gosu manticore idx_playlist --rotate;
docker exec -it podverse_manticore_prod gosu manticore idx_podcast --rotate;
docker exec -it podverse_manticore_prod gosu manticore idx_episode idx_episode_01 idx_episode_02 idx_episode_03 idx_episode_04 idx_episode_05 idx_episode_06 idx_episode_07 idx_episode_08 idx_episode_09 idx_episode_10 idx_episode_11 idx_episode_12 idx_episode_13 idx_episode_14 idx_episode_15 idx_episode_16 idx_episode_17 idx_episode_18 idx_episode_19 --merge;
