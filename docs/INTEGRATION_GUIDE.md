# AirSync + Open-AutoGLM 集成指南

## 📖 概述

本指南介绍如何将 Open-AutoGLM 的 AI 自动化能力集成到 AirSync 中，实现通过自然语言控制 Android 设备。

## 🎯 功能特性

- **AI 聊天界面**：在 AirSync 中直接与 AI 对话，控制手机
- **自然语言控制**：说"打开微信给张三发消息"，AI 自动执行
- **实时状态显示**：查看 AI 执行进度和结果
- **无缝集成**：利用 AirSync 现有的 ADB 连接

## 🏗️ 架构设计

```
┌─────────────────────────────────────────┐
│         AirSync (Swift/macOS)           │
│  ┌──────────┐  ┌──────────┐  ┌────────┐│
│  │Notif Tab │  │ AI Chat  │  │Settings││
│  └──────────┘  └────┬─────┘  └────────┘│
│                     │ HTTP API          │
└─────────────────────┼───────────────────┘
                      │
              ┌───────▼────────┐
              │ AutoGLM Server │
              │  localhost:8765│
              └───────┬────────┘
                      │ ADB
              ┌───────▼────────┐
              │ Android Device │
              │ 192.168.x.x    │
              └────────────────┘
```

## 📦 文件结构

### Open-AutoGLM 新增文件

```
Open-AutoGLM-main/
├── api_server.py              # HTTP API 服务器
├── start_api_server.sh        # 启动脚本
└── requirements.txt           # 更新依赖（添加 Flask）
```

### AirSync 新增文件

```
airsync-mac-main/airsync-mac/
├── Core/Util/AutoGLM/
│   └── AutoGLMClient.swift    # API 客户端
├── Screens/HomeScreen/AIChatView/
│   └── AIChatView.swift       # AI 聊天界面
└── Screens/Settings/Components/
    └── AISettingsView.swift   # AI 配置界面
```

### 修改的文件

```
airsync-mac-main/airsync-mac/
├── Model/TabIdentifier.swift          # 添加 AI Chat 标签
├── Core/AppState.swift                # 添加 AI 配置状态
└── Screens/HomeScreen/AppContentView.swift  # 添加 AI Chat 标签页
```

## 🚀 快速开始

### 1. 安装 AutoGLM API 服务

```bash
# 进入 Open-AutoGLM 目录
cd Open-AutoGLM-main

# 安装依赖
pip install -r requirements.txt

# 启动 API 服务器

# 选项 A：使用 BigModel API
python3 api_server.py \
    --base-url https://open.bigmodel.cn/api/paas/v4 \
    --model autoglm-phone \
    --apikey YOUR_BIGMODEL_API_KEY

# 选项 B：使用 ModelScope API（推荐）
python3 api_server.py \
    --base-url https://api-inference.modelscope.cn/v1 \
    --model ZhipuAI/AutoGLM-Phone-9B \
    --apikey ms-YOUR-MODELSCOPE-TOKEN

# 或使用启动脚本
chmod +x start_api_server.sh
./start_api_server.sh
```

### 2. 配置 AirSync

1. 在 Xcode 中打开 AirSync 项目
2. 添加新创建的文件到项目中：
   - `AutoGLMClient.swift`
   - `AIChatView.swift`
   - `AISettingsView.swift`
3. 编译并运行 AirSync

### 3. 启用 AI 功能

1. 在 AirSync 中连接 Android 设备
2. 确保 ADB 已连接（Settings → ADB）
3. 进入 Settings → AI Assistant
4. 启用 "AI Assistant"
5. 确认服务器 URL 为 `http://127.0.0.1:8765`
6. 点击刷新按钮测试连接

### 4. 使用 AI Chat

1. 切换到 "AI Chat" 标签页（脑图标）
2. 输入自然语言指令，例如：
   - "打开微信给张三发消息"
   - "在淘宝搜索无线耳机"
   - "打开抖音刷视频"
3. 点击发送，AI 将自动执行任务

## 🔧 API 端点说明

### GET /health
健康检查，返回服务器状态和已连接设备

**响应示例：**
```json
{
  "status": "ok",
  "agent_initialized": true,
  "devices": [
    {
      "id": "192.168.1.100:5555",
      "status": "device",
      "type": "remote",
      "model": "Pixel 6"
    }
  ]
}
```

### POST /execute
执行任务

**请求体：**
```json
{
  "task": "打开微信给张三发消息",
  "device_id": "192.168.1.100:5555"
}
```

**响应：**
```json
{
  "status": "started",
  "task": "打开微信给张三发消息",
  "message": "Task execution started. Use /status to check progress."
}
```

### GET /status
查询任务执行状态

