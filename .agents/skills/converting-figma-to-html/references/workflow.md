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
【Step 1.5: 画面・状態の判定】（複数フレームの場合）
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

複数フレームが含まれる場合、以下の基準で判定：

■ 同一画面の状態バリエーション
  - フレーム名に共通プレフィックス + 状態サフィックス
  - 例: Home_Default, Home_Empty, Home_Error
  - サフィックス例: _Default, _Empty, _Error, _Loading, _Modal

■ 完全に異なる画面
  - 名前に共通部分がない
  - レイアウト構造が根本的に異なる
  - 例: Home, Settings, Profile

■ 判定結果の通知
  検出結果をユーザーに通知し、確認を得る：
  ```
  3個のフレームを検出しました：
  - Home_Default, Home_Empty → 同一画面「Home」の2状態
  - Settings → 別画面

  この判定で正しいですか？
  ```

■ 出力構造の決定
  - 同一画面の状態 → 1ディレクトリ内に複数HTML
  - 別画面 → 画面ごとに別ディレクトリ

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

■ mapping-overlay.js
- `</body>` 直前に `<script src="mapping-overlay.js"></script>` を追加
- APIマッピング可視化のためのオーバーレイスクリプト

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
【Step 3: 出力ファイル】
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

以下のファイルを生成：

1. {component_name}.html
   - 変換後のHTML（data属性付き）

2. spec.md
   - 画面仕様書（コンテンツ分析セクション含む）

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
| config | 画面設定で変わる要素 |
| asset | 静的アセット（アイコン等） |
| user_asset | ユーザーアップロード画像等 |

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
【Step 5: コンテンツ分類属性の埋め込み】
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Step 4で分析した内容をHTML要素に data 属性として埋め込む。
これにより後続のAPI連携フェーズで活用できる状態にする。

■ 必須属性一覧

| 属性 | 用途 | 例 |
|------|------|-----|
| `data-figma-content-id` | 一意識別子（snake_case） | `"badge_text"` |
| `data-figma-content-type` | コンテンツ種別 | `"text"`, `"icon"`, `"ui_state"` |
| `data-figma-content-classification` | 分類 | `"static"`, `"dynamic"`, `"asset"` |
| `data-figma-content-data-type` | データ型 | `"string"`, `"number"`, `"svg"` |

■ オプション属性

| 属性 | 用途 | 例 |
|------|------|-----|
| `data-figma-content-value` | Figmaでの表示値 | `"テスト運用版"` |
| `data-figma-content-notes` | 補足説明 | `"最終ステップでは「はじめる」に変化"` |
| `data-figma-display-format` | 表示フォーマット | `"{value}分"` |

■ type の値一覧

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

■ classification の値一覧

| 値 | 説明 |
|-----|------|
| `static` | 固定ラベル・UI文言 |
| `dynamic` | ユーザー/時間で変わるデータ |
| `dynamic_list` | 件数可変のリスト |
| `config` | 画面設定で変わる要素 |
| `asset` | 静的アセット（アイコン等） |
| `user_asset` | ユーザーアップロード画像等 |

■ 埋め込み例

```html
<!-- テキスト（静的） -->
<span class="badge-text"
      data-figma-node="2350:6414"
      data-figma-content-id="badge_text"
      data-figma-content-type="text"
      data-figma-content-value="テスト運用版"
      data-figma-content-classification="static"
      data-figma-content-data-type="string"
      data-figma-font="JP/10 - Bold">テスト運用版</span>

<!-- アイコン（アセット） -->
<button class="nav-icon"
        data-figma-node="I2350:6398;48:622"
        data-figma-name="Common/Forward_Outlined"
        data-figma-content-id="nav_back_icon"
        data-figma-content-type="icon"
        data-figma-content-classification="asset"
        data-figma-content-data-type="svg"
        data-figma-icon-svg="assets/icon-back.svg">
  <img src="assets/icon-back.svg" alt="" width="24" height="24">
</button>

<!-- UI状態（設定） -->
<nav class="pagination"
     data-figma-node="2350:6402"
     data-figma-content-id="pagination"
     data-figma-content-type="ui_state"
     data-figma-content-classification="config"
     data-figma-content-data-type="number"
     data-figma-content-notes="現在のステップを示す（1-4）">

<!-- テキスト（条件付き変化） -->
<button class="button button-primary"
        data-figma-node="2350:6410"
        data-figma-content-id="next_button"
        data-figma-content-type="text"
        data-figma-content-value="次へ"
        data-figma-content-classification="static"
        data-figma-content-data-type="string"
        data-figma-content-notes="最終ステップでは「はじめる」に変化">
  次へ
</button>
```

■ 命名規則（content-id）

- snake_case を使用
- 2-3語で構成
- 例: `badge_text`, `nav_back_icon`, `step_description`, `pagination_dot_1`

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
【Step 6: 画面遷移属性の埋め込み】
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

spec.md の「インタラクション」「画面フロー」セクションを参照して、
HTMLに画面遷移属性を付与する。

■ 必須属性一覧

