//
//  AIChatView.swift
//  AirSync
//
//  AI Chat interface for controlling Android device
//

import SwiftUI

struct AIChatView: View {
    @ObservedObject var appState = AppState.shared
    @ObservedObject var aiClient = AutoGLMClient.shared
    
    @State private var messageText: String = ""
    @State private var messages: [ChatMessage] = []
    @State private var isScrolledToBottom = true
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            headerView
            
            Divider()
            
            // Messages
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 12) {
                        if messages.isEmpty {
                            emptyStateView
                        } else {
                            ForEach(messages) { message in
                                ChatMessageView(message: message)
                                    .id(message.id)
                            }
                        }
                    }
                    .padding()
                }
                .onChange(of: messages.count) {
                    if isScrolledToBottom, let lastMessage = messages.last {
                        withAnimation {
                            proxy.scrollTo(lastMessage.id, anchor: .bottom)
                        }
                    }
                }
            }
            
            Divider()
            
            // Input area
            inputView
        }
        .onAppear {
            aiClient.checkHealth()
            loadSampleMessages()
        }
    }
    
    // MARK: - Header
    
    private var headerView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    Image(systemName: "brain.head.profile")
                        .font(.title2)
                        .foregroundColor(.accentColor)
                    
                    Text("AI Assistant")
                        .font(.headline)
                }
                
                HStack(spacing: 4) {
                    Circle()
                        .fill(aiClient.isConnected ? Color.green : Color.red)
                        .frame(width: 8, height: 8)
                    
                    Text(aiClient.isConnected ? "Connected" : "Disconnected")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    if aiClient.isExecuting {
                        Text("• Executing...")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                }
            }
            
            Spacer()
            
            // Settings button
            Button(action: {
                // Open AI settings
            }) {
                Image(systemName: "gearshape")
                    .font(.title3)
            }
            .buttonStyle(.plain)
        }
        .padding()
    }
    
    // MARK: - Empty State
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "sparkles")
                .font(.system(size: 60))
                .foregroundColor(.accentColor.opacity(0.5))
            
            Text("AI Assistant Ready")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Tell me what you'd like to do with your phone")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            VStack(alignment: .leading, spacing: 12) {
                Text("Try asking:")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                SamplePromptButton(text: "打开微信给张三发消息") {
                    messageText = "打开微信给张三发消息"
                }
                
                SamplePromptButton(text: "在淘宝搜索无线耳机") {
                    messageText = "在淘宝搜索无线耳机"
                }
                
                SamplePromptButton(text: "打开抖音刷视频") {
                    messageText = "打开抖音刷视频"
                }
            }
            .padding()
            .background(Color.secondary.opacity(0.1))
            .cornerRadius(12)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
    
    // MARK: - Input
    
    private var inputView: some View {
        HStack(spacing: 12) {
            TextField("Type your message...", text: $messageText)
                .textFieldStyle(.plain)
                .padding(10)
                .background(Color.secondary.opacity(0.1))
                .cornerRadius(8)
                .disabled(aiClient.isExecuting)
                .onSubmit {
                    sendMessage()
                }
            
            if aiClient.isExecuting {
                Button(action: {
                    aiClient.stopTask { success in
                        if success {
                            addSystemMessage("Task stopped by user")
                        }
                    }
                }) {
                    Image(systemName: "stop.circle.fill")
                        .font(.title2)
                        .foregroundColor(.red)
                }
                .buttonStyle(.plain)
            } else {
                Button(action: sendMessage) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.title2)
                        .foregroundColor(messageText.isEmpty ? .gray : .accentColor)
                }
                .buttonStyle(.plain)
                .disabled(messageText.isEmpty || !aiClient.isConnected)
            }
        }
        .padding()
    }
    
    // MARK: - Actions
    
    private func sendMessage() {
        guard !messageText.isEmpty, !aiClient.isExecuting else { return }
        
        // Reset progress tracking for new task
        lastProgressStepCount = 0
        
        let userMessage = ChatMessage(
            role: .user,
            content: messageText,
            timestamp: Date()
        )
        
        messages.append(userMessage)
        let taskText = messageText
        messageText = ""
        
        // Get device ID
        let deviceId: String? = {
            if let device = appState.device, appState.adbConnected {
                return "\(device.ipAddress):\(appState.adbPort)"
            }
            return nil
        }()
        
        // Execute task
        aiClient.executeTask(taskText, deviceId: deviceId) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let message):
                    addSystemMessage(message)
                    
                    // Poll for completion
                    pollForCompletion()
                    
                case .failure(let error):
                    addErrorMessage(error.localizedDescription)
                }
            }
        }
    }
    
    private func pollForCompletion() {
        // Update progress immediately
        self.updateProgressMessage()
        
        // Check if still executing
        if !aiClient.isExecuting {
            // Task completed
            if let error = aiClient.lastError {
                addErrorMessage(error)
            } else {
                addAssistantMessage("✅ Task completed successfully!")
            }
            return
        }
        
        // Continue polling with shorter interval (0.3s for real-time feel)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.pollForCompletion()
        }
    }
    
    @State private var lastProgressStepCount = 0  // Track last step count to avoid duplicates
    
    private func updateProgressMessage() {
        // Get current status from API
        guard let url = URL(string: "\(appState.aiServerURL)/status") else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else { return }
            
            do {
                let decoder = JSONDecoder()
                let status = try decoder.decode(AutoGLMStatusResponse.self, from: data)
                
                DispatchQueue.main.async {
                    // Convert progress to ExecutionStep
                    if let progressArray = status.progress, !progressArray.isEmpty {
                        // Only update if there are new steps
                        if progressArray.count != self.lastProgressStepCount {
                            self.lastProgressStepCount = progressArray.count
                            
                            let steps = progressArray.map { p in
                                ExecutionStep(
                                    stepNumber: p.step,
                                    thinking: p.thinking ?? "Processing...",
                                    action: p.action
                                )
                            }
                            
                            // Update or add progress message
                            if let lastIndex = self.messages.lastIndex(where: { $0.role == .progress }) {
                                // Update existing progress message
                                self.messages[lastIndex] = ChatMessage(
                                    role: .progress,
                                    content: "🤖 Executing: \(status.task ?? "Task")",
                                    timestamp: self.messages[lastIndex].timestamp,
                                    steps: steps
                                )
                            } else {
                                // Add new progress message
                                let progressMessage = ChatMessage(
                                    role: .progress,
                                    content: "🤖 Executing: \(status.task ?? "Task")",
                                    timestamp: Date(),
                                    steps: steps
                                )
                                self.messages.append(progressMessage)
                            }
                        }
                    }
                }
            } catch {
                print("Failed to decode status: \(error)")
            }
        }.resume()
    }
    
    private func addAssistantMessage(_ content: String) {
        let message = ChatMessage(
            role: .assistant,
            content: content,
            timestamp: Date()
        )
        messages.append(message)
    }
    
    private func addSystemMessage(_ content: String) {
        let message = ChatMessage(
            role: .system,
            content: content,
            timestamp: Date()
        )
        messages.append(message)
    }
    
    private func addErrorMessage(_ content: String) {
        let message = ChatMessage(
            role: .error,
            content: content,
            timestamp: Date()
        )
        messages.append(message)
    }
    
    private func loadSampleMessages() {
        // Add welcome message
        if messages.isEmpty {
            addSystemMessage("Welcome! I can help you control your Android device using natural language.")
        }
    }
}