**响应：**
```json
{
  "running": true,
  "task": "打开微信给张三发消息",
  "step": 3,
  "message": null,
  "error": null
}
```

### POST /stop
停止当前任务

## ⚙️ 配置选项

### AutoGLM API 服务器

```bash
python3 api_server.py \
    --host 127.0.0.1 \          # 监听地址
    --port 8765 \               # 监听端口
    --base-url URL \            # 模型 API 地址
    --model MODEL_NAME \        # 模型名称
    --apikey API_KEY \          # API 密钥
    --device-id DEVICE_ID \     # 默认设备 ID
    --lang cn \                 # 语言（cn/en）
    --debug                     # 调试模式
```

### 环境变量

```bash
export AUTOGLM_BASE_URL="http://localhost:8000/v1"
export AUTOGLM_MODEL="autoglm-phone-9b"
export AUTOGLM_API_KEY="YOUR_KEY"
export AUTOGLM_HOST="127.0.0.1"
export AUTOGLM_PORT="8765"
export AUTOGLM_LANG="cn"
```

## 🎨 UI 界面说明

### AI Chat 标签页

- **聊天界面**：类似 ChatGPT 的对话界面
- **消息类型**：
  - 用户消息（蓝色气泡）
  - AI 回复（灰色气泡）
  - 系统消息（蓝色背景）
  - 错误消息（红色背景）
- **快捷提示**：点击示例提示快速输入
- **执行状态**：实时显示 AI 执行进度

### AI Settings

- **启用开关**：开启/关闭 AI 功能
- **服务器 URL**：配置 API 服务器地址
- **连接状态**：显示连接状态和错误信息
- **帮助文档**：查看详细设置说明

## 🔍 故障排查

### 问题：AI Chat 标签页不显示

**解决方案：**
1. 确保 ADB 已连接（Settings → ADB）
2. 确保 AI Assistant 已启用（Settings → AI Assistant）
3. 重启 AirSync

### 问题：连接失败

**解决方案：**
1. 检查 AutoGLM API 服务器是否运行：
   ```bash
   curl http://127.0.0.1:8765/health
   ```
2. 检查防火墙设置
3. 确认端口 8765 未被占用

### 问题：任务执行失败

**解决方案：**
1. 检查 ADB 连接状态
2. 确认设备 ID 正确
3. 查看 API 服务器日志
4. 检查模型服务是否正常

### 问题：模型响应慢

**解决方案：**
1. 使用本地部署的模型（需要 GPU）
2. 降低任务复杂度
3. 检查网络连接（如使用远程 API）

## 📊 性能优化

### 1. 使用本地模型

```bash
# 使用 vLLM 部署本地模型
python3 -m vllm.entrypoints.openai.api_server \
    --model zai-org/AutoGLM-Phone-9B \
    --port 8000

# 启动 AutoGLM API
python3 api_server.py \
    --base-url http://localhost:8000/v1 \
    --model autoglm-phone-9b
```

### 2. 调整轮询间隔

在 `AutoGLMClient.swift` 中修改：

```swift
statusCheckTimer = Timer.scheduledTimer(
    withTimeInterval: 0.5,  // 从 1.0 改为 0.5
    repeats: true
) { [weak self] _ in
    self?.checkStatus()
}
```

### 3. 启用调试模式

```bash
python3 api_server.py --debug
```

## 🔐 安全建议

1. **仅本地访问**：默认绑定到 `127.0.0.1`，不对外暴露
2. **API 密钥保护**：不要在代码中硬编码 API 密钥
3. **任务审核**：敏感操作需要用户确认
4. **日志管理**：定期清理日志文件

## 🚧 已知限制

1. **单任务执行**：同一时间只能执行一个任务
2. **无流式输出**：暂不支持实时显示 AI 思考过程
3. **ADB 依赖**：必须先建立 ADB 连接
4. **模型依赖**：需要外部模型服务

## 🔮 未来改进

- [ ] 支持流式输出（SSE）
- [ ] 任务队列管理
- [ ] 对话历史保存
- [ ] 自定义快捷指令
- [ ] 多设备并发控制
- [ ] 语音输入支持

## 📚 参考资料

- [Open-AutoGLM 文档](https://github.com/zai-org/Open-AutoGLM)
- [AirSync 文档](https://airsync.notion.site/)
- [Flask 文档](https://flask.palletsprojects.com/)
- [智谱 BigModel API](https://docs.bigmodel.cn/)
- [ModelScope API 配置](./MODELSCOPE_SETUP.md)
- [ModelScope 官方文档](https://modelscope.cn/docs)

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

## 📄 许可证

本集成遵循 Open-AutoGLM 和 AirSync 各自的许可证。
