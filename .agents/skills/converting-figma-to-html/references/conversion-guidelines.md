# Figma MCP → フロントエンド変換ルールガイドライン

## 概要

このガイドラインは、Figma MCPから取得したデザイン情報をWeb/Android/iOSなどのフロントエンドUIに変換する際の判断基準とルールを定義する。

---

## 1. アイコン・画像アセットの処理

### ルール

| 状況 | 対応 |
|------|------|
| SVGアイコン | プレースホルダーSVGを仮置きし、**`data-figma-icon-svg`属性でアイコンの親ノードIDを必須設定** |
| PNG/JPG画像 | プレースホルダーを使用し、`data-figma-asset-src`属性でFigmaアセットURLを埋め込む |
| ロゴ等のブランドアセット | 同上 |

### data-figma-icon-svg の必須設定（重要）

**アイコン要素には必ず `data-figma-icon-svg` 属性を設定すること。**

値は `get_design_context` または `get_metadata` で取得した**アイコンの親ノードID**を設定する。
このノードIDは Figma API `getImages` でSVGをダウンロードする際に使用する。

```javascript
// get_design_context の出力例
<div data-node-id="3428:18627" data-name="Common/Home(Outlined)">
  <img src="https://www.figma.com/api/mcp/asset/..." />  // MCP URLは7日で期限切れ
</div>
```

```html
<!-- HTML出力: data-figma-icon-svg にノードIDを設定 -->
<span class="icon" data-figma-icon-svg="3428:18627" data-figma-node="3428:18626">
  <svg><!-- placeholder --></svg>
</span>
```

### ノードIDの取得方法

1. `get_design_context` を呼び出す
2. アイコン要素の `data-node-id` または `data-name` からノードIDを特定
3. 対応するアイコン要素の `data-figma-icon-svg` 属性に設定

### getImages APIでのダウンロード

```bash
# Figma API でSVGをエクスポート
curl -H "X-Figma-Token: $FIGMA_TOKEN" \
  "https://api.figma.com/v1/images/{file_key}?ids=3428:18627&format=svg"
```

**注意**: インスタンスノードの場合、親コンポーネントのノードIDを使用する必要がある場合がある。

### プレースホルダー方針

**SVGやアイコンは無理に再現しようとしない。** サイズと位置関係を最優先とし、簡単なプレースホルダーに置き換える。

```html
<!-- ❌ 複雑なパスを再現しようとしない -->
<svg viewBox="0 0 24 24">
  <path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm-1 17.93c-3.95-.49-7-3.85-7-7.93 0-.62.08-1.21.21-1.79L9 15v1c0 1.1.9 2 2 2v1.93zm6.9-2.54c-.26-.81-1-1.39-1.9-1.39h-1v-3c0-.55-.45-1-1-1H8v-2h2c.55 0 1-.45 1-1V7h2c1.1 0 2-.9 2-2v-.41c2.93 1.19 5 4.06 5 7.41 0 2.08-.8 3.97-2.1 5.39z"/>
</svg>

<!-- ✅ シンプルな図形でサイズ・位置を保持 -->
<svg class="w-6 h-6" viewBox="0 0 24 24" fill="none">
  <rect x="4" y="4" width="16" height="16" rx="2" stroke="currentColor" stroke-width="2"/>
</svg>
```

### 実装例

```html
<span class="w-6 h-6"
      data-figma-icon-svg="3428:18627"
      data-figma-icon-color="Icon/Main/Default">
  <!-- Placeholder SVG -->
  <svg viewBox="0 0 24 24">...</svg>
</span>
```

### data属性仕様

| 属性 | 用途 | 値の例 | 必須 |
|------|------|--------|:----:|
| `data-figma-icon-svg` | **アイコンの親ノードID（getImages用）** | `3428:18627` | **必須** |
| `data-figma-icon-color` | Figmaのカラートークン名 | `Icon/Main/Default` | 任意 |
| `data-figma-asset-src` | FigmaアセットURL（画像、7日間有効） | `https://www.figma.com/api/mcp/asset/xxx-xxx` | 任意 |

### アイコンコンテナの配置ルール（重要）

**Figma MCPで明確な配置指定がない場合、アイコンはコンテナ内で中央配置をデフォルトとする。**

| アイコンの配置方法 | 実装 |
|-------------------|------|
| `<div>` で囲む場合 | `display: flex; align-items: center; justify-content: center;` |
| `<img>` 直接の場合 | 親要素で `display: flex; align-items: center;` を設定 |
| `<svg>` インラインの場合 | 親要素で `display: flex; align-items: center; justify-content: center;` |

### 実装例（アイコンコンテナ）

```html
<!-- ✅ divで囲む場合 -->
<div class="w-6 h-6 flex items-center justify-center">
  <img src="icon.svg" class="max-w-full max-h-full" alt="">
</div>

<!-- ✅ ボタン内のアイコン（親がflex） -->
<button class="flex items-center gap-2">
  <img src="icon.svg" class="w-6 h-6 object-contain" alt="">
  <span>ラベル</span>
</button>
```

### 理由

- Figmaでは要素は常に中央に配置されているように見えるが、明示的な指定がないことが多い
- HTMLでは明示的に配置を指定しないと左上に寄る
- デフォルトで中央配置にすることで、Figmaデザインとの乖離を防ぐ

### 注意事項

- FigmaアセットURLは**7日間で期限切れ**になるため、実装時に再取得またはダウンロードが必要
- 後処理スクリプトで`data-figma-icon-svg`属性からURLを抽出し、アセットをダウンロード可能

---

## 2. レイアウト・配置の処理

### ルール

**Figmaの絶対位置情報はコンポーネントの位置関係・並べ方の参考にとどめ、`absolute`や`fixed`は使用しない。**

| Figmaの状態 | 変換方針 |
|-------------|----------|
| 絶対位置で配置されている | Flexbox/Gridで相対的なレイアウトに変換 |
| オーバーラップしている要素 | 必要に応じて`relative`+`absolute`を検討するが、基本は避ける |
| 固定サイズ指定 | レスポンシブを考慮し、`max-w-*`や`w-full`を優先 |

### サイズ指定の柔軟化

**オートレイアウトの有無に関わらず、視覚情報からfill/hug/fixedの意図を推測し、固定px値を避ける。**

| 視覚的特徴 | 推測される意図 | 変換方針 |
|-----------|---------------|----------|
| 親と同じ幅/高さ | Fill (親に合わせる) | `w-full`, `flex-1` |
| コンテンツにぴったり | Hug (内容に合わせる) | `w-fit`, `w-auto` |
| 特定のサイズで固定 | Fixed | `w-[Npx]` (最小限に) |

### 理由

- Figmaのデザインはピクセルパーフェクトだが、実装は様々な画面サイズに対応する必要がある
- 絶対位置はメンテナンス性が低く、レスポンシブ対応が困難
- Flexbox/Gridを使うことで、意図したレイアウトを柔軟に実現できる

### 実装例

```html
<!-- ❌ Figmaの絶対位置をそのまま使わない -->
<div class="relative">
  <div class="absolute top-[16px] left-[24px]">ヘッダー</div>
  <div class="absolute top-[80px] left-[24px]">コンテンツ</div>
</div>

<!-- ✅ Flexboxで位置関係を再現 -->
<div class="flex flex-col gap-4 p-6">
  <div>ヘッダー</div>
  <div>コンテンツ</div>
</div>
```

### 例外

以下の場合のみ`absolute`/`fixed`を許容：

- モーダル/オーバーレイ
- ツールチップ/ポップオーバー
- フローティングアクションボタン
- アイコンバッジ（通知数など）

---

## 3. デザイントークンの処理

### ルール

- Figmaのデザイントークン（CSS変数形式）はTailwindの固定値に変換
- 元のトークン名は`data-figma-tokens`属性で保持
- マッピング表を別途作成し、デザインシステムとの整合性を維持

### 実装例

```html
<div class="gap-3 px-4 py-3 bg-[#cfe5fc]"
     data-figma-tokens="background: Background/Main/Secondary, gap: Space/150, padding-x: Space/200, padding-y: Space/150">
```

### マッピング優先順位

1. プロジェクトのtailwind.config.jsに定義済みのトークンがあれば使用
2. なければTailwindのデフォルトユーティリティクラスで近似
3. 完全一致がなければ任意値（`[]`記法）で対応

---

## 4. タイポグラフィの処理

### ルール

- Figmaのフォントトークン名を`data-figma-font`属性で埋め込む
- フォントファミリーはシステムフォント依存を考慮しフォールバックを設定
- Webフォントとして利用不可のフォント（Hiragino Sans等）は代替フォントを明示

### 実装例

```html
<span class="font-hiragino text-base leading-[1.5]"
      data-figma-font="JP/16 - Regular"
      data-figma-tokens="color: Text/Default/Default">
  テキスト
</span>
```

### フォントフォールバック設定

```css
.font-hiragino {
  font-family: "Hiragino Sans", "Hiragino Kaku Gothic ProN", "Noto Sans JP", sans-serif;
}
```

---

## 5. コンポーネント状態の処理

### ルール

| 状況 | 対応 |
|------|------|
| 状態バリエーションが別ノードで定義されている | 各状態のノードIDを取得し、hover/active/disabled等のスタイルを抽出 |
| 状態バリエーションがない | デフォルトのインタラクションスタイルを追加（hover:bg-gray-100等） |
| 状態バリエーションの有無が不明 | ユーザーに確認を求める |

### 実装例（状態なしの場合）

```html
<a href="#" class="... hover:bg-gray-100 transition-colors">
```

---

## 6. インタラクション属性

### ルール

インタラクティブな要素には、画面遷移やモーダル表示などの動作を定義するdata属性を付与する。

| 属性 | 用途 | 必須 |
|------|------|:----:|
| `data-figma-interaction` | インタラクション定義 | インタラクティブ要素で必須 |
| `data-figma-states` | サポートするUI状態 | 状態変化がある要素で必須 |
| `data-figma-navigate` | 画面遷移先 | navigate時のみ |
| `data-state` | 現在のUI状態 | disabled/loading時のみ |

### インタラクション形式

```
形式: {trigger}:{action}:{target}

trigger: tap, hover, focus, longpress
action: navigate, show-modal, close-modal, submit, toggle
target: 遷移先パス, モーダルID, または対象要素
```

### 実装例（画面遷移）

```html
<article class="course-card"
         data-figma-states="default,hover,active"
         data-figma-interaction="tap:navigate:/course/1"
         data-figma-navigate="/course/1"
         tabindex="0" role="button">
  <h3>講座タイトル</h3>
</article>
```

### 実装例（モーダル表示）

```html
<button data-figma-states="default,hover,active"
        data-figma-interaction="tap:show-modal:confirm-dialog">
  削除する
</button>
```

### 実装例（無効状態）

```html
<button data-figma-states="default,hover,active,disabled"
        data-state="disabled">
  送信
</button>
```

### 実装例（読み込み中状態）

```html
<button data-figma-states="default,hover,active,loading"
        data-state="loading">
  保存中...
</button>
```

### UI状態のCSS実装

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

@keyframes spin {
  to { transform: rotate(360deg); }
}
```

---

## 7. Figmaノード情報の保持

### ルール

- すべての主要要素に`data-figma-node`属性でノードIDを埋め込む
- デバッグ・トレーサビリティ・将来の更新のため

### 実装例

```html
<div data-figma-node="I4829:26664;4067:23861">
```

---

## 8. 出力ファイル構成

### 推奨構成

```
.outputs/{short-screen-name}/
├── index.html                   # 変換後のHTML
├── spec.md                      # 画面仕様書（コンテンツ分析含む）
└── assets/
    └── icons/                   # エクスポートしたSVG（後から配置）
