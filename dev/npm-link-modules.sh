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

echo "Installing podverse-api dependencies..."
cd ../podverse-api
nvm use
rm -rf node_modules
npm install

echo "Installing podverse-external-services dependencies..."
cd ../podverse-external-services
nvm use
rm -rf node_modules
npm install

echo "Installing podverse-helpers dependencies..."
cd ../podverse-helpers
nvm use
rm -rf node_modules
npm install

echo "Installing podverse-orm dependencies..."
cd ../podverse-orm
nvm use
rm -rf node_modules
npm install

echo "Installing podverse-parser dependencies..."
cd ../podverse-parser
nvm use
rm -rf node_modules
npm install

echo "Installing podverse-queue dependencies..."
cd ../podverse-queue
nvm use
rm -rf node_modules
npm install

echo "Installing podverse-workers dependencies..."
cd ../podverse-workers
nvm use
rm -rf node_modules
npm install

# Link dependencies to npm

echo "Linking podverse-external-services dependency..."
cd ../podverse-external-services
nvm use
npm link

echo "Linking podverse-helpers dependency..."
cd ../podverse-helpers
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

echo "Linking podverse-queue dependency..."
cd ../podverse-queue
nvm use
npm link

# Link dependencies to consuming projects

echo "Linking podverse-api dependencies..."
cd ../podverse-api
nvm use
npm link podverse-helpers
npm link podverse-orm

echo "Linking podverse-external-services dependencies..."
cd ../podverse-external-services
nvm use
npm link podverse-helpers

echo "Linking podverse-orm dependencies..."
cd ../podverse-orm
nvm use
npm link podverse-helpers

echo "Linking podverse-parser dependencies..."
cd ../podverse-parser
nvm use
npm link podverse-external-services
npm link podverse-helpers
npm link podverse-orm

echo "Linking podverse-queue dependencies..."
cd ../podverse-queue
nvm use
npm link podverse-external-services
npm link podverse-helpers
npm link podverse-orm
npm link podverse-parser

echo "Linking podverse-workers dependencies..."
cd ../podverse-workers
nvm use
npm link podverse-helpers
npm link podverse-orm
npm link podverse-parser
npm link podverse-queue
