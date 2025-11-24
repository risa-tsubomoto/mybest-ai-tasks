# アーキテクチャとディレクトリ構成

## 📐 全体アーキテクチャ

このプロジェクトは **Clean Architecture** と **MVVM (Model-View-ViewModel)** パターンを組み合わせた、マルチモジュール構成のiOSアプリケーションです。

### アーキテクチャの特徴

- **レイヤー分離**: ビジネスロジック、データアクセス、UIを明確に分離
- **依存性の方向**: 外側のレイヤー（UI）から内側のレイヤー（Domain）への単方向依存
- **テスタビリティ**: プロトコルベースの設計により、モックやスタブを使ったテストが容易
- **モジュール化**: Swift Package Managerを使用した独立したモジュール構成

### データフロー

```
┌─────────────────────────────────────────────────────────┐
│                    Presentation Layer                    │
│  ┌──────────┐         ┌──────────────┐                 │
│  │   View   │ ◄────── │  ViewModel   │                 │
│  │ (SwiftUI)│         │ (@Published) │                 │
│  └──────────┘         └──────┬───────┘                 │
└────────────────────────────────┼──────────────────────────┘
                                 │
┌────────────────────────────────┼──────────────────────────┐
│                    Domain Layer│                          │
│                         ┌──────▼────────┐                │
│                         │   UseCase     │                │
│                         │ (ビジネスロジック) │                │
│                         └──────┬────────┘                │
└────────────────────────────────┼──────────────────────────┘
                                 │
┌────────────────────────────────┼──────────────────────────┐
│                     Data Layer │                          │
│                         ┌──────▼────────┐                │
│                         │  Repository   │                │
│                         │  (Protocol)   │                │
│                         └──────┬────────┘                │
│                                │                          │
│              ┌─────────────────┼─────────────────┐       │
│              │                 │                 │       │
│      ┌───────▼────────┐ ┌─────▼──────┐  ┌──────▼─────┐ │
│      │   SwiftData    │ │  Gemini    │  │  Calendar  │ │
│      │  (永続化)       │ │  Service   │  │  Service   │ │
│      └────────────────┘ └────────────┘  └────────────┘ │
└─────────────────────────────────────────────────────────┘
```

## 🗂 ディレクトリ構成

```
mybest_tasks/
├── Packages/                          # Swift Packages
│   ├── MyBestAITasksCore/            # コアビジネスロジックパッケージ
│   │   └── Sources/MyBestAITasksCore/
│   │       ├── Model/                # データモデル層
│   │       │   ├── Enums/           # 列挙型定義
│   │       │   │   ├── TaskStatus.swift
│   │       │   │   ├── TaskRecurrence.swift
│   │       │   │   └── Weekday.swift
│   │       │   ├── Goal.swift       # 目標モデル (@Model class)
│   │       │   ├── GoalTask.swift   # タスクモデル (@Model class)
│   │       │   └── Milestone.swift  # マイルストーンモデル (@Model class)
│   │       │
│   │       ├── Data/                # データアクセス層
│   │       │   ├── DataSources/     # 外部データソース
│   │       │   │   ├── GeminiService.swift    # AI API連携
│   │       │   │   ├── CalendarService.swift  # カレンダー連携
│   │       │   │   └── CalendarActor.swift    # カレンダー状態管理 (actor)
│   │       │   ├── Repositories/    # リポジトリパターン
│   │       │   │   └── GoalRepository.swift   # 目標データアクセス (class)
│   │       │   └── Mocks/           # テスト用モック
│   │       │       └── MockGoalRepository.swift
│   │       │
│   │       ├── Domain/              # ドメイン層（ビジネスロジック）
│   │       │   ├── CreateGoalUseCase.swift      # 目標作成ユースケース (struct)
│   │       │   └── ToggleTaskStatusUseCase.swift # タスク状態変更 (struct)
│   │       │
│   │       └── Infrastructure/      # インフラストラクチャ層
│   │           ├── Logger/
│   │           │   └── LoggerClient.swift       # ロギング (struct)
│   │           ├── Notification/
│   │           │   └── NotificationManager.swift # 通知管理 (class)
│   │           └── Security/
│   │               └── KeychainHelper.swift      # Keychain操作 (class)
│   │
│   └── DesignSystem/                 # デザインシステムパッケージ
│       └── Sources/DesignSystem/
│           ├── DesignSystem.swift    # デザイントークン (struct)
│           ├── View+Extensions.swift # View拡張
│           ├── Components/           # 再利用可能UIコンポーネント
│           │   ├── DSButton.swift   # ボタンコンポーネント (struct)
│           │   ├── DSCard.swift     # カードコンポーネント (struct)
│           │   └── DSTextField.swift # テキストフィールド (struct)
│           └── Resources/            # リソース（色、画像など）
│               └── Colors.xcassets
│
└── mybest_tasks/                     # メインアプリケーション
    ├── mybest_tasksApp.swift        # アプリエントリーポイント
    │
    └── Feature/                      # 機能別UI層
        ├── FEATURE_README.md        # Feature層の説明
        │
        ├── Common/                   # 共通コンポーネント
        │   └── LoadingView.swift
        │
        ├── GoalList/                 # 目標一覧機能
        │   ├── GoalListView.swift           # View (struct)
        │   ├── GoalListViewModel.swift      # ViewModel (class)
        │   └── Components/
        │       ├── GoalCardView.swift
        │       ├── EmptyStateView.swift
        │       └── ApiKeyInputView.swift
        │
        ├── GoalCreation/             # 目標作成機能
        │   ├── GoalInputView.swift          # View (struct)
        │   └── GoalInputViewModel.swift     # ViewModel (class)
        │
        ├── GoalDetail/               # 目標詳細機能
        │   ├── GoalDetailView.swift         # View (struct)
        │   ├── GoalDetailViewModel.swift    # ViewModel (class)
        │   └── Components/
        │       ├── ProgressCard.swift       # 進捗カード
        │       ├── MilestoneSection.swift   # マイルストーンセクション
        │       └── TaskRowView.swift        # タスク行
        │
        ├── GoalChat/                 # AI チャット機能
        │   ├── GoalChatView.swift           # View (struct)
        │   └── GoalChatViewModel.swift      # ViewModel (class)
        │
        └── Settings/                 # 設定機能
            ├── SettingsView.swift           # View (struct)
            └── Components/
                ├── WorkHoursSettingsCard.swift
                └── WeekdayTimeSettings.swift
```

