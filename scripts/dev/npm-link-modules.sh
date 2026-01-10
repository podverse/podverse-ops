#!/bin/bash

# Source nvm script
export NVM_DIR="$HOME/.nvm"
# This loads nvm
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
# This loads nvm bash_completion
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# Get directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Navigate up to parent directory where all repos should be
# Script is at: podverse-ops/scripts/dev/
# Repos are at: repos/ (3 levels up from script)
REPOS_BASE_DIR="$(cd "$SCRIPT_DIR/../../.." && pwd)"

# Check if repos are in the same directory as podverse-ops
if [ ! -d "$REPOS_BASE_DIR/podverse-helpers" ]; then
  # Try going up one more level (repos are sibling to podverse-ops)
  REPOS_BASE_DIR="$(cd "$SCRIPT_DIR/../../../.." && pwd)"
fi

# Repos to process (in dependency order)
REPOS=(
  "partytime"
  "podverse-helpers"
  "podverse-external-services"
  "podverse-notifications"
  "podverse-orm"
  "podverse-parser"
  "podverse-mq"
  "podverse-workers"
  "podverse-api"
  "podverse-web"
  "podverse-qa"
)

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

# Install dependencies for each repo
for repo in "${REPOS[@]}"; do
  repo_path="$REPOS_BASE_DIR/$repo"
  
  if [ ! -d "$repo_path" ]; then
    echo "Skipping $repo (directory not found at $repo_path)"
    continue
  fi
  
  echo "Installing $repo dependencies..."
  cd "$repo_path"
  nvm use
  rm -rf node_modules
  rm -rf dist
  rm package-lock.json
  npm install
done

# Link dependencies to npm

echo "Linking podverse-partytime dependency..."
cd "$REPOS_BASE_DIR/partytime"
nvm use
npm link

echo "Linking podverse-helpers dependency..."
cd "$REPOS_BASE_DIR/podverse-helpers"
nvm use
npm link

echo "Linking podverse-external-services dependency..."
cd "$REPOS_BASE_DIR/podverse-external-services"
nvm use
npm link

echo "Linking podverse-notifications dependency..."
cd "$REPOS_BASE_DIR/podverse-notifications"
nvm use
npm link

echo "Linking podverse-orm dependency..."
cd "$REPOS_BASE_DIR/podverse-orm"
nvm use
npm link

echo "Linking podverse-parser dependency..."
cd "$REPOS_BASE_DIR/podverse-parser"
nvm use
npm link

echo "Linking podverse-mq dependency..."
cd "$REPOS_BASE_DIR/podverse-mq"
nvm use
npm link

echo "Linking podverse-qa dependency..."
cd "$REPOS_BASE_DIR/podverse-qa"
nvm use
npm link

# Link dependencies to consuming projects

echo "Linking podverse-external-services dependencies..."
cd "$REPOS_BASE_DIR/podverse-external-services"
nvm use
npm link podverse-helpers

echo "Linking podverse-notifications dependencies..."
cd "$REPOS_BASE_DIR/podverse-notifications"
nvm use
npm link podverse-helpers podverse-external-services

echo "Linking podverse-orm dependencies..."
cd "$REPOS_BASE_DIR/podverse-orm"
nvm use
npm link podverse-helpers

echo "Linking podverse-parser dependencies..."
cd "$REPOS_BASE_DIR/podverse-parser"
nvm use
npm link podverse-partytime podverse-external-services podverse-helpers podverse-orm podverse-notifications

echo "Linking podverse-mq dependencies..."
cd "$REPOS_BASE_DIR/podverse-mq"
nvm use
npm link podverse-external-services podverse-helpers podverse-orm podverse-parser

echo "Linking podverse-workers dependencies..."
cd "$REPOS_BASE_DIR/podverse-workers"
nvm use
npm link podverse-external-services podverse-helpers podverse-orm podverse-parser podverse-mq

echo "Linking podverse-api dependencies..."
cd "$REPOS_BASE_DIR/podverse-api"
nvm use
npm link podverse-external-services podverse-helpers podverse-orm podverse-parser podverse-mq

echo "Linking podverse-web dependencies..."
cd "$REPOS_BASE_DIR/podverse-web"
nvm use
npm link podverse-helpers

echo "Linking podverse-qa dependencies..."
cd "$REPOS_BASE_DIR/podverse-qa"
nvm use
npm link podverse-helpers podverse-external-services podverse-orm podverse-parser

# Build all projects

echo "Building podverse-partytime..."
cd "$REPOS_BASE_DIR/partytime"
nvm use
npm run build

echo "Building podverse-helpers..."
cd "$REPOS_BASE_DIR/podverse-helpers"
nvm use
npm run build

echo "Building podverse-external-services..."
cd "$REPOS_BASE_DIR/podverse-external-services"
nvm use
npm run build

echo "Building podverse-notifications..."
cd "$REPOS_BASE_DIR/podverse-notifications"
nvm use
npm run build

echo "Building podverse-orm..."
cd "$REPOS_BASE_DIR/podverse-orm"
nvm use
npm run build

echo "Building podverse-parser..."
cd "$REPOS_BASE_DIR/podverse-parser"
nvm use
npm run build

echo "Building podverse-mq..."
cd "$REPOS_BASE_DIR/podverse-mq"
nvm use
npm run build

echo "Building podverse-workers..."
cd "$REPOS_BASE_DIR/podverse-workers"
nvm use
npm run build

echo "Building podverse-api..."
cd "$REPOS_BASE_DIR/podverse-api"
nvm use
npm run build:dev

echo "Building podverse-web..."
cd "$REPOS_BASE_DIR/podverse-web"
nvm use
npm run build

echo "Building podverse-qa..."
cd "$REPOS_BASE_DIR/podverse-qa"
nvm use
npm run build
