# AppState.swift 修改说明

**文件位置：** `airsync-mac/Core/AppState.swift`

## 修改内容

### 1. 添加 AI 相关的 Published 属性

在 `AppState` 类中添加以下属性（建议放在其他 `@Published` 属性附近）：

```swift
// AI Assistant 始终启用
@Published var aiEnabled: Bool = true

@Published var aiServerURL: String = "http://127.0.0.1:8765" {
    didSet {
        UserDefaults.standard.set(aiServerURL, forKey: "aiServerURL")
        AutoGLMClient.shared.updateBaseURL(aiServerURL)
    }
}
```

### 2. 在 init() 方法中初始化 AI 配置

在 `init()` 方法中添加（建议放在其他配置初始化附近）：

```swift
init() {
    // ... 现有代码 ...
    
    // AI 配置初始化
    self.aiEnabled = true
    self.aiServerURL = UserDefaults.standard.string(forKey: "aiServerURL") ?? "http://127.0.0.1:8765"
    
    // ... 其他初始化代码 ...
}
```

## 说明

- `aiEnabled` 始终为 `true`，表示 AI 功能默认启用
- `aiServerURL` 从 UserDefaults 读取，默认为 `http://127.0.0.1:8765`
- 当 URL 改变时，自动更新 AutoGLMClient 的配置

## 完成

保存文件后，应用将能够管理 AI 相关的状态。
