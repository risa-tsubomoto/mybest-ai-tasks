import Foundation

/// タスクの完了状態を切り替えるユースケース。
public struct ToggleTaskStatusUseCase {
    let repository: GoalRepositoryProtocol
    
    public init(repository: GoalRepositoryProtocol) {
        self.repository = repository
    }
    
    /// タスクの完了状態を切り替える。
    /// - Parameters:
    ///   - goalId: 目標のID。
    ///   - taskId: タスクのID。
    public func execute(goalId: UUID, taskId: UUID) async throws {
        try await repository.toggleTaskStatus(goalId: goalId, taskId: taskId)
    }
}
