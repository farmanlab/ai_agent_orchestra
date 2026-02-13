# APIマッピング ワークフロー

HTML要素とAPIエンドポイントのマッピングを行う詳細な手順です。

## 概要

```
1. spec.md の存在確認
2. 動的データ要素を検出
3. OpenAPIスキーマを解析
4. APIエンドポイントを特定
5. リクエスト/レスポンス構造を定義
6. データバインディングを整理
7. API呼び出しタイミングを決定
8. エラーハンドリングを定義
9. spec.md の「APIマッピング」セクションを更新
10. HTMLにdata-api-*属性を追加
11. マッピングオーバーレイ生成（任意）
```

---

## Step 0: spec.md の存在確認

```bash
ls .agents/tmp/{screen-id}/spec.md
```

---

## Step 1: 動的データ要素を検出

### 情報源

1. **spec.md「UI状態」セクション**: 動的データの一覧
2. **spec.md「コンテンツ分析」セクション**: dynamic分類されたコンテンツ
3. **生成済みHTML**: `data-figma-content-*` 属性

### 検出対象

| 分類 | 説明 | 例 |
|------|------|-----|
| dynamic | 単一の動的値 | ユーザー名、進捗率 |
| dynamic_list | リストデータ | 講座一覧、通知一覧 |

---

## Step 2: OpenAPIスキーマを解析

```bash
Read: openapi/index.yaml
```

### OpenAPIがない場合

1. 画面のUIから必要なデータを推測
2. 一般的なRESTful命名規則を適用
3. 「要確認」として明示

---

## Step 3-5: APIエンドポイントとリクエスト/レスポンス

### データソース別のAPI

| データ種別 | エンドポイント | メソッド |
|-----------|--------------|---------|
| 一覧表示 | /api/resources | GET |
| 詳細表示 | /api/resources/:id | GET |
| 作成 | /api/resources | POST |
| 更新 | /api/resources/:id | PUT/PATCH |
| 削除 | /api/resources/:id | DELETE |

---

## Step 6: データバインディングを整理

### マッピング表の作成

| UI要素 | data-figma-content | APIフィールド | 変換 |
|--------|-------------------|--------------|------|
| 講座タイトル | course-title | data[].title | そのまま |
| 進捗率 | course-progress | data[].progress | `${value}%` |

---

## Step 7: API呼び出しタイミング

| タイミング | トリガー | 備考 |
|-----------|---------|------|
| 画面表示時 | onMount | 初期データ取得 |
| 検索実行 | onSearch | デバウンス推奨 |
| フォーム送信 | onSubmit | バリデーション後 |

---

## Step 8: エラーハンドリング

| HTTPステータス | 意味 | UI動作 |
|---------------|------|--------|
| 401 | 認証エラー | ログイン画面へ |
| 404 | データなし | Empty状態表示 |
| 500 | サーバーエラー | エラー + リトライ |

---

## Step 9: spec.md の更新

1. セクションを特定（`## APIマッピング`）
2. ステータスを「完了 ✓」に更新
3. 内容を挿入
4. 完了チェックリストを更新
5. 変更履歴に追記

---

## Step 10: HTMLにdata-api-*属性を追加

動的要素に以下の属性を追加：

```html
<div data-figma-content-id="user-name"
     data-figma-content-classification="dynamic"
     data-api-endpoint="GET /api/users/me"
     data-api-response-field="name"
     data-api-contract="get_user.md">
  ユーザー名
</div>
```

| 属性 | 用途 | 必須 |
|------|------|:----:|
| `data-api-endpoint` | APIエンドポイント | ✓ |
| `data-api-response-field` | レスポンスフィールドパス | △ |
| `data-api-request-body` | リクエストボディ | △ |
| `data-api-contract` | 契約ファイル名 | ✓ |

---

## Step 11: マッピングオーバーレイ生成（任意）

ユーザーが可視化を要求した場合のみ実行。

### 11.1 テンプレートをコピー

```bash
cp ../../templates/mapping-overlay.js .agents/tmp/{screen-id}/
```

### 11.2 CONTRACT_DATA にAPIサンプルJSONを追加

```javascript
const CONTRACT_DATA = {
  'get_user.md': {
    endpoint: 'GET /api/users/me',
    json: {
      "id": "user-123",
      "name": "山田太郎",
      "email": "yamada@example.com"
    }
  }
};
```

### 11.3 HTMLにスクリプトを追加

```html
<script src="mapping-overlay.js"></script>
```

### オーバーレイ機能

| 機能 | 説明 |
|------|------|
| データタイプ可視化 | 静的/動的/リスト等の色分け |
| API可視化 | GET/POST/LOCAL の色分け |
| JSONプレビュー | ホバー時にJSONとフィールドハイライト |
| ドラッグ移動 | パネル位置を自由に移動 |
| ホールドボタン | ピン留めでコンテンツ維持 |
| フィルタリング | 凡例クリックでタイプ別フィルター |
| Mappingトグル | 全機能のオン/オフ切り替え |
