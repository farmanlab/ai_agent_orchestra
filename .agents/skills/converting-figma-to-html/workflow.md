# Figma MCP → HTML変換 ワークフロープロンプト

## 概要

このプロンプトは、Figma MCPを使用してFigmaデザインからHTML/CSSを生成し、コンテンツ分析を行うための完全なワークフローです。

---

## 使用方法

以下のプロンプトをコピーして、Figma URLを置き換えて使用してください。

### メインプロンプト

```
以下のFigma URLからHTML/CSSを生成してください。

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
【Figma URL】
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

{ここにFigma URLを貼り付け}

例: https://figma.com/design/XXXXX/Project?node-id=1234-5678

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
【Step 1: Figmaデータ取得】
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

以下の順序でFigma MCPツールを実行：

1. figma:get_screenshot
   - デザインのビジュアル参照を取得
   - 実装時の比較基準として使用

2. figma:get_design_context
   - clientLanguages: "html,css"
   - デザイン構造、スタイル情報、アセットURLを取得
   - ★最重要：これがHTML生成の主データソース

3. figma:get_metadata（必要に応じて）
   - 階層構造の詳細確認用
   - 複雑なレイアウトの場合に使用

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
【Step 2: HTML生成ルール】
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

■ 基本設定
- Tailwind CSS（CDN経由）を使用
- 日本語フォント: Hiragino Sans + フォールバック
- モバイルファースト（max-w-[375px]等）

■ 必須data属性
以下の属性を適切な要素に付与すること：

| 属性 | 用途 | 付与対象 |
|------|------|----------|
| data-figma-node | FigmaノードID | 主要な全要素 |
| data-figma-tokens | デザイントークン | 色・スペーシング使用要素 |
| data-figma-font | フォントトークン | テキスト要素 |
| data-figma-icon-svg | アイコンURL | SVGアイコン |
| data-figma-content-XXX | コンテンツID | コンテンツ要素 |

■ data-figma-content-XXX の命名規則
- 2-3語のケバブケース
- 例: nav-title, achievement-value, course-item

■ アイコン・画像の処理
- 複雑なSVGパスは再現しない
- シンプルなプレースホルダーを配置
- data-figma-icon-svg属性でFigma URLを埋め込む

■ レイアウト
- absolute/fixedは原則使用しない
- Flexbox/Gridで相対的に配置
- 例外: モーダル、FAB、バッジ

■ OSネイティブUI
- ステータスバー（時刻、電波、バッテリー）は省略
- Dynamic Island、Home Indicatorも省略

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
【Step 3: 出力ファイル】
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

以下のファイルを生成：

1. {component_name}.html
   - 変換後のHTML（data属性付き）

2. {component_name}_content_analysis.md
   - コンテンツ分析ドキュメント

3. {component_name}_preview.html（オプション）
   - デバイスフレーム付きプレビュー

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
【Step 4: コンテンツ分析】
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

HTMLの各コンテンツを以下の分類で整理：

■ 分類体系
| 分類 | 説明 |
|------|------|
| static | 固定ラベル・UI文言 |
| dynamic | ユーザー/時間で変わる値 |
| dynamic_list | 件数可変のリスト |
| asset | アイコン・画像 |

■ 静的と判断する条件
- ラベル系テキスト（「〜の」「〜一覧」）
- ナビゲーション項目名
- ボタンラベル
- セクションタイトル
- 単位（「分」「時間」「%」）

■ 動的と判断する条件
- 数値（パーセント、カウント、時間、金額）
- 日付・期間
- ユーザー名
- ステータス・状態値
- バッジのカウント

■ 出力フォーマット
セクションごとにテーブル形式で整理：
| ID | 表示値 | 分類 | 備考 |
|----|--------|------|------|

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
【チェックリスト】
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

生成完了後、以下を確認：

□ Figmaスクリーンショットと見た目が一致
□ 全ての主要要素にdata-figma-node属性がある
□ コンテンツ要素にdata-figma-content-XXX属性がある
□ アイコンにdata-figma-icon-svg属性がある
□ ステータスバー等のOSネイティブUIが除外されている
□ コンテンツ分析が完成している
```

---

## 品質検証ループ

変換後、以下のステップで検証を実施し、問題があれば該当ステップに戻って修正します。

### 1. ビジュアル確認

**検証内容**:
- Figmaスクリーンショットと生成HTMLを並べて比較
- レイアウト、間隔、サイズ、配置が一致しているか

