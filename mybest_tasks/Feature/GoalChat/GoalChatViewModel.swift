import SwiftUI
import SwiftData
import MyBestAITasksCore
import Dependencies

@MainActor
class GoalChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    @Dependency(\.logger) var logger
    
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
        // logger property is not available in init because it's a property wrapper on self, 
        // but DependencyClient is usually lazy. However, @Dependency is property wrapper.
        // We can't use self.logger in init easily if it relies on self.
        // Actually @Dependency resolves from global stack if not injected.
        // But for safety and simplicity in init, we might skip logging or use a local resolution if needed.
        // However, standard practice is to rely on it in methods. 
        // Let's try to use it, but if it fails we might need a workaround. 
        // Actually, @Dependency can be used in init if it's not using 'self' to access it, but here it is a property of self.
        // Let's just print to console for init or use a static logger if available? 
        // The user said "use logger client for EVERYTHING".
        // I will use `print` in init for now as `self` is not fully initialized, OR I can initialize it inline.
        // Wait, @Dependency is available after init.
        // I will move the logging to `onAppear` or just remove the init log if it's not critical, or use `DependencyValues._current.logger`.
        // Let's check how LoggerClient is defined.
        
        self.geminiService = GeminiService(apiKey: apiKey)
        
        // Initial message
        messages.append(ChatMessage(text: "この目標について何か変更したいことはありますか？\n(例: 「タスクAを削除して」「期限を延ばして」)", isUser: false))
    }
    
    func sendMessage(_ text: String) async {
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        logger.info("🔵 [GoalChatViewModel] Sending message: \(text)")
        logger.debug("🔵 [GoalChatViewModel] Current goal: \(self.goal.title)")
        logger.debug("🔵 [GoalChatViewModel] Current tasks count: \(self.goal.tasks.count)")
        
        messages.append(ChatMessage(text: text, isUser: true))
        isLoading = true
        errorMessage = nil
        
        do {
            logger.info("🔵 [GoalChatViewModel] Calling GeminiService.updateGoal...")
            let (newTasks, newMilestones) = try await geminiService.updateGoal(currentGoal: goal, instruction: text)
            
            logger.info("✅ [GoalChatViewModel] Received \(newTasks.count) tasks and \(newMilestones.count) milestones")
            
            // Update goal
            logger.info("🔵 [GoalChatViewModel] Updating goal tasks and milestones...")
            goal.tasks = newTasks
            goal.milestones = newMilestones
            
            // Save context (SwiftData autosaves, but good to be explicit if needed)
            // try modelContext.save()
            
            messages.append(ChatMessage(text: "目標を更新しました！\n新しいタスク数: \(newTasks.count)", isUser: false))
            
            // Schedule notifications for new tasks
            logger.info("🔵 [GoalChatViewModel] Scheduling notifications for \(newTasks.count) tasks...")
            for task in newTasks {
                notificationManager.scheduleNotification(for: task)
            }
            logger.info("✅ [GoalChatViewModel] Successfully completed update")
            
        } catch let error as NSError {
            logger.error("❌ [GoalChatViewModel] Error occurred: \(error)")
            logger.error("❌ [GoalChatViewModel] Error type: \(type(of: error))")
            logger.error("❌ [GoalChatViewModel] Error localized description: \(error.localizedDescription)")
            logger.error("❌ [GoalChatViewModel] Error domain: \(error.domain)")
            logger.error("❌ [GoalChatViewModel] Error code: \(error.code)")
            logger.error("❌ [GoalChatViewModel] Error userInfo: \(error.userInfo)")
            
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
        logger.info("🔵 [GoalChatViewModel] Message processing completed")
    }
    
    /// この目標のカレンダーイベントを削除する。
    func removeCalendarEvents() async {
        logger.info("🗑️ [GoalChatViewModel] Removing calendar events for goal: \(self.goal.title)")
        isLoading = true
        
        do {
            let calendarService = CalendarService()
            try await calendarService.removeExistingEvents(tasks: goal.tasks, goalTitle: goal.title)
            
            await MainActor.run {
                messages.append(ChatMessage(text: "カレンダー登録を削除しました。", isUser: false))
                logger.info("✅ [GoalChatViewModel] Successfully removed calendar events")
            }
        } catch {
            logger.error("❌ [GoalChatViewModel] Failed to remove calendar events: \(error)")
            await MainActor.run {
                messages.append(ChatMessage(text: "カレンダー削除中にエラーが発生しました。", isUser: false))
            }
        }
        
        isLoading = false
    }
}
