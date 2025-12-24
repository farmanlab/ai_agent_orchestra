# AI Agent Orchestra

プロンプトエンジニアリングのベストプラクティスを集約し、Claude Code / Cursor / GitHub Copilot 間で共有するためのフレームワーク。

## 基本原則

1. **Single Source of Truth**: `.agents/` ディレクトリが正規ソース
2. **Progressive Disclosure**: 詳細は参照ファイルに分離（500行以下を維持）
3. **Cross-Platform Sync**: `sync.sh` で各ツール形式に自動変換

## ディレクトリ構造

```
.agents/
├── agents/      # エージェント定義（Task tool で起動）
├── skills/      # 再利用可能なスキル（エージェント・ルールから参照）
├── rules/       # 開発規約・ルール
├── commands/    # スラッシュコマンド
└── sync/        # 同期スクリプト
```

## 利用可能なエージェント

| エージェント | 説明 | 詳細 |
|-------------|------|------|
| code-reviewer | コードレビューを実施 | [agents/code-reviewer.md](.agents/agents/code-reviewer.md) |
| converting-figma-to-html | Figma → HTML/CSS 変換 | [agents/converting-figma-to-html.md](.agents/agents/converting-figma-to-html.md) |
| prompt-quality-checker | プロンプト品質検証 | [agents/prompt-quality-checker.md](.agents/agents/prompt-quality-checker.md) |
| prompt-writer | 新規プロンプト作成 | [agents/prompt-writer.md](.agents/agents/prompt-writer.md) |
| researching-best-practices | ベストプラクティス調査 | [agents/researching-best-practices.md](.agents/agents/researching-best-practices.md) |

## 同期

```bash
# 全ツールに同期
.agents/sync/sync.sh all

# 検証のみ
.agents/sync/sync.sh validate
```

## 参照

- **[CLAUDE.md](CLAUDE.md)**: Claude Code 用の詳細インストラクション
- **[.agents/rules/](.agents/rules/)**: 開発規約
- **[.agents/skills/](.agents/skills/)**: スキル一覧
