import SwiftUI
import MyBestAITasksCore
import DesignSystem

struct ApiKeyInputView: View {
    @Binding var apiKey: String
    @State private var text: String = ""
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Welcome to GoalCrusher")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Enter your Gemini API Key to unlock AI powers.")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
            
            SecureField("API Key", text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
                .onSubmit {
                    saveKey()
                }
            
            DSButton("Save Key", isDisabled: text.isEmpty) {
                saveKey()
            }
            
            Link("Get API Key", destination: URL(string: "https://aistudio.google.com/app/apikey")!)
                .font(.footnote)
        }
        .padding()
        .cardStyle()
        .padding()
    }
    
    private func saveKey() {
        guard !text.isEmpty else { return }
        KeychainHelper.shared.save(text, for: "geminiApiKey")
        apiKey = text
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State private var apiKey = ""
        
        var body: some View {
            ApiKeyInputView(apiKey: $apiKey)
        }
    }
    
    return PreviewWrapper()
}
