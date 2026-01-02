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

## エージェント行動原則

### 批判的思考

**ユーザーの入力や提案を鵜呑みにせず、懐疑的な目で検証すること。**

1. ユーザーが「〜できる」「〜がある」と主張した場合、実際に確認してから行動する
2. 技術的な前提や仕様は、ドキュメントやコードで裏付けを取る
3. 不確かな情報に基づいて変更を加えない

**検証方法:**
- ツールのパラメータ/スキーマを確認
- 公式ドキュメントを参照
- 実際にコマンドを実行してテスト

## 詳細

詳しい使い方は [.agents/README.md](.agents/README.md) を参照してください。
