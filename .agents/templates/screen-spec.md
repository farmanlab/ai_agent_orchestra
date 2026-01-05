# 画面仕様書: {{SCREEN_NAME}}

## 概要

| 項目 | 内容 |
| ---- | ---- |
| 画面名 | {{SCREEN_NAME}} |
| Figma URL | {{FIGMA_URL}} |
| HTML | {{HTML_FILE}} |
| 説明 | {{DESCRIPTION}} |

---

## data-figma-* 属性リファレンス

| 属性パターン | 用途 | 付与対象 | 例 |
| ---- | ---- | ---- | ---- |
| `data-figma-filekey` | FigmaファイルキーをHTMLに紐付け | `<body>` | `data-figma-filekey="WQxcEmQk2..."` |
| `data-figma-node` | Figmaノードへのトレーサビリティ | 全要素 | `data-figma-node="123:456"` |
| `data-figma-content-screen-*` | 画面ルートコンテナの識別 | ルート`<div>` | `data-figma-content-screen-home` |
| `data-figma-content-*` | コンテンツ要素の識別（static/dynamic分類用） | テキスト・画像要素 | `data-figma-content-user-name` |
| `data-figma-states` | 要素がサポートする状態のリスト | インタラクティブ要素 | `data-figma-states="default,hover,active"` |
| `data-figma-interaction` | インタラクション定義（トリガー:アクション:ターゲット） | ボタン・リンク | `data-figma-interaction="tap:navigate:/home"` |
| `data-state` | 現在のUI状態（JavaScript制御用） | 状態を持つ要素 | `data-state="loading"` |

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

### 分類凡例

| 分類 | 説明 | 例 |
| ---- | ---- | ---- |
| `static` | 固定テキスト・ラベル | ボタンラベル、セクションタイトル |
| `dynamic` | ユーザーや時間によって変わる値 | 数値、日付、ユーザー名 |
| `dynamic_list` | 件数が可変のリスト | 講座一覧、通知一覧 |
| `asset` | アイコン・画像等のアセット | アイコンSVG、ロゴ |

### コンテンツ一覧

| ID | 表示値 | 分類 | data属性 | 備考 |
| ---- | ---- | ---- | ---- | ---- |
| {{CONTENT_ID}} | {{DISPLAY_VALUE}} | {{CLASSIFICATION}} | `{{DATA_ATTRIBUTE}}` | {{NOTES}} |

### リストデータ

| リストID | アイテム型 | 最小件数 | 最大件数 | 空時の表示 |
| ---- | ---- | ---- | ---- | ---- |
| {{LIST_ID}} | {{ITEM_TYPE}} | {{MIN_COUNT}} | {{MAX_COUNT}} | {{EMPTY_MESSAGE}} |

### 分類集計

| 分類 | 件数 |
| ---- | ---- |
| static | {{STATIC_COUNT}} |
| dynamic | {{DYNAMIC_COUNT}} |
| dynamic_list | {{LIST_COUNT}} |
| asset | {{ASSET_COUNT}} |
| **合計** | **{{TOTAL_COUNT}}** |

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
