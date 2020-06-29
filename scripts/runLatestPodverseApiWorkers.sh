docker rm $(docker stop $(docker ps -a -q --filter ancestor=podverse/podverse_api))
sleep 30
docker image rm podverse/podverse_api
sleep 30
docker-compose -f /home/mitch/podverse-ops/docker-compose.$1.yml run -d --name podverse_api_parser_worker_1 podverse_api_parser_worker npm run scripts:parseFeedUrlsFromQueue -- 1800000
sleep 30
docker-compose -f /home/mitch/podverse-ops/docker-compose.$1.yml run -d --name podverse_api_parser_worker_2 podverse_api_parser_worker npm run scripts:parseFeedUrlsFromQueue -- 1800000
sleep 30
docker-compose -f /home/mitch/podverse-ops/docker-compose.$1.yml run -d --name podverse_api_parser_worker_3 podverse_api_parser_worker npm run scripts:parseFeedUrlsFromQueue -- 1800000
sleep 30
docker-compose -f /home/mitch/podverse-ops/docker-compose.$1.yml run -d --name podverse_api_parser_worker_4 podverse_api_parser_worker npm run scripts:parseFeedUrlsFromQueue -- 1800000
sleep 30
docker-compose -f /home/mitch/podverse-ops/docker-compose.$1.yml run -d --name podverse_api_parser_worker_5 podverse_api_parser_worker npm run scripts:parseFeedUrlsFromQueue -- 1800000
sleep 30
