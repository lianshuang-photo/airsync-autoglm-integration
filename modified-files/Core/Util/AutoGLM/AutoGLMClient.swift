//
//  AutoGLMClient.swift
//  AirSync
//
//  AutoGLM API Client for AI-powered phone control
//

import Foundation
internal import Combine

// MARK: - Models

struct AutoGLMDevice: Codable, Sendable {
    let id: String
    let status: String
    let connectionType: String
    let model: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case status
        case connectionType = "connection_type"
        case model
    }
}

struct AutoGLMHealthResponse: Codable, Sendable {
    let status: String
    let agentInitialized: Bool
    let devices: [AutoGLMDevice]
    
    enum CodingKeys: String, CodingKey {
        case status
        case agentInitialized = "agent_initialized"
        case devices
    }
}

struct AutoGLMExecuteRequest: Codable, Sendable {
    let task: String
    let deviceId: String?
    let stream: Bool?
    
    enum CodingKeys: String, CodingKey {
        case task
        case deviceId = "device_id"
        case stream
    }
}

struct AutoGLMExecuteResponse: Codable, Sendable {
    let status: String
    let task: String
    let message: String
    let error: String?
}

struct AutoGLMStatusResponse: Codable, Sendable {
    let running: Bool
    let task: String?
    let step: Int
    let message: String?
    let error: String?
    let thinking: String?
    let progress: [ProgressStep]?
    
    // Ignore action field for now (complex nested structure)
    enum CodingKeys: String, CodingKey {
        case running, task, step, message, error, thinking, progress
    }
}

struct ProgressStep: Codable, Sendable {
    let step: Int
    let thinking: String?
    let action: String?
}

// MARK: - Client

@MainActor
class AutoGLMClient: ObservableObject {
    static let shared = AutoGLMClient()
    
    @Published var isConnected: Bool = false
    @Published var isExecuting: Bool = false
    @Published var currentTask: String?
    @Published var lastError: String?
    
    private var baseURL: String
    private var statusCheckTimer: Timer?
    
    init(baseURL: String = "http://127.0.0.1:8765") {
        self.baseURL = baseURL
    }
    
    // MARK: - Configuration
    
    func updateBaseURL(_ url: String) {
        self.baseURL = url
        checkHealth()
    }
    
    // MARK: - Health Check
    
    func checkHealth(completion: ((Bool) -> Void)? = nil) {
        guard let url = URL(string: "\(baseURL)/health") else {
            DispatchQueue.main.async {
                self.isConnected = false
                self.lastError = "Invalid URL"
            }
            completion?(false)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 5
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.isConnected = false
                    self.lastError = error.localizedDescription
                    completion?(false)
                    return
                }
                
                guard let data = data else {
                    self.isConnected = false
                    self.lastError = "No data received"
                    completion?(false)
                    return
                }
                
                do {
                    let healthResponse = try JSONDecoder().decode(AutoGLMHealthResponse.self, from: data)
                    self.isConnected = healthResponse.status == "ok"
                    self.lastError = nil
                    completion?(true)
                } catch {
                    self.isConnected = false
                    self.lastError = "Failed to decode response: \(error.localizedDescription)"
                    completion?(false)
                }
            }
        }.resume()
    }
    
    // MARK: - Execute Task
    
    func executeTask(
        _ task: String,
        deviceId: String? = nil,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        guard let url = URL(string: "\(baseURL)/execute") else {
            completion(.failure(NSError(domain: "AutoGLM", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody = AutoGLMExecuteRequest(task: task, deviceId: deviceId, stream: false)
        
        do {
            request.httpBody = try JSONEncoder().encode(requestBody)
        } catch {
            completion(.failure(error))
            return
        }
        
        DispatchQueue.main.async {
            self.isExecuting = true
            self.currentTask = task
            self.lastError = nil
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.isExecuting = false
                    self.lastError = error.localizedDescription
                }
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                let error = NSError(domain: "AutoGLM", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"])
                DispatchQueue.main.async {
                    self.isExecuting = false
                    self.lastError = "No data received"
                }
                completion(.failure(error))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let executeResponse = try decoder.decode(AutoGLMExecuteResponse.self, from: data)
                
                if let error = executeResponse.error {
                    DispatchQueue.main.async {
                        self.isExecuting = false
                        self.lastError = error
                    }
                    completion(.failure(NSError(domain: "AutoGLM", code: -1, userInfo: [NSLocalizedDescriptionKey: error])))
                } else {
                    // Start polling for status
                    DispatchQueue.main.async {
                        self.startStatusPolling()
                    }
                    completion(.success(executeResponse.message))
                }
            } catch {
                DispatchQueue.main.async {
                    self.isExecuting = false
                    self.lastError = error.localizedDescription
                }
                completion(.failure(error))
            }
        }.resume()
    }
    
    // MARK: - Status Polling
    
    private func startStatusPolling() {
        stopStatusPolling()
        
        statusCheckTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.checkStatus()
            }
        }
    }
    
    private func stopStatusPolling() {
        statusCheckTimer?.invalidate()
        statusCheckTimer = nil
    }
    
    func checkStatus() {
        guard let url = URL(string: "\(baseURL)/status") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 5
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else { return }
            
            do {
                let decoder = JSONDecoder()
                let statusResponse = try decoder.decode(AutoGLMStatusResponse.self, from: data)
                
                DispatchQueue.main.async {
                    self.isExecuting = statusResponse.running
                    
                    if !statusResponse.running {
                        self.stopStatusPolling()
                        
                        if let error = statusResponse.error {
                            self.lastError = error
                        } else if let message = statusResponse.message {
                            // Task completed successfully
                            print("[AutoGLM] Task completed: \(message)")
                        }
                    }
                }
            } catch {
                print("[AutoGLM] Failed to decode status: \(error)")
            }
        }.resume()
    }
    
    // MARK: - Stop Task
    
    func stopTask(completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "\(baseURL)/stop") else {
            completion(false)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if error == nil {
                    self.isExecuting = false
                    self.stopStatusPolling()
                    completion(true)
                } else {
                    completion(false)
                }
            }
        }.resume()
    }
}
