import Foundation
import Combine

/// テスト用のモックリポジトリ。
class MockGoalRepository: GoalRepositoryProtocol {
    var goals: [Goal] = []
    
    init(initialGoals: [Goal] = []) {
        self.goals = initialGoals
    }
    
    func getGoals() -> AnyPublisher<[Goal], Never> {
        return Just(goals).eraseToAnyPublisher()
    }
    
    func addGoal(_ goal: Goal) async throws {
        goals.append(goal)
    }
    
    func updateGoal(_ goal: Goal) async throws {
        if let index = goals.firstIndex(where: { $0.id == goal.id }) {
            goals[index] = goal
        }
    }
    
    func deleteGoal(id: UUID) async throws {
        goals.removeAll { $0.id == id }
    }
    
    func toggleTaskStatus(goalId: UUID, taskId: UUID) async throws {
        guard let goalIndex = goals.firstIndex(where: { $0.id == goalId }),
              let taskIndex = goals[goalIndex].tasks.firstIndex(where: { $0.id == taskId }) else {
            return
        }
        
        let task = goals[goalIndex].tasks[taskIndex]
        task.status = (task.status == .completed) ? .pending : .completed
    }
}
