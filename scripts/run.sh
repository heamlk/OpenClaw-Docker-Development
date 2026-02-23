#!/bin/bash

# OpenClaw Agent - Docker Run Script
# Runs the container with maximum security isolation

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== OpenClaw Agent - Docker Run ===${NC}"

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo -e "${RED}Error: Docker is not running. Please start Docker Desktop.${NC}"
    exit 1
fi

# Check if image exists
IMAGE_NAME="openclaw-agent:latest"
if ! docker image inspect "${IMAGE_NAME}" > /dev/null 2>&1; then
    echo -e "${YELLOW}Image not found. Building...${NC}"
    ./scripts/build.sh
fi

# Check if .env file exists
if [ ! -f .env ]; then
    echo -e "${RED}Error: .env file not found.${NC}"
    echo -e "${YELLOW}Please copy .env.example to .env and configure your API credentials.${NC}"
    exit 1
fi

# Validate required environment variables
source .env
REQUIRED_VARS=("OPENAI_API_KEY" "SLACK_BOT_TOKEN")
MISSING_VARS=()

for var in "${REQUIRED_VARS[@]}"; do
    if [ -z "${!var}" ]; then
        MISSING_VARS+=("$var")
    fi
done

if [ ${#MISSING_VARS[@]} -ne 0 ]; then
    echo -e "${RED}Error: Missing required environment variables:${NC}"
    printf '%s\n' "${MISSING_VARS[@]}"
    exit 1
fi

# Container name
CONTAINER_NAME="openclaw-agent"

# Stop and remove existing container if running
if docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    echo -e "${YELLOW}Stopping existing container...${NC}"
    docker stop "${CONTAINER_NAME}" > /dev/null 2>&1 || true
    docker rm "${CONTAINER_NAME}" > /dev/null 2>&1 || true
fi

echo -e "${GREEN}Starting container with security isolation...${NC}"

# Run container with security flags
docker run -d \
    --name "${CONTAINER_NAME}" \
    --read-only \
    --tmpfs /tmp:noexec,nosuid,size=100m \
    --user 1000:1000 \
    --cap-drop=ALL \
    --security-opt no-new-privileges \
    --network bridge \
    --env-file .env \
    --cpus="4" \
    --memory="8g" \
    --memory-swap="8g" \
    --restart unless-stopped \
    --log-driver json-file \
    --log-opt max-size=10m \
    --log-opt max-file=3 \
    "${IMAGE_NAME}"

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Container started successfully!${NC}"
    echo -e "${GREEN}Container name: ${CONTAINER_NAME}${NC}"
    echo ""
    echo -e "${YELLOW}Useful commands:${NC}"
    echo -e "  View logs:    docker logs -f ${CONTAINER_NAME}"
    echo -e "  Stop:         docker stop ${CONTAINER_NAME}"
    echo -e "  Remove:       docker rm -f ${CONTAINER_NAME}"
    echo -e "  Shell access: docker exec -it ${CONTAINER_NAME} /bin/bash"
    echo ""
    echo -e "${GREEN}Following logs (Ctrl+C to exit)...${NC}"
    docker logs -f "${CONTAINER_NAME}"
else
    echo -e "${RED}✗ Failed to start container!${NC}"
    exit 1
fi
