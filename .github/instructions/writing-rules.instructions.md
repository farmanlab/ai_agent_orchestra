---
applyTo:  ".agents/rules/**/*.md"
---


# Writing Rules

`.agents/rules/` にルールを作成・編集する際の規約。

## 命名規則

- 小文字・数字・ハイフンのみ
- 内容を明確に表す名前
- 64文字以内

```
# Good
architecture.md
testing.md
writing-skills.md

# Avoid
rules.md       # 曖昧
misc.md        # 曖昧
```

## メタデータ要件

`.agents/rules/` に作成するファイルの共通形式:

```yaml
---
description: What this rule enforces. Use when...  # 第三人称 + トリガー
paths: "**/*.{ts,tsx}"                             # 対象ファイルパターン
---
```

| フィールド | 必須 | 説明 |
|-----------|------|------|
| `description` | ✓ | 第三人称で記述、トリガー含む |
| `paths` | - | 対象ファイルパターン（glob形式） |

**paths の書き方**:
- カンマ区切り: `"**/*.ts,**/*.tsx"`
- ブレース展開: `"**/*.{ts,tsx}"`
- 省略時: 全ファイルに適用

**Note**: sync 実行時にエージェント別形式に自動変換されます。

## ファイルサイズ

**推奨: 500行以下**

超過する場合は Progressive Disclosure で分割。

## 必須構成要素

1. **目的**: このルールが何を強制するか
2. **適用範囲**: どのファイル/場面に適用するか
3. **具体例**: Good/Bad の比較

## 具体例パターン

```markdown
## Examples

### Bad

\```typescript
// bad code
\```

### Good

\```typescript
// good code
\```

**Why**: [explanation]
```

## スコープの適切性

**タスク非依存であること**:

```markdown
# Bad - タスク固有
Fix the bug in login.js line 42

# Good - リポジトリレベル
Authentication logic should validate tokens before processing
```

## テンプレート

```yaml
---
description: Enforces X. Use when Y.
paths: "**/*.{ts,tsx}"
---

# Rule Title

## Purpose

This rule enforces [purpose].

## Scope

- TypeScript/TSX files
- [specific use cases]

## Rules

### Required

1. [Rule 1]
2. [Rule 2]

### Recommended

- [Recommendation 1]

## Examples

### Bad

\```typescript
// bad code
\```

### Good

\```typescript
// good code
\```

**Why**: [explanation]
```
