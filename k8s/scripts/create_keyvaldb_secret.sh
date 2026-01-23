#!/usr/bin/env bash
# VERSION: 1
# Filename: create_valkey_secret.sh
# Helper to create the encrypted Valkey secret.
# Maps inputs to KEYVALDB_PASSWORD (and generic PASSWORD for compatibility).

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

echo "Running create_keyvaldb_secret.sh"

# ENVIRONMENT INPUT
if [ "$AUTO_GEN" = true ]; then
  ENVIRONMENT="${1:-alpha}"
  echo "Auto-generating with environment: $ENVIRONMENT"
else
  read -r -p "Enter environment [alpha]: " ENVIRONMENT
fi
ENVIRONMENT="${ENVIRONMENT:-alpha}"

# Matches the secret name defined in podverse-alpha.yaml
SECRET_NAME="podverse-keyvaldb-opaque"
NAMESPACE="podverse-${ENVIRONMENT}"
OUTPUT_FILE="./k8s/secrets/podverse-${ENVIRONMENT}-keyvaldb-opaque.enc.yaml"

# ------------------------------------------------------------------
# INPUTS
# ------------------------------------------------------------------
if [ "$AUTO_GEN" = true ]; then
  echo "Auto-generating secrets..."
  KEYVALDB_PASSWORD=$(generate_password)
  echo "  KEYVALDB_PASSWORD: [generated]"
else
  echo ""
  echo "--- SENSITIVE INPUTS ---"
  read -r -s -p "Enter Valkey Password: " KEYVALDB_PASSWORD
  echo ""
  if [ -z "$KEYVALDB_PASSWORD" ]; then
    echo "Error: Password required."
    exit 1
  fi
fi

# --- GENERATION ---
mkdir -p "$(dirname "$OUTPUT_FILE")"
echo "Generating and encrypting secret..."

TMP_FILE="$(mktemp -t "${SECRET_NAME}.XXXXXX.yaml")"

# We create both KEYVALDB_PASSWORD and PASSWORD to ensure compatibility
# with various images or custom entrypoint scripts.
kubectl create secret generic "${SECRET_NAME}" \
  --namespace "${NAMESPACE}" \
  --from-literal=KEYVALDB_PASSWORD="${KEYVALDB_PASSWORD}" \
  --from-literal=PASSWORD="${KEYVALDB_PASSWORD}" \
  --dry-run=client -o yaml >"$TMP_FILE"

sops --encrypt --encrypted-regex '^(data|stringData)$' \
  --input-type=yaml "$TMP_FILE" >"${OUTPUT_FILE}"

rm -f "$TMP_FILE"

echo "----------------------------------------------------"
echo "SUCCESS: Encrypted secret created at ${OUTPUT_FILE}"
echo "----------------------------------------------------"
echo "You can verify the values (if you have the key) by running:"
echo "sops -d ${OUTPUT_FILE}"
echo ""
echo "You can apply the values (if you have the key) by running:"
echo "sops -d ${OUTPUT_FILE} | kubectl apply -f -"

