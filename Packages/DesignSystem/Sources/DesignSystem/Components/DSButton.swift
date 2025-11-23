import SwiftUI

/// プレミアムスタイルのボタンコンポーネント。
public struct DSButton: View {
    let title: String
    let icon: String?
    let isLoading: Bool
    let isDisabled: Bool
    let action: () -> Void
    
    public init(_ title: String, icon: String? = nil, isLoading: Bool = false, isDisabled: Bool = false, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.isLoading = isLoading
        self.isDisabled = isDisabled
        self.action = action
    }
    
    public var body: some View {
        Button(action: action) {
            HStack {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Text(title)
                        .fontWeight(.bold)
                    if let icon = icon {
                        Image(systemName: icon)
                    }
                }
            }
            .frame(maxWidth: .infinity)
        }
        .premiumButtonStyle()
        .disabled(isDisabled || isLoading)
        .opacity(isDisabled ? 0.6 : 1.0)
    }
}
