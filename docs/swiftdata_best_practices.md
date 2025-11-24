# SwiftData ベストプラクティス

このドキュメントでは、SwiftDataを使って複雑なテーブル構造（RDBライク）を管理する際のベストプラクティスを、プロジェクトの実例を交えて説明します。

## 📋 目次

1. [モデル設計の基本原則](#モデル設計の基本原則)
2. [リレーションシップの定義](#リレーションシップの定義)
3. [複雑なリレーションシップのパターン](#複雑なリレーションシップのパターン)
4. [モデルの組織化](#モデルの組織化)
5. [クエリのベストプラクティス](#クエリのベストプラクティス)
6. [データの整合性を保つ](#データの整合性を保つ)
7. [パフォーマンス最適化](#パフォーマンス最適化)
8. [マイグレーション戦略](#マイグレーション戦略)
9. [テストのベストプラクティス](#テストのベストプラクティス)
10. [実践的な設計例](#実践的な設計例)

## 🏗 モデル設計の基本原則

### 1つのモデル = 1つのファイル

SwiftDataモデルは、各エンティティを独立したファイルとして管理します。

```swift
// ❌ 悪い例: 複数のモデルを1ファイルに
// Models.swift
@Model class Goal { ... }
@Model class GoalTask { ... }
@Model class Milestone { ... }

// ✅ 良い例: 1モデル1ファイル
// Goal.swift
@Model
public final class Goal {
    public var id: UUID
    public var title: String
    public var deadline: Date
    
    public init(id: UUID = UUID(), title: String, deadline: Date) {
        self.id = id
        self.title = title
        self.deadline = deadline
    }
}

// GoalTask.swift
@Model
public final class GoalTask {
    public var id: UUID
    public var title: String
    
    public init(id: UUID = UUID(), title: String) {
        self.id = id
        self.title = title
    }
}
```

**理由**:
- コードの可読性向上
- ファイル検索が容易
- マージコンフリクトの軽減
- 責務の明確化

### `@Model` マクロの要件

SwiftDataモデルは以下の要件を満たす必要があります：

```swift
@Model  // ✅ 必須: SwiftDataマクロ
public final class Goal {  // ✅ 推奨: final class
    // ✅ stored properties（格納プロパティ）のみ
    public var id: UUID
    public var title: String
    
    // ✅ 初期化子が必要
    public init(id: UUID, title: String) {
        self.id = id
        self.title = title
    }
}
```

**重要なポイント**:
- `class` である必要がある（`struct` は不可）
- `final` を付けることを推奨（継承を防ぐ）
- すべてのプロパティは格納プロパティ
- 計算プロパティは `extension` で定義

## 🔗 リレーションシップの定義

### 基本的なリレーションシップ

SwiftDataでは、`@Relationship` マクロを使ってRDBの外部キー制約のような関係を定義します。

#### プロジェクトの実例: Goal ↔ GoalTask（1対多）

```swift
// Goal.swift (親エンティティ)
@Model
public final class Goal {
    public var id: UUID
    public var title: String
    public var deadline: Date
    
    // 1対多のリレーション: 1つのGoalは複数のGoalTaskを持つ
    @Relationship(deleteRule: .cascade, inverse: \GoalTask.goal)
    public var tasks: [GoalTask]
    
    // 1対多のリレーション: 1つのGoalは複数のMilestoneを持つ
    @Relationship(deleteRule: .cascade, inverse: \Milestone.goal)
    public var milestones: [Milestone]
    
    public init(id: UUID = UUID(), title: String, deadline: Date, tasks: [GoalTask] = [], milestones: [Milestone] = []) {
        self.id = id
        self.title = title
        self.deadline = deadline
        self.tasks = tasks
        self.milestones = milestones
    }
}

// GoalTask.swift (子エンティティ)
@Model
public final class GoalTask: @unchecked Sendable {
    public var id: UUID
    public var title: String
    
    // 多対1のリレーション: 1つのGoalTaskは1つのGoalに属する
    public var goal: Goal?  // 逆参照（inverse）
    
    public init(id: UUID = UUID(), title: String) {
        self.id = id
        self.title = title
    }
}
```

### `@Relationship` のパラメータ

```swift
@Relationship(
    deleteRule: .cascade,      // 削除ルール
    inverse: \GoalTask.goal    // 逆参照のキーパス
)
public var tasks: [GoalTask]
```

#### 削除ルール（deleteRule）

| ルール | 説明 | RDB相当 | 使用例 |
|---|---|---|---|
| `.cascade` | 親を削除すると子も削除 | `ON DELETE CASCADE` | Goal削除時にTaskも削除 |
| `.nullify` | 親を削除すると子の参照を `nil` に | `ON DELETE SET NULL` | User削除時にPostは残す |
| `.deny` | 子が存在する場合、親の削除を拒否 | 制約違反エラー | 注文がある顧客は削除不可 |

#### 逆参照（inverse）

双方向リレーションシップを自動管理するためのキーパス：

```swift
// 親側
@Relationship(inverse: \GoalTask.goal)
var tasks: [GoalTask]

// 子側
var goal: Goal?  // inverseで指定されたプロパティ
```

**利点**:
- 手動で両方を設定する必要がない
- データの整合性が自動的に保たれる
- メモリ効率が良い

## 🔀 複雑なリレーションシップのパターン

### パターン1: 1対多（One-to-Many）

最も一般的なパターン。1つの親エンティティが複数の子エンティティを持つ。

```swift
// 例: 1つのUserが複数のPostを持つ
@Model
class User {
    var id: UUID
    var name: String
    var email: String
    
    @Relationship(deleteRule: .cascade, inverse: \Post.author)
    var posts: [Post]
    
    init(id: UUID = UUID(), name: String, email: String, posts: [Post] = []) {
        self.id = id
        self.name = name
        self.email = email
        self.posts = posts
    }
}

@Model
class Post {
    var id: UUID
    var title: String
    var content: String
    var createdAt: Date
    
    var author: User?  // 逆参照
    
    init(id: UUID = UUID(), title: String, content: String, createdAt: Date = Date()) {
        self.id = id
        self.title = title
        self.content = content
        self.createdAt = createdAt
    }
}
```

**使用例**:
- ユーザーと投稿
- カテゴリーと商品
- プロジェクトとタスク

### パターン2: 多対多（Many-to-Many）

SwiftDataでは、中間エンティティを明示的に作成して多対多関係を実現します。

```swift
// 例: StudentとCourseの多対多関係
@Model
class Student {
    var id: UUID
    var name: String
    
    @Relationship(deleteRule: .cascade, inverse: \Enrollment.student)
    var enrollments: [Enrollment]
    
    init(id: UUID = UUID(), name: String, enrollments: [Enrollment] = []) {
        self.id = id
        self.name = name
        self.enrollments = enrollments
    }
}

@Model
class Course {
    var id: UUID
    var title: String
    var credits: Int
    
    @Relationship(deleteRule: .cascade, inverse: \Enrollment.course)
    var enrollments: [Enrollment]
    
    init(id: UUID = UUID(), title: String, credits: Int, enrollments: [Enrollment] = []) {
        self.id = id
        self.title = title
        self.credits = credits
        self.enrollments = enrollments
    }
}

// 中間エンティティ（結合テーブル）
@Model
class Enrollment {
    var id: UUID
    var enrolledAt: Date
    var grade: String?
    
    var student: Student?
    var course: Course?
    
    init(id: UUID = UUID(), enrolledAt: Date = Date(), grade: String? = nil) {
        self.id = id
        self.enrolledAt = enrolledAt
        self.grade = grade
    }
}
```

**使用例**:
- 学生と講座
- タグと記事
- ユーザーとグループ

**中間エンティティの利点**:
- 関係自体に属性を持たせられる（例: `enrolledAt`, `grade`）
- クエリが柔軟になる
- データの整合性が保たれる

### パターン3: 自己参照（Self-Referencing）

エンティティが自分自身を参照する場合。ツリー構造やグラフ構造に使用。

```swift
// 例: コメントの返信（ツリー構造）
@Model
class Comment {
    var id: UUID
    var text: String
    var createdAt: Date
    
    // 親コメント（このコメントが返信している元のコメント）
    var parentComment: Comment?
    
    // 子コメント（このコメントへの返信）
    @Relationship(deleteRule: .cascade, inverse: \Comment.parentComment)
    var replies: [Comment]
    
    init(id: UUID = UUID(), text: String, createdAt: Date = Date(), replies: [Comment] = []) {
        self.id = id
        self.text = text
        self.createdAt = createdAt
        self.replies = replies
    }
}
```

**使用例**:
- コメントとその返信
- カテゴリーの階層構造
- 組織図（上司と部下）

### パターン4: オプショナルリレーション

リレーションが必須でない場合。

```swift
@Model
class Task {
    var id: UUID
    var title: String
    
    // オプショナル: タスクは担当者がいない場合もある
    var assignee: User?
    
    init(id: UUID = UUID(), title: String) {
        self.id = id
        self.title = title
    }
}

@Model
class User {
    var id: UUID
    var name: String
    
    @Relationship(deleteRule: .nullify, inverse: \Task.assignee)
    var assignedTasks: [Task]
    
    init(id: UUID = UUID(), name: String, assignedTasks: [Task] = []) {
        self.id = id
        self.name = name
        self.assignedTasks = assignedTasks
    }
}
```

### パターン5: 継承 vs コンポジション（重要）

SwiftDataでは、**継承よりもコンポジション（合成）を強く推奨**します。

#### ❌ 継承を使った設計（非推奨）

```swift
// SwiftDataでは継承は推奨されない
@Model
class JobPosting {
    var id: UUID
    var title: String
    var company: String
}

// ❌ これは避けるべき
@Model
class FavoriteJobPosting: JobPosting {
    var favoritedAt: Date
}
```

**問題点**:
- SwiftDataでの継承サポートは限定的
- クエリが複雑になる
- データの重複が発生する可能性
- 柔軟性が低い（お気に入りと閲覧履歴を同時に管理できない）

#### ✅ コンポジションを使った設計（推奨）

中間エンティティを使って、リレーションシップで関係を表現します。

##### 実例: 求人のお気に入りと閲覧履歴

```swift
// JobPosting.swift - 求人エンティティ
@Model
public final class JobPosting {
    public var id: UUID
    public var title: String
    public var company: String
    public var description: String
    public var salary: String?
    public var location: String
    public var postedAt: Date
    
    // お気に入りとの関連
    @Relationship(deleteRule: .cascade, inverse: \FavoriteJob.jobPosting)
    public var favorites: [FavoriteJob]
    
    // 閲覧履歴との関連
    @Relationship(deleteRule: .cascade, inverse: \JobViewHistory.jobPosting)
    public var viewHistories: [JobViewHistory]
    
    public init(id: UUID = UUID(), title: String, company: String, description: String, salary: String? = nil, location: String, postedAt: Date = Date()) {
        self.id = id
        self.title = title
        self.company = company
        self.description = description
        self.salary = salary
        self.location = location
        self.postedAt = postedAt
    }
}

// FavoriteJob.swift - お気に入り求人（中間エンティティ）
@Model
public final class FavoriteJob {
    public var id: UUID
    public var favoritedAt: Date
    public var memo: String?  // お気に入り固有の情報
    public var tags: [String]  // カスタムタグ
    
    // 求人への参照
    public var jobPosting: JobPosting?
    
    // ユーザーへの参照（複数ユーザーがいる場合）
    public var user: User?
    
    public init(id: UUID = UUID(), favoritedAt: Date = Date(), memo: String? = nil, tags: [String] = []) {
        self.id = id
        self.favoritedAt = favoritedAt
        self.memo = memo
        self.tags = tags
    }
}

// JobViewHistory.swift - 閲覧履歴（中間エンティティ）
@Model
public final class JobViewHistory {
    public var id: UUID
    public var viewedAt: Date
    public var viewDuration: TimeInterval?  // 閲覧時間（秒）
    public var scrollDepth: Double?  // スクロール深度（0.0〜1.0）
    
    // 求人への参照
    public var jobPosting: JobPosting?
    
    // ユーザーへの参照
    public var user: User?
    
    public init(id: UUID = UUID(), viewedAt: Date = Date(), viewDuration: TimeInterval? = nil, scrollDepth: Double? = nil) {
        self.id = id
        self.viewedAt = viewedAt
        self.viewDuration = viewDuration
        self.scrollDepth = scrollDepth
    }
}

// User.swift - ユーザーエンティティ（オプション）
@Model
public final class User {
    public var id: UUID
    public var name: String
    public var email: String
    
    @Relationship(deleteRule: .cascade, inverse: \FavoriteJob.user)
    public var favoriteJobs: [FavoriteJob]
    
    @Relationship(deleteRule: .cascade, inverse: \JobViewHistory.user)
    public var viewHistories: [JobViewHistory]
    
    public init(id: UUID = UUID(), name: String, email: String, favoriteJobs: [FavoriteJob] = [], viewHistories: [JobViewHistory] = []) {
        self.id = id
        self.name = name
        self.email = email
        self.favoriteJobs = favoriteJobs
        self.viewHistories = viewHistories
    }
}
```

##### リレーションシップの図解

```
┌──────────────┐
│     User     │
│              │
│ - name       │
│ - email      │
└──────┬───────┘
       │ 1
       │
       ├─────────────────┬─────────────────┐
       │ *               │ *               │
┌──────▼──────────┐ ┌───▼──────────┐     │
│  FavoriteJob    │ │JobViewHistory│     │
│                 │ │              │     │
│ - favoritedAt   │ │ - viewedAt   │     │
│ - memo          │ │ - duration   │     │
│ - tags          │ │ - scrollDepth│     │
└────────┬────────┘ └──────┬───────┘     │
         │ *               │ *           │
         │                 │             │
         └─────────┬───────┘             │
                   │ 1                   │
            ┌──────▼──────────┐          │
            │   JobPosting    │          │
            │                 │          │
            │ - title         │          │
            │ - company       │          │
            │ - description   │          │
            │ - salary        │          │
            │ - location      │          │
            └─────────────────┘          │
```

##### 使用例

**お気に入りに追加**:

```swift
let jobPosting = JobPosting(
    title: "iOS Engineer",
    company: "Apple Inc.",
    description: "Build amazing apps...",
    location: "Cupertino, CA"
)

let favorite = FavoriteJob(
    memo: "給与が良い！福利厚生も充実",
    tags: ["iOS", "Swift", "大手企業"]
)

// リレーションシップを設定
favorite.jobPosting = jobPosting

modelContext.insert(jobPosting)
modelContext.insert(favorite)
try modelContext.save()
```

**お気に入り一覧を取得**:

```swift
// お気に入りした求人を取得（最近お気に入りした順）
let descriptor = FetchDescriptor<FavoriteJob>(
    sortBy: [SortDescriptor(\.favoritedAt, order: .reverse)]
)
let favorites = try modelContext.fetch(descriptor)

// 求人情報にアクセス
for favorite in favorites {
    if let job = favorite.jobPosting {
        print("\(job.title) at \(job.company)")
        print("お気に入り登録日: \(favorite.favoritedAt)")
        if let memo = favorite.memo {
            print("メモ: \(memo)")
        }
        print("タグ: \(favorite.tags.joined(separator: ", "))")
    }
}
```

**特定の求人がお気に入りかチェック**:

```swift
let jobId = UUID() // チェックしたい求人のID

let descriptor = FetchDescriptor<FavoriteJob>(
    predicate: #Predicate { favorite in
        favorite.jobPosting?.id == jobId
    }
)
let favorites = try modelContext.fetch(descriptor)
let isFavorite = !favorites.isEmpty
```

**閲覧履歴を記録**:

```swift
let jobPosting = /* 既存の求人 */
let viewHistory = JobViewHistory(
    viewDuration: 120.0,  // 2分間閲覧
    scrollDepth: 0.75     // 75%スクロール
)

viewHistory.jobPosting = jobPosting

modelContext.insert(viewHistory)
try modelContext.save()
```

**最近閲覧した求人を取得**:

```swift
var descriptor = FetchDescriptor<JobViewHistory>(
    sortBy: [SortDescriptor(\.viewedAt, order: .reverse)]
)
descriptor.fetchLimit = 10 // 最新10件

let recentViews = try modelContext.fetch(descriptor)

for view in recentViews {
    if let job = view.jobPosting {
        print("\(job.title) - 閲覧日時: \(view.viewedAt)")
        if let duration = view.viewDuration {
            print("閲覧時間: \(Int(duration))秒")
        }
    }
}
```

**タグで検索**:

```swift
let targetTag = "Swift"

let descriptor = FetchDescriptor<FavoriteJob>(
    predicate: #Predicate { favorite in
        favorite.tags.contains(targetTag)
    }
)
let swiftJobs = try modelContext.fetch(descriptor)
```

##### 計算プロパティで便利に

```swift
// JobPosting.swift の extension
extension JobPosting {
    /// この求人がお気に入りされているか
    public var isFavorited: Bool {
        !favorites.isEmpty
    }
    
    /// 最新のお気に入り登録日
    public var latestFavoritedAt: Date? {
        favorites.max(by: { $0.favoritedAt < $1.favoritedAt })?.favoritedAt
    }
    
    /// 閲覧回数
    public var viewCount: Int {
        viewHistories.count
    }
    
    /// 最終閲覧日時
    public var lastViewedAt: Date? {
        viewHistories.max(by: { $0.viewedAt < $1.viewedAt })?.viewedAt
    }
    
    /// 平均閲覧時間
    public var averageViewDuration: TimeInterval? {
        let durations = viewHistories.compactMap { $0.viewDuration }
        guard !durations.isEmpty else { return nil }
        return durations.reduce(0, +) / Double(durations.count)
    }
}
```

##### 代替パターン: フラグを使う方法（シンプルだが柔軟性が低い）

```swift
// JobPosting.swift
@Model
public final class JobPosting {
    public var id: UUID
    public var title: String
    public var company: String
    
    // お気に入りフラグ
    public var isFavorite: Bool
    public var favoritedAt: Date?
    
    // 閲覧済みフラグ
    public var isViewed: Bool
    public var lastViewedAt: Date?
    
    public init(id: UUID = UUID(), title: String, company: String, isFavorite: Bool = false, favoritedAt: Date? = nil, isViewed: Bool = false, lastViewedAt: Date? = nil) {
        self.id = id
        self.title = title
        self.company = company
        self.isFavorite = isFavorite
        self.favoritedAt = favoritedAt
        self.isViewed = isViewed
        self.lastViewedAt = lastViewedAt
    }
}
```

**このパターンの問題点**:
- 複数ユーザーに対応できない
- 履歴が1件しか保存できない
- 追加情報（メモ、タグなど）を持たせられない
- 拡張性が低い

##### まとめ: どちらのパターンを選ぶべきか

**中間エンティティ（推奨）を選ぶべき場合**:

- ✅ 複数ユーザーに対応する必要がある
- ✅ お気に入りや閲覧履歴に追加情報を持たせたい（メモ、タグ、閲覧時間など）
- ✅ 履歴を複数保存したい
- ✅ 将来的な拡張性が必要
- ✅ 統計情報を取りたい（お気に入り数、閲覧回数、平均閲覧時間など）

**フラグパターンを選ぶべき場合**:

- ✅ シングルユーザーアプリ
- ✅ シンプルなお気に入り機能のみ
- ✅ 追加情報が不要
- ✅ 履歴は最新の1件のみで十分

> **推奨**: ほとんどの場合、**中間エンティティパターン**を使うことをお勧めします。初期実装は少し複雑ですが、将来的な拡張性と柔軟性が高いためです。

## 📁 モデルの組織化


### ディレクトリ構造のベストプラクティス

```
MyBestAITasksCore/Sources/MyBestAITasksCore/
├── Model/
│   ├── Enums/                    # 列挙型を分離
│   │   ├── TaskStatus.swift      # enum TaskStatus { ... }
│   │   ├── TaskRecurrence.swift  # enum TaskRecurrence { ... }
│   │   └── Weekday.swift         # enum Weekday { ... }
│   │
│   ├── Goal.swift                # メインエンティティ
│   ├── GoalTask.swift            # 関連エンティティ
│   └── Milestone.swift           # 関連エンティティ
```

**組織化のルール**:

1. **列挙型は `Enums/` ディレクトリに分離**
   - モデルで使用する列挙型は独立したファイルに
   - 再利用性が高まる
   - モデルファイルがシンプルになる

2. **エンティティごとに1ファイル**
   - ファイル名 = クラス名
   - 例: `Goal.swift` には `Goal` クラスのみ

3. **関連する拡張は同じファイルに**
   - 計算プロパティやヘルパーメソッドは `extension` で定義

### プロジェクトの実例

#### Goal.swift

```swift
import Foundation
import SwiftData

/// 複数のタスクを含む、ユーザーの目標を表す。
@Model
public final class Goal {
    public var id: UUID
    public var title: String
    public var deadline: Date
    
    @Relationship(deleteRule: .cascade, inverse: \GoalTask.goal)
    public var tasks: [GoalTask]
    
    @Relationship(deleteRule: .cascade, inverse: \Milestone.goal)
    public var milestones: [Milestone]
    
    public var createdAt: Date
    public var startDate: Date?
    public var isCompleted: Bool
    
    public init(id: UUID = UUID(), title: String, deadline: Date, tasks: [GoalTask] = [], milestones: [Milestone] = [], createdAt: Date = Date(), startDate: Date? = nil, isCompleted: Bool = false) {
        self.id = id
        self.title = title
        self.deadline = deadline
        self.tasks = tasks
        self.milestones = milestones
        self.createdAt = createdAt
        self.startDate = startDate
        self.isCompleted = isCompleted
    }
}

// 計算プロパティは extension で定義
extension Goal {
    /// タスクベースの進捗（0.0〜1.0）。
    public var progress: Double {
        guard !tasks.isEmpty else { return 0 }
        let completed = tasks.filter { $0.status == .completed }.count
        return Double(completed) / Double(tasks.count)
    }
    
    /// マイルストーンベースの進捗（0.0〜1.0）。
    public var milestoneProgress: Double? {
        guard !milestones.isEmpty else { return nil }
        let completed = milestones.filter { $0.isCompleted(tasks: tasks) }.count
        return Double(completed) / Double(milestones.count)
    }
}
```

#### Enums/TaskStatus.swift

```swift
import Foundation

/// タスクの状態を表す列挙型。
public enum TaskStatus: String, Codable, Sendable {
    /// 未着手
    case pending
    /// 完了
    case completed
}
```

## 🔍 クエリのベストプラクティス

### 基本的なクエリ（FetchDescriptor）

SwiftDataでは、`FetchDescriptor` を使ってデータを取得します。

```swift
import SwiftData

// すべてのGoalを取得（作成日時の降順）
let descriptor = FetchDescriptor<Goal>(
    sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
)
let goals = try modelContext.fetch(descriptor)
```

### 条件付きクエリ（Predicate）

`#Predicate` マクロを使って、型安全なクエリを記述します。

```swift
// 特定のIDのGoalを取得
let goalId = UUID()
let descriptor = FetchDescriptor<Goal>(
    predicate: #Predicate { $0.id == goalId }
)
let goal = try modelContext.fetch(descriptor).first
```

### 複雑な条件

複数の条件を組み合わせることができます。

```swift
// 期限が今日以降で、未完了のGoalを取得
let today = Date()
let descriptor = FetchDescriptor<Goal>(
    predicate: #Predicate { goal in
        goal.deadline >= today && !goal.isCompleted
    },
    sortBy: [SortDescriptor(\.deadline)]
)
let upcomingGoals = try modelContext.fetch(descriptor)
```

### リレーションシップを含むクエリ

関連エンティティの条件でフィルタリングできます。

```swift
// タスクが5個以上あるGoalを取得
let descriptor = FetchDescriptor<Goal>(
    predicate: #Predicate { goal in
        goal.tasks.count >= 5
    }
)
let complexGoals = try modelContext.fetch(descriptor)

// 特定のステータスのタスクを持つGoalを取得
let descriptor2 = FetchDescriptor<Goal>(
    predicate: #Predicate { goal in
        goal.tasks.contains { $0.status == .pending }
    }
)
let goalsWithPendingTasks = try modelContext.fetch(descriptor2)
```

### ソート（SortDescriptor）

複数のソート条件を指定できます。

```swift
let descriptor = FetchDescriptor<Goal>(
    sortBy: [
        SortDescriptor(\.isCompleted),           // 未完了を先に
        SortDescriptor(\.deadline, order: .forward)  // 期限が近い順
    ]
)
let sortedGoals = try modelContext.fetch(descriptor)
```

let pageSize = 20
let offset = 0

var descriptor = FetchDescriptor<Goal>(
    sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
)
descriptor.fetchLimit = pageSize
descriptor.fetchOffset = offset

let goals = try modelContext.fetch(descriptor)
```

### 複数テーブルにまたがる複雑なクエリ

複数のエンティティにまたがるデータを効率的に取得し、SwiftUIのViewに軽量に反映させる方法を説明します。

#### パターン1: SwiftUIの `@Query` マクロ（最も軽量）

SwiftUIで直接クエリを行うと、自動的にデータバインディングされます。

```swift
import SwiftUI
import SwiftData

struct FavoriteJobsView: View {
    // お気に入り求人を直接クエリ（最新順）
    @Query(
        sort: \FavoriteJob.favoritedAt,
        order: .reverse
    ) private var favorites: [FavoriteJob]
    
    var body: some View {
        List(favorites) { favorite in
            if let job = favorite.jobPosting {
                VStack(alignment: .leading, spacing: 8) {
                    Text(job.title)
                        .font(.headline)
                    Text(job.company)
                        .font(.subheadline)
                    Text("お気に入り: \(favorite.favoritedAt.formatted())")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}
```

**利点**:
- 自動的にデータ変更を監視
- コードが最小限
- パフォーマンスが良い
- リレーションシップは遅延読み込み

#### パターン2: 動的な条件でクエリ

```swift
struct JobListView: View {
    let searchText: String
    
    @Query private var jobs: [JobPosting]
    
    init(searchText: String) {
        self.searchText = searchText
        
        // 検索条件を動的に設定
        let predicate = #Predicate<JobPosting> { job in
            searchText.isEmpty || 
            job.title.localizedStandardContains(searchText) ||
            job.company.localizedStandardContains(searchText)
        }
        
        _jobs = Query(
            filter: predicate,
            sort: \JobPosting.postedAt,
            order: .reverse
        )
    }
    
    var body: some View {
        List(jobs) { job in
            JobRowView(job: job)
        }
    }
}
```

#### パターン3: 中間エンティティ経由の結合クエリ

```swift
struct UserFavoriteJobsView: View {
    let userId: UUID
    
    // ユーザーのお気に入り求人を取得
    @Query private var favorites: [FavoriteJob]
    
    init(userId: UUID) {
        self.userId = userId
        
        let predicate = #Predicate<FavoriteJob> { favorite in
            favorite.user?.id == userId
        }
        
        _favorites = Query(
            filter: predicate,
            sort: \FavoriteJob.favoritedAt,
            order: .reverse
        )
    }
    
    var body: some View {
        List(favorites) { favorite in
            if let job = favorite.jobPosting {
                VStack(alignment: .leading, spacing: 8) {
                    // 求人情報
                    Text(job.title)
                        .font(.headline)
                    Text(job.company)
                        .font(.subheadline)
                    
                    // お気に入り固有の情報
                    if let memo = favorite.memo {
                        Text(memo)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    // タグ
                    if !favorite.tags.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(favorite.tags, id: \.self) { tag in
                                    Text(tag)
                                        .font(.caption2)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(.blue.opacity(0.2))
                                        .cornerRadius(4)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
```

#### パターン4: 複数条件の組み合わせ

```swift
struct AdvancedJobSearchView: View {
    let location: String
    let isFavoriteOnly: Bool
    
    @Query private var jobs: [JobPosting]
    
    init(location: String, isFavoriteOnly: Bool) {
        self.location = location
        self.isFavoriteOnly = isFavoriteOnly
        
        let predicate = #Predicate<JobPosting> { job in
            // 場所でフィルタ
            (location.isEmpty || job.location.localizedStandardContains(location)) &&
            // お気に入りのみ
            (!isFavoriteOnly || job.favorites.count > 0)
        }
        
        _jobs = Query(
            filter: predicate,
            sort: \JobPosting.postedAt,
            order: .reverse
        )
    }
    
    var body: some View {
        List(jobs) { job in
            JobRowView(job: job)
        }
    }
}
```

#### パターン5: ViewModelを使った複雑なクエリ（より柔軟）

ViewModelを使うと、より複雑なロジックを実装できます。

```swift
import SwiftUI
import SwiftData
import Dependencies

@Observable
class JobSearchViewModel {
    @ObservationIgnored
    @Dependency(\.modelContext) var modelContext
    
    var jobs: [JobPosting] = []
    var isLoading = false
    var errorMessage: String?
    
    func searchJobs(
        keyword: String,
        location: String,
        tags: [String],
        onlyFavorites: Bool
    ) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        do {
            if onlyFavorites {
                // お気に入りから検索
                let favoritePredicate = #Predicate<FavoriteJob> { favorite in
                    // タグでフィルタ
                    tags.isEmpty || tags.allSatisfy { tag in
                        favorite.tags.contains(tag)
                    }
                }
                
                let descriptor = FetchDescriptor<FavoriteJob>(
                    predicate: favoritePredicate,
                    sortBy: [SortDescriptor(\.favoritedAt, order: .reverse)]
                )
                
                let favorites = try modelContext.fetch(descriptor)
                jobs = favorites.compactMap { $0.jobPosting }
                
                // さらにキーワードと場所でフィルタ（メモリ上）
                jobs = jobs.filter { job in
                    (keyword.isEmpty || 
                     job.title.localizedStandardContains(keyword) ||
                     job.company.localizedStandardContains(keyword)) &&
                    (location.isEmpty || 
                     job.location.localizedStandardContains(location))
                }
            } else {
                // 通常の求人検索
                let jobPredicate = #Predicate<JobPosting> { job in
                    (keyword.isEmpty || 
                     job.title.localizedStandardContains(keyword) ||
                     job.company.localizedStandardContains(keyword)) &&
                    (location.isEmpty || 
                     job.location.localizedStandardContains(location))
                }
                
                let descriptor = FetchDescriptor<JobPosting>(
                    predicate: jobPredicate,
                    sortBy: [SortDescriptor(\.postedAt, order: .reverse)]
                )
                
                jobs = try modelContext.fetch(descriptor)
            }
        } catch {
            errorMessage = "検索エラー: \(error.localizedDescription)"
        }
    }
}

// View
struct JobSearchView: View {
    @State private var viewModel = JobSearchViewModel()
    @State private var keyword = ""
    @State private var location = ""
    @State private var selectedTags: [String] = []
    @State private var onlyFavorites = false
    
    var body: some View {
        VStack {
            // 検索フォーム
            Form {
                Section("検索条件") {
                    TextField("キーワード", text: $keyword)
                    TextField("場所", text: $location)
                    Toggle("お気に入りのみ", isOn: $onlyFavorites)
                }
            }
            .frame(height: 200)
            
            Button("検索") {
                Task {
                    await viewModel.searchJobs(
                        keyword: keyword,
                        location: location,
                        tags: selectedTags,
                        onlyFavorites: onlyFavorites
                    )
                }
            }
            .buttonStyle(.borderedProminent)
            
            // 結果表示
            if viewModel.isLoading {
                ProgressView("検索中...")
            } else if let error = viewModel.errorMessage {
                Text(error)
                    .foregroundStyle(.red)
            } else {
                List(viewModel.jobs) { job in
                    JobRowView(job: job)
                }
            }
        }
    }
}
```

#### パターン6: 集計クエリ（計算プロパティを活用）

```swift
struct JobDetailView: View {
    let job: JobPosting
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // 基本情報
                Text(job.title)
                    .font(.title)
                Text(job.company)
                    .font(.headline)
                Text(job.description)
                    .font(.body)
                
                Divider()
                
                // 統計情報（計算プロパティ）
                VStack(alignment: .leading, spacing: 8) {
                    Text("統計情報")
                        .font(.headline)
                    
                    HStack {
                        Label("\(job.viewCount)回閲覧", systemImage: "eye")
                        
                        if job.isFavorited {
                            Label("お気に入り", systemImage: "star.fill")
                                .foregroundStyle(.yellow)
                        }
                    }
                    .font(.caption)
                    
                    // 平均閲覧時間
                    if let avgDuration = job.averageViewDuration {
                        Text("平均閲覧時間: \(Int(avgDuration))秒")
                            .font(.caption)
                    }
                    
                    // 最終閲覧日時
                    if let lastViewed = job.lastViewedAt {
                        Text("最終閲覧: \(lastViewed.formatted())")
                            .font(.caption)
                    }
                }
            }
            .padding()
        }
    }
}

// JobPosting の extension（計算プロパティ）
extension JobPosting {
    /// 閲覧回数
    var viewCount: Int {
        viewHistories.count
    }
    
    /// お気に入りされているか
    var isFavorited: Bool {
        !favorites.isEmpty
    }
    
    /// 最終閲覧日時
    var lastViewedAt: Date? {
        viewHistories.max(by: { $0.viewedAt < $1.viewedAt })?.viewedAt
    }
    
    /// 平均閲覧時間
    var averageViewDuration: TimeInterval? {
        let durations = viewHistories.compactMap { $0.viewDuration }
        guard !durations.isEmpty else { return nil }
        return durations.reduce(0, +) / Double(durations.count)
    }
}
```

### パフォーマンス最適化のテクニック

#### A. 必要なデータのみ取得（fetchLimit）

```swift
// ❌ 悪い例: すべてのデータを取得してから制限
@Query private var allJobs: [JobPosting]

var body: some View {
    List(allJobs.prefix(20)) { job in
        JobRowView(job: job)
    }
}

// ✅ 良い例: 最初から20件のみ取得
@Query private var jobs: [JobPosting]

init() {
    var descriptor = FetchDescriptor<JobPosting>(
        sortBy: [SortDescriptor(\.postedAt, order: .reverse)]
    )
    descriptor.fetchLimit = 20
    
    _jobs = Query(FetchDescriptor: descriptor)
}
```

#### B. 遅延読み込み（Lazy Loading）の活用

```swift
struct JobListView: View {
    @Query(sort: \JobPosting.postedAt, order: .reverse) 
    private var jobs: [JobPosting]
    
    var body: some View {
        List(jobs) { job in
            // リレーションシップは必要になるまで読み込まれない
            JobRowView(job: job)
        }
    }
}

struct JobRowView: View {
    let job: JobPosting
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(job.title)
            Text(job.company)
            
            // ✅ この時点で初めて favorites が読み込まれる（遅延読み込み）
            if job.isFavorited {
                Image(systemName: "star.fill")
                    .foregroundStyle(.yellow)
            }
        }
    }
}
```

#### C. ページネーション（無限スクロール）

```swift
import SwiftUI
import SwiftData
import Dependencies

@Observable
class PaginatedJobListViewModel {
    @ObservationIgnored
    @Dependency(\.modelContext) var modelContext
    
    var jobs: [JobPosting] = []
    var currentPage = 0
    let pageSize = 20
    var hasMore = true
    var isLoading = false
    
    func loadMore() async {
        guard hasMore, !isLoading else { return }
        
        isLoading = true
        defer { isLoading = false }
        
        var descriptor = FetchDescriptor<JobPosting>(
            sortBy: [SortDescriptor(\.postedAt, order: .reverse)]
        )
        descriptor.fetchLimit = pageSize
        descriptor.fetchOffset = currentPage * pageSize
        
        do {
            let newJobs = try modelContext.fetch(descriptor)
            jobs.append(contentsOf: newJobs)
            hasMore = newJobs.count == pageSize
            currentPage += 1
        } catch {
            print("読み込みエラー: \(error)")
        }
    }
    
    func reset() {
        jobs = []
        currentPage = 0
        hasMore = true
    }
}

struct PaginatedJobListView: View {
    @State private var viewModel = PaginatedJobListViewModel()
    
    var body: some View {
        List {
            ForEach(viewModel.jobs) { job in
                JobRowView(job: job)
                    .onAppear {
                        // 最後の項目が表示されたら次のページを読み込む
                        if job.id == viewModel.jobs.last?.id {
                            Task {
                                await viewModel.loadMore()
                            }
                        }
                    }
            }
            
            if viewModel.hasMore {
                HStack {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
                .onAppear {
                    Task {
                        await viewModel.loadMore()
                    }
                }
            }
        }
        .task {
            await viewModel.loadMore()
        }
        .refreshable {
            viewModel.reset()
            await viewModel.loadMore()
        }
    }
}
```

#### D. メモリ効率の良いクエリ

```swift
// ❌ 悪い例: N+1問題
@Query private var goals: [Goal]

var body: some View {
    List(goals) { goal in
        VStack {
            Text(goal.title)
            // 各goalごとにtasksを読み込む（N+1問題）
            Text("\(goal.tasks.count)個のタスク")
        }
    }
}

// ✅ 良い例: 必要な条件でフィルタリング
@Query private var goals: [Goal]

init() {
    // タスクがあるgoalのみを取得
    let predicate = #Predicate<Goal> { goal in
        goal.tasks.count > 0
    }
    
    _goals = Query(
        filter: predicate,
        sort: \Goal.createdAt,
        order: .reverse
    )
}

var body: some View {
    List(goals) { goal in
        VStack {
            Text(goal.title)
            Text("\(goal.tasks.count)個のタスク")
        }
    }
}
```

### クエリ戦略の使い分けガイド

| シナリオ | 推奨アプローチ | 理由 |
|---|---|---|
| シンプルな一覧表示 | `@Query` マクロ | 最も軽量、自動バインディング |
| 動的な検索条件 | `@Query` + `init` | 条件を動的に変更可能 |
| 複雑なビジネスロジック | ViewModel + `FetchDescriptor` | 柔軟性が高い、エラーハンドリングが容易 |
| 大量データ（100件以上） | ページネーション | メモリ効率が良い |
| リアルタイム更新が必要 | `@Query` マクロ | 自動的に更新される |
| 集計・統計情報 | 計算プロパティ | クエリを最小限に、遅延読み込み |
| 複数条件の組み合わせ | `#Predicate` マクロ | 型安全、可読性が高い |
| ユーザー入力による検索 | ViewModel | 非同期処理、ローディング状態管理 |

### ベストプラクティスのまとめ

1. **`@Query` を優先**: SwiftUIでは可能な限り `@Query` マクロを使用
2. **遅延読み込みを活用**: リレーションシップは必要になるまで読み込まれない
3. **`fetchLimit` で制限**: 大量データは最初から制限をかける
4. **計算プロパティで集計**: 統計情報は計算プロパティで実装
5. **ページネーションを実装**: 100件以上のデータは無限スクロールを検討
6. **ViewModelで複雑なロジック**: 複雑な検索やエラーハンドリングはViewModelで
7. **`#Predicate` で型安全**: 条件は `#Predicate` マクロで型安全に記述

## ✅ データの整合性を保つ


### 双方向リレーションシップの正しい設定

`inverse` を使用すると、リレーションシップが自動的に管理されます。

```swift
// ✅ 正しい方法: 親から追加
let goal = Goal(title: "Learn Swift", deadline: Date())
let task = GoalTask(title: "Read documentation")

goal.tasks.append(task)
// task.goal は自動的に goal に設定される（inverse のおかげ）

modelContext.insert(goal)
try modelContext.save()
```

### 避けるべきパターン

```swift
// ❌ 両方を手動で設定しない（重複）
goal.tasks.append(task)
task.goal = goal  // 不要！inverseが自動で設定する

// ❌ 子を先に挿入しない
modelContext.insert(task)  // goalがまだ挿入されていない
task.goal = goal
modelContext.insert(goal)
```

### カスケード削除の動作

```swift
// .cascade の場合
let goal = /* 既存のGoal */
modelContext.delete(goal)
try modelContext.save()
// goal.tasks も自動的に削除される

// .nullify の場合
let user = /* 既存のUser */
modelContext.delete(user)
try modelContext.save()
// user.posts は残るが、post.author は nil になる
```

## ⚡️ パフォーマンス最適化

### 遅延読み込み（Lazy Loading）

SwiftDataはデフォルトで遅延読み込みを行います。

```swift
let goal = try modelContext.fetch(descriptor).first
// この時点では tasks はまだ読み込まれていない

let taskCount = goal.tasks.count
// アクセス時に初めて読み込まれる（データベースクエリが発生）
```

**利点**:
- 不要なデータを読み込まない
- メモリ効率が良い

**注意点**:
- N+1問題が発生する可能性がある

### N+1問題の回避

```swift
// ❌ 悪い例: N+1問題
let goals = try modelContext.fetch(FetchDescriptor<Goal>())
for goal in goals {
    print(goal.tasks.count)  // 各goalごとにクエリが発生
}

// ✅ 良い例: 必要なデータのみをクエリ
// 現在のSwiftDataでは明示的なプリフェッチはサポートされていないため、
// クエリを工夫する
let descriptor = FetchDescriptor<Goal>(
    predicate: #Predicate { goal in
        goal.tasks.count > 0  // 条件を追加してフィルタリング
    }
)
let goalsWithTasks = try modelContext.fetch(descriptor)
```

### バッチ処理

大量のデータを処理する場合は、バッチで処理します。

```swift
let batchSize = 100
var offset = 0

while true {
    var descriptor = FetchDescriptor<Goal>()
    descriptor.fetchLimit = batchSize
    descriptor.fetchOffset = offset
    
    let batch = try modelContext.fetch(descriptor)
    if batch.isEmpty { break }
    
    // バッチ処理
    for goal in batch {
        // 処理
    }
    
    offset += batchSize
}
```

## 🔄 マイグレーション戦略

### スキーマバージョニング

SwiftDataでは、スキーマを明示的に定義します。

```swift
import SwiftData

// スキーマの定義
let schema = Schema([
    Goal.self,
    GoalTask.self,
    Milestone.self
])

// ModelConfigurationの作成
let modelConfiguration = ModelConfiguration(
    schema: schema,
    isStoredInMemoryOnly: false  // 永続化する
)

// ModelContainerの作成
let container = try ModelContainer(
    for: schema,
    configurations: [modelConfiguration]
)
```

### フィールド追加時の互換性

新しいフィールドを追加する場合は、オプショナルにすることで既存データとの互換性を保ちます。

```swift
@Model
public final class Goal {
    // 既存フィールド
    public var id: UUID
    public var title: String
    public var deadline: Date
    
    // ✅ 新しいフィールドはオプショナルにする
    public var startDate: Date?  // 既存データでは nil
    public var priority: Int?    // 既存データでは nil
    
    public init(id: UUID = UUID(), title: String, deadline: Date, startDate: Date? = nil, priority: Int? = nil) {
        self.id = id
        self.title = title
        self.deadline = deadline
        self.startDate = startDate
        self.priority = priority
    }
}
```

### デフォルト値の提供

オプショナルではなく、デフォルト値を提供することもできます。

```swift
@Model
public final class Goal {
    public var id: UUID
    public var title: String
    public var priority: Int  // 非オプショナル
    
    public init(id: UUID = UUID(), title: String, priority: Int = 0) {
        self.id = id
        self.title = title
        self.priority = priority  // デフォルトは0
    }
}
```

**注意**: 既存データには自動的にデフォルト値が設定されないため、マイグレーションコードが必要になる場合があります。

## 🧪 テストのベストプラクティス

### インメモリストレージを使う

テストでは、ディスクに保存せずメモリ内のみで動作させます。

```swift
import XCTest
import SwiftData
@testable import MyBestAITasksCore

class GoalRepositoryTests: XCTestCase {
    var container: ModelContainer!
    var context: ModelContext!
    
    override func setUp() async throws {
        // テスト用のスキーマ
        let schema = Schema([
            Goal.self,
            GoalTask.self,
            Milestone.self
        ])
        
        // インメモリ設定
        let configuration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: true  // ✅ メモリ内のみ
        )
        
        container = try ModelContainer(
            for: schema,
            configurations: [configuration]
        )
        
        context = ModelContext(container)
    }
    
    func testAddGoal() async throws {
        let goal = Goal(title: "Test Goal", deadline: Date())
        context.insert(goal)
        try context.save()
        
        let descriptor = FetchDescriptor<Goal>()
        let goals = try context.fetch(descriptor)
        
        XCTAssertEqual(goals.count, 1)
        XCTAssertEqual(goals.first?.title, "Test Goal")
    }
}
```

### モックRepositoryの使用

依存性注入を使って、テスト時にモックRepositoryを使用します。

```swift
// MockGoalRepository.swift
public class MockGoalRepository: GoalRepositoryProtocol {
    private var goals: [Goal] = []
    
    public init() {}
    
    public func addGoal(_ goal: Goal) async throws {
        goals.append(goal)
    }
    
    public func getGoals() -> AnyPublisher<[Goal], Never> {
        Just(goals).eraseToAnyPublisher()
    }
    
    public func updateGoal(_ goal: Goal) async throws {
        // モック実装
    }
    
    public func deleteGoal(id: UUID) async throws {
        goals.removeAll { $0.id == id }
    }
}
```

### テストでの使用

```swift
// ViewModelのテスト
class GoalListViewModelTests: XCTestCase {
    func testLoadGoals() async {
        // モックRepositoryを使用
        let mockRepository = MockGoalRepository()
        
        // 依存性を注入
        await withDependencies {
            $0.goalRepository = mockRepository
        } operation: {
            let viewModel = GoalListViewModel()
            await viewModel.loadGoals()
            
            // アサーション
            XCTAssertEqual(viewModel.goals.count, 0)
        }
    }
}
```

## 🎯 実践的な設計例

### 複雑なドメインモデルの例: プロジェクト管理システム

```swift
// Project.swift
@Model
class Project {
    var id: UUID
    var name: String
    var description: String
    var startDate: Date
    var endDate: Date?
    var status: ProjectStatus
    
    @Relationship(deleteRule: .cascade, inverse: \Task.project)
    var tasks: [Task]
    
    @Relationship(deleteRule: .nullify, inverse: \User.projects)
    var members: [User]
    
    init(id: UUID = UUID(), name: String, description: String, startDate: Date, endDate: Date? = nil, status: ProjectStatus = .active, tasks: [Task] = [], members: [User] = []) {
        self.id = id
        self.name = name
        self.description = description
        self.startDate = startDate
        self.endDate = endDate
        self.status = status
        self.tasks = tasks
        self.members = members
    }
}

// Task.swift
@Model
class Task {
    var id: UUID
    var title: String
    var description: String
    var status: TaskStatus
    var priority: Priority
    var dueDate: Date?
    var createdAt: Date
    
    var project: Project?
    var assignee: User?
    
    @Relationship(deleteRule: .cascade, inverse: \Comment.task)
    var comments: [Comment]
    
    @Relationship(deleteRule: .cascade, inverse: \Attachment.task)
    var attachments: [Attachment]
    
    init(id: UUID = UUID(), title: String, description: String, status: TaskStatus = .todo, priority: Priority = .medium, dueDate: Date? = nil, createdAt: Date = Date(), comments: [Comment] = [], attachments: [Attachment] = []) {
        self.id = id
        self.title = title
        self.description = description
        self.status = status
        self.priority = priority
        self.dueDate = dueDate
        self.createdAt = createdAt
        self.comments = comments
        self.attachments = attachments
    }
}

// User.swift
@Model
class User {
    var id: UUID
    var name: String
    var email: String
    var avatarURL: String?
    
    @Relationship(deleteRule: .nullify, inverse: \Project.members)
    var projects: [Project]
    
    @Relationship(deleteRule: .nullify, inverse: \Task.assignee)
    var assignedTasks: [Task]
    
    @Relationship(deleteRule: .cascade, inverse: \Comment.author)
    var comments: [Comment]
    
    init(id: UUID = UUID(), name: String, email: String, avatarURL: String? = nil, projects: [Project] = [], assignedTasks: [Task] = [], comments: [Comment] = []) {
        self.id = id
        self.name = name
        self.email = email
        self.avatarURL = avatarURL
        self.projects = projects
        self.assignedTasks = assignedTasks
        self.comments = comments
    }
}

// Comment.swift
@Model
class Comment {
    var id: UUID
    var text: String
    var createdAt: Date
    
    var task: Task?
    var author: User?
    
    init(id: UUID = UUID(), text: String, createdAt: Date = Date()) {
        self.id = id
        self.text = text
        self.createdAt = createdAt
    }
}

// Attachment.swift
@Model
class Attachment {
    var id: UUID
    var fileName: String
    var fileURL: String
    var fileSize: Int
    var uploadedAt: Date
    
    var task: Task?
    
    init(id: UUID = UUID(), fileName: String, fileURL: String, fileSize: Int, uploadedAt: Date = Date()) {
        self.id = id
        self.fileName = fileName
        self.fileURL = fileURL
        self.fileSize = fileSize
        self.uploadedAt = uploadedAt
    }
}

// Enums/ProjectStatus.swift
enum ProjectStatus: String, Codable {
    case active
    case onHold
    case completed
    case archived
}

// Enums/TaskStatus.swift
enum TaskStatus: String, Codable {
    case todo
    case inProgress
    case review
    case done
}

// Enums/Priority.swift
enum Priority: String, Codable {
    case low
    case medium
    case high
    case urgent
}
```

### リレーションシップの図解

```
┌─────────────┐
│   Project   │
│             │
│ - name      │
│ - status    │
└──────┬──────┘
       │ 1
       │
       │ *
┌──────▼──────┐         ┌──────────────┐
│    Task     │ *     1 │     User     │
│             ├─────────┤              │
│ - title     │         │ - name       │
│ - status    │         │ - email      │
└──────┬──────┘         └──────┬───────┘
       │ 1                     │ 1
       │                       │
       │ *                     │ *
┌──────▼──────┐         ┌──────▼───────┐
│   Comment   │         │   Comment    │
│             │         │              │
│ - text      │         │ - text       │
└─────────────┘         └──────────────┘
```

## 📋 SwiftData設計のチェックリスト

設計時に確認すべき項目：

- [ ] **1モデル1ファイル**: 各エンティティを独立したファイルに配置
- [ ] **`@Model` と `final class`**: SwiftDataモデルは `final class` で定義
- [ ] **`@Relationship` で関連を定義**: `deleteRule` と `inverse` を適切に設定
- [ ] **列挙型は分離**: `Enums/` ディレクトリに配置
- [ ] **オプショナルで互換性**: 新しいフィールドは `?` を付けて既存データとの互換性を保つ
- [ ] **双方向リレーションシップ**: `inverse` を使って自動管理
- [ ] **適切な削除ルール**: `.cascade`, `.nullify`, `.deny` を使い分け
- [ ] **`#Predicate` でクエリ**: 型安全なクエリを記述
- [ ] **Repositoryパターン**: データアクセスを抽象化
- [ ] **テストはインメモリ**: `isStoredInMemoryOnly: true` を使用
- [ ] **DocC コメント**: すべてのpublicメンバーに日本語ドキュメントを追加
- [ ] **`Sendable` 準拠**: 並行処理で使用する場合は `@unchecked Sendable` を追加

## 🎓 まとめ

### SwiftDataの強み

- **型安全**: コンパイル時にエラーを検出
- **SwiftUIとの統合**: `@Query` マクロで簡単にデータバインディング
- **自動マイグレーション**: 多くの場合、スキーマ変更が自動的に処理される
- **モダンなAPI**: `async/await` や `#Predicate` マクロを使用

### 設計の基本方針

1. **シンプルに始める**: 最初から複雑にしない
2. **リレーションシップを明確に**: `@Relationship` で関係を定義
3. **テスタビリティを重視**: Repositoryパターンと依存性注入を使用
4. **パフォーマンスを意識**: 遅延読み込みとバッチ処理を活用
5. **互換性を保つ**: 新しいフィールドはオプショナルに

### 参考資料

- [SwiftData Documentation](https://developer.apple.com/documentation/swiftdata)
- [WWDC 2023 - Meet SwiftData](https://developer.apple.com/videos/play/wwdc2023/10187/)
- [WWDC 2023 - Model your schema with SwiftData](https://developer.apple.com/videos/play/wwdc2023/10195/)
- [WWDC 2023 - Dive deeper into SwiftData](https://developer.apple.com/videos/play/wwdc2023/10196/)

このプロジェクトの `Goal` ↔ `GoalTask` ↔ `Milestone` の関係は、SwiftDataのベストプラクティスに沿った良い実装例です！
