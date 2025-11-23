# 実装計画: スマート機能とチャットインターフェースの追加

## 目標
ユーザー体験を向上させるために、以下の機能を追加します：
1.  **スマートスケジュール**: 期限から逆算した最適なスケジュール設定。
2.  **デイリールーチン**: 毎日実行するタスクの設定と通知。
3.  **チャット調整**: 自然言語で目標やタスクを調整できるチャットインターフェース。
4.  **スマートタイトル**: ユーザー入力からより良い目標タイトルを自動生成。

## ユーザーレビューが必要な事項
- **通知許可**: デイリールーチン機能のために通知許可が必要です。
- **Gemini API**: チャット機能とスマートタイトル生成のために Gemini API の呼び出し回数が増加します。

## 変更内容

### Core

#### [MODIFY] [Goal.swift](file:///Users/lisa/dev/mybest-ai-tasks/mybest_tasks/mybest_tasks/Core/Model/Goal.swift)
- `GoalTask` クラスに `recurrence` (繰り返し設定) プロパティを追加します。
- `TaskStatus` に関連するロジックを更新します。

#### [MODIFY] [GeminiService.swift](file:///Users/lisa/dev/mybest-ai-tasks/mybest_tasks/mybest_tasks/Core/Data/DataSources/GeminiService.swift)
- `generateTasks` のプロンプトを更新し、以下の情報を要求します：
    - 最適化された目標タイトル
    - 各タスクの期限からの逆算日 (または推奨実施日)
- 新しいメソッド `updateGoal(currentGoal: Goal, instruction: String)` を追加し、チャットによる目標修正をサポートします。

#### [NEW] [NotificationManager.swift](file:///Users/lisa/dev/mybest-ai-tasks/mybest_tasks/mybest_tasks/Core/Services/NotificationManager.swift)
- ローカル通知のスケジュールと管理を行う新しいサービスを作成します。

### Feature

#### [NEW] [GoalChatView.swift](file:///Users/lisa/dev/mybest-ai-tasks/mybest_tasks/mybest_tasks/Feature/GoalChat/GoalChatView.swift)
- Gemini と対話して目標を調整するためのチャット画面を作成します。

#### [MODIFY] [GoalDetailView.swift](file:///Users/lisa/dev/mybest-ai-tasks/mybest_tasks/mybest_tasks/Feature/GoalDetail/GoalDetailView.swift)
- チャット画面への遷移ボタンを追加します。

#### [MODIFY] [CreateGoalUseCase.swift](file:///Users/lisa/dev/mybest-ai-tasks/mybest_tasks/mybest_tasks/Core/Domain/CreateGoalUseCase.swift)
- `GeminiService` から返されたスマートタイトルとスケジュール情報を `Goal` オブジェクトに反映させます。

## 検証計画

### 自動テスト
- 現状、UIテストやユニットテストの基盤が不明確なため、主要なロジック (GeminiService のパース処理など) に対して単体テストを追加することを検討します。

### 手動検証
1.  **スマートスケジュール**:
    - 新しい目標を作成し、タスクの日付が期限から逆算して適切に設定されているか確認します。
    - 目標タイトルが入力したものより具体的で魅力的なものになっているか確認します。
2.  **デイリールーチン**:
    - 繰り返しタスクを作成し、指定した時間に通知が届くか確認します (シミュレータ設定で通知許可が必要)。
3.  **チャット調整**:
    - 目標詳細画面からチャット画面を開きます。
    - 「タスクAを削除して」「期限を2日延ばして」などの指示を送り、目標が正しく更新されるか確認します。
