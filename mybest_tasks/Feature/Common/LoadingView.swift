import SwiftUI
import DesignSystem

/// AI生成中のローディング画面。
struct LoadingView: View {
    var body: some View {
        VStack(spacing: 24) {
            Image("icon")
                .resizable()
                .scaledToFit()
                .frame(width: 150, height: 150)
            
            ProgressView()
                .tint(DesignSystem.Colors.primary)
                .scaleEffect(1.5)
            
            Text("AIがプランを作成中...")
                .font(.headline)
                .foregroundColor(DesignSystem.Colors.text.opacity(0.7))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(DesignSystem.Colors.background)
    }
}

#Preview {
    LoadingView()
}
