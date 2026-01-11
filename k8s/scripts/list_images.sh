#!/usr/bin/env bash
# VERSION: 1
# Lists all container images running in pods within a specified namespace.

set -euo pipefail

echo "Running list_images.sh"

# ------------------------------------------------------------------
# INPUTS
# ------------------------------------------------------------------ 

# Allow passing namespace as first argument, otherwise prompt
if [ "$#" -ge 1 ]; then
    NAMESPACE="$1"
else
    # Default to podverse-alpha if the user just hits enter, 
    # but allow typing a different namespace (e.g. argocd, kube-system)
    read -p "Enter Namespace [podverse-alpha]: " INPUT_NS
    NAMESPACE="${INPUT_NS:-podverse-alpha}"
fi

echo "----------------------------------------------------"
echo "Listing images in namespace: $NAMESPACE"
echo "----------------------------------------------------"

# Check if namespace exists before trying to list pods
if ! kubectl get namespace "$NAMESPACE" >/dev/null 2>&1; then
    echo "Error: Namespace '$NAMESPACE' does not exist."
    echo "Available namespaces:"
    kubectl get namespaces -o custom-columns=NAME:.metadata.name
    exit 1
fi

# Get pods and images using custom-columns for a readable table view
# We use -o wide-ish logic by selecting specific columns
kubectl get pods -n "$NAMESPACE" \
    -o custom-columns=POD_NAME:.metadata.name,STATUS:.status.phase,IMAGES:.spec.containers[*].image

echo "----------------------------------------------------"
echo "Done."
