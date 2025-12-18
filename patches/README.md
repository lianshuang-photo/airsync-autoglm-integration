# AirSync 集成补丁

本目录包含将 AutoGLM 集成到 AirSync 所需的修改说明。

## 📋 修改清单

| 文件 | 类型 | 说明 |
|------|------|------|
| AutoGLMClient.swift | 新增 | AutoGLM API 客户端 |
| AIChatView.swift | 新增 | AI 聊天界面 |
| AISettingsView.swift | 新增 | AI 设置界面 |
| TabIdentifier.swift | 修改 | 添加 AI Chat 标签 |
| AppState.swift | 修改 | 添加 AI 状态管理 |
| SettingsView.swift | 修改 | 集成 AI 设置 |

## 🚀 快速开始

### 方法 1：按照文档手动集成（推荐）

1. 阅读 [集成指南](../docs/INTEGRATION_GUIDE.md)
2. 按照步骤创建新文件
3. 修改现有文件

### 方法 2：参考修改说明

查看 `modifications/` 目录中的详细说明：
- `01-TabIdentifier.md` - 添加 AI Chat 标签
- `02-AppState.md` - 添加 AI 状态
- `03-SettingsView.md` - 集成设置界面
- `04-NewFiles.md` - 新文件创建指南

## ⚠️ 重要提示

由于 AirSync 的许可证限制，我们不能直接提供修改后的源代码。请：

1. 自行下载 AirSync 源代码
2. 按照说明进行修改
3. 仅供个人使用

## 📚 相关文档

- [集成指南](../docs/INTEGRATION_GUIDE.md)
- [快速开始](../docs/QUICKSTART.md)
- [故障排查](../docs/INTEGRATION_GUIDE.md#故障排查)
