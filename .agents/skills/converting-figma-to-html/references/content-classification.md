# コンテンツ分析（後続フェーズ連携用）

## 目的

Figmaから出力したHTMLのコンテンツを分類し、UIデザインから見た**データの種別を識別**する。

## 禁止事項

**以下は絶対に行わないこと：**
- API仕様の提案（エンドポイント、リクエスト/レスポンス形式）
- データモデル設計の提案（エンティティ、スキーマ、型定義）
- バックエンド実装に関する提案

コンテンツ分析の目的は「このUIに動的データが必要」という**事実の識別のみ**です。
「どのようなAPIで取得すべきか」「どのようなデータ構造にすべきか」は提案しません。

## 出力ファイル

```
.agents/tmp/{short-screen-name}/
├── index.html
├── preview.html
├── tokens.md
└── spec.md   ← コンテンツ分析セクション含む
```

## 分類体系

| 分類 | 説明 |
|------|------|
| `static` | 固定ラベル・UI文言 |
| `dynamic` | ユーザー/時間で変わるデータ |
| `dynamic_list` | 件数可変のリスト |
| `config` | 画面設定で変わる要素 |
| `asset` | 静的アセット（アイコン等） |
| `user_asset` | ユーザーアップロード画像等 |

## 判定基準

```yaml
# 静的（static）と判断する条件
static_indicators:
  - ラベル系テキスト（「〜の」「〜一覧」等の接尾辞）
  - ナビゲーション項目名
  - ボタンラベル
  - セクションタイトル
  - 単位（「分」「時間」「%」等）
  - アイコンの説明テキスト

# 動的（dynamic）と判断する条件
dynamic_indicators:
  - 数値（パーセンテージ、カウント、時間、金額）
  - 日付・期間
  - ユーザー名・ID
  - プレースホルダー的テキスト（「〜が入ります」「サンプル」等）
  - ステータス・状態値
  - バッジのカウント

# 動的リスト（dynamic_list）と判断する条件
dynamic_list_indicators:
  - 同一構造の繰り返し要素
  - 「一覧」「リスト」を含むセクション
  - 件数が0件の可能性があるもの

# 要確認（人間判断が必要）
needs_review:
  - 固定に見えるが実は設定可能な値
  - A/Bテスト対象の文言
  - ロール/権限で出し分けるUI要素
```

## コンテンツ記述フォーマット

```yaml
- id: content_unique_id           # 一意の識別子（snake_case）
  type: text|number|percentage|duration|date|date_range|list|icon|ui_state
  value: "Figmaでの表示値"         # サンプル値
  classification: static|dynamic|dynamic_list|config|asset|user_asset
  data_type: "number|string|date|..."  # 実データ型
  display_format: "{value}分"     # 表示フォーマット
  html_selector: "[data-figma-node='xxx'] .class"  # HTML要素特定
  notes: "補足説明"
```

## HTMLとの紐付け

`data-figma-node`属性を使用してコンテンツとHTMLを紐付ける：

```
Content ID          ←→  data-figma-node
achievement_rate        4296:28365
course_items            4296:28471
```

## 出力に含める内容

コンテンツ分析の最後に以下を含める：

1. **データ要件サマリー** - 動的データの一覧（型、表示例、表示フォーマット）
2. **HTMLマッピングサマリー** - Content ID / Classification / HTML Selector の一覧表
3. **分類集計** - static / dynamic / asset 等の件数

## HTML属性への埋め込み

コンテンツ分析結果をHTMLのdata属性として埋め込む。これにより後続のAPI連携フェーズで活用できる。

### 必須属性

| 属性 | 用途 | 値の例 |
|------|------|--------|
| `data-figma-content-id` | 一意識別子（snake_case） | `"badge_text"` |
| `data-figma-content-type` | コンテンツ種別 | `"text"`, `"icon"`, `"ui_state"` |
| `data-figma-content-classification` | 分類 | `"static"`, `"dynamic"`, `"asset"` |
| `data-figma-content-data-type` | データ型 | `"string"`, `"number"`, `"svg"` |

### オプション属性

| 属性 | 用途 | 値の例 |
|------|------|--------|
| `data-figma-content-value` | Figmaでの表示値 | `"テスト運用版"` |
| `data-figma-content-notes` | 補足説明 | `"最終ステップでは「はじめる」に変化"` |
| `data-figma-display-format` | 表示フォーマット | `"{value}分"` |

### 埋め込み例

```html
<!-- テキスト（静的） -->
<span data-figma-node="2350:6414"
      data-figma-content-id="badge_text"
      data-figma-content-type="text"
      data-figma-content-value="テスト運用版"
      data-figma-content-classification="static"
      data-figma-content-data-type="string"
      data-figma-font="JP/10 - Bold">テスト運用版</span>

<!-- アイコン（アセット） -->
<button data-figma-node="I2350:6398;48:622"
        data-figma-name="Common/Forward_Outlined"
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
     data-figma-content-notes="現在のステップを示す（1-4）">

<!-- テキスト（条件付き変化） -->
<button data-figma-node="2350:6410"
        data-figma-content-id="next_button"
        data-figma-content-type="text"
        data-figma-content-value="次へ"
        data-figma-content-classification="static"
        data-figma-content-data-type="string"
        data-figma-content-notes="最終ステップでは「はじめる」に変化">
  次へ
</button>
```

