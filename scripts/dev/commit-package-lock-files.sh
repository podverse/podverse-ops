#!/bin/bash

# Script to commit and push package-lock.json changes across all repos
# This script will only proceed if:
# 1. Each repo is on the v5-develop branch
# 2. The only changes are to package-lock.json files
# Otherwise, it will fail and display the errors

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

# Repos to process
REPOS=(
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
echo -e "${BLUE}  Podverse Commit Package Lock Files${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
echo -e "${BLUE}Base directory: $REPOS_BASE_DIR${NC}"
echo ""

# Function to check if repo has only package-lock.json changes
# Returns 0 if valid, 1 if invalid, and outputs errors to stdout
check_repo_changes() {
  local repo_path="$1"
  local repo_name="$2"
  local has_error=false
  
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
  
  # Check for uncommitted changes
  if git diff --quiet && git diff --cached --quiet; then
    # No changes at all
    return 0
  fi
  
  # Get list of changed files
  changed_files=$(git diff --name-only 2>/dev/null || echo "")
  staged_files=$(git diff --cached --name-only 2>/dev/null || echo "")
  all_changed_files=$(echo -e "$changed_files\n$staged_files" | grep -v '^$' | sort -u)
  
  # Check if there are any changes
  if [ -z "$all_changed_files" ]; then
    return 0
  fi
  
  # Check if all changed files are package-lock.json
  non_lock_files=""
  for file in $all_changed_files; do
    if [ "$file" != "package-lock.json" ]; then
      if [ -z "$non_lock_files" ]; then
        non_lock_files="$file"
      else
        non_lock_files="$non_lock_files, $file"
      fi
    fi
  done
  
  if [ -n "$non_lock_files" ]; then
    echo "Has changes to files other than package-lock.json: $non_lock_files"
    return 1
  fi
  
  # If we get here, only package-lock.json has changes
  return 0
}

# Function to commit and push package-lock.json
commit_and_push_package_lock() {
  local repo_path="$1"
  local repo_name="$2"
  
  cd "$repo_path" || {
    echo -e "${RED}  ✗ Failed to change to directory: $repo_path${NC}"
    return 1
  }
  
  # Check if package-lock.json actually has changes
  if git diff --quiet package-lock.json 2>/dev/null && git diff --cached --quiet package-lock.json 2>/dev/null; then
    echo -e "${YELLOW}  No changes to package-lock.json in $repo_name${NC}"
    return 0
  fi
  
  # Stage package-lock.json
  if ! git add package-lock.json; then
    echo -e "${RED}  ✗ Failed to stage package-lock.json for $repo_name${NC}"
    return 1
  fi
  
  # Commit with generic message
  if ! git commit -m "chore: update package-lock.json" > /dev/null 2>&1; then
    echo -e "${RED}  ✗ Failed to commit package-lock.json for $repo_name${NC}"
    return 1
  fi
  
  # Push to v5-develop
  if ! git push origin v5-develop > /dev/null 2>&1; then
    echo -e "${RED}  ✗ Failed to push package-lock.json for $repo_name${NC}"
    return 1
  fi
  
  echo -e "${GREEN}  ✓ Committed and pushed package-lock.json for $repo_name${NC}"
  return 0
}

# Step 1: Check all repos for validity
echo -e "${YELLOW}Step 1: Checking all repos...${NC}"
echo ""

has_errors=false
repos_with_changes=()

for repo in "${REPOS[@]}"; do
  repo_path="$REPOS_BASE_DIR/$repo"
  
  if [ ! -d "$repo_path" ]; then
    echo -e "${YELLOW}Skipping $repo (directory not found)${NC}"
    continue
  fi
  
  echo -n "Checking $repo... "
  
  error_output=$(check_repo_changes "$repo_path" "$repo" 2>&1)
  check_exit_code=$?
  
  if [ $check_exit_code -eq 0 ]; then
    # Check if there are actually changes to commit
    cd "$repo_path"
    if ! git diff --quiet package-lock.json 2>/dev/null || ! git diff --cached --quiet package-lock.json 2>/dev/null; then
      echo -e "${GREEN}✓ ready (has package-lock.json changes)${NC}"
      repos_with_changes+=("$repo")
    else
      echo -e "${GREEN}✓ ready (no changes)${NC}"
    fi
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

# If there are errors, fail
if [ "$has_errors" = true ]; then
  echo -e "${RED}========================================${NC}"
  echo -e "${RED}  ABORTED: Some repos have errors${NC}"
  echo -e "${RED}  Please fix the errors before proceeding${NC}"
  echo -e "${RED}========================================${NC}"
  exit 1
fi

# Check if there are any repos with changes
if [ ${#repos_with_changes[@]} -eq 0 ]; then
  echo -e "${GREEN}========================================${NC}"
  echo -e "${GREEN}  No package-lock.json changes found${NC}"
  echo -e "${GREEN}  All repos are up to date${NC}"
  echo -e "${GREEN}========================================${NC}"
  exit 0
fi

# Step 2: Commit and push changes
echo -e "${YELLOW}Step 2: Committing and pushing package-lock.json changes...${NC}"
echo ""

push_errors=false
for repo in "${repos_with_changes[@]}"; do
  repo_path="$REPOS_BASE_DIR/$repo"
  if ! commit_and_push_package_lock "$repo_path" "$repo"; then
    push_errors=true
  fi
done

if [ "$push_errors" = true ]; then
  echo ""
  echo -e "${RED}========================================${NC}"
  echo -e "${RED}  Some commits/pushes failed${NC}"
  echo -e "${RED}  Please check the errors above${NC}"
  echo -e "${RED}========================================${NC}"
  exit 1
fi

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  SUCCESS: All package-lock.json files committed and pushed${NC}"
echo -e "${GREEN}========================================${NC}"
