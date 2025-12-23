---
description: Enforces agent file conventions. Use when creating or editing files in .agents/agents/.

globs:  ".agents/agents/**/*.md"
alwaysApply: false
---


# Writing Agents

`.agents/agents/` にエージェントを作成・編集する際の規約。

## 命名規則

- 小文字・数字・ハイフンのみ
- 役割を明確に表す名前
- 64文字以内

```
# Good
code-reviewer
prompt-writer
researching-best-practices

# Avoid
helper
agent1
my-agent
```

## メタデータ要件

```yaml
---
name: agent-name
description: Does X as a specialized agent. Use when Y.  # 第三人称 + トリガー
tools: [Read, Write, Grep, Glob]   # 使用するツール
skills: [skill-name]               # 参照するスキル（オプション）
model: sonnet                      # 使用モデル（オプション）
---
```

### description の書き方

**第三人称 + トリガー**:

```yaml
# Bad - 一人称
description: I review code and provide feedback

# Bad - トリガーなし
description: Reviews code

# Good
description: Reviews code for architecture, quality, and security issues. Use when conducting PR reviews or quality checks.
```

## ファイルサイズ

- 500行以下推奨
- 超過する場合はスキルに分離して参照

## 必須構成要素

1. **役割**: 何を担当するエージェントか
2. **タスク**: 実行するタスクのリスト
3. **プロセス**: ステップ形式の手順
4. **出力形式**: 期待する出力のテンプレート

## スキル参照パターン

複雑なロジックはスキルに分離:

```markdown
## スキル参照

詳細な手順は以下のスキルを参照:

- **[skill-name](../skills/skill-name/SKILL.md)**: 機能説明
```

## プロセス記述

```markdown
## Process

### Step 1: Task Description

[詳細な手順]

Tools:
\```bash
Read: file_path="..."
Grep: pattern="..." path="..."
\```

### Step 2: Validation

[検証手順]

If validation fails, return to Step 1.
```

## 出力形式テンプレート

```markdown
## Output Format

\```markdown
# Report Title

## Summary
[summary]

## Details
- Detail 1
- Detail 2

## Recommendations
1. [recommendation]
\```
```

## テンプレート

```yaml
---
name: agent-name
description: Performs X. Use when Y or Z.
tools: [Read, Write, Grep, Glob]
skills: [relevant-skill]
---

# Agent Title

## Role

This agent handles [role].

## Skill References

- **[skill-name](../skills/skill-name/SKILL.md)**: Description

## Tasks

1. [Task 1]
2. [Task 2]

## Process

### Step 1: ...

[instructions]

### Step 2: ...

[instructions]

If Step 2 fails, return to Step 1.

## Output Format

\```markdown
# Title

## Summary
...
\```
```
