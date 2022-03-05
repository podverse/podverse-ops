for i in `seq -w 1 9`
do
  touch /Users/Mitch/Repos/podverse-ops/manticore/episode_export_csvs/episode_export_0$i.csv
done

for i in `seq -w 10 99`
do
  touch /Users/Mitch/Repos/podverse-ops/manticore/episode_export_csvs/episode_export_$i.csv
done
