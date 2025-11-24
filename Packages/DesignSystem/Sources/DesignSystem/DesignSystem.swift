import SwiftUI

public struct DesignSystem {
    public struct Colors {
        public static let background = Color("Background")
        public static let primary = Color("AppPrimary")
        public static let secondary = Color("AppSecondary")
        public static let text = Color.primary
        public static let cardBackground = Color.gray.opacity(0.1)
    }
    
    public struct Spacing {
        public static let small: CGFloat = 8
        public static let medium: CGFloat = 16
        public static let large: CGFloat = 24
    }
    
    public struct CornerRadius {
        public static let card: CGFloat = 16
        public static let button: CGFloat = 12
    }
}

public extension View {
    func cardStyle() -> some View {
        self
            .background(DesignSystem.Colors.cardBackground)
            .cornerRadius(DesignSystem.CornerRadius.card)
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
    
    func premiumButtonStyle() -> some View {
        self
            .padding()
            .background(LinearGradient(gradient: Gradient(colors: [DesignSystem.Colors.primary, DesignSystem.Colors.secondary]), startPoint: .leading, endPoint: .trailing))
            .foregroundColor(.white)
            .cornerRadius(DesignSystem.CornerRadius.button)
            .shadow(color: DesignSystem.Colors.primary.opacity(0.3), radius: 5, x: 0, y: 3)
    }
}