**不一致がある場合**:
- → **Step 2: HTML生成ルール** に戻る
- レイアウトロジック（Flexbox/Grid）を見直し
- スペーシング（gap, padding, margin）を調整

### 2. data属性検証

**検証内容**:
```bash
# data-figma-node が全要素にあるか確認
grep -c 'data-figma-node' component.html

# data-figma-content-XXX の命名規則を確認
grep -o 'data-figma-content-[^"]*' component.html
```

**欠落がある場合**:
- → 該当要素に `data-figma-node` を追加
- コンテンツ要素に `data-figma-content-XXX` を追加
- アイコンに `data-figma-icon-svg` を追加

### 3. コンテンツ分析検証

**検証内容**:
- 全てのコンテンツが static / dynamic / dynamic_list / asset に分類されているか
- HTML内の `data-figma-content-XXX` とコンテンツ分析のIDが一致しているか
- 分類集計の件数が合っているか

**不明な分類がある場合**:
- → **Step 4: コンテンツ分析** に戻る
- 判定基準を再確認
- 必要に応じてユーザーに確認を求める

### 4. レスポンシブ確認（オプション）

**検証内容**:
- 異なる画面サイズ（375px, 390px, 430px）で表示確認
- 要素が切れたり、重なったりしていないか

**レイアウトが崩れる場合**:
- → **Step 2: HTML生成ルール** に戻る
- 固定幅を `max-w-*` に変更
- Flexboxの `flex-wrap` を確認

### 5. 完了確認

**全てのチェック項目が✓になったら完了**:
- 生成ファイルを最終確認
- 出力ファイル構成が正しいか確認
- 変更履歴にバージョン情報を記録

---

## 追加プロンプト（オプション）

### プレビューラッパー生成

```
生成したHTMLをデバイスフレーム付きで表示するプレビューHTMLを作成してください。

要件:
- iPhone 13 miniサイズ（375x812）
- グレー背景にデバイスフレーム
- 元HTMLはiframe経由で読み込み
- 複数デバイスサイズ切り替え可能
```

### デザイントークンマッピング生成

```
HTMLで使用されているデザイントークンの一覧を作成してください。

出力フォーマット:
| トークン名 | 使用箇所 | Tailwindクラス | Hex値 |
```

### コンポーネント分割

```
生成したHTMLを再利用可能なコンポーネント単位に分割してください。

要件:
- 各コンポーネントを独立したsection/articleで定義
- コンポーネント名をコメントで明記
- Props化すべき値を特定
```

---

## 出力ファイル構成

```
outputs/
├── {component_name}.html              # メインHTML
├── {component_name}_preview.html      # プレビュー用（オプション）
├── {component_name}_content_analysis.md  # コンテンツ分析
├── {component_name}_tokens.md         # トークンマッピング（オプション）
└── figma_conversion_guidelines.md     # 変換ルールガイドライン
```

---

## data属性一覧

### 必須属性

| 属性 | 用途 | 値の例 |
|------|------|--------|
| `data-figma-node` | FigmaノードID | `"5070:65342"` |
| `data-figma-content-XXX` | コンテンツ識別子 | `nav-title`, `course-item` |

### 推奨属性

| 属性 | 用途 | 値の例 |
|------|------|--------|
| `data-figma-tokens` | デザイントークン | `"background: darkblue"` |
| `data-figma-font` | フォントトークン | `"System Font: Size 16"` |
| `data-figma-icon-svg` | アイコンURL | `"https://figma.com/api/..."` |
| `data-figma-icon-color` | アイコンカラー | `"Icon/Main/Default"` |

---

## data-figma-content-XXX 命名例

### ナビゲーション
- `nav-title` - ナビタイトル
- `nav-back-icon` - 戻るアイコン
- `settings-icon` - 設定アイコン

### タブ・メニュー
- `tab-menu` - タブメニュー全体
- `tab-active` - アクティブタブ
- `tab-{name}` - 各タブラベル

### コンテンツ
- `section-title` - セクションタイトル
- `{name}-label` - ラベル
- `{name}-value` - 値
- `{name}-unit` - 単位
- `{name}-icon` - アイコン

### リスト
- `{name}-list` - リストコンテナ
- `{name}-item` - リストアイテム

### ボトムナビゲーション
- `bottom-nav` - ボトムナビ全体
- `nav-{name}-icon` - 各ナビアイコン
- `nav-{name}-label` - 各ナビラベル
- `nav-active` - アクティブ状態

---

## 変更履歴

| 日付 | 変更内容 |
|------|----------|
| 2024-12-18 | 初版作成 |
