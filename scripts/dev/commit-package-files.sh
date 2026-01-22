#!/bin/bash

# Script to commit and push package.json and/or package-lock.json changes across all repos
# This script will only proceed if:
# 1. Each repo is on the specified target branch (default: v5-develop)
# 2. The only changes are to package.json and/or package-lock.json files (either or both)
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
echo -e "${BLUE}  Podverse Commit Package Files${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
echo -e "${BLUE}Base directory: $REPOS_BASE_DIR${NC}"
echo ""

# Prompt for branch name
echo -e "${YELLOW}Enter branch name to push changes to (default: v5-develop):${NC}"
read -r TARGET_BRANCH
TARGET_BRANCH=${TARGET_BRANCH:-v5-develop}
echo -e "${BLUE}Using branch: $TARGET_BRANCH${NC}"
echo ""

# Function to check if a file is a valid package file (package.json or package-lock.json)
# Returns 0 if valid, 1 if invalid
is_valid_package_file() {
  local file="$1"
  
  # Check if file is root package.json or package-lock.json
  if [ "$file" = "package.json" ] || [ "$file" = "package-lock.json" ]; then
    return 0
  fi
  
  # Check if file is qa/**/package.json or qa/**/package-lock.json
  if [[ "$file" =~ ^qa/.*/package\.json$ ]] || [[ "$file" =~ ^qa/.*/package-lock\.json$ ]]; then
    return 0
  fi
  
  return 1
}

# Function to check if repo has only package.json and/or package-lock.json changes
# Returns 0 if valid, 1 if invalid, and outputs errors to stdout
check_repo_changes() {
  local repo_path="$1"
  local repo_name="$2"
  local target_branch="$3"
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
  
  if [ "$current_branch" != "$target_branch" ]; then
    echo "Not on $target_branch branch (currently on: $current_branch)"
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
  
  # Check if all changed files are package.json or package-lock.json (root or qa subdirectories)
  non_package_files=""
  for file in $all_changed_files; do
    if ! is_valid_package_file "$file"; then
      if [ -z "$non_package_files" ]; then
        non_package_files="$file"
      else
        non_package_files="$non_package_files, $file"
      fi
    fi
  done
  
  if [ -n "$non_package_files" ]; then
    echo "Has changes to files other than package.json/package-lock.json: $non_package_files"
    return 1
  fi
  
  # If we get here, only package.json and/or package-lock.json files have changes
  return 0
}

