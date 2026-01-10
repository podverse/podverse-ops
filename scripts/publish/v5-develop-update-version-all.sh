#!/bin/bash

# Update Version All Packages Script
# This script updates the version in package.json and package-lock.json for all podverse packages.
# It commits and pushes the changes to v5-develop branch.

set -e

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Get script directory for finding audit script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Base directory for repos (parent of podverse-ops)
# Script is at: podverse-ops/scripts/publish/v5-develop-update-version-all.sh
# Repos are at: (parent directory, 3 levels up from script)
REPOS_DIR="$(cd "$SCRIPT_DIR/../../.." && pwd)"

# Check if repos are in the expected location
if [ ! -d "$REPOS_DIR/podverse-helpers" ]; then
  echo -e "${RED}ERROR: No repos found at $REPOS_DIR${NC}"
  echo -e "${YELLOW}Please ensure all podverse repos are in sibling folders next to each other.${NC}"
  exit 1
fi

# Path to audit script
AUDIT_SCRIPT="$SCRIPT_DIR/../audit/audit-all-repos.sh"

# Repos to update (same order as publish)
REPOS=(
  "podverse-helpers"
  "podverse-external-services"
  "podverse-notifications"
  "podverse-orm"
  "podverse-parser"
  "podverse-mq"
  "podverse-api"
  "podverse-web"
  "podverse-workers"
)

# Version passed as argument or empty
VERSION="$1"

# Function to check for vulnerabilities
check_vulnerabilities() {
  echo -e "${YELLOW}Step 0: Checking for vulnerabilities in all repos...${NC}"
  echo ""
  
  if [ ! -f "$AUDIT_SCRIPT" ]; then
    echo -e "${YELLOW}Warning: Audit script not found at $AUDIT_SCRIPT${NC}"
    echo -e "${YELLOW}Skipping vulnerability check.${NC}"
    echo ""
    return 0
  fi
  
  # Run audit script and capture output
  audit_output=$(bash "$AUDIT_SCRIPT" 2>&1)
  audit_exit_code=$?
  
  # Check if audit script itself failed
  if [ $audit_exit_code -ne 0 ]; then
    echo -e "${RED}Error: Vulnerability check failed.${NC}"
    echo "$audit_output"
    return 1
  fi
  
  # Extract vulnerability count from output
  # Look for line like: "Total vulnerabilities across X repo(s): Y"
  vuln_line=$(echo "$audit_output" | grep "Total vulnerabilities across" || true)
  
  if [ -n "$vuln_line" ]; then
    # Extract the number of repos with vulnerabilities
    repos_with_vulns=$(echo "$vuln_line" | sed -n 's/.*Total vulnerabilities across \([0-9]*\) repo(s):.*/\1/p')
    
    if [ -n "$repos_with_vulns" ] && [ "$repos_with_vulns" -gt 0 ]; then
      # Found vulnerabilities
      echo "$audit_output"
      echo ""
      echo -e "${RED}========================================${NC}"
      echo -e "${RED}  ABORTED: Vulnerabilities found in repos${NC}"
      echo -e "${RED}  Please fix vulnerabilities before updating versions${NC}"
      echo -e "${RED}========================================${NC}"
      return 1
    fi
  fi
  
  # Check if output contains "All repos are clean!"
  if echo "$audit_output" | grep -q "All repos are clean! No vulnerabilities found"; then
    echo "$audit_output"
    echo ""
    echo -e "${GREEN}✓ No vulnerabilities found. Proceeding...${NC}"
    echo ""
    return 0
  fi
  
  # If we get here, something unexpected happened
  echo "$audit_output"
  echo ""
  echo -e "${YELLOW}Warning: Could not determine vulnerability status from audit output.${NC}"
  echo -e "${YELLOW}Proceeding with caution...${NC}"
  echo ""
  return 0
}

# Function to prompt for y/n confirmation with validation
confirm_prompt() {
  local prompt_message="$1"
  while true; do
    read -p "$prompt_message (y/N) " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      return 0
    elif [[ $REPLY =~ ^[Nn]$ ]] || [[ -z "$REPLY" ]]; then
      return 1
    else
      echo -e "${RED}Invalid input. Please enter 'y' or 'n'.${NC}"
    fi
  done
}

