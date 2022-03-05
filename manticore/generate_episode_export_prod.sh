PGPASSWORD=mysecretpw psql -h 0.0.0.0 -p 5432 -U postgres -c "COPY episodes(id, title, "\"pastHourTotalUniquePageviews\"", "\"pastDayTotalUniquePageviews\"", "\"pastWeekTotalUniquePageviews\"", "\"pastMonthTotalUniquePageviews\"", "\"pastYearTotalUniquePageviews\"", "\"pastAllTimeTotalUniquePageviews\"") TO stdout DELIMITER ',' CSV;" > /home/mitch/podverse-ops/manticore/episode_export.csv;
awk '{printf "%s,%s\n", NR,$0}' /home/mitch/podverse-ops/manticore/episode_export.csv > /home/mitch/podverse-ops/manticore/episode_export_with_serial_column.csv;
rm /home/mitch/podverse-ops/manticore/episode_export.csv;
docker exec -it podverse_manticore_prod gosu manticore indexer --all --rotate;
