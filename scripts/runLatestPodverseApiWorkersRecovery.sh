docker rm $(docker stop $(docker ps -a -q --filter ancestor=podverse/podverse_api))
docker image rm podverse/podverse_api
/usr/local/bin/docker-compose -f /home/mitch/podverse-ops/docker-compose.$1.yml run -d --name podverse_api_parser_worker_1 podverse_api_parser_worker npm run scripts:parseFeedUrlsFromQueue -- 60000 priority
/usr/local/bin/docker-compose -f /home/mitch/podverse-ops/docker-compose.$1.yml run -d --name podverse_api_parser_worker_2 podverse_api_parser_worker npm run scripts:parseFeedUrlsFromQueue -- 60000 priority
/usr/local/bin/docker-compose -f /home/mitch/podverse-ops/docker-compose.$1.yml run -d --name podverse_api_parser_worker_3 podverse_api_parser_worker npm run scripts:parseFeedUrlsFromQueue -- 60000 priority
/usr/local/bin/docker-compose -f /home/mitch/podverse-ops/docker-compose.$1.yml run -d --name podverse_api_parser_worker_4 podverse_api_parser_worker npm run scripts:parseFeedUrlsFromQueue -- 60000 priority
/usr/local/bin/docker-compose -f /home/mitch/podverse-ops/docker-compose.$1.yml run -d --name podverse_api_parser_worker_5 podverse_api_parser_worker npm run scripts:parseFeedUrlsFromQueue -- 60000 priority
/usr/local/bin/docker-compose -f /home/mitch/podverse-ops/docker-compose.$1.yml run -d --name podverse_api_parser_worker_6 podverse_api_parser_worker npm run scripts:parseFeedUrlsFromQueue -- 360000
/usr/local/bin/docker-compose -f /home/mitch/podverse-ops/docker-compose.$1.yml run -d --name podverse_api_parser_worker_7 podverse_api_parser_worker npm run scripts:parseFeedUrlsFromQueue -- 360000
/usr/local/bin/docker-compose -f /home/mitch/podverse-ops/docker-compose.$1.yml run -d --name podverse_api_parser_worker_8 podverse_api_parser_worker npm run scripts:parseFeedUrlsFromQueue -- 360000
/usr/local/bin/docker-compose -f /home/mitch/podverse-ops/docker-compose.$1.yml run -d --name podverse_api_parser_worker_9 podverse_api_parser_worker npm run scripts:parseFeedUrlsFromQueue -- 360000
/usr/local/bin/docker-compose -f /home/mitch/podverse-ops/docker-compose.$1.yml run -d --name podverse_api_parser_worker_10 podverse_api_parser_worker npm run scripts:parseFeedUrlsFromQueue -- 360000
