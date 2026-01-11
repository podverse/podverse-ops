#!/usr/bin/env bash
# Connect to the ActiveMQ Artemis Web Console via k3s port-forward
# Pulls credentials from the encrypted Kubernetes secret

set -euo pipefail

# ------------------------------------------------------------------
# CONFIGURATION
# ------------------------------------------------------------------
ENVIRONMENT="${1:-alpha}"
NAMESPACE="podverse-${ENVIRONMENT}"
SECRET_NAME="podverse-${ENVIRONMENT}-mq-opaque"
SERVICE_NAME="podverse-mq"
LOCAL_PORT="${2:-8161}"
REMOTE_PORT=8161

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
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
ARTEMIS_USER=$(sops -d "$SECRET_FILE" | grep -A 100 "^data:" | grep "ARTEMIS_USER:" | awk '{print $2}' | base64 -d)
ARTEMIS_PASSWORD=$(sops -d "$SECRET_FILE" | grep -A 100 "^data:" | grep "ARTEMIS_PASSWORD:" | awk '{print $2}' | base64 -d)

if [ -z "$ARTEMIS_USER" ] || [ -z "$ARTEMIS_PASSWORD" ]; then
    echo -e "${RED}Error: Failed to extract credentials from secret${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Credentials extracted${NC}"

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
# DISPLAY CONNECTION INFO
# ------------------------------------------------------------------
echo ""
echo -e "${GREEN}══════════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}  ActiveMQ Artemis Web Console${NC}"
echo -e "${GREEN}══════════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "  ${CYAN}URL:${NC}      http://localhost:${LOCAL_PORT}/console"
echo ""
echo -e "  ${CYAN}Username:${NC} ${ARTEMIS_USER}"
echo -e "  ${CYAN}Password:${NC} ${ARTEMIS_PASSWORD}"
echo ""
echo -e "${GREEN}══════════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "${YELLOW}Press Ctrl+C to stop the port-forward and exit${NC}"
echo ""

# Wait for user to terminate
wait $PORT_FORWARD_PID