# Validate version format (semver: X.Y.Z)
validate_version() {
  local version="$1"
  if [[ ! "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo -e "${RED}Error: Invalid version format. Expected format: X.Y.Z (e.g., 5.1.18)${NC}"
    return 1
  fi
  return 0
}

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Podverse Update Version All Packages ${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Step 0: Check for vulnerabilities FIRST
if ! check_vulnerabilities; then
  exit 1
fi

# Function to check if repo is on v5-develop and clean
check_repo_state() {
  local repo_path="$1"
  local repo_name="$2"
  
  cd "$repo_path"
  
  # Check branch
  current_branch=$(git branch --show-current)
  if [[ "$current_branch" != "v5-develop" ]]; then
    echo -e "${RED}Error: $repo_name is not on v5-develop branch (currently on $current_branch).${NC}"
    return 1
  fi
  
  # Check for uncommitted changes
  if ! git diff --quiet || ! git diff --cached --quiet; then
    echo -e "${RED}Error: $repo_name has uncommitted changes.${NC}"
    return 1
  fi
  
  return 0
}

# Function to update version in a single repo
update_repo_version() {
  local repo_name="$1"
  local version="$2"
  local repo_path="$REPOS_DIR/$repo_name"
  
  echo -e "${BLUE}Updating $repo_name to version $version...${NC}"
  
  cd "$repo_path"
  
  # Pull latest changes
  git pull origin v5-develop --quiet
  
  # Update package.json version
  npm version "$version" --no-git-tag-version --allow-same-version
  
  # Regenerate package-lock.json with new version
  npm install --package-lock-only --ignore-scripts 2>/dev/null || true
  
  # Check if there are changes to commit
  if git diff --quiet package.json package-lock.json; then
    echo -e "${YELLOW}  No version change needed for $repo_name (already at $version)${NC}"
    return 0
  fi
  
  # Stage and commit changes
  git add package.json package-lock.json
  git commit -m "chore: bump version to $version"
  
  # Push changes
  git push origin v5-develop
  
  echo -e "${GREEN}  ✓ Updated $repo_name to $version${NC}"
  return 0
}

# If no version provided as argument, prompt for it
if [[ -z "$VERSION" ]]; then
  read -p "Enter version number (e.g., 5.1.18): " VERSION
  echo ""
fi

# Validate version
if ! validate_version "$VERSION"; then
  exit 1
fi

echo -e "${YELLOW}Will update all packages to version: $VERSION${NC}"
echo ""

# Check all repos first
echo -e "${YELLOW}Step 1: Checking all repos are on v5-develop and clean...${NC}"
echo ""

all_ready=true
for repo in "${REPOS[@]}"; do
  repo_path="$REPOS_DIR/$repo"
  
  if [[ ! -d "$repo_path" ]]; then
    echo -e "${RED}Error: Repo directory not found: $repo_path${NC}"
    exit 1
  fi
  
  echo -n "Checking $repo... "
  
  if ! check_repo_state "$repo_path" "$repo"; then
    all_ready=false
    continue
  fi
  
  echo -e "${GREEN}✓ ready${NC}"
done

echo ""

if [[ "$all_ready" != "true" ]]; then
  echo -e "${RED}========================================${NC}"
  echo -e "${RED}  Some repos have issues. Fix them before updating.${NC}"
  echo -e "${RED}========================================${NC}"
  exit 1
fi

# Confirm before proceeding
if ! confirm_prompt "Ready to update all packages to version $VERSION. Continue?"; then
  echo "Aborted."
  exit 0
fi

echo ""
echo -e "${YELLOW}Step 2: Updating versions...${NC}"
echo ""

# Update each repo
for repo in "${REPOS[@]}"; do
  if ! update_repo_version "$repo" "$VERSION"; then
    echo -e "${RED}Failed to update $repo${NC}"
    exit 1
  fi
done

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  SUCCESS: All packages updated to $VERSION${NC}"
echo -e "${GREEN}========================================${NC}"
