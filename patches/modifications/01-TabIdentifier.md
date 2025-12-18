# TabIdentifier.swift 修改说明

**文件位置：** `airsync-mac/Model/TabIdentifier.swift`

## 修改内容

### 1. 添加 AI Chat 枚举值

在 `TabIdentifier` 枚举中添加新的 case：

```swift
enum TabIdentifier: String, CaseIterable, Identifiable {
    case notifications = "notifications.tab"
    case apps = "apps.tab"
    case aiChat = "aichat.tab"  // ← 添加这一行
    case transfers = "transfers.tab"
    case settings = "settings.tab"
    case qr = "qr.tab"
    
    var id: String { rawValue }
```

### 2. 添加图标

在 `icon` 计算属性的 switch 语句中添加：

```swift
var icon: String {
    switch self {
    case .notifications: return "bell.badge"
    case .apps: return "app"
    case .aiChat: return "brain.head.profile"  // ← 添加这一行
    case .transfers: return "tray.and.arrow.up"
    case .settings: return "gear"
    case .qr: return "qrcode"
    }
}
```

### 3. 添加快捷键

在 `shortcut` 计算属性的 switch 语句中添加：

```swift
var shortcut: KeyEquivalent {
    switch self {
    case .notifications: return "1"
    case .apps: return "2"
    case .aiChat: return "3"  // ← 添加这一行
    case .transfers: return "4"
    case .settings: return ","
    case .qr: return "."
    }
}
```

### 4. 更新 availableTabs

修改 `availableTabs` 静态变量，在有 ADB 连接时显示 AI Chat 标签：

```swift
static var availableTabs: [TabIdentifier] {
    var tabs: [TabIdentifier] = [.qr, .settings]
    if AppState.shared.device != nil {
        tabs.remove(at: 0)
        tabs.insert(.notifications, at: 0)
        tabs.insert(.apps, at: 1)
        
        // 显示 AI Chat（如果 ADB 已连接）
        if AppState.shared.adbConnected {
            tabs.insert(.aiChat, at: 2)
            tabs.insert(.transfers, at: 3)
        } else {
            tabs.insert(.transfers, at: 2)
        }
    }
    return tabs
}
```

## 完成

保存文件后，AI Chat 标签将在 ADB 连接时自动显示。
