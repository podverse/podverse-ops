#!/usr/bin/env bash
# VERSION: 1
# Helper to create the encrypted Firebase secret from a local JSON file.

set -euo pipefail

# ------------------------------------------------------------------
# CONFIGURATION
# ------------------------------------------------------------------
AUTO_GEN=false

# Check for --auto-gen flag
if [[ "${1:-}" == "--auto-gen" ]]; then
    AUTO_GEN=true
    shift || true
fi

echo "Running create_firebase_secret.sh"

# ENVIRONMENT INPUT
if [ "$AUTO_GEN" = true ]; then
    ENVIRONMENT="${1:-alpha}"
    echo "Auto-generating with environment: $ENVIRONMENT"
else
    read -r -p "Enter environment [alpha]: " ENVIRONMENT
fi
ENVIRONMENT="${ENVIRONMENT:-alpha}"

SECRET_NAME="podverse-workers-firebase-opaque"
NAMESPACE="podverse-${ENVIRONMENT}"
OUTPUT_FILE="./k8s/secrets/podverse-${ENVIRONMENT}-workers-firebase-opaque.enc.yaml"

# ------------------------------------------------------------------
# INPUTS
# ------------------------------------------------------------------
if [ "$AUTO_GEN" = true ]; then
    # For Firebase, we need a real file, so we look for it in standard location
    FIREBASE_LOCATIONS=(
        "./config/firebase/firebase-key.json"
        "./firebase-key.json"
        "${HOME}/.config/podverse/firebase-key.json"
    )
    FILE_PATH=""
    for loc in "${FIREBASE_LOCATIONS[@]}"; do
        if [ -f "$loc" ]; then
            FILE_PATH="$loc"
            break
        fi
    done
    if [ -z "$FILE_PATH" ]; then
        echo "Error: --auto-gen requires firebase-key.json in standard location"
        exit 1
    fi
    echo "Using Firebase key: $FILE_PATH"
else
    echo "Please enter the path to your 'firebase-key.json' file:"
    read -r -e -p "Path: " FILE_PATH
fi

# Verify file exists
if [ ! -f "$FILE_PATH" ]; then
    echo "Error: File not found at $FILE_PATH"
    exit 1
fi

# --- GENERATION ---
mkdir -p "$(dirname "$OUTPUT_FILE")"
echo "Reading file and encrypting secret..."

# We use --from-file to load the entire JSON content
TMP_FILE="$(mktemp -t "${SECRET_NAME}.XXXXXX.yaml")"
kubectl create secret generic "${SECRET_NAME}" \
    --namespace "${NAMESPACE}" \
    --from-file=firebase-key.json="${FILE_PATH}" \
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