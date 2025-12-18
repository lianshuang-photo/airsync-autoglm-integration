# 使用 ModelScope API 配置 AutoGLM

## 📖 概述

ModelScope 提供了 AutoGLM-Phone-9B 模型的在线推理服务，无需本地部署即可使用。

## 🔑 获取 ModelScope Token

1. 访问 [ModelScope](https://modelscope.cn/)
2. 注册/登录账号
3. 进入个人中心 → API Token
4. 复制你的 Token（格式：`ms-xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx`）

## 🚀 启动 API 服务器

### 方法 1：使用命令行参数

```bash
cd Open-AutoGLM-main

python3 api_server.py \
    --base-url https://api-inference.modelscope.cn/v1 \
    --model ZhipuAI/AutoGLM-Phone-9B \
    --apikey ms-YOUR-TOKEN-HERE
```

### 方法 2：使用环境变量

```bash
export PHONE_AGENT_BASE_URL="https://api-inference.modelscope.cn/v1"
export PHONE_AGENT_MODEL="ZhipuAI/AutoGLM-Phone-9B"
export PHONE_AGENT_API_KEY="ms-YOUR-TOKEN-HERE"

python3 api_server.py
```

### 方法 3：使用 ModelScope 专用启动脚本（推荐）

我们提供了一个专门的启动脚本 `start_with_modelscope.sh`：

```bash
# 1. 编辑脚本，替换 YOUR_MODELSCOPE_TOKEN 为你的 Token
nano start_with_modelscope.sh

# 或者设置环境变量
export MODELSCOPE_API_KEY="ms-YOUR-TOKEN-HERE"

# 2. 运行脚本
chmod +x start_with_modelscope.sh
./start_with_modelscope.sh
```

### 方法 4：修改通用启动脚本

编辑 `start_api_server.sh`，取消注释 ModelScope 配置：

```bash
# Option 2: ModelScope API (推荐)
BASE_URL="https://api-inference.modelscope.cn/v1"
MODEL="ZhipuAI/AutoGLM-Phone-9B"
API_KEY="ms-YOUR-TOKEN-HERE"
```

然后运行：

```bash
chmod +x start_api_server.sh
./start_api_server.sh
```

## 📝 完整示例代码

如果你想直接测试 ModelScope API（不通过 api_server.py），可以使用以下代码：

```python
from openai import OpenAI
import requests

# 初始化客户端
client = OpenAI(
    base_url='https://api-inference.modelscope.cn/v1',
    api_key='ms-YOUR-TOKEN-HERE',  # 替换为你的 ModelScope Token
)

# 获取测试数据
json_url = "https://modelscope.oss-cn-beijing.aliyuncs.com/phone_agent_test.json"
response_json = requests.get(json_url)
messages = response_json.json()

# 调用模型
response = client.chat.completions.create(
    model='ZhipuAI/AutoGLM-Phone-9B',
    messages=messages,
    temperature=0.0,
    max_tokens=1024,
    stream=False
)

print(response.choices[0].message.content)
```

## ✅ 验证配置

### 1. 测试 API 服务器

```bash
# 健康检查
curl http://127.0.0.1:8765/health

# 应该返回：
# {
#   "status": "ok",
#   "agent_initialized": true,
#   "devices": [...]
# }
```

### 2. 测试 ModelScope API

使用专门的 ModelScope 测试脚本：

```bash
cd Open-AutoGLM-main

# 方法 1：直接传入 Token
python3 test_modelscope.py ms-YOUR-TOKEN-HERE

# 方法 2：使用环境变量
export MODELSCOPE_API_KEY="ms-YOUR-TOKEN-HERE"
python3 test_modelscope.py
```

这个脚本会：
- 测试 ModelScope API 连接
- 使用官方测试数据调用模型
- 显示模型响应和 Token 使用情况
- 测试 AutoGLM API 服务器连接

### 3. 测试任务执行

```bash
# 使用通用测试脚本
cd Open-AutoGLM-main
python3 test_api.py
```

### 3. 在 AirSync 中测试

1. 启动 AirSync
2. 连接 Android 设备
3. 启用 ADB 连接
4. 进入 Settings → AI Assistant
5. 启用 AI Assistant
6. 确认连接状态为绿色
7. 切换到 AI Chat 标签页
8. 输入测试指令：`打开设置`

## 🆚 ModelScope vs BigModel

| 特性 | ModelScope | BigModel |
|------|-----------|----------|
| 注册 | 免费注册 | 免费注册 |
| 模型 | ZhipuAI/AutoGLM-Phone-9B | autoglm-phone |
| API 格式 | OpenAI 兼容 | OpenAI 兼容 |
| 响应速度 | 快 | 快 |
| 稳定性 | 高 | 高 |
| 费用 | 按调用计费 | 按调用计费 |

## 💰 费用说明

ModelScope 的推理服务按调用次数计费，具体费用请查看 [ModelScope 定价](https://modelscope.cn/pricing)。

建议：
- 开发测试阶段使用在线 API
- 生产环境考虑本地部署（如果有 GPU）

## 🔧 故障排查

### 问题 1：Token 无效

**错误信息：**
```
Authentication failed
```

**解决方案：**
1. 检查 Token 格式是否正确（应该以 `ms-` 开头）
2. 确认 Token 未过期
3. 在 ModelScope 网站重新生成 Token

### 问题 2：模型不可用

**错误信息：**
```
Model not found
```

**解决方案：**
1. 确认模型名称为 `ZhipuAI/AutoGLM-Phone-9B`（区分大小写）
2. 检查 ModelScope 服务状态
3. 尝试访问 [模型页面](https://modelscope.cn/models/ZhipuAI/AutoGLM-Phone-9B)

### 问题 3：请求超时

**错误信息：**
```
Request timeout
```

**解决方案：**
1. 检查网络连接
2. 尝试使用代理（如果在国外）
3. 增加超时时间

### 问题 4：配额不足

**错误信息：**
```
Quota exceeded
```

**解决方案：**
1. 检查 ModelScope 账户余额
2. 升级账户套餐
3. 等待配额重置

## 🌐 网络要求

- 需要稳定的互联网连接
- 能够访问 `api-inference.modelscope.cn`
- 如果在国外，可能需要使用代理

## 📊 性能对比

### 在线 API（ModelScope/BigModel）

**优点：**
- ✅ 无需本地 GPU
- ✅ 快速启动
- ✅ 自动更新模型
- ✅ 稳定可靠

**缺点：**
- ❌ 需要网络连接
- ❌ 按调用计费
- ❌ 响应时间受网络影响

### 本地部署（vLLM/SGLang）

**优点：**
- ✅ 无网络依赖
- ✅ 无调用费用
- ✅ 数据隐私
- ✅ 可定制化

**缺点：**
- ❌ 需要 GPU（24GB+ 显存）
- ❌ 部署复杂
- ❌ 维护成本高

## 🔄 切换到本地部署

如果你有 GPU，可以切换到本地部署：

```bash
# 1. 使用 vLLM 部署模型
python3 -m vllm.entrypoints.openai.api_server \
    --model zai-org/AutoGLM-Phone-9B \
    --port 8000

# 2. 启动 AutoGLM API 服务器
python3 api_server.py \
    --base-url http://localhost:8000/v1 \
    --model autoglm-phone-9b \
    --apikey EMPTY
```

## 📚 相关文档

- [ModelScope 官方文档](https://modelscope.cn/docs)
- [AutoGLM 项目](https://github.com/zai-org/Open-AutoGLM)
- [集成指南](./INTEGRATION_GUIDE.md)
- [快速开始](./QUICKSTART.md)

## 🆘 获取帮助

如果遇到问题：
1. 查看 [故障排查](#故障排查) 部分
2. 查看 ModelScope 服务状态
3. 提交 GitHub Issue
4. 加入社区讨论

## 🎉 开始使用

现在你已经配置好 ModelScope API，可以开始使用 AI 控制手机了！

```bash
# 启动服务器
python3 api_server.py \
    --base-url https://api-inference.modelscope.cn/v1 \
    --model ZhipuAI/AutoGLM-Phone-9B \
    --apikey ms-YOUR-TOKEN-HERE

# 在 AirSync 中开始聊天！
```

---

**最后更新：** 2024-12-18
