import Foundation
import SwiftData


/// 複数のタスクを含む、ユーザーの目標を表す。
@Model
public final class Goal {
    /// 目標の一意な識別子。
    /// SwiftData は ID を自動管理するが、既存のロジックとの互換性や安定した識別のために UUID を保持する。
    public var id: UUID
    /// 目標のタイトル。
    public var title: String
    /// 目標達成の期限。
    public var deadline: Date
    /// 目標を達成するために必要なタスクのリスト。
    @Relationship(deleteRule: .cascade, inverse: \GoalTask.goal)
    public var tasks: [GoalTask]
    /// 目標のマイルストーン（オプション、AI生成）。
    @Relationship(deleteRule: .cascade, inverse: \Milestone.goal)
    public var milestones: [Milestone]
    /// 目標が作成された日時。
    public var createdAt: Date
    /// 目標の開始日。スケジュールを組む際、この日より前にタスクを配置しない。既存データとの互換性のためオプショナル。
    public var startDate: Date?
    /// 目標全体が完了しているかどうかを示す。
    public var isCompleted: Bool
    
    /// 新しい `Goal` を初期化する。
    /// - Parameters:
    ///   - id: 一意な識別子。デフォルトは新しい UUID。
    ///   - title: 目標のタイトル。
    ///   - deadline: 目標の期限。
    ///   - tasks: タスクのリスト。デフォルトは空。
    ///   - milestones: マイルストーンのリスト。デフォルトは空。
    ///   - createdAt: 作成日時。デフォルトは現在日時。
    ///   - startDate: 開始日。デフォルトは `nil`（作成日時と同じとして扱われる）。
    ///   - isCompleted: 完了状態。デフォルトは `false`。
    public init(id: UUID = UUID(), title: String, deadline: Date, tasks: [GoalTask] = [], milestones: [Milestone] = [], createdAt: Date = Date(), startDate: Date? = nil, isCompleted: Bool = false) {
        self.id = id
        self.title = title
        self.deadline = deadline
        self.tasks = tasks
        self.milestones = milestones
        self.createdAt = createdAt
        self.startDate = startDate
        self.isCompleted = isCompleted
    }
}

extension Goal {
    /// タスクベースの進捗（0.0〜1.0）。
    public var progress: Double {
        guard !tasks.isEmpty else { return 0 }
        let completed = tasks.filter { $0.status == .completed }.count
        return Double(completed) / Double(tasks.count)
    }
    
    /// マイルストーンベースの進捗（0.0〜1.0）。
    /// マイルストーンがない場合は `nil`。
    public var milestoneProgress: Double? {
        guard !milestones.isEmpty else { return nil }
        let completed = milestones.filter { $0.isCompleted(tasks: tasks) }.count
        return Double(completed) / Double(milestones.count)
    }
    
    /// 完了タスク数と全タスク数のタプル。
    public var taskCounts: (completed: Int, total: Int) {
        let completed = tasks.filter { $0.status == .completed }.count
        return (completed, tasks.count)
    }
}
