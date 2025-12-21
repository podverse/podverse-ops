#!/usr/bin/env bash
# VERSION: 1
# Helper to create the encrypted Database secret with the correct keys.

set -euo pipefail

echo "Running create_db_secret.sh"

# ------------------------------------------------------------------
# CONFIGURATION
# ------------------------------------------------------------------
SECRET_NAME="podverse-db-secret"
NAMESPACE="podverse-alpha"
# Outputting to k8s/secrets as requested (relative to where script is run, usually repo root)
OUTPUT_FILE="./k8s/secrets/podverse-db-secret.enc.yaml"

# ------------------------------------------------------------------
# INPUTS
# ------------------------------------------------------------------
echo "You are generating the PostgreSQL credentials."
echo "Press Enter to use the default value."
echo ""

# Standard defaults
DEFAULT_DB="postgres"
DEFAULT_USER="postgres"

read -p "POSTGRES_DB [${DEFAULT_DB}]: " INPUT_DB
POSTGRES_DB="${INPUT_DB:-$DEFAULT_DB}"

read -p "POSTGRES_USER [${DEFAULT_USER}]: " INPUT_USER
POSTGRES_USER="${INPUT_USER:-$DEFAULT_USER}"

echo ""
echo "--- SENSITIVE INPUTS ---"
# -s hides input
read -s -p "Enter POSTGRES_PASSWORD (Superuser): " POSTGRES_PASSWORD
echo ""
if [ -z "$POSTGRES_PASSWORD" ]; then echo "Error: Password required."; exit 1; fi

read -s -p "Enter POSTGRES_READ_PASSWORD (Read-only User): " POSTGRES_READ_PASSWORD
echo ""
if [ -z "$POSTGRES_READ_PASSWORD" ]; then echo "Error: Password required."; exit 1; fi

read -s -p "Enter POSTGRES_READ_WRITE_PASSWORD (App User): " POSTGRES_READ_WRITE_PASSWORD
echo ""
if [ -z "$POSTGRES_READ_WRITE_PASSWORD" ]; then echo "Error: Password required."; exit 1; fi

# ------------------------------------------------------------------
# GENERATION
# ------------------------------------------------------------------

# Ensure secrets dir exists
mkdir -p "$(dirname "$OUTPUT_FILE")"

echo "Generating secret manifest..."

# We use dry-run to generate the valid YAML without applying it.
kubectl create secret generic "${SECRET_NAME}" \
    --namespace "${NAMESPACE}" \
    --from-literal=POSTGRES_DB="${POSTGRES_DB}" \
    --from-literal=POSTGRES_USER="${POSTGRES_USER}" \
    --from-literal=POSTGRES_PASSWORD="${POSTGRES_PASSWORD}" \
    --from-literal=POSTGRES_READ_PASSWORD="${POSTGRES_READ_PASSWORD}" \
    --from-literal=POSTGRES_READ_WRITE_PASSWORD="${POSTGRES_READ_WRITE_PASSWORD}" \
    --dry-run=client -o yaml > temp_secret.yaml

echo "Encrypting with SOPS to ${OUTPUT_FILE}..."

# Encrypt the 'data' or 'stringData' fields
sops --encrypt --encrypted-regex '^(data|stringData)$' \
    temp_secret.yaml > "${OUTPUT_FILE}"

# Cleanup
rm temp_secret.yaml

echo "----------------------------------------------------"
echo "SUCCESS: Encrypted secret created at ${OUTPUT_FILE}"
echo "----------------------------------------------------"
echo "You can verify the values (if you have the key) by running:"
echo "sops -d ${OUTPUT_FILE}"