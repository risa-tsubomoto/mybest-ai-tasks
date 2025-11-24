import Foundation
import Combine
import MyBestAITasksCore

/// 目標詳細画面の ViewModel。
///
/// この ViewModel は、目標詳細画面のアクションを管理する。
@MainActor
class GoalDetailViewModel: ObservableObject {
    /// 表示中の目標。
    @Published var goal: Goal // Added
    private let repository: GoalRepositoryProtocol
    private let toggleTaskStatusUseCase: ToggleTaskStatusUseCase
    
    /// カレンダー連携サービス。
    private let calendarService = CalendarService() // Added
    /// カレンダー連携のアラートを表示するかどうか。
    @Published var showingCalendarAlert = false
    /// カレンダー連携のアラートメッセージ。
    @Published var calendarAlertMessage = ""
    /// 設定アプリへの誘導ボタンを表示するかどうか。
    @Published var shouldShowSettingsButton = false
    
    /// ViewModel を初期化する。
    /// - Parameters:
    ///   - goal: 詳細を表示する目標。
    ///   - repository: 目標データを管理するためのリポジトリ。
    init(goal: Goal, repository: GoalRepositoryProtocol) {
        self.goal = goal
        self.repository = repository
        self.toggleTaskStatusUseCase = ToggleTaskStatusUseCase(repository: repository)
    }
    
    /// タスクの完了状態を切り替える。
    /// - Parameter task: 切り替えるタスク。
    func toggleTask(_ task: GoalTask) {
        if let index = goal.tasks.firstIndex(where: { $0.id == task.id }) {
            // Update local state immediately for UI responsiveness
            goal.tasks[index].status = (goal.tasks[index].status == .completed) ? .pending : .completed
            
            // Persist change
            Task {
                try? await repository.updateGoal(goal)
            }
        }
    }
    
    /// 目標内のすべてのタスクをカレンダーに追加する。
    func addToCalendar() {
        Task {
            do {
                let _ = try await calendarService.scheduleTasks(goal.tasks, goal.startDate ?? Date(), goal.deadline)
                await MainActor.run {
                    self.calendarAlertMessage = "既存のイベントを削除してカレンダーに追加しました"
                    self.shouldShowSettingsButton = false
                    self.showingCalendarAlert = true
                }
            } catch {
                await MainActor.run {
                    self.calendarAlertMessage = error.localizedDescription
                    // Check if it's a permission error (code 1 from CalendarService)
                    let nsError = error as NSError
                    if nsError.domain == "CalendarService" && nsError.code == 1 {
                        self.shouldShowSettingsButton = true
                    } else {
                        self.shouldShowSettingsButton = false
                    }
                    self.showingCalendarAlert = true
                }
            }
        }
    }
}