# Function to commit and push package.json and/or package-lock.json
commit_and_push_package_files() {
  local repo_path="$1"
  local repo_name="$2"
  local target_branch="$3"
  
  cd "$repo_path" || {
    echo -e "${RED}  ✗ Failed to change to directory: $repo_path${NC}"
    return 1
  }
  
  # Find all package.json and package-lock.json files with changes (root and qa subdirectories)
  changed_files=$(git diff --name-only 2>/dev/null | grep -E '^(package\.json|package-lock\.json|qa/.*/package\.json|qa/.*/package-lock\.json)$' || true)
  staged_files=$(git diff --cached --name-only 2>/dev/null | grep -E '^(package\.json|package-lock\.json|qa/.*/package\.json|qa/.*/package-lock\.json)$' || true)
  all_package_files=$(echo -e "$changed_files\n$staged_files" | grep -v '^$' | sort -u)
  
  # Check if any package files have changes
  if [ -z "$all_package_files" ]; then
    echo -e "${YELLOW}  No changes to package.json/package-lock.json files in $repo_name${NC}"
    return 0
  fi
  
  # Stage all package files with changes
  staged_count=0
  for file in $all_package_files; do
    if git add "$file" 2>/dev/null; then
      staged_count=$((staged_count + 1))
    fi
  done
  
  if [ $staged_count -eq 0 ]; then
    echo -e "${YELLOW}  No changes to package.json/package-lock.json files in $repo_name${NC}"
    return 0
  fi
  
  # Determine commit message based on what files changed
  has_package_json=false
  has_package_lock=false
  
  for file in $all_package_files; do
    if [[ "$file" =~ package\.json$ ]] && [[ ! "$file" =~ package-lock\.json$ ]]; then
      has_package_json=true
    elif [[ "$file" =~ package-lock\.json$ ]]; then
      has_package_lock=true
    fi
  done
  
  # Build commit message
  if [ "$has_package_json" = true ] && [ "$has_package_lock" = true ]; then
    if [ $staged_count -eq 2 ]; then
      commit_msg="chore: update package.json and package-lock.json"
    else
      commit_msg="chore: update package.json and package-lock.json files"
    fi
  elif [ "$has_package_json" = true ]; then
    if [ $staged_count -eq 1 ]; then
      commit_msg="chore: update package.json"
    else
      commit_msg="chore: update package.json files"
    fi
  else
    if [ $staged_count -eq 1 ]; then
      commit_msg="chore: update package-lock.json"
    else
      commit_msg="chore: update package-lock.json files"
    fi
  fi
  
  if ! git commit -m "$commit_msg" > /dev/null 2>&1; then
    echo -e "${RED}  ✗ Failed to commit package files for $repo_name${NC}"
    return 1
  fi
  
  # Push to target branch
  if ! git push origin "$target_branch" > /dev/null 2>&1; then
    echo -e "${RED}  ✗ Failed to push package files for $repo_name${NC}"
    return 1
  fi
  
  if [ $staged_count -eq 1 ]; then
    echo -e "${GREEN}  ✓ Committed and pushed package file for $repo_name${NC}"
  else
    echo -e "${GREEN}  ✓ Committed and pushed $staged_count package files for $repo_name${NC}"
  fi
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
  
  error_output=$(check_repo_changes "$repo_path" "$repo" "$TARGET_BRANCH" 2>&1)
  check_exit_code=$?
  
  if [ $check_exit_code -eq 0 ]; then
    # Check if there are actually changes to commit (root or qa subdirectories)
    cd "$repo_path"
    has_package_changes=false
    
    # Check root package.json and package-lock.json
    if ! git diff --quiet package.json 2>/dev/null || ! git diff --cached --quiet package.json 2>/dev/null; then
      has_package_changes=true
    fi
    if ! git diff --quiet package-lock.json 2>/dev/null || ! git diff --cached --quiet package-lock.json 2>/dev/null; then
      has_package_changes=true
    fi
    
    # Check qa subdirectory package files
    if [ -d "qa" ]; then
      for qa_package_file in qa/*/package.json qa/*/package-lock.json; do
        # Check if glob matched any files (not literal "qa/*/package.json")
        if [ -f "$qa_package_file" ]; then
          if ! git diff --quiet "$qa_package_file" 2>/dev/null || ! git diff --cached --quiet "$qa_package_file" 2>/dev/null; then
            has_package_changes=true
            break
          fi
        fi
      done
    fi
    
    if [ "$has_package_changes" = true ]; then
      echo -e "${GREEN}✓ ready (has package.json/package-lock.json changes)${NC}"
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
  echo -e "${GREEN}  No package.json/package-lock.json changes found${NC}"
  echo -e "${GREEN}  All repos are up to date${NC}"
  echo -e "${GREEN}========================================${NC}"
  exit 0
fi

# Step 2: Commit and push changes
echo -e "${YELLOW}Step 2: Committing and pushing package.json/package-lock.json changes...${NC}"
echo ""

push_errors=false
for repo in "${repos_with_changes[@]}"; do
  repo_path="$REPOS_BASE_DIR/$repo"
  if ! commit_and_push_package_files "$repo_path" "$repo" "$TARGET_BRANCH"; then
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
echo -e "${GREEN}  SUCCESS: All package.json/package-lock.json files committed and pushed${NC}"
echo -e "${GREEN}========================================${NC}"
