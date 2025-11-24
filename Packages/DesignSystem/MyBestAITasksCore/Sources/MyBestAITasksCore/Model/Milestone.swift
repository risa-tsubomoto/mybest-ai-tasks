import Foundation
import SwiftData

/// 目標のマイルストーンを表すモデル。
@Model
public final class Milestone {
    /// マイルストーンの一意な識別子。
    public var id: UUID
    /// マイルストーンのタイトル。
    public var title: String
    /// マイルストーンに関連付けられたタスクのIDリスト。
    public var taskIds: [UUID]
    /// マイルストーンの期限（オプショナル）。
    public var deadline: Date?
    /// マイルストーンの順序。
    public var order: Int
    
    /// このマイルストーンが属する目標。
    public var goal: Goal?
    
    public init(id: UUID = UUID(), title: String, taskIds: [UUID] = [], deadline: Date? = nil, order: Int = 0) {
        self.id = id
        self.title = title
        self.taskIds = taskIds
        self.deadline = deadline
        self.order = order
    }
    
    /// マイルストーンに含まれるタスクがすべて完了しているかどうかを判定する。
    /// - Parameter tasks: 目標に含まれる全タスクのリスト。
    /// - Returns: すべて完了していれば true。
    public func isCompleted(tasks: [GoalTask]) -> Bool {
        guard !taskIds.isEmpty else { return false }
        
        let milestoneTasks = tasks.filter { taskIds.contains($0.id) }
        guard !milestoneTasks.isEmpty else { return false }
        
        return milestoneTasks.allSatisfy { $0.status == .completed }
    }
    
    /// マイルストーンの進捗率（0.0〜1.0）を計算する。
    /// - Parameter tasks: 目標に含まれる全タスクのリスト。
    /// - Returns: 進捗率。タスクがない場合は0.0。
    public func progress(tasks: [GoalTask]) -> Double {
        guard !taskIds.isEmpty else { return 0.0 }
        
        let milestoneTasks = tasks.filter { taskIds.contains($0.id) }
        guard !milestoneTasks.isEmpty else { return 0.0 }
        
        let completedCount = milestoneTasks.filter { $0.status == .completed }.count
        return Double(completedCount) / Double(milestoneTasks.count)
    }
}
