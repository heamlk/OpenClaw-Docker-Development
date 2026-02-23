#!/bin/bash

# OpenClaw Agent - Docker Stop Script
# Gracefully stops the running container

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

CONTAINER_NAME="openclaw-agent"

echo -e "${GREEN}=== OpenClaw Agent - Docker Stop ===${NC}"

# Check if container exists
if ! docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    echo -e "${YELLOW}Container '${CONTAINER_NAME}' not found.${NC}"
    exit 0
fi

# Check if container is running
if docker ps --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    echo -e "${GREEN}Stopping container '${CONTAINER_NAME}'...${NC}"
    docker stop "${CONTAINER_NAME}"
    echo -e "${GREEN}✓ Container stopped successfully.${NC}"
else
    echo -e "${YELLOW}Container '${CONTAINER_NAME}' is not running.${NC}"
fi

# Ask if user wants to remove the container
read -p "Remove container? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    docker rm "${CONTAINER_NAME}"
    echo -e "${GREEN}✓ Container removed.${NC}"
fi
