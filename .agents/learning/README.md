# Session Learning System

セッション中の会話から自動的にKnowledge（rules/skills）を学習・提案するシステム。

## 仕組み

```
セッション中のやりとり
        ↓
   AI が自動監視
   (rules/session-learning.md)
        ↓
  パターン検出時に提案
        ↓
  ユーザー承認/却下
        ↓
  承認 → rules/ or skills/ に保存
       → sync.sh all で全ツールに反映
```

## 検出パターン

| パターン | 検出条件 | 提案種別 |
|---------|---------|---------|
| 修正フィードバック | ユーザーが訂正 | Rule |
| 繰り返し指示 | 同じ指示が2回以上 | Rule |
| プロジェクト規約 | 「このPJでは」等 | Rule |
| ワークフロー完了 | 3ステップ以上の作業完了 | Skill |
| トラブルシュート | エラー解決後 | Rule |

## ディレクトリ構造

```
learning/
├── README.md          # このファイル
├── pending/           # 未承認の提案（一時保存）
│   └── .gitkeep
└── history.jsonl      # 提案履歴（オプション）
```

## 対応ツール

- Claude Code: `.claude/rules/session-learning.md`
- Cursor: `.cursor/rules/session-learning/RULE.md`
- GitHub Copilot: `.github/instructions/session-learning.instructions.md`

## 使用方法

### ユーザー側
1. 通常通りAIとやりとり
2. 提案が表示されたら:
   - 承認: 「保存して」と返答
   - 編集: 修正内容を指示
   - 却下: スキップ（返答不要）

### 承認後
1. `.agents/rules/` または `.agents/skills/` に保存
2. `sync.sh all` で全ツールに反映
3. 次回以降のセッションで自動適用
