import SwiftUI

extension View {
    @ViewBuilder
    public func onChangeCompat<V: Equatable>(of value: V, perform action: @escaping (V) -> Void) -> some View {
        if #available(iOS 17.0, macOS 14.0, *) {
            self.onChange(of: value) { _, newValue in
                action(newValue)
            }
        } else {
            self.onChange(of: value, perform: action)
        }
    }
}
