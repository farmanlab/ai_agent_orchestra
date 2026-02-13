---
description: Enforces skill file conventions. Use when creating, editing, or reviewing files in .agents/skills/.
paths: ".agents/skills/**/*.md"
---

# Writing Skills

`.agents/skills/` にスキルを作成・編集する際の規約。

## 命名規則

### Skill名

**gerund形式（-ing）を使用**:

```yaml
# Good
- processing-pdfs
- analyzing-spreadsheets
- managing-databases
- testing-code
- ensuring-prompt-quality

# Avoid
- helper
- utils
- pdf-processor
- data-handler
```

### name フィールド制約

| 制約 | ルール |
|------|--------|
| 文字数 | 1-64文字 |
| 使用可能文字 | 小文字 (a-z)、数字 (0-9)、ハイフン (-) |
| ハイフン | 先頭/末尾禁止、連続 (`--`) 禁止 |
| **ディレクトリ名一致** | `name` は親ディレクトリ名と一致必須 |

```yaml
# Good
name: pdf-processing     # ディレクトリ: pdf-processing/

# Bad
name: PDF-Processing     # 大文字禁止
name: -pdf               # 先頭ハイフン禁止
name: pdf--processing    # 連続ハイフン禁止
name: my-skill           # ディレクトリが other-name/ なら不一致
```

### ディレクトリ構成

```
.agents/skills/
└── skill-name/           # name フィールドと一致必須
    ├── SKILL.md          # 必須：エントリーポイント
    ├── scripts/          # オプション：実行スクリプト
    ├── references/       # オプション：詳細ドキュメント
    └── assets/           # オプション：テンプレート、静的リソース
```

### scripts/ フォルダ

**目的**: エージェントが実行可能なスクリプト

| 項目 | 内容 |
|------|------|
| 対応言語 | Python, Bash, JavaScript 等 |
| 命名 | 機能を明確に表す名前（`extract.py`, `validate.sh`） |
| 実行方式 | **Zero-context execution** - スクリプト内容はコンテキストに読み込まず、出力のみ取得 |

```
scripts/
├── extract.py        # データ抽出
├── validate.sh       # 検証スクリプト
└── transform.js      # データ変換
```

**要件**:
- 自己完結型（依存関係は明記）
- 適切なエラーメッセージ
- エッジケースの処理

### references/ フォルダ

**目的**: オンデマンドで読み込む詳細ドキュメント

| 項目 | 内容 |
|------|------|
| ファイル形式 | Markdown（`.md`） |
| 読み込み | 必要時のみ（トークン効率化） |
| 深さ | **1階層まで**（ネスト禁止） |

**推奨ファイル名（公式仕様）**:

| ファイル名 | 用途 |
|-----------|------|
| `REFERENCE.md` | 詳細な技術リファレンス |
| `FORMS.md` | フォームテンプレート、構造化データ形式 |
| `{domain}.md` | ドメイン固有ドキュメント（例: `finance.md`, `legal.md`） |

```
references/
├── REFERENCE.md      # 技術リファレンス（推奨）
├── FORMS.md          # フォームテンプレート（推奨）
├── patterns.md       # パターン集
└── examples.md       # 具体例
```

**ベストプラクティス**:
- 各ファイルは単一トピックに集中（自己完結型チャンク）
- 100行超は目次必須
- 小さいファイル = 少ないコンテキスト消費

### assets/ フォルダ

**目的**: テンプレート、画像、静的データ

| ファイル種別 | 例 |
|-------------|-----|
| テンプレート | `template.md`, `config.yaml` |
| 画像 | `diagram.png`, `flowchart.svg` |
| データ | `lookup-table.json`, `schema.json` |

```
assets/
├── template-report.md    # レポートテンプレート
├── config-example.yaml   # 設定例
└── lookup-table.json     # 参照データ
```

## メタデータ要件

### 必須フィールド

```yaml
---
name: doing-something           # 1-64文字、親ディレクトリ名と一致
description: Does X. Use when Y.  # 1-1024文字、第三人称、トリガー含む
---
```

### オプションフィールド

