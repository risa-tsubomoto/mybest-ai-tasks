import Foundation

/// タスクの繰り返し設定。
public enum TaskRecurrence: String, Codable {
    case none
    case daily
    case weekly
    case weekdays
}
