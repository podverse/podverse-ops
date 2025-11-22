#!/usr/bin/env bash

# getLatestAlphaTag.sh
# Determines the latest docker image tag matching x.x.x-alpha.x

set -euo pipefail

IMAGE_PATH="${GHCR_IMAGE_PATH}"
RAW_TOKEN="${GHCR_REGISTRY_TOKEN}"

# If the token is already a base64 string that decodes to a ghp_ prefix, keep it.
# Otherwise base64 encode the raw PAT.
is_base64_pat() {
	local decoded
	decoded=$(echo "$1" | base64 -d 2>/dev/null || true)
	[[ $decoded == ghp_* ]]
}

if is_base64_pat "$RAW_TOKEN"; then
	TOKEN_B64="$RAW_TOKEN"
else
	# Encode without newlines (macOS base64 wraps at 76 chars by default)
	TOKEN_B64=$(printf '%s' "$RAW_TOKEN" | base64 | tr -d '\n')
fi

if ! command -v jq >/dev/null 2>&1; then
	echo "jq is required but not found in PATH" >&2
	exit 1
fi

if [[ -z "$RAW_TOKEN" ]]; then
	echo "GHCR_REGISTRY_TOKEN is not set" >&2
	exit 1
fi

# Fetch tags list from GHCR
TAGS_JSON=$(curl -fsSL -H "Authorization: Bearer $TOKEN_B64" "https://ghcr.io/v2/${IMAGE_PATH}/tags/list" || true)

if [[ -z "$TAGS_JSON" ]]; then
	echo "No tags JSON returned from GHCR" >&2
	exit 1
fi

# Extract alpha tags matching semantic pattern and determine latest (lexicographic version sort)
LATEST=$(echo "$TAGS_JSON" \
	| jq -r '.tags[]?' 2>/dev/null \
	| grep -E '^[0-9]+\.[0-9]+\.[0-9]+-alpha\.[0-9]+$' \
	| sort -V \
	| tail -n1 || true)

# If none found, exit silently (echo nothing)
if [[ -z "$LATEST" ]]; then
	exit 0
fi

echo "$LATEST"
