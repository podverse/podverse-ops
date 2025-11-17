#!/usr/bin/env bash
# Idempotent Artemis queue provisioning for local/sandbox
# Usage: ./scripts/mq/provision_queues.sh <container_name> <env_file_path> [queue1 queue2 ...]
set -euo pipefail

CONTAINER="${1:-}"
ENV_FILE="${2:-}"
shift 2 || true
QUEUES=("$@")

if [[ -z "$CONTAINER" || -z "$ENV_FILE" ]]; then
  echo "Usage: provision_queues.sh <container_name> <env_file> [queues...]"
  exit 1
fi

if [[ ${#QUEUES[@]} -eq 0 ]]; then
  QUEUES=(rss-fast rss-slow rss-live)
fi

if [[ ! -f "$ENV_FILE" ]]; then
  echo "Env file not found: $ENV_FILE"
  exit 1
fi

# shellcheck disable=SC1090
source "$ENV_FILE"

ARTEMIS_USER="${ARTEMIS_USER:-}"
ARTEMIS_PASSWORD="${ARTEMIS_PASSWORD:-}"

if [[ -z "$ARTEMIS_USER" || -z "$ARTEMIS_PASSWORD" ]]; then
  echo "ARTEMIS_USER or ARTEMIS_PASSWORD not set in $ENV_FILE"
  exit 1
fi

echo "[provision] Waiting for broker CLI directory..."
for i in $(seq 1 20); do
  if docker exec "$CONTAINER" test -d /var/lib/artemis-instance/bin; then
    break
  fi
  echo "[provision] Attempt $i: broker not ready yet"
  sleep 1
done

echo "[provision] Creating queues: ${QUEUES[*]}"
for q in "${QUEUES[@]}"; do
  echo "[provision] -> $q"
  # Artemis CLI create (idempotent; errors on existing queue are tolerated)
  docker exec "$CONTAINER" /var/lib/artemis-instance/bin/artemis queue create \
    --user "$ARTEMIS_USER" --password "$ARTEMIS_PASSWORD" \
    --url tcp://localhost:61616 \
    --name "$q" --address "$q" \
    --anycast --durable --auto-create-address --silent >/dev/null 2>&1 || true
done

echo "[provision] Done."