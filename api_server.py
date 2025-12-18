#!/usr/bin/env python3
"""
AutoGLM HTTP API Server for AirSync Integration

This server provides a REST API for controlling Android devices via AutoGLM.
It's designed to be called from the AirSync macOS app.

Usage:
    python api_server.py --base-url http://localhost:8000/v1 --model autoglm-phone-9b
"""

import argparse
import json
import os
import threading
from typing import Optional

from flask import Flask, jsonify, request, Response, stream_with_context
from flask_cors import CORS
import time

from phone_agent import PhoneAgent
from phone_agent.adb import list_devices
from phone_agent.agent import AgentConfig
from phone_agent.model import ModelConfig

app = Flask(__name__)
CORS(app)  # Allow requests from AirSync

# Global agent instance
agent: Optional[PhoneAgent] = None
agent_lock = threading.Lock()
current_task_status = {
    "running": False,
    "task": None,
    "step": 0,
    "message": None,
    "error": None,
    "thinking": None,
    "action": None,
    "progress": []
}


@app.route('/health', methods=['GET'])
def health_check():
    """Health check endpoint."""
    return jsonify({
        "status": "ok",
        "agent_initialized": agent is not None,
        "devices": [
            {
                "id": d.device_id,
                "status": d.status,
                "type": d.connection_type.value,
                "model": d.model
            }
            for d in list_devices()
        ]
    })


@app.route('/devices', methods=['GET'])
def get_devices():
    """List connected ADB devices."""
    devices = list_devices()
    return jsonify({
        "devices": [
            {
                "id": d.device_id,
                "status": d.status,
                "connection_type": d.connection_type.value,
                "model": d.model
            }
            for d in devices
        ]
    })


@app.route('/execute', methods=['POST'])
def execute_task():
    """
    Execute a task on the connected device.
    
    Request body:
    {
        "task": "打开微信给张三发消息",
        "device_id": "192.168.1.100:5555",  // optional
        "stream": false  // optional, for future streaming support
    }
    """
    global current_task_status
    
    if not agent:
        return jsonify({"error": "Agent not initialized"}), 500
    
    data = request.get_json()
    if not data or 'task' not in data:
        return jsonify({"error": "Missing 'task' in request body"}), 400
    
    task = data['task']
    device_id = data.get('device_id')
    
    # Check if a task is already running
    with agent_lock:
        if current_task_status["running"]:
            return jsonify({
                "error": "Another task is already running",
                "current_task": current_task_status["task"]
            }), 409
        
        # Mark task as running
        current_task_status = {
            "running": True,
            "task": task,
            "step": 0,
            "message": "Starting task...",
            "error": None,
            "thinking": None,
            "action": None,
            "progress": []
        }
    
    # Execute task in background thread
    def run_task():
        global current_task_status
        try:
            # Update device_id if provided
            if device_id:
                agent.agent_config.device_id = device_id
            
            # Reset agent for new task
            agent.reset()
            
            # Execute task step by step to capture progress
            result = agent.step(task)
            
            with agent_lock:
                current_task_status["step"] = agent.step_count
                current_task_status["thinking"] = result.thinking
                current_task_status["action"] = result.action
                current_task_status["progress"].append({
                    "step": agent.step_count,
                    "thinking": result.thinking[:200] + "..." if len(result.thinking) > 200 else result.thinking,
                    "action": result.action.get("action") if result.action else None
                })
            
            # Continue until finished
            while not result.finished and agent.step_count < agent.agent_config.max_steps:
                result = agent.step()
                
                with agent_lock:
                    current_task_status["step"] = agent.step_count
                    current_task_status["thinking"] = result.thinking
                    current_task_status["action"] = result.action
                    current_task_status["progress"].append({
                        "step": agent.step_count,
                        "thinking": result.thinking[:200] + "..." if len(result.thinking) > 200 else result.thinking,
                        "action": result.action.get("action") if result.action else None
                    })
            
            # Task completed
            final_message = result.message or "Task completed successfully!"
            
            with agent_lock:
                current_task_status = {
                    "running": False,
                    "task": task,
                    "step": agent.step_count,
                    "message": final_message,
                    "error": None,
                    "thinking": result.thinking,
                    "action": result.action,
                    "progress": current_task_status["progress"]
                }
        except Exception as e:
            with agent_lock:
                current_task_status = {
                    "running": False,
                    "task": task,
                    "step": agent.step_count if agent else 0,
                    "message": None,
                    "error": str(e),
                    "thinking": None,
                    "action": None,
                    "progress": current_task_status.get("progress", [])
                }
    
    thread = threading.Thread(target=run_task, daemon=True)
    thread.start()
    
    return jsonify({
        "status": "started",
        "task": task,
        "message": "Task execution started. Use /status to check progress."
    })