```

`{short-screen-name}` はFigmaの画面名から生成した短い識別名（例: `homework-modal`, `login-form`）

---

## 9. 変換プロセスのチェックリスト

### 変換前

- [ ] `get_design_context`でコード情報を取得
- [ ] `get_variable_defs`でデザイントークンを取得
- [ ] `get_screenshot`でビジュアル参照を取得
- [ ] 状態バリエーションの有無を確認

### 変換中

- [ ] アイコンは仮置き + `data-figma-icon-svg`属性でFigma URLを埋め込み
- [ ] フォントトークンは`data-figma-font`属性で保持
- [ ] カラー/スペーシングトークンは`data-figma-tokens`属性で保持
- [ ] ノードIDは`data-figma-node`属性で保持

### 変換後

- [ ] デザイントークンマッピング表を作成
- [ ] フォントフォールバックを設定
- [ ] アクセシビリティ属性（aria-label等）を追加

---

## 10. OSネイティブUI要素の処理

### ルール

**OSネイティブUI要素は変換対象から省略する。** ネイティブアプリではOSが自動描画し、Webアプリでは通常表示しないため。

### OSネイティブUIの判断基準

以下の条件に該当する要素はOSネイティブUIと判断し、**出力から除外する**：

| 判断基準 | 具体例 |
|----------|--------|
| **ノード名に以下を含む** | `Status Bar`, `StatusBar`, `status-bar`, `Bars/Status` |
| **ノード名に以下を含む** | `Notch`, `Dynamic Island`, `Home Indicator` |
| **子要素に以下が含まれる** | 時刻表示（`9:41`, `12:00`等の固定時刻）、`Carrier`, `100%`（バッテリー）、電波アイコン、WiFiアイコン、バッテリーアイコン |
| **位置が画面最上部** | y=0 かつ height が 20〜50px 程度の細長いバー |
| **iOSデザインの特徴** | SF Pro フォント使用、黒/白のステータスアイコン群 |
| **Androidデザインの特徴** | Roboto フォント使用、時刻が左上、アイコンが右上 |

### 実装例

```html
<!-- ❌ ステータスバーを含めない -->
<div class="navigation">
  <div class="status-bar">...</div>  <!-- 削除 -->
  <nav class="nav-bar">...</nav>
</div>

<!-- ✅ ナビゲーション部分のみ出力 -->
<nav class="nav-bar">...</nav>
```

### 注意

- デザインファイル内では視覚的な確認のためにステータスバーが含まれることが多い
- 変換時は自動的に除外し、アプリ固有のUIのみを出力する

---

## 11. プラットフォーム別の考慮事項

### Web (HTML/Tailwind)

- CDN版Tailwindで即座にプレビュー可能
- data属性でメタ情報を保持

### Android (Compose/XML)

- トークンマッピングをdimens.xml/colors.xmlに変換
- data属性の情報をXMLコメントとして保持

### iOS (SwiftUI/UIKit)

- トークンマッピングをAsset Catalog/拡張に変換
- data属性の情報をコードコメントとして保持

---

## 12. PCでのモバイルデザインプレビュー

詳細は [mobile-preview.md](./mobile-preview.md) を参照。

**概要**: iframeとデバイスフレームを使用してモバイルHTMLをPC上でプレビューする方法。

---

## 13. コンテンツ分析（後続フェーズ連携用）

詳細は [content-classification.md](./content-classification.md) を参照。

**概要**: HTMLコンテンツを静的/動的/リストに分類し、データ要件を整理する方法。

---

## 14. CSS/HTMLのベストプラクティス優先

Figmaのノード構造を忠実に再現するのではなく、同じ視覚結果を達成するCSS/HTMLのベストプラクティスを優先する。

| Figmaの構造 | 変換方針 |
|-------------|----------|
| 文字が個別ノードで縦に並ぶ | `writing-mode: vertical-rl` で縦書き |
| 絶対位置で配置 | Flexbox/Grid で相対レイアウト |
| コンポーネントにバリアント名あり | バリアント名に従ったスタイル適用 |

---

## 15. 実装不要要素の除外

ブラウザ/OSが描画する要素やデザイン参照用要素は出力から除外する。

| 除外対象 | 理由 |
|----------|------|
| スクロールバー形状の矩形 | ブラウザがスクロールバーを描画 |
| カーソル/ポインター | OS/ブラウザが描画 |
| ステータスバー等のOS UI | OSが描画 |
| デザインガイド線 | デザイナー向け参照 |

---

## 16. 出力前の整合性チェック

生成したHTMLに論理的矛盾がないか確認する。

| チェック項目 | 問題例 |
|-------------|--------|
| 親子サイズの整合性 | 親が `w-px` (1px) で子が `w-[171px]` |
| overflow設定 | スクロール領域に `overflow-y: auto` だとコンテンツ不足時にスクロールバー非表示 |
| 視覚とDOMの一致 | 見た目は縦書きだがDOMは横並び |

---

## 変更履歴

| 日付 | 変更内容 |
|------|----------|
| 2025-01-XX | 初版作成 |
| 2025-12-19 | ベストプラクティス優先、実装不要要素除外、整合性チェックのルール追加 |
