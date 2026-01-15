---
name: review-session
description: Reviews session to detect corrections, uncertainties, and patterns for rule improvements. Use at session end or manually when reflecting on session learnings.
argument-hint: [transcript-path] (optional, uses current session if omitted)
allowed-tools: Read, Glob, Grep, Write, AskUserQuestion, Bash(echo:*)
---

# セッション振り返り

## 目次

1. [概要](#概要)
2. [使用方法](#使用方法)
3. [手順](#手順)
   - [Step 0: ワーキングディレクトリの取得](#step-0-ワーキングディレクトリの取得)
   - [Step 1: Transcript取得](#step-1-transcript取得)
   - [Step 2: 会話内容の解析](#step-2-会話内容の解析)
   - [Step 3: 既存ルールとの比較](#step-3-既存ルールとの比較)
   - [Step 4: 改善提案の生成](#step-4-改善提案の生成)
   - [Step 5: ユーザー確認](#step-5-ユーザー確認)
   - [Step 6: 実行](#step-6-実行)
4. [検出パターン](#検出パターン)
5. [出力形式](#出力形式)
6. [Hook連携](#hook連携)

## 概要

セッション中のやりとりを振り返り、以下を検出してルール改善を提案する：

| 検出対象 | 説明 |
|----------|------|
| **修正フィードバック** | ユーザーから訂正された箇所 |
| **判断の迷い** | 複数の選択肢で迷った場面 |
| **暗黙のルール** | 明文化されていないが重要なパターン |
| **既存ルールとの矛盾** | 現行ルールと実践のギャップ |

## 使用方法

```bash
# 手動実行（現在のセッション）
/review-session

# transcript指定
/review-session /path/to/transcript.jsonl
```

**引数**:
- `transcript-path` (省略可): transcriptファイルパス。省略時は環境変数`$TRANSCRIPT_PATH`を使用

## 手順

### Step 0: ワーキングディレクトリの取得

```
1. 現在のワーキングディレクトリを取得（pwd）
2. 以下の情報を記録:
   - プロジェクトルート: $CWD または pwd の結果
   - .agents/ の存在確認: $CWD/.agents/
   - .cursor/rules/ の存在確認: $CWD/.cursor/rules/
3. ルール保存先を決定:
   - .agents/rules/ が存在する場合: そこに保存
   - 存在しない場合: ユーザーに確認
```

**取得する情報**:

| 項目 | 取得方法 | 用途 |
|------|----------|------|
| プロジェクトルート | `pwd` または `$CWD` | ルールファイルの保存先 |
| Git リポジトリ判定 | `.git/` の存在確認 | プロジェクト固有ルールか判定 |
| 既存ルールパス | `.agents/rules/` | 既存ルールとの比較 |

### Step 1: Transcript取得

```
1. $ARGUMENTS が指定されている場合: そのパスを使用
2. $ARGUMENTS が空の場合:
   - Hook経由: $TRANSCRIPT_PATH 環境変数を使用
   - 手動実行: 現在の会話履歴を使用
3. Transcriptが取得できない場合: エラー終了
```

### Step 2: 会話内容の解析

Transcript（JSONL形式）を解析し、以下のパターンを検出：

#### 2.1 修正フィードバックの検出

**検出キーワード**:
- 日本語: 「違う」「そうじゃなくて」「待って」「〜じゃなくて」「〜ではなく」
- 英語: "no,", "actually", "instead", "wait", "not that"

**記録項目**:
- 修正前のAI応答
- ユーザーの修正内容
- 修正後の正しい対応

#### 2.2 判断の迷いの検出

**検出パターン**:
- 複数オプションを提示した場面
- ユーザーに確認を求めた場面
- 前提条件が不明確だった場面

**記録項目**:
- 迷いの内容
- 最終的な判断
- 判断の根拠

#### 2.3 繰り返し指示の検出

**検出パターン**:
- 同じ内容の指示が2回以上
- 同じツール/手法の指定
- 同じフォーマットの要求

**記録項目**:
- 繰り返された指示内容
- 対応すべきルール案

#### 2.4 暗黙のルールの検出

**検出パターン**:
- 明示的な規約言及（「このプロジェクトでは」「いつも」「必ず」）
- 特定のワークフローの繰り返し
- トラブルシュート後の解決パターン

**記録項目**:
- 暗黙のルール内容
- ルール化すべきか判定

### Step 3: 既存ルールとの比較

```
1. .agents/rules/ 配下の既存ルールを読み込み
2. 検出したパターンと比較:
   - 既存ルールでカバーされているか
   - 既存ルールと矛盾していないか
   - 既存ルールの改善が必要か
3. 以下のいずれかを判定:
   - 新規ルール作成
   - 既存ルール更新
   - 対応不要
```

### Step 4: 改善提案の生成

検出結果を基に、以下を提案：

| アクション | 条件 |
|-----------|------|
| **新規ルール作成** | 既存ルールでカバーされていない重要パターン |
| **既存ルール更新** | 現行ルールと実践のギャップがある |
| **スキル作成** | 3ステップ以上の再利用可能なワークフロー |
| **対応不要** | 一度限りの特殊ケース |

### Step 5: ユーザー確認

AskUserQuestionツールを使用して各提案について確認：

- 「作成する」「更新する」「スキップ」の選択肢
- 修正したい場合は内容を編集

### Step 6: 実行

ユーザーが承認した提案を実行：

```
1. ファイル作成/更新
2. .agents/scripts/sync/sync.sh all でSync実行
3. 完了報告
```

## 検出パターン

### パターン1: 修正フィードバック

```
User: Prismaマイグレーションして
AI: npx prisma migrate dev を実行しました
User: 違う、SQLを先に確認したかった  ← 検出
```

**提案**:
```yaml
type: rule_update
target: .agents/rules/prisma-migration.md
content: |
  Prismaマイグレーション時はSQLを先に確認する
  1. npx prisma migrate dev --create-only
  2. SQLを確認
  3. npx prisma migrate dev
```

### パターン2: 判断の迷い

```
AI: ファイル構成について、以下のどちらにしますか？
    A) components/Button.tsx
    B) ui/Button.tsx
User: Aで
```

**提案**:
```yaml
type: new_rule
target: .agents/rules/file-structure.md
content: |
  コンポーネントは components/ ディレクトリに配置する
```

### パターン3: 繰り返し指示

```
User: pnpmでインストールして
AI: npm install を実行...
User: pnpmを使って  ← 検出（2回目）
```

**提案**:
```yaml
type: new_rule
target: .agents/rules/package-manager.md
content: |
  パッケージマネージャーはpnpmを使用する
```

### パターン4: 暗黙のルール

```
User: このプロジェクトではテストは必須です  ← 検出
```

**提案**:
```yaml
type: rule_update
target: .agents/rules/testing.md
content: |
  全ての変更にテストを含める（必須）
```

## 出力形式

### 検出サマリー

```markdown
## セッション振り返りレポート

### 検出結果

| カテゴリ | 件数 |
|----------|------|
| 修正フィードバック | N件 |
| 判断の迷い | N件 |
| 繰り返し指示 | N件 |
| 暗黙のルール | N件 |

### 改善提案

#### 提案 #1: [タイトル]

| 項目 | 内容 |
|------|------|
| 種別 | 新規ルール / ルール更新 / スキル |
| 検出理由 | [修正/迷い/繰り返し/暗黙] |
| 対象ファイル | `.agents/rules/[name].md` |

**内容:**
> [具体的な改善内容]

**根拠:**
> [検出された会話の要約]

---

[提案 #2, #3, ...]
```

### 完了報告

```markdown
## 実行結果

| アクション | ファイル | ステータス |
|-----------|----------|-----------|
| 作成 | .agents/rules/xxx.md | 完了 |
| 更新 | .agents/rules/yyy.md | 完了 |
| Sync | 全エージェント | 完了 |

次のステップ:
- 各エージェントで新ルールが適用されます
- 必要に応じて微調整してください
```

## Hook連携

このコマンドはClaude CodeのHookから自動呼び出し可能です。

### 環境変数

Hook経由で呼び出される場合、以下の環境変数が利用可能:

| 変数名 | 説明 |
|--------|------|
| `TRANSCRIPT_PATH` | セッションのtranscript JSONLファイルパス |
| `SESSION_ID` | セッションID |
| `CWD` | 作業ディレクトリ |

### Hook設定例

`.claude/settings.json`:

```json
{
  "hooks": {
    "Stop": [
      {
        "hooks": [
          {
            "type": "prompt",
            "prompt": "セッションを振り返り、ルール改善が必要か確認してください。改善提案がある場合のみユーザーに提示してください。",
            "timeout": 60
          }
        ]
      }
    ]
  }
}
```

### 設定ファイル

詳細なhook設定例は以下を参照:
- `.agents/hooks/review-session-claude.json` - Claude Code用
- `.agents/hooks/review-session-cursor.json` - Cursor用

## 注意事項

- 提案は最大5件まで（過度な提案を避ける）
- 既存ルールと重複する内容は提案しない
- セキュリティに関わる機密情報はルール化しない
- 一度限りの特殊ケースは対応不要と判定
