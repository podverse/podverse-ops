docker rm $(docker stop $(docker ps -a -q --filter ancestor=podverse/podverse_admin))
docker image rm podverse/podverse_admin
docker-compose -f /home/mitch/podverse-ops/docker-compose.$1.yml up -d podverse_admin
