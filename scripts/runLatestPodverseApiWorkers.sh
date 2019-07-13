docker rm $(docker stop $(docker ps -a -q --filter ancestor=podverse/podverse_api))
docker image rm podverse/podverse_api
docker-compose -f /home/mitch/podverse-ops/docker-compose.$1.yml run -d --name podverse_api_parser_worker_1j podverse_api_parser_worker npm run scripts:parseFeedUrlsFromQueue -- 1 3600000
docker-compose -f /home/mitch/podverse-ops/docker-compose.$1.yml run -d --name podverse_api_parser_worker_1i podverse_api_parser_worker npm run scripts:parseFeedUrlsFromQueue -- 1 3600000
docker-compose -f /home/mitch/podverse-ops/docker-compose.$1.yml run -d --name podverse_api_parser_worker_1h podverse_api_parser_worker npm run scripts:parseFeedUrlsFromQueue -- 1 3600000
docker-compose -f /home/mitch/podverse-ops/docker-compose.$1.yml run -d --name podverse_api_parser_worker_1g podverse_api_parser_worker npm run scripts:parseFeedUrlsFromQueue -- 1 3600000
docker-compose -f /home/mitch/podverse-ops/docker-compose.$1.yml run -d --name podverse_api_parser_worker_1f podverse_api_parser_worker npm run scripts:parseFeedUrlsFromQueue -- 1 3600000
docker-compose -f /home/mitch/podverse-ops/docker-compose.$1.yml run -d --name podverse_api_parser_worker_1e podverse_api_parser_worker npm run scripts:parseFeedUrlsFromQueue -- 1 3600000
docker-compose -f /home/mitch/podverse-ops/docker-compose.$1.yml run -d --name podverse_api_parser_worker_1d podverse_api_parser_worker npm run scripts:parseFeedUrlsFromQueue -- 1 3600000
docker-compose -f /home/mitch/podverse-ops/docker-compose.$1.yml run -d --name podverse_api_parser_worker_1c podverse_api_parser_worker npm run scripts:parseFeedUrlsFromQueue -- 1 3600000
docker-compose -f /home/mitch/podverse-ops/docker-compose.$1.yml run -d --name podverse_api_parser_worker_1b podverse_api_parser_worker npm run scripts:parseFeedUrlsFromQueue -- 1 3600000
docker-compose -f /home/mitch/podverse-ops/docker-compose.$1.yml run -d --name podverse_api_parser_worker_1a podverse_api_parser_worker npm run scripts:parseFeedUrlsFromQueue -- 1 3600000
