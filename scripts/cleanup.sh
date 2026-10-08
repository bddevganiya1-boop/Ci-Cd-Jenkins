#!/usr/bin/env bash
set -e

# ==============================================================================
# Script: cleanup.sh
# Purpose: Prune dangling images and clean build cache
# ==============================================================================

echo "========================================================"
echo " [CLEANUP] Pruning dangling Docker images..."
echo "========================================================"

# Remove dangling docker images to free up disk space on Jenkins node
DANGLING_IMAGES=$(docker images -f "dangling=true" -q)
if [ -n "$DANGLING_IMAGES" ]; then
    echo "Removing dangling images: $DANGLING_IMAGES"
    docker rmi $DANGLING_IMAGES || true
else
    echo "No dangling images found."
fi

echo "✔ [CLEANUP] Cleanup completed."
