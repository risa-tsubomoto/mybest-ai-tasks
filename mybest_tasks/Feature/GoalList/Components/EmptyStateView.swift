import SwiftUI

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image("icon")
                .resizable()
                .scaledToFit()
                .frame(width: 120, height: 120)
                .opacity(0.8)
            
            Text("目標を追加して\n始めましょう！")
                .font(.title2)
                .multilineTextAlignment(.center)
                .foregroundColor(DesignSystem.Colors.text.opacity(0.7))
        }
        .padding(40)
    }
}

#Preview {
    EmptyStateView()
        .background(DesignSystem.Colors.background)
}
