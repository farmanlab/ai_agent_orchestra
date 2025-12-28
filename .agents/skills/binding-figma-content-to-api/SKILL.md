---
name: binding-figma-content-to-api
description: Binds Figma-generated HTML content to API fields and generates visualization overlays. Use when creating standalone data binding specs from content_analysis.md.
allowed-tools: [Read, Glob, Grep, Write]
---

# Figma Content to API Binding

Figma生成HTMLのコンテンツ要素をAPIレスポンスフィールドにバインディングし、データバインディング設計書とビジュアル確認用オーバーレイを生成するスキル。

## 入力/出力

| 入力 | 出力 |
|------|------|
| content_analysis.md | `{screen}_api_mapping.md` |
| OpenAPI仕様書 | `mapping-overlay.js` |
| HTMLファイル（任意） | |

## Workflow

```
API Binding Progress:
- [ ] Step 1: 入力ファイル収集
- [ ] Step 2: 全コンテンツ要素抽出
- [ ] Step 3: OpenAPIスキーマ解析
- [ ] Step 4: 自動マッピング + 静的→動的の再分類
- [ ] Step 5: データ変換要否の分析
- [ ] Step 6: マッピングレポート生成
- [ ] Step 7: 未マッチ要素の確認
- [ ] Step 8: 未使用APIフィールドの分析
- [ ] Step 9: マッピングオーバーレイ生成（任意）
```

---

## Step 1-3: データ収集

```bash
Read: content_analysis.md   # 動的/静的コンテンツ一覧
Read: openapi/index.yaml    # APIスキーマ
```

**抽出項目:**
- Content ID, data-figma-content属性, 分類, データ型
- APIフィールド名, 型, 必須/任意, ネスト構造

---

## Step 4: 自動マッピング

**マッピングルール:**

| 優先度 | ルール | 例 |
|--------|--------|-----|
| 1 | 完全一致（snake↔kebab） | `user_id` ↔ `user-id` |
| 2 | 部分一致（接尾辞除去） | `name_value` → `name` |
| 3 | 意味的一致 | `title` ↔ `name` |

**再分類条件（static → dynamic）:**
- APIフィールドにマッチ
- 値の変動可能性あり
- 配列要素の一部

If no matches found, mark as unmatched and continue to Step 5.

---

## Step 5: データ変換分析

| パターン | 検出方法 | 変換例 |
|---------|---------|--------|
| 日付 | ISO8601 → 表示形式 | `formatDate(value, 'yyyy/MM/dd')` |
| 結合 | 複数フィールド | `${last} ${first}` |
| 列挙 | コード → ラベル | `STATUS_MAP[value]` |
| 条件 | 値による分岐 | `score >= 80 ? '合格' : '不合格'` |

---

## Step 6-8: レポート生成

出力ファイル: `{screen}_api_mapping.md`

```markdown
# データバインディング設計書

## マッピング一覧
| Content ID | data-figma-content | API Field | 変換 |

## 未使用APIフィールド
| Field | 型 | 未使用理由 |
```

If unmatched elements exist, return to Step 4 for manual review.

---

## Step 9: オーバーレイ生成

**テンプレート:** [templates/mapping-overlay.js](templates/mapping-overlay.js)

### タイプ別色分け

| タイプ | 色 | ラベル |
|--------|-----|--------|
| static | グレー | 静的 |
| dynamic | 緑 | 動的(API) |
| dynamic_list | 青 | 動的リスト(API) |
| local | 紫 | 動的(ローカル) |
| asset | 黄 | アセット |

### マッピングデータ形式

```javascript
'data-figma-content-{attr}': {
  type: 'static|dynamic|dynamic_list|local|asset',
  endpoint: 'GET /api/endpoint/{id}' | null,
  apiField: 'response.field.path' | null,
  transform: '変換ロジック' | null,
  label: '日本語ラベル'
}
```

### HTMLへの組み込み

```html
<script src="mapping-overlay.js"></script>
</body>
```

---

## 出力形式テンプレート

```markdown
# データバインディング設計書: {画面名}

## 概要
| 項目 | 値 |
|------|-----|
| 対象画面 | {画面名} |
| APIエンドポイント | `{method} {path}` |

## マッピング一覧

### 確定マッピング
| Content ID | data-figma-content | API Field | 型 | 変換 |

### リスト要素
**リストID**: `{list_id}`
**APIフィールド**: `{api_array}`

### 確定した静的要素
| Content ID | 表示値 | 備考 |

## データ変換ロジック
| Content ID | API Field | 変換種別 | ロジック |

## 未使用APIフィールド
| Field | 型 | 未使用理由 |

## 実装メモ
- [ ] 確認事項
```

---

## 関連スキル

- **[converting-figma-to-html](../converting-figma-to-html/SKILL.md)**: HTML生成スキル
- **[mapping-html-to-api](../mapping-html-to-api/SKILL.md)**: spec.md セクション更新スキル
