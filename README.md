# ai_agent_orchestra

<img width="567" height="309" alt="ai_agent_orchestra" src="https://github.com/user-attachments/assets/f10a36d9-faa2-4114-9c40-4508ebb10884" />

**Claude Code, Cursor, GitHub Copilot の AI エージェント設定を単一ソースから管理**

## 概要

このリポジトリは、複数の AI コーディングエージェント（Claude Code, Cursor, GitHub Copilot）の設定を統一的に管理するためのシステムを提供します。

### 主な特徴

- **統一ソース管理**: `.agents/` に定義した Rules, Skills, Agents を各エージェント向けに自動変換
- **クロスプラットフォーム互換性**: `CLAUDE.md` ファイルで Claude Code と Copilot の両方に対応
- **自動同期**: Git hooks による変更の自動反映
- **プロジェクト再利用**: ホームディレクトリにコピーして全プロジェクトで利用可能

### サポート対象

| エージェント | Rules | Skills | Subagents | Commands |
|-------------|-------|--------|-----------|----------|
| **Claude Code** | ✅ .claude/rules/*.md | ✅ .claude/skills/* | ✅ .claude/agents/*.md | ✅ .claude/commands/ |
| **Cursor** | ✅ .cursor/rules/*/RULE.md | ✅ .cursor/skills/* | ✅ .cursor/agents/*.md | ✅ .cursor/commands/ |
| **GitHub Copilot** | ✅ .github/copilot-instructions.md | ✅ .github/skills/* | ✅ .github/agents/*.agents.md | ✅ .github/prompts/ |

> **Note**: Cursor の RULE.md は `description`, `alwaysApply`, `globs` (カンマ区切り) のみをサポート

## クイックスタート

### 1. 初めて使う場合

```bash
# このリポジトリをクローン
git clone https://github.com/farmanlab/ai_agent_orchestra.git
cd ai_agent_orchestra

# 設定を生成
.agents/sync/sync.sh all

# 動作確認
cat CLAUDE.md
```

### 2. 既存プロジェクトで使う場合

```bash
# プロジェクトルートで .agents/ フォルダをコピー
cp -r /path/to/ai_agent_orchestra/.agents .

# 初期化と同期
.agents/sync/sync.sh init
.agents/sync/sync.sh all

# Git に追加
git add .agents/ .claude/ .cursor/ .github/ CLAUDE.md AGENTS.md
git commit -m "Add AI agent configuration"
```

### 3. ホームディレクトリにコピーして全プロジェクトで使う

このリポジトリの設定フォルダをホームディレクトリにコピーすると、すべてのプロジェクトで利用できます。

#### 方法1: リポジトリをクローンして実行

```bash
git clone https://github.com/farmanlab/ai_agent_orchestra.git
cd ai_agent_orchestra
./scripts/copy_to_home.sh
```

強制上書きする場合:

```bash
./scripts/copy_to_home.sh -f
```

#### 方法2: GitHub CLIで直接実行

リポジトリをクローンせずに、ghコマンドで直接スクリプトを実行できます。

確認ありでコピー:

```bash
bash <(gh api repos/farmanlab/ai_agent_orchestra/contents/scripts/copy_to_home.sh --jq '.content' | base64 -d)
```

強制上書き:

```bash
bash <(gh api repos/farmanlab/ai_agent_orchestra/contents/scripts/copy_to_home.sh --jq '.content' | base64 -d) -f
```

または、curlを使用する場合。

確認ありでコピー:

```bash
bash <(curl -s https://raw.githubusercontent.com/farmanlab/ai_agent_orchestra/main/scripts/copy_to_home.sh)
```

強制上書き:

```bash
bash <(curl -s https://raw.githubusercontent.com/farmanlab/ai_agent_orchestra/main/scripts/copy_to_home.sh) -f
```

## 使い方

### ルールを追加する

```bash
# 新しいルールファイルを作成
cat > .agents/rules/my-rule.md << 'EOF'
---
name: my-rule
description: 私のカスタムルール
---

# My Custom Rule

- ここにルールを記述
EOF

# 同期して各エージェント向けに変換
.agents/sync/sync.sh all
```

### スキルを追加する

```bash
# スキルフォルダを作成
mkdir -p .agents/skills/my-skill

# SKILL.md を作成
cat > .agents/skills/my-skill/SKILL.md << 'EOF'
---
name: my-skill
description: 私のカスタムスキル
triggers: [keyword1, keyword2]
---

# My Skill

スキルの内容...
EOF

# 同期
.agents/sync/sync.sh all
```

### エージェントを追加する

```bash
# エージェントファイルを作成
cat > .agents/agents/my-agent.md << 'EOF'
---
name: my-agent
description: 私のカスタムエージェント
tools: [Read, Write, Bash]
model: sonnet
---

# My Agent

あなたは〜として...
EOF

# 同期
.agents/sync/sync.sh all
```

### コマンドを追加する

```bash
# コマンドファイルを作成
cat > .agents/commands/my-command.md << 'EOF'
---
description: 私のカスタムコマンド
argument-hint: [引数のヒント]
---

# My Command

## 指示

コマンドの詳細な指示...
EOF

# 同期
.agents/sync/sync.sh all

# 使用方法：Claude Code や Cursor で
# /my-command [引数]
```

## ディレクトリ構造

```
.agents/                         # 統一ソース（編集対象）
├── README.md                    # 詳細ドキュメント
├── config.yaml                  # 設定ファイル
├── rules/                       # ルール定義
│   ├── _base.md                 # 基本ルール
│   ├── architecture.md          # アーキテクチャ原則
│   └── testing.md               # テスト規約
├── skills/                      # スキル定義
│   └── code-review/
│       ├── SKILL.md
│       ├── patterns.md
│       └── checklist.md
├── agents/                      # エージェント定義
│   ├── code-reviewer.md
│   ├── implementer.md
│   └── researcher.md
├── commands/                    # コマンド定義（Slash Commands）
│   └── pr-review.md             # /pr-review コマンド
└── sync/                        # 同期スクリプト
    ├── sync.sh                  # メインスクリプト
    ├── to-claude.sh
    ├── to-cursor.sh
    └── to-copilot.sh

# 生成されるファイル（自動生成、編集不要）
# ※ skills/, agents/ は .agents/ へのシンボリックリンク（ファイル単位）
#   各エージェント固有のファイルを追加可能
CLAUDE.md                        # Claude + Copilot 共通 (-> AGENTS.md)
AGENTS.md                        # Copilot エージェント定義
.claude/                         # Claude Code 用
  ├── rules/
  ├── skills/                    # → .agents/skills/* (symlinks)
  ├── agents/                    # → .agents/agents/* (symlinks)
  └── commands/                  # Slash Commands
.cursor/                         # Cursor 用
  ├── rules/
  ├── skills/                    # → .agents/skills/* (symlinks)
  ├── agents/                    # → .agents/agents/* (symlinks)
  └── commands/                  # Slash Commands
.github/                         # GitHub Copilot 用
  ├── copilot-instructions.md
  ├── instructions/
  ├── skills/                    # → .agents/skills/* (symlinks)
  ├── agents/                    # *.agents.md (symlinks)
  └── prompts/                   # GitHub Prompts
```

## 詳細ドキュメント

詳しい使い方は [.agents/README.md](.agents/README.md) を参照してください。

## コマンドリファレンス

```bash
# 全エージェントに同期
.agents/sync/sync.sh all

# 特定エージェントのみ
.agents/sync/sync.sh claude
.agents/sync/sync.sh cursor
.agents/sync/sync.sh copilot

# Git hooks をインストール（コミット時に自動同期）
.agents/sync/sync.sh install-hooks

# 生成ファイルをクリーンアップ
.agents/sync/sync.sh clean

# 詳細ログ表示
.agents/sync/sync.sh --verbose all

# ドライラン（変更せず確認のみ）
.agents/sync/sync.sh --dry-run all
```

## トラブルシューティング

### 同期が動かない

```bash
# 実行権限を確認
chmod +x .agents/sync/*.sh

# 詳細ログで実行
.agents/sync/sync.sh --verbose all
```

### 変更が反映されない

- **Claude Code**: 新しいセッションを開始
- **Cursor**: アプリケーションを再起動
- **GitHub Copilot**: VS Code をリロード

## ライセンス

MIT License

## 関連リンク

- [Claude Code Documentation](https://code.claude.com/docs)
- [Cursor Documentation](https://docs.cursor.com)
- [GitHub Copilot Documentation](https://docs.github.com/copilot)
