#!/usr/bin/env bash
set -e

# ==============================================================================
# Script: build.sh
# Purpose: Build Docker image with version and latest tags
# ==============================================================================

IMAGE_NAME="${1:-cicd-jenkins-app}"
IMAGE_TAG="${2:-latest}"

echo "========================================================"
echo " [BUILD] Building Docker Image: ${IMAGE_NAME}:${IMAGE_TAG}"
echo "========================================================"

# Check if Docker is available
if ! command -v docker &> /dev/null; then
    echo "❌ Error: Docker is not installed or not in PATH."
    exit 1
fi

# Build Docker image
docker build \
    --build-arg APP_VERSION="${IMAGE_TAG}" \
    -t "${IMAGE_NAME}:${IMAGE_TAG}" \
    -t "${IMAGE_NAME}:latest" \
    .

echo "✔ [BUILD] Docker image built successfully: ${IMAGE_NAME}:${IMAGE_TAG}"
