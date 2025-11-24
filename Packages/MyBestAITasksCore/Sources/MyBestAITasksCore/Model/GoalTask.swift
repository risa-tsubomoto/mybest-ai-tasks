import Foundation
import SwiftData

/// 目標に関連付けられた単一のタスク。
@Model
public final class GoalTask: @unchecked Sendable {
    /// タスクの一意な識別子。
    public var id: UUID
    /// タスクのタイトルまたは説明。
    public var title: String
    /// タスク完了までの推定時間（分）。
    public var estimatedMinutes: Int
    /// タスクの現在の状態。
    public var status: TaskStatus
    /// タスクの予定日（設定されている場合）。
    public var scheduledDate: Date?
    /// タスクの繰り返し設定。既存データとの後方互換性のためオプショナル。
    public var recurrence: TaskRecurrence?
    
    /// このタスクが属する目標。
    /// 注意: タスクは割り当てられる前に作成される可能性があるためオプショナルだが、
    /// このアプリのロジックでは通常、目標の一部として存在する。
    public var goal: Goal?
    
    /// 新しい `GoalTask` を初期化する。
    /// - Parameters:
    ///   - id: 一意な識別子。デフォルトは新しい UUID。
    ///   - title: タスクのタイトル。
    ///   - estimatedMinutes: 推定所要時間（分）。
    ///   - status: 初期状態。デフォルトは `.pending`。
    ///   - scheduledDate: 予定日。デフォルトは `nil`。
    ///   - recurrence: 繰り返し設定。デフォルトは `nil`。
    public init(id: UUID = UUID(), title: String, estimatedMinutes: Int, status: TaskStatus = .pending, scheduledDate: Date? = nil, recurrence: TaskRecurrence? = nil) {
        self.id = id
        self.title = title
        self.estimatedMinutes = estimatedMinutes
        self.status = status
        self.scheduledDate = scheduledDate
        self.recurrence = recurrence
    }
}
