import Foundation
import EventKit
import Dependencies
import DependenciesMacros

/// カレンダーとの連携を担当するクライアント
@DependencyClient
struct CalendarClient: Sendable {
    /// カレンダーアクセス許可をリクエスト
    var requestAccess: @Sendable () async -> Bool = { false }
    
    /// タスクをカレンダーにスケジュール
    var scheduleTasks: @Sendable (_ tasks: [GoalTask], _ startDate: Date) async throws -> [GoalTask]
    
    /// 既存のイベントを削除
    var removeExistingEvents: @Sendable (_ tasks: [GoalTask], _ goalTitle: String) async throws -> Void = { _, _ in }
}

extension CalendarClient: DependencyKey {
    static let liveValue: CalendarClient = {
        @Dependency(\.logger) var logger
        
        let actor = CalendarActor()
        
        return CalendarClient(
            requestAccess: {
                await withCheckedContinuation { continuation in
                    Task {
                        let store = await actor.eventStore
                        store.requestFullAccessToEvents { granted, error in
                            Task {
                                await actor.setAccessGranted(granted)
                                if let error = error {
                                    logger.error("Calendar access error: \(error.localizedDescription)")
                                }
                                continuation.resume(returning: granted)
                            }
                        }
                    }
                }
            },
            scheduleTasks: { tasks, startDate in
                guard await actor.isAccessGranted else {
                    throw NSError(domain: "CalendarClient", code: 1, userInfo: [NSLocalizedDescriptionKey: "Calendar access not granted"])
                }
                
                var scheduledTasks = tasks
                var currentDate = Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: startDate.addingTimeInterval(86400))! // Tomorrow 9 AM
                let store = await actor.eventStore
                
                for i in 0..<scheduledTasks.count {
                    let task = scheduledTasks[i]
                    let duration = TimeInterval(task.estimatedMinutes * 60)
                    
                    let event = EKEvent(eventStore: store)
                    event.title = "Goal: \(task.title)"
                    event.startDate = currentDate
                    event.endDate = currentDate.addingTimeInterval(duration)
                    event.calendar = store.defaultCalendarForNewEvents
                    
                    do {
                        try store.save(event, span: .thisEvent)
                        scheduledTasks[i].scheduledDate = currentDate
                        logger.info("Scheduled \(task.title) at \(currentDate.formatted())")
                    } catch {
                        logger.error("Failed to save event: \(error.localizedDescription)")
                    }
                    
                    currentDate = currentDate.addingTimeInterval(duration + 15 * 60)
                }
                
                return scheduledTasks
            },
            removeExistingEvents: { tasks, goalTitle in
                guard await actor.isAccessGranted else { return }
                
                let store = await actor.eventStore
                // 単純化のため、直近1年間のイベントを検索して削除（本来はID管理すべきだが）
                let startDate = Date().addingTimeInterval(-86400 * 30) // 1ヶ月前
                let endDate = Date().addingTimeInterval(86400 * 365) // 1年後
                let predicate = store.predicateForEvents(withStart: startDate, end: endDate, calendars: nil)
                let events = store.events(matching: predicate)
                
                for event in events {
                    if event.title.starts(with: "Goal:") && (event.title.contains(goalTitle) || tasks.contains(where: { event.title.contains($0.title) })) {
                        do {
                            try store.remove(event, span: .thisEvent)
                            logger.info("Removed event: \(event.title ?? "")")
                        } catch {
                            logger.error("Failed to remove event: \(error.localizedDescription)")
                        }
                    }
                }
            }
        )
    }()
}


// 互換性のための typealias
typealias CalendarService = CalendarClient

extension DependencyValues {
    var calendarClient: CalendarClient {
        get { self[CalendarClient.self] }
        set { self[CalendarClient.self] = newValue }
    }
}
