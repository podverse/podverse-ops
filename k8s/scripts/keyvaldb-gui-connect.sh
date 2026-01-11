#!/usr/bin/env bash
# Connect to the RedisInsight GUI for Valkey so you can inspect the dataset.

set -euo pipefail

# ------------------------------------------------------------------
# CONFIGURATION
# ------------------------------------------------------------------
ENVIRONMENT="${1:-alpha}"
NAMESPACE="podverse-${ENVIRONMENT}"
SECRET_NAME="podverse-${ENVIRONMENT}-keyvaldb-opaque"
SERVICE_NAME="podverse-keyvaldb-gui"
LOCAL_PORT="${2:-8001}"
REMOTE_PORT=8001

# Colors for user-friendly output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${YELLOW}Checking dependencies...${NC}"

if ! command -v kubectl &> /dev/null; then
    echo -e "${RED}Error: kubectl is not installed${NC}"
    exit 1
fi

if ! command -v sops &> /dev/null; then
    echo -e "${RED}Error: sops is not installed${NC}"
    exit 1
fi

# ------------------------------------------------------------------
# EXTRACT VALKEY PASSWORD
# ------------------------------------------------------------------
echo -e "${YELLOW}Extracting credentials from secret...${NC}"

SECRET_FILE="./k8s/secrets/${SECRET_NAME}.enc.yaml"

if [ ! -f "$SECRET_FILE" ]; then
    echo -e "${RED}Error: Secret file not found at ${SECRET_FILE}${NC}"
    exit 1
fi

VALKEY_PASSWORD=$(sops -d "$SECRET_FILE" | grep -A 100 "^data:" | grep "VALKEY_PASSWORD:" | awk '{print $2}' | base64 -d)

if [ -z "$VALKEY_PASSWORD" ]; then
    echo -e "${RED}Error: Failed to extract VALKEY_PASSWORD${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Credentials extracted${NC}"

# ------------------------------------------------------------------
# START PORT FORWARD
# ------------------------------------------------------------------
echo -e "${YELLOW}Starting port-forward to ${SERVICE_NAME}...${NC}"

# Free the port if in use so the script can bind cleanly
if lsof -Pi :${LOCAL_PORT} -sTCP:LISTEN -t >/dev/null 2>&1 ; then
    echo -e "${YELLOW}Port ${LOCAL_PORT} is already in use. Attempting to free it...${NC}"
    pkill -f "kubectl.*port-forward.*${SERVICE_NAME}" || true
    sleep 2
fi

kubectl port-forward -n "${NAMESPACE}" "service/${SERVICE_NAME}" ${LOCAL_PORT}:${REMOTE_PORT} > /dev/null 2>&1 &
PORT_FORWARD_PID=$!

sleep 2

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
# DISPLAY CONNECTION INFO
# ------------------------------------------------------------------
echo ""
echo -e "${GREEN}══════════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}  Valkey RedisInsight GUI${NC}"
echo -e "${GREEN}══════════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "  ${CYAN}URL:${NC}      http://localhost:${LOCAL_PORT}/"
echo ""
echo -e "  ${CYAN}Valkey Password:${NC} ${VALKEY_PASSWORD}"
echo ""
echo -e "${GREEN}══════════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "${YELLOW}Press Ctrl+C to stop the port-forward and exit${NC}"
echo ""

wait $PORT_FORWARD_PID