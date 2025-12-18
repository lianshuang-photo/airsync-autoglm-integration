#!/usr/bin/env python3
"""
Test script for ModelScope API integration

This script tests the ModelScope API directly without using the AutoGLM agent.
"""

import os
import sys
import requests
from openai import OpenAI


def test_modelscope_api():
    """Test ModelScope API with sample data."""
    
    # Get API key from environment or command line
    api_key = os.getenv("MODELSCOPE_API_KEY")
    if not api_key and len(sys.argv) > 1:
        api_key = sys.argv[1]
    
    if not api_key:
        print("❌ Error: ModelScope API key not provided")
        print("\nUsage:")
        print("  python3 test_modelscope.py ms-YOUR-TOKEN")
        print("  or set MODELSCOPE_API_KEY environment variable")
        sys.exit(1)
    
    print("=" * 60)
    print("Testing ModelScope API")
    print("=" * 60)
    print(f"API Key: {api_key[:10]}...{api_key[-10:]}")
    print()
    
    try:
        # Initialize OpenAI client with ModelScope endpoint
        print("📡 Initializing client...")
        client = OpenAI(
            base_url='https://api-inference.modelscope.cn/v1',
            api_key=api_key,
        )
        print("✅ Client initialized")
        print()
        
        # Get test data from ModelScope
        print("📥 Fetching test data...")
        json_url = "https://modelscope.oss-cn-beijing.aliyuncs.com/phone_agent_test.json"
        response_json = requests.get(json_url)
        response_json.raise_for_status()
        messages = response_json.json()
        print(f"✅ Loaded {len(messages)} messages")
        print()
        
        # Display messages
        print("📝 Test messages:")
        for i, msg in enumerate(messages, 1):
            role = msg.get('role', 'unknown')
            content = msg.get('content', '')
            if isinstance(content, list):
                content_preview = f"[{len(content)} items]"
            else:
                content_preview = content[:100] + "..." if len(content) > 100 else content
            print(f"  {i}. {role}: {content_preview}")
        print()
        
        # Call the model
        print("🤖 Calling AutoGLM-Phone-9B model...")
        response = client.chat.completions.create(
            model='ZhipuAI/AutoGLM-Phone-9B',
            messages=messages,
            temperature=0.0,
            max_tokens=1024,
            stream=False
        )
        print("✅ Model response received")
        print()
        
        # Display response
        print("=" * 60)
        print("Model Response:")
        print("=" * 60)
        print(response.choices[0].message.content)
        print("=" * 60)
        print()
        
        # Display usage info
        if hasattr(response, 'usage'):
            print("📊 Token Usage:")
            print(f"  Prompt tokens: {response.usage.prompt_tokens}")
            print(f"  Completion tokens: {response.usage.completion_tokens}")
            print(f"  Total tokens: {response.usage.total_tokens}")
        
        print()
        print("✅ Test completed successfully!")
        
    except requests.exceptions.RequestException as e:
        print(f"❌ Network error: {e}")
        sys.exit(1)
    except Exception as e:
        print(f"❌ Error: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)


def test_api_server():
    """Test the AutoGLM API server."""
    
    print("\n" + "=" * 60)
    print("Testing AutoGLM API Server")
    print("=" * 60)
    
    base_url = "http://127.0.0.1:8765"
    
    try:
        # Test health endpoint
        print(f"📡 Testing {base_url}/health...")
        response = requests.get(f"{base_url}/health", timeout=5)
        response.raise_for_status()
        data = response.json()
        
        print("✅ API server is running")
        print(f"  Status: {data.get('status')}")
        print(f"  Agent initialized: {data.get('agent_initialized')}")
        print(f"  Devices: {len(data.get('devices', []))}")
        
        for device in data.get('devices', []):
            print(f"    - {device.get('id')} ({device.get('status')})")
        
        print()
        print("✅ API server test completed!")
        
    except requests.exceptions.ConnectionError:
        print("❌ Cannot connect to API server")
        print(f"   Make sure the server is running on {base_url}")
        print("\n   Start the server with:")
        print("   python3 api_server.py \\")
        print("       --base-url https://api-inference.modelscope.cn/v1 \\")
        print("       --model ZhipuAI/AutoGLM-Phone-9B \\")
        print("       --apikey ms-YOUR-TOKEN")
    except Exception as e:
        print(f"❌ Error: {e}")


if __name__ == "__main__":
    # Test ModelScope API directly
    test_modelscope_api()
    
    # Test AutoGLM API server
    test_api_server()
