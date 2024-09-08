#!/bin/bash

cd ../podverse-api
npm install

cd ../podverse-external-services
npm install
npm link

cd ../podverse-helpers
npm install
npm link

cd ../podverse-orm
npm install
npm link

cd ../podverse-parser
npm install
npm link

cd ../podverse-queue
npm install
npm link

cd ../podverse-workers
npm install

cd ../podverse-api
npm link podverse-helpers
npm link podverse-orm
npm link podverse-parser

cd ../podverse-external-services
npm link podverse-helpers

cd ../podverse-orm
npm link podverse-helpers

cd ../podverse-parser
npm link podverse-helpers
npm link podverse-orm

cd ../podverse-queue
npm link podverse-external-services
npm link podverse-helpers
npm link podverse-orm
npm link podverse-parser

cd ../podverse-workers
npm link podverse-helpers
npm link podverse-queue
