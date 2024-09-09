#!/bin/bash

echo "Clearing npm cache..."
npm cache clean --force

echo "Installing podverse-api dependencies..."
cd ../podverse-api
rm -rf node_modules
npm install

echo "Installing podverse-external-services dependencies..."
cd ../podverse-external-services
rm -rf node_modules
npm install
npm link

echo "Installing podverse-helpers dependencies..."
cd ../podverse-helpers
rm -rf node_modules
npm install
npm link

echo "Installing podverse-orm dependencies..."
cd ../podverse-orm
rm -rf node_modules
npm install
npm link

echo "Installing podverse-parser dependencies..."
cd ../podverse-parser
rm -rf node_modules
npm install
npm link

echo "Installing podverse-queue dependencies..."
cd ../podverse-queue
rm -rf node_modules
npm install
npm link

echo "Installing podverse-workers dependencies..."
cd ../podverse-workers
rm -rf node_modules
npm install

echo "Linking podverse-api dependencies..."
cd ../podverse-api
npm link podverse-helpers
npm link podverse-orm
npm link podverse-parser

echo "Linking podverse-external-services dependencies..."
cd ../podverse-external-services
npm link podverse-helpers

echo "Linking podverse-orm dependencies..."
cd ../podverse-orm
npm link podverse-helpers

echo "Linking podverse-parser dependencies..."
cd ../podverse-parser
npm link podverse-helpers
npm link podverse-orm

echo "Linking podverse-queue dependencies..."
cd ../podverse-queue
npm link podverse-external-services
npm link podverse-helpers
npm link podverse-orm
npm link podverse-parser

echo "Linking podverse-workers dependencies..."
cd ../podverse-workers
npm link podverse-helpers
npm link podverse-orm
npm link podverse-queue
