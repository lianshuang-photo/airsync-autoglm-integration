# 🚀 快速开始：AirSync AI Assistant

5 分钟内让 AI 控制你的 Android 手机！

## 📋 前置要求

- ✅ macOS 14.5+
- ✅ Python 3.10+
- ✅ Android 设备（Android 7.0+）
- ✅ ADB 工具
- ✅ 智谱 BigModel API Key（或其他模型服务）

## 🎯 三步启动

### 第一步：启动 AutoGLM API 服务（2分钟）

```bash
# 1. 进入 Open-AutoGLM 目录
cd Open-AutoGLM-main

# 2. 安装依赖（首次运行）
pip install -r requirements.txt

# 3. 启动 API 服务器

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
```

看到这个输出就成功了：
```
✅ Agent initialized successfully!

API Endpoints:
  GET  /health  - Health check
  POST /execute - Execute a task
  ...
```

### 第二步：配置 AirSync（2分钟）

1. **在 Xcode 中打开 AirSync 项目**

2. **添加新文件到项目**：
   - 右键点击项目 → Add Files to "AirSync"
   - 添加以下文件夹：
     - `airsync-mac/Core/Util/AutoGLM/`
     - `airsync-mac/Screens/HomeScreen/AIChatView/`
     - `airsync-mac/Screens/Settings/Components/AISettingsView.swift`

3. **编译并运行**：
   - 选择 "AirSync Self Compiled" Scheme
   - 点击 Run (Cmd+R)

### 第三步：开始使用（1分钟）

1. **连接设备**：
   - 在 AirSync 中扫描二维码连接 Android 设备
   - 或使用 Quick Connect

2. **启用 ADB**：
   - 进入 Settings → Features
   - 启用 "Auto connect ADB"
   - 点击 "Connect ADB"

3. **启用 AI**：
   - 进入 Settings → AI Assistant
   - 启用 "AI Assistant"
   - 确认连接状态为绿色

4. **开始聊天**：
   - 切换到 "AI Chat" 标签页（脑图标）
   - 输入：`打开微信`
   - 点击发送，看 AI 自动操作！

## 🎉 成功！

现在你可以用自然语言控制手机了！

### 试试这些指令：

```
打开淘宝搜索无线耳机
在小红书搜索美食推荐
打开抖音刷视频
在美团搜索附近的火锅店
```

## 🔧 故障排查

### 问题：API 服务器启动失败

```bash
# 检查 Python 版本
python3 --version  # 应该 >= 3.10

# 重新安装依赖
pip install -r requirements.txt --force-reinstall
```

### 问题：AirSync 连接失败

1. 检查 API 服务器是否运行：
   ```bash
   curl http://127.0.0.1:8765/health
   ```

2. 在 AirSync Settings → AI Assistant 中点击刷新按钮

### 问题：AI Chat 标签页不显示

1. 确保 ADB 已连接（Settings → Features）
2. 确保 AI Assistant 已启用（Settings → AI Assistant）
3. 重启 AirSync

## 📚 下一步

- 📖 阅读 [完整集成指南](./INTEGRATION_GUIDE.md)
- 💡 查看 [使用示例](./USAGE_EXAMPLES.md)
- 🔍 了解 [项目总结](./SUMMARY.md)

## 🆘 需要帮助？

- 查看 [故障排查指南](./INTEGRATION_GUIDE.md#故障排查)
- 提交 GitHub Issue
- 加入社区讨论

## 🎊 享受 AI 控制的乐趣！

现在你可以躺在沙发上，用 Mac 控制手机了！
