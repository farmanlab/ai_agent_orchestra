# 画面仕様書: {{SCREEN_NAME}}

<!--
  このファイルは画面の概要情報を提供します。
  対象読者: PM、全ステークホルダー
  関連ファイル: spec-visual.md, spec-behavior.md
-->

## データソース凡例

| ラベル | 意味 | 信頼度 |
|--------|------|--------|
| `[Figma]` | Figmaデザインから直接取得 | ✅ 確実 |
| `[HTML]` | 生成HTMLから取得 | ✅ 確実 |
| `[API]` | OpenAPI仕様書から取得 | ✅ 確実 |
| `[推奨]` | ベストプラクティスからの提案 | ⚠️ レビュー推奨 |
| `[要確認]` | エージェントの推測・仮定 | ❌ 要確認 |

---

## 概要

| 項目 | 内容 |
|------|------|
| 画面名 | {{SCREEN_NAME}} |
| 画面ID | {{SCREEN_ID}} |
| Figma URL | {{FIGMA_URL}} |
| HTML | {{HTML_FILE}} |
| ルートノードID | {{ROOT_NODE_ID}} |
| 作成日 | {{DATE}} |

### 説明

{{DESCRIPTION}}

### 関連仕様書

| ファイル | 内容 | 対象読者 |
|----------|------|----------|
| [spec-visual.md](./spec-visual.md) | ビジュアル仕様（構造、UI状態、デザイントークン） | デザイナー、開発者 |
| [spec-behavior.md](./spec-behavior.md) | 動作仕様（インタラクション、API、アクセシビリティ） | 開発者、QA |

---

## 画面フロー

<!-- @generated-by: documenting-screen-flows | @timestamp: {{DATE}} -->

### 画面の位置づけ

| 項目 | 内容 | ソース |
|------|------|--------|
| 現在の画面 | {{SCREEN_NAME}} | - |
| 流入元 | {{INBOUND_SCREENS}} | `[要確認]` |
| 流出先 | {{OUTBOUND_SCREENS}} | `[要確認]` |

### 遷移図

```mermaid
stateDiagram-v2
    [*] --> {{CURRENT_SCREEN}}
    {{CURRENT_SCREEN}} --> {{NEXT_SCREEN_1}}: {{TRANSITION_ACTION_1}}
    {{CURRENT_SCREEN}} --> {{NEXT_SCREEN_2}}: {{TRANSITION_ACTION_2}}
```

### 遷移テーブル

| 遷移元 | アクション | 遷移先 | 条件 | ソース |
|--------|------------|--------|------|--------|
| {{FROM_SCREEN}} | {{ACTION}} | {{TO_SCREEN}} | {{CONDITION}} | {{SOURCE}} |

---

## 生成ファイル一覧

| ファイル | 説明 |
|----------|------|
| index.html | 静的HTML |
| mapping-overlay.js | マッピング可視化 |
| spec.md | 概要仕様（このファイル） |
| spec-visual.md | ビジュアル仕様 |
| spec-behavior.md | 動作仕様 |

---

## 変更履歴

| 日付 | 変更内容 | 担当 |
|------|----------|------|
| {{DATE}} | 初版作成 | orchestrating-figma-to-spec |
