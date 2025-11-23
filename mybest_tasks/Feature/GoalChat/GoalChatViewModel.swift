import SwiftUI
import SwiftData

@MainActor
class GoalChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let goal: Goal
    private let geminiService: GeminiService
    private let modelContext: ModelContext
    private let notificationManager: NotificationManaging
    
    init(goal: Goal, modelContext: ModelContext, notificationManager: NotificationManaging) {
        self.goal = goal
        self.modelContext = modelContext
        self.notificationManager = notificationManager
        
        // Retrieve API key from Keychain
        let apiKey = KeychainHelper.shared.read(for: "geminiApiKey") ?? ""
        print("🔵 [GoalChatViewModel.init] API Key retrieved from Keychain: \(apiKey.isEmpty ? "EMPTY" : "EXISTS (length: \(apiKey.count))")")
        self.geminiService = GeminiService(apiKey: apiKey)
        
        // Initial message
        messages.append(ChatMessage(text: "この目標について何か変更したいことはありますか？\n(例: 「タスクAを削除して」「期限を延ばして」)", isUser: false))
    }
    
    func sendMessage(_ text: String) async {
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        print("🔵 [GoalChatViewModel] Sending message: \(text)")
        print("🔵 [GoalChatViewModel] Current goal: \(goal.title)")
        print("🔵 [GoalChatViewModel] Current tasks count: \(goal.tasks.count)")
        
        messages.append(ChatMessage(text: text, isUser: true))
        isLoading = true
        errorMessage = nil
        
        do {
            print("🔵 [GoalChatViewModel] Calling GeminiService.updateGoal...")
            let (newTasks, newMilestones) = try await geminiService.updateGoal(currentGoal: goal, instruction: text)
            
            print("✅ [GoalChatViewModel] Received \(newTasks.count) tasks and \(newMilestones.count) milestones")
            
            // Update goal
            print("🔵 [GoalChatViewModel] Updating goal tasks and milestones...")
            goal.tasks = newTasks
            goal.milestones = newMilestones
            
            // Save context (SwiftData autosaves, but good to be explicit if needed)
            // try modelContext.save()
            
            messages.append(ChatMessage(text: "目標を更新しました！\n新しいタスク数: \(newTasks.count)", isUser: false))
            
            // Schedule notifications for new tasks
            print("🔵 [GoalChatViewModel] Scheduling notifications for \(newTasks.count) tasks...")
            for task in newTasks {
                notificationManager.scheduleNotification(for: task)
            }
            print("✅ [GoalChatViewModel] Successfully completed update")
            
        } catch let error as NSError {
            print("❌ [GoalChatViewModel] Error occurred: \(error)")
            print("❌ [GoalChatViewModel] Error type: \(type(of: error))")
            print("❌ [GoalChatViewModel] Error localized description: \(error.localizedDescription)")
            print("❌ [GoalChatViewModel] Error domain: \(error.domain)")
            print("❌ [GoalChatViewModel] Error code: \(error.code)")
            print("❌ [GoalChatViewModel] Error userInfo: \(error.userInfo)")
            
            // Provide user-friendly error messages
            var userMessage = "申し訳ありません、エラーが発生しました。"
            
            if error.domain == "GeminiService" && error.code == 403 {
                userMessage = "API認証エラー: Gemini APIキーが正しく設定されていません。設定画面でAPIキーを確認してください。"
            } else if error.domain == "GeminiService" && error.code == 1 {
                userMessage = "Gemini APIからの応答を解析できませんでした。もう一度お試しください。"
            }
            
            errorMessage = error.localizedDescription
            messages.append(ChatMessage(text: userMessage, isUser: false))
        }
        
        isLoading = false
        print("🔵 [GoalChatViewModel] Message processing completed")
    }
    
    /// この目標のカレンダーイベントを削除する。
    func removeCalendarEvents() async {
        print("🗑️ [GoalChatViewModel] Removing calendar events for goal: \(goal.title)")
        isLoading = true
        
        do {
            let calendarService = CalendarService()
            try await calendarService.removeExistingEvents(tasks: goal.tasks, goalTitle: goal.title)
            
            await MainActor.run {
                messages.append(ChatMessage(text: "カレンダー登録を削除しました。", isUser: false))
                print("✅ [GoalChatViewModel] Successfully removed calendar events")
            }
        } catch {
            print("❌ [GoalChatViewModel] Failed to remove calendar events: \(error)")
            await MainActor.run {
                messages.append(ChatMessage(text: "カレンダー削除中にエラーが発生しました。", isUser: false))
            }
        }
        
        isLoading = false
    }
}
