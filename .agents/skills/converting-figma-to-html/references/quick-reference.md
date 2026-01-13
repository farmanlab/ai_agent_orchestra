# Figma MCP → HTML 変換 クイックリファレンス

## 目次

1. [基本フロー](#-基本フロー)
2. [data属性一覧](#-data属性一覧)
3. [コンテンツ分類](#-コンテンツ分類)
4. [インタラクション属性](#-インタラクション属性)
5. [HTML構造パターン](#-html構造パターン)
6. [Tailwindクラス早見表](#-tailwindクラス早見表)
7. [完了チェックリスト](#-完了チェックリスト)

---

## 🚀 基本フロー

```
1. figma:get_screenshot     → ビジュアル参照
2. figma:get_design_context → 構造・スタイル取得 ★メイン
3. figma:get_metadata       → 階層構造確認（必要時）
4. HTML生成                 → data属性付きHTML
5. コンテンツ分析           → 分類ドキュメント
6. コンテンツ分類属性       → data-figma-content-* 埋め込み
7. 画面遷移属性             → data-figma-interaction/navigate 埋め込み
```

---

## 📋 data属性一覧

### 基本属性

| 属性 | 用途 | 例 |
|------|------|-----|
| `data-figma-node` | FigmaノードID | `"2350:6396"` |
| `data-figma-filekey` | Figmaファイルキー | `"a0Yir10b6qxVEltgVTOa9d"` |
| `data-figma-name` | Figmaでの名前 | `"Navigation"` |
| `data-figma-url` | FigmaのURL | `"https://figma.com/design/..."` |
| `data-screen-id` | 画面識別子（kebab-case） | `"tutorial"` |
| `data-screen-name` | 画面名（日本語） | `"チュートリアル"` |

### デザイントークン属性 (data-figma-token-*)

| 属性 | 用途 | 例 |
|------|------|-----|
| `data-figma-token-bg` | 背景色トークン | `"Background/Default/Default"` |
| `data-figma-token-color` | テキスト色トークン | `"Text/Default/Default"` |
| `data-figma-token-font` | フォントトークン | `"JP/16 - Bold"` |
| `data-figma-token-radius` | 角丸トークン | `"Radius/100"` |
| `data-figma-token-padding` | パディングトークン | `"Space/200"` |
| `data-figma-token-gap` | ギャップトークン | `"Space/100"` |
| `data-figma-token-height` | 高さトークン | `"56px"` |
| `data-figma-token-border` | ボーダートークン | `"Border/Main/Default"` |
| `data-figma-token-size` | サイズトークン | `"44px"` |

### コンテンツ分類属性 (data-figma-content-*)

| 属性 | 用途 | 例 |
|------|------|-----|
| `data-figma-content-id` | 一意識別子（snake_case） | `"nav_back_icon"` |
| `data-figma-content-type` | コンテンツ種別 | `"text"`, `"icon"`, `"ui_state"` |
| `data-figma-content-classification` | 分類 | `"static"`, `"dynamic"`, `"asset"` |
| `data-figma-content-data-type` | データ型 | `"string"`, `"number"`, `"svg"` |
| `data-figma-content-value` | Figmaでの表示値 | `"テスト運用版"` |
| `data-figma-content-notes` | 補足説明 | `"最終ステップでは「はじめる」に変化"` |

### インタラクション属性

| 属性 | 用途 | 例 |
|------|------|-----|
| `data-figma-interaction` | インタラクション定義 | `"tap:navigate:tutorial"` |
| `data-figma-navigate` | 遷移先パス | `"/{locale}/ask_ai/tutorial"` |
| `data-figma-states` | サポートするUI状態 | `"default,hover,active,disabled"` |
| `data-state` | 現在のUI状態 | `"active"`, `"disabled"`, `"loading"` |

### アイコン・アセット属性

| 属性 | 用途 | 例 |
|------|------|-----|
| `data-figma-icon-svg` | アイコンパスまたはノードID | `"assets/icon-back.svg"` |

---

## 📊 コンテンツ分類

| 分類 | 判断基準 | 例 |
|------|----------|-----|
| `static` | 固定ラベル・UI文言 | ボタン名、セクション名 |
| `dynamic` | ユーザー/時間で変化 | 数値、日付、名前 |
| `dynamic_list` | 件数可変リスト | 一覧データ |
| `config` | 画面設定で変わる要素 | ページネーション状態 |
| `asset` | 静的アセット | SVGアイコン、ロゴ |
| `user_asset` | ユーザーアップロード画像 | プロフィール画像 |

### 判断チェックリスト

**static（固定）**
- [ ] ラベル系テキスト（「〜の」「〜一覧」）
- [ ] ボタンテキスト
- [ ] ナビゲーション項目
- [ ] 単位（分、時間、%）

**dynamic（動的）**
- [ ] 数値（カウント、パーセント）
- [ ] 日付・期間
- [ ] ユーザー名・ID
- [ ] ステータス値

### content-type 一覧

| 値 | 説明 |
|-----|------|
| `text` | テキストコンテンツ |
| `icon` | アイコン |
| `image` | 画像 |
| `list` | リストコンテナ |
| `ui_state` | UI状態（ページネーション等） |

### content-id 命名規則

```
形式: {category}_{element} (snake_case)

例:
nav_back_icon       ナビの戻るアイコン
nav_title           ナビタイトル
badge_text          バッジのテキスト
step_description    ステップの説明文
pagination_dot_1    ページネーションドット1
next_button         次へボタン
primary_button      プライマリボタン
bottom_tab_bar      ボトムタブバー
nav_top_tab         ナビのトップタブ
nav_top_icon        ナビのトップアイコン
nav_top_label       ナビのトップラベル
history_item        履歴アイテム
item_category_1     アイテムのカテゴリ1
item_date_1         アイテムの日付1
item_bookmark_1     アイテムのブックマーク1
```

---

## 🎯 インタラクション属性

### インタラクション形式

```
形式: {trigger}:{action}:{target}

trigger: tap, hover, focus, longpress, click
action: navigate, show-modal, close-modal, submit, toggle, conditional-navigate, open-file-dialog
target: 遷移先パス, モーダルID, または対象要素
```

### 遷移パターン

| パターン | 形式 | 例 |
|---------|------|-----|
| 単純遷移 | `tap:navigate:{target}` | `tap:navigate:tutorial` |
| 条件付き | `tap:conditional-navigate` | 同意状態で分岐 |
| 内部遷移 | `tap:navigate:next-step` | ステップ遷移 |
| 複合 | `tap:action1\|action2` | `tap:open-file-dialog\|navigate:trim` |
| 戻る | `tap:navigate:back` | 前の画面へ |
| トグル | `click:toggle:{target}` | `click:toggle:dropdown-menu` |

### 遷移先の記述形式

```
単純遷移:
  /{locale}/ask_ai/tutorial

条件付き:
  consented:/{locale}/ask_ai|unconsented:consent-modal

内部遷移:
  tutorial-step-{n+1}
  previous-screen

複合条件:
  step1-3:tutorial-step-{n+1}|step4-consented:/{locale}/ask_ai|step4-unconsented:consent-modal
```

### UI状態一覧

| 状態 | 説明 | CSS例 |
|------|------|-------|
| `default` | 通常状態 | - |
| `hover` | ホバー中 | `:hover` |
| `active` | タップ/クリック中 | `:active`, `[data-state="active"]` |
| `focus` | フォーカス中 | `:focus` |
| `disabled` | 無効状態 | `[aria-disabled="true"]` |
| `loading` | 読み込み中 | `[data-state="loading"]` |
| `selected` | 選択状態 | `[data-state="selected"]` |
| `open` | 展開状態 | `[data-state="open"]` |
| `inactive` | 非アクティブ | タブ等 |
| `bookmarked` | ブックマーク済み | アイコン切替 |

### 埋め込み例

```html
<!-- 単純な画面遷移 -->
<button data-figma-interaction="tap:navigate:tutorial"
        data-figma-navigate="/{locale}/ask_ai/tutorial"
        data-figma-states="default,hover,active">
  ヘルプ
</button>

<!-- 条件付き遷移 -->
<button data-figma-interaction="tap:conditional-navigate"
        data-figma-navigate="consented:/{locale}/ask_ai|unconsented:consent-modal"
        data-figma-states="default,hover,active">
  スキップ
</button>

<!-- 内部ステップ遷移 -->
<button data-figma-interaction="tap:navigate:next-step"
        data-figma-navigate="step1-3:tutorial-step-{n+1}|step4:/{locale}/ask_ai"
        data-figma-states="default,hover,active">
  次へ
</button>

<!-- 複合アクション -->
<button data-figma-interaction="tap:open-file-dialog|navigate:trim"
        data-figma-navigate="/{locale}/ask_ai/trim"
        data-figma-states="default,hover,active,loading">
  写真を共有
</button>

<!-- ドロップダウントグル -->
<div data-figma-interaction="click:toggle:dropdown-menu"
     data-figma-states="default,open">
  すべて
</div>

<!-- 無効状態のボタン -->
<button data-figma-interaction="tap:navigate:previous-step"
        data-figma-navigate="tutorial-step-{n-1}"
        data-figma-states="default,disabled"
        aria-disabled="true">
  前へ
</button>

<!-- ボトムナビゲーション -->
<a data-figma-interaction="tap:navigate:history"
   data-figma-navigate="/{locale}/ask_ai/history"
   data-figma-states="active,inactive"
   role="tab"
   aria-selected="false">
  マイリスト
</a>
```

---

## 🏗️ HTML構造パターン

### 画面コンテナ

```html
<div class="w-[375px] min-h-screen mx-auto flex flex-col"
     data-screen-id="tutorial"
     data-screen-name="チュートリアル"
     data-figma-url="https://figma.com/design/..."
     data-figma-node="2350:6396"
     data-figma-filekey="a0Yir10b6qxVEltgVTOa9d"
     data-figma-name="チュートリアル01"
     data-figma-token-bg="Background/Default/Default Hover"
     role="main"
     aria-label="チュートリアル">
```

### ナビゲーションバー

```html
<header role="banner">
  <nav class="w-full h-14 min-h-[56px] bg-bg-default-default flex items-center justify-between px-space-150 py-space-200"
       data-figma-node="xxx"
       data-figma-token-bg="Background/Default/Default"
       data-figma-token-height="56px"
       aria-label="ナビゲーション">
    <button data-figma-content-id="nav_back_icon"
            data-figma-content-type="icon"
            data-figma-content-classification="asset"
            data-figma-icon-svg="assets/icon-back.svg"
            data-figma-interaction="tap:navigate:back"
            data-figma-navigate="previous-screen"
            data-figma-states="default,hover,active,disabled"
            aria-label="戻る">
      <img src="assets/icon-back.svg" alt="" width="24" height="24">
    </button>
    <h1 data-figma-content-id="nav_title"
        data-figma-content-type="text"
        data-figma-content-classification="static"
        data-figma-token-font="JP/18 - Bold">タイトル</h1>
    <button data-figma-content-id="nav_close_icon"
            data-figma-interaction="tap:navigate:top"
            aria-label="閉じる">
      <img src="assets/icon-close.svg" alt="" width="24" height="24">
    </button>
  </nav>
</header>
```

### プライマリボタン

```html
<button class="w-full min-h-[48px] rounded-radius-100 bg-bg-main-default text-text-default-on font-bold"
        data-figma-node="2350:6410"
        data-figma-content-id="primary_button"
        data-figma-content-type="text"
        data-figma-content-value="次へ"
        data-figma-content-classification="static"
        data-figma-content-data-type="string"
        data-figma-content-notes="最終ステップでは「はじめる」に変化"
        data-figma-interaction="tap:navigate:next-step"
        data-figma-navigate="tutorial-step-{n+1}"
        data-figma-states="default,hover,active,disabled,loading"
        data-figma-token-bg="Background/Main/Default"
        data-figma-token-color="Text/Default/On"
        data-figma-token-radius="Radius/100"
        data-figma-token-height="48px">
  次へ
</button>
```

### リストアイテム

```html
<article class="flex flex-col gap-space-100 cursor-pointer"
         data-figma-node="2350:2737"
         data-figma-content-id="history_item_1"
         data-figma-content-classification="dynamic_list"
         data-figma-content-type="list"
         data-figma-interaction="tap:navigate:explanation"
         data-figma-navigate="/explanation"
         data-figma-token-gap="Space/100">
  <div class="flex items-center gap-space-100">
    <div class="px-2 py-1 rounded-radius-050 border-2"
         data-figma-token-bg="Background/Default/Default"
         data-figma-token-border="Subject/Math"
         data-figma-token-radius="Radius/050">
      <span data-figma-content-id="item_category_1"
            data-figma-content-classification="dynamic"
            data-figma-content-type="text">数学 解き方を教えて</span>
    </div>
    <span data-figma-content-id="item_date_1"
          data-figma-content-classification="dynamic"
          data-figma-content-type="text"
          data-figma-token-color="Text/Default/Tertiary">00月00日 00:00</span>
    <img data-figma-content-id="item_bookmark_1"
         data-figma-content-classification="dynamic"
         data-figma-content-type="icon"
         data-figma-states="default,bookmarked"
         src="assets/icon-bookmark-filled.svg">
  </div>
  <div class="rounded-radius-100 overflow-hidden">
    <img data-figma-content-id="item_preview_1"
         data-figma-content-classification="user_asset"
         data-figma-content-type="image"
         src="assets/screenshot.png">
  </div>
</article>
```

### ボトムナビゲーション

```html
<footer role="contentinfo">
  <nav class="w-full h-14 flex items-center border-t bg-bg-default-default"
       data-figma-node="1962:10375"
       data-figma-content-id="bottom_tab_bar"
       data-figma-content-type="ui_state"
       data-figma-content-classification="config"
       data-figma-token-bg="Background/Default/Default"
       data-figma-token-border="Icon/Disabled/Default"
       aria-label="メインナビゲーション"
       role="tablist">
    <a class="flex-1 h-full flex flex-col items-center justify-center gap-[2px]"
       data-figma-content-id="nav_top_tab"
       data-figma-interaction="tap:navigate:top"
       data-figma-navigate="/{locale}/ask_ai"
       data-figma-states="active,inactive"
       role="tab"
       aria-selected="true">
      <img data-figma-icon-svg="1962:10234"
           data-figma-content-id="nav_top_icon"
           data-figma-content-type="icon"
           data-figma-content-classification="asset"
           src="assets/icon-home-active.svg">
      <span data-figma-content-id="nav_top_label"
            data-figma-content-type="text"
            data-figma-content-classification="static"
            data-figma-token-font="JP/12 - Bold"
            data-figma-token-color="Text/Main/Default">トップ</span>
    </a>
    <a class="flex-1 h-full flex flex-col items-center justify-center gap-[2px]"
       data-figma-content-id="nav_mylist_tab"
       data-figma-interaction="tap:navigate:history"
       data-figma-navigate="/{locale}/ask_ai/history"
       data-figma-states="active,inactive"
       role="tab"
       aria-selected="false">
      <img data-figma-icon-svg="2239:2782"
           data-figma-content-id="nav_mylist_icon"
           src="assets/icon-bookmark.svg">
      <span data-figma-content-id="nav_mylist_label"
            data-figma-token-color="Text/Default/Default">マイリスト</span>
    </a>
  </nav>
</footer>
```

### ページネーション

```html
<nav class="flex items-center justify-center gap-space-100"
     data-figma-node="2350:6402"
     data-figma-content-id="pagination"
     data-figma-content-type="ui_state"
     data-figma-content-classification="config"
     data-figma-content-data-type="number"
     data-figma-content-notes="現在のステップを示す（1-4）"
     data-figma-token-gap="Space/100"
     aria-label="チュートリアルページ"
     role="navigation">
  <ol class="contents list-none">
    <li data-step="1"
        data-figma-content-id="pagination_dot_1"
        data-figma-content-type="ui_state"
        data-figma-content-classification="config"
        data-figma-token-bg="Background/Main/Default"
        aria-current="page"
        aria-label="ステップ1"></li>
    <li data-step="2"
        data-figma-content-id="pagination_dot_2"
        aria-label="ステップ2"></li>
  </ol>
</nav>
```

---

## 🎨 Tailwindクラス早見表

### 背景色

```
bg-bg-default-default      #ffffff（白）
bg-bg-default-hover        #fafafa（ホバー）
bg-bg-default-secondary    #e9eeef（セカンダリ）
bg-bg-main-default         #0070e0（メインブルー）
bg-bg-main-secondary       #cfe5fc（薄いブルー）
bg-bg-disabled-default     #dae2e5（無効）
```

### テキスト色

```
text-text-default-default    #24243f（デフォルト）
text-text-default-secondary  #67717a（セカンダリ）
text-text-default-tertiary   #adb8be（三次）
text-text-default-on         #ffffff（白抜き）
text-text-main-default       #0070e0（メインブルー）
```

### スペーシング

```
space-050   4px
space-100   8px
space-150   12px
space-200   16px
space-300   24px
space-400   32px
```

### 角丸

```
radius-050    4px
radius-100    8px
radius-200    16px
radius-full   9999px（完全円形）
```

### フォント

```
font-hiragino      Hiragino Sans（通常）
text-[10px]        10px
text-xs            12px
text-sm            14px
text-base          16px
text-lg            18px
text-xl            20px
```

---

## 🎭 アイコン処理

```html
<!-- img要素でアイコン表示 + data-figma-icon-svg でトレース -->
<button class="w-11 h-11 flex items-center justify-center"
        data-figma-content-id="nav_back_icon"
        data-figma-content-type="icon"
        data-figma-content-classification="asset"
        data-figma-content-data-type="svg"
        data-figma-icon-svg="assets/icon-back.svg">
  <img src="assets/icon-back.svg" alt="" width="24" height="24" aria-hidden="true">
</button>

<!-- インラインSVGの場合 -->
<button data-figma-icon-svg="2239:2926">
  <svg viewBox="0 0 18 18" fill="none" aria-hidden="true" class="w-[18px] h-[18px]">
    <path fill-rule="evenodd" d="..." fill="#24243F"/>
  </svg>
</button>
```

---

## 🚫 除外するもの

- ステータスバー（時刻、電波、バッテリー）
- Dynamic Island
- Home Indicator
- 複雑なSVGパス（プレースホルダーに置換）

---

## 📁 出力ファイル

```
.outputs/{screen-name}/
├── index.html              # メインHTML
├── index-{state}.html      # 状態バリエーション（該当する場合）
├── spec.md                 # 画面仕様書（コンテンツ分析含む）
├── mapping-overlay.js      # マッピング可視化スクリプト
└── assets/                 # アセット（オプション）
    ├── icons/
    └── images/
```

---

## ✅ 完了チェックリスト

### 基本

- [ ] Figmaスクリーンショットと見た目一致
- [ ] 全要素に`data-figma-node`
- [ ] OSネイティブUI除外済み
- [ ] HTMLがブラウザでエラーなく開ける

### コンテンツ分類属性

- [ ] `data-figma-content-id`（snake_case）
- [ ] `data-figma-content-type`（text/icon/ui_state/list/image）
- [ ] `data-figma-content-classification`（static/dynamic/asset等）
- [ ] `data-figma-content-data-type`（string/number/svg/image）

### デザイントークン属性

- [ ] `data-figma-token-bg`
- [ ] `data-figma-token-color`
- [ ] `data-figma-token-font`
- [ ] 必要に応じて他のトークン属性

### インタラクション属性

- [ ] `data-figma-interaction`（trigger:action:target）
- [ ] `data-figma-navigate`（遷移先パス）
- [ ] `data-figma-states`（対応UI状態）

### アイコン

- [ ] アイコンに`data-figma-icon-svg`
- [ ] `data-figma-content-type="icon"`
- [ ] `data-figma-content-classification="asset"`

### アクセシビリティ

- [ ] role属性（button, tab, tablist, navigation等）
- [ ] aria-label（アイコンボタン）
- [ ] aria-selected（タブ）
- [ ] aria-current（ページネーション）
- [ ] aria-disabled（無効ボタン）

---
