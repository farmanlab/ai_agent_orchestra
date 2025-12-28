# 画面仕様書: {{SCREEN_NAME}}

## 概要

| 項目 | 内容 |
| ---- | ---- |
| 画面名 | {{SCREEN_NAME}} |
| Figma URL | {{FIGMA_URL}} |
| HTML | {{HTML_FILE}} |
| 説明 | {{DESCRIPTION}} |

---

## 構造・スタイル

### HTML構造

```html
<!-- Root Container -->
<div data-figma-content-screen-{{SCREEN_ID}} data-figma-node="{{ROOT_NODE_ID}}">
  {{HTML_STRUCTURE}}
</div>
```

---

## コンテンツ分析

| コンテンツ | 分類 | data属性 | API/データソース |
| ---- | ---- | ---- | ---- |
| {{CONTENT_NAME}} | static/dynamic | `{{DATA_ATTRIBUTE}}` | {{API_SOURCE}} |

**API依存**: {{API_DEPENDENCIES}}

---

## UI状態

### デフォルト状態

| 要素 | 状態 | 備考 |
| ---- | ---- | ---- |
| {{ELEMENT_NAME}} | {{ELEMENT_STATE}} | {{ELEMENT_NOTES}} |

### ボタン状態

| 状態 | 視覚的変化 | 動作 |
| ---- | ---- | ---- |
| default | {{DEFAULT_VISUAL}} | {{DEFAULT_ACTION}} |
| hover | {{HOVER_VISUAL}} | {{HOVER_ACTION}} |
| active | {{ACTIVE_VISUAL}} | {{ACTIVE_ACTION}} |
| disabled | {{DISABLED_VISUAL}} | {{DISABLED_ACTION}} |

---

## インタラクション

### INT-001: {{INTERACTION_NAME_1}}

| 項目 | 内容 |
| ---- | ---- |
| トリガー | {{TRIGGER}} |
| 前提条件 | {{PRECONDITION}} |
| アクション | {{ACTION}} |
| API | {{API_CALL}} |
| 遷移先 | {{DESTINATION}} |

### INT-002: {{INTERACTION_NAME_2}}

| 項目 | 内容 |
| ---- | ---- |
| トリガー | {{TRIGGER}} |
| 前提条件 | {{PRECONDITION}} |
| アクション | {{ACTION}} |
| API | {{API_CALL}} |
| 遷移先 | {{DESTINATION}} |

---

## APIマッピング

{{API_MAPPING_DESCRIPTION}}

---

## アクセシビリティ

### セマンティック要件

| 要素 | role | aria属性 | 備考 |
| ---- | ---- | ---- | ---- |
| {{ELEMENT}} | {{ROLE}} | {{ARIA_ATTRS}} | {{NOTES}} |

### フォーカス管理

| 要件 | 説明 |
| ---- | ---- |
| 初期フォーカス | {{INITIAL_FOCUS}} |
| Tab順序 | {{TAB_ORDER}} |
| フォーカス表示 | {{FOCUS_INDICATOR}} |

### キーボード操作

| キー | アクション |
| ---- | ---- |
| Tab | {{TAB_ACTION}} |
| Enter/Space | {{ENTER_ACTION}} |
| Escape | {{ESC_ACTION}} |

---

## デザイントークン

### カラー

| トークン名 | 値 | 用途 |
| ---- | ---- | ---- |
| {{TOKEN_NAME}} | {{COLOR_VALUE}} | {{COLOR_USAGE}} |

### タイポグラフィ

| トークン名 | font-size | font-weight | 用途 |
| ---- | ---- | ---- | ---- |
| {{TYPO_TOKEN}} | {{FONT_SIZE}} | {{FONT_WEIGHT}} | {{TYPO_USAGE}} |

### スペーシング

| トークン名 | 値 | 用途 |
| ---- | ---- | ---- |
| {{SPACE_TOKEN}} | {{SPACE_VALUE}} | {{SPACE_USAGE}} |

---

## 画面フロー

### 遷移図

```mermaid
stateDiagram-v2
    [*] --> {{CURRENT_SCREEN}}
    {{CURRENT_SCREEN}} --> {{NEXT_SCREEN_1}}: {{TRANSITION_ACTION_1}}
    {{CURRENT_SCREEN}} --> {{NEXT_SCREEN_2}}: {{TRANSITION_ACTION_2}}
```

### 遷移テーブル

| 遷移元 | アクション | 遷移先 | 条件 |
| ---- | ---- | ---- | ---- |
| {{FROM_SCREEN}} | {{ACTION}} | {{TO_SCREEN}} | {{CONDITION}} |

---

## 変更履歴

| 日付 | 変更内容 | 担当 |
| ---- | ---- | ---- |
| {{DATE}} | 初版作成 | {{AUTHOR}} |
