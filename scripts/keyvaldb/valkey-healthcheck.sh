#!/bin/sh
set -e

# Check if KEYVALDB_PASSWORD is set
if [ -n "$KEYVALDB_PASSWORD" ]; then
  # Use password for healthcheck
  valkey-cli -a "${KEYVALDB_PASSWORD}" ping
else
  # Backward compatibility: no password
  valkey-cli ping
fi
