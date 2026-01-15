#!/bin/bash

# Alpha Publish All Packages Script
# This script publishes all podverse packages to npm alpha channel in the correct order.
# It checks for clean working directories, runs publish scripts, and monitors GitHub Actions.

set -e

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Base directory for repos (parent of podverse-ops)
# Script is at: podverse-ops/scripts/publish/alpha-publish-all-packages.sh
# Repos are at: (parent directory, 3 levels up from script)
REPOS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"

# Check if repos are in the expected location
if [ ! -d "$REPOS_DIR/podverse-helpers" ]; then
  # Try going up one more level
  REPOS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
fi

# Repos in publish order (dependencies first)
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
  "podverse-management-api"
  "podverse-management"
)

# GitHub org
GITHUB_ORG="podverse"

# Time to wait after successful publish before moving to next repo (seconds)
POST_SUCCESS_WAIT=20

# Maximum time to wait for a GitHub Action to complete (seconds)
MAX_WAIT_TIME=600

# Poll interval for checking GitHub Action status (seconds)
POLL_INTERVAL=10

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Podverse Alpha Publish All Packages  ${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Script directory
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Version update script
VERSION_UPDATE_SCRIPT="$SCRIPT_DIR/v5-develop-update-version-all.sh"

# Validate version format (semver: X.Y.Z)
validate_version() {
  local version="$1"
  if [[ ! "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo -e "${RED}Error: Invalid version format. Expected format: X.Y.Z (e.g., 5.1.18)${NC}"
    return 1
  fi
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

# Function to check if gh CLI is installed and authenticated
check_gh_cli() {
  if ! command -v gh &> /dev/null; then
    echo -e "${RED}Error: GitHub CLI (gh) is not installed.${NC}"
    echo "Install it with: brew install gh"
    exit 1
  fi

  if ! gh auth status &> /dev/null; then
    echo -e "${RED}Error: GitHub CLI is not authenticated.${NC}"
    echo "Run: gh auth login"
    exit 1
  fi
}

# Function to check if repo has unstaged changes
check_unstaged_changes() {
  local repo_path="$1"
  local repo_name="$2"
  
  cd "$repo_path"
  
  if ! git diff --quiet; then
    echo -e "${RED}Error: $repo_name has unstaged changes.${NC}"
    return 1
  fi
  
  if ! git diff --cached --quiet; then
    echo -e "${RED}Error: $repo_name has staged but uncommitted changes.${NC}"
    return 1
  fi
  
  return 0
}

# Function to check if repo has unpushed commits
check_unpushed_commits() {
  local repo_path="$1"
  local repo_name="$2"
  
  cd "$repo_path"
  
  # Make sure we're on v5-develop
  current_branch=$(git branch --show-current)
  if [[ "$current_branch" != "v5-develop" ]]; then
    echo -e "${YELLOW}Warning: $repo_name is not on v5-develop branch (currently on $current_branch).${NC}"
  fi
  
  # Fetch latest from remote
  git fetch origin --quiet
  
  # Check for unpushed commits on current branch
  local_commits=$(git rev-list --count @{u}..HEAD 2>/dev/null || echo "0")
  if [[ "$local_commits" -gt 0 ]]; then
    echo -e "${RED}Error: $repo_name has $local_commits unpushed commit(s).${NC}"
    return 1
  fi
  
  return 0
}

# Function to get the latest workflow run for a repo triggered by push to v5-alpha
# Returns: run_id
get_latest_workflow_run_id() {
  local repo_name="$1"
  
  # Get the latest workflow run triggered by push to v5-alpha
  gh run list \
    --repo "$GITHUB_ORG/$repo_name" \
    --branch "v5-alpha" \
    --event "push" \
    --limit 1 \
    --json databaseId \
    --jq '.[0].databaseId'
}

# Function to get workflow run for a specific commit SHA
# Polls until found or timeout
get_workflow_run_for_commit() {
  local repo_name="$1"
  local commit_sha="$2"
  local max_attempts=12  # 12 attempts * 5 seconds = 60 seconds max wait
  local attempt=0
  
  while [[ $attempt -lt $max_attempts ]]; do
    local run_id=$(gh run list \
      --repo "$GITHUB_ORG/$repo_name" \
      --branch "v5-alpha" \
      --event "push" \
      --limit 5 \
      --json databaseId,headSha \
      --jq ".[] | select(.headSha == \"$commit_sha\") | .databaseId" | head -1)
    
    if [[ -n "$run_id" ]]; then
      echo "$run_id"
      return 0
    fi
    
    attempt=$((attempt + 1))
    if [[ $attempt -lt $max_attempts ]]; then
      sleep 5
    fi
  done
  
  return 1
}

# Function to wait for a workflow run to complete
wait_for_workflow() {
  local repo_name="$1"
  local run_id="$2"
  local elapsed=0
  
  echo -e "${BLUE}Monitoring workflow run $run_id for $repo_name...${NC}"
  
  while [[ $elapsed -lt $MAX_WAIT_TIME ]]; do
    status=$(gh run view "$run_id" --repo "$GITHUB_ORG/$repo_name" --json status,conclusion --jq '.status')
    
    if [[ "$status" == "completed" ]]; then
      conclusion=$(gh run view "$run_id" --repo "$GITHUB_ORG/$repo_name" --json conclusion --jq '.conclusion')
      
      if [[ "$conclusion" == "success" ]]; then
        echo -e "${GREEN}✓ Workflow completed successfully for $repo_name${NC}"
        return 0
      else
        echo -e "${RED}✗ Workflow failed for $repo_name (conclusion: $conclusion)${NC}"
        echo ""
        echo "View the failed run: gh run view $run_id --repo $GITHUB_ORG/$repo_name --log-failed"
        return 1
      fi
    fi
    
    echo -e "  Status: $status (elapsed: ${elapsed}s)"
    sleep $POLL_INTERVAL
    elapsed=$((elapsed + POLL_INTERVAL))
  done
  
  echo -e "${RED}✗ Timeout waiting for workflow to complete for $repo_name${NC}"
  return 1
}

# Function to publish a single repo
publish_repo() {
  local repo_name="$1"
  local repo_path="$REPOS_DIR/$repo_name"
  local publish_script="$repo_path/scripts/publish/alpha/publish.sh"
  
  echo -e "${BLUE}----------------------------------------${NC}"
  echo -e "${BLUE}Publishing: $repo_name${NC}"
  echo -e "${BLUE}----------------------------------------${NC}"
  
  # Check if publish script exists
  if [[ ! -f "$publish_script" ]]; then
    echo -e "${RED}Error: Publish script not found at $publish_script${NC}"
    return 1
  fi
  
  cd "$repo_path"
  
  # Fetch to ensure we have latest remote refs
  git fetch origin --quiet
  
  # Get the v5-alpha commit SHA BEFORE pushing (if branch exists)
  local before_sha=""
  if git show-ref --verify --quiet refs/remotes/origin/v5-alpha; then
    before_sha=$(git rev-parse origin/v5-alpha)
  fi
  
  # Run the publish script
  echo "Running publish script..."
  bash "$publish_script"
  
  # Fetch again to get the new state
  git fetch origin --quiet
  
  # Get the v5-alpha commit SHA AFTER pushing
  local after_sha=$(git rev-parse origin/v5-alpha)
  
  # Check if v5-alpha was actually updated
  if [[ "$before_sha" == "$after_sha" ]]; then
    # No change - v5-alpha was already up to date with v5-develop
    echo -e "${YELLOW}No changes pushed for $repo_name (v5-alpha already up to date)${NC}"
    
    # Check if there's a previous successful workflow for this commit
    local existing_run_id=$(get_latest_workflow_run_id "$repo_name")
    if [[ -n "$existing_run_id" && "$existing_run_id" != "null" ]]; then
      local conclusion=$(gh run view "$existing_run_id" --repo "$GITHUB_ORG/$repo_name" --json conclusion --jq '.conclusion')
      if [[ "$conclusion" == "success" ]]; then
        echo -e "${GREEN}✓ Previous workflow was successful for $repo_name${NC}"
        return 0
      else
        echo -e "${RED}✗ Previous workflow did not succeed for $repo_name (conclusion: $conclusion)${NC}"
        echo -e "${YELLOW}You may need to manually trigger a new publish or investigate the issue.${NC}"
        return 1
      fi
    fi
    
    echo -e "${YELLOW}No previous workflow found, continuing to next repo...${NC}"
    return 0
  fi
  
  # v5-alpha was updated - wait for the workflow run for this commit
  echo "Waiting for workflow to be triggered for commit ${after_sha:0:7}..."
  local run_id=$(get_workflow_run_for_commit "$repo_name" "$after_sha")
  
  if [[ -z "$run_id" ]]; then
    echo -e "${RED}Error: Timed out waiting for workflow run for $repo_name${NC}"
    return 1
  fi
  
  # Wait for the workflow to complete
  if ! wait_for_workflow "$repo_name" "$run_id"; then
    return 1
  fi
  
  # Wait additional time before next repo
  echo -e "${YELLOW}Waiting ${POST_SUCCESS_WAIT}s before next repo...${NC}"
  sleep $POST_SUCCESS_WAIT
  
  return 0
}

# Main execution

# Check prerequisites
check_gh_cli

# Step 0: Ask for version update
echo -e "${YELLOW}Step 0: Version Update (Optional)${NC}"
echo -e "Enter a version number to update all packages before publishing."
echo -e "Leave blank to retain current versions."
echo ""
read -p "Version number (e.g., 5.1.18) or press Enter to skip: " VERSION_INPUT
echo ""

if [[ -n "$VERSION_INPUT" ]]; then
  # Validate version format
  if ! validate_version "$VERSION_INPUT"; then
    exit 1
  fi
  
  # Check if version update script exists
  if [[ ! -f "$VERSION_UPDATE_SCRIPT" ]]; then
    echo -e "${RED}Error: Version update script not found at $VERSION_UPDATE_SCRIPT${NC}"
    exit 1
  fi
  
  echo -e "${YELLOW}Running version update script...${NC}"
  echo ""
  
  # Run version update script (it will handle its own confirmation)
  if ! bash "$VERSION_UPDATE_SCRIPT" "$VERSION_INPUT"; then
    echo -e "${RED}Version update failed. Aborting.${NC}"
    exit 1
  fi
  
  echo ""
  echo -e "${GREEN}Version update complete. Continuing with alpha publish...${NC}"
  echo ""
fi

echo -e "${YELLOW}Step 1: Checking all repos for clean state...${NC}"
echo ""

all_clean=true
for repo in "${REPOS[@]}"; do
  repo_path="$REPOS_DIR/$repo"
  
  if [[ ! -d "$repo_path" ]]; then
    echo -e "${RED}Error: Repo directory not found: $repo_path${NC}"
    exit 1
  fi
  
  echo -n "Checking $repo... "
  
  if ! check_unstaged_changes "$repo_path" "$repo"; then
    all_clean=false
    continue
  fi
  
  if ! check_unpushed_commits "$repo_path" "$repo"; then
    all_clean=false
    continue
  fi
  
  echo -e "${GREEN}✓ clean${NC}"
done

echo ""

if [[ "$all_clean" != "true" ]]; then
  echo -e "${RED}========================================${NC}"
  echo -e "${RED}  Some repos have issues. Fix them before publishing.${NC}"
  echo -e "${RED}========================================${NC}"
  exit 1
fi

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  All repos are clean!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

# Confirm before proceeding
if ! confirm_prompt "Ready to publish all packages to alpha. Continue?"; then
  echo "Aborted."
  exit 0
fi

echo ""
echo -e "${YELLOW}Step 2: Publishing packages in order...${NC}"
echo ""

# Publish each repo in order
for repo in "${REPOS[@]}"; do
  if ! publish_repo "$repo"; then
    echo ""
    echo -e "${RED}========================================${NC}"
    echo -e "${RED}  FAILED: Publishing stopped at $repo${NC}"
    echo -e "${RED}========================================${NC}"
    exit 1
  fi
done

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  SUCCESS: All packages published!${NC}"
echo -e "${GREEN}========================================${NC}"
