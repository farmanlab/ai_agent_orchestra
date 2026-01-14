---
name: explain-pr
description: Explains GitHub PR changes based on user's technical proficiency level. Use when reviewing or learning from pull request changes.
---

# Explain PR Command

## 目次

1. [概要](#概要)
2. [使用方法](#使用方法)
3. [実行手順](#実行手順)
   - [Step 1: PR情報の取得](#step-1-pr情報の取得)
   - [Step 2: カテゴリ自動検出と習熟度確認](#step-2-カテゴリ自動検出と習熟度確認)
   - [Step 3: カテゴリ別の解説生成](#step-3-カテゴリ別の解説生成)
   - [Step 4: 出力とフィードバック](#step-4-出力とフィードバック)
   - [Step 5: レビュー指摘の提案](#step-5-レビュー指摘の提案)
4. [習熟度設定ファイル](#習熟度設定ファイル)
5. [エラーハンドリング](#エラーハンドリング)

---

## 概要

このコマンドは、GitHub PRのURLを受け取り、その変更内容をユーザーの技術レベルに応じて適切な詳細度で解説します。

**特徴**:
- PRの内容から関連カテゴリを**自動検出**
- カテゴリ別（言語、インフラ、ライブラリ、サービス、ドメイン）に習熟度を設定可能
- 設定は `.agents/memory/proficiency.yaml` に保存され、次回以降のデフォルト値として使用

## 使用方法

```bash
/explain-pr <pr-url>
```

**引数**:

- `pr-url` (必須): GitHub PRのURL
  - 例: `https://github.com/owner/repo/pull/123`

**使用例**:

```bash
/explain-pr https://github.com/quipper/monorepo/pull/135963
```

## 実行手順

### Step 1: PR情報の取得

GitHub CLIを使用してPR情報を取得します。

```bash
# PRの基本情報を取得
gh pr view <pr-url> --json title,body,author,additions,deletions,files,baseRefName,headRefName

# PRの差分を取得
gh pr diff <pr-url>
```

### Step 2: カテゴリ自動検出と習熟度確認

#### 2.1 カテゴリの自動検出

PRの差分から関連するカテゴリを自動検出します。

**検出ルール**:

| カテゴリ | 検出方法 |
|---------|---------|
| **language** | ファイル拡張子（`.ts`→typescript, `.go`→go, `.py`→python） |
| **infrastructure** | パス（`kubernetes/`, `terraform/`）、キーワード（datadog, aws） |
| **library** | package.json の dependencies、import 文 |
| **service** | ファイルパスのトップディレクトリ（モノレポ内のサービス名） |
| **domain** | キーワード（trace/apm→observability, auth→authentication） |

**検出例（PR #135963）**:

```yaml
detected:
  language: [typescript, javascript]
  infrastructure: [datadog, observability]
  library: [prisma, dd-trace, sentry]
  service: [early-admission]
  domain: [observability]
```

#### 2.2 習熟度設定の読み込み

`.agents/memory/proficiency.yaml` から既存の設定を読み込みます。

```bash
Read: .agents/memory/proficiency.yaml
```

#### 2.3 デフォルト値の提示と確認

検出したカテゴリごとに、設定された習熟度をデフォルト値として提示します。

**設定がある場合**:
```
このPRに関連するカテゴリと習熟度設定:

| カテゴリ | 項目 | 設定値 |
|---------|------|--------|
| language | typescript | intermediate (設定済み) |
| infrastructure | datadog | beginner (デフォルト) |
| library | prisma | intermediate (設定済み) |
| service | early-admission | beginner (デフォルト) |
| domain | observability | beginner (デフォルト) |

この設定で解説しますか？変更したい場合は指定してください。
```

**設定がない場合（省略不可）**:

`AskUserQuestion` ツールで必ず確認:

```
以下のカテゴリの習熟度を設定してください（初回のみ）:

1. typescript: beginner / intermediate / advanced ?
2. datadog: beginner / intermediate / advanced ?
...
```

#### 2.4 設定の保存

ユーザーが指定した習熟度を `.agents/memory/proficiency.yaml` に保存します。

```bash
Edit: .agents/memory/proficiency.yaml
# 新しい設定を追加
```

### Step 3: カテゴリ別の解説生成

各カテゴリの習熟度に応じて、説明の詳細度を調整します。

#### 習熟度レベル別の解説方針

| レベル | 焦点 | 解説スタイル |
|--------|------|-------------|
| **beginner** | What/Why | 用語解説、各行にコメント、参考リソース |
| **intermediate** | How | 設計判断、ベストプラクティス、代替案との比較 |
| **advanced** | Impact | アーキテクチャ影響、パフォーマンス、改善提案 |

#### 出力構造

```markdown
## 変更の概要

[全体像を簡潔に説明]

## 詳細解説

### [ファイル名]

**関連カテゴリ**: language:typescript(intermediate), library:prisma(beginner)

#### TypeScript観点 (intermediate)
[設計判断や実装の詳細を解説]

#### Prisma観点 (beginner)
[Prisma Instrumentationとは何か、各オプションの意味を丁寧に解説]

---

### [次のファイル]
...
```

#### 解説例（PR #135963 の instrument.js）

**dd-trace (beginner)** の場合:
```markdown
#### Datadog APM (beginner)

**dd-trace とは？**
Datadog APM（Application Performance Monitoring）用のトレーシングライブラリです。
アプリケーション内の処理を可視化し、パフォーマンス問題を特定できます。

**コード解説**:
```javascript
tracer.init({
  profiling: true,      // CPU/メモリプロファイリングを有効化
  logInjection: true,   // ログにトレースIDを自動挿入
  runtimeMetrics: true, // Node.jsランタイムメトリクスを収集
  dbmPropagationMode: 'full', // DB監視との連携を有効化
});
```

**参考リソース**:
- [Datadog APM公式ドキュメント](https://docs.datadoghq.com/tracing/)
```

**TypeScript (intermediate)** の場合:
```markdown
#### TypeScript/Node.js (intermediate)

**設計判断**:
- `instrument.js` を分離し、アプリケーション起動前にトレーサーを初期化
- `--import` フラグで ESM 環境でも確実に最初に読み込まれる

**ベストプラクティス**:
- dd-trace は他のモジュールより先にインポートする必要がある（モンキーパッチのため）
- blocklist で不要なトレース（Sentry通信など）を除外
```

### Step 4: 出力とフィードバック

```markdown
# PR解説: [PR タイトル]

**PR URL**: [URL]
**解説日時**: [日時]

## 習熟度設定

| カテゴリ | 項目 | レベル |
|---------|------|--------|
| language | typescript | intermediate |
| infrastructure | datadog | beginner |
| ... | ... | ... |

[カテゴリ別の解説内容]

---

## 次のステップ

- 習熟度設定を変更したい場合は、`.agents/memory/proficiency.yaml` を編集
- 特定のカテゴリだけ詳しく聞きたい場合は「datadog についてもっと詳しく」と指定

## 質問やフィードバック

この解説で不明な点があれば、お気軽にご質問ください。
```

### Step 5: レビュー指摘の提案

解説完了後、PRに対する指摘事項があるかをユーザーに提案します。

#### 5.1 提案の確認

解説出力の最後に以下を追加:

```markdown
---

## レビュー指摘の提案

このPRについて、気になる点や改善提案があります。
レビューコメントとして使える形式で出力しますか？

👉 「はい」または「指摘を見せて」と返答してください
```

#### 5.2 指摘事項のラベリング

ユーザーが承諾した場合、以下の3段階でラベリングして出力:

| ラベル | 意味 | 対応の必要性 |
|--------|------|-------------|
| **MUST** | 修正必須 | セキュリティ問題、バグ、重大な設計ミス |
| **IMO** | 意見・提案 | より良い実装方法、設計改善の提案 |
| **nits** | 軽微な指摘 | typo、命名、フォーマット等 |

#### 5.3 出力フォーマット

```markdown
## レビュー指摘事項

### MUST (修正必須)

1. **[ファイル名:行番号]** セキュリティ: ハードコードされた認証情報
   > 認証情報が平文で含まれています。環境変数または Secrets Manager を使用してください。

### IMO (提案)

1. **[ファイル名:行番号]** 可読性: 変数名の改善
   > `data` よりも `userCredentials` の方が意図が明確です。

2. **[ファイル名:行番号]** パフォーマンス: N+1クエリの可能性
   > ループ内でクエリを発行しています。`include` を使用した一括取得を検討してください。

### nits (軽微)

1. **[ファイル名:行番号]** typo: `recieve` → `receive`

---

💡 これらの指摘をPRコメントとして投稿しますか？
```

#### 5.4 指摘の観点

レビュー時に確認する観点:

| カテゴリ | チェック項目 |
|---------|-------------|
| **セキュリティ** | 認証情報のハードコード、インジェクション、権限チェック |
| **バグ** | エッジケース、null/undefined処理、型不一致 |
| **設計** | 責務の分離、DRY原則、依存関係 |
| **パフォーマンス** | N+1クエリ、不要なループ、メモリリーク |
| **可読性** | 命名、複雑度、マジックナンバー |
| **テスト** | テストカバレッジ、エッジケースのテスト |
| **ドキュメント** | 必要なコメント、API仕様との整合性 |

#### 5.5 指摘がない場合

```markdown
---

## レビュー指摘の提案

このPRを確認しましたが、特に指摘すべき事項は見つかりませんでした。
コードは適切に実装されています。
```

---

## 習熟度設定ファイル

### 保存場所

```
.agents/memory/proficiency.yaml
```

### ファイル構造

```yaml
# カテゴリ別習熟度
language:
  typescript: intermediate
  javascript: intermediate
  go: beginner

infrastructure:
  kubernetes: beginner
  datadog: beginner

library:
  prisma: intermediate
  react: advanced

service:
  early-admission: beginner

domain:
  observability: beginner
  authentication: intermediate

# デフォルト値（未設定の項目に適用）
defaults:
  language: intermediate
  infrastructure: beginner
  library: beginner
  service: beginner
  domain: beginner
```

### 設定の優先順位

1. **明示的な設定** (`language.typescript: advanced`)
2. **カテゴリのデフォルト** (`defaults.language: intermediate`)
3. **確認必須** (どちらもない場合は省略不可、ユーザーに確認)

---

## エラーハンドリング

**PR URLが無効な場合**:

```text
指定されたURLが無効です。以下の形式で指定してください:
https://github.com/owner/repo/pull/123
```

**GitHub CLIがインストールされていない場合**:

```text
GitHub CLI (gh) がインストールされていません。
インストール方法: https://cli.github.com/
```

**認証エラーの場合**:

```bash
gh auth login
```

**習熟度設定ファイルが存在しない場合**:

```text
習熟度設定ファイルが見つかりません。
初期設定を行いますか？ (Y/n)
```

→ Y の場合、`.agents/memory/proficiency.yaml` を作成
