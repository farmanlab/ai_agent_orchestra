---
name: write-prompt
description: Creates new prompt files (rules, skills, agents, commands) following official best practices with independent quality review. Use when creating new AI agent configurations.
argument-hint: <type> <name> [description]
allowed-tools: Task, AskUserQuestion
---

# Write Prompt

新規のプロンプトファイルをベストプラクティスに従って作成し、独立した品質レビューを実施します。

## Overview

`prompt-writer` でファイルを作成し、`prompt-quality-checker` で別コンテキストからレビューするオーケストレーターコマンドです。自己レビューのバイアスを排除し、客観的な品質保証を行います。

## Usage

```bash
/write-prompt <type> <name> [description]
```

**Arguments**:
- `type` (必須): プロンプトの種類（rule, skill, agent, command）
- `name` (必須): プロンプトの名前（小文字・ハイフン区切り）
- `description` (省略可): 簡単な説明（対話で詳細をヒアリング）

**Examples**:
```bash
/write-prompt rule api-error-handling "APIエラーハンドリングの統一ルール"
/write-prompt skill testing-integration-tests
/write-prompt agent code-quality-reviewer
/write-prompt command analyze-dependencies
```

引数なしで実行すると、対話形式で要件をヒアリングします：
```bash
/write-prompt
```

## Process

```
Orchestration Flow:
- [ ] Step 1: 引数確認
- [ ] Step 2: prompt-writer でファイル作成
- [ ] Step 3: prompt-quality-checker で品質レビュー
- [ ] Step 4: レビュー結果判定（フィードバックループ）
- [ ] Step 5: 完了報告 + sync案内
```

### Step 1: 引数の確認

引数が提供された場合、それを初期情報として使用。
引数がない場合、AskUserQuestion で以下を質問：
- プロンプトの種類（rule, skill, agent, command）
- 名前
- 目的・用途

**バリデーション**:
- `type` は rule, skill, agent, command のいずれか
- `name` は小文字・数字・ハイフンのみ

### Step 2: prompt-writer でファイル作成

`prompt-writer` サブエージェントを起動してファイルを作成する。
品質チェックは行わず、作成に専念させる。

```
Task tool:
  subagent_type: prompt-writer
  description: Create new prompt file
  prompt: |
    Create a new {type} named '{name}'.

    Requirements:
    - Type: {type}
    - Name: {name}
    - Description: {description}

    Follow the prompt-writer process:
    1. Requirements gathering (if description is sparse, ask for details)
    2. Research existing patterns in .agents/
    3. Design and structure the prompt
    4. Create the file

    IMPORTANT: Do NOT perform quality checks. Quality review will be
    conducted separately by prompt-quality-checker.

    When done, report:
    - Created file path(s)
    - Brief summary of what was created
```

**期待する出力**: 作成されたファイルパスと概要

### Step 3: prompt-quality-checker で品質レビュー

Step 2 で作成されたファイルを、別コンテキストの `prompt-quality-checker` でレビューする。

```
Task tool:
  subagent_type: prompt-quality-checker
  description: Review created prompt file
  prompt: |
    Review the following prompt file for quality:
    - File: {created_file_path}

    Perform a focused review on this single file:
    1. Fetch latest best practices (Step 0)
    2. Evaluate against all 14 criteria
    3. Generate a quality report with score (0-100)

    Report must include:
    - Overall score (0-100)
    - Issues found (with severity: high/medium/low)
    - Specific improvement suggestions with line numbers
```

**期待する出力**: スコア（0-100）と問題点レポート

### Step 4: レビュー結果判定

スコアに応じて次のアクションを決定:

| スコア | アクション |
|--------|-----------|
| >= 70 | 完了 → Step 5 へ |
| < 70 | prompt-writer を再起動して修正（最大2回まで） |

**フィードバックループ** (スコア < 70 の場合):

```
Task tool:
  subagent_type: prompt-writer
  description: Fix prompt based on review
  prompt: |
    Fix the following prompt file based on quality review feedback:
    - File: {created_file_path}

    Review findings:
    {quality_report_issues}

    Instructions:
    1. Read the current file
    2. Address each issue listed above
    3. Write the corrected file
    4. Report what was changed

    Do NOT perform quality checks. Focus on fixing the reported issues.
```

修正後、Step 3 に戻って再レビュー。最大2回の修正サイクル後はスコアに関わらず完了とし、残課題をユーザーに報告する。

### Step 5: 完了報告

最終結果をユーザーに報告:

- 作成されたファイルパス
- 品質レビュースコアと結果サマリー
- 修正サイクルの回数（あれば）
- 残課題（あれば）
- 次のステップ（sync実行）

## Output Example

```markdown
## プロンプト作成完了

### 作成ファイル
- `.agents/rules/api-error-handling.md`

### 品質レビュー結果
- **スコア**: 82/100 (Good)
- **修正サイクル**: 1回（初回スコア: 58 → 修正後: 82）

#### 解決済みの問題
- description に "Use when..." トリガーを追加
- Before/After 形式のコード例を追加

#### 残課題（軽微）
- Progressive Disclosure の適用検討（現在420行）

### 次のステップ
1. 同期スクリプトを実行して各エージェントに反映
   ```bash
   .agents/scripts/sync/sync.sh all
   ```

2. 検証を実行
   ```bash
   .agents/scripts/sync/validate.sh
   ```
```

## Error Handling

**無効なtype**:
```
Error: Invalid type '{type}'. Expected: rule, skill, agent, or command
```

**無効な名前形式**:
```
Error: Invalid name '{name}'. Use lowercase letters, numbers, and hyphens only.
Example: api-error-handling
```

**エージェント起動失敗**:
```
Error: Failed to start agent.
Please try again or create the file manually using templates in .agents/templates/
```

**フィードバックループ上限到達**:
```
Note: Maximum revision cycles (2) reached. Score: {score}/100
Remaining issues are listed above for manual review.
```

## Notes

- このコマンドは `prompt-writer` と `prompt-quality-checker` のオーケストレーターです
- 品質チェックは別コンテキストで実行され、自己レビューのバイアスを排除します
- フィードバックループは最大2回まで（無限ループ防止）
- 作成後は必ず `sync.sh` で同期してください
