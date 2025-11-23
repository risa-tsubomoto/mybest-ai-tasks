# DesignSystem Package

アプリケーション全体で統一されたデザインを提供するためのUIコンポーネントライブラリです。
Swift Package として独立しており、アプリ本体からインポートして使用します。

## 🎨 デザイン定数 (DesignSystem)

`DesignSystem` 構造体を通じて、色、スペース、角丸などの定数にアクセスできます。

```swift
import DesignSystem

// 使用例
Text("Hello")
    .foregroundColor(DesignSystem.Colors.primary)
    .padding(DesignSystem.Spacing.medium)
```

## 🧩 UIコンポーネント

- **DSButton**:
  - プレミアムなスタイルのボタン。
  - ローディング状態、無効化状態、アイコン表示をサポート。
  
- **DSCard**:
  - コンテンツをカード状のコンテナで囲むラッパービュー。
  - 統一された影と角丸を提供。

- **DSTextField**:
  - スタイル適用済みのテキスト入力フィールド。

## 🛠 Extensions

- **View+Extensions**:
  - `.cardStyle()`: 任意のViewをカード化する修飾子。
  - `.premiumButtonStyle()`: ボタンにプレミアムスタイルを適用する修飾子。
