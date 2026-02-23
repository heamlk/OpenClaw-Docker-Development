"""
OpenAI Client Wrapper for OpenClaw Agent
Provides easy-to-use functions for OpenAI API interactions
"""

import os
import logging
from typing import Optional, List, Dict, Any

logger = logging.getLogger(__name__)


class OpenAIClient:
    """Wrapper class for OpenAI API interactions"""
    
    def __init__(self, api_key: Optional[str] = None):
        """
        Initialize OpenAI client
        
        Args:
            api_key: OpenAI API key (defaults to OPENAI_API_KEY env var)
        """
        self.api_key = api_key or os.getenv("OPENAI_API_KEY")
        if not self.api_key:
            raise ValueError("OpenAI API key not found. Set OPENAI_API_KEY environment variable.")
        
        try:
            from openai import OpenAI
            self.client = OpenAI(api_key=self.api_key)
            self._use_library = True
        except ImportError:
            logger.warning("OpenAI library not installed. Using HTTP requests fallback.")
            self._use_library = False
            self.client = None
    
    def chat_completion(
        self,
        messages: List[Dict[str, str]],
        model: str = "gpt-3.5-turbo",
        temperature: float = 0.7,
        max_tokens: Optional[int] = None,
        **kwargs
    ) -> Dict[str, Any]:
        """
        Create a chat completion
        
        Args:
            messages: List of message dicts with 'role' and 'content'
            model: Model to use (default: gpt-3.5-turbo)
            temperature: Sampling temperature (0-2)
            max_tokens: Maximum tokens to generate
            **kwargs: Additional parameters for the API
        
        Returns:
            Dict with 'content', 'usage', and 'model' keys
        
        Example:
            messages = [
                {"role": "system", "content": "You are a helpful assistant."},
                {"role": "user", "content": "Hello!"}
            ]
            response = client.chat_completion(messages)
            print(response['content'])
        """
        if self._use_library:
            return self._chat_completion_library(messages, model, temperature, max_tokens, **kwargs)
        else:
            return self._chat_completion_http(messages, model, temperature, max_tokens, **kwargs)
    
    def _chat_completion_library(
        self,
        messages: List[Dict[str, str]],
        model: str,
        temperature: float,
        max_tokens: Optional[int],
        **kwargs
    ) -> Dict[str, Any]:
        """Use OpenAI library for chat completion"""
        params = {
            "model": model,
            "messages": messages,
            "temperature": temperature,
        }
        if max_tokens:
            params["max_tokens"] = max_tokens
        params.update(kwargs)
        
        try:
            response = self.client.chat.completions.create(**params)
            return {
                "content": response.choices[0].message.content,
                "usage": {
                    "prompt_tokens": response.usage.prompt_tokens,
                    "completion_tokens": response.usage.completion_tokens,
                    "total_tokens": response.usage.total_tokens,
                },
                "model": response.model,
            }
        except Exception as e:
            logger.error(f"OpenAI API error: {e}")
            raise
    
    def _chat_completion_http(
        self,
        messages: List[Dict[str, str]],
        model: str,
        temperature: float,
        max_tokens: Optional[int],
        **kwargs
    ) -> Dict[str, Any]:
        """Use HTTP requests for chat completion (fallback)"""
        import urllib.request
        import json
        
        url = "https://api.openai.com/v1/chat/completions"
        headers = {
            "Authorization": f"Bearer {self.api_key}",
            "Content-Type": "application/json"
        }
        
        data = {
            "model": model,
            "messages": messages,
            "temperature": temperature,
        }
        if max_tokens:
            data["max_tokens"] = max_tokens
        data.update(kwargs)
        
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
                    "model": result["model"],
                }
        except Exception as e:
            logger.error(f"OpenAI API error: {e}")
            raise
    
    def list_models(self) -> List[str]:
        """List available OpenAI models"""
        if self._use_library:
            try:
                models = self.client.models.list()
                return [model.id for model in models.data]
            except Exception as e:
                logger.error(f"Error listing models: {e}")
                return []
        else:
            # Fallback: return common models
            return [
                "gpt-4",
                "gpt-4-turbo-preview",
                "gpt-3.5-turbo",
                "gpt-3.5-turbo-16k",
            ]


# Convenience function for quick usage
def get_openai_client() -> OpenAIClient:
    """Get an initialized OpenAI client"""
    return OpenAIClient()
