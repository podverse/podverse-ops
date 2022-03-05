for i in `seq -w 0 9`
do
    cp /dev/null /home/mitch/podverse-ops/manticore/episode_export_csvs/episode_export_0$i.csv
done

for i in `seq -w 10 99`
do
    cp /dev/null /home/mitch/podverse-ops/manticore/episode_export_csvs/episode_export_$i.csv
done
