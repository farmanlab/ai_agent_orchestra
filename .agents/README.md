# AI Coding Agent 統一管理システム

Claude Code, GitHub Copilot のエージェント設定を単一ソースから管理するシステム。

## 設計思想

```
Single Source of Truth (.agents/) → 各エージェント固有形式へ変換
```

### サポート対象

| エージェント | Rules | Skills | Subagents | Commands |
|-------------|-------|--------|-----------|----------|
| Claude Code | ✅ .claude/rules/*.md | ✅ .claude/skills/* | ✅ .claude/agents/*.md | ✅ .claude/commands/ |
| GitHub Copilot | ✅ .github/copilot-instructions.md | ✅ .github/skills/* | ✅ .github/agents/*.agents.md | ✅ .github/prompts/ |

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
    └── to-copilot.sh            # GitHub Copilot用変換
```

## 統一ファイル形式

### 1. Rules (.agents/rules/*.md)

```markdown
---
# メタデータ (YAML frontmatter)
name: rule-name
description: ルールの説明
paths: "**/*.{ts,js,py}"            # 適用対象 (オプション、カンマ区切り)
---

# Rule Content

ルールの本文...
```

**注意**: `paths` はカンマ区切りの単一文字列で記述します（ブレース展開可）。各エージェント向けに変換される際、フィールド名のみ変換されます（Copilot: `applyTo`）。

### 2. Skills (.agents/skills/{name}/SKILL.md)

```markdown
---
name: skill-name
description: スキルの説明
triggers: [keyword1, keyword2]     # 自動検出用キーワード
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

> **Note**: GitHub Copilot は triggers による自動読み込み機能を持たないため、Skills は Claude Code 専用です。

### 3. Agents (.agents/agents/*.md)

```markdown
---
name: agent-name
description: エージェントの説明
tools: [Read, Grep, Glob]          # Claude Code用
model: sonnet                       # Claude Code用
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
.agents/scripts/sync/sync.sh init
```

### 同期実行

```bash
# 全エージェント向けに同期
.agents/scripts/sync/sync.sh all

# 特定エージェントのみ
.agents/scripts/sync/sync.sh claude
.agents/scripts/sync/sync.sh copilot
```

### 設定ファイルの検証

同期前に `.agents/` の構造とコンテンツを検証できます：

```bash
# 設定ファイルを検証
.agents/scripts/sync/sync.sh validate
```

**検証項目**:
- ディレクトリ構造の確認（rules, skills, agents, commands の存在）
- frontmatter の必須フィールド検証（name, description など）
- ファイル命名規則の確認
- YAML 構文の検証（frontmatter の区切りが正しいか）
- Skills の構造検証（SKILL.md の存在）

エラーが見つかった場合は終了コード 1 で終了します。警告のみの場合は終了コード 0 で終了します。

### プロンプトサイズのチェック

ファイルサイズとトークン数を計測し、肥大化を防ぎます：

```bash
# プロンプトサイズをチェック
.agents/scripts/sync/sync.sh check-size
```

**チェック項目**:
- 各ファイルの行数、文字数、バイト数
- 推定トークン数（1トークン ≈ 4文字として計算）
- カテゴリ別の集計（rules, skills, agents, commands）
- 合計トークン数

**デフォルトしきい値**:
- 単一ファイル警告: 500行 または 2000トークン
- 単一ファイルエラー: 1000行 または 4000トークン
- 全体警告: 10000トークン
- 全体エラー: 20000トークン

しきい値を超えた場合、ファイル分割や progressive disclosure の活用を推奨します。

### プロンプト品質のチェック

ベストプラクティスに基づいてプロンプト構成を検証します：

```bash
# 高速な静的チェック
.agents/scripts/sync/sync.sh check-quality
```

**検証観点**:
1. **明確性**: 曖昧な表現（「できれば」「なるべく」など）の検出
2. **構造化**: 適切な見出し階層とセクション分け
3. **具体例**: コード例や Before/After の提供
4. **スコープ**: タスク固有でなく汎用的な指針か
5. **Progressive Disclosure**: 詳細情報の適切な分離
6. **重複回避**: 複数ファイル間での重複・矛盾の検出
7. **ファイル命名**: 内容を明確に表す命名
8. **アクション指向**: 実行可能な指示の提供
9. **メタデータ**: frontmatter の完全性
10. **トーン**: 一貫したプロフェッショナルな文体

**公式ベストプラクティス準拠**:
- GitHub Copilot: 最大2ページ、タスク非依存、明確で簡潔
- Claude Code: 具体的なコンテキスト、構造化形式

**問題の優先度**:
- 🔴 高: 必須メタデータ欠落、過度なサイズ超過
- 🟡 中: 構造不備、曖昧な表現、progressive disclosure 未活用
- 🟢 低: アクション指向性の低さ、軽微な改善提案

#### 詳細な品質チェック（プラグイン）

