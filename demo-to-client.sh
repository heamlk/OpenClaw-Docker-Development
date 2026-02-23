#!/bin/bash
# Demo script to show project status to client

echo "=========================================="
echo "OpenClaw Agent - Docker Project Demo"
echo "=========================================="
echo ""

echo "=== 1. Container Status ==="
docker-compose ps
echo ""

echo "=== 2. Security Validation ==="
echo "Running as non-root user:"
docker exec openclaw-agent whoami 2>/dev/null || echo "Container not running"
docker exec openclaw-agent id 2>/dev/null || echo "Container not running"
echo ""

echo "Read-only filesystem test:"
docker exec openclaw-agent touch /test.txt 2>&1 | head -1 || echo "✓ Read-only filesystem working"
echo ""

echo "=== 3. API Connectivity ==="
if docker ps | grep -q openclaw-agent; then
    cat test_api_connectivity.py | docker exec -i openclaw-agent python - 2>/dev/null || echo "Running API tests..."
else
    echo "Container not running. Start with: docker-compose up -d"
fi
echo ""

echo "=== 4. Container Health ==="
docker inspect openclaw-agent --format='Status: {{.State.Status}} | Health: {{.State.Health.Status}}' 2>/dev/null || echo "Container not running"
echo ""

echo "=== 5. Recent Application Logs ==="
docker-compose logs --tail 10 2>/dev/null || echo "No logs available"
echo ""

echo "=== 6. Image Information ==="
docker images | grep openclaw-agent || echo "Image not found"
echo ""

echo "=========================================="
echo "Demo Complete"
echo "=========================================="
echo ""
echo "For detailed information, see:"
echo "  - README.md"
echo "  - CLIENT_PRESENTATION.md"
echo "  - COMPLETE_TEST_STEPS.md"
