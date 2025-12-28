# AI Agent Orchestra

Claude Code, Cursor, GitHub Copilot のエージェント設定を単一ソースから管理するシステム。

## 設計思想

```
Single Source of Truth (.agents/) → 各エージェント固有形式へ変換
```

## フォルダ構成

```
.agents/
├── agents/                      # サブエージェント定義
│   ├── code-reviewer.md
│   ├── converting-figma-to-html.md
│   ├── comparing-figma-html.md
│   ├── prompt-quality-checker.md
│   └── ...
│
├── skills/                      # スキル定義
│   ├── reviewing-code/
│   ├── converting-figma-to-html/
│   ├── ensuring-prompt-quality/
│   └── ...
│
├── rules/                       # ルール定義
│   ├── _base.md                 # 共通ベースルール
│   ├── writing-agents.md
│   ├── writing-skills.md
│   └── ...
│
├── commands/                    # Slash Commands
│   ├── pr-review.md
│   ├── explain-pr.md
│   └── visualize-issue.md
│
├── templates/                   # テンプレート
│   └── screen-spec.md
│
├── scripts/                     # ユーティリティスクリプト
│   └── sync/
│
└── README.md                    # 詳細ドキュメント
```

## 同期コマンド

```bash
# 全エージェント向けに同期
.agents/sync/sync.sh all

# 特定エージェントのみ
.agents/sync/sync.sh claude
.agents/sync/sync.sh cursor
.agents/sync/sync.sh copilot

# 検証
.agents/sync/sync.sh validate
```

## 詳細

詳しい使い方は [.agents/README.md](.agents/README.md) を参照してください。
