import SwiftUI

/// 一貫したカードスタイルのコンテナビュー。
public struct DSCard<Content: View>: View {
    let content: Content
    
    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    public var body: some View {
        content
            .padding()
            .cardStyle()
    }
}
