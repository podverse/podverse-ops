#!/usr/bin/env bash
# VERSION: 1
# Helper to create the encrypted Workers secret (Podcast Index Keys).

set -euo pipefail

echo "Running create_workers_secret.sh"
SECRET_NAME="podverse-workers-secret"
NAMESPACE="podverse-alpha"
OUTPUT_FILE="./k8s/secrets/podverse-workers-secret.enc.yaml"

# --- INPUTS ---
echo "--- PODCAST INDEX API ---"
read -s -p "Enter PODCAST_INDEX_AUTH_KEY: " PI_AUTH
echo ""
if [ -z "$PI_AUTH" ]; then echo "Error: Auth Key required."; exit 1; fi

read -s -p "Enter PODCAST_INDEX_SECRET_KEY: " PI_SECRET
echo ""
if [ -z "$PI_SECRET" ]; then echo "Error: Secret Key required."; exit 1; fi

# --- GENERATION ---
mkdir -p "$(dirname "$OUTPUT_FILE")"
echo "Generating and encrypting secret..."

kubectl create secret generic "${SECRET_NAME}" \
    --namespace "${NAMESPACE}" \
    --from-literal=PODCAST_INDEX_AUTH_KEY="${PI_AUTH}" \
    --from-literal=PODCAST_INDEX_SECRET_KEY="${PI_SECRET}" \
    --dry-run=client -o yaml | \
sops --encrypt --encrypted-regex '^(data|stringData)$' \
    --input-type=yaml /dev/stdin > "${OUTPUT_FILE}"

echo "SUCCESS: Created ${OUTPUT_FILE}"