```yaml
---
name: doing-something
description: Does X. Use when Y.
license: Apache-2.0                    # ライセンス
compatibility: Requires git, docker    # 環境要件（1-500文字）
metadata:                              # 任意のキーバリュー
  author: example-org
  version: "1.0"
allowed-tools: [Read, Write, Bash]     # 実験的機能
---
```

| フィールド | 必須 | 制約 |
|-----------|------|------|
| `name` | ✓ | 1-64文字、ディレクトリ名一致 |
| `description` | ✓ | 1-1024文字 |
| `license` | - | ライセンス名 or ファイル参照 |
| `compatibility` | - | 1-500文字、環境要件 |
| `metadata` | - | 任意オブジェクト |
| `allowed-tools` | - | **実験的機能** |

### allowed-tools 詳細構文（実験的）

**基本形式:**

```yaml
allowed-tools: [Read, Write, Bash]          # 配列形式
allowed-tools: ["*"]                         # 全ツール許可
allowed-tools: ["*", "-Edit", "-Write"]     # 全許可から除外
allowed-tools: ["mcp__*"]                   # MCPツール全許可
```

**ワイルドカード:**

| パターン | 意味 | 例 |
|----------|------|-----|
| `*` | 全ツール許可 | すべて |
| `-ToolName` | 除外 | `-Edit` で編集禁止 |
| `mcp__*` | MCPサーバー全ツール | 全MCPツール |
| `mcp__server__*` | 特定サーバーの全ツール | `mcp__figma__*` |

**readonly パターン:**

```yaml
# 読み取り専用スキル
allowed-tools: ["*", "-Edit", "-Write", "-Bash"]
```

### description の書き方

**第三人称 + トリガー**:

```yaml
# Bad - 一人称
description: I can help you process Excel files

# Bad - 二人称
description: You can use this to process Excel files

# Bad - トリガーなし
description: Processes data

# Good
description: Processes Excel files and generates reports. Use when analyzing spreadsheets or .xlsx files.
```

## ファイルサイズ

| ファイル | 上限 | 備考 |
|---------|------|------|
| SKILL.md | 500行 | エントリーポイント |
| references/*.md | 制限なし | 100行超は目次必須 |

## Claude Code インポート構文

スキル内で他のファイルを参照する場合、`@path` 構文でインポート可能:

```markdown
## References

詳細は以下を参照:

@references/patterns.md
@references/examples.md
```

**特徴:**

- 相対パス（スキルディレクトリからの相対）
- ファイル内容がコンテキストに展開される
- 必要なときだけ読み込む遅延参照

**注意:** この構文はClaude Code固有。他エージェントでは通常のリンクを使用。

## Progressive Disclosure

**参照の深さは1階層まで**:

```
# Good: 1階層
SKILL.md → patterns.md (実際の情報)
        → examples.md (実際の情報)

# Bad: 2階層以上
SKILL.md → advanced.md → details.md → 実際の情報
```

## 必須構成要素

1. **概要**: 何をするスキルか（1-2段落）
2. **Workflow**: チェックリスト形式の手順
3. **具体例**: Before/After 形式

## Workflow パターン

````markdown
## Workflow

Copy this checklist:

```
Task Progress:
- [ ] Step 1: Analyze requirements
- [ ] Step 2: Design solution
- [ ] Step 3: Validate
```

**Step 1: Analyze requirements**
[詳細な手順]

If validation fails at Step 3, return to Step 2 and revise.
````

## テンプレート

```yaml
---
name: doing-something
description: Does X. Use when Y or Z.
license: MIT                           # オプション
compatibility: Requires git            # オプション
allowed-tools: [Read, Write, Bash]     # オプション（実験的）
---

# Skill Title

## Overview

This skill provides [purpose].

## Quick Start

\```language
# minimal example
\```

## References

- **`references/patterns.md`**: Pattern collection

## Workflow

Copy this checklist:

\```
Progress:
- [ ] Step 1: ...
- [ ] Step 2: ...
\```

**Step 1: ...**
[instructions]

If Step 1 fails, [recovery action].
```
