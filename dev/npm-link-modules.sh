#!/bin/bash

# List all globally linked packages
linked_packages=$(npm ls -g --depth=0 --link=true --parseable | tail -n +2)

# Unlink each globally linked package
for package in $linked_packages; do
  npm unlink -g "$package"
done

# Delete and reinstall all node_modules

# Clean npm cache
npm cache clean --force

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

echo "Installing podverse-helpers dependencies..."
cd ../podverse-helpers
rm -rf node_modules
npm install

echo "Installing podverse-orm dependencies..."
cd ../podverse-orm
rm -rf node_modules
npm install

echo "Installing podverse-parser dependencies..."
cd ../podverse-parser
rm -rf node_modules
npm install

echo "Installing podverse-queue dependencies..."
cd ../podverse-queue
rm -rf node_modules
npm install

echo "Installing podverse-workers dependencies..."
cd ../podverse-workers
rm -rf node_modules
npm install

# Link dependencies to npm

echo "Linking podverse-external-services dependency..."
cd ../podverse-external-services
npm link

echo "Linking podverse-helpers dependency..."
cd ../podverse-helpers
npm link

echo "Linking podverse-orm dependency..."
cd ../podverse-orm
npm link

echo "Linking podverse-parser dependency..."
cd ../podverse-parser
npm link

echo "Linking podverse-queue dependency..."
cd ../podverse-queue
npm link

# Link dependencies to conuming projects

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
npm link podverse-external-services
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
npm link podverse-parser
npm link podverse-queue
