---
name: orchestrating-figma-to-spec
description: Orchestrates the complete Figma-to-specification workflow by coordinating multiple specialized agents. Use when converting Figma designs into comprehensive screen specifications.
compatibility: Claude Code
allowed-tools: Task Read Write Glob Grep Bash mcp__figma__whoami mcp__figma__get_screenshot mcp__figma__get_design_context mcp__figma__get_metadata
---

# Figma to Screen Specification Orchestrator

Figmaデザインから画面仕様書を生成するワークフローを統括します。

---

## 絶対ルール（違反禁止）

> **このセクションの内容は例外なく遵守すること**

### 1. 自分で作業しない

**全作業はTaskツールでサブエージェントに委譲する。**

| 禁止 | 代わりに |
|------|---------|
| 自分でHTMLを生成 | `Task(subagent_type="converting-figma-to-html")` |
| 自分でspec.mdセクションを書く | 各専門サブエージェントを起動 |
| 自分でデザイントークンを抽出 | `Task(subagent_type="extracting-design-tokens")` |

### 2. Phase順序を守る

| Phase | 内容 | スキップ |
|:-----:|------|:--------:|
| 0 | 事前確認（MCP接続） | 不可 |
| 1 | HTML変換 | 不可 |
| 2 | HTML検証 + ユーザー承認 | **不可** |
| 3 | 仕様書初期化 | 不可 |
| 4 | セクション生成 | 条件付き |
| 5 | 最終検証 | 不可 |
| 6 | 完了レポート | 不可 |

### 3. Phase 2 ハードゲート

**Phase 2完了前にPhase 3に進むことは絶対禁止。**

Phase 2完了の条件:
1. comparing-figma-html サブエージェントを実行した
2. 比較結果をユーザーに報告した
3. **ユーザーが「続行」「はい」「OK」等を明示的に回答した**

### 4. API仕様は推測禁止

OpenAPI仕様書が提供された場合のみAPIマッピングを記述。
提供されていない場合は「API仕様書未提供のためスキップ」と記載。

---

## サブエージェント一覧

Taskツールで起動するサブエージェント:

| subagent_type | 役割 | 必須/条件 |
|---------------|------|:--------:|
| `converting-figma-to-html` | Figma → HTML変換 | 必須 |
| `comparing-figma-html` | HTML品質検証 | 必須 |
| `documenting-ui-states` | UI状態の文書化 | 必須 |
| `extracting-interactions` | インタラクション仕様 | 必須 |
| `defining-form-specs` | フォーム仕様 | フォームあり |
| `mapping-html-to-api` | APIマッピング | OpenAPIあり |
| `extracting-design-tokens` | デザイントークン | 必須 |
| `defining-accessibility-requirements` | アクセシビリティ | 必須 |
| `documenting-screen-flows` | 画面フロー | 遷移あり |
| `binding-figma-content-to-api` | APIバインディング | OpenAPIあり |

---

## Task呼び出し形式

サブエージェント起動は以下の形式を使用:

```xml
<invoke name="Task">
  <parameter name="subagent_type">converting-figma-to-html</parameter>
  <parameter name="prompt">
    Figma URL: {url}
    出力先: .outputs/{screen-id}/
    HTMLを生成してください。
  </parameter>
  <parameter name="description">Figma to HTML変換</parameter>
</invoke>
```

---

## 実行開始時のTodo作成

オーケストレーション開始時に必ずTodoリストを作成:

```
TodoWrite([
  { content: "Phase 0: 事前確認", status: "pending", activeForm: "事前確認中" },
  { content: "Phase 1: HTML変換", status: "pending", activeForm: "HTML変換中" },
  { content: "Phase 2: HTML検証・ユーザー承認", status: "pending", activeForm: "HTML検証中" },
  { content: "Phase 3: 仕様書初期化", status: "pending", activeForm: "仕様書初期化中" },
  { content: "Phase 4: セクション生成", status: "pending", activeForm: "セクション生成中" },
  { content: "Phase 5: 最終検証", status: "pending", activeForm: "最終検証中" },
  { content: "Phase 6: 完了レポート", status: "pending", activeForm: "完了レポート作成中" }
])
```

---

## 成果物フォルダ構造

```
.outputs/{screen-id}/
├── index.html              # 生成HTML
├── spec.md                 # 画面仕様書
├── mapping-overlay.js      # マッピング可視化
├── assets/                 # アセット
└── comparison/             # 比較成果物
    ├── figma.png
    ├── html.png
    ├── diff.png
    └── README.md
```

---

## 使い方

### 基本

```
@orchestrating-figma-to-spec

Figma URL: https://figma.com/design/XXXXX/Project?node-id=1234-5678
画面ID: course-list
画面名: 講座一覧
```

### OpenAPI指定あり

```
@orchestrating-figma-to-spec

Figma URL: https://figma.com/design/XXXXX/Project?node-id=1234-5678
画面ID: course-list
画面名: 講座一覧
OpenAPI: openapi/index.yaml
```

---

## 詳細手順

各Phaseの詳細な手順は以下を参照:

**[references/workflow.md](references/workflow.md)**

- Phase 0-6 の各ステップ詳細
- サブエージェント呼び出し例
- エラーハンドリング
- 成果物チェックリスト

---

## 自己チェック

各Phase完了時に確認:

- [ ] Taskツールでサブエージェントを起動したか？
- [ ] 自分で作業を実行していないか？
- [ ] サブエージェントの出力を検証したか？
- [ ] Phase 2でユーザー承認を得たか？（Phase 3以降）
