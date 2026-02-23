#!/bin/bash
# Quick script to test API connectivity

echo "=== Testing API Connectivity ==="
echo ""

cd "$(dirname "$0")"

# Run the test script inside the container
cat test_api_connectivity.py | docker exec -i openclaw-agent python -
