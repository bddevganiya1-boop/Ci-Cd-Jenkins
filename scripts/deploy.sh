#!/usr/bin/env bash
set -e

# ==============================================================================
# Script: deploy.sh
# Purpose: Stop old container, deploy new container, verify health check
# ==============================================================================

IMAGE_NAME="${1:-cicd-jenkins-app}"
IMAGE_TAG="${2:-latest}"
CONTAINER_NAME="${3:-cicd-jenkins-container}"
HOST_PORT="${4:-3000}"
CONTAINER_PORT="3000"

echo "========================================================"
echo " [DEPLOY] Deploying Container: ${CONTAINER_NAME}"
echo " [DEPLOY] Image: ${IMAGE_NAME}:${IMAGE_TAG}"
echo " [DEPLOY] Port Mapping: ${HOST_PORT}:${CONTAINER_PORT}"
echo "========================================================"

# Check if old container exists and stop/remove it
if [ "$(docker ps -aq -f name=^/${CONTAINER_NAME}$)" ]; then
    echo "⚙ Stopping existing container: ${CONTAINER_NAME}..."
    docker stop "${CONTAINER_NAME}" || true
    echo "⚙ Removing existing container: ${CONTAINER_NAME}..."
    docker rm "${CONTAINER_NAME}" || true
fi

# Run the new container
echo "🚀 Starting new container: ${CONTAINER_NAME}..."
docker run -d \
    --name "${CONTAINER_NAME}" \
    --restart unless-stopped \
    -p "${HOST_PORT}:${CONTAINER_PORT}" \
    -e PORT="${CONTAINER_PORT}" \
    -e APP_VERSION="${IMAGE_TAG}" \
    "${IMAGE_NAME}:${IMAGE_TAG}"

echo "⏳ Waiting for service to initialize (5s)..."
sleep 5

# Health Check verification
HEALTH_URL="http://localhost:${HOST_PORT}/health"
echo "🔍 Performing health check on: ${HEALTH_URL}"

MAX_RETRIES=5
COUNT=0
HEALTH_STATUS="DOWN"

while [ $COUNT -lt $MAX_RETRIES ]; do
    if curl -s -f "${HEALTH_URL}" > /dev/null; then
        HEALTH_STATUS="UP"
        break
    fi
    echo "Waiting for health endpoint... retry $((COUNT+1))/$MAX_RETRIES"
    sleep 3
    COUNT=$((COUNT+1))
done

if [ "$HEALTH_STATUS" = "UP" ]; then
    echo "✔ [DEPLOY SUCCESS] Container ${CONTAINER_NAME} is UP and healthy on port ${HOST_PORT}!"
    exit 0
else
    echo "❌ [DEPLOY FAILED] Container failed health check at ${HEALTH_URL}."
    echo "Dumping container logs:"
    docker logs "${CONTAINER_NAME}"
    exit 1
fi
