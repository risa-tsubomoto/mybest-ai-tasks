import Foundation
import Dependencies

/// 目標作成のユースケース。
public struct CreateGoalUseCase {
    var repository: GoalRepositoryProtocol
    var geminiService: GeminiService
    var notificationManager: NotificationManaging
    
    public init(repository: GoalRepositoryProtocol, geminiService: GeminiService, notificationManager: NotificationManaging) {
        self.repository = repository
        self.geminiService = geminiService
        self.notificationManager = notificationManager
    }
    
    /// 目標を作成し、AIを使ってタスクを生成して保存する。
    public func execute(title: String, deadline: Date) async throws {
        // 1. Geminiでタスク生成
        let tasks = try await geminiService.generateTasks(title, deadline)
        
        // 2. Goal作成
        let goal = Goal(title: title, deadline: deadline, tasks: tasks)
        
        // 3. 保存
        try await repository.addGoal(goal)
        
        // 4. 通知スケジュール (例: 締め切りの前日)
        let notificationDate = deadline.addingTimeInterval(-86400) // 1日前
        if notificationDate > Date() {
            notificationManager.scheduleNotification(
                title: "目標の期限が近づいています",
                body: "目標「\(title)」の期限は明日です。",
                date: notificationDate
            )
        }
    }
}
