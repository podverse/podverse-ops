#!/bin/sh
set -e

# Check if KEYVALDB_PASSWORD is set (required)
if [ -z "$KEYVALDB_PASSWORD" ]; then
  echo "ERROR: KEYVALDB_PASSWORD environment variable is required but not set"
  exit 1
fi

# Build valkey-server command with password and existing arguments
exec valkey-server \
  --requirepass "${KEYVALDB_PASSWORD}" \
  --save 900 1 \
  --appendonly yes
