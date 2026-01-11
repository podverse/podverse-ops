#!/usr/bin/env bash

# Version: 1
# Description: 
#   Hard resets the Alpha Database.
#   1. Pauses ArgoCD Auto-Sync (to prevent it from fighting us).
#   2. Scales the DB to 0 (to release the volume lock).
#   3. Deletes the PVC (the persistent data).
#   4. Re-enables ArgoCD Auto-Sync (which recreates the DB and a fresh Volume).

# Stop on any error
set -e

APP_NAME="podverse-alpha-db"
ARGOCD_NS="argocd"
TARGET_NS="podverse-alpha"
STATEFULSET_NAME="podverse-db"
PVC_NAME="db-data-podverse-db-0"

echo "⚠️  WARNING: This will destroy all data in the $TARGET_NS database."
echo "   App: $APP_NAME"
echo "   PVC: $PVC_NAME"
read -p "Are you sure? (y/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    echo "Aborting."
    exit 1
fi

echo "------------------------------------------------"
echo "Step 1: Pausing ArgoCD Auto-Sync..."
# We patch the ArgoCD Application to remove the 'automated' sync policy temporarily.
# This prevents ArgoCD from trying to 'heal' the StatefulSet while we are deleting it.
kubectl patch application $APP_NAME -n $ARGOCD_NS --type merge \
    -p '{"spec":{"syncPolicy":{"automated":null}}}'

echo "------------------------------------------------"
echo "Step 2: Scaling down StatefulSet..."
# We must scale to 0 to ensure no process is holding a lock on the volume files.
kubectl scale statefulset $STATEFULSET_NAME -n $TARGET_NS --replicas=0

echo "Waiting for pods to terminate..."
kubectl wait --for=delete pod --selector=app=$STATEFULSET_NAME -n $TARGET_NS --timeout=60s

echo "------------------------------------------------"
echo "Step 3: Deleting Persistent Volume Claim (PVC)..."
# This is the actual 'destruction' of the data.
# Note: In K3s with local-path, this usually deletes the folder on the host node immediately.
kubectl delete pvc $PVC_NAME -n $TARGET_NS

echo "------------------------------------------------"
echo "Step 4: Restoring ArgoCD..."
# We re-apply the automated sync policy. 
# ArgoCD will detect the StatefulSet is missing (or at 0 replicas) and the PVC is missing,
# and it will recreate them according to git.
kubectl patch application $APP_NAME -n $ARGOCD_NS --type merge \
    -p '{"spec":{"syncPolicy":{"automated":{"prune":true,"selfHeal":true}}}}'

echo "------------------------------------------------"
echo "✅ Database reset complete. ArgoCD should now provision a fresh empty database."
echo "   Monitor progress with: kubectl get pods -n $TARGET_NS -w"
