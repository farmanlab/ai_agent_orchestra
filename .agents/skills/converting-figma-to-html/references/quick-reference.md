# Figma MCP → HTML 変換 クイックリファレンス

## 🚀 基本フロー

```
1. figma:get_screenshot     → ビジュアル参照
2. figma:get_design_context → 構造・スタイル取得 ★メイン
3. figma:get_metadata       → 階層構造確認（必要時）
4. HTML生成                 → data属性付きHTML
5. コンテンツ分析           → 分類ドキュメント
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
| `asset` | アイコン・画像 | SVG、ロゴ |

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
