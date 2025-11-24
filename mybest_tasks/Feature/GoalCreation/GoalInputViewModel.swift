import Foundation
import Combine
import MyBestAITasksCore

/// ViewModel for the goal creation view.
///
/// This ViewModel handles the input form for creating a new goal and orchestrates the AI generation process.
@MainActor
class GoalInputViewModel: ObservableObject {
    /// The title of the new goal.
    @Published var title: String = ""
    /// The deadline for the new goal.
    @Published var deadline: Date = Date().addingTimeInterval(86400 * 7)
    /// Indicates whether the creation process is in progress.
    @Published var isLoading: Bool = false
    /// An error message to display if creation fails.
    @Published var errorMessage: String?
    /// Indicates whether the view should be dismissed.
    @Published var isDismissed: Bool = false
    
    private let createGoalUseCase: CreateGoalUseCase
    
    /// Initializes the ViewModel.
    /// - Parameter createGoalUseCase: The use case for creating goals.
    init(createGoalUseCase: CreateGoalUseCase) {
        self.createGoalUseCase = createGoalUseCase
    }
    
    /// Initiates the goal creation process.
    ///
    /// This method validates the input, calls the use case, and updates the state based on the result.
    func createGoal() {
        guard !title.isEmpty else { return }
        
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                try await createGoalUseCase.execute(title: title, deadline: deadline)
                isLoading = false
                isDismissed = true
            } catch {
                isLoading = false
                errorMessage = "Failed to create goal: \(error.localizedDescription)"
            }
        }
    }
}
