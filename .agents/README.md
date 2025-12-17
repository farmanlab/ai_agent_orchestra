# AI Coding Agent 統一管理システム

Claude Code, Cursor, GitHub Copilot のエージェント設定を単一ソースから管理するシステム。

## 設計思想

```
Single Source of Truth (.agents/) → 各エージェント固有形式へ変換
```

### サポート対象

| エージェント | Rules | Skills | Subagents |
|-------------|-------|--------|-----------|
| Claude Code | ✅ .claude/rules/*.md | ✅ .claude/skills/ | ✅ .claude/agents/ |
| Cursor | ✅ .cursor/rules/*.mdc | ✅ .cursor/rules/skill-*/ | ✅ Agent mode |
| GitHub Copilot | ✅ .github/copilot-instructions.md | ❌ (非サポート) | ✅ AGENTS.md |

### クロスプラットフォーム互換性

#### CLAUDE.md 互換性

`CLAUDE.md` ファイルをリポジトリルートに配置すると、以下の両方で自動読み込みされます：
- **Claude Code** - ネイティブサポート
- **GitHub Copilot coding agent** - ネイティブサポート（2025年8月〜）

これにより、単一ファイルで複数のエージェントに指示を提供できます。

## フォルダ構成

```
.agents/
├── README.md                    # このファイル
├── config.yaml                  # 同期設定（オプション）
│
├── rules/                       # 統一ルール定義
│   ├── _base.md                 # 共通ベースルール
│   ├── architecture.md          # アーキテクチャ原則
│   ├── testing.md               # テスト規約
│   └── {domain}.md              # ドメイン固有ルール
│
├── skills/                      # 統一スキル定義
│   ├── {skill-name}/
│   │   ├── SKILL.md             # エントリーポイント
│   │   ├── patterns.md          # パターン集
│   │   ├── checklist.md         # チェックリスト
│   │   └── scripts/             # 実行スクリプト（オプション）
│   └── ...
│
├── agents/                      # 統一サブエージェント定義
│   ├── code-reviewer.md
│   ├── implementer.md
│   └── researcher.md
│
├── commands/                    # 統一コマンド定義（Slash Commands）
│   ├── pr-review.md             # /pr-review コマンド
│   └── {command-name}.md        # その他のコマンド
│
└── sync/                        # 同期スクリプト
    ├── sync.sh                  # メイン同期スクリプト
    ├── to-claude.sh             # Claude Code用変換
    ├── to-cursor.sh             # Cursor用変換
    └── to-copilot.sh            # GitHub Copilot用変換
```

## 統一ファイル形式

### 1. Rules (.agents/rules/*.md)

```markdown
---
# メタデータ (YAML frontmatter)
name: rule-name
description: ルールの説明
paths:                              # 適用対象 (オプション)
  - "**/*.ts"
  - "**/*.js"
  - "**/*.py"
agents: [claude, cursor, copilot]  # 対象エージェント
priority: 100                       # 優先度 (高い順)
---

# Rule Content

ルールの本文...
```

**注意**: 統一形式では `paths` を YAML 配列形式で記述します。各エージェント向けに変換される際に適切な形式に自動変換されます。

### 2. Skills (.agents/skills/{name}/SKILL.md)

```markdown
---
name: skill-name
description: スキルの説明
triggers: [keyword1, keyword2]     # 自動検出用キーワード
agents: [claude, cursor]           # copilot は Skills 非サポート
---

# Skill Content

## When to Use
このスキルを使うタイミング...

## Golden Pattern
推奨される手順...

## Reference Files
- [patterns.md](patterns.md)
- [checklist.md](checklist.md)
```

> **Note**: GitHub Copilot は triggers による自動読み込み機能を持たないため、Skills は claude/cursor 専用です。

### 3. Agents (.agents/agents/*.md)

```markdown
---
name: agent-name
description: エージェントの説明
tools: [Read, Grep, Glob]          # Claude Code用
model: sonnet                       # Claude Code用
agents: [claude, copilot]
---

# Agent Prompt

あなたは〜として...
```

