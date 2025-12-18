# 贡献指南

感谢你对 AirSync-AutoGLM Integration 项目的关注！

## 🤝 如何贡献

### 报告问题

如果你发现了 bug 或有功能建议：

1. 检查 [Issues](https://github.com/YOUR_USERNAME/airsync-autoglm-integration/issues) 是否已有相关讨论
2. 如果没有，创建新 Issue
3. 提供详细信息：
   - 问题描述
   - 复现步骤
   - 预期行为
   - 实际行为
   - 环境信息（macOS 版本、Python 版本等）
   - 截图或日志（如果适用）

### 提交代码

1. **Fork 仓库**
   ```bash
   # 在 GitHub 上点击 Fork 按钮
   ```

2. **克隆你的 Fork**
   ```bash
   git clone https://github.com/YOUR_USERNAME/airsync-autoglm-integration.git
   cd airsync-autoglm-integration
   ```

3. **创建分支**
   ```bash
   git checkout -b feature/your-feature-name
   # 或
   git checkout -b fix/your-bug-fix
   ```

4. **进行修改**
   - 遵循现有代码风格
   - 添加必要的注释
   - 更新相关文档

5. **测试你的修改**
   ```bash
   # 测试 API 服务器
   python api_server.py --help
   
   # 测试 ModelScope 连接
   python test_modelscope.py YOUR_TOKEN
   ```

6. **提交更改**
   ```bash
   git add .
   git commit -m "feat: add amazing feature"
   # 或
   git commit -m "fix: resolve issue #123"
   ```

7. **推送到你的 Fork**
   ```bash
   git push origin feature/your-feature-name
   ```

8. **创建 Pull Request**
   - 在 GitHub 上打开你的 Fork
   - 点击 "New Pull Request"
   - 填写 PR 描述
   - 等待审核

## 📝 代码规范

### Python 代码

- 遵循 PEP 8 风格指南
- 使用有意义的变量名
- 添加类型提示
- 编写文档字符串

```python
def execute_task(task: str, device_id: str | None = None) -> dict:
    """
    Execute a task on the device.
    
    Args:
        task: Natural language task description
        device_id: Optional device ID
        
    Returns:
        dict: Execution result
    """
    pass
```

### 文档

- 使用清晰的标题和结构
- 提供代码示例
- 包含截图（如果适用）
- 保持简洁明了

### Commit 消息

使用语义化提交消息：

- `feat:` 新功能
- `fix:` Bug 修复
- `docs:` 文档更新
- `style:` 代码格式（不影响功能）
- `refactor:` 重构
- `test:` 测试相关
- `chore:` 构建/工具相关

示例：
```
feat: add support for custom API endpoints
fix: resolve connection timeout issue
docs: update installation guide
```

## 🎯 贡献方向

### 优先级高

- [ ] 改进错误处理和提示
- [ ] 添加更多使用示例
- [ ] 优化性能
- [ ] 完善文档

### 欢迎贡献

- [ ] 支持更多模型服务
- [ ] 添加单元测试
- [ ] 国际化（i18n）
- [ ] 性能监控和日志
- [ ] Docker 支持

### 实验性功能

- [ ] WebSocket 实时通信
- [ ] 语音输入支持
- [ ] 任务队列管理
- [ ] 多设备并发控制

## ⚠️ 重要提醒

### 不要提交

- ❌ AirSync 的完整源代码
- ❌ 修改后的 AirSync 构建版本
- ❌ API 密钥或敏感信息
- ❌ 大型二进制文件

### 可以提交

- ✅ API 服务器改进
- ✅ 文档和教程
- ✅ 补丁文件（diff 格式）
- ✅ 测试脚本
- ✅ 配置示例

## 📄 许可证

提交代码即表示你同意将你的贡献以 Apache 2.0 许可证发布。

## 🙏 致谢

所有贡献者都会在 README 中列出。感谢你的贡献！

## 💬 交流

- GitHub Issues: 技术问题和 bug 报告
- GitHub Discussions: 功能讨论和想法交流
- Email: 私密问题或合作

---

**再次感谢你的贡献！** 🎉
