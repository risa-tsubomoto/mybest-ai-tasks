import Foundation
import EventKit
import Dependencies
import DependenciesMacros

/// カレンダーとの連携を担当するクライアント
@DependencyClient
public struct CalendarClient: Sendable {
    /// カレンダーアクセス許可をリクエスト
    public var requestAccess: @Sendable () async -> Bool = { false }
    
    /// タスクをカレンダーにスケジュール
    public var scheduleTasks: @Sendable (_ tasks: [GoalTask], _ startDate: Date, _ deadline: Date) async throws -> [GoalTask]
    
    /// 互換性のためのオーバーロード（期限なし）
    public var scheduleTasksLegacy: @Sendable (_ tasks: [GoalTask], _ startDate: Date) async throws -> [GoalTask] = { _, _ in [] }
    
    /// 既存のイベントを削除
    public var removeExistingEvents: @Sendable (_ tasks: [GoalTask], _ goalTitle: String) async throws -> Void = { _, _ in }
}

extension CalendarClient: DependencyKey {
    public static var liveValue: CalendarClient = {
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
            scheduleTasks: { tasks, startDate, deadline in
                guard await actor.isAccessGranted else {
                    throw NSError(domain: "CalendarClient", code: 1, userInfo: [NSLocalizedDescriptionKey: "Calendar access not granted"])
                }
                
                var scheduledTasks = tasks
                let store = await actor.eventStore
                let calendar = Calendar.current
                
                // 1. Calculate total minutes needed
                let totalMinutes = tasks.reduce(0) { $0 + $1.estimatedMinutes }
                
                // 2. Calculate available days
                let startDay = calendar.startOfDay(for: startDate)
                let endDay = calendar.startOfDay(for: deadline)
                
                let daysDiff = calendar.dateComponents([.day], from: startDay, to: endDay).day ?? 0
                let availableDays = max(1, daysDiff + 1)
                let minutesPerDay = Double(totalMinutes) / Double(availableDays)
                
                var currentTaskIndex = 0
                var currentDate = startDay
                
                // Loop through days until all tasks are scheduled
                while currentTaskIndex < scheduledTasks.count {
                    // Get working hours for this day
                    let weekdayInt = calendar.component(.weekday, from: currentDate)
                    let actualStartHour = (UserDefaults.standard.object(forKey: "workStartHour_\(weekdayInt)") as? Int) ?? 9
                    let actualEndHour = (UserDefaults.standard.object(forKey: "workEndHour_\(weekdayInt)") as? Int) ?? 18
                    
                    // Set start time for this day
                    var timeSlot = calendar.date(bySettingHour: actualStartHour, minute: 0, second: 0, of: currentDate)!
                    let endTime = calendar.date(bySettingHour: actualEndHour, minute: 0, second: 0, of: currentDate)!
                    
                    // If we are on the very first day and startDate is later than startHour, start from startDate
                    if calendar.isDate(currentDate, inSameDayAs: startDate) && startDate > timeSlot {
                        timeSlot = startDate
                    }
                    
                    var dailyMinutesScheduled = 0.0
                    
                    // Try to schedule tasks for this day
                    while currentTaskIndex < scheduledTasks.count {
                        let task = scheduledTasks[currentTaskIndex]
                        let taskDuration = TimeInterval(task.estimatedMinutes * 60)
                        
                        // Check if task fits in remaining time of the day
                        if timeSlot.addingTimeInterval(taskDuration) <= endTime {
                            
                            // Check if we exceeded daily quota (soft limit)
                            // We allow exceeding if it's the first task of the day (to avoid infinite loop if task > quota)
                            if dailyMinutesScheduled >= minutesPerDay && dailyMinutesScheduled > 0 {
                                break // Move to next day
                            }
                            
                            // Schedule it
                            let event = EKEvent(eventStore: store)
                            event.title = "Goal: \(task.title)"
                            event.startDate = timeSlot
                            event.endDate = timeSlot.addingTimeInterval(taskDuration)
                            event.calendar = store.defaultCalendarForNewEvents
                            
                            do {
                                try store.save(event, span: .thisEvent)
                                scheduledTasks[currentTaskIndex].scheduledDate = timeSlot
                                logger.info("Scheduled \(task.title) at \(timeSlot.formatted())")
                            } catch {
                                logger.error("Failed to save event: \(error.localizedDescription)")
                            }
                            
                            // Advance time
                            timeSlot = timeSlot.addingTimeInterval(taskDuration + 15 * 60) // 15 min buffer
                            dailyMinutesScheduled += Double(task.estimatedMinutes)
                            currentTaskIndex += 1
                        } else {
                            // Doesn't fit in this day
                            break
                        }
                    }
                    
                    // Move to next day
                    guard let nextDate = calendar.date(byAdding: .day, value: 1, to: currentDate) else { break }
                    currentDate = nextDate
                    
                    // Safety break to prevent infinite loop if tasks can never be scheduled
                    if currentDate > deadline.addingTimeInterval(86400 * 365) {
                        logger.error("Failed to schedule all tasks within reasonable time")
                        break
                    }
                }
                
                return scheduledTasks
            },
            scheduleTasksLegacy: { tasks, startDate in
                let deadline = Calendar.current.date(byAdding: .year, value: 1, to: startDate) ?? startDate
                return []
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
public typealias CalendarService = CalendarClient

public extension DependencyValues {
    var calendarClient: CalendarClient {
        get { self[CalendarClient.self] }
        set { self[CalendarClient.self] = newValue }
    }
}
