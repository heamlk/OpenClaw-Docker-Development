#!/usr/bin/env python3
"""
Quick script to check if Slack token format is correct
"""

import os
import sys

GREEN = '\033[0;32m'
RED = '\033[0;31m'
YELLOW = '\033[1;33m'
NC = '\033[0m'

def check_slack_token():
    """Check Slack token format"""
    token = os.getenv("SLACK_BOT_TOKEN", "")
    
    if not token:
        print(f"{RED}✗ SLACK_BOT_TOKEN not found in environment{NC}")
        return False
    
    # Show first few characters (for verification, not full token)
    preview = token[:10] + "..." if len(token) > 10 else token
    
    print(f"{YELLOW}Checking Slack token format...{NC}")
    print(f"Token preview: {preview}")
    print("")
    
    if token.startswith("xoxb-"):
        print(f"{GREEN}✓ Token format is correct (starts with 'xoxb-'){NC}")
        print(f"{GREEN}  This is a Bot User OAuth Token{NC}")
        return True
    elif token.startswith("xoxp-"):
        print(f"{YELLOW}⚠ Token starts with 'xoxp-' (User OAuth Token){NC}")
        print(f"{YELLOW}  You need a Bot User OAuth Token (starts with 'xoxb-'){NC}")
        return False
    else:
        print(f"{RED}✗ Token format is incorrect{NC}")
        print(f"{RED}  Expected format: xoxb-... (Bot User OAuth Token){NC}")
        print(f"{YELLOW}  Current format: {preview}{NC}")
        print("")
        print(f"{YELLOW}To fix this:{NC}")
        print(f"  1. Go to https://api.slack.com/apps")
        print(f"  2. Create/select your Slack app")
        print(f"  3. Go to 'OAuth & Permissions'")
        print(f"  4. Copy the 'Bot User OAuth Token' (starts with xoxb-)")
        print(f"  5. Update SLACK_BOT_TOKEN in your .env file")
        print(f"  6. Restart container: docker-compose restart")
        return False

if __name__ == "__main__":
    result = check_slack_token()
    sys.exit(0 if result else 1)