## 🏗 各レイヤーの責務

### 1. Model Layer (`MyBestAITasksCore/Model/`)

**責務**: アプリケーションのコアデータ構造を定義

- **データモデル**: `Goal`, `GoalTask`, `Milestone`
  - SwiftDataの `@Model` マクロを使用
  - `class` として定義（参照型、SwiftDataの要件）
  - リレーションシップを `@Relationship` で定義
  
- **列挙型**: `TaskStatus`, `TaskRecurrence`, `Weekday`
  - `enum` として定義
  - 独立したファイルとして `Enums/` ディレクトリに配置

### 2. Data Layer (`MyBestAITasksCore/Data/`)

**責務**: データの取得、保存、外部サービスとの連携

#### DataSources
- **GeminiService**: AI APIとの通信（タスク生成）
- **CalendarService**: iOS カレンダーとの連携
- **CalendarActor**: カレンダーアクセス状態の並行管理

#### Repositories
- **GoalRepository**: SwiftDataを使用したCRUD操作
- **GoalRepositoryProtocol**: テスト容易性のための抽象化

### 3. Domain Layer (`MyBestAITasksCore/Domain/`)

**責務**: ビジネスロジックの実装

- **UseCase パターン**: 各ビジネスユースケースを独立したstructとして実装
- **CreateGoalUseCase**: AI生成を含む目標作成フロー
- **ToggleTaskStatusUseCase**: タスク完了状態の切り替えロジック

### 4. Infrastructure Layer (`MyBestAITasksCore/Infrastructure/`)

**責務**: 横断的関心事の実装

- **Logger**: アプリケーション全体のロギング
- **NotificationManager**: プッシュ通知管理
- **KeychainHelper**: 機密情報（APIキーなど）の安全な保存

### 5. Presentation Layer (`mybest_tasks/Feature/`)

**責務**: UIとユーザーインタラクション

- **MVVM パターン**:
  - **View (struct)**: SwiftUIビュー、UIのみを担当
  - **ViewModel (class)**: 状態管理、UseCaseの実行、`ObservableObject`
  
- **機能別分割**: 各機能を独立したディレクトリで管理

### 6. Design System (`DesignSystem` Package)

**責務**: 一貫したUIデザインの提供

- **デザイントークン**: 色、スペーシング、角丸などの定数
- **再利用可能コンポーネント**: `DSButton`, `DSCard`, `DSTextField`
- **Atomic Design**: 小さなコンポーネントから大きなコンポーネントを構築

## 🔄 依存関係の管理

### パッケージ間の依存

