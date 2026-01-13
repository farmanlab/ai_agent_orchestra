---
name: generating-acceptance-criteria
description: Generates TDD-ready acceptance criteria from screen spec.md. Extracts requirements from features, interactions, flows, and API mappings in Given-When-Then format. Use when creating implementation task specifications.
allowed-tools: [Read, Write, Glob, Grep]
---

# Acceptance Criteria Generation Skill

画面仕様書（spec.md）から TDD 向けの受け入れ要件を自動生成するスキルです。

## 目次

1. [概要](#概要)
2. [クイックスタート](#クイックスタート)
3. [抽出ロジック](#抽出ロジック)
4. [出力形式](#出力形式)
5. [詳細ガイド](#詳細ガイド)

## 概要

このスキルは以下のタスクをサポートします：

1. **要件抽出**: spec.md の各セクションから受け入れ要件を抽出
2. **TDD形式変換**: Given-When-Then 形式に変換
3. **テストケース対応**: 各要件が1つの `it()` ブロックに対応する粒度
4. **カテゴリ分類**: 表示・操作・遷移・状態・API・エラーに分類

## 禁止事項

**以下は絶対に行わないこと：**
- テストコードの生成（Jest/Vitest/Playwright等）
- 実装コードの生成
- テストフレームワークの提案

このスキルの目的は「何をテストすべきか」の**要件整理のみ**です。

## 出力先

このスキルは**画面仕様書（spec.md）の「受け入れ要件」セクション**を更新します。

```
.outputs/{screen-id}/
├── spec.md                 # ← このスキルが「受け入れ要件」セクションを更新
├── index.html
└── assets/
```

## クイックスタート

### 基本的な使い方

```
以下の画面仕様から受け入れ要件を生成してください：
/path/to/screen/spec.md
```

エージェントは自動的に：
1. spec.md の各セクションを解析
2. 抽出ルールに基づき要件を生成
3. Given-When-Then 形式に変換
4. **spec.md の「受け入れ要件」セクションを更新**

## 抽出ロジック

### データソースとカテゴリマッピング

| spec.md セクション | 抽出対象 | 要件カテゴリ |
|-------------------|----------|-------------|
| 機能一覧 | 機能名・説明 | AC-D（表示） |
| インタラクション | data-figma-interaction | AC-I（操作） |
| 画面フロー | 流入/流出遷移 | AC-N（遷移） |
| UI状態 | 状態一覧・状態遷移 | AC-S（状態） |
| APIマッピング | APIフィールドバインディング | AC-A（API） |
| 表示条件 + リストデータ | 空時の表示・境界値 | AC-E（エラー/エッジ） |

### カテゴリ定義

| カテゴリ | プレフィックス | テスト種別 | 説明 |
|----------|---------------|-----------|------|
| 表示 | `AC-D` (Display) | Unit/Integration | データ表示・レンダリング |
| 操作 | `AC-I` (Interaction) | Integration/E2E | ユーザーインタラクション |
| 遷移 | `AC-N` (Navigation) | E2E | 画面遷移 |
| 状態 | `AC-S` (State) | Unit/Integration | 状態管理・状態遷移 |
| API | `AC-A` (API) | Integration | API連携・データバインディング |
| エラー | `AC-E` (Error/Edge) | Unit/Integration | エラーハンドリング・境界値 |

## 出力形式

### TDD向け構造化 Given-When-Then

```markdown
### AC-I01: ブックマークのトグル

| 項目 | 内容 |
|------|------|
| 対象コンポーネント | `HistoryItem`, `SubmissionBookmark` |
| 関連API | `PUT /student_api/ask_ai/submission/{id}/bookmark` |

#### シナリオ一覧

| ID | Given (前提条件) | When (操作) | Then (期待結果) | 優先度 |
|----|------------------|-------------|-----------------|--------|
| 01 | 未ブックマークの履歴が存在する | ブックマークアイコンをタップ | ブックマーク済み状態に変化する | 必須 |
| 02 | ブックマーク済みの履歴が存在する | ブックマークアイコンをタップ | 未ブックマーク状態に変化する | 必須 |
| 03 | ブックマークAPIがエラーを返す | ブックマークアイコンをタップ | エラートーストが表示される | 推奨 |

#### モックデータ要件

- `mockHistory`: 正常系データ
- `mockBookmarkApiError`: エラーレスポンス
```

### テストコードへの変換イメージ

```typescript
describe('AC-I01: ブックマークのトグル', () => {
  it('01: 未ブックマーク → ブックマーク済みに変化する', async () => {
    // Given: 未ブックマークの履歴が存在する
    // When: ブックマークアイコンをタップ
    // Then: ブックマーク済み状態に変化する
  });
});
```

## Workflow

受け入れ要件生成時にこのチェックリストをコピー：

```
Acceptance Criteria Generation Progress:
- [ ] Step 1: spec.md を読み込み
- [ ] Step 2: 機能一覧から AC-D を抽出
- [ ] Step 3: インタラクションから AC-I を抽出
- [ ] Step 4: 画面フローから AC-N を抽出
- [ ] Step 5: UI状態から AC-S を抽出
- [ ] Step 6: APIマッピングから AC-A を抽出
- [ ] Step 7: 表示条件・リストデータから AC-E を抽出
- [ ] Step 8: 重複排除・優先度設定
- [ ] Step 9: spec.md の「受け入れ要件」セクションを更新
```

### Step 1: spec.md を読み込み

対象の spec.md を読み込み、以下のセクションの存在を確認：

- [ ] 機能一覧
- [ ] インタラクション
- [ ] 画面フロー
- [ ] UI状態
- [ ] APIマッピング
- [ ] 表示条件
- [ ] リストデータ（コンテンツ分析内）

### Step 2: 機能一覧から AC-D を抽出

**入力テーブル:**
```markdown
| 機能 | 説明 |
|------|------|
| 履歴一覧表示 | 月別にグループ化された履歴を表示 |
```

**変換ルール:**
- 機能名 → 要件ID の一部
- 説明 → Then（期待結果）
- Given: 「画面を表示している」（デフォルト）
- When: 「画面を表示する」（デフォルト）

**出力:**
```markdown
### AC-D01: 履歴一覧表示

| ID | Given | When | Then | 優先度 |
|----|-------|------|------|--------|
| 01 | 履歴データが存在する | 画面を表示する | 月別にグループ化された履歴が表示される | 必須 |
```

### Step 3: インタラクションから AC-I を抽出

**入力テーブル:**
```markdown
| 要素 | data-figma-interaction | 説明 |
|------|------------------------|------|
| ブックマークアイコン | `tap:toggle:bookmark` | ブックマーク状態をトグル |
```

**変換ルール:**
- `tap:navigate:*` → Given: 画面表示中, When: タップ, Then: 遷移する
- `tap:toggle:*` → Given: 状態A/B, When: タップ, Then: 状態B/A に変化
- `click:show-modal:*` → Given: モーダル非表示, When: クリック, Then: モーダル表示

**出力:**
```markdown
### AC-I01: ブックマークのトグル

| ID | Given | When | Then | 優先度 |
|----|-------|------|------|--------|
| 01 | 未ブックマーク状態 | アイコンをタップ | ブックマーク済みに変化 | 必須 |
| 02 | ブックマーク済み状態 | アイコンをタップ | 未ブックマークに変化 | 必須 |
```

### Step 4: 画面フローから AC-N を抽出

**入力テーブル:**
```markdown
### 流入遷移
| 遷移元 | トリガー | 遷移パラメータ |
|--------|----------|----------------|
| TOP画面 | ボトムナビ「マイリスト」タップ | なし |

### 流出遷移
| 遷移先 | トリガー | 条件 |
|--------|----------|------|
| 解説画面 | 履歴アイテムタップ | 履歴が存在する場合 |
```

**変換ルール:**
- 流入: Given = 遷移元画面, When = トリガー, Then = 本画面に遷移
- 流出: Given = 本画面 + 条件, When = トリガー, Then = 遷移先に遷移

### Step 5: UI状態から AC-S を抽出

**入力テーブル:**
```markdown
| 状態 | 条件 | Figma Node |
|------|------|------------|
| default | データが正常に取得できた場合 | `1234:5679` |
| empty | データが0件の場合 | `1234:5680` |
```

**変換ルール:**
- 各状態 → Given: 状態の条件, When: 画面表示, Then: 対応する表示

### Step 6: APIマッピングから AC-A を抽出

**入力テーブル:**
```markdown
| HTML要素 | APIフィールド | 変換処理 |
|----------|---------------|----------|
| `.month-header` | `year_month` | フォーマット |
```

**変換ルール:**
- 変換処理あり → Given: APIレスポンス, When: 表示, Then: 変換後の形式で表示

### Step 7: 表示条件・リストデータから AC-E を抽出

**入力テーブル:**
```markdown
| リストID | 最小件数 | 最大件数 | 空時の表示 |
|----------|----------|----------|------------|
| histories | 0 | 無制限 | 空状態画面 |
```

**変換ルール:**
- 空時の表示 → Given: データ0件, When: 表示, Then: 空状態画面
- 最大件数有限 → Given: 最大件数超過, When: 表示, Then: ページネーション/スクロール

### Step 8: 重複排除・優先度設定

1. **重複排除**: 同じ Given-When-Then の組み合わせを排除
2. **優先度設定**:
   - 必須: 主要機能、正常系
   - 推奨: エラーハンドリング、エッジケース
   - 任意: 細かいUI状態

### Step 9: spec.md の「受け入れ要件」セクションを更新

1. セクションを特定（`## 受け入れ要件`）
2. ステータスを「完了 ✓」に更新
3. 内容を生成した要件に置換
4. 完了チェックリストを更新
5. 変更履歴に追記

## 詳細ガイド

詳細な情報は以下のファイルを参照してください：

- **[workflow.md](references/workflow.md)**: 詳細なワークフロー
- **[extraction-rules.md](references/extraction-rules.md)**: 抽出ルール詳細
- **[section-template.md](references/section-template.md)**: セクション出力テンプレート
- **[examples.md](references/examples.md)**: 具体例（履歴画面）

## 完了チェックリスト

生成後、以下を確認：

```
- [ ] spec.md の「受け入れ要件」セクションが更新されている
- [ ] ステータスが「完了 ✓」になっている
- [ ] 全カテゴリ（D/I/N/S/A/E）の要件が抽出されている
- [ ] 各要件に Given-When-Then が明記されている
- [ ] 各要件に優先度が設定されている
- [ ] 重複する要件がない
- [ ] 対象コンポーネント・APIが明記されている
- [ ] 完了チェックリストが更新されている
- [ ] 変更履歴に記録が追加されている
```

## 注意事項

### テスト項目セクションとの違い

| 観点 | テスト項目 | 受け入れ要件 |
|------|----------|-------------|
| 目的 | QA向けテスト手順 | TDD向け実装仕様 |
| 形式 | 操作→期待結果 | Given-When-Then |
| 粒度 | シナリオ単位 | テストケース単位 |
| 使用者 | QAエンジニア | 開発者 |

### 既存の受け入れ要件との整合

spec.md に既存の受け入れ要件がある場合：
1. 既存要件を保持
2. 新規抽出要件をマージ
3. 重複を排除
4. ID を再採番

### 他のセクションを変更しない

このスキルは「受け入れ要件」セクションのみを更新します。

## 参照

- **[workflow.md](references/workflow.md)**: 詳細なワークフロー
- **[extraction-rules.md](references/extraction-rules.md)**: 抽出ルール詳細
- **[section-template.md](references/section-template.md)**: セクション出力テンプレート
- **[examples.md](references/examples.md)**: 具体例
- **[managing-screen-specs](../managing-screen-specs/SKILL.md)**: 仕様書管理スキル
