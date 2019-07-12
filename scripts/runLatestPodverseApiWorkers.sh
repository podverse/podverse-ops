docker rm $(docker stop $(docker ps -a -q --filter ancestor=podverse/podverse_api))
docker image rm podverse/podverse_api
docker-compose -f /home/mitch/podverse-ops/docker-compose.$1.yml run -d --name podverse_api_parser_worker_5b podverse_api_parser_worker npm run scripts:parseFeedUrlsFromQueue -- 5 900000
docker-compose -f /home/mitch/podverse-ops/docker-compose.$1.yml run -d --name podverse_api_parser_worker_5a podverse_api_parser_worker npm run scripts:parseFeedUrlsFromQueue -- 5 900000
docker-compose -f /home/mitch/podverse-ops/docker-compose.$1.yml run -d --name podverse_api_parser_worker_4b podverse_api_parser_worker npm run scripts:parseFeedUrlsFromQueue -- 4 3600000
docker-compose -f /home/mitch/podverse-ops/docker-compose.$1.yml run -d --name podverse_api_parser_worker_4a podverse_api_parser_worker npm run scripts:parseFeedUrlsFromQueue -- 4 3600000
docker-compose -f /home/mitch/podverse-ops/docker-compose.$1.yml run -d --name podverse_api_parser_worker_3b podverse_api_parser_worker npm run scripts:parseFeedUrlsFromQueue -- 3 3600000
docker-compose -f /home/mitch/podverse-ops/docker-compose.$1.yml run -d --name podverse_api_parser_worker_3a podverse_api_parser_worker npm run scripts:parseFeedUrlsFromQueue -- 3 3600000
docker-compose -f /home/mitch/podverse-ops/docker-compose.$1.yml run -d --name podverse_api_parser_worker_2b podverse_api_parser_worker npm run scripts:parseFeedUrlsFromQueue -- 2 3600000
docker-compose -f /home/mitch/podverse-ops/docker-compose.$1.yml run -d --name podverse_api_parser_worker_2a podverse_api_parser_worker npm run scripts:parseFeedUrlsFromQueue -- 2 3600000
docker-compose -f /home/mitch/podverse-ops/docker-compose.$1.yml run -d --name podverse_api_parser_worker_1b podverse_api_parser_worker npm run scripts:parseFeedUrlsFromQueue -- 1 3600000
docker-compose -f /home/mitch/podverse-ops/docker-compose.$1.yml run -d --name podverse_api_parser_worker_1a podverse_api_parser_worker npm run scripts:parseFeedUrlsFromQueue -- 1 3600000
