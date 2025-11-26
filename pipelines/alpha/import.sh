#!/bin/bash

set -euo pipefail

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Determine the Git repo root to make paths relative to it
if REPO_ROOT=$(git -C "$SCRIPT_DIR" rev-parse --show-toplevel 2>/dev/null); then
    :
else
    echo "ERROR: Unable to determine Git repo root. Ensure this script runs within a Git repository." >&2
    exit 1
fi

# Usage: ./import.sh <credentials_file> [jenkins_url] [jenkins_folder_name]
# credentials_file format:
#   Single line: username:password

if [ $# -lt 1 ]; then
    echo "Usage: $0 <credentials_file> [jenkins_url] [jenkins_folder_name]" >&2
    exit 1
fi

CRED_FILE="$1"
JENKINS_URL="${2:-http://localhost:8080/}"
JENKINS_FOLDER="${3:-pipelines}"

if [ ! -f "${CRED_FILE}" ]; then
    echo "ERROR: Credentials file not found: ${CRED_FILE}" >&2
    exit 1
fi

line="$(sed -n '1p' "${CRED_FILE}" | tr -d '\r')"

if [[ -z "${line}" ]]; then
    echo "ERROR: Credentials file is empty or first line blank." >&2
    exit 1
fi

if [[ "${line}" != *:* ]]; then
    echo "ERROR: Credentials file must be single line in format username:password" >&2
    exit 1
fi

AUTH="${line}"
USER="$(echo "${AUTH}" | cut -d: -f1)"
PASS="$(echo "${AUTH}" | cut -d: -f2-)"

if [[ -z "${USER}" || -z "${PASS}" ]]; then
    echo "ERROR: Parsed username or password is empty." >&2
    exit 1
fi

echo "Authenticated as: ${USER}"

# 1. Ensure the folder exists
echo '<com.cloudbees.hudson.plugins.folder.Folder/>' | \
java -jar "${SCRIPT_DIR}/jenkins-cli.jar" -s "$JENKINS_URL" -auth "$AUTH" create-job "$JENKINS_FOLDER" 2>/dev/null || true

echo "Folder '$JENKINS_FOLDER' is ready (created or already exists)"

# 2. Discover Jenkinsfiles in the current script directory
# Builds the FILES array from any files starting with 'Jenkinsfile.'
# Paths are set relative to the script's directory for consistency.
shopt -s nullglob
declare -a FILES=()
for jf in "$SCRIPT_DIR"/Jenkinsfile.*; do
    # Convert absolute path to repo-root-relative path starting with './'
    # Strip the repo root prefix
    rel_path="${jf#$REPO_ROOT/}"
    rel="./$rel_path"
    FILES+=("$rel")
done
shopt -u nullglob

# Fail early if no Jenkinsfiles are found
if [[ ${#FILES[@]} -eq 0 ]]; then
    echo "ERROR: No files matching 'Jenkinsfile.*' found in $SCRIPT_DIR" >&2
    exit 1
fi

# 3. Create or update jobs for each file
for FILE_PATH in "${FILES[@]}"; do
    # Extract job name (e.g., 'pipelines/alpha/Jenkinsfile.srv_api_up' -> 'srv_api_up')
    JOB_NAME=$(basename "$FILE_PATH" | sed 's/Jenkinsfile.//')
    
    # Check if job already exists
    if java -jar "${SCRIPT_DIR}/jenkins-cli.jar" -s "$JENKINS_URL" -auth "$AUTH" get-job "$JENKINS_FOLDER/$JOB_NAME" > /dev/null 2>&1; then
        echo "Updating job: $JENKINS_FOLDER/$JOB_NAME pointing to $FILE_PATH"
        sed "s|REPLACE_SCRIPT_PATH|$FILE_PATH|g" "${SCRIPT_DIR}/scm-job.xml" | \
        java -jar "${SCRIPT_DIR}/jenkins-cli.jar" -s "$JENKINS_URL" -auth "$AUTH" update-job "$JENKINS_FOLDER/$JOB_NAME"
    else
        echo "Creating job: $JENKINS_FOLDER/$JOB_NAME pointing to $FILE_PATH"
        sed "s|REPLACE_SCRIPT_PATH|$FILE_PATH|g" "${SCRIPT_DIR}/scm-job.xml" | \
        java -jar "${SCRIPT_DIR}/jenkins-cli.jar" -s "$JENKINS_URL" -auth "$AUTH" create-job "$JENKINS_FOLDER/$JOB_NAME"
    fi
done