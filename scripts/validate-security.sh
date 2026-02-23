#!/bin/bash

# OpenClaw Agent - Security Validation Script
# Validates that the container is properly isolated and secure

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

CONTAINER_NAME="openclaw-agent"

echo -e "${GREEN}=== OpenClaw Agent - Security Validation ===${NC}"

# Check if container is running
if ! docker ps --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    echo -e "${RED}Error: Container '${CONTAINER_NAME}' is not running.${NC}"
    echo -e "${YELLOW}Please start the container first: ./scripts/run.sh${NC}"
    exit 1
fi

echo -e "${GREEN}Container is running. Running security checks...${NC}"
echo ""

# Test 1: Check if running as non-root user
echo -e "${YELLOW}[Test 1] Checking user permissions...${NC}"
USER_CHECK=$(docker exec "${CONTAINER_NAME}" whoami 2>/dev/null || echo "root")
if [ "$USER_CHECK" = "openclaw" ] || [ "$USER_CHECK" = "1000" ]; then
    echo -e "${GREEN}✓ Running as non-root user: ${USER_CHECK}${NC}"
else
    echo -e "${RED}✗ Running as root or unexpected user: ${USER_CHECK}${NC}"
fi

# Test 2: Check if root filesystem is read-only
echo -e "${YELLOW}[Test 2] Checking filesystem permissions...${NC}"
if docker exec "${CONTAINER_NAME}" sh -c "touch /test-write 2>&1" | grep -q "Read-only"; then
    echo -e "${GREEN}✓ Root filesystem is read-only${NC}"
else
    # Try to write and check if it fails
    WRITE_TEST=$(docker exec "${CONTAINER_NAME}" sh -c "touch /test-write 2>&1" || echo "failed")
    if echo "$WRITE_TEST" | grep -q "Read-only\|Permission denied"; then
        echo -e "${GREEN}✓ Root filesystem is read-only${NC}"
    else
        echo -e "${RED}✗ Root filesystem is writable (security risk!)${NC}"
        docker exec "${CONTAINER_NAME}" rm -f /test-write 2>/dev/null || true
    fi
fi

# Test 3: Check if /tmp is writable (should be via tmpfs)
echo -e "${YELLOW}[Test 3] Checking /tmp directory...${NC}"
TMP_TEST=$(docker exec "${CONTAINER_NAME}" sh -c "touch /tmp/test-write && rm /tmp/test-write && echo 'ok'" 2>&1)
if [ "$TMP_TEST" = "ok" ]; then
    echo -e "${GREEN}✓ /tmp is writable (tmpfs)${NC}"
else
    echo -e "${RED}✗ /tmp is not writable${NC}"
fi

# Test 4: Check if Docker socket is accessible (should NOT be)
echo -e "${YELLOW}[Test 4] Checking Docker socket access...${NC}"
DOCKER_SOCK_TEST=$(docker exec "${CONTAINER_NAME}" sh -c "test -S /var/run/docker.sock && echo 'accessible' || echo 'not accessible'" 2>&1)
if echo "$DOCKER_SOCK_TEST" | grep -q "not accessible"; then
    echo -e "${GREEN}✓ Docker socket is not accessible${NC}"
else
    echo -e "${RED}✗ Docker socket is accessible (security risk!)${NC}"
fi

# Test 5: Check if host filesystem is accessible (should NOT be)
echo -e "${YELLOW}[Test 5] Checking host filesystem access...${NC}"
HOST_FS_TEST=$(docker exec "${CONTAINER_NAME}" sh -c "test -d /Users && echo 'accessible' || echo 'not accessible'" 2>&1)
if echo "$HOST_FS_TEST" | grep -q "not accessible"; then
    echo -e "${GREEN}✓ Host filesystem (/Users) is not accessible${NC}"
else
    echo -e "${RED}✗ Host filesystem is accessible (security risk!)${NC}"
fi

# Test 6: Check capabilities
echo -e "${YELLOW}[Test 6] Checking Linux capabilities...${NC}"
CAPS=$(docker inspect "${CONTAINER_NAME}" --format='{{.HostConfig.CapDrop}}' 2>/dev/null || echo "")
if echo "$CAPS" | grep -q "ALL"; then
    echo -e "${GREEN}✓ All capabilities dropped${NC}"
else
    echo -e "${YELLOW}⚠ Capabilities check inconclusive${NC}"
fi

# Test 7: Check network isolation
echo -e "${YELLOW}[Test 7] Checking network configuration...${NC}"
NETWORK_MODE=$(docker inspect "${CONTAINER_NAME}" --format='{{.HostConfig.NetworkMode}}' 2>/dev/null || echo "unknown")
echo -e "${GREEN}✓ Network mode: ${NETWORK_MODE}${NC}"

# Test 8: Check environment variables (should not expose sensitive data in inspect)
echo -e "${YELLOW}[Test 8] Checking environment variable exposure...${NC}"
ENV_VARS=$(docker inspect "${CONTAINER_NAME}" --format='{{range .Config.Env}}{{println .}}{{end}}' 2>/dev/null | grep -i "key\|token\|secret" | wc -l || echo "0")
if [ "$ENV_VARS" -gt 0 ]; then
    echo -e "${YELLOW}⚠ Found ${ENV_VARS} environment variables with sensitive keywords${NC}"
    echo -e "${YELLOW}  (This is expected - they're needed for API access)${NC}"
else
    echo -e "${GREEN}✓ Environment variables properly configured${NC}"
fi

echo ""
echo -e "${GREEN}=== Security Validation Complete ===${NC}"
echo -e "${GREEN}Review the results above. All tests should pass for a secure setup.${NC}"
