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

### 状態一覧

| 要素 | data-figma-states | data-state | 備考 |
| ---- | ---- | ---- | ---- |
| {{ELEMENT_NAME}} | `{{STATES_LIST}}` | `{{CURRENT_STATE}}` | {{ELEMENT_NOTES}} |

### 状態定義

| 状態 | 検出方法 | 視覚的変化 | CSS/属性 |
| ---- | ---- | ---- | ---- |
| default | 初期状態 | {{DEFAULT_VISUAL}} | - |
| hover | マウスオーバー | {{HOVER_VISUAL}} | `:hover` |
| active | タップ/クリック中 | {{ACTIVE_VISUAL}} | `:active` |
| focus | フォーカス中 | {{FOCUS_VISUAL}} | `:focus` |
| disabled | 無効状態 | 透明度40%、操作不可 | `data-state="disabled"` |
| loading | 読み込み中 | スピナー表示 | `data-state="loading"` |
| selected | 選択状態 | ハイライト | `.active`, `aria-current` |

### CSS実装例

```css
/* 無効状態 */
[data-state="disabled"] {
  opacity: 0.4;
  pointer-events: none;
}

/* 読み込み中状態 */
[data-state="loading"] {
  position: relative;
  pointer-events: none;
}

[data-state="loading"]::after {
  content: '';
  position: absolute;
  width: 16px;
  height: 16px;
  border: 2px solid transparent;
  border-top-color: currentColor;
  border-radius: 50%;
  animation: spin 0.8s linear infinite;
}
```

---

## インタラクション

### インタラクティブ要素一覧

| 要素 | data-figma-interaction | data-figma-states | 説明 |
| ---- | ---- | ---- | ---- |
| {{ELEMENT_NAME}} | `{{INTERACTION_VALUE}}` | `{{STATES_VALUE}}` | {{DESCRIPTION}} |

### INT-001: {{INTERACTION_NAME_1}}

| 項目 | 内容 |
| ---- | ---- |
| 対象要素 | {{TARGET_ELEMENT}} |
| data属性 | `data-figma-interaction="{{INTERACTION_VALUE}}"` |
| トリガー | {{TRIGGER}} |
| 前提条件 | {{PRECONDITION}} |
| アクション | {{ACTION}} |
| API | {{API_CALL}} |
| 遷移先 | {{DESTINATION}} |

### INT-002: {{INTERACTION_NAME_2}}

| 項目 | 内容 |
| ---- | ---- |
| 対象要素 | {{TARGET_ELEMENT}} |
| data属性 | `data-figma-interaction="{{INTERACTION_VALUE}}"` |
| トリガー | {{TRIGGER}} |
| 前提条件 | {{PRECONDITION}} |
| アクション | {{ACTION}} |
| API | {{API_CALL}} |
| 遷移先 | {{DESTINATION}} |

### インタラクション形式

```
形式: {trigger}:{action}:{target}

trigger: tap, hover, focus, longpress
action: navigate, show-modal, close-modal, submit, toggle
target: 遷移先パス、モーダルID、または対象要素
```

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
