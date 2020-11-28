docker rm $(docker stop $(docker ps -a -q --filter ancestor=podverse/podverse_api))
docker image rm podverse/podverse_api
/usr/local/bin/docker-compose -f /home/mitch/podverse-ops/docker-compose.$1.yml run -d --name podverse_api_parser_worker_priority_1 podverse_api_parser_worker npm run scripts:parseFeedUrlsFromQueue -- 150000 priority
/usr/local/bin/docker-compose -f /home/mitch/podverse-ops/docker-compose.$1.yml run -d --name podverse_api_parser_worker_priority_2 podverse_api_parser_worker npm run scripts:parseFeedUrlsFromQueue -- 150000 priority
/usr/local/bin/docker-compose -f /home/mitch/podverse-ops/docker-compose.$1.yml run -d --name podverse_api_parser_worker_priority_3 podverse_api_parser_worker npm run scripts:parseFeedUrlsFromQueue -- 150000 priority
/usr/local/bin/docker-compose -f /home/mitch/podverse-ops/docker-compose.$1.yml run -d --name podverse_api_parser_worker_priority_4 podverse_api_parser_worker npm run scripts:parseFeedUrlsFromQueue -- 150000 priority
/usr/local/bin/docker-compose -f /home/mitch/podverse-ops/docker-compose.$1.yml run -d --name podverse_api_parser_worker_priority_5 podverse_api_parser_worker npm run scripts:parseFeedUrlsFromQueue -- 150000 priority
/usr/local/bin/docker-compose -f /home/mitch/podverse-ops/docker-compose.$1.yml run -d --name podverse_api_parser_worker_priority_6 podverse_api_parser_worker npm run scripts:parseFeedUrlsFromQueue -- 150000 priority
/usr/local/bin/docker-compose -f /home/mitch/podverse-ops/docker-compose.$1.yml run -d --name podverse_api_parser_worker_priority_7 podverse_api_parser_worker npm run scripts:parseFeedUrlsFromQueue -- 150000 priority
/usr/local/bin/docker-compose -f /home/mitch/podverse-ops/docker-compose.$1.yml run -d --name podverse_api_parser_worker_priority_8 podverse_api_parser_worker npm run scripts:parseFeedUrlsFromQueue -- 150000 priority

