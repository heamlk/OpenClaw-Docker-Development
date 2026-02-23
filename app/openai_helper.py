"""
OpenAI Helper Functions - Works without installing OpenAI library
Uses HTTP requests directly (no dependencies needed)
"""

import urllib.request
import json
import os
import logging

logger = logging.getLogger(__name__)


def call_openai(
    messages: list,
    model: str = "gpt-3.5-turbo",
    max_tokens: int = 200,
    temperature: float = 0.7
) -> dict:
    """
    Call OpenAI API using HTTP requests
    
    Args:
        messages: List of message dicts with 'role' and 'content'
                  Example: [{"role": "user", "content": "Hello!"}]
        model: Model to use (default: "gpt-3.5-turbo")
        max_tokens: Maximum tokens to generate
        temperature: Sampling temperature (0-2)
    
    Returns:
        Dict with 'content', 'usage', and 'model' keys
    
    Example:
        response = call_openai([{"role": "user", "content": "Hello!"}])
        print(response['content'])
    """
    api_key = os.getenv("OPENAI_API_KEY")
    if not api_key:
        raise ValueError("OPENAI_API_KEY not found in environment")
    
    url = "https://api.openai.com/v1/chat/completions"
    
    headers = {
        "Authorization": f"Bearer {api_key}",
        "Content-Type": "application/json"
    }
    
    data = {
        "model": model,
        "messages": messages,
        "max_tokens": max_tokens,
        "temperature": temperature
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
            return {
                "content": result["choices"][0]["message"]["content"],
                "usage": result["usage"],
                "model": result["model"]
            }
    except urllib.error.HTTPError as e:
        error_body = e.read().decode() if e.fp else "Unknown error"
        logger.error(f"OpenAI API HTTP error {e.code}: {error_body}")
        raise
    except Exception as e:
        logger.error(f"OpenAI API error: {e}")
        raise


def ask_question(question: str, system_prompt: str = None) -> str:
    """
    Simple function to ask OpenAI a question
    
    Args:
        question: The question to ask
        system_prompt: Optional system prompt
    
    Returns:
        The answer as a string
    
    Example:
        answer = ask_question("What is Python?")
        print(answer)
    """
    messages = []
    if system_prompt:
        messages.append({"role": "system", "content": system_prompt})
    messages.append({"role": "user", "content": question})
    
    response = call_openai(messages)
    return response['content']
