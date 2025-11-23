import SwiftUI

/// スタイル適用済みのテキストフィールドコンポーネント。
public struct DSTextField: View {
    let placeholder: String
    @Binding var text: String
    
    public init(_ placeholder: String, text: Binding<String>) {
        self.placeholder = placeholder
        self._text = text
    }
    
    public var body: some View {
        TextField(placeholder, text: $text)
            .padding()
            .background(DesignSystem.Colors.cardBackground)
            .cornerRadius(8)
    }
}
