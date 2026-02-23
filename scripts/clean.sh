#!/bin/bash

# OpenClaw Agent - Docker Clean Script
# Removes containers, images, and cleans up Docker resources

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

CONTAINER_NAME="openclaw-agent"
IMAGE_NAME="openclaw-agent:latest"

echo -e "${GREEN}=== OpenClaw Agent - Docker Clean ===${NC}"

# Stop and remove container
if docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    echo -e "${YELLOW}Removing container '${CONTAINER_NAME}'...${NC}"
    docker stop "${CONTAINER_NAME}" > /dev/null 2>&1 || true
    docker rm "${CONTAINER_NAME}" > /dev/null 2>&1 || true
    echo -e "${GREEN}✓ Container removed.${NC}"
else
    echo -e "${YELLOW}Container '${CONTAINER_NAME}' not found.${NC}"
fi

# Remove image
if docker image inspect "${IMAGE_NAME}" > /dev/null 2>&1; then
    echo -e "${YELLOW}Removing image '${IMAGE_NAME}'...${NC}"
    docker rmi "${IMAGE_NAME}"
    echo -e "${GREEN}✓ Image removed.${NC}"
else
    echo -e "${YELLOW}Image '${IMAGE_NAME}' not found.${NC}"
fi

# Optional: Clean up dangling images and build cache
read -p "Clean up dangling images and build cache? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}Cleaning up Docker system...${NC}"
    docker system prune -f
    echo -e "${GREEN}✓ Docker system cleaned.${NC}"
fi

echo -e "${GREEN}✓ Cleanup complete!${NC}"
