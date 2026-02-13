# prompt-engineering Plugin

AI エージェントのプロンプトファイル（rules, skills, agents, commands）を作成・検証・改善するための Claude Code プラグインです。

## 含まれるコンポーネント

### Agents

| Agent | 説明 |
|-------|------|
| `prompt-writer` | 新規プロンプトファイルをベストプラクティスに則って作成 |
| `prompt-quality-checker` | 既存プロンプトファイルの品質を14観点で検証 |
| `researching-best-practices` | 公式ドキュメントからベストプラクティスを収集・更新 |

### Commands

| Command | 説明 |
|---------|------|
| `/write-prompt` | 作成→品質レビュー→修正のオーケストレーター |

### Skills

| Skill | 説明 |
|-------|------|
| `ensuring-prompt-quality` | プロンプト品質検証の専門知識を提供 |
| `checking-references` | ファイル参照の整合性を検証 |

### References

`skills/ensuring-prompt-quality/references/` に含まれる参照ドキュメント:

| ファイル | 内容 |
|---------|------|
| `validation-criteria.md` | コンテンツ品質の検証観点（1-7） |
| `validation-criteria-technical.md` | 技術要件の検証観点（8-14） |
| `best-practices.md` | 公式ベストプラクティスまとめ |
| `examples.md` | 良い例集 |
| `examples-antipatterns.md` | アンチパターン集 |
| `templates.md` | プロンプトテンプレート |
| `report-template.md` | 品質レポートテンプレート |
| `REFERENCE.md` | 参照ドキュメント索引 |
| `writing-skills.md` | Skills 記載ルール |
| `writing-rules.md` | Rules 記載ルール |
| `writing-agents.md` | Agents 記載ルール |
| `writing-commands.md` | Commands 記載ルール |

## インストール

```bash
# リポジトリをクローン
git clone https://github.com/your-org/ai-agent-orchestra.git
cd ai-agent-orchestra

# CLIツールもグローバルインストールする場合
npm install -g .
```

## 使い方

```bash
# プラグインとして読み込み
claude --plugin-dir plugins/prompt-engineering

# 新規プロンプト作成（オーケストレーター）
/write-prompt rule api-error-handling "APIエラーハンドリング"

# エージェント直接呼び出し
@prompt-writer

# 品質チェック
@prompt-quality-checker

# ベストプラクティス調査
@researching-best-practices
```

## 対応エージェント

- Claude Code
- Cursor
- GitHub Copilot
