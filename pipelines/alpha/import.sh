#!/bin/bash

set -euo pipefail

# Usage: ./import.sh <credentials_file> [jenkins_url] [folder_name]
# credentials_file format:
#   Single line: username:password

if [ $# -lt 1 ]; then
    echo "Usage: $0 <credentials_file> [jenkins_url] [folder_name]" >&2
    exit 1
fi

CRED_FILE="$1"
JENKINS_URL="${2:-http://localhost:8080/}"
FOLDER="${3:-pipelines}"

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
USER="${AUTH%%:*}"
PASS="${AUTH#*:}"

if [[ -z "${USER}" || -z "${PASS}" ]]; then
    echo "ERROR: Parsed username or password is empty." >&2
    exit 1
fi

echo "Using Jenkins auth for user: ${USER}"

# 1. Ensure the folder exists
echo '<com.cloudbees.hudson.plugins.folder.Folder/>' | \
java -jar jenkins-cli.jar -s "$JENKINS_URL" -auth "$AUTH" create-job "$FOLDER" 2>/dev/null || true

echo "Folder '$FOLDER' is ready (created or already exists)"

# 2. List of Jenkinsfiles in your repo structure
# (Based on the file structure you provided earlier)
declare -a FILES=(
    "./pipelines/alpha/Jenkinsfile.aux_all_down"
    "./pipelines/alpha/Jenkinsfile.aux_db_down"
    # "./pipelines/alpha/Jenkinsfile.aux_db_drop_everything"
    # "./pipelines/alpha/Jenkinsfile.aux_db_init"
    # "./pipelines/alpha/Jenkinsfile.aux_db_up"
    # "./pipelines/alpha/Jenkinsfile.aux_docker_prune_images"
    # "./pipelines/alpha/Jenkinsfile.aux_mq_down"
    # "./pipelines/alpha/Jenkinsfile.aux_mq_up"
    # "./pipelines/alpha/Jenkinsfile.aux_network_create"
    # "./pipelines/alpha/Jenkinsfile.aux_network_remove"
    # "./pipelines/alpha/Jenkinsfile.aux_ops_git_pull"
    # "./pipelines/alpha/Jenkinsfile.aux_workers_archive_all"
    # "./pipelines/alpha/Jenkinsfile.aux_workers_down"
    # "./pipelines/alpha/Jenkinsfile.aux_workers_mq_rss_add"
    # "./pipelines/alpha/Jenkinsfile.aux_workers_mq_rss_add_recently_updated_feeds_from_podcast_index"
    # "./pipelines/alpha/Jenkinsfile.aux_workers_mq_rss_run_live_item_listener"
    # "./pipelines/alpha/Jenkinsfile.aux_workers_mq_rss_run_parsers"
    # "./pipelines/alpha/Jenkinsfile.aux_workers_mq_rss_run_parsers_all"
    # "./pipelines/alpha/Jenkinsfile.aux_workers_mq_rss_stop_parsers"
    # "./pipelines/alpha/Jenkinsfile.aux_workers_orm_feed_update_flag_status"
    # "./pipelines/alpha/Jenkinsfile.aux_workers_parser_rss_parse_feed"
    # "./pipelines/alpha/Jenkinsfile.aux_workers_podcast_index_dead_feeds_delete_cache"
    # "./pipelines/alpha/Jenkinsfile.aux_workers_podcast_index_dead_feeds_flag_and_merge"
    # "./pipelines/alpha/Jenkinsfile.aux_workers_up"
    # "./pipelines/alpha/Jenkinsfile.srv_all_down"
    # "./pipelines/alpha/Jenkinsfile.srv_api_down"
    # "./pipelines/alpha/Jenkinsfile.srv_api_up"
    # "./pipelines/alpha/Jenkinsfile.srv_docker_prune_images"
    # "./pipelines/alpha/Jenkinsfile.srv_network_create"
    # "./pipelines/alpha/Jenkinsfile.srv_network_remove"
    # "./pipelines/alpha/Jenkinsfile.srv_ops_git_pull"
    # "./pipelines/alpha/Jenkinsfile.srv_web_down"
    # "./pipelines/alpha/Jenkinsfile.srv_web_up"
    # "./pipelines/alpha/Jenkinsfile.u_all_down"
    # "./pipelines/alpha/Jenkinsfile.u_ops_git_pull"
)

# 3. Create jobs for each file
for FILE_PATH in "${FILES[@]}"; do
    # Extract job name (e.g., 'pipelines/alpha/Jenkinsfile.srv_api_up' -> 'srv_api_up')
    JOB_NAME=$(basename "$FILE_PATH" | sed 's/Jenkinsfile.//')
    
    echo "Creating job: $FOLDER/$JOB_NAME pointing to $FILE_PATH"

    # Use sed to inject the correct script path into the XML and pipe it to the CLI
    sed "s|REPLACE_SCRIPT_PATH|$FILE_PATH|g" scm-job.xml | \
    java -jar jenkins-cli.jar -s "$JENKINS_URL" -auth "$AUTH" create-job "$FOLDER/$JOB_NAME"
done