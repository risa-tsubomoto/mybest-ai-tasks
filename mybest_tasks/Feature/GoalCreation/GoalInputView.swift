import SwiftUI

struct GoalInputView: View {
    @StateObject var viewModel: GoalInputViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                DesignSystem.Colors.background.ignoresSafeArea()
                
                VStack(spacing: DesignSystem.Spacing.large) {
                    // Form
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.medium) {
                        Text("What is your goal?")
                            .font(.headline)
                        
                        DSTextField("E.g., Learn SwiftUI in 30 days", text: $viewModel.title)
                        
                        Text("Deadline")
                            .font(.headline)
                            .padding(.top)
                        
                        DatePicker("", selection: $viewModel.deadline, displayedComponents: .date)
                            .datePickerStyle(GraphicalDatePickerStyle())
                            .padding()
                            .background(DesignSystem.Colors.cardBackground)
                            .cornerRadius(8)
                    }
                    .padding()
                    
                    if let error = viewModel.errorMessage {
                        Text(error)
                            .foregroundColor(.red)
                            .font(.caption)
                            .padding()
                    }
                    
                    Spacer()
                    
                    DSButton("Generate Plan with AI", icon: "wand.and.stars", isLoading: viewModel.isLoading, isDisabled: viewModel.title.isEmpty) {
                        viewModel.createGoal()
                    }
                    .padding()
                }
            }
            .navigationTitle("New Goal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .onChangeCompat(of: viewModel.isDismissed) { dismissed in
                if dismissed {
                    dismiss()
                }
            }
        }
    }
}

#Preview {
    GoalInputView(viewModel: {
        let mockRepo = MockGoalRepository()
        let geminiService = GeminiService.liveValue
        let useCase = CreateGoalUseCase(repository: mockRepo, geminiService: geminiService, notificationManager: NotificationManager())
        return GoalInputViewModel(createGoalUseCase: useCase)
    }())
}
