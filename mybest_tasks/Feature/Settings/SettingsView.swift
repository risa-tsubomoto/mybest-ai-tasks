import SwiftUI
import DesignSystem
import MyBestAITasksCore

/// アプリの設定画面。
struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 32) {
                    // アプリロゴとバージョン
                    VStack(spacing: 16) {
                        Image("icon")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                        
                        Text("mybest_tasks")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(DesignSystem.Colors.text)
                        
                        Text("Version 1.0.0")
                            .font(.caption)
                            .foregroundColor(DesignSystem.Colors.text.opacity(0.6))
                    }
                    .padding(.top, 40)
                    
                    // 設定セクション
                    VStack(spacing: 16) {
                        WorkHoursSettingsCard()
                        
                        DSCard {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("アプリについて")
                                    .font(.headline)
                                    .foregroundColor(DesignSystem.Colors.text)
                                
                                Text("AI駆動の目標管理アプリ。Gemini APIを使用してタスクを自動生成し、マイルストーンで進捗を可視化します。")
                                    .font(.caption)
                                    .foregroundColor(DesignSystem.Colors.text.opacity(0.7))
                            }
                        }
                        
                        DSCard {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("開発者")
                                    .font(.headline)
                                    .foregroundColor(DesignSystem.Colors.text)
                                
                                Text("Built with ❤️ using SwiftUI & Gemini AI")
                                    .font(.caption)
                                    .foregroundColor(DesignSystem.Colors.text.opacity(0.7))
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .background(DesignSystem.Colors.background)
            .navigationTitle("設定")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("閉じる") {
                        dismiss()
                    }
                    .foregroundColor(DesignSystem.Colors.primary)
                }
            }
        }
    }
}

#Preview {
    SettingsView()
}




