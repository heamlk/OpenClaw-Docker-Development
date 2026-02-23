#!/usr/bin/env python3
"""
Example: How to use OpenAI API in your OpenClaw Agent
This demonstrates basic OpenAI API usage
"""

import os
import sys

# Method 1: Using OpenAI Python Library (Recommended)
def example_with_openai_library():
    """Example using the official OpenAI Python library"""
    try:
        from openai import OpenAI
        
        # Initialize client with API key from environment
        client = OpenAI(api_key=os.getenv("OPENAI_API_KEY"))
        
        print("=== Using OpenAI Python Library ===")
        print("")
        
        # Example 1: List available models
        print("Available models:")
        models = client.models.list()
        for model in list(models.data)[:5]:  # Show first 5
            print(f"  - {model.id}")
        print("")
        
        # Example 2: Simple chat completion
        print("Chat completion example:")
        response = client.chat.completions.create(
            model="gpt-3.5-turbo",
            messages=[
                {"role": "system", "content": "You are a helpful assistant."},
                {"role": "user", "content": "Say hello in one sentence."}
            ],
            max_tokens=50
        )
        
        print(f"Response: {response.choices[0].message.content}")
        print(f"Tokens used: {response.usage.total_tokens}")
        print("")
        
        return True
        
    except ImportError:
        print("OpenAI library not installed. Install with: pip install openai")
        return False
    except Exception as e:
        print(f"Error: {e}")
        return False


# Method 2: Using HTTP requests directly (No library needed)
def example_with_http_requests():
    """Example using HTTP requests (no external library needed)"""
    import urllib.request
    import json
    
    api_key = os.getenv("OPENAI_API_KEY")
    if not api_key:
        print("OPENAI_API_KEY not found")
        return False
    
    print("=== Using HTTP Requests (No Library) ===")
    print("")
    
    # Example: Chat completion via HTTP
    url = "https://api.openai.com/v1/chat/completions"
    headers = {
        "Authorization": f"Bearer {api_key}",
        "Content-Type": "application/json"
    }
    
    data = {
        "model": "gpt-3.5-turbo",
        "messages": [
            {"role": "system", "content": "You are a helpful assistant."},
            {"role": "user", "content": "Say hello in one sentence."}
        ],
        "max_tokens": 50
    }
    
    try:
        req = urllib.request.Request(
            url,
            data=json.dumps(data).encode('utf-8'),
            headers=headers,
            method="POST"
        )
        
        with urllib.request.urlopen(req, timeout=30) as response:
            result = json.loads(response.read().decode())
            print(f"Response: {result['choices'][0]['message']['content']}")
            print(f"Tokens used: {result['usage']['total_tokens']}")
            return True
            
    except Exception as e:
        print(f"Error: {e}")
        return False


def main():
    """Run examples"""
    api_key = os.getenv("OPENAI_API_KEY")
    if not api_key:
        print("ERROR: OPENAI_API_KEY not found in environment")
        print("Make sure your .env file has OPENAI_API_KEY set")
        return 1
    
    print(f"API Key found: {api_key[:10]}...")
    print("")
    
    # Try with library first, fallback to HTTP
    if not example_with_openai_library():
        print("")
        print("Falling back to HTTP requests method...")
        print("")
        if not example_with_http_requests():
            return 1
    
    return 0


if __name__ == "__main__":
    sys.exit(main())