```
┌─────────────────┐
│  mybest_tasks   │ (Main App)
│   (Feature/)    │
└────────┬────────┘
         │ depends on
         ├──────────────┬──────────────┐
         │              │              │
    ┌────▼────────┐ ┌──▼──────────┐  │
    │DesignSystem │ │MyBestAITasks│  │
    │             │ │    Core     │  │
    └─────────────┘ └──────┬──────┘  │
                           │         │
                    ┌──────▼─────────▼──┐
                    │  swift-dependencies│
                    │  (外部ライブラリ)     │
                    └────────────────────┘
```

### 依存性注入

- **Dependencies ライブラリ**: Point-Free社の `swift-dependencies` を使用
- **@Dependency マクロ**: 依存関係を宣言的に注入
- **テスト容易性**: モックへの差し替えが容易

## 🎯 設計原則

### SOLID 原則の適用

1. **Single Responsibility Principle (単一責任の原則)**
   - 各クラス/構造体は1つの責務のみを持つ
   - 例: `CreateGoalUseCase` は目標作成のみ、`GoalRepository` はデータアクセスのみ

2. **Open/Closed Principle (開放/閉鎖の原則)**
   - プロトコルを使用して拡張に開き、修正に閉じる
   - 例: `GoalRepositoryProtocol` により実装を差し替え可能

3. **Liskov Substitution Principle (リスコフの置換原則)**
   - プロトコル準拠型は基底型と置き換え可能
   - 例: `MockGoalRepository` は `GoalRepositoryProtocol` として使用可能

4. **Interface Segregation Principle (インターフェース分離の原則)**
   - 必要最小限のインターフェースのみを公開
   - 例: 各UseCaseは特定の操作のみを公開

5. **Dependency Inversion Principle (依存性逆転の原則)**
   - 具象ではなく抽象（プロトコル）に依存
   - 例: ViewModelはRepositoryの具象クラスではなくプロトコルに依存

### その他の設計原則

- **DRY (Don't Repeat Yourself)**: 共通ロジックをUseCaseやRepositoryに集約
- **KISS (Keep It Simple, Stupid)**: シンプルで理解しやすいコード
- **YAGNI (You Aren't Gonna Need It)**: 必要になるまで実装しない

## 📦 モジュール分割の利点

### MyBestAITasksCore パッケージ

**利点**:
- ビジネスロジックの再利用性向上
- UIから独立したテストが可能
- ビルド時間の短縮（変更がない場合は再ビルド不要）
- 明確な境界による責務の分離

**含まれるもの**:
- データモデル
- ビジネスロジック（UseCase）
- データアクセス（Repository, DataSource）
- インフラストラクチャ

### DesignSystem パッケージ

**利点**:
- デザインの一貫性保証
- コンポーネントの再利用
- デザイン変更時の影響範囲の限定
- 独立したプレビュー・テストが可能

**含まれるもの**:
- デザイントークン（色、スペーシングなど）
- 再利用可能UIコンポーネント
- View拡張

## 🔍 コード組織化のルール

### ファイル構成

1. **1ファイル1型**: 各クラス/構造体/列挙型は独立したファイルに配置
2. **ファイル名 = 型名**: `Goal.swift` には `Goal` クラスのみ
3. **関連する拡張は同じファイル**: 例: `Goal` の計算プロパティは `Goal.swift` 内の `extension` に記述

### ディレクトリ構成

1. **機能別分割**: Feature層は機能ごとにディレクトリを分ける
2. **レイヤー別分割**: Core層はレイヤー（Model, Data, Domain）ごとに分ける
3. **Componentsディレクトリ**: 再利用可能なUIコンポーネントは `Components/` に配置

### 命名規則

1. **View**: `〜View.swift` (例: `GoalListView`)
2. **ViewModel**: `〜ViewModel.swift` (例: `GoalListViewModel`)
3. **UseCase**: `〜UseCase.swift` (例: `CreateGoalUseCase`)
4. **Repository**: `〜Repository.swift` (例: `GoalRepository`)
5. **Service**: `〜Service.swift` (例: `GeminiService`)

## 🧪 テスト戦略

### テスタビリティの確保

1. **プロトコルベース設計**: 依存関係をプロトコルで抽象化
2. **依存性注入**: `@Dependency` マクロによる注入
3. **モックの提供**: `MockGoalRepository` などのモック実装

### テストの種類

1. **ユニットテスト**: UseCase, Repository, ViewModelのロジック
2. **統合テスト**: Repository と SwiftData の連携
3. **UIテスト**: 主要なユーザーフロー

## 📚 参考資料

- [Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html) by Robert C. Martin
- [MVVM Pattern](https://docs.microsoft.com/en-us/xamarin/xamarin-forms/enterprise-application-patterns/mvvm)
- [Swift Package Manager](https://swift.org/package-manager/)
- [SwiftData Documentation](https://developer.apple.com/documentation/swiftdata)
