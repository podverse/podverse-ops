#!/bin/bash

# Script to run npm audit in all npm module repos and summarize vulnerabilities

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Navigate up to parent directory where all repos should be
# Script is at: podverse-ops/scripts/audit/
# Repos are at: repos/ (3 levels up from script)
REPOS_BASE_DIR="$(cd "$SCRIPT_DIR/../../.." && pwd)"

# Check if repos are in the expected location
if [ ! -d "$REPOS_BASE_DIR/podverse-helpers" ]; then
  echo -e "${RED}ERROR: No repos found at $REPOS_BASE_DIR${NC}"
  echo -e "${YELLOW}Please ensure all podverse repos are in sibling folders next to each other.${NC}"
  exit 1
fi

# Array of podverse repos that might have npm packages
# These are relative paths from the base directory
REPO_NAMES=(
  "podverse-helpers"
  "podverse-external-services"
  "podverse-notifications"
  "podverse-orm"
  "podverse-parser"
  "podverse-mq"
  "podverse-api"
  "podverse-web"
  "podverse-workers"
  "podverse-qa",
  "podverse-management-api",
  "podverse-management"
)

# Build full repo paths and check which repos exist
REPOS=()
for repo_name in "${REPO_NAMES[@]}"; do
  repo_path="$REPOS_BASE_DIR/$repo_name"
  if [ -d "$repo_path" ]; then
    REPOS+=("$repo_path")
  fi
done

# Arrays to store results (bash 3.x compatible - no associative arrays)
REPO_RESULTS=()
VULN_COUNTS=()

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Running npm audit on all repos${NC}"
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Base directory: $REPOS_BASE_DIR${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

if [ ${#REPOS[@]} -eq 0 ]; then
  echo -e "${RED}ERROR: No repos found at $REPOS_BASE_DIR${NC}"
  echo -e "${YELLOW}Please ensure all podverse repos are in sibling folders next to each other.${NC}"
  exit 1
fi

echo -e "${BLUE}Found ${#REPOS[@]} repo(s) to audit:${NC}"
for repo in "${REPOS[@]}"; do
  echo -e "${BLUE}  - $(basename "$repo")${NC}"
done
echo ""

for repo in "${REPOS[@]}"; do
  repo_name=$(basename "$repo")
  
  # Check if package.json exists
  if [ ! -f "$repo/package.json" ]; then
    echo -e "${YELLOW}Skipping $repo_name (no package.json)${NC}"
    continue
  fi
  
  echo -e "${BLUE}Auditing $repo_name...${NC}"
  cd "$repo" || continue
  
  # Run npm audit and capture output
  audit_output=$(npm audit --json 2>&1)
  exit_code=$?
  
  # Parse the JSON output to get vulnerability counts
  total_vulns="0"
  if [ $exit_code -eq 0 ]; then
    # No vulnerabilities
    echo -e "${GREEN}✓ No vulnerabilities found${NC}"
  else
    # Parse the JSON to count vulnerabilities
    # npm audit returns non-zero even if vulnerabilities exist
    total_vulns=$(echo "$audit_output" | jq -r '.metadata.vulnerabilities.total // 0' 2>/dev/null)
    
    if [ "$total_vulns" = "0" ] || [ -z "$total_vulns" ]; then
      # Try alternative parsing if jq fails or returns 0
      total_vulns=$(echo "$audit_output" | grep -oP 'found \K[0-9]+' | head -1)
      if [ -z "$total_vulns" ]; then
        total_vulns="?"
      fi
    fi
    
    if [ "$total_vulns" = "?" ]; then
      echo -e "${YELLOW}⚠ Could not determine vulnerability count (exit code: $exit_code)${NC}"
    elif [ "$total_vulns" = "0" ]; then
      echo -e "${GREEN}✓ No vulnerabilities found${NC}"
    else
      echo -e "${RED}✗ Found $total_vulns vulnerabilities${NC}"
    fi
  fi
  
  # Store results in parallel arrays (bash 3.x compatible)
  REPO_RESULTS+=("$repo_name")
  VULN_COUNTS+=("$total_vulns")
  
  echo ""
done

# Print summary
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}SUMMARY OF VULNERABILITIES${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

total_vulnerabilities=0
repos_with_vulns=0

# Iterate through parallel arrays (bash 3.x compatible)
i=0
while [ $i -lt ${#REPO_RESULTS[@]} ]; do
  repo="${REPO_RESULTS[$i]}"
  count="${VULN_COUNTS[$i]}"
  
  if [ "$count" != "?" ] && [ "$count" != "0" ]; then
    echo -e "${RED}$repo: $count vulnerabilities${NC}"
    repos_with_vulns=$((repos_with_vulns + 1))
    total_vulnerabilities=$((total_vulnerabilities + count))
  elif [ "$count" = "0" ]; then
    echo -e "${GREEN}$repo: No vulnerabilities${NC}"
  else
    echo -e "${YELLOW}$repo: Unknown status${NC}"
  fi
  
  i=$((i + 1))
done

echo ""
echo -e "${BLUE}========================================${NC}"
if [ $repos_with_vulns -eq 0 ]; then
  echo -e "${GREEN}All repos are clean! No vulnerabilities found.${NC}"
else
  echo -e "${RED}Total vulnerabilities across $repos_with_vulns repo(s): $total_vulnerabilities${NC}"
fi
echo -e "${BLUE}========================================${NC}"
