#!/usr/bin/env bash
# VERSION: 1
# Helper to create the encrypted MQ secret.
# Includes aliases: ARTEMIS_* (for Broker) and MESSAGE_QUEUE_* (for Workers).

set -euo pipefail

# ------------------------------------------------------------------
# CONFIGURATION
# ------------------------------------------------------------------
PASSWORD_LENGTH=20
AUTO_GEN=false

# Check for --auto-gen flag
if [[ "${1:-}" == "--auto-gen" ]]; then
    AUTO_GEN=true
    shift || true
fi

# Generate secure random password
generate_password() {
    pwgen -s "$PASSWORD_LENGTH" 1
}

echo "Running create_mq_secret.sh"

# ENVIRONMENT INPUT
if [ "$AUTO_GEN" = true ]; then
    ENVIRONMENT="${1:-alpha}"
    echo "Auto-generating with environment: $ENVIRONMENT"
else
    read -r -p "Enter environment [alpha]: " ENVIRONMENT
fi
ENVIRONMENT="${ENVIRONMENT:-alpha}"

SECRET_NAME="podverse-mq-opaque"
NAMESPACE="podverse-${ENVIRONMENT}"
OUTPUT_FILE="./k8s/secrets/podverse-${ENVIRONMENT}-mq-opaque.enc.yaml"

# ------------------------------------------------------------------
# INPUTS
# ------------------------------------------------------------------
DEFAULT_USER="admin"

if [ "$AUTO_GEN" = true ]; then
    echo "Auto-generating secrets..."
    MQ_USER="$DEFAULT_USER"
    MQ_PASSWORD=$(generate_password)
    echo "  MQ_USER: $MQ_USER"
    echo "  MQ_PASSWORD: [generated]"
else
    echo ""
    echo "--- USERNAME INPUTS ---"

    read -r -p "Enter MQ Username [${DEFAULT_USER}]: " INPUT_USER
    MQ_USER="${INPUT_USER:-$DEFAULT_USER}"

    echo ""
    echo "--- SENSITIVE INPUTS ---"
    read -r -s -p "Enter MQ Password: " MQ_PASSWORD
    echo ""
    if [ -z "$MQ_PASSWORD" ]; then echo "Error: Password required."; exit 1; fi
fi

# --- GENERATION ---
mkdir -p "$(dirname "$OUTPUT_FILE")"
echo "Generating and encrypting secret..."

TMP_FILE="$(mktemp -t "${SECRET_NAME}.XXXXXX.yaml")"
kubectl create secret generic "${SECRET_NAME}" \
    --namespace "${NAMESPACE}" \
    --from-literal=ARTEMIS_USER="${MQ_USER}" \
    --from-literal=ARTEMIS_PASSWORD="${MQ_PASSWORD}" \
    \
    --from-literal=MESSAGE_QUEUE_USERNAME="${MQ_USER}" \
    --from-literal=MESSAGE_QUEUE_PASSWORD="${MQ_PASSWORD}" \
    \
    --dry-run=client -o yaml > "$TMP_FILE"

sops --encrypt --encrypted-regex '^(data|stringData)$' \
    --input-type=yaml "$TMP_FILE" > "${OUTPUT_FILE}"

rm -f "$TMP_FILE"

echo "----------------------------------------------------"
echo "SUCCESS: Encrypted secret created at ${OUTPUT_FILE}"
echo "----------------------------------------------------"
echo "You can verify the values (if you have the key) by running:"
echo "sops -d ${OUTPUT_FILE}"
echo ""
echo "You can apply the values (if you have the key) by running:"
echo "sops -d ${OUTPUT_FILE} | kubectl apply -f -"