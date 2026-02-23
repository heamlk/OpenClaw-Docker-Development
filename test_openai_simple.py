#!/usr/bin/env python3
"""
Simple test to demonstrate OpenAI usage
"""

import sys
import os

try:
    # Import directly (PYTHONPATH should include /app)
    from openai_client import get_openai_client
    
    print("=== OpenAI Test ===")
    print("")
    
    # Initialize client
    print("Initializing OpenAI client...")
    client = get_openai_client()
    print("✓ Client initialized")
    print("")
    
    # Simple chat completion
    print("Sending a simple message...")
    messages = [
        {"role": "system", "content": "You are a helpful assistant. Keep responses brief."},
        {"role": "user", "content": "Say hello in one sentence."}
    ]
    
    response = client.chat_completion(messages, max_tokens=50)
    
    print(f"Response: {response['content']}")
    print(f"Tokens used: {response['usage']['total_tokens']}")
    print("")
    print("✓ OpenAI is working correctly!")
    
except ImportError as e:
    print(f"Error importing: {e}")
    print("Make sure the container is rebuilt with OpenAI installed")
    sys.exit(1)
except Exception as e:
    print(f"Error: {e}")
    sys.exit(1)
