//
//  AISettingsView.swift
//  AirSync
//
//  AI Assistant configuration settings
//

import SwiftUI

struct AISettingsView: View {
    @ObservedObject var appState = AppState.shared
    @ObservedObject var aiClient = AutoGLMClient.shared
    
    @State private var showingServerInfo = false
    
    var body: some View {
        Form {
            Section {
                // Server URL
                HStack {
                    Label("Server URL", systemImage: "server.rack")
                        .frame(width: 120, alignment: .leading)
                    
                    TextField("http://127.0.0.1:8765", text: $appState.aiServerURL)
                        .textFieldStyle(.roundedBorder)
                        .disabled(aiClient.isExecuting)
                        .onChange(of: appState.aiServerURL) {
                            aiClient.updateBaseURL(appState.aiServerURL)
                        }
                    
                    Button(action: {
                        aiClient.checkHealth()
                    }) {
                        Image(systemName: "arrow.clockwise")
                    }
                    .help("Test connection")
                }
                
                // Connection Status
                HStack {
                    Label("Status", systemImage: "circle.fill")
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(
                            aiClient.isConnected ? .green : .red,
                            .secondary
                        )
                        .frame(width: 120, alignment: .leading)
                    
                    Text(aiClient.isConnected ? "Connected" : "Disconnected")
                        .foregroundColor(aiClient.isConnected ? .green : .red)
                    
                    if let error = aiClient.lastError {
                        Text("• \(error)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        showingServerInfo = true
                    }) {
                        Image(systemName: "info.circle")
                    }
                    .help("How to start the AI server")
                }
                
                if aiClient.isExecuting {
                    Divider()
                    
                    HStack {
                        ProgressView()
                            .scaleEffect(0.7)
                        
                        if let task = aiClient.currentTask {
                            Text("Executing: \(task)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                        }
                        
                        Spacer()
                        
                        Button("Stop") {
                            aiClient.stopTask { _ in }
                        }
                        .buttonStyle(.bordered)
                    }
                }
            } header: {
                Text("AI Assistant")
            } footer: {
                Text("The AI Assistant requires a running AutoGLM API server. Make sure ADB is connected before using AI features.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .formStyle(.grouped)
        .onAppear {
            aiClient.updateBaseURL(appState.aiServerURL)
            aiClient.checkHealth()
        }
        .sheet(isPresented: $showingServerInfo) {
            ServerInfoSheet(isPresented: $showingServerInfo)
        }
    }
}

// MARK: - Server Info Sheet

struct ServerInfoSheet: View {
    @Binding var isPresented: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            HStack {
                Image(systemName: "server.rack")
                    .font(.largeTitle)
                    .foregroundColor(.accentColor)
                
                VStack(alignment: .leading) {
                    Text("AutoGLM API Server")
                        .font(.title2)
                        .fontWeight(.bold)
                    Text("Setup Instructions")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button(action: { isPresented = false }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()
            
            Divider()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Step 1
                    InstructionStep(
                        number: 1,
                        title: "Install Dependencies",
                        description: "Open Terminal and run:",
                        code: "cd /path/to/Open-AutoGLM\npip install -r requirements.txt"
                    )
                    
                    // Step 2
                    InstructionStep(
                        number: 2,
                        title: "Start the API Server",
                        description: "Run the following command:",
                        code: "python3 api_server.py --base-url http://localhost:8000/v1 --model autoglm-phone-9b"
                    )
                    
                    // Step 3
                    InstructionStep(
                        number: 3,
                        title: "Configure Model Service",
                        description: "You need a running model service. Choose one option:",
                        bullets: [
                            "BigModel API: --base-url https://open.bigmodel.cn/api/paas/v4 --model autoglm-phone --apikey YOUR_KEY",
                            "ModelScope API: --base-url https://api-inference.modelscope.cn/v1 --model ZhipuAI/AutoGLM-Phone-9B --apikey YOUR_MODELSCOPE_TOKEN",
                            "Local deployment with vLLM or SGLang (requires GPU with 24GB+ VRAM)"
                        ]
                    )
                    
                    // Step 4
                    InstructionStep(
                        number: 4,
                        title: "Verify Connection",
                        description: "The server should start on http://127.0.0.1:8765. Click the refresh button in AirSync to test the connection."
                    )
                    
                    Divider()
                    
                    // Quick Start Script
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Quick Start Script")
                            .font(.headline)
                        
                        Text("Use the provided startup script:")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        CodeBlock(code: "cd /path/to/Open-AutoGLM\nchmod +x start_api_server.sh\n./start_api_server.sh")
                    }
                    .padding()
                    .background(Color.secondary.opacity(0.1))
                    .cornerRadius(8)
                }
                .padding()
            }
            
            Divider()
            
            // Footer
            HStack {
                Link(destination: URL(string: "https://github.com/zai-org/Open-AutoGLM")!) {
                    Label("View Documentation", systemImage: "book")
                }
                
                Spacer()
                
                Button("Close") {
                    isPresented = false
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
        }
        .frame(width: 600, height: 700)
    }
}

// MARK: - Instruction Step

struct InstructionStep: View {
    let number: Int
    let title: String
    let description: String
    var code: String? = nil
    var bullets: [String]? = nil
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Number badge
            Text("\(number)")
                .font(.headline)
                .foregroundColor(.white)
                .frame(width: 32, height: 32)
                .background(Color.accentColor)
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.headline)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                if let code = code {
                    CodeBlock(code: code)
                }
                
                if let bullets = bullets {
                    VStack(alignment: .leading, spacing: 4) {
                        ForEach(bullets, id: \.self) { bullet in
                            HStack(alignment: .top, spacing: 8) {
                                Text("•")
                                    .foregroundColor(.accentColor)
                                Text(bullet)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding(.leading, 8)
                }
            }
        }
    }
}

// MARK: - Code Block

struct CodeBlock: View {
    let code: String
    @State private var copied = false
    
    var body: some View {
        HStack {
            Text(code)
                .font(.system(.caption, design: .monospaced))
                .padding(8)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Button(action: {
                NSPasteboard.general.clearContents()
                NSPasteboard.general.setString(code, forType: .string)
                copied = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    copied = false
                }
            }) {
                Image(systemName: copied ? "checkmark" : "doc.on.doc")
                    .foregroundColor(copied ? .green : .secondary)
            }
            .buttonStyle(.plain)
            .help("Copy to clipboard")
        }
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(6)
    }
}

#Preview {
    AISettingsView()
        .frame(width: 500)
}
