#!/usr/bin/env python3
"""
Test script to verify connectivity to OpenAI, Slack, and Google Sheets APIs
"""

import os
import sys
import urllib.request
import urllib.error
import json
from urllib.parse import urlencode

# Colors for output
GREEN = '\033[0;32m'
RED = '\033[0;31m'
YELLOW = '\033[1;33m'
NC = '\033[0m'  # No Color

def test_openai():
    """Test OpenAI API connectivity"""
    print(f"{YELLOW}[Test 1] Testing OpenAI API connectivity...{NC}")
    
    api_key = os.getenv("OPENAI_API_KEY", "")
    if not api_key:
        print(f"{RED}✗ OPENAI_API_KEY not found in environment{NC}")
        return False
    
    url = "https://api.openai.com/v1/models"
    headers = {
        "Authorization": f"Bearer {api_key}",
        "Content-Type": "application/json"
    }
    
    try:
        req = urllib.request.Request(url, headers=headers)
        with urllib.request.urlopen(req, timeout=10) as response:
            status_code = response.getcode()
            if status_code == 200:
                print(f"{GREEN}✓ OpenAI API is reachable and authenticated (HTTP {status_code}){NC}")
                return True
            elif status_code == 401:
                print(f"{YELLOW}⚠ OpenAI API is reachable but authentication failed (HTTP {status_code}){NC}")
                print(f"{YELLOW}  Check if your API key is valid{NC}")
                return False
            else:
                print(f"{YELLOW}⚠ OpenAI API returned HTTP {status_code}{NC}")
                return False
    except urllib.error.HTTPError as e:
        status_code = e.code
        if status_code == 401:
            print(f"{YELLOW}⚠ OpenAI API is reachable but authentication failed (HTTP {status_code}){NC}")
            print(f"{YELLOW}  Check if your API key is valid{NC}")
        elif status_code == 429:
            print(f"{YELLOW}⚠ OpenAI API rate limit exceeded (HTTP {status_code}){NC}")
        else:
            print(f"{YELLOW}⚠ OpenAI API returned HTTP {status_code}{NC}")
        return False
    except urllib.error.URLError as e:
        print(f"{RED}✗ OpenAI API is not reachable: {e.reason}{NC}")
        return False
    except Exception as e:
        print(f"{RED}✗ Error testing OpenAI API: {str(e)}{NC}")
        return False

def test_slack():
    """Test Slack API connectivity"""
    print(f"{YELLOW}[Test 2] Testing Slack API connectivity...{NC}")
    
    bot_token = os.getenv("SLACK_BOT_TOKEN", "")
    if not bot_token:
        print(f"{RED}✗ SLACK_BOT_TOKEN not found in environment{NC}")
        return False
    
    url = "https://slack.com/api/auth.test"
    headers = {
        "Authorization": f"Bearer {bot_token}",
        "Content-Type": "application/x-www-form-urlencoded"
    }
    
    try:
        req = urllib.request.Request(url, headers=headers, method="POST")
        with urllib.request.urlopen(req, timeout=10) as response:
            status_code = response.getcode()
            data = json.loads(response.read().decode())
            
            if status_code == 200:
                if data.get("ok"):
                    print(f"{GREEN}✓ Slack API is reachable and authenticated (HTTP {status_code}){NC}")
                    print(f"{GREEN}  Connected as: {data.get('user', 'unknown')} ({data.get('team', 'unknown')}){NC}")
                    return True
                else:
                    error = data.get("error", "unknown error")
                    print(f"{YELLOW}⚠ Slack API returned error: {error}{NC}")
                    if error == "invalid_auth":
                        print(f"{YELLOW}  Your SLACK_BOT_TOKEN may be invalid or expired.{NC}")
                        print(f"{YELLOW}  Make sure you're using a Bot User OAuth Token (starts with 'xoxb-'){NC}")
                    return False
            else:
                print(f"{YELLOW}⚠ Slack API returned HTTP {status_code}{NC}")
                return False
    except urllib.error.HTTPError as e:
        status_code = e.code
        if status_code == 401:
            print(f"{YELLOW}⚠ Slack API is reachable but authentication failed (HTTP {status_code}){NC}")
            print(f"{YELLOW}  Check if your bot token is valid{NC}")
        else:
            print(f"{YELLOW}⚠ Slack API returned HTTP {status_code}{NC}")
        return False
    except urllib.error.URLError as e:
        print(f"{RED}✗ Slack API is not reachable: {e.reason}{NC}")
        return False
    except Exception as e:
        print(f"{RED}✗ Error testing Slack API: {str(e)}{NC}")
        return False

