import Foundation
import UserNotifications

/// 通知管理のプロトコル。
///
/// ローカル通知のスケジュールや権限リクエストなどの機能を抽象化します。
public protocol NotificationManaging {
    /// 通知の許可をユーザーにリクエストします。
    func requestAuthorization()
    
    /// 指定された日時で通知をスケジュールします。
    /// - Parameters:
    ///   - title: 通知のタイトル。
    ///   - body: 通知の本文。
    ///   - date: 通知を表示する日時。
    func scheduleNotification(title: String, body: String, date: Date)
    
    /// タスクの期限に基づいて通知をスケジュールします。
    /// - Parameter task: 通知を設定するタスク。
    func scheduleNotification(for task: GoalTask)
}

/// ローカル通知を管理するクラス。
public class NotificationManager: NotificationManaging {
    private let center = UNUserNotificationCenter.current()
    
    public init() {}
    
    /// 通知の許可をリクエストする。
    public func requestAuthorization() {
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Notification authorization error: \(error)")
            }
        }
    }
    
    /// 通知をスケジュールする。
    /// - Parameters:
    ///   - title: 通知のタイトル。
    ///   - body: 通知の本文。
    ///   - date: 通知を表示する日時。
    public func scheduleNotification(title: String, body: String, date: Date) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        center.add(request) { error in
            if let error = error {
                print("Failed to schedule notification: \(error)")
            }
        }
    }
    
    /// タスクの通知をスケジュールする。
    public func scheduleNotification(for task: GoalTask) {
        guard let date = task.scheduledDate else { return }
        scheduleNotification(title: "タスクの期限です", body: task.title, date: date)
    }
}
