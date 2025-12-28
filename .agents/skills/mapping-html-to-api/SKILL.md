---
name: mapping-html-to-api
description: Maps HTML content elements to API response fields and generates data binding specifications. Updates the "APIマッピング" section in screen spec.md.
allowed-tools: [Read, Write, Glob, Grep]
---

# HTML to API Mapping Skill

HTML要素・UIコンポーネントとAPIエンドポイントの対応関係を整理するスキルです。

## 目次

1. [概要](#概要)
2. [適用条件](#適用条件)
3. [クイックスタート](#クイックスタート)
4. [詳細ガイド](#詳細ガイド)
5. [出力形式](#出力形式)

## 概要

このスキルは以下のタスクをサポートします：

1. **データソースの特定**: 各UI要素が表示するデータの出所
2. **APIエンドポイントの整理**: 必要なAPIとそのパラメータ
3. **リクエスト/レスポンス構造**: APIの入出力形式
4. **データバインディング**: UIフィールドとAPIフィールドの対応
5. **API呼び出しタイミング**: いつAPIを呼ぶか

## 禁止事項

**以下は絶対に行わないこと：**
- 実装コードの生成（fetch/axios等）
- 特定のHTTPライブラリの提案
- バックエンド実装の詳細

このスキルの目的は「どのUIがどのAPIとつながるか」の**情報整理のみ**です。

## 適用条件

このスキルは**動的データを表示/送信する画面**に適用します。

### 適用する画面の例

- データ一覧の表示（API取得）
- 詳細情報の表示（API取得）
- フォーム送信（API送信）
- 検索/フィルター（API取得）
- ユーザー情報の表示（API取得）

### 適用しない画面の例

- 完全に静的なページ
- ローカルデータのみの画面
- APIとの連携がない画面

**API連携がない場合**、spec.md のAPIマッピングセクションに「該当なし」と記載します。

## 出力先

このスキルは**画面仕様書（spec.md）の「APIマッピング」セクション**を更新します。

```
.agents/tmp/{screen-id}/
├── spec.md                 # ← このスキルが「APIマッピング」セクションを更新
├── index.html              # 参照用HTML
└── assets/
```

## クイックスタート

### 基本的な使い方

```
以下の画面のAPIマッピングを整理してください：
画面ID: course-list
OpenAPI: openapi/index.yaml
```

エージェントは自動的に：
1. 動的データ要素を検出
2. APIエンドポイントを特定
3. データバインディングを整理
4. **spec.md の「APIマッピング」セクションを更新**

## 詳細ガイド

詳細な情報は以下のファイルを参照してください：

- **[workflow.md](references/workflow.md)**: APIマッピングのワークフロー
- **[api-patterns.md](references/api-patterns.md)**: 一般的なAPIパターン
- **[section-template.md](references/section-template.md)**: セクション出力テンプレート

## Workflow

APIマッピング時にこのチェックリストをコピー：

```
API Mapping Progress:
- [ ] Step 0: spec.md の存在確認
- [ ] Step 1: 動的データ要素を検出
- [ ] Step 2: APIエンドポイントを特定
- [ ] Step 3: リクエスト構造を定義
- [ ] Step 4: レスポンス構造を定義
- [ ] Step 5: データバインディングを整理
- [ ] Step 6: API呼び出しタイミングを決定
- [ ] Step 7: エラーハンドリングを定義
- [ ] Step 8: spec.md の「APIマッピング」セクションを更新
```

### Step 0: spec.md の存在確認

```bash
ls .agents/tmp/{screen-id}/spec.md
```

### Step 1: 動的データ要素を検出

HTMLおよび他セクションから以下を特定：

- リストで繰り返し表示される要素（`dynamic_list`）
- ユーザー固有のデータ（`dynamic`）
- 数値データ（件数、金額等）
- 日時データ
- ステータス/状態表示

### Step 2: APIエンドポイントを特定

各データソースに対するAPI：

| データ | エンドポイント | メソッド |
|--------|--------------|---------|
| 講座一覧 | /api/courses | GET |
| 講座詳細 | /api/courses/:id | GET |
| ユーザー情報 | /api/users/me | GET |

### Step 3: リクエスト構造を定義

- パスパラメータ
- クエリパラメータ
- リクエストボディ
- ヘッダー

### Step 4: レスポンス構造を定義

- レスポンスボディの型
- ページネーション情報
- メタデータ

### Step 5: データバインディングを整理

UIフィールドとAPIフィールドの対応：

| UI要素 | APIフィールド | 変換 |
|--------|-------------|------|
| 講座タイトル | course.title | そのまま |
| 作成日 | course.created_at | formatDate |

### Step 6: API呼び出しタイミングを決定

| タイミング | API | トリガー |
|----------|-----|---------|
| 画面表示時 | GET /api/courses | useEffect / onMounted |
| 検索実行時 | GET /api/courses?q=xxx | 検索ボタンクリック |
| フォーム送信時 | POST /api/courses | 送信ボタンクリック |

### Step 7: エラーハンドリングを定義

| エラー | HTTPステータス | UI対応 |
|--------|--------------|--------|
| 認証エラー | 401 | ログイン画面へ遷移 |
| 権限エラー | 403 | エラーメッセージ表示 |
| 未検出 | 404 | 空状態表示 |
| サーバーエラー | 500 | リトライ促進 |

### Step 8: spec.md の「APIマッピング」セクションを更新

1. セクションを特定（`## APIマッピング`）
2. ステータスを「完了 ✓」に更新
3. `{{API_MAPPING_CONTENT}}` を内容に置換
4. 完了チェックリストを更新
5. 変更履歴に追記

## 出力形式

### spec.md「APIマッピング」セクションの内容

```markdown
## APIマッピング

> **ステータス**: 完了 ✓  
> **生成スキル**: mapping-html-to-api  
> **更新日**: 2024-01-15

### 使用API一覧

| エンドポイント | メソッド | 用途 | 呼び出しタイミング |
|---------------|---------|------|------------------|
| /api/courses | GET | 講座一覧取得 | 画面表示時 |
| /api/courses/:id | GET | 講座詳細取得 | カードクリック時 |
| /api/courses | POST | 講座作成 | フォーム送信時 |

### データバインディング

#### GET /api/courses

**リクエスト**

| パラメータ | 型 | 必須 | 説明 |
|-----------|-----|:----:|------|
| page | number | - | ページ番号 |
| limit | number | - | 取得件数 |
| q | string | - | 検索キーワード |
| category | string | - | カテゴリフィルター |

**レスポンス**

\`\`\`typescript
interface CoursesResponse {
  courses: Course[];
  total: number;
  page: number;
  limit: number;
}

interface Course {
  id: string;
  title: string;
  description: string;
  category: string;
  duration: number;
  created_at: string;
}
\`\`\`

**UIマッピング**

| UI要素 | data-figma-content | APIフィールド | 変換 |
|--------|-------------------|--------------|------|
| 講座タイトル | course-title | course.title | そのまま |
| 講座説明 | course-description | course.description | 100文字で切り詰め |
| カテゴリ | course-category | course.category | カテゴリ名に変換 |
| 所要時間 | course-duration | course.duration | \`${value}分\` |
| 作成日 | course-created-at | course.created_at | formatDate |

#### POST /api/courses

**リクエスト**

\`\`\`typescript
interface CreateCourseRequest {
  title: string;
  description: string;
  category: string;
  duration: number;
}
\`\`\`

**フォームマッピング**

| フォームフィールド | APIフィールド | バリデーション |
|------------------|--------------|---------------|
| タイトル入力 | title | 必須、100文字以内 |
| 説明入力 | description | 任意、1000文字以内 |
| カテゴリ選択 | category | 必須 |
| 所要時間入力 | duration | 必須、1-480 |

### API呼び出しタイミング

| タイミング | API | トリガー | 備考 |
|----------|-----|---------|------|
| 画面表示時 | GET /api/courses | マウント時 | 初回データ取得 |
| 検索実行時 | GET /api/courses?q=xxx | 検索フォーム送信 | デバウンス300ms |
| ページ遷移時 | GET /api/courses?page=N | ページネーションクリック | - |
| 作成実行時 | POST /api/courses | フォーム送信 | バリデーション後 |

### エラーハンドリング

| HTTPステータス | エラー種別 | UI対応 |
|--------------|----------|--------|
| 401 | 認証エラー | ログイン画面へリダイレクト |
| 403 | 権限エラー | 権限エラーメッセージ表示 |
| 404 | データ未検出 | Empty状態表示 |
| 422 | バリデーションエラー | フォームエラー表示 |
| 500 | サーバーエラー | リトライボタン表示 |

### 特記事項

- 講座一覧は無限スクロールまたはページネーションで対応
- 検索は300msのデバウンスを適用
- カテゴリは事前にマスタデータを取得してキャッシュ
```

## API連携がない場合

API連携がない画面の場合、以下のように記載：

```markdown
## APIマッピング

> **ステータス**: 該当なし  
> **生成スキル**: mapping-html-to-api  
> **更新日**: 2024-01-15

この画面にはAPI連携がありません。
```

## 完了チェックリスト

生成後、以下を確認：

```
- [ ] spec.md の「APIマッピング」セクションが更新されている
- [ ] ステータスが「完了 ✓」になっている
- [ ] 使用API一覧が網羅されている
- [ ] リクエスト/レスポンス構造が定義されている
- [ ] UIマッピングが整理されている
- [ ] API呼び出しタイミングが明確
- [ ] エラーハンドリングが定義されている
- [ ] 完了チェックリストが更新されている
- [ ] 変更履歴に記録が追加されている
```

## 注意事項

### 他のセクションを変更しない

このスキルは「APIマッピング」セクションのみを更新します。

### OpenAPI仕様書との連携

OpenAPI仕様書がある場合：

1. `Read: openapi/index.yaml`
2. スキーマ定義からレスポンス構造を抽出
3. 自動マッピングを実施

### defining-form-specs との連携

フォーム仕様がある場合、フォームフィールドとAPIリクエストの対応を整理。

## 参照

- **[workflow.md](references/workflow.md)**: 詳細なワークフロー
- **[api-patterns.md](references/api-patterns.md)**: APIパターン集
- **[section-template.md](references/section-template.md)**: セクション出力テンプレート
- **[managing-screen-specs](../managing-screen-specs/SKILL.md)**: 仕様書管理スキル
