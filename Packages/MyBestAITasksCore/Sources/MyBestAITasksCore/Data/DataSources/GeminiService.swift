import Foundation
import Dependencies
import DependenciesMacros

/// Gemini APIとの通信を担当するクライアント
@DependencyClient
public struct GeminiClient {
    /// ゴールからタスクリストを生成
    public var generateTasks: (_ goal: String, _ deadline: Date) async throws -> [GoalTask]
    
    /// チャット指示に基づいてゴールを更新（タスクとマイルストーンの生成）
    public var updateGoal: (_ currentGoal: Goal, _ instruction: String) async throws -> (tasks: [GoalTask], milestones: [Milestone])
}

extension GeminiClient: DependencyKey {
    public static let liveValue: GeminiClient = {
        let apiKey = UserDefaults.standard.string(forKey: "geminiApiKey") ?? ""
        
        // 共通のAPIリクエストロジック
        @Sendable func generateContent(prompt: String) async throws -> String {
            let url = URL(string: "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=\(apiKey)")!
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let body: [String: Any] = [
                "contents": [
                    [
                        "parts": [
                            ["text": prompt]
                        ]
                    ]
                ]
            ]
            
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
            
            let (data, _) = try await URLSession.shared.data(for: request)
            
            guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let candidates = json["candidates"] as? [[String: Any]],
                  let content = candidates.first?["content"] as? [String: Any],
                  let parts = content["parts"] as? [[String: Any]],
                  let text = parts.first?["text"] as? String else {
                throw NSError(domain: "GeminiClient", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to parse Gemini response"])
            }
            
            return text.replacingOccurrences(of: "```json", with: "").replacingOccurrences(of: "```", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
        }
        
        return GeminiClient(
            generateTasks: { goal, deadline in
                let prompt = """
                You are an expert project manager.
                The user has a goal: "\(goal)".
                The deadline is: \(deadline.formatted()).
                
                Break this goal down into a list of concrete, actionable tasks.
                For each task, provide:
                1. A concise title.
                2. Estimated time in minutes (integer).
                
                Return ONLY a JSON array of objects with keys "title" and "minutes".
                Example: [{"title": "Research topic", "minutes": 60}, {"title": "Draft outline", "minutes": 30}]
                Do not include markdown formatting like ```json. Just the raw JSON string.
                """
                
                let cleanText = try await generateContent(prompt: prompt)
                
                guard let taskData = cleanText.data(using: .utf8) else {
                     throw NSError(domain: "GeminiClient", code: 2, userInfo: [NSLocalizedDescriptionKey: "Failed to convert text to data"])
                }
                
                struct GeminiTask: Decodable {
                    let title: String
                    let minutes: Int
                }
                
                let geminiTasks = try JSONDecoder().decode([GeminiTask].self, from: taskData)
                
                return geminiTasks.map { GoalTask(title: $0.title, estimatedMinutes: $0.minutes) }
            },
            updateGoal: { currentGoal, instruction in
                let prompt = """
                You are an expert project manager.
                The user has a goal: "\(currentGoal.title)".
                Current tasks: \(currentGoal.tasks.map { $0.title }.joined(separator: ", "))
                
                User Instruction: "\(instruction)"
                
                Based on the instruction, generate a NEW list of tasks and milestones.
                
                Return ONLY a JSON object with two keys: "tasks" and "milestones".
                "tasks": Array of objects with "title" and "minutes".
                "milestones": Array of objects with "title" and "order" (int).
                
                Example:
                {
                  "tasks": [{"title": "Task 1", "minutes": 30}],
                  "milestones": [{"title": "Phase 1", "order": 0}]
                }
                """
                
                let cleanText = try await generateContent(prompt: prompt)
                
                guard let data = cleanText.data(using: .utf8) else {
                    throw NSError(domain: "GeminiClient", code: 2, userInfo: [NSLocalizedDescriptionKey: "Failed to convert text to data"])
                }
                
                struct GeminiResponse: Decodable {
                    struct Task: Decodable { let title: String; let minutes: Int }
                    struct Milestone: Decodable { let title: String; let order: Int }
                    let tasks: [Task]
                    let milestones: [Milestone]
                }
                
                let response = try JSONDecoder().decode(GeminiResponse.self, from: data)
                
                let newTasks = response.tasks.map { GoalTask(title: $0.title, estimatedMinutes: $0.minutes) }
                // MilestoneのtaskIdsは後で紐付ける必要があるが、ここでは空で作成
                let newMilestones = response.milestones.map { Milestone(title: $0.title, taskIds: [], order: $0.order) }
                
                return (newTasks, newMilestones)
            }
        )
    }()
}

// 互換性のための typealias
public typealias GeminiService = GeminiClient

extension GeminiClient {
    /// APIキーを指定して初期化（互換性のため）
    public init(apiKey: String) {
        // 共通のAPIリクエストロジック
        @Sendable func generateContent(prompt: String) async throws -> String {
            let url = URL(string: "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=\(apiKey)")!
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let body: [String: Any] = [
                "contents": [
                    [
                        "parts": [
                            ["text": prompt]
                        ]
                    ]
                ]
            ]
            
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
            
            let (data, _) = try await URLSession.shared.data(for: request)
            
            guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let candidates = json["candidates"] as? [[String: Any]],
                  let content = candidates.first?["content"] as? [String: Any],
                  let parts = content["parts"] as? [[String: Any]],
                  let text = parts.first?["text"] as? String else {
                throw NSError(domain: "GeminiClient", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to parse Gemini response"])
            }
            
            return text.replacingOccurrences(of: "```json", with: "").replacingOccurrences(of: "```", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
        }
        
        self.generateTasks = { goal, deadline in
            let prompt = """
            You are an expert project manager.
            The user has a goal: "\(goal)".
            The deadline is: \(deadline.formatted()).
            
            Break this goal down into a list of concrete, actionable tasks.
            For each task, provide:
            1. A concise title.
            2. Estimated time in minutes (integer).
            
            Return ONLY a JSON array of objects with keys "title" and "minutes".
            Example: [{"title": "Research topic", "minutes": 60}, {"title": "Draft outline", "minutes": 30}]
            Do not include markdown formatting like ```json. Just the raw JSON string.
            """
            
            let cleanText = try await generateContent(prompt: prompt)
            
            guard let taskData = cleanText.data(using: .utf8) else {
                 throw NSError(domain: "GeminiClient", code: 2, userInfo: [NSLocalizedDescriptionKey: "Failed to convert text to data"])
            }
            
            struct GeminiTask: Decodable {
                let title: String
                let minutes: Int
            }
            
            let geminiTasks = try JSONDecoder().decode([GeminiTask].self, from: taskData)
            
            return geminiTasks.map { GoalTask(title: $0.title, estimatedMinutes: $0.minutes) }
        }
        
        self.updateGoal = { currentGoal, instruction in
            let prompt = """
            You are an expert project manager.
            The user has a goal: "\(currentGoal.title)".
            Current tasks: \(currentGoal.tasks.map { $0.title }.joined(separator: ", "))
            
            User Instruction: "\(instruction)"
            
            Based on the instruction, generate a NEW list of tasks and milestones.
            
            Return ONLY a JSON object with two keys: "tasks" and "milestones".
            "tasks": Array of objects with "title" and "minutes".
            "milestones": Array of objects with "title" and "order" (int).
            
            Example:
            {
              "tasks": [{"title": "Task 1", "minutes": 30}],
              "milestones": [{"title": "Phase 1", "order": 0}]
            }
            """
            
            let cleanText = try await generateContent(prompt: prompt)
            
            guard let data = cleanText.data(using: .utf8) else {
                throw NSError(domain: "GeminiClient", code: 2, userInfo: [NSLocalizedDescriptionKey: "Failed to convert text to data"])
            }
            
            struct GeminiResponse: Decodable {
                struct Task: Decodable { let title: String; let minutes: Int }
                struct Milestone: Decodable { let title: String; let order: Int }
                let tasks: [Task]
                let milestones: [Milestone]
            }
            
            let response = try JSONDecoder().decode(GeminiResponse.self, from: data)
            
            let newTasks = response.tasks.map { GoalTask(title: $0.title, estimatedMinutes: $0.minutes) }
            // MilestoneのtaskIdsは後で紐付ける必要があるが、ここでは空で作成
            let newMilestones = response.milestones.map { Milestone(title: $0.title, taskIds: [], order: $0.order) }
            
            return (newTasks, newMilestones)
        }
    }
}

public extension DependencyValues {
    var geminiClient: GeminiClient {
        get { self[GeminiClient.self] }
        set { self[GeminiClient.self] = newValue }
    }
}
