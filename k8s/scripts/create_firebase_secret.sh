#!/usr/bin/env bash
# VERSION: 1
# Helper to create the encrypted Firebase secret from a local JSON file.

set -euo pipefail

echo "Running create_firebase_secret.sh"
SECRET_NAME="podverse-workers-firebase-secret"
NAMESPACE="podverse-alpha"
OUTPUT_FILE="./k8s/secrets/podverse-workers-firebase-secret.enc.yaml"

# --- INPUTS ---
echo "Please enter the path to your 'firebase-key.json' file:"
read -e -p "Path: " FILE_PATH

# Verify file exists
if [ ! -f "$FILE_PATH" ]; then
    echo "Error: File not found at $FILE_PATH"
    exit 1
fi

# --- GENERATION ---
mkdir -p "$(dirname "$OUTPUT_FILE")"
echo "Reading file and encrypting secret..."

# We use --from-file to load the entire JSON content
kubectl create secret generic "${SECRET_NAME}" \
    --namespace "${NAMESPACE}" \
    --from-file=firebase-key.json="${FILE_PATH}" \
    --dry-run=client -o yaml | \
sops --encrypt --encrypted-regex '^(data|stringData)$' \
    --input-type=yaml /dev/stdin > "${OUTPUT_FILE}"

echo "SUCCESS: Created ${OUTPUT_FILE}"
