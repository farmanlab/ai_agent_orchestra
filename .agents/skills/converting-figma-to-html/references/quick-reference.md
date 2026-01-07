# Figma MCP → HTML 変換 クイックリファレンス

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

## 📋 必須data属性

| 属性 | 用途 | 例 |
|------|------|-----|
| `data-figma-node` | ノードID | `"5070:65342"` |
| `data-figma-content-XXX` | コンテンツID | `nav-title` |
| `data-figma-tokens` | デザイントークン | `"background: darkblue"` |
| `data-figma-font` | フォントトークン | `"JP/16 - Bold"` |
| `data-figma-icon-svg` | アイコンURL | `"https://..."` |

---

## 🎯 インタラクション属性

| 属性 | 用途 | 例 |
|------|------|-----|
| `data-figma-interaction` | インタラクション定義 | `"tap:navigate:/course/1"` |
| `data-figma-states` | サポートするUI状態 | `"default,hover,active,disabled"` |
| `data-figma-navigate` | 画面遷移先 | `"/course/detail"` |
| `data-state` | 現在のUI状態 | `"disabled"`, `"loading"` |

### インタラクション形式

```
形式: {trigger}:{action}:{target}

例:
tap:navigate:/course/1       タップで画面遷移
tap:show-modal:confirm       タップでモーダル表示
hover:show-tooltip:help      ホバーでツールチップ表示
```

### UI状態一覧

| 状態 | 説明 | CSS例 |
|------|------|-------|
| `default` | 通常状態 | - |
| `hover` | ホバー中 | `:hover` |
| `active` | タップ/クリック中 | `:active` |
| `focus` | フォーカス中 | `:focus` |
| `disabled` | 無効状態 | `[data-state="disabled"]` |
| `loading` | 読み込み中 | `[data-state="loading"]` |
| `selected` | 選択状態 | `.active`, `aria-current` |

---

## 🎨 data-figma-content-XXX 命名規則

```
形式: {category}-{element}

例:
nav-title          ナビタイトル
tab-learning       タブ「学習」
section-title      セクションタイトル
achievement-value  達成率の値
course-item        講座アイテム
course-title       講座タイトル
nav-home-icon      ナビのホームアイコン
nav-home-label     ナビのホームラベル
```

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
- [ ] ラベル系（「〜の」「〜一覧」）
- [ ] ボタンテキスト
- [ ] ナビゲーション項目
- [ ] 単位（分、時間、%）

**dynamic（動的）**
- [ ] 数値（カウント、パーセント）
- [ ] 日付・期間
- [ ] ユーザー名・ID
- [ ] ステータス値

---

## 🏷️ コンテンツ分類属性

### 必須属性

| 属性 | 用途 | 例 |
|------|------|-----|
| `data-figma-content-id` | 一意識別子（snake_case） | `"badge_text"` |
| `data-figma-content-type` | コンテンツ種別 | `"text"`, `"icon"`, `"ui_state"` |
| `data-figma-content-classification` | 分類 | `"static"`, `"dynamic"` |
| `data-figma-content-data-type` | データ型 | `"string"`, `"number"`, `"svg"` |

### オプション属性

| 属性 | 用途 | 例 |
|------|------|-----|
| `data-figma-content-value` | Figmaでの表示値 | `"テスト運用版"` |
| `data-figma-content-notes` | 補足説明 | `"最終ステップでは変化"` |
| `data-figma-display-format` | 表示フォーマット | `"{value}分"` |

### type の値一覧

| 値 | 説明 |
|-----|------|
| `text` | テキストコンテンツ |
| `number` | 数値 |
| `percentage` | パーセンテージ |
| `duration` | 時間・期間 |
| `date` | 日付 |
| `date_range` | 日付範囲 |
| `list` | リストコンテナ |
| `icon` | アイコン |
| `ui_state` | UI状態（ページネーション等） |

### 埋め込み例

```html
<!-- テキスト（静的） -->
<span data-figma-node="2350:6414"
      data-figma-content-id="badge_text"
      data-figma-content-type="text"
      data-figma-content-value="テスト運用版"
      data-figma-content-classification="static"
      data-figma-content-data-type="string">テスト運用版</span>

<!-- アイコン（アセット） -->
<button data-figma-node="I2350:6398;48:622"
        data-figma-content-id="nav_back_icon"
        data-figma-content-type="icon"
        data-figma-content-classification="asset"
        data-figma-content-data-type="svg"
        data-figma-icon-svg="assets/icon-back.svg">
  <img src="assets/icon-back.svg" width="24" height="24">
</button>

<!-- UI状態（設定） -->
<nav data-figma-node="2350:6402"
     data-figma-content-id="pagination"
     data-figma-content-type="ui_state"
     data-figma-content-classification="config"
     data-figma-content-data-type="number"
     data-figma-content-notes="現在のステップ（1-4）">
```

### content-id 命名規則

```
形式: {category}_{element} (snake_case)

例:
badge_text          バッジのテキスト
nav_back_icon       ナビの戻るアイコン
step_description    ステップの説明文
pagination_dot_1    ページネーションドット1
next_button         次へボタン
```

---

## 🔗 画面遷移属性

### 必須属性

