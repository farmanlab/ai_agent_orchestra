# コンテンツ分析: {{COMPONENT_NAME}}

## 概要

| 項目 | 値 |
|------|-----|
| Figma Node | {{ROOT_NODE_ID}} |
| Figma URL | {{FIGMA_URL}} |
| HTML File | {{HTML_FILENAME}} |

---

## 分類凡例

| 分類 | 説明 | 例 |
|------|------|-----|
| `static` | 固定テキスト・ラベル | ボタンラベル、セクションタイトル |
| `dynamic` | ユーザーや時間によって変わる値 | 数値、日付、ユーザー名 |
| `dynamic_list` | 件数が可変のリスト | 講座一覧、通知一覧 |
| `asset` | アイコン・画像等のアセット | アイコンSVG、ロゴ |
| `config` | 設定で変わる要素 | テーマカラー、表示切替 |

---

## Navigation Bar

| ID | 表示値 | 分類 | data-figma-content | HTML Selector |
|----|--------|------|-------------------|---------------|
| nav_title | {{NAV_TITLE}} | static | `nav-title` | `[data-figma-content-nav-title]` |
| nav_back_icon | （戻るアイコン） | asset | `back-icon` | `[data-figma-content-back-icon]` |
| nav_action_icon | （アクションアイコン） | asset | `{{ACTION_ID}}-icon` | `[data-figma-content-{{ACTION_ID}}-icon]` |

---

## Tab Menu

| ID | 表示値 | 分類 | data-figma-content | HTML Selector |
|----|--------|------|-------------------|---------------|
| tab_{{TAB1_ID}} | {{TAB1_LABEL}} | static | `tab-{{TAB1_ID}}` | `[data-figma-content-tab-{{TAB1_ID}}]` |
| tab_{{TAB2_ID}} | {{TAB2_LABEL}} | static | `tab-{{TAB2_ID}}` | `[data-figma-content-tab-{{TAB2_ID}}]` |
| tab_active_state | （選択中タブ） | dynamic | `tab-active` | `[data-figma-content-tab-active]` |

---

## Main Section - {{SECTION1_NAME}}

| ID | 表示値 | 分類 | data-figma-content | 備考 |
|----|--------|------|-------------------|------|
| {{FIELD1_ID}}_label | {{FIELD1_LABEL}} | static | `{{FIELD1_ID}}-label` | |
| {{FIELD1_ID}}_value | {{FIELD1_VALUE}} | dynamic | `{{FIELD1_ID}}-value` | {{FIELD1_NOTE}} |
| {{FIELD1_ID}}_unit | {{FIELD1_UNIT}} | static | `{{FIELD1_ID}}-unit` | |

---

## Main Section - {{SECTION2_NAME}}

| ID | 表示値 | 分類 | data-figma-content | 備考 |
|----|--------|------|-------------------|------|
| {{FIELD2_ID}}_label | {{FIELD2_LABEL}} | static | `{{FIELD2_ID}}-label` | |
| {{FIELD2_ID}}_value | {{FIELD2_VALUE}} | dynamic | `{{FIELD2_ID}}-value` | {{FIELD2_NOTE}} |

---

## List Section - {{LIST_SECTION_NAME}}

### ヘッダー

| ID | 表示値 | 分類 | data-figma-content |
|----|--------|------|-------------------|
| {{LIST_ID}}_section_title | {{LIST_SECTION_TITLE}} | static | `section-title` |

### リストアイテム（dynamic_list）

**リスト構造**: `[data-figma-content-{{LIST_ID}}-list]`

各アイテムの構造:

