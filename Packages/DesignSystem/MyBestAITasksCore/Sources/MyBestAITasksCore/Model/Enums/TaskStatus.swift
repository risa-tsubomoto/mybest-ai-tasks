import Foundation

/// 目標内のタスクの状態を表す。
public enum TaskStatus: String, Codable {
    /// タスクは完了待ち。
    case pending
    /// タスクは完了済み。
    case completed
    /// タスクはスキップされた。
    case skipped
}
