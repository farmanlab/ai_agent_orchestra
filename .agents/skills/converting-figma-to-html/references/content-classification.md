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
