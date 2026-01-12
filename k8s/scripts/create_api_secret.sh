#!/usr/bin/env bash
# VERSION: 1
# Helper to create the encrypted API secret.

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
    uuidgen
}

echo "Running create_api_secret.sh"

# ENVIRONMENT INPUT
if [ "$AUTO_GEN" = true ]; then
    ENVIRONMENT="${1:-alpha}"
    echo "Auto-generating with environment: $ENVIRONMENT"
else
    read -r -p "Enter environment [alpha]: " ENVIRONMENT
fi
ENVIRONMENT="${ENVIRONMENT:-alpha}"

SECRET_NAME="podverse-api-opaque"
NAMESPACE="podverse-${ENVIRONMENT}"
OUTPUT_FILE="./k8s/secrets/podverse-${ENVIRONMENT}-api-opaque.enc.yaml"

# ------------------------------------------------------------------
# INPUTS
# ------------------------------------------------------------------
if [ "$AUTO_GEN" = true ]; then
    echo "Auto-generating secrets..."
    AUTH_JWT_SECRET=$(generate_password)
    MAILER_PASSWORD=$(generate_password)
    echo "  AUTH_JWT_SECRET: [generated]"
    echo "  MAILER_PASSWORD: [generated]"
else
    echo "--- AUTHENTICATION ---"
    read -r -s -p "Enter AUTH_JWT_SECRET (Random String): " AUTH_JWT_SECRET
    echo ""
    if [ -z "$AUTH_JWT_SECRET" ]; then echo "Error: JWT Secret required."; exit 1; fi

    echo ""
    echo "--- MAILER (Optional - Press Enter to skip) ---"
    read -r -s -p "Enter MAILER_PASSWORD: " MAILER_PASSWORD
    echo ""
fi

# --- GENERATION ---
mkdir -p "$(dirname "$OUTPUT_FILE")"
echo "Generating and encrypting secret..."

TMP_FILE="$(mktemp -t "${SECRET_NAME}.XXXXXX.yaml")"
kubectl create secret generic "${SECRET_NAME}" \
    --namespace "${NAMESPACE}" \
    --from-literal=AUTH_JWT_SECRET="${AUTH_JWT_SECRET}" \
    --from-literal=MAILER_PASSWORD="${MAILER_PASSWORD}" \
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