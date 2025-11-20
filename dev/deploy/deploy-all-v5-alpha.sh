cd ~/repos/podverse-helpers
git checkout v5-develop
git pull origin v5-develop
git checkout v5-alpha
git pull origin v5-develop
git push origin v5-alpha
git checkout v5-develop

sleep 60

cd ~/repos/podverse-external-services
git checkout v5-develop
git pull origin v5-develop
git checkout v5-alpha
git pull origin v5-develop
git push origin v5-alpha
git checkout v5-develop

sleep 60

cd ~/repos/podverse-orm
git checkout v5-develop
git pull origin v5-develop
git checkout v5-alpha
git pull origin v5-develop
git push origin v5-alpha
git checkout v5-develop

sleep 60

cd ~/repos/podverse-parser
git checkout v5-develop
git pull origin v5-develop
git checkout v5-alpha
git pull origin v5-develop
git push origin v5-alpha
git checkout v5-develop

sleep 60

cd ~/repos/podverse-mq
git checkout v5-develop
git pull origin v5-develop
git checkout v5-alpha
git pull origin v5-develop
git push origin v5-alpha
git checkout v5-develop

sleep 60

cd ~/repos/podverse-workers
git checkout v5-develop
git pull origin v5-develop
git checkout v5-alpha
git pull origin v5-develop
git push origin v5-alpha
git checkout v5-develop

sleep 60

cd ~/repos/podverse-api
git checkout v5-develop
git pull origin v5-develop
git checkout v5-alpha
git pull origin v5-develop
git push origin v5-alpha
git checkout v5-develop