より詳細な14観点での品質検証は `prompt-engineering` プラグインを使用してください：

```bash
claude --plugin-dir plugins/prompt-engineering
# @prompt-quality-checker で品質チェック実行
```

詳しくは [plugins/prompt-engineering/README.md](../plugins/prompt-engineering/README.md) を参照。

### Git Hooks 設定（推奨）

```bash
# pre-commit hookで自動同期
.agents/scripts/sync/sync.sh install-hooks
```

コミット時に自動的に同期されるようになります。

### その他のコマンド

```bash
# 詳細ログ表示
.agents/scripts/sync/sync.sh --verbose all

# ドライラン（実際には変更しない）
.agents/scripts/sync/sync.sh --dry-run all

# 生成ファイルをクリーンアップ
.agents/scripts/sync/sync.sh clean
```

## 変換ルール

### Rules 変換

| 統一形式 | Claude Code | Copilot |
|---------|-------------|---------|
| `_base.md` | .claude/rules/_base.md | copilot-instructions.md に統合 |
| `{name}.md` | .claude/rules/{name}.md | instructions/{name}.instructions.md |
| `paths` (YAML配列) | `paths` (YAML配列) | `applyTo` (カンマ区切り単一行) |

**形式の違い**:
- `.agents/rules/`: `paths:` + YAML配列形式（`- "**/*.ts"`）+ メタデータ（`name`, `description`）
- `.claude/rules/`: `paths:` + YAML配列形式（そのまま維持）
- `.github/instructions/`: `applyTo:` + カンマ区切り単一行（`"**/*.ts", "**/*.js"`）

### Skills 変換

| 統一形式 | Claude Code | Copilot |
|---------|-------------|---------|
| `{name}/` | .claude/skills/{name} (symlink) | .github/skills/{name} (symlink) |

> **Note**: 各ディレクトリはファイル単位のシンボリックリンクで管理されるため、エージェント固有のスキルを追加可能です。

### Agents 変換

| 統一形式 | Claude Code | Copilot |
|---------|-------------|---------|
| `{name}.md` | .claude/agents/{name}.md (symlink) | .github/agents/{name}.agents.md (symlink) |
| `tools`, `model` | 保持 | 保持 | 保持 |

> **Note**: 各ディレクトリはファイル単位のシンボリックリンクで管理されるため、エージェント固有のファイルを追加可能です。
> GitHub Copilot は `*.agents.md` という命名規則が必要です。

### Commands 変換

| 統一形式 | Claude Code | Copilot |
|---------|-------------|---------|
| `{name}.md` | .claude/commands/{name}.md | .github/prompts/{name}.prompt.md |
| フォーマット | そのまま | .prompt.md 拡張子 |
| 用途 | Slash Commands | GitHub Prompts |

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
├── CLAUDE.md -> AGENTS.md        # Claude Code + Copilot 共通 ⭐
├── AGENTS.md                     # Copilot Coding Agent 用
│
├── .claude/                      # Claude Code 用
│   ├── rules/                    # モジュラールール
│   ├── skills/*                  # → .agents/skills/* (symlinks)
│   ├── agents/*.md               # → .agents/agents/* (symlinks)
│   └── commands/                 # Slash Commands
│
└── .github/                      # GitHub Copilot 用
    ├── copilot-instructions.md   # Copilot 用メイン
    ├── instructions/*.instructions.md # パス指定 Instructions
    ├── skills/*                  # → .agents/skills/* (symlinks)
    ├── agents/*.agents.md        # → .agents/agents/* (symlinks, renamed)
    └── prompts/*.prompt.md       # GitHub Prompts
```

> **Note**: skills/ と agents/ はファイル単位のシンボリックリンクで管理されます。
> 各エージェント固有のファイルを追加することも可能です。

## 日常的なワークフロー

### ルールを追加/編集

```bash
# 1. ソースを編集
vim .agents/rules/new-rule.md

# 2. 同期
.agents/scripts/sync/sync.sh all

# 3. コミット
git add .agents/ .claude/ .github/ CLAUDE.md AGENTS.md
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
---

# My Skill

スキルの内容...
EOF

# 3. 同期
.agents/scripts/sync/sync.sh all
```

## ベストプラクティス

### 1. ルールは簡潔に
- 1ファイル150行以内推奨（500行で警告、1000行でエラー）
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
ls -la .agents/scripts/sync/sync.sh

# 実行権限付与
chmod +x .agents/scripts/sync/*.sh

# 詳細ログで実行
.agents/scripts/sync/sync.sh --verbose all
```

### 特定エージェントで認識されない

### 変更が反映されない

- **Claude Code**: 新しいセッションを開始
- **Copilot**: VS Code をリロード

## 関連ドキュメント

- [Claude Code Memory Management](https://code.claude.com/docs/en/memory)
- [GitHub Copilot Custom Instructions](https://docs.github.com/en/copilot/customizing-copilot/adding-custom-instructions-for-github-copilot)
