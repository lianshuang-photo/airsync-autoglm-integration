# 新文件创建指南

以下文件需要在 AirSync 项目中创建。完整的代码实现请参考 [集成指南](../../docs/INTEGRATION_GUIDE.md)。

## 1. AutoGLMClient.swift

**位置：** `airsync-mac/Core/Util/AutoGLM/AutoGLMClient.swift`

**说明：** AutoGLM API 客户端，负责与 API 服务器通信

**创建步骤：**

1. 在 Xcode 中右键点击 `Core/Util/`
2. 选择 New Group，命名为 `AutoGLM`
3. 右键点击 `AutoGLM` 文件夹
4. 选择 New File → Swift File
5. 命名为 `AutoGLMClient.swift`

**主要功能：**
- HTTP API 请求封装
- 健康检查
- 任务执行
- 状态轮询
- 错误处理

**关键类型：**
```swift
@MainActor
class AutoGLMClient: ObservableObject {
    @Published var isConnected: Bool = false
    @Published var isExecuting: Bool = false
    @Published var currentTask: String?
    @Published var lastError: String?
    
    func checkHealth()
    func executeTask(_ task: String, deviceId: String?, completion: ...)
    func checkStatus()
    func stopTask(completion: ...)
}
```

## 2. AIChatView.swift

**位置：** `airsync-mac/Screens/HomeScreen/AIChatView/AIChatView.swift`

**说明：** AI 聊天界面，类似 ChatGPT 的对话界面

**创建步骤：**

1. 在 Xcode 中右键点击 `Screens/HomeScreen/`
2. 选择 New Group，命名为 `AIChatView`
3. 右键点击 `AIChatView` 文件夹
4. 选择 New File → Swift File
5. 命名为 `AIChatView.swift`

**主要功能：**
- 消息列表显示
- 可展开的执行步骤
- 实时进度更新（0.3秒轮询）
- 输入框和发送按钮
- 示例提示

**关键类型：**
```swift
struct AIChatView: View {
    @State private var messageText: String = ""
    @State private var messages: [ChatMessage] = []
    @State private var lastProgressStepCount = 0
    
    var body: some View { ... }
}

struct ChatMessage: Identifiable {
    let role: MessageRole
    let content: String
    var steps: [ExecutionStep]?
}

struct ProgressMessageView: View { ... }
struct StepView: View { ... }
```

## 3. AISettingsView.swift

**位置：** `airsync-mac/Screens/Settings/Components/AISettingsView.swift`

**说明：** AI 设置界面，配置服务器 URL 和查看连接状态

**创建步骤：**

1. 在 Xcode 中右键点击 `Screens/Settings/Components/`
2. 选择 New File → Swift File
3. 命名为 `AISettingsView.swift`

**主要功能：**
- 服务器 URL 配置
- 连接状态显示
- 测试连接按钮
- 帮助文档

**关键类型：**
```swift
struct AISettingsView: View {
    @ObservedObject var appState = AppState.shared
    @ObservedObject var aiClient = AutoGLMClient.shared
    
    var body: some View { ... }
}

struct ServerInfoSheet: View { ... }
```

## 4. AppContentView.swift 修改

**位置：** `airsync-mac/Screens/HomeScreen/AppContentView.swift`

**说明：** 添加 AI Chat 标签页的视图

在 TabView 中添加 AI Chat 的 case：

```swift
TabView(selection: $appState.selectedTab) {
    // ... 现有标签 ...
    
    if appState.selectedTab == .aiChat {
        AIChatView()
            .tabItem {
                Label("AI Chat", systemImage: "brain.head.profile")
            }
            .tag(TabIdentifier.aiChat)
            .keyboardShortcut("3", modifiers: .command)
    }
    
    // ... 其他标签 ...
}
```

## 📚 详细实现

完整的代码实现和详细说明请参考：

- [集成指南](../../docs/INTEGRATION_GUIDE.md) - 完整的集成步骤
- [快速开始](../../docs/QUICKSTART.md) - 5分钟快速启动

## 💡 提示

1. 确保所有新文件都添加到 Xcode 项目中
2. 检查 Target Membership 包含 "AirSync"
3. 编译前先 Clean Build Folder (Cmd+Shift+K)
4. 如果遇到编译错误，参考 [故障排查](../../docs/INTEGRATION_GUIDE.md#故障排查)

## ⚠️ 注意

由于许可证限制，我们不能提供完整的源代码文件。请：

1. 参考集成指南中的代码片段
2. 根据你的 AirSync 版本进行适配
3. 仅供个人学习和使用