### 4. Commands (.agents/commands/*.md)

Slash Commands（`/command-name`）として実行可能なコマンドを定義します。

```markdown
---
description: コマンドの説明
argument-hint: [引数のヒント]      # オプション
allowed-tools: [Tool1, Tool2, ...]  # Claude Code用（オプション）
---

# Command Name

## 指示

コマンドの詳細な指示...

## 手順

1. 最初のステップ
2. 次のステップ
...
```

## 使用方法

### 初期セットアップ

```bash
# リポジトリルートで実行
.agents/sync/sync.sh init
```

### 同期実行

```bash
# 全エージェント向けに同期
.agents/sync/sync.sh all

# 特定エージェントのみ
.agents/sync/sync.sh claude
.agents/sync/sync.sh cursor
.agents/sync/sync.sh copilot
```

### Git Hooks 設定（推奨）

```bash
# pre-commit hookで自動同期
.agents/sync/sync.sh install-hooks
```

コミット時に自動的に同期されるようになります。

### その他のコマンド

```bash
# 詳細ログ表示
.agents/sync/sync.sh --verbose all

# ドライラン（実際には変更しない）
.agents/sync/sync.sh --dry-run all

# 生成ファイルをクリーンアップ
.agents/sync/sync.sh clean
```

## 変換ルール

### Rules 変換

| 統一形式 | Claude Code | Cursor | Copilot |
|---------|-------------|--------|---------|
| `_base.md` | .claude/rules/_base.md | .cursor/rules/_base/RULE.md | copilot-instructions.md に統合 |
| `{name}.md` | .claude/rules/{name}.md | .cursor/rules/{name}/RULE.md | instructions/{name}.instructions.md |
| `paths` (YAML配列) | `paths` (YAML配列) | `globs` (カンマ区切り単一行) | `applyTo` (カンマ区切り単一行) |

**形式の違い**:
- `.agents/rules/`: `paths:` + YAML配列形式（`- "**/*.ts"`）+ 他のメタデータ（`name`, `agents`, `priority`）
- `.claude/rules/`: `paths:` + YAML配列形式（そのまま維持）
- `.cursor/rules/`: `description`と`alwaysApply`（と`globs`）のみ、`globs`はカンマ区切り単一行
- `.github/instructions/`: `applyTo:` + カンマ区切り単一行（`"**/*.ts", "**/*.js"`）

**重要**:
- Cursor の RULE.md には `name`, `triggers`, `agents`, `priority` などは不要で、`description`, `alwaysApply`, `globs` のみが有効です
- `alwaysApply` の自動判定ルール：
  - `description` または `globs` が指定されている場合: `alwaysApply: false`
  - どちらも指定されていない場合: `alwaysApply: true`（実質的にはほぼ使われない）
- **適用範囲の優先順位**：
  - `globs` が指定されている場合: `globs` パターンに一致するファイルのみに適用
  - `globs` がなく `description` のみの場合: 全ファイルに適用
  - `description` と `globs` の両方がある場合: `globs` が優先され、パターンに一致するファイルのみに適用

### Skills 変換

| 統一形式 | Claude Code | Cursor | Copilot |
|---------|-------------|--------|---------|
| `SKILL.md` | SKILL.md (変換) + 補助ファイル (symlink) | RULE.md (変換) + 補助ファイル (symlink) | ❌ 非サポート |
| frontmatter | `name`, `description`, `allowed-tools`のみ | `description`と`alwaysApply`のみ | — |
| フォルダ構造 | ディレクトリ構造維持 | ディレクトリ構造維持 | — |
| Progressive disclosure | ✅ 完全維持 | ✅ 完全維持 | — |

> **Note**:
> - Claude Code の SKILL.md frontmatter には `name`, `description`, `allowed-tools` のみが有効（自動変換される）
> - Cursor v2.2+ では `.cursor/rules/skill-name/RULE.md` 形式で Progressive disclosure をサポート
> - Cursor の RULE.md frontmatter には `description`と`alwaysApply`のみが有効（自動変換される）
> - GitHub Copilot は Skills の自動読み込み機能（triggers）を持たないため、変換対象外

