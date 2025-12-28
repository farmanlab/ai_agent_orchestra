# APIパターン集

一般的なAPIパターンとUIマッピングの例を定義します。

## 目次

1. [一覧取得パターン](#一覧取得パターン)
2. [詳細取得パターン](#詳細取得パターン)
3. [作成パターン](#作成パターン)
4. [更新パターン](#更新パターン)
5. [削除パターン](#削除パターン)
6. [検索・フィルターパターン](#検索フィルターパターン)
7. [ページネーションパターン](#ページネーションパターン)
8. [エラーハンドリング](#エラーハンドリング)
9. [データ変換パターン](#データ変換パターン)

---

## 一覧取得パターン

### 基本形

```
GET /api/{resources}
```

### リクエスト

| パラメータ | 型 | 説明 |
|-----------|-----|------|
| page | number | ページ番号 |
| limit | number | 取得件数 |
| sort | string | ソート項目 |
| order | string | asc / desc |

### レスポンス

```typescript
interface ListResponse<T> {
  data: T[];
  total: number;
  page: number;
  limit: number;
  hasMore: boolean;
}
```

### UIマッピング例

| UI要素 | APIフィールド | 変換 |
|--------|-------------|------|
| リストコンテナ | data[] | ループレンダリング |
| 件数表示 | total | `${total}件` |
| ページ表示 | page, limit | `${page}/${Math.ceil(total/limit)}` |

---

## 詳細取得パターン

### 基本形

```
GET /api/{resources}/:id
```

### リクエスト

| パラメータ | 位置 | 型 | 説明 |
|-----------|------|-----|------|
| id | path | string | リソースID |

### レスポンス

```typescript
interface DetailResponse<T> {
  data: T;
}
```

---

## 作成パターン

### 基本形

```
POST /api/{resources}
```

### フォームマッピング例

| フォームフィールド | APIフィールド | バリデーション |
|------------------|--------------|---------------|
| タイトル入力 | title | 必須、100文字以内 |
| 説明入力 | description | 任意、1000文字以内 |

### 成功時のUI対応

- 成功メッセージ表示
- 一覧画面へリダイレクト

---

## 更新パターン

### PUT vs PATCH

| メソッド | 用途 |
|---------|------|
| PUT | 全フィールド更新（置換） |
| PATCH | 一部フィールド更新（部分更新） |

---

## 削除パターン

### 基本形

```
DELETE /api/{resources}/:id
```

### UI対応

| 操作 | 確認 | 成功後 |
|------|------|--------|
| 削除ボタン | 確認ダイアログ | 一覧から削除 |

---

## 検索・フィルターパターン

### 複合検索

```
GET /api/{resources}?q=keyword&status=active&sort=created_at
```

### UIマッピング例

| UI要素 | パラメータ | 備考 |
|--------|-----------|------|
| 検索入力 | q | デバウンス300ms |
| ステータスセレクト | status | 即時反映 |
| ソートセレクト | sort, order | 即時反映 |

---

## ページネーションパターン

### オフセットベース

```
GET /api/resources?page=2&limit=20
```

### カーソルベース

```
GET /api/resources?cursor=xxx&limit=20
```

---

## エラーハンドリング

### HTTPステータスコード

| コード | 意味 | UI対応 |
|--------|------|--------|
| 400 | Bad Request | 入力エラー表示 |
| 401 | Unauthorized | ログイン画面へ |
| 403 | Forbidden | 権限エラー表示 |
| 404 | Not Found | Empty状態 |
| 422 | Validation Error | フォームエラー表示 |
| 500 | Server Error | リトライボタン |

### エラーレスポンス形式

```typescript
interface ErrorResponse {
  error: {
    code: string;
    message: string;
    details?: Record<string, string[]>;
  };
}
```

---

## データ変換パターン

### 日付変換

| 元データ | 変換後 | 関数 |
|---------|--------|------|
| 2024-01-15T10:30:00Z | 2024/01/15 | formatDate |
| 2024-01-15T10:30:00Z | 1時間前 | formatRelative |

### 数値変換

| 元データ | 変換後 | 関数 |
|---------|--------|------|
| 1234567 | 1,234,567 | toLocaleString |
| 0.856 | 85.6% | toPercent |
| 90 | 1時間30分 | formatDuration |

### ステータス変換

| APIコード | 表示ラベル | 色 |
|----------|-----------|-----|
| draft | 下書き | gray |
| pending | 審査中 | yellow |
| active | 公開中 | green |
| archived | アーカイブ | red |