| 属性 | 用途 | 例 |
|------|------|-----|
| `data-figma-interaction` | インタラクション定義 | `"tap:navigate:tutorial"` |
| `data-figma-navigate` | 遷移先パス | `"/{locale}/ask_ai/tutorial"` |
| `data-figma-states` | サポートするUI状態 | `"default,hover,active,disabled"` |

### 遷移パターン

| パターン | 形式 | 例 |
|---------|------|-----|
| 単純遷移 | `tap:navigate:{target}` | `tap:navigate:tutorial` |
| 条件付き | `tap:conditional-navigate` | 同意状態で分岐 |
| 内部遷移 | `tap:navigate:next-step` | ステップ遷移 |
| 複合 | `tap:action1\|action2` | ファイル選択+遷移 |
| 戻る | `tap:navigate:back` | 前の画面へ |

### 遷移先の記述形式

```
単純遷移:
  /{locale}/ask_ai/tutorial

条件付き:
  consented:/{locale}/ask_ai|unconsented:consent-modal

内部遷移:
  tutorial-step-{n+1}
  previous-screen
```

### 埋め込み例

```html
<!-- 単純な画面遷移 -->
<button data-figma-interaction="tap:navigate:tutorial"
        data-figma-navigate="/{locale}/ask_ai/tutorial">
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

<!-- ボトムナビゲーション -->
<a data-figma-interaction="tap:navigate:history"
   data-figma-navigate="/{locale}/ask_ai/history"
   data-figma-states="active,inactive">
  マイリスト
</a>
```

### spec.md から遷移情報を抽出

1. 「インタラクション」セクション → 各要素のタップ時動作
2. 「画面フロー」セクション → 画面間の遷移関係
3. ボタン・リンク・ナビ要素に属性を付与

---

## 🏗️ HTML構造パターン

### ナビゲーションバー
```html
<nav class="flex items-center justify-between p-2.5 bg-[#0b41a0]"
     data-figma-node="xxx">
  <div class="w-6 h-6"><!-- 左ボタン --></div>
  <h1 data-figma-content-nav-title>タイトル</h1>
  <button data-figma-content-settings-icon><!-- 右ボタン --></button>
</nav>
```

### タブメニュー
```html
<div class="flex" data-figma-content-tab-menu>
  <button data-figma-content-tab-active>
    <span data-figma-content-tab-xxx>タブ1</span>
    <div class="h-[3px] bg-[#3ec1bd]"></div>
  </button>
  <button>
    <span data-figma-content-tab-yyy>タブ2</span>
  </button>
</div>
```

### リストアイテム
```html
<div data-figma-content-xxx-list>
  <article data-figma-content-xxx-item>
    <div data-figma-content-xxx-icon><!-- アイコン --></div>
    <div>
      <p data-figma-content-xxx-category>カテゴリ</p>
      <p data-figma-content-xxx-title>タイトル</p>
    </div>
    <span data-figma-content-xxx-value>値</span>
  </article>
</div>
```

### ボトムナビゲーション
```html
<nav class="fixed bottom-0 h-[56px] flex" data-figma-content-bottom-nav>
  <button data-figma-content-nav-xxx>
    <div data-figma-content-nav-xxx-icon><!-- アイコン --></div>
    <span data-figma-content-nav-xxx-label>ラベル</span>
  </button>
</nav>
```

---

## 🎭 アイコン処理

```html
<!-- プレースホルダーSVG + Figma URL埋め込み -->
<div class="w-6 h-6"
     data-figma-icon-svg="https://figma.com/api/..."
     data-figma-content-xxx-icon>
  <svg class="w-6 h-6" viewBox="0 0 24 24" fill="none">
    <rect x="4" y="4" width="16" height="16" rx="2" 
          stroke="currentColor" stroke-width="2"/>
  </svg>
</div>
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
.outputs/{short-screen-name}/
├── index.html              # メインHTML
├── spec.md                 # 画面仕様書（コンテンツ分析含む）
├── preview.html            # プレビュー（オプション）
└── tokens.md               # トークン（オプション）
```

---

## ✅ 完了チェックリスト

- [ ] Figmaスクリーンショットと見た目一致
- [ ] 全要素に`data-figma-node`
- [ ] コンテンツ要素に`data-figma-content-XXX`
- [ ] アイコンに`data-figma-icon-svg`
- [ ] OSネイティブUI除外済み
- [ ] コンテンツ分析完成
- [ ] コンテンツ分類属性が埋め込まれている
  - `data-figma-content-id`（snake_case）
  - `data-figma-content-type`
  - `data-figma-content-classification`
  - `data-figma-content-data-type`
- [ ] 画面遷移属性が埋め込まれている
  - `data-figma-interaction`（トリガー:アクション:ターゲット）
  - `data-figma-navigate`（遷移先パス）
  - `data-figma-states`（対応UI状態）

---

## 📝 よく使うTailwindクラス

### 背景色
```
bg-[#0b41a0]  ナビ（ダークブルー）
bg-[#093788]  アクセント
bg-[#f8f9f9]  ページ背景
bg-white      カード背景
```

### テキスト色
```
text-white         白
text-[#24243f]     デフォルト
text-[#67717a]     セカンダリ
text-[#0070e0]     リンク
```

### フォント
```
font-hiragino      通常
font-hiragino-w3   細い
font-hiragino-w6   太い
font-number        数字
```

### サイズ
```
text-[10px]   10px
text-xs       12px
text-sm       14px
text-base     16px
text-xl       20px
text-2xl      24px
```
