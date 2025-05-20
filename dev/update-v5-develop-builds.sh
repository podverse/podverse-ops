cd ~/repos/podverse-api
git pull origin v5-develop

cd ~/repos/podverse-external-services
git pull origin v5-develop
rm -rf dist
npm install
npm run build

cd ~/repos/podverse-helpers
git pull origin v5-develop
rm -rf dist
npm install
npm run build

cd ~/repos/podverse-ops
git pull origin v5-develop

cd ~/repos/podverse-orm
git pull origin v5-develop
rm -rf dist
npm install
npm run build

cd ~/repos/podverse-parser
git pull origin v5-develop
rm -rf dist
npm install
npm run build

cd ~/repos/podverse-queue
git pull origin v5-develop
rm -rf dist
npm install
npm run build

cd ~/repos/podverse-workers
git pull origin v5-develop
rm -rf dist
npm install
npm run build