def test_google_sheets():
    """Test Google Sheets API connectivity"""
    print(f"{YELLOW}[Test 3] Testing Google Sheets API connectivity...{NC}")
    
    # Test basic connectivity to the discovery API endpoint
    url = "https://sheets.googleapis.com/$discovery/rest?version=v4"
    
    try:
        req = urllib.request.Request(url)
        with urllib.request.urlopen(req, timeout=10) as response:
            status_code = response.getcode()
            print(f"{GREEN}✓ Google Sheets API is reachable (HTTP {status_code}){NC}")
            return True
    except urllib.error.HTTPError as e:
        status_code = e.code
        if status_code in [400, 401, 403]:
            print(f"{GREEN}✓ Google Sheets API is reachable (HTTP {status_code} - expected without auth){NC}")
            return True
        elif status_code == 404:
            # Try alternative endpoint
            try:
                alt_url = "https://www.googleapis.com/discovery/v1/apis/sheets/v4/rest"
                alt_req = urllib.request.Request(alt_url)
                with urllib.request.urlopen(alt_req, timeout=10) as alt_response:
                    alt_status = alt_response.getcode()
                    print(f"{GREEN}✓ Google Sheets API is reachable via discovery API (HTTP {alt_status}){NC}")
                    return True
            except:
                print(f"{GREEN}✓ Google Sheets API endpoint is reachable (HTTP {status_code} - endpoint exists){NC}")
                return True
        else:
            print(f"{YELLOW}⚠ Google Sheets API returned HTTP {status_code}{NC}")
            return False
    except urllib.error.URLError as e:
        print(f"{RED}✗ Google Sheets API is not reachable: {e.reason}{NC}")
        return False
    except Exception as e:
        print(f"{RED}✗ Error testing Google Sheets API: {str(e)}{NC}")
        return False

def test_google_oauth2():
    """Test Google OAuth2 API connectivity"""
    print(f"{YELLOW}[Test 4] Testing Google OAuth2 API connectivity...{NC}")
    
    url = "https://oauth2.googleapis.com/token"
    
    try:
        req = urllib.request.Request(url, method="POST")
        with urllib.request.urlopen(req, timeout=10) as response:
            status_code = response.getcode()
            print(f"{GREEN}✓ Google OAuth2 API is reachable (HTTP {status_code}){NC}")
            return True
    except urllib.error.HTTPError as e:
        status_code = e.code
        if status_code in [400, 401]:
            print(f"{GREEN}✓ Google OAuth2 API is reachable (HTTP {status_code} - expected without auth){NC}")
            return True
        else:
            print(f"{YELLOW}⚠ Google OAuth2 API returned HTTP {status_code}{NC}")
            return False
    except urllib.error.URLError as e:
        print(f"{RED}✗ Google OAuth2 API is not reachable: {e.reason}{NC}")
        return False
    except Exception as e:
        print(f"{RED}✗ Error testing Google OAuth2 API: {str(e)}{NC}")
        return False

def main():
    """Run all connectivity tests"""
    print(f"{GREEN}=== API Connectivity Test ==={NC}")
    print("")
    
    results = []
    results.append(("OpenAI API", test_openai()))
    print("")
    results.append(("Slack API", test_slack()))
    print("")
    results.append(("Google Sheets API", test_google_sheets()))
    print("")
    results.append(("Google OAuth2 API", test_google_oauth2()))
    print("")
    
    # Summary
    print(f"{GREEN}=== Test Summary ==={NC}")
    passed = sum(1 for _, result in results if result)
    total = len(results)
    
    for name, result in results:
        status = f"{GREEN}✓ PASS{NC}" if result else f"{RED}✗ FAIL{NC}"
        print(f"{name}: {status}")
    
    print("")
    print(f"Total: {passed}/{total} tests passed")
    
    if passed == total:
        print(f"{GREEN}All API connectivity tests passed!{NC}")
        return 0
    else:
        print(f"{YELLOW}Some tests failed. Check your API credentials and network connectivity.{NC}")
        return 1

if __name__ == "__main__":
    sys.exit(main())