### Agents 変換

| 統一形式 | Claude Code | Cursor | Copilot |
|---------|-------------|--------|---------|
| `{name}.md` | .claude/agents/{name}.md | （未サポート） | AGENTS.md へ統合 |
| `tools`, `model` | 保持 | — | 削除 |

### Commands 変換

| 統一形式 | Claude Code | Cursor | Copilot |
|---------|-------------|--------|---------|
| `{name}.md` | .claude/commands/{name}.md | .cursor/commands/{name}.md | .github/prompts/{name}.prompt.md |
| フォーマット | そのまま | そのまま | .prompt.md 拡張子 |
| 用途 | Slash Commands | Slash Commands | GitHub Prompts |

## 生成されるファイル

同期後、以下のファイルが自動生成されます：

```
project/
├── .agents/                      # ソース（編集対象）
│   ├── rules/*.md
│   ├── skills/*/
│   ├── agents/*.md
│   └── commands/*.md
│
├── CLAUDE.md                     # Claude Code + Copilot 共通 ⭐
│
├── .claude/                      # Claude Code 用
│   ├── rules/                    # モジュラールール
│   ├── skills/                   # Skills
│   ├── agents/                   # Subagents
│   └── commands/                 # Slash Commands
│
├── .cursor/
│   ├── rules/*.mdc               # Cursor 用 Rules
│   └── commands/*.md             # Cursor 用 Slash Commands
│
├── .github/
│   ├── copilot-instructions.md   # Copilot 用メイン
│   ├── instructions/*.instructions.md # パス指定 Instructions
│   └── prompts/*.prompt.md       # GitHub Prompts
│
└── AGENTS.md                     # Copilot Coding Agent 用
```

## 日常的なワークフロー

### ルールを追加/編集

```bash
# 1. ソースを編集
vim .agents/rules/new-rule.md

# 2. 同期
.agents/sync/sync.sh all

# 3. コミット
git add .agents/ .claude/ .cursor/ .github/ CLAUDE.md AGENTS.md
git commit -m "Add new-rule"
```

### スキルを追加

```bash
# 1. スキルフォルダ作成
mkdir -p .agents/skills/my-skill

# 2. SKILL.md 作成
cat > .agents/skills/my-skill/SKILL.md << 'EOF'
---
name: my-skill
description: スキルの説明
triggers: [keyword1, keyword2]
agents: [claude, cursor]
---

# My Skill

スキルの内容...
EOF

# 3. 同期
.agents/sync/sync.sh all
```

## ベストプラクティス

### 1. ルールは簡潔に
- 1ファイル150行以内推奨
- 箇条書きより具体例
- 重複を避ける

### 2. スキルはモジュール化
- 1スキル1責務
- Progressive disclosure を意識
- 実行コードは scripts/ に分離

### 3. エージェントは目的特化
- 明確な description
- 必要最小限の tools
- 具体的な output format

### 4. Git管理
- 生成ファイルも Git で管理（チーム共有のため）
- コミット前に必ず同期実行
- pre-commit hook の活用推奨

## トラブルシューティング

### 同期が動かない

```bash
# 権限確認
ls -la .agents/sync/sync.sh

# 実行権限付与
chmod +x .agents/sync/*.sh

# 詳細ログで実行
.agents/sync/sync.sh --verbose all
```

### 特定エージェントで認識されない

```bash
# 生成ファイルを確認
cat .cursor/rules/00-_base.mdc

# frontmatter の形式確認
# --- で始まり --- で終わる必要あり
```

### 変更が反映されない

- **Cursor**: Cursor を再起動
- **Claude Code**: 新しいセッションを開始
- **Copilot**: VS Code をリロード

## 関連ドキュメント

- [Claude Code Memory Management](https://code.claude.com/docs/en/memory)
- [Cursor Rules](https://docs.cursor.com/context/rules)
- [GitHub Copilot Custom Instructions](https://docs.github.com/en/copilot/customizing-copilot/adding-custom-instructions-for-github-copilot)
