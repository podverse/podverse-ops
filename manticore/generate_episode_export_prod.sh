psql -h 0.0.0.0 -p 5432 -U postgres -c "COPY episodes(id, title, "\"pastHourTotalUniquePageviews\"", "\"pastDayTotalUniquePageviews\"", "\"pastWeekTotalUniquePageviews\"", "\"pastMonthTotalUniquePageviews\"", "\"pastYearTotalUniquePageviews\"", "\"pastAllTimeTotalUniquePageviews\"") TO stdout DELIMITER ',' CSV;" > /mnt/podverse_db_prod_volume/manticore/data/episode_export.csv;
awk '{printf "%s,%s\n", NR,$0}' /mnt/podverse_db_prod_volume/manticore/data/episode_export.csv > /mnt/podverse_db_prod_volume/manticore/data/episode_export_with_serial_column.csv;
rm /mnt/podverse_db_prod_volume/manticore/data/episode_export.csv;
docker exec -it podverse_manticore_prod gosu manticore indexer --all --rotate;