// MARK: - Chat Message Model

struct ChatMessage: Identifiable {
    let id = UUID()
    let role: MessageRole
    let content: String
    let timestamp: Date
    var steps: [ExecutionStep]? = nil  // For progress messages
    
    enum MessageRole {
        case user
        case assistant
        case system
        case error
        case progress  // New: for showing execution steps
    }
}

struct ExecutionStep: Identifiable {
    let id = UUID()
    let stepNumber: Int
    let thinking: String
    let action: String?
}

// MARK: - Chat Message View

struct ChatMessageView: View {
    let message: ChatMessage
    @State private var isExpanded = true  // Default expanded for progress messages
    
    var body: some View {
        HStack {
            if message.role == .user {
                Spacer()
            }
            
            VStack(alignment: message.role == .user ? .trailing : .leading, spacing: 4) {
                if message.role == .progress, let steps = message.steps {
                    // Progress message with expandable steps
                    ProgressMessageView(
                        title: message.content,
                        steps: steps,
                        isExpanded: $isExpanded
                    )
                } else {
                    // Regular message
                    Text(message.content)
                        .padding(12)
                        .background(backgroundColor)
                        .foregroundColor(foregroundColor)
                        .cornerRadius(12)
                        .frame(maxWidth: 400, alignment: message.role == .user ? .trailing : .leading)
                }
                
                Text(timeString)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            if message.role != .user {
                Spacer()
            }
        }
    }
    
    private var backgroundColor: Color {
        switch message.role {
        case .user:
            return .accentColor
        case .assistant:
            return Color.secondary.opacity(0.2)
        case .system:
            return Color.blue.opacity(0.1)
        case .error:
            return Color.red.opacity(0.1)
        case .progress:
            return Color.purple.opacity(0.1)
        }
    }
    
    private var foregroundColor: Color {
        switch message.role {
        case .user:
            return .white
        case .assistant, .system:
            return .primary
        case .error:
            return .red
        case .progress:
            return .primary
        }
    }
    
    private var timeString: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: message.timestamp)
    }
}

