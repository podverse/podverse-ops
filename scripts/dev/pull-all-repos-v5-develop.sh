#!/bin/bash

# Script to pull latest changes from v5-develop branch across all repos
# This script will only proceed if:
# 1. Each repo is on the v5-develop branch
# 2. Each repo has no local changes (working directory and staging area are clean)
# Otherwise, it will fail and display the errors without pulling any changes

# Don't use set -e, we want to handle errors gracefully

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Get directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Navigate up to parent directory where all repos should be
# Script is at: podverse-ops/scripts/dev/
# Repos are at: repos/ (3 levels up from script)
REPOS_BASE_DIR="$(cd "$SCRIPT_DIR/../../.." && pwd)"

# Check if repos are in the same directory as podverse-ops
if [ ! -d "$REPOS_BASE_DIR/podverse-helpers" ]; then
  # Try going up one more level (repos are sibling to podverse-ops)
  REPOS_BASE_DIR="$(cd "$SCRIPT_DIR/../../../.." && pwd)"
fi

# Check if repos are in the expected location
if [ ! -d "$REPOS_BASE_DIR/podverse-helpers" ]; then
  echo -e "${RED}ERROR: No repos found at $REPOS_BASE_DIR${NC}"
  echo -e "${YELLOW}Please ensure all podverse repos are in sibling folders next to each other.${NC}"
  exit 1
fi

# Repos to process (including podverse-ops)
REPOS=(
  "podverse-ops"
  "partytime"
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
  "podverse-management-api"
  "podverse-management-web"
)

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Podverse Pull All Repos${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
echo -e "${BLUE}Base directory: $REPOS_BASE_DIR${NC}"
echo ""

# Function to check if repo is ready to pull
# Returns 0 if valid, 1 if invalid, and outputs errors to stdout
check_repo_ready() {
  local repo_path="$1"
  local repo_name="$2"
  
  # Check if directory exists
  if [ ! -d "$repo_path" ]; then
    echo "Directory not found: $repo_path"
    return 1
  fi
  
  cd "$repo_path" || {
    echo "Could not change to directory: $repo_path"
    return 1
  }
  
  # Check if it's a git repository
  if [ ! -d "$repo_path/.git" ]; then
    echo "Not a git repository"
    return 1
  fi
  
  # Check current branch
  current_branch=$(git branch --show-current 2>/dev/null || echo "")
  if [ -z "$current_branch" ]; then
    echo "Could not determine current branch"
    return 1
  fi
  
  if [ "$current_branch" != "v5-develop" ]; then
    echo "Not on v5-develop branch (currently on: $current_branch)"
    return 1
  fi
  
  # Check for uncommitted changes in working directory
  if ! git diff --quiet 2>/dev/null; then
    changed_files=$(git diff --name-only 2>/dev/null | head -5 | tr '\n' ', ' | sed 's/,$//')
    if [ -n "$changed_files" ]; then
      echo "Has uncommitted changes in working directory: $changed_files"
    else
      echo "Has uncommitted changes in working directory"
    fi
    return 1
  fi
  
  # Check for staged changes
  if ! git diff --cached --quiet 2>/dev/null; then
    staged_files=$(git diff --cached --name-only 2>/dev/null | head -5 | tr '\n' ', ' | sed 's/,$//')
    if [ -n "$staged_files" ]; then
      echo "Has staged changes: $staged_files"
    else
      echo "Has staged changes"
    fi
    return 1
  fi
  
  # If we get here, repo is clean and on correct branch
  return 0
}

# Function to pull latest changes
pull_latest() {
  local repo_path="$1"
  local repo_name="$2"
  
  cd "$repo_path" || {
    echo -e "${RED}  ✗ Failed to change to directory: $repo_path${NC}"
    return 1
  }
  
  # Fetch latest changes
  if ! git fetch origin v5-develop > /dev/null 2>&1; then
    echo -e "${RED}  ✗ Failed to fetch latest changes for $repo_name${NC}"
    return 1
  fi
  
  # Check if there are any changes to pull
  local_behind=$(git rev-list --count HEAD..origin/v5-develop 2>/dev/null || echo "0")
  
  if [ "$local_behind" = "0" ]; then
    echo -e "${GREEN}  ✓ $repo_name is up to date${NC}"
    return 0
  fi
  
  # Pull latest changes
  if ! git pull origin v5-develop > /dev/null 2>&1; then
    echo -e "${RED}  ✗ Failed to pull latest changes for $repo_name${NC}"
    return 1
  fi
  
  echo -e "${GREEN}  ✓ Pulled latest changes for $repo_name${NC}"
  return 0
}

# Step 1: Check all repos for validity
echo -e "${YELLOW}Step 1: Checking all repos are on v5-develop with no local changes...${NC}"
echo ""

has_errors=false
valid_repos=()

for repo in "${REPOS[@]}"; do
  repo_path="$REPOS_BASE_DIR/$repo"
  
  if [ ! -d "$repo_path" ]; then
    echo -e "${YELLOW}Skipping $repo (directory not found)${NC}"
    continue
  fi
  
  echo -n "Checking $repo... "
  
  error_output=$(check_repo_ready "$repo_path" "$repo" 2>&1)
  check_exit_code=$?
  
  if [ $check_exit_code -eq 0 ]; then
    echo -e "${GREEN}✓ ready${NC}"
    valid_repos+=("$repo")
  else
    echo -e "${RED}✗ ERROR${NC}"
    has_errors=true
    echo -e "${RED}  Errors for $repo:${NC}"
    echo "$error_output" | while IFS= read -r line; do
      if [ -n "$line" ]; then
        echo -e "${RED}    - $line${NC}"
      fi
    done
  fi
done

echo ""

# If there are errors, fail without pulling anything
if [ "$has_errors" = true ]; then
  echo -e "${RED}========================================${NC}"
  echo -e "${RED}  ABORTED: Some repos have errors${NC}"
  echo -e "${RED}  No changes were pulled${NC}"
  echo -e "${RED}  Please fix the errors before proceeding${NC}"
  echo -e "${RED}========================================${NC}"
  exit 1
fi

# Check if we have any valid repos
if [ ${#valid_repos[@]} -eq 0 ]; then
  echo -e "${YELLOW}No valid repos found to pull${NC}"
  exit 0
fi

# Step 2: Pull latest changes for all valid repos
echo -e "${YELLOW}Step 2: Pulling latest changes from v5-develop...${NC}"
echo ""

pull_errors=false
for repo in "${valid_repos[@]}"; do
  repo_path="$REPOS_BASE_DIR/$repo"
  if ! pull_latest "$repo_path" "$repo"; then
    pull_errors=true
  fi
done

if [ "$pull_errors" = true ]; then
  echo ""
  echo -e "${RED}========================================${NC}"
  echo -e "${RED}  Some pulls failed${NC}"
  echo -e "${RED}  Please check the errors above${NC}"
  echo -e "${RED}========================================${NC}"
  exit 1
fi

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  SUCCESS: All repos checked and updated${NC}"
echo -e "${GREEN}========================================${NC}"
