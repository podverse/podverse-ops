#!/usr/bin/env bash
# Connect to the PostgreSQL database via k3s port-forward
# Pulls credentials from the encrypted Kubernetes secret

set -euo pipefail

# ------------------------------------------------------------------
# CONFIGURATION
# ------------------------------------------------------------------
ENVIRONMENT="${1:-alpha}"
NAMESPACE="podverse-${ENVIRONMENT}"
SECRET_NAME="podverse-${ENVIRONMENT}-db-opaque"
SERVICE_NAME="podverse-db"
LOCAL_PORT="${2:-5432}"
REMOTE_PORT=5432

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# ------------------------------------------------------------------
# CHECK DEPENDENCIES
# ------------------------------------------------------------------
echo -e "${YELLOW}Checking dependencies...${NC}"

if ! command -v kubectl &> /dev/null; then
    echo -e "${RED}Error: kubectl is not installed${NC}"
    exit 1
fi

if ! command -v sops &> /dev/null; then
    echo -e "${RED}Error: sops is not installed${NC}"
    exit 1
fi

if ! command -v psql &> /dev/null; then
    echo -e "${RED}Error: psql is not installed${NC}"
    echo -e "${YELLOW}Run 'nix develop' to enter the dev environment${NC}"
    exit 1
fi

# ------------------------------------------------------------------
# EXTRACT CREDENTIALS FROM SECRET
# ------------------------------------------------------------------
echo -e "${YELLOW}Extracting credentials from secret...${NC}"

SECRET_FILE="./k8s/secrets/${SECRET_NAME}.enc.yaml"

if [ ! -f "$SECRET_FILE" ]; then
    echo -e "${RED}Error: Secret file not found at ${SECRET_FILE}${NC}"
    exit 1
fi

# Decrypt and extract credentials
POSTGRES_DB=$(sops -d "$SECRET_FILE" | grep -A 100 "^data:" | grep "POSTGRES_DB:" | awk '{print $2}' | base64 -d)
POSTGRES_USER=$(sops -d "$SECRET_FILE" | grep -A 100 "^data:" | grep "POSTGRES_USER:" | awk '{print $2}' | base64 -d)
POSTGRES_PASSWORD=$(sops -d "$SECRET_FILE" | grep -A 100 "^data:" | grep "POSTGRES_PASSWORD:" | awk '{print $2}' | base64 -d)

if [ -z "$POSTGRES_DB" ] || [ -z "$POSTGRES_USER" ] || [ -z "$POSTGRES_PASSWORD" ]; then
    echo -e "${RED}Error: Failed to extract credentials from secret${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Credentials extracted${NC}"
echo -e "  Database: ${POSTGRES_DB}"
echo -e "  User: ${POSTGRES_USER}"

# ------------------------------------------------------------------
# START PORT FORWARD
# ------------------------------------------------------------------
echo -e "${YELLOW}Starting port-forward to ${SERVICE_NAME}...${NC}"

# Kill any existing port-forward on this port
if lsof -Pi :${LOCAL_PORT} -sTCP:LISTEN -t >/dev/null 2>&1 ; then
    echo -e "${YELLOW}Port ${LOCAL_PORT} is already in use. Attempting to free it...${NC}"
    pkill -f "kubectl.*port-forward.*${SERVICE_NAME}" || true
    sleep 2
fi

# Start port-forward in background
kubectl port-forward -n "${NAMESPACE}" "service/${SERVICE_NAME}" ${LOCAL_PORT}:${REMOTE_PORT} > /dev/null 2>&1 &
PORT_FORWARD_PID=$!

# Give it a moment to establish
sleep 2

# Check if port-forward is running
if ! kill -0 $PORT_FORWARD_PID 2>/dev/null; then
    echo -e "${RED}Error: Failed to establish port-forward${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Port-forward established (PID: ${PORT_FORWARD_PID})${NC}"

# ------------------------------------------------------------------
# CLEANUP FUNCTION
# ------------------------------------------------------------------
cleanup() {
    echo -e "\n${YELLOW}Cleaning up...${NC}"
    if kill -0 $PORT_FORWARD_PID 2>/dev/null; then
        kill $PORT_FORWARD_PID
        echo -e "${GREEN}✓ Port-forward stopped${NC}"
    fi
}

trap cleanup EXIT INT TERM

# ------------------------------------------------------------------
# CONNECT TO DATABASE
# ------------------------------------------------------------------
echo -e "${GREEN}Connecting to database...${NC}"
echo -e "${YELLOW}(Press Ctrl+D or type \q to exit)${NC}\n"

# Connect using psql
PGPASSWORD="$POSTGRES_PASSWORD" psql -h localhost -p ${LOCAL_PORT} -U "${POSTGRES_USER}" -d "${POSTGRES_DB}"

# Cleanup will run automatically on exit