| ID | 表示値 | 分類 | data-figma-content | 備考 |
|----|--------|------|-------------------|------|
| {{LIST_ID}}_item | （アイテム全体） | dynamic_list | `{{LIST_ID}}-item` | 繰り返し要素 |
| {{LIST_ID}}_icon | （アイコン） | asset | `{{LIST_ID}}-icon` | |
| {{LIST_ID}}_category | {{ITEM_CATEGORY}} | dynamic | `{{LIST_ID}}-category` | |
| {{LIST_ID}}_title | {{ITEM_TITLE}} | dynamic | `{{LIST_ID}}-title` | |
| {{LIST_ID}}_duration | {{ITEM_DURATION}} | dynamic | `{{LIST_ID}}-duration` | 時間表示 |
| {{LIST_ID}}_score | {{ITEM_SCORE}} | dynamic | `{{LIST_ID}}-score` | スコア/進捗 |

---

## Bottom Navigation

| ID | 表示値 | 分類 | data-figma-content |
|----|--------|------|-------------------|
| bottom_nav | （ナビ全体） | - | `bottom-nav` |
| nav_{{NAV1_ID}}_icon | （アイコン） | asset | `nav-{{NAV1_ID}}-icon` |
| nav_{{NAV1_ID}}_label | {{NAV1_LABEL}} | static | `nav-{{NAV1_ID}}-label` |
| nav_{{NAV2_ID}}_icon | （アイコン） | asset | `nav-{{NAV2_ID}}-icon` |
| nav_{{NAV2_ID}}_label | {{NAV2_LABEL}} | static | `nav-{{NAV2_ID}}-label` |
| nav_{{NAV3_ID}}_icon | （アイコン） | asset | `nav-{{NAV3_ID}}-icon` |
| nav_{{NAV3_ID}}_label | {{NAV3_LABEL}} | static | `nav-{{NAV3_ID}}-label` |
| nav_active | （アクティブ状態） | dynamic | `nav-active` |

---

## データ要件サマリー

### 動的データ一覧

| Content ID | データ型 | 表示例 | 表示フォーマット |
|------------|----------|--------|-----------------|
| {{FIELD1_ID}}_value | number | {{FIELD1_VALUE}} | `{value}{{FIELD1_UNIT}}` |
| {{FIELD2_ID}}_value | number | {{FIELD2_VALUE}} | `{value}` |
| {{LIST_ID}}_category | string | {{ITEM_CATEGORY}} | `{value}` |
| {{LIST_ID}}_title | string | {{ITEM_TITLE}} | `{value}` |
| {{LIST_ID}}_duration | duration | {{ITEM_DURATION}} | `{minutes}分` |

### リストデータ

| リストID | アイテム型 | 最小件数 | 最大件数 | 空時の表示 |
|----------|-----------|----------|----------|-----------|
| {{LIST_ID}}_list | {{LIST_ID}}_item | 0 | - | 「{{EMPTY_MESSAGE}}」 |

---

## HTMLマッピングサマリー

| Content ID | Classification | data-figma-content | HTML Selector |
|------------|---------------|-------------------|---------------|
| nav_title | static | `nav-title` | `[data-figma-content-nav-title]` |
| tab_{{TAB1_ID}} | static | `tab-{{TAB1_ID}}` | `[data-figma-content-tab-{{TAB1_ID}}]` |
| {{FIELD1_ID}}_value | dynamic | `{{FIELD1_ID}}-value` | `[data-figma-content-{{FIELD1_ID}}-value]` |
| {{LIST_ID}}_item | dynamic_list | `{{LIST_ID}}-item` | `[data-figma-content-{{LIST_ID}}-item]` |

---

## 分類集計

| 分類 | 件数 |
|------|------|
| static | {{STATIC_COUNT}} |
| dynamic | {{DYNAMIC_COUNT}} |
| dynamic_list | {{LIST_COUNT}} |
| asset | {{ASSET_COUNT}} |
| **合計** | **{{TOTAL_COUNT}}** |

---

## 備考

- {{NOTE1}}
- {{NOTE2}}

---

## 変更履歴

| 日付 | 変更内容 |
|------|----------|
| {{DATE}} | 初版作成 |
