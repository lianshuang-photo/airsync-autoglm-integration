# SettingsView.swift 修改说明

**文件位置：** `airsync-mac/Screens/Settings/SettingsView.swift`

## 修改内容

### 添加 AI 设置部分

在 `SettingsFeaturesView()` 之后添加 AI 设置：

找到这段代码：

```swift
SettingsFeaturesView()
    .background(.background.opacity(0.3))
    .cornerRadius(12.0)

Spacer(minLength: 32)
```

在它们之间添加：

```swift
SettingsFeaturesView()
    .background(.background.opacity(0.3))
    .cornerRadius(12.0)

Spacer(minLength: 32)

// AI Assistant Section
AISettingsView()
    .background(.background.opacity(0.3))
    .cornerRadius(12.0)

Spacer(minLength: 32)
```

## 完整示例

修改后的代码应该类似：

```swift
VStack {
    // ... 其他设置 ...
    
    SettingsFeaturesView()
        .background(.background.opacity(0.3))
        .cornerRadius(12.0)

    Spacer(minLength: 32)

    // AI Assistant Section
    AISettingsView()
        .background(.background.opacity(0.3))
        .cornerRadius(12.0)

    Spacer(minLength: 32)

    // App icons
    AppIconView()
    
    // ... 其他设置 ...
}
```

## 完成

保存文件后，AI 设置将出现在 Settings 界面中。
