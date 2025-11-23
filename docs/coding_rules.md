# コーディングルール

## SwiftUI View 実装ルール

1.  **プレビューの必須実装**
    - View を実装する際は、必ず `#Preview` (または `PreviewProvider`) を実装すること。
    - プレビューでは、可能な限り実際のデータに近いダミーデータを使用し、View の状態を確認できるようにすること。

2.  **View と ViewModel のファイル分離**
    - View と ViewModel は別々のファイルに定義すること。
    - ファイル名は `[FeatureName]View.swift` および `[FeatureName]ViewModel.swift` とすること。
    - 同一ファイル内に `class ViewModel` を定義しないこと。
