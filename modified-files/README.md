# 修改后的 AirSync 文件

本目录包含已集成 AutoGLM 功能的 AirSync 源文件。

## 📁 文件列表

### 新增文件

```
Core/Util/AutoGLM/
└── AutoGLMClient.swift          # AutoGLM API 客户端

Screens/HomeScreen/AIChatView/
└── AIChatView.swift             # AI 聊天界面

Screens/Settings/Components/
└── AISettingsView.swift         # AI 设置界面
```

### 修改的文件

```
Configs/
└── SelfCompiled.xcconfig        # 修改了编译标志

Core/
├── AppState.swift               # 添加了 AI 状态管理
└── Trial/
    └── TrialManager.swift       # 添加了 SELF_COMPILED 检查

Model/
└── TabIdentifier.swift          # 添加了 AI Chat 标签

Screens/
├── HomeScreen/
│   └── AppContentView.swift     # 添加了 AI Chat 标签页
└── Settings/
    ├── SettingsView.swift       # 集成了 AI 设置界面
    └── SettingsFeaturesView.swift  # 移除了 Auto-open links（基于老版本）
```

## 🚀 使用方法

### 方法 1：直接替换（推荐）

1. **下载 AirSync 源代码**
   ```bash
   git clone https://github.com/sameerasw/airsync-mac.git
   cd airsync-mac
   ```

2. **备份原始文件**
   ```bash
   # 创建备份
   cp -r airsync-mac airsync-mac.backup
   ```

3. **复制修改后的文件**
   ```bash
   # 从本仓库复制文件到 AirSync
   cp -r /path/to/airsync-autoglm-integration/modified-files/* airsync-mac/
   ```

4. **在 Xcode 中添加新文件**
   - 打开 `AirSync.xcodeproj`
   - 右键点击对应的文件夹
   - 选择 "Add Files to AirSync"
   - 添加新文件：
     - `Core/Util/AutoGLM/AutoGLMClient.swift`
     - `Screens/HomeScreen/AIChatView/AIChatView.swift`
     - `Screens/Settings/Components/AISettingsView.swift`

5. **添加编译标志**
   - 选择项目 → Build Settings
   - 搜索 "Swift Compiler - Custom Flags"
   - 在 "Other Swift Flags" 中添加：`-D SELF_COMPILED`

6. **编译运行**
   - 选择 "AirSync Self Compiled" scheme
   - Product → Build (Cmd+B)
   - Product → Run (Cmd+R)

### 方法 2：手动对比修改

如果你想了解具体修改了什么：

```bash
# 对比文件差异
diff -u airsync-mac/Model/TabIdentifier.swift \
        modified-files/Model/TabIdentifier.swift

# 查看所有差异
diff -ru airsync-mac/ modified-files/
```

## 📋 修改说明

### TabIdentifier.swift

**修改内容：**
- 添加了 `aiChat` 枚举值
- 添加了脑图标 `brain.head.profile`
- 添加了快捷键 `3`
- 在 ADB 连接时显示 AI Chat 标签

### AppState.swift

**修改内容：**
- 添加了 `aiEnabled` 属性（始终为 true）
- 添加了 `aiServerURL` 属性（默认 `http://127.0.0.1:8765`）
- 简化了 SELF_COMPILED 相关代码

### SettingsView.swift

**修改内容：**
- 在 `SettingsFeaturesView` 后添加了 `AISettingsView`

### 新文件说明

- **AutoGLMClient.swift**: 完整的 HTTP API 客户端实现
- **AIChatView.swift**: 类似 ChatGPT 的聊天界面，支持可展开的执行步骤
- **AISettingsView.swift**: AI 配置界面，包含服务器 URL 设置和帮助文档

## ⚠️ 重要提示

### 版本兼容性

这些文件基于 AirSync v2.1.6+ 版本。如果你使用的是其他版本，可能需要手动调整。

### 许可证说明

- 这些文件遵循 AirSync 的 MPL 2.0 许可证
- 修改后的文件仅供个人使用
- 不要分发修改后的构建版本

### SELF_COMPILED 标志

添加 `-D SELF_COMPILED` 编译标志后：
- 会启用自编译模式
- 跳过许可证验证
- 这是 AirSync 官方支持的功能

## 🔍 验证安装

编译成功后，检查：

1. ✅ Settings 中有 "AI Assistant" 部分
2. ✅ 连接 ADB 后出现 AI Chat 标签（脑图标）
3. ✅ 可以配置服务器 URL
4. ✅ 连接状态显示正常

## 📚 下一步

1. 启动 AutoGLM API 服务器（参考主 README）
2. 在 AirSync 中配置服务器 URL
3. 连接 Android 设备
4. 开始使用 AI 控制手机！

## 🆘 故障排查

### 编译错误

```bash
# 清理构建
Product → Clean Build Folder (Cmd+Shift+K)

# 重新构建
Product → Build (Cmd+B)
```

### 文件未找到

确保在 Xcode 中正确添加了新文件，并且 Target Membership 包含 "AirSync"。

### AI Chat 标签不显示

1. 确保 ADB 已连接
2. 检查 `TabIdentifier.swift` 是否正确修改
3. 重启 AirSync

---

**提示：** 完整的使用指南请参考主 [README](../README.md)
