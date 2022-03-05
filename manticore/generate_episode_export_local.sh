PGPASSWORD=mysecretpw psql -h 0.0.0.0 -p 5432 -U postgres -c "COPY episodes(id, title, "\"pastHourTotalUniquePageviews\"", "\"pastDayTotalUniquePageviews\"", "\"pastWeekTotalUniquePageviews\"", "\"pastMonthTotalUniquePageviews\"", "\"pastYearTotalUniquePageviews\"", "\"pastAllTimeTotalUniquePageviews\"") TO stdout DELIMITER ',' CSV;" > ./manticore/episode_export.csv;
awk '{printf "%s,%s\n", NR,$0}' ./manticore/episode_export.csv > ./manticore/episode_export_with_serial_column.csv;
rm ./manticore/episode_export.csv;
docker exec -it podverse_manticore_local gosu manticore indexer --all --rotate;
