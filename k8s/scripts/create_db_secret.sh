#!/usr/bin/env bash
# VERSION: 3 (Aliases + Secure Pipe)
# Helper to create the encrypted Database secret.
# It includes ALIASES so the same secret works for the DB (POSTGRES_*) and Apps (DB_*).

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

echo "Running create_db_secret.sh"

# ------------------------------------------------------------------
# ENVIRONMENT INPUT
# ------------------------------------------------------------------
if [ "$AUTO_GEN" = true ]; then
  ENVIRONMENT="${1:-alpha}"
  echo "Auto-generating with environment: $ENVIRONMENT"
else
  read -r -p "Enter environment [alpha]: " ENVIRONMENT
fi
ENVIRONMENT="${ENVIRONMENT:-alpha}"

# ------------------------------------------------------------------
# CONFIGURATION
# ------------------------------------------------------------------
SECRET_NAME="podverse-db-opaque"
NAMESPACE="podverse-${ENVIRONMENT}"
OUTPUT_FILE="./k8s/secrets/podverse-${ENVIRONMENT}-db-opaque.enc.yaml"

# ------------------------------------------------------------------
# INPUTS
# ------------------------------------------------------------------
DEFAULT_DB="postgres"
DEFAULT_USER="postgres"
DEFAULT_READ_USER="read"
DEFAULT_READ_WRITE_USER="read_write"

if [ "$AUTO_GEN" = true ]; then
  echo "Auto-generating secrets..."
  POSTGRES_DB="$DEFAULT_DB"
  POSTGRES_USER="$DEFAULT_USER"
  POSTGRES_READ_USER="$DEFAULT_READ_USER"
  POSTGRES_READ_WRITE_USER="$DEFAULT_READ_WRITE_USER"
  POSTGRES_PASSWORD=$(generate_password)
  POSTGRES_READ_PASSWORD=$(generate_password)
  POSTGRES_READ_WRITE_PASSWORD=$(generate_password)
  echo "  POSTGRES_DB: $POSTGRES_DB"
  echo "  POSTGRES_USER: $POSTGRES_USER"
  echo "  POSTGRES_PASSWORD: [generated]"
  echo "  POSTGRES_READ_PASSWORD: [generated]"
  echo "  POSTGRES_READ_WRITE_PASSWORD: [generated]"
else
  echo "You are generating the PostgreSQL credentials."
  echo "Press Enter to use the default value."
  echo ""

  echo ""
  echo "--- DBNAME INPUTS ---"
  read -r -p "POSTGRES_DB [${DEFAULT_DB}]: " INPUT_DB
  POSTGRES_DB="${INPUT_DB:-$DEFAULT_DB}"
  echo ""
  echo "--- USERNAME INPUTS ---"
  echo "--- ADMIN USER ---"
  read -r -p "POSTGRES_USER [${DEFAULT_USER}]: " INPUT_USER
  POSTGRES_USER="${INPUT_USER:-$DEFAULT_USER}"
  echo ""
  echo "--- READ-ONLY USER ---"
  read -r -p "POSTGRES_READ_USER [${DEFAULT_READ_USER}]: " INPUT_READ_USER
  POSTGRES_READ_USER="${INPUT_READ_USER:-$DEFAULT_READ_USER}"
  echo ""
  echo "--- READ-WRITE USER ---"
  read -r -p "POSTGRES_READ_WRITE_USER [${DEFAULT_READ_WRITE_USER}]: " INPUT_READ_WRITE_USER
  POSTGRES_READ_WRITE_USER="${INPUT_READ_WRITE_USER:-$DEFAULT_READ_WRITE_USER}"

  echo ""
  echo "--- SENSITIVE INPUTS ---"
  # -s hides input
  read -r -s -p "Enter POSTGRES_PASSWORD (Superuser): " POSTGRES_PASSWORD
  echo ""
  if [ -z "$POSTGRES_PASSWORD" ]; then
    echo "Error: Password required."
    exit 1
  fi

  read -r -s -p "Enter POSTGRES_READ_PASSWORD (Read-only User): " POSTGRES_READ_PASSWORD
  echo ""
  if [ -z "$POSTGRES_READ_PASSWORD" ]; then
    echo "Error: Password required."
    exit 1
  fi

  read -r -s -p "Enter POSTGRES_READ_WRITE_PASSWORD (App User): " POSTGRES_READ_WRITE_PASSWORD
  echo ""
  if [ -z "$POSTGRES_READ_WRITE_PASSWORD" ]; then
    echo "Error: Password required."
    exit 1
  fi
fi

# ------------------------------------------------------------------
# GENERATION
# ------------------------------------------------------------------

# Ensure secrets dir exists
mkdir -p "$(dirname "$OUTPUT_FILE")"

echo "Generating and encrypting secret..."

# We pipe kubectl output directly to sops.
# We include both the standard POSTGRES_* keys AND the DB_* aliases
# so the API and Workers can use this secret directly.

TMP_FILE="$(mktemp -t "${SECRET_NAME}.XXXXXX.yaml")"
kubectl create secret generic "${SECRET_NAME}" \
  --namespace "${NAMESPACE}" \
  --from-literal=DB_DATABASE="${POSTGRES_DB}" \
  --from-literal=POSTGRES_DB="${POSTGRES_DB}" \
  --from-literal=POSTGRES_USER="${POSTGRES_USER}" \
  --from-literal=POSTGRES_PASSWORD="${POSTGRES_PASSWORD}" \
  --from-literal=POSTGRES_READ_USER="${POSTGRES_READ_USER}" \
  --from-literal=POSTGRES_READ_PASSWORD="${POSTGRES_READ_PASSWORD}" \
  --from-literal=POSTGRES_READ_WRITE_USER="${POSTGRES_READ_WRITE_USER}" \
  --from-literal=POSTGRES_READ_WRITE_PASSWORD="${POSTGRES_READ_WRITE_PASSWORD}" \
  --from-literal=DB_READ_USERNAME="${POSTGRES_READ_USER}" \
  --from-literal=DB_READ_PASSWORD="${POSTGRES_READ_PASSWORD}" \
  --from-literal=DB_READ_WRITE_USERNAME="${POSTGRES_READ_WRITE_USER}" \
  --from-literal=DB_READ_WRITE_PASSWORD="${POSTGRES_READ_WRITE_PASSWORD}" \
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
