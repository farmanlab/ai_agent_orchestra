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

### Claude Code Rules (`.claude/rules/`)

```yaml
---
description: What this rule enforces. Use when...
paths: "**/*.{ts,tsx}"    # カンマ区切り、ブレース展開可
---
```

### Cursor Rules (`.cursor/rules/`)

```yaml
---
description: What this rule does
alwaysApply: false           # description/globs があれば false
globs: "**/*.ts,**/*.tsx"    # カンマ区切り、単一行
---
```

**ルールタイプ**:

| タイプ | 適用条件 | 設定 |
|--------|---------|------|
| Always Apply | 全チャットセッション | `alwaysApply: true` |
| Apply Intelligently | Agent判断 | `description` のみ |
| Apply to Specific Files | ファイルパターン | `globs` 指定 |
| Apply Manually | @メンション時 | 両方なし |

### GitHub Copilot (`.github/`)

```yaml
---
applyTo: "**/*.ts,**/*.tsx"  # カンマ区切り
---
```

## ファイルサイズ

| エージェント | 上限 |
|------------|------|
| Cursor | 500行 |
| Copilot | 2ページ (~1000行) |
| Claude | 制限なし（500行推奨） |

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
