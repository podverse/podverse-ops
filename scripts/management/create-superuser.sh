#!/bin/bash
set -e

# Ensure required env vars exist
: "${SUPERUSER_EMAIL:?Missing SUPERUSER_EMAIL}"
: "${SUPERUSER_PASSWORD:?Missing SUPERUSER_PASSWORD}"

# Get the directory of this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Change to script directory
cd "$SCRIPT_DIR"

# Check if node_modules exists, if not install dependencies
if [ ! -d "node_modules" ]; then
  echo "Installing dependencies..."
  npm install --silent
fi

# Export environment variables needed by the Node.js script
export DB_HOST="${DB_HOST:-localhost}"
export DB_PORT="${DB_PORT:-5999}"
export DB_DATABASE="${DB_DATABASE:-${POSTGRES_DB:-postgres}}"
export POSTGRES_USER="${POSTGRES_USER:-postgres}"
export POSTGRES_PASSWORD="${POSTGRES_PASSWORD:-}"

# Run the Node.js script
node create-superuser.js
