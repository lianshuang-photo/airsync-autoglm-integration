#!/bin/bash
# AutoGLM API Server Startup Script with ModelScope
# 使用 ModelScope API 启动 AutoGLM 服务器

# ============================================
# 配置说明
# ============================================
# 1. 访问 https://modelscope.cn/
# 2. 注册/登录账号
# 3. 进入个人中心 → API Token
# 4. 复制你的 Token（格式：ms-xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx）
# 5. 将下面的 YOUR_MODELSCOPE_TOKEN 替换为你的 Token
# ============================================

# ModelScope 配置
BASE_URL="https://api-inference.modelscope.cn/v1"
MODEL="ZhipuAI/AutoGLM-Phone-9B"
API_KEY="${MODELSCOPE_API_KEY:-YOUR_MODELSCOPE_TOKEN}"

# 服务器配置
HOST="127.0.0.1"
PORT="8765"
LANG="cn"

# 检查 API Key
if [ "$API_KEY" = "YOUR_MODELSCOPE_TOKEN" ]; then
    echo "❌ 错误：请先配置 ModelScope API Token"
    echo ""
    echo "方法 1：编辑此脚本，将 YOUR_MODELSCOPE_TOKEN 替换为你的 Token"
    echo "方法 2：设置环境变量："
    echo "  export MODELSCOPE_API_KEY='ms-your-token-here'"
    echo ""
    echo "获取 Token："
    echo "  1. 访问 https://modelscope.cn/"
    echo "  2. 注册/登录账号"
    echo "  3. 进入个人中心 → API Token"
    echo "  4. 复制你的 Token"
    echo ""
    exit 1
fi

echo "=========================================="
echo "Starting AutoGLM API Server"
echo "Using ModelScope API"
echo "=========================================="
echo "Model: $MODEL"
echo "Base URL: $BASE_URL"
echo "Server: http://$HOST:$PORT"
echo "Language: $LANG"
echo "API Key: ${API_KEY:0:10}...${API_KEY: -10}"
echo "=========================================="
echo ""

# 检查 Python
if ! command -v python3 &> /dev/null; then
    echo "❌ 错误：未找到 python3"
    echo "请安装 Python 3.10 或更高版本"
    exit 1
fi

# 检查依赖
echo "📦 检查依赖..."
if ! python3 -c "import flask" 2>/dev/null; then
    echo "⚠️  Flask 未安装，正在安装依赖..."
    pip3 install -r requirements.txt
fi

if ! python3 -c "import openai" 2>/dev/null; then
    echo "⚠️  OpenAI 未安装，正在安装..."
    pip3 install openai
fi

echo "✅ 依赖检查完成"
echo ""

# 启动服务器
echo "🚀 启动服务器..."
python3 api_server.py \
    --host "$HOST" \
    --port "$PORT" \
    --base-url "$BASE_URL" \
    --model "$MODEL" \
    --apikey "$API_KEY" \
    --lang "$LANG"
