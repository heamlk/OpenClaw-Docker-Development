#!/bin/bash

# OpenClaw Agent - Connectivity Test Script
# Tests outbound connectivity to required API endpoints

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

CONTAINER_NAME="openclaw-agent"

echo -e "${GREEN}=== OpenClaw Agent - Connectivity Test ===${NC}"

# Check if container is running
if ! docker ps --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    echo -e "${RED}Error: Container '${CONTAINER_NAME}' is not running.${NC}"
    echo -e "${YELLOW}Please start the container first: ./scripts/run.sh${NC}"
    exit 1
fi

echo -e "${GREEN}Container is running. Testing API connectivity...${NC}"
echo ""

# Test 1: OpenAI API
echo -e "${YELLOW}[Test 1] Testing OpenAI API connectivity...${NC}"
OPENAI_TEST=$(docker exec "${CONTAINER_NAME}" sh -c "curl -s -o /dev/null -w '%{http_code}' --connect-timeout 5 https://api.openai.com/v1/models" 2>&1 || echo "000")
if [ "$OPENAI_TEST" = "401" ] || [ "$OPENAI_TEST" = "200" ]; then
    echo -e "${GREEN}✓ OpenAI API is reachable (HTTP ${OPENAI_TEST})${NC}"
elif [ "$OPENAI_TEST" = "000" ]; then
    echo -e "${RED}✗ OpenAI API is not reachable (connection failed)${NC}"
else
    echo -e "${YELLOW}⚠ OpenAI API returned HTTP ${OPENAI_TEST}${NC}"
fi

# Test 2: Slack API
echo -e "${YELLOW}[Test 2] Testing Slack API connectivity...${NC}"
SLACK_TEST=$(docker exec "${CONTAINER_NAME}" sh -c "curl -s -o /dev/null -w '%{http_code}' --connect-timeout 5 https://api.slack.com/api/api.test" 2>&1 || echo "000")
if [ "$SLACK_TEST" = "200" ] || [ "$SLACK_TEST" = "401" ]; then
    echo -e "${GREEN}✓ Slack API is reachable (HTTP ${SLACK_TEST})${NC}"
elif [ "$SLACK_TEST" = "000" ]; then
    echo -e "${RED}✗ Slack API is not reachable (connection failed)${NC}"
else
    echo -e "${YELLOW}⚠ Slack API returned HTTP ${SLACK_TEST}${NC}"
fi

# Test 3: Google Sheets API
echo -e "${YELLOW}[Test 3] Testing Google Sheets API connectivity...${NC}"
GOOGLE_TEST=$(docker exec "${CONTAINER_NAME}" sh -c "curl -s -o /dev/null -w '%{http_code}' --connect-timeout 5 https://sheets.googleapis.com/v4/spreadsheets" 2>&1 || echo "000")
if [ "$GOOGLE_TEST" = "400" ] || [ "$GOOGLE_TEST" = "401" ] || [ "$GOOGLE_TEST" = "403" ]; then
    echo -e "${GREEN}✓ Google Sheets API is reachable (HTTP ${GOOGLE_TEST})${NC}"
elif [ "$GOOGLE_TEST" = "000" ]; then
    echo -e "${RED}✗ Google Sheets API is not reachable (connection failed)${NC}"
else
    echo -e "${YELLOW}⚠ Google Sheets API returned HTTP ${GOOGLE_TEST}${NC}"
fi

# Test 4: Google OAuth2 API
echo -e "${YELLOW}[Test 4] Testing Google OAuth2 API connectivity...${NC}"
OAUTH_TEST=$(docker exec "${CONTAINER_NAME}" sh -c "curl -s -o /dev/null -w '%{http_code}' --connect-timeout 5 https://oauth2.googleapis.com/token" 2>&1 || echo "000")
if [ "$OAUTH_TEST" = "400" ] || [ "$OAUTH_TEST" = "401" ]; then
    echo -e "${GREEN}✓ Google OAuth2 API is reachable (HTTP ${OAUTH_TEST})${NC}"
elif [ "$OAUTH_TEST" = "000" ]; then
    echo -e "${RED}✗ Google OAuth2 API is not reachable (connection failed)${NC}"
else
    echo -e "${YELLOW}⚠ Google OAuth2 API returned HTTP ${OAUTH_TEST}${NC}"
fi

# Test 5: DNS resolution
echo -e "${YELLOW}[Test 5] Testing DNS resolution...${NC}"
DNS_TEST=$(docker exec "${CONTAINER_NAME}" sh -c "nslookup api.openai.com > /dev/null 2>&1 && echo 'ok' || echo 'failed'" 2>&1)
if [ "$DNS_TEST" = "ok" ]; then
    echo -e "${GREEN}✓ DNS resolution working${NC}"
else
    echo -e "${RED}✗ DNS resolution failed${NC}"
fi

# Test 6: Check if curl is available
echo -e "${YELLOW}[Test 6] Checking required tools...${NC}"
CURL_CHECK=$(docker exec "${CONTAINER_NAME}" sh -c "which curl > /dev/null 2>&1 && echo 'ok' || echo 'missing'" 2>&1)
if [ "$CURL_CHECK" = "ok" ]; then
    echo -e "${GREEN}✓ curl is available${NC}"
else
    echo -e "${YELLOW}⚠ curl is not available (install curl in Dockerfile if needed)${NC}"
fi

echo ""
echo -e "${GREEN}=== Connectivity Test Complete ===${NC}"
echo -e "${YELLOW}Note: HTTP 401/403 responses are expected without valid credentials.${NC}"
echo -e "${YELLOW}The important thing is that the endpoints are reachable.${NC}"