| 属性 | 用途 | 例 |
|------|------|-----|
| `data-figma-interaction` | インタラクション定義 | `"tap:navigate:tutorial"` |
| `data-figma-navigate` | 遷移先パス | `"/{locale}/ask_ai/tutorial"` |
| `data-figma-states` | サポートするUI状態 | `"default,hover,active,disabled"` |

■ インタラクション形式

```
形式: {trigger}:{action}:{target}

例:
tap:navigate:tutorial        タップでチュートリアルへ遷移
tap:navigate:back            タップで前の画面へ戻る
tap:conditional-navigate     条件付き遷移
tap:open-file-dialog|navigate:trim  複合アクション
```

■ 遷移先の記述形式

| パターン | 形式 | 例 |
|---------|------|-----|
| 単純遷移 | `/{locale}/path` | `/{locale}/ask_ai/tutorial` |
| 条件付き | `cond1:path1\|cond2:path2` | `consented:/{locale}/ask_ai\|unconsented:consent-modal` |
| 内部遷移 | `step-{n+1}`, `previous` | `tutorial-step-{n+1}`, `previous-screen` |

■ 遷移パターン例

```html
<!-- 単純な画面遷移 -->
<button data-figma-node="2350:2674"
        data-figma-interaction="tap:navigate:tutorial"
        data-figma-navigate="/{locale}/ask_ai/tutorial">
  ヘルプ
</button>

<!-- 条件付き遷移（同意状態等） -->
<button data-figma-node="2350:6409"
        data-figma-interaction="tap:conditional-navigate"
        data-figma-navigate="consented:/{locale}/ask_ai|unconsented:consent-modal"
        data-figma-states="default,hover,active">
  スキップ
</button>

<!-- 内部ステップ遷移 -->
<button data-figma-node="2350:6410"
        data-figma-interaction="tap:navigate:next-step"
        data-figma-navigate="step1-3:tutorial-step-{n+1}|step4-consented:/{locale}/ask_ai"
        data-figma-states="default,hover,active">
  次へ
</button>

<!-- 複合アクション -->
<button data-figma-node="2350:2671"
        data-figma-interaction="tap:open-file-dialog|navigate:trim"
        data-figma-navigate="/{locale}/ask_ai/trim"
        data-figma-states="default,hover,active,loading">
  写真を共有
</button>

<!-- ボトムナビゲーション -->
<a data-figma-node="2239:2779"
   data-figma-interaction="tap:navigate:history"
   data-figma-navigate="/{locale}/ask_ai/history"
   data-figma-states="active,inactive">
  マイリスト
</a>
```

■ spec.md から遷移情報を抽出

1. 「インタラクション」セクションを確認
   - 各要素のタップ/クリック時の動作
   - 遷移先画面
   - 条件分岐（同意状態等）

2. 「画面フロー」セクションを確認
   - 画面間の遷移関係
   - 遷移トリガー

3. 該当するHTML要素に属性を付与
   - ボタン、リンク、ナビゲーション要素
   - インタラクティブなカード等

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
【チェックリスト】
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

生成完了後、以下を確認：

□ Figmaスクリーンショットと見た目が一致
□ 全ての主要要素にdata-figma-node属性がある
□ コンテンツ要素にdata-figma-content-XXX属性がある
□ アイコンにdata-figma-icon-svg属性がある
□ ステータスバー等のOSネイティブUIが除外されている
□ mapping-overlay.js が読み込まれている
□ コンテンツ分析が完成している（※static/dynamicは仮決定）
□ コンテンツ分類属性が埋め込まれている（Step 5）
  - data-figma-content-id（snake_case）
  - data-figma-content-type
  - data-figma-content-classification
  - data-figma-content-data-type
□ 画面遷移属性が埋め込まれている（Step 6）
  - data-figma-interaction（トリガー:アクション:ターゲット）
  - data-figma-navigate（遷移先パス）
  - data-figma-states（対応UI状態）
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

### 単一画面の場合

```
.outputs/{screen-name}/
├── index.html                    # メインHTML（mapping-overlay.js読み込み含む）
├── index-{state}.html            # 状態バリエーション（Empty, Error等）
├── spec.md                       # 画面仕様書（コンテンツ分析含む）
├── mapping-overlay.js            # マッピング可視化
├── preview.html                  # プレビュー用（オプション）
└── tokens.md                     # トークンマッピング（オプション）
```

### 複数画面の場合

```
.outputs/
├── {screen-a}/
│   ├── index.html
│   ├── index-empty.html          # 同一画面の状態バリエーション
│   ├── index-error.html
│   ├── spec.md
│   └── mapping-overlay.js
├── {screen-b}/
│   ├── index.html
│   ├── spec.md
│   └── mapping-overlay.js
└── {screen-c}/
    └── ...
```

> **注意**:
> - `spec.md` 内の static/dynamic 分類は**仮決定**です。API仕様確定後にレビューしてください。
> - 複数画面の場合、**画面ごとに別ディレクトリ**を作成します。
> - 同一画面の状態バリエーションは**同じディレクトリ内**に `index-{state}.html` として出力します。

`{screen-name}` はFigmaの画面名から生成した短い識別名

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
