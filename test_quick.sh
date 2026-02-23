#!/bin/bash
# Quick test script for sandbox environment

echo "=========================================="
echo "Quick Sandbox Test"
echo "=========================================="
echo ""

echo "1. Testing Tools:"
docker exec openclaw-agent python --version
docker exec openclaw-agent pip --version
docker exec openclaw-agent git --version
echo ""

echo "2. Testing Git Clone:"
docker exec openclaw-agent sh -c "cd /tmp && rm -rf test-repo && git clone --depth 1 https://github.com/octocat/Hello-World.git test-repo >/dev/null 2>&1 && echo '✅ Git clone works!' && rm -rf test-repo"
echo ""

echo "3. Testing Pip Install:"
docker exec openclaw-agent python -c "import requests" 2>/dev/null && echo "✅ Pip install works (requests already installed)" || docker exec openclaw-agent pip install --user requests >/dev/null 2>&1 && docker exec openclaw-agent python -c "import requests; print('✅ Pip install works!')"
echo ""

echo "4. Testing Isolation:"
docker exec openclaw-agent sh -c "test -d /Users || echo '✅ Isolated from host filesystem'"
docker exec openclaw-agent sh -c "test -S /var/run/docker.sock || echo '✅ Isolated from Docker socket'"
echo ""

echo "5. Testing File Operations:"
docker exec openclaw-agent sh -c "echo 'test' > /tmp/test.txt && cat /tmp/test.txt >/dev/null && rm /tmp/test.txt && echo '✅ /tmp is writable'"
docker exec openclaw-agent sh -c "touch /test.txt 2>&1 | grep -q 'Read-only' && echo '✅ Root filesystem is read-only' || echo '⚠️  Root filesystem check'"
echo ""

echo "6. Container Status:"
docker-compose ps | grep openclaw-agent
echo ""

echo "=========================================="
echo "✅ All tests complete!"
echo "=========================================="
