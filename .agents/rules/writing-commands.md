---
description: Enforces command file conventions. Use when creating, editing, or reviewing files in .agents/commands/.
paths: ".agents/commands/**/*.md"
---

# Writing Commands

`.agents/commands/` にコマンドを作成・編集する際の規約。

## 命名規則

- 小文字・数字・ハイフンのみ
- 動作を明確に表す動詞形
- 64文字以内

```
# Good
explain-pr
commit
review-code

# Avoid
helper
cmd1
do-stuff
```

## メタデータ要件

```yaml
---
name: command-name
description: Does X when invoked. Use when Y.  # 第三人称 + トリガー
---
```

### description の書き方

```yaml
# Bad
description: Helps with commits

# Good
description: Creates a commit with conventional format. Use when committing changes.
```

## ファイルサイズ

- 500行以下推奨
- 複雑なロジックはスキルに分離

## 必須構成要素

1. **概要**: コマンドの目的（1-2文）
2. **使用方法**: 構文と引数
3. **実行手順**: ステップ形式
4. **出力例**: 期待する結果

## 使用方法セクション

```markdown
## Usage

\```bash
/command-name <required-arg> [optional-arg]
\```

**Arguments**:
- `required-arg` (必須): Description
- `optional-arg` (省略可): Description, default: value

**Examples**:
\```bash
/command-name https://github.com/org/repo/pull/123
/command-name https://github.com/org/repo/pull/123 advanced
\```
```

## 実行手順

```markdown
## Process

### Step 1: Validate Input

[validation logic]

### Step 2: Execute

[main logic]

### Step 3: Output Results

[output generation]

If Step 2 fails, [error handling].
```

## エラーハンドリング

```markdown
## Error Handling

**Invalid input**:
\```
Error: Invalid URL format. Expected: https://github.com/owner/repo/pull/123
\```

**Authentication required**:
\```bash
gh auth login
\```
```

## テンプレート

```yaml
---
name: command-name
description: Does X. Use when Y.
---

# Command Title

## Overview

This command executes [purpose].

## Usage

\```bash
/command-name <arg1> [arg2]
\```

**Arguments**:
- `arg1` (必須): Description
- `arg2` (省略可): Description

## Process

### Step 1: ...

[instructions]

### Step 2: ...

[instructions]

If Step 2 fails, [recovery].

## Output Example

\```
Expected output here
\```

## Error Handling

**Error case**:
\```
Error message and recovery steps
\```
```
