docker rm $(docker stop $(docker ps -a -q --filter ancestor=podverse/podverse_api))
docker image rm podverse/podverse_api
docker-compose -f /home/mitch/podverse-ops/docker-compose.$1.yml up -d podverse_api
