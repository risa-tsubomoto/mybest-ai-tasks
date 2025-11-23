# mybest_tasks

AI駆動の目標管理アプリ。Gemini APIを使用してタスクを自動生成し、マイルストーンで進捗を可視化します。

## 主な機能

- 🎯 **AI目標分解**: Gemini APIが目標を具体的なタスクに分解
- 📊 **自動マイルストーン**: タスクが5個以上の場合、AIが自動でマイルストーンを提案
- 📈 **進捗可視化**: タスクベース & マイルストーンベースの進捗表示
- ✅ **シンプルなUI**: タスクをチェックするだけで進捗が自動更新
- 🎨 **モダンデザイン**: オレンジ×ダークグレーのプレミアムテーマ

## 技術スタック

- **UI**: SwiftUI
- **データ永続化**: SwiftData
- **アーキテクチャ**: Clean Architecture + MVVM
- **AI統合**: Gemini 1.5 Flash API
- **最小iOS**: 17.0+

## プロジェクト構造

```
mybest_tasks/
├── Core/
│   ├── Model/           # データモデル (Goal, GoalTask, Milestone)
│   ├── Data/            # データソース & リポジトリ
│   │   ├── DataSources/ # GeminiService
│   │   └── Repositories/# GoalRepository
│   ├── Domain/          # ユースケース & プロトコル
│   └── DesignSystem/    # デザインシステム (色、コンポーネント)
├── Feature/
│   ├── GoalList/        # 目標一覧画面
│   ├── GoalDetail/      # 目標詳細画面
│   │   └── Components/  # ProgressCard, MilestoneSection, TaskRowView
│   └── GoalCreation/    # 目標作成画面
└── Packages/
    └── DesignSystem/    # (旧) 現在は Core/DesignSystem に統合
```

## セットアップ

1. **Gemini API キーの取得**
   - [Google AI Studio](https://aistudio.google.com/app/apikey) でAPIキーを取得

2. **プロジェクトを開く**
   ```bash
   cd mybest_tasks
   open mybest_tasks.xcodeproj
   ```

3. **ビルド & 実行**
   - Xcode で `Cmd + R`
   - 初回起動時にAPIキーを入力

## 使い方

### 目標の作成
1. 「+」ボタンをタップ
2. 目標と期限を入力
3. 「Generate Plan with AI」をタップ
4. AIがタスク（とマイルストーン）を自動生成

### 進捗の確認
- 目標詳細画面で進捗カードを確認
- タスクベース進捗: 完了タスク数 / 全タスク数
- マイルストーン進捗: 完了マイルストーン数 / 全マイルストーン数

### タスクの完了
- タスクの左側のチェックボックスをタップ
- 進捗が自動更新される

## デザインシステム

### カラーテーマ
- **背景**: ダークグレー (`Color(white: 0.25)`)
- **プライマリ**: 鮮やかなオレンジ
- **セカンダリ**: コーラルレッド
- **テキスト**: 白
- **カード**: より濃いグレー

### コンポーネント
- `DSButton`: グラデーションボタン
- `DSCard`: カードコンテナ
- `DSTextField`: スタイル付きテキストフィールド
- `ProgressCard`: 進捗表示カード
- `MilestoneSection`: マイルストーンセクション

## アーキテクチャ

### データフロー
```
View → ViewModel → UseCase → Repository → SwiftData
                        ↓
                  GeminiService (AI)
```

### 主要コンポーネント

#### Model Layer
- `Goal`: 目標（タスクとマイルストーンを含む）
- `GoalTask`: 個別タスク
- `Milestone`: マイルストーン（タスクをグループ化）

#### Repository Pattern
- `GoalRepository`: SwiftDataを使用したCRUD操作
- `GoalRepositoryProtocol`: テスト用プロトコル

#### UseCase Pattern
- `CreateGoalUseCase`: AI生成を含む目標作成
- `ToggleTaskStatusUseCase`: タスク完了状態の切り替え

## 開発

### 新しいコンポーネントの追加
1. `Core/DesignSystem/Components/` に配置
2. `#Preview` を追加
3. Xcodeのキャンバスで確認

### 新しいFeatureの追加
1. `Feature/` 配下に新しいディレクトリを作成
2. View, ViewModel, Components を配置
3. Clean Architectureの原則に従う

## ライセンス

MIT License
