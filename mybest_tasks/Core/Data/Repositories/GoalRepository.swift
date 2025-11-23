import Foundation
import Combine
import SwiftData

/// 目標データへのアクセスを抽象化するプロトコル。
///
/// このプロトコルは、目標（Goal）の取得、追加、更新、削除などの基本的なデータ操作を定義します。
/// アプリケーションの他の部分は、具体的な実装クラスではなく、このプロトコルに依存することで、
/// テスト容易性と疎結合性を高めることができます。
protocol GoalRepositoryProtocol {
    /// 全ての目標を取得する Publisher を返します。
    /// - Returns: 目標の配列を放出する AnyPublisher。
    func getGoals() -> AnyPublisher<[Goal], Never>
    
    /// 新しい目標を追加します。
    /// - Parameter goal: 追加する目標オブジェクト。
    func addGoal(_ goal: Goal) async throws
    
    /// 既存の目標を更新します。
    /// - Parameter goal: 更新する目標オブジェクト。
    func updateGoal(_ goal: Goal) async throws
    
    /// 指定されたIDの目標を削除します。
    /// - Parameter id: 削除する目標のUUID。
    func deleteGoal(id: UUID) async throws
    
    /// 指定されたタスクの完了状態を切り替えます。
    /// - Parameters:
    ///   - goalId: タスクが属する目標のUUID。
    ///   - taskId: 状態を切り替えるタスクのUUID。
    func toggleTaskStatus(goalId: UUID, taskId: UUID) async throws
}

/// SwiftData を使用した `GoalRepositoryProtocol` の具体的な実装。
class GoalRepository: GoalRepositoryProtocol {
    private let modelContext: ModelContext
    private let goalsSubject = CurrentValueSubject<[Goal], Never>([])
    
    /// リポジトリを初期化する。
    /// - Parameter modelContext: SwiftData のモデルコンテキスト。
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        loadData()
    }
    
    private func loadData() {
        do {
            let descriptor = FetchDescriptor<Goal>(sortBy: [SortDescriptor(\.createdAt)])
            let goals = try modelContext.fetch(descriptor)
            goalsSubject.send(goals)
        } catch {
            print("Failed to fetch goals: \(error)")
        }
    }
    
    /// 現在の目標リストを放出する Publisher を取得する。
    func getGoals() -> AnyPublisher<[Goal], Never> {
        return goalsSubject.eraseToAnyPublisher()
    }
    
    /// 新しい目標をリポジトリに追加する。
    func addGoal(_ goal: Goal) async throws {
        modelContext.insert(goal)
        try modelContext.save()
        loadData()
    }
    
    /// リポジトリ内の既存の目標を更新する。
    func updateGoal(_ goal: Goal) async throws {
        // SwiftData では、'goal' は参照型 (@Model class) なので、
        // オブジェクトのプロパティを直接変更すればコンテキストが更新される。
        // ここでは保存するだけ。
        try modelContext.save()
        loadData()
    }
    
    /// 指定された識別子の目標を削除する。
    func deleteGoal(id: UUID) async throws {
        let descriptor = FetchDescriptor<Goal>(predicate: #Predicate { $0.id == id })
        if let goalToDelete = try modelContext.fetch(descriptor).first {
            modelContext.delete(goalToDelete)
            try modelContext.save()
            loadData()
        }
    }
    
    /// 目標内の特定のタスクの完了状態を切り替える。
    func toggleTaskStatus(goalId: UUID, taskId: UUID) async throws {
        // まず目標を取得
        let descriptor = FetchDescriptor<Goal>(predicate: #Predicate { $0.id == goalId })
        guard let goal = try modelContext.fetch(descriptor).first else { return }
        
        // タスクを探す
        // 注意: GoalTask はクラスになったので、直接変更できる
        if let task = goal.tasks.first(where: { $0.id == taskId }) {
            task.status = (task.status == .completed) ? .pending : .completed
            try modelContext.save()
            loadData()
        }
    }
}
