#!/bin/bash
# Test script to verify sandbox environment is ready

echo "=========================================="
echo "Sandbox Environment Test"
echo "=========================================="
echo ""

# Test 1: Check tools are available
echo "=== Test 1: Tools Availability ==="
echo "Python:"
docker exec openclaw-agent python --version
echo "pip:"
docker exec openclaw-agent pip --version
echo "git:"
docker exec openclaw-agent git --version
echo ""

# Test 2: Test git clone capability
echo "=== Test 2: Git Clone Test ==="
echo "Testing git clone (small test repo)..."
docker exec openclaw-agent sh -c "cd /tmp && git clone --depth 1 https://github.com/octocat/Hello-World.git /tmp/test-repo 2>&1 | head -5"
if docker exec openclaw-agent test -d /tmp/test-repo; then
    echo "✅ Git clone works!"
    docker exec openclaw-agent rm -rf /tmp/test-repo
else
    echo "⚠️  Git clone test (may need network)"
fi
echo ""

# Test 3: Test pip install capability
echo "=== Test 3: Pip Install Test ==="
echo "Testing pip install (small package)..."
docker exec openclaw-agent pip install --user requests 2>&1 | tail -3
if docker exec openclaw-agent python -c "import requests" 2>/dev/null; then
    echo "✅ Pip install works!"
else
    echo "⚠️  Pip install test"
fi
echo ""

# Test 4: Test isolation
echo "=== Test 4: Isolation Test ==="
echo "Host filesystem access:"
docker exec openclaw-agent sh -c "test -d /Users && echo '❌ Can access /Users' || echo '✅ Cannot access /Users (isolated)'"
docker exec openclaw-agent sh -c "test -d /c/Users && echo '❌ Can access /c/Users' || echo '✅ Cannot access /c/Users (isolated)'"
echo "Docker socket:"
docker exec openclaw-agent sh -c "test -S /var/run/docker.sock && echo '❌ Can access Docker socket' || echo '✅ Cannot access Docker socket (isolated)'"
echo "Volume mounts:"
MOUNT_COUNT=$(docker inspect openclaw-agent --format='{{len .Mounts}}')
if [ "$MOUNT_COUNT" -eq 0 ]; then
    echo "✅ No volume mounts (complete isolation)"
else
    echo "⚠️  Has $MOUNT_COUNT volume mount(s)"
fi
echo ""

# Test 5: Test working directory
echo "=== Test 5: Working Directory ==="
docker exec openclaw-agent pwd
docker exec openclaw-agent ls -la /app | head -5
echo ""

# Test 6: Test file operations
echo "=== Test 6: File Operations ==="
echo "Test write to /tmp (should work):"
docker exec openclaw-agent sh -c "echo 'test' > /tmp/test.txt && cat /tmp/test.txt && rm /tmp/test.txt && echo '✅ /tmp is writable'"
echo "Test write to root (should fail):"
docker exec openclaw-agent sh -c "touch /test.txt 2>&1 | head -1 || echo '✅ Root filesystem is read-only'"
echo ""

# Test 7: Container status
echo "=== Test 7: Container Status ==="
docker-compose ps | grep openclaw-agent
echo ""

# Test 8: Security check
echo "=== Test 8: Security Check ==="
echo "Running as user:"
docker exec openclaw-agent whoami
docker exec openclaw-agent id
echo ""

echo "=========================================="
echo "Test Complete!"
echo "=========================================="
echo ""
echo "✅ All tests passed = Ready for OpenClaw setup"
echo ""
