#!/bin/bash

# Source nvm script
export NVM_DIR="$HOME/.nvm"
# This loads nvm
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
# This loads nvm bash_completion
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

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

echo "Installing podverse-partytime dependencies..."
cd ../podverse-partytime
nvm use
rm -rf node_modules
rm -rf dist
rm package-lock.json
npm install

echo "Installing podverse-helpers dependencies..."
cd ../podverse-helpers
nvm use
rm -rf node_modules
rm -rf dist
rm package-lock.json
npm install

echo "Installing podverse-external-services dependencies..."
cd ../podverse-external-services
nvm use
rm -rf node_modules
rm -rf dist
rm package-lock.json
npm install

echo "Installing podverse-notifications dependencies..."
cd ../podverse-notifications
nvm use
rm -rf node_modules
rm -rf dist
rm package-lock.json
npm install

echo "Installing podverse-orm dependencies..."
cd ../podverse-orm
nvm use
rm -rf node_modules
rm -rf dist
rm package-lock.json
npm install

echo "Installing podverse-parser dependencies..."
cd ../podverse-parser
nvm use
rm -rf node_modules
rm -rf dist
rm package-lock.json
npm install

echo "Installing podverse-mq dependencies..."
cd ../podverse-mq
nvm use
rm -rf node_modules
rm -rf dist
rm package-lock.json
npm install

echo "Installing podverse-workers dependencies..."
cd ../podverse-workers
nvm use
rm -rf node_modules
rm -rf dist
rm package-lock.json
npm install

echo "Installing podverse-api dependencies..."
cd ../podverse-api
nvm use
rm -rf node_modules
rm -rf dist
rm package-lock.json
npm install

echo "Installing podverse-web dependencies..."
cd ../podverse-web
nvm use
rm -rf node_modules
rm -rf dist
rm package-lock.json
npm install

echo "Installing podverse-qa dependencies..."
cd ../podverse-qa
nvm use
rm -rf node_modules
rm -rf dist
rm package-lock.json
npm install

# Link dependencies to npm

echo "Linking podverse-partytime dependency..."
cd ../podverse-partytime
nvm use
npm link

echo "Linking podverse-helpers dependency..."
cd ../podverse-helpers
nvm use
npm link

echo "Linking podverse-external-services dependency..."
cd ../podverse-external-services
nvm use
npm link

echo "Linking podverse-notifications dependency..."
cd ../podverse-notifications
nvm use
npm link

echo "Linking podverse-orm dependency..."
cd ../podverse-orm
nvm use
npm link

echo "Linking podverse-parser dependency..."
cd ../podverse-parser
nvm use
npm link

echo "Linking podverse-mq dependency..."
cd ../podverse-mq
nvm use
npm link

echo "Linking podverse-qa dependency..."
cd ../podverse-qa
nvm use
npm link

# Link dependencies to consuming projects

echo "Linking podverse-external-services dependencies..."
cd ../podverse-external-services
nvm use
npm link podverse-helpers

echo "Linking podverse-notifications dependencies..."
cd ../podverse-notifications
nvm use
npm link podverse-helpers podverse-external-services

echo "Linking podverse-orm dependencies..."
cd ../podverse-orm
nvm use
npm link podverse-helpers

echo "Linking podverse-parser dependencies..."
cd ../podverse-parser
nvm use
npm link podverse-partytime podverse-external-services podverse-helpers podverse-orm podverse-notifications

echo "Linking podverse-mq dependencies..."
cd ../podverse-mq
nvm use
npm link podverse-external-services podverse-helpers podverse-orm podverse-parser

echo "Linking podverse-workers dependencies..."
cd ../podverse-workers
nvm use
npm link podverse-external-services podverse-helpers podverse-orm podverse-parser podverse-mq

echo "Linking podverse-api dependencies..."
cd ../podverse-api
nvm use
npm link podverse-external-services podverse-helpers podverse-orm podverse-parser podverse-mq

echo "Linking podverse-web dependencies..."
cd ../podverse-web
nvm use
npm link podverse-helpers

echo "Linking podverse-qa dependencies..."
cd ../podverse-qa
nvm use
npm link podverse-helpers podverse-external-services podverse-orm podverse-parser

# Build all projects

echo "Building podverse-partytime..."
cd ../podverse-partytime
nvm use
npm run build

echo "Building podverse-helpers..."
cd ../podverse-helpers
nvm use
npm run build

echo "Building podverse-external-services..."
cd ../podverse-external-services
nvm use
npm run build

echo "Building podverse-notifications..."
cd ../podverse-notifications
nvm use
npm run build

echo "Building podverse-orm..."
cd ../podverse-orm
nvm use
npm run build

echo "Building podverse-parser..."
cd ../podverse-parser
nvm use
npm run build

echo "Building podverse-mq..."
cd ../podverse-mq
nvm use
npm run build

echo "Building podverse-workers..."
cd ../podverse-workers
nvm use
npm run build

echo "Building podverse-api..."
cd ../podverse-api
nvm use
npm run build:dev

echo "Building podverse-web..."
cd ../podverse-web
nvm use
npm run build

echo "Building podverse-qa..."
cd ../podverse-qa
nvm use
npm run build
