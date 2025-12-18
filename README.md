# AirSync-AutoGLM Integration

🤖 将 AI 手机控制能力集成到 AirSync 中

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](LICENSE)
[![AirSync](https://img.shields.io/badge/AirSync-v2.1.6+-green.svg)](https://github.com/sameerasw/airsync-mac)
[![AutoGLM](https://img.shields.io/badge/AutoGLM-Phone--9B-orange.svg)](https://github.com/zai-org/Open-AutoGLM)

## 📖 项目简介

本项目提供了将 [Open-AutoGLM](https://github.com/zai-org/Open-AutoGLM) 的 AI 自动化能力集成到 [AirSync](https://github.com/sameerasw/airsync-mac) 的完整方案。通过自然语言即可控制 Android 手机。

**注意：** 本项目基于 AirSync 的自编译版本（SELF_COMPILED），这是官方支持的功能。

## ✨ 功能特性

- 🗣️ **自然语言控制** - "打开微信给张三发消息"
- 🎯 **实时进度显示** - 查看每一步的执行过程
- 📊 **可展开步骤** - 类似思考模型的界面
- ⚡ **快速响应** - 0.3秒轮询，接近实时
- 🔧 **完整 API 服务器** - HTTP REST API
- 🌐 **多种模型支持** - ModelScope/BigModel/本地部署

## 🎬 演示

<p align="center">
  <img src="ex1.png" alt="AI 控制演示" width="600"/>
</p>

**真实案例：** 用户说"打开微信给张三发消息"，AutoGLM 自动执行 3 个步骤完成任务：

- **Step 1 • Launch** - 用户要求打开微信...
- **Step 2 • Tap** - 微信已打开，点击搜索...
- **Step 3 • Type** - 输入"张三"并发送消息...
- ✅ Task completed successfully!

## 🚀 快速开始

### 前置要求

- macOS 14.5+
- Python 3.10+
- Android 设备（Android 7.0+）
- ADB 工具
- ModelScope API Token（或其他模型服务）

### 1. 克隆仓库

```bash
git clone https://github.com/lianshuang-photo/airsync-autoglm-integration.git
cd airsync-autoglm-integration
```

### 2. 下载 AirSync

```bash
git clone https://github.com/sameerasw/airsync-mac.git
cd airsync-mac
```

### 3. 应用集成

**方法 A：直接使用修改后的文件（推荐）**

```bash
# 复制修改后的文件
cp -r airsync-autoglm-integration/modified-files/* airsync-mac/

# 在 Xcode 中添加新文件并设置 SELF_COMPILED 标志
```

详细步骤请查看 [modified-files/README.md](modified-files/README.md)

**方法 B：手动集成**

按照 [集成指南](docs/INTEGRATION_GUIDE.md) 的步骤手动修改文件

### 4. 启动 API 服务器

```bash
cd ../airsync-autoglm-integration

# 安装依赖
pip install -r requirements.txt

# 启动服务器（使用 ModelScope）
./start_with_modelscope.sh
```

### 5. 编译运行

在 Xcode 中：
1. 打开 `airsync-mac/AirSync.xcodeproj`
2. 选择 "AirSync Self Compiled" scheme
3. 点击 Run (Cmd+R)

## 📚 文档

- [集成指南](docs/INTEGRATION_GUIDE.md) - 完整的集成步骤
- [快速开始](docs/QUICKSTART.md) - 5分钟快速启动
- [ModelScope 配置](docs/MODELSCOPE_SETUP.md) - ModelScope API 使用
- [使用示例](docs/USAGE_EXAMPLES.md) - 各种使用场景

## 🔧 API 服务器

### 启动选项

```bash
# ModelScope（推荐）
python api_server.py \
    --base-url https://api-inference.modelscope.cn/v1 \
    --model ZhipuAI/AutoGLM-Phone-9B \
    --apikey ms-YOUR-TOKEN

# BigModel
python api_server.py \
    --base-url https://open.bigmodel.cn/api/paas/v4 \
    --model autoglm-phone \
    --apikey YOUR-API-KEY

# 本地部署
python api_server.py \
    --base-url http://localhost:8000/v1 \
    --model autoglm-phone-9b
```

### API 端点

- `GET /health` - 健康检查
- `GET /devices` - 列出设备
- `POST /execute` - 执行任务
- `GET /status` - 查询状态
- `POST /stop` - 停止任务

## 🎨 UI 特性

### 可展开的执行步骤

- 显示每一步的思考过程
- 点击展开/收缩详细内容
- 实时更新进度（0.3秒轮询）
- 类似思考模型的界面

### 消息类型

- 用户消息（蓝色）
- AI 回复（灰色）
- 进度消息（紫色，可展开）
- 系统消息（浅蓝色）
- 错误消息（红色）

## 📊 性能

- **API 响应**: < 200ms
- **简单任务**: 1-3秒
- **复杂任务**: 10-30秒
- **UI 更新延迟**: ~0.3秒

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

查看 [贡献指南](CONTRIBUTING.md) 了解详情。

## 📄 许可证

本项目采用 Apache 2.0 许可证 - 查看 [LICENSE](LICENSE) 文件了解详情。

### 第三方项目

- [Open-AutoGLM](https://github.com/zai-org/Open-AutoGLM) - Apache 2.0
- [AirSync](https://github.com/sameerasw/airsync-mac) - MPL 2.0

**注意：** 本项目基于 AirSync 的自编译功能（SELF_COMPILED），这是官方支持的特性。

## 🙏 致谢

- [Open-AutoGLM](https://github.com/zai-org/Open-AutoGLM) - AI 手机控制框架
- [AirSync](https://github.com/sameerasw/airsync-mac) - Mac-Android 同步工具
- [ModelScope](https://modelscope.cn/) - 模型推理服务

## ⭐ Star History

如果这个项目对你有帮助，请给个 Star！

---

**免责声明：** 本项目仅供学习和研究使用。请遵守相关法律法规和第三方服务的使用条款。
