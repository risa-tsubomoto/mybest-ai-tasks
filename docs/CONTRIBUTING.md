# コントリビューションガイド

このプロジェクトへのコントリビューションを歓迎します！
以下のガイドラインに従って作業を進めてください。

## ワークフロー (GitHub Flow)

このプロジェクトは **GitHub Flow** を採用しています。

### 1. Issue の作成

作業を始める前に、必ず Issue を作成してください。

- **Bug Report**: `.github/ISSUE_TEMPLATE/bug_report.md` を使用
- **Feature Request**: `.github/ISSUE_TEMPLATE/feature_request.md` を使用
- **Refactor**: `.github/ISSUE_TEMPLATE/refactor.md` を使用

### 2. ブランチの作成

Issue 番号を含むブランチ名を使用してください。

**命名規則:**
- `feature/issue-{番号}-{簡潔な説明}` - 新機能
- `fix/issue-{番号}-{簡潔な説明}` - バグ修正
- `refactor/issue-{番号}-{簡潔な説明}` - リファクタリング
- `docs/issue-{番号}-{簡潔な説明}` - ドキュメント

**例:**
```bash
git checkout -b feature/issue-5-add-calendar-sync
```

### 3. 作業 & コミット

- コミットメッセージは明確に記述する
- 小さな単位でコミットする
- コミットメッセージの形式:
  ```
  [種別] 簡潔な説明
  
  詳細な説明（必要に応じて）
  ```

**種別の例:**
- `[Feature]` - 新機能
- `[Fix]` - バグ修正
- `[Refactor]` - リファクタリング
- `[Docs]` - ドキュメント
- `[Test]` - テスト追加・修正
- `[Style]` - コードフォーマットのみの変更

### 4. プルリクエストの作成

1. GitHub でプルリクエストを作成
2. タイトルに `Close #X` を含める（自動クローズ用）
3. PR テンプレートに従って必要事項を記入
4. レビューを依頼

### 5. マージ後

- ブランチを削除
- Issue がクローズされていることを確認

## コーディング規約

### Swift コードスタイル

- **インデント**: スペース4つ
- **命名規則**:
  - クラス/構造体/列挙型: `PascalCase`
  - 変数/関数: `camelCase`
  - 定数: `camelCase`
- **ファイル構成**: 1ファイル1クラス/構造体
- **Enum**: `Core/Model/Enums/` ディレクトリに配置

### ドキュメント

- すべてのpublic API に **日本語の DocC コメント** を追加
- コメント形式:
  ```swift
  /// メソッドの説明。
  /// - Parameter param: パラメータの説明。
  /// - Returns: 戻り値の説明。
  ```

### アーキテクチャ

- **Core**: ビジネスロジック、データモデル、ドメインロジック
- **Feature**: UI層（View, ViewModel）
- **Infrastructure**: 外部システム連携（Calendar, Network, Security, Notification）

### 依存性管理

- `swift-dependencies` を使用
- バージョン: **1.3.9** (Swift Testing 非依存)

## テスト

- 新機能には可能な限りテストを追加
- リファクタリング時は既存のテストが通ることを確認

## その他

- 質問や提案があれば Issue で気軽に相談してください
- コードレビューは建設的なフィードバックを心がけましょう