@app.route('/status', methods=['GET'])
def get_status():
    """Get current task execution status."""
    with agent_lock:
        return jsonify(current_task_status)


@app.route('/stop', methods=['POST'])
def stop_task():
    """Stop the currently running task."""
    global current_task_status
    
    with agent_lock:
        if not current_task_status["running"]:
            return jsonify({"error": "No task is running"}), 400
        
        # Note: This doesn't actually stop the agent, just marks it as stopped
        # A proper implementation would need to add cancellation support to PhoneAgent
        current_task_status["running"] = False
        current_task_status["message"] = "Task stopped by user"
    
    return jsonify({"status": "stopped"})


@app.route('/chat', methods=['POST'])
def chat():
    """
    Chat-style interaction with the agent.
    
    Request body:
    {
        "message": "打开微信",
        "device_id": "192.168.1.100:5555",  // optional
        "conversation_id": "uuid"  // optional, for maintaining context
    }
    """
    # This is a simplified version - you could extend it to maintain conversation history
    data = request.get_json()
    if not data or 'message' not in data:
        return jsonify({"error": "Missing 'message' in request body"}), 400
    
    # For now, just execute as a task
    return execute_task()


def parse_args():
    """Parse command line arguments."""
    parser = argparse.ArgumentParser(
        description="AutoGLM HTTP API Server for AirSync"
    )
    
    parser.add_argument(
        "--host",
        type=str,
        default="127.0.0.1",
        help="Host to bind the server to (default: 127.0.0.1)"
    )
    
    parser.add_argument(
        "--port",
        type=int,
        default=8765,
        help="Port to bind the server to (default: 8765)"
    )
    
    parser.add_argument(
        "--base-url",
        type=str,
        default=os.getenv("PHONE_AGENT_BASE_URL", "http://localhost:8000/v1"),
        help="Model API base URL"
    )
    
    parser.add_argument(
        "--model",
        type=str,
        default=os.getenv("PHONE_AGENT_MODEL", "autoglm-phone-9b"),
        help="Model name"
    )
    
    parser.add_argument(
        "--apikey",
        type=str,
        default=os.getenv("PHONE_AGENT_API_KEY", "EMPTY"),
        help="API key for model authentication"
    )
    
    parser.add_argument(
        "--device-id",
        type=str,
        default=os.getenv("PHONE_AGENT_DEVICE_ID"),
        help="Default ADB device ID"
    )
    
    parser.add_argument(
        "--lang",
        type=str,
        choices=["cn", "en"],
        default=os.getenv("PHONE_AGENT_LANG", "cn"),
        help="Language for system prompt"
    )
    
    parser.add_argument(
        "--debug",
        action="store_true",
        help="Enable debug mode"
    )
    
    return parser.parse_args()


def main():
    """Main entry point."""
    global agent
    
    args = parse_args()
    
    print("=" * 60)
    print("AutoGLM API Server for AirSync")
    print("=" * 60)
    print(f"Model: {args.model}")
    print(f"Base URL: {args.base_url}")
    print(f"Language: {args.lang}")
    print(f"Server: http://{args.host}:{args.port}")
    print("=" * 60)
    
    # Initialize agent
    model_config = ModelConfig(
        base_url=args.base_url,
        model_name=args.model,
        api_key=args.apikey,
        lang=args.lang,
    )
    
    agent_config = AgentConfig(
        device_id=args.device_id,
        lang=args.lang,
        verbose=args.debug,
    )
    
    agent = PhoneAgent(
        model_config=model_config,
        agent_config=agent_config,
    )
    
    print("\n✅ Agent initialized successfully!")
    print(f"\nAPI Endpoints:")
    print(f"  GET  /health  - Health check")
    print(f"  GET  /devices - List connected devices")
    print(f"  POST /execute - Execute a task")
    print(f"  POST /chat    - Chat with the agent")
    print(f"  GET  /status  - Get task status")
    print(f"  POST /stop    - Stop current task")
    print("\n" + "=" * 60 + "\n")
    
    # Run Flask app
    app.run(
        host=args.host,
        port=args.port,
        debug=args.debug,
        threaded=True
    )


if __name__ == "__main__":
    main()
