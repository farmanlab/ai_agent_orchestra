---
paths:
  - "**/*Test.ts"
  - "**/*Test.js"
  - "**/*_test.py"
  - "**/test/**"

---


# Testing Rules

## Test Structure
- AAA パターン（Arrange, Act, Assert）を使用
- テスト名は「should_期待結果_when_条件」形式
- 1つのテストで1つの観点のみ検証

## Test Coverage
- 新規機能には必ずテストを追加
- 重要なビジネスロジックは100%カバレッジ
- エッジケースと異常系のテストを含める

## Mocking
- 外部依存は必ずモック化
- テストダブルは適切に使い分け
  - Stub: 入力の代替
  - Mock: 振る舞いの検証
  - Spy: 呼び出しの記録

## Test Organization
- テストファイルは対象ファイルと同じディレクトリ構造
- 共通のテストユーティリティは test/helpers/ に配置
- テストデータは test/fixtures/ に配置

## Best Practices
- テストは独立して実行可能に
- テストの実行順序に依存しない
- テストは高速に（単体テストは1秒以内）
- テストコードも本番コードと同じ品質で