// MARK: - Progress Message View

struct ProgressMessageView: View {
    let title: String
    let steps: [ExecutionStep]
    @Binding var isExpanded: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header with expand/collapse button
            Button(action: {
                withAnimation {
                    isExpanded.toggle()
                }
            }) {
                HStack {
                    Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Text("\(steps.count) steps")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(12)
                .background(Color.purple.opacity(0.1))
                .cornerRadius(12)
            }
            .buttonStyle(.plain)
            
            // Expandable steps
            if isExpanded {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(steps) { step in
                        StepView(step: step)
                    }
                }
                .padding(.leading, 8)
            }
        }
        .frame(maxWidth: 500, alignment: .leading)
    }
}

// MARK: - Step View

struct StepView: View {
    let step: ExecutionStep
    @State private var isThinkingExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            // Step header
            HStack {
                Text("Step \(step.stepNumber)")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.purple)
                
                if let action = step.action {
                    Text("•")
                        .foregroundColor(.secondary)
                    Text(action)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button(action: {
                    withAnimation {
                        isThinkingExpanded.toggle()
                    }
                }) {
                    Image(systemName: isThinkingExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
            }
            
            // Thinking content (expandable)
            if isThinkingExpanded {
                Text(step.thinking)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(8)
                    .background(Color.secondary.opacity(0.05))
                    .cornerRadius(6)
            } else {
                // Show preview (first 100 chars)
                Text(step.thinking.prefix(100) + (step.thinking.count > 100 ? "..." : ""))
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
        }
        .padding(8)
        .background(Color.secondary.opacity(0.05))
        .cornerRadius(8)
    }
}

// MARK: - Sample Prompt Button

struct SamplePromptButton: View {
    let text: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: "lightbulb")
                    .font(.caption)
                Text(text)
                    .font(.caption)
                Spacer()
                Image(systemName: "arrow.right")
                    .font(.caption)
            }
            .padding(8)
            .background(Color.secondary.opacity(0.1))
            .cornerRadius(8)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    AIChatView()
        .frame(width: 600, height: 800)
}
