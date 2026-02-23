#!/bin/bash

# OpenClaw Agent - Docker Build Script
# Builds the Docker image with proper security settings

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== OpenClaw Agent - Docker Build ===${NC}"

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo -e "${RED}Error: Docker is not running. Please start Docker Desktop.${NC}"
    exit 1
fi

# Check if .env file exists
if [ ! -f .env ]; then
    echo -e "${YELLOW}Warning: .env file not found.${NC}"
    echo -e "${YELLOW}Please copy .env.example to .env and configure your API credentials.${NC}"
    read -p "Continue anyway? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Build arguments
IMAGE_NAME="openclaw-agent"
IMAGE_TAG="latest"
BUILD_DATE=$(date -u +'%Y-%m-%dT%H:%M:%SZ')
VCS_REF=$(git rev-parse --short HEAD 2>/dev/null || echo "unknown")

echo -e "${GREEN}Building Docker image: ${IMAGE_NAME}:${IMAGE_TAG}${NC}"

# Build the image
docker build \
    --tag "${IMAGE_NAME}:${IMAGE_TAG}" \
    --label "org.opencontainers.image.created=${BUILD_DATE}" \
    --label "org.opencontainers.image.revision=${VCS_REF}" \
    --label "org.opencontainers.image.title=OpenClaw Agent" \
    --label "org.opencontainers.image.description=Sandboxed Docker environment for OpenClaw Agent" \
    --progress=plain \
    .

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Build successful!${NC}"
    echo -e "${GREEN}Image: ${IMAGE_NAME}:${IMAGE_TAG}${NC}"
    
    # Show image size
    IMAGE_SIZE=$(docker images "${IMAGE_NAME}:${IMAGE_TAG}" --format "{{.Size}}")
    echo -e "${GREEN}Image size: ${IMAGE_SIZE}${NC}"
else
    echo -e "${RED}✗ Build failed!${NC}"
    exit 1
fi
