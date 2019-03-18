docker rm $(docker stop $(docker ps -a -q --filter ancestor=podverse/podverse_api))
docker image rm podverse/podverse_api
docker-compose -f /home/mitch/podverse-ops/docker-compose.$1.yml up -d podverse_api
docker-compose -f /home/mitch/podverse-ops/docker-compose.$1.yml run -d --name podverse_api_parser_worker_5 podverse_api_parser_worker npm run scripts:parseFeedUrlsFromQueue -- 5 900000
docker-compose -f /home/mitch/podverse-ops/docker-compose.$1.yml run -d --name podverse_api_parser_worker_4 podverse_api_parser_worker npm run scripts:parseFeedUrlsFromQueue -- 4 3600000
docker-compose -f /home/mitch/podverse-ops/docker-compose.$1.yml run -d --name podverse_api_parser_worker_3 podverse_api_parser_worker npm run scripts:parseFeedUrlsFromQueue -- 3 3600000
docker-compose -f /home/mitch/podverse-ops/docker-compose.$1.yml run -d --name podverse_api_parser_worker_2 podverse_api_parser_worker npm run scripts:parseFeedUrlsFromQueue -- 2 3600000
docker-compose -f /home/mitch/podverse-ops/docker-compose.$1.yml run -d --name podverse_api_parser_worker_1 podverse_api_parser_worker npm run scripts:parseFeedUrlsFromQueue -- 1 3600000
