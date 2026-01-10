#!/bin/bash

# Script to run npm audit in all npm module repos and summarize vulnerabilities

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Navigate up to the parent directory where all repos should be
REPOS_BASE_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

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
  "podverse-qa"
)

# Build full repo paths
REPOS=()
for repo_name in "${REPO_NAMES[@]}"; do
  REPOS+=("$REPOS_BASE_DIR/$repo_name")
done

# Associative array to store results
declare -A RESULTS

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

# Check which repos exist
existing_repos=()
for repo in "${REPOS[@]}"; do
  if [ -d "$repo" ]; then
    existing_repos+=("$repo")
  fi
done

if [ ${#existing_repos[@]} -eq 0 ]; then
  echo -e "${RED}ERROR: No repos found at $REPOS_BASE_DIR${NC}"
  echo -e "${YELLOW}Please ensure all podverse repos are in sibling folders next to each other.${NC}"
  exit 1
fi

echo -e "${BLUE}Found ${#existing_repos[@]} repo(s) to audit:${NC}"
for repo in "${existing_repos[@]}"; do
  echo -e "${BLUE}  - $(basename "$repo")${NC}"
done
echo ""

for repo in "${existing_repos[@]}"; do
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
  if [ $exit_code -eq 0 ]; then
    # No vulnerabilities
    RESULTS["$repo_name"]="0"
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
    
    RESULTS["$repo_name"]="$total_vulns"
    
    if [ "$total_vulns" = "?" ]; then
      echo -e "${YELLOW}⚠ Could not determine vulnerability count (exit code: $exit_code)${NC}"
    elif [ "$total_vulns" = "0" ]; then
      echo -e "${GREEN}✓ No vulnerabilities found${NC}"
    else
      echo -e "${RED}✗ Found $total_vulns vulnerabilities${NC}"
    fi
  fi
  
  echo ""
done

# Print summary
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}SUMMARY OF VULNERABILITIES${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

total_vulnerabilities=0
repos_with_vulns=0

for repo in "${!RESULTS[@]}"; do
  count="${RESULTS[$repo]}"
  
  if [ "$count" != "?" ] && [ "$count" != "0" ]; then
    echo -e "${RED}$repo: $count vulnerabilities${NC}"
    repos_with_vulns=$((repos_with_vulns + 1))
    total_vulnerabilities=$((total_vulnerabilities + count))
  elif [ "$count" = "0" ]; then
    echo -e "${GREEN}$repo: No vulnerabilities${NC}"
  else
    echo -e "${YELLOW}$repo: Unknown status${NC}"
  fi
done

echo ""
echo -e "${BLUE}========================================${NC}"
if [ $repos_with_vulns -eq 0 ]; then
  echo -e "${GREEN}All repos are clean! No vulnerabilities found.${NC}"
else
  echo -e "${RED}Total vulnerabilities across $repos_with_vulns repo(s): $total_vulnerabilities${NC}"
fi
echo -e "${BLUE}========================================${NC}"