### content-id 命名規則

- **形式**: snake_case（アンダースコア区切り）
- **構成**: 2-3語
- **例**:
  - `badge_text` - バッジのテキスト
  - `nav_back_icon` - ナビの戻るアイコン
  - `step_description` - ステップの説明文
  - `pagination_dot_1` - ページネーションドット1
  - `next_button` - 次へボタン
  - `history_item` - 履歴リスト項目
  - `period_dropdown` - 期間選択ドロップダウン

---

## 動的リストの埋め込み例

リスト形式のデータは、リストコンテナと各項目にdata属性を付与する。

### リストコンテナ

```html
<div data-figma-node="4296:28471"
     data-figma-content-id="history_list"
     data-figma-content-type="list"
     data-figma-content-classification="dynamic_list"
     data-figma-content-data-type="array"
     data-figma-content-notes="履歴一覧、0件時はエンプティ表示">
  <!-- 各項目 -->
</div>
```

### リスト項目

```html
<article data-figma-node="4296:28480"
         data-figma-content-id="history_item"
         data-figma-content-type="list_item"
         data-figma-content-classification="dynamic_list"
         data-figma-content-data-type="object"
         data-figma-interaction="tap:navigate:/chat/:id"
         data-figma-states="default,hover,active">

  <h3 data-figma-content-id="history_title"
      data-figma-content-type="text"
      data-figma-content-classification="dynamic"
      data-figma-content-data-type="string">キャリア形成に関するご質問</h3>

  <p data-figma-content-id="history_preview"
     data-figma-content-type="text"
     data-figma-content-classification="dynamic"
     data-figma-content-data-type="string">AIからの回答の冒頭部分が表示...</p>

  <time data-figma-content-id="history_date"
        data-figma-content-type="date"
        data-figma-content-classification="dynamic"
        data-figma-content-data-type="date">2024/01/15</time>
</article>
```

---

## ドロップダウン（設定要素）

ユーザー選択で変わる要素は `config` として分類する。

```html
<!-- ドロップダウントリガー -->
<button data-figma-node="4296:28417"
        data-figma-content-id="period_selector"
        data-figma-content-type="ui_state"
        data-figma-content-classification="config"
        data-figma-content-data-type="string"
        data-figma-content-value="過去7日間"
        data-figma-states="default,hover,active,expanded"
        data-figma-interaction="tap:open-dropdown:period-dropdown">
  <span>過去7日間</span>
  <span data-figma-icon-svg="3428:18650" class="w-4 h-4">
    <svg><!-- chevron --></svg>
  </span>
</button>

<!-- ドロップダウンオプション -->
<div id="period-dropdown" class="hidden">
  <button data-figma-content-id="period_option_7d"
          data-figma-content-type="text"
          data-figma-content-classification="static"
          data-figma-interaction="tap:select:7days">過去7日間</button>
  <button data-figma-content-id="period_option_30d"
          data-figma-content-type="text"
          data-figma-content-classification="static"
          data-figma-interaction="tap:select:30days">過去30日間</button>
  <button data-figma-content-id="period_option_all"
          data-figma-content-type="text"
          data-figma-content-classification="static"
          data-figma-interaction="tap:select:all">すべて</button>
</div>
```

---

## ナビゲーション（アセット + 静的）

ナビゲーションアイコンは `asset`、ラベルは `static` として分類する。

```html
<nav data-figma-node="4296:28350"
     data-figma-content-id="bottom_navigation"
     data-figma-content-type="ui_state"
     data-figma-content-classification="config"
     data-figma-content-notes="選択中タブで表示が変化">

  <button data-figma-states="default,selected"
          data-figma-interaction="tap:navigate:/chat"
          data-state="default">
    <span data-figma-content-id="nav_chat_icon"
          data-figma-content-type="icon"
          data-figma-content-classification="asset"
          data-figma-content-data-type="svg"
          data-figma-icon-svg="3428:18620">
      <svg><!-- chat icon --></svg>
    </span>
    <span data-figma-content-id="nav_chat_label"
          data-figma-content-type="text"
          data-figma-content-classification="static"
          data-figma-content-data-type="string">チャット</span>
  </button>

  <button data-figma-states="default,selected"
          data-figma-interaction="tap:navigate:/history"
          data-state="selected">
    <span data-figma-content-id="nav_history_icon"
          data-figma-content-type="icon"
          data-figma-content-classification="asset"
          data-figma-content-data-type="svg"
          data-figma-icon-svg="3428:18625">
      <svg><!-- history icon --></svg>
    </span>
    <span data-figma-content-id="nav_history_label"
          data-figma-content-type="text"
          data-figma-content-classification="static"
          data-figma-content-data-type="string">履歴</span>
  </button>
</nav>
```
