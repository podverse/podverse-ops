#!/usr/bin/env bash

# Step 1: Make sure the correct version of Node is used!
# You will need to run `nvm use` within podverse-ops.

# Step 2: Link modules
cd ../podverse-external-services
yarn link

cd ../podverse-orm
yarn link

cd ../podverse-parser
yarn link

cd ../podverse-shared
yarn link

cd ../podverse-workers
yarn link

# Step 3: Finish linking modules in each repo where they are needed.
# This has to happen last to guarantee the modules you are linking are available.

cd ../podverse-api
yarn link podverse-external-services
yarn link podverse-orm
yarn link podverse-parser
yarn link podverse-shared

cd ../podverse-external-services
yarn link podverse-shared

cd ../podverse-fdroid
yarn link podverse-parser
yarn link podverse-shared

cd ../podverse-orm
yarn link podverse-external-services
yarn link podverse-shared

cd ../podverse-parser
yarn link podverse-external-services
yarn link podverse-orm
yarn link podverse-shared

cd ../podverse-rn
yarn link podverse-parser
yarn link podverse-shared

cd ../podverse-serverless
yarn link podverse-external-services
yarn link podverse-orm
yarn link podverse-parser
yarn link podverse-shared

cd ../podverse-web
yarn link podverse-shared

cd ../podverse-workers
yarn link podverse-external-services
yarn link podverse-orm
yarn link podverse-parser
yarn link podverse-shared

cd ../podverse-ops
