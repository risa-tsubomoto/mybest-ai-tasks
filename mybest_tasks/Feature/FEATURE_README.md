# Feature Layer (Feature)

このディレクトリは、ユーザーインターフェース（UI）と画面ごとのプレゼンテーションロジックを含みます。
機能（Feature）ごとにサブディレクトリで分割されています。

## 🏗 アーキテクチャ: MVVM

各機能は **Model-View-ViewModel (MVVM)** パターンに従って実装されています。

- **View (SwiftUI)**:
  - 画面のレイアウトと表示を担当。
  - `ViewModel` を `@StateObject` または `@ObservedObject` として持ち、状態の変化を監視して画面を更新します。
  - ロジックは持たず、ユーザー操作は `ViewModel` のメソッドを呼び出すことで処理します。

- **ViewModel**:
  - 画面の状態（State）を保持し、Viewに公開します（`@Published` プロパティ）。
  - `Core/Domain` 層の `UseCase` を実行し、その結果に基づいて状態を更新します。
  - UIロジック（バリデーション、エラーハンドリングなど）を担当します。

## 📁 ディレクトリ構成

- **GoalList**: 目標一覧画面。
- **GoalCreation**: 目標作成画面（AI生成機能含む）。
- **GoalDetail**: 目標詳細・タスク管理画面。

## 📦 依存関係
- `Core/Domain`: ビジネスロジックを実行するために使用。
- `Core/Model`: データを表示するために使用。
- `DesignSystem` (Package): UIコンポーネントを使用。
