import Foundation

/// タスクの完了状態を切り替えるユースケース。
public struct ToggleTaskStatusUseCase {
    let repository: GoalRepositoryProtocol
    
    /// タスクの完了状態を切り替える。
    /// - Parameters:
    ///   - goalId: 目標のID。
    ///   - taskId: タスクのID。
    func execute(goalId: UUID, taskId: UUID) async throws {
        try await repository.toggleTaskStatus(goalId: goalId, taskId: taskId)
    }
}
