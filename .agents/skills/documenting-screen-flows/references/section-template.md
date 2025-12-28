# 画面フローセクション テンプレート

spec.md の「画面フロー」セクションに挿入する内容のテンプレートです。

---

## セクション全体（遷移あり）

```markdown
## 画面フロー

> **ステータス**: 完了 ✓  
> **生成スキル**: documenting-screen-flows  
> **更新日**: {{DATE}}

### この画面の位置づけ

| 項目 | 値 |
|------|-----|
| 画面ID | {{SCREEN_ID}} |
| 画面名 | {{SCREEN_NAME}} |
| 前の画面 | {{PREVIOUS_SCREENS}} |
| 次の画面 | {{NEXT_SCREENS}} |

### 遷移一覧

#### この画面への遷移（流入）

| 元画面 | トリガー | パラメータ |
|--------|----------|-----------|
| {{INFLOW_SOURCE}} | {{INFLOW_TRIGGER}} | {{INFLOW_PARAMS}} |

#### この画面からの遷移（流出）

| 遷移先 | トリガー | パラメータ | 種別 |
|--------|----------|-----------|------|
| {{OUTFLOW_DEST}} | {{OUTFLOW_TRIGGER}} | {{OUTFLOW_PARAMS}} | {{OUTFLOW_TYPE}} |

### 遷移パラメータ

#### {{PARAM_NAME}}

| 項目 | 値 |
|------|-----|
| 型 | {{PARAM_TYPE}} |
| 必須 | {{PARAM_REQUIRED}} |
| 説明 | {{PARAM_DESC}} |
| 例 | {{PARAM_EXAMPLE}} |
| 取得元 | {{PARAM_SOURCE}} |

### 条件分岐

| 条件 | True時の遷移 | False時の遷移 |
|------|-------------|---------------|
| {{BRANCH_CONDITION}} | {{BRANCH_TRUE}} | {{BRANCH_FALSE}} |

### フロー図

\`\`\`mermaid
{{MERMAID_DIAGRAM}}
\`\`\`

### 画面スタック

\`\`\`
{{NAVIGATION_STACK}}
\`\`\`

### 特記事項

- {{FLOW_NOTE_1}}
- {{FLOW_NOTE_2}}
```

---

## セクション全体（遷移なし）

```markdown
## 画面フロー

> **ステータス**: 該当なし  
> **生成スキル**: documenting-screen-flows  
> **更新日**: {{DATE}}

この画面には他画面への遷移がありません。
```

---

## 変数一覧

### 基本情報

| 変数 | 説明 |
|------|------|
| `{{DATE}}` | 更新日 |
| `{{SCREEN_ID}}` | 画面ID |
| `{{SCREEN_NAME}}` | 画面名 |
| `{{PREVIOUS_SCREENS}}` | 前の画面（カンマ区切り） |
| `{{NEXT_SCREENS}}` | 次の画面（カンマ区切り） |

### 流入

| 変数 | 説明 |
|------|------|
| `{{INFLOW_SOURCE}}` | 元画面 |
| `{{INFLOW_TRIGGER}}` | 遷移トリガー |
| `{{INFLOW_PARAMS}}` | パラメータ |

### 流出

| 変数 | 説明 |
|------|------|
| `{{OUTFLOW_DEST}}` | 遷移先 |
| `{{OUTFLOW_TRIGGER}}` | 遷移トリガー |
| `{{OUTFLOW_PARAMS}}` | パラメータ |
| `{{OUTFLOW_TYPE}}` | 遷移種別（push/pop/modal等） |

### パラメータ

| 変数 | 説明 |
|------|------|
| `{{PARAM_NAME}}` | パラメータ名 |
| `{{PARAM_TYPE}}` | データ型 |
| `{{PARAM_REQUIRED}}` | 必須（✓ or -） |
| `{{PARAM_DESC}}` | 説明 |
| `{{PARAM_EXAMPLE}}` | 例 |
| `{{PARAM_SOURCE}}` | 取得元 |

### 条件分岐

| 変数 | 説明 |
|------|------|
| `{{BRANCH_CONDITION}}` | 条件 |
| `{{BRANCH_TRUE}}` | True時の遷移 |
| `{{BRANCH_FALSE}}` | False時の遷移 |

### フロー図

| 変数 | 説明 |
|------|------|
| `{{MERMAID_DIAGRAM}}` | Mermaidフロー図コード |
| `{{NAVIGATION_STACK}}` | ナビゲーションスタック表現 |

---

## spec.md 更新時の追加変更

### 1. 完了チェックリスト

```markdown
- [x] 画面フロー (documenting-screen-flows)
```

### 2. 変更履歴

```markdown
| {{DATE}} | 画面フロー | documenting-screen-flowsにより生成 |
```

---

## 出力例

```markdown
## 画面フロー

> **ステータス**: 完了 ✓  
> **生成スキル**: documenting-screen-flows  
> **更新日**: 2024-01-15

### この画面の位置づけ

| 項目 | 値 |
|------|-----|
| 画面ID | course-list |
| 画面名 | 講座一覧 |
| 前の画面 | ホーム, 検索結果, カテゴリ一覧 |
| 次の画面 | 講座詳細, フィルターモーダル, 検索結果 |

### 遷移一覧

#### この画面への遷移（流入）

| 元画面 | トリガー | パラメータ |
|--------|----------|-----------|
| ホーム | 「講座一覧」リンク | - |
| 検索結果 | 検索実行 | query: 検索キーワード |
| カテゴリ一覧 | カテゴリ選択 | categoryId: カテゴリID |
| 講座詳細 | 戻るボタン | - |

#### この画面からの遷移（流出）

| 遷移先 | トリガー | パラメータ | 種別 |
|--------|----------|-----------|------|
| 講座詳細 | カードクリック | courseId: 講座ID | push |
| フィルターモーダル | フィルターボタン | - | modal |
| 検索結果 | 検索実行 | query: 検索キーワード | push |
| ホーム | ロゴクリック | - | replace |

### 遷移パラメータ

#### courseId

| 項目 | 値 |
|------|-----|
| 型 | string |
| 必須 | ✓ |
| 説明 | 講座の一意識別子 |
| 例 | "course-123" |
| 取得元 | 講座カードのdata-id属性 |

#### query

| 項目 | 値 |
|------|-----|
| 型 | string |
| 必須 | - |
| 説明 | 検索キーワード |
| 例 | "プログラミング" |
| 取得元 | 検索入力フィールド |

#### categoryId

| 項目 | 値 |
|------|-----|
| 型 | string |
| 必須 | - |
| 説明 | カテゴリの識別子 |
| 例 | "cat-programming" |
| 取得元 | カテゴリ選択時にURLパラメータとして渡される |

### 条件分岐

| 条件 | True時の遷移 | False時の遷移 |
|------|-------------|---------------|
| ログイン済み | マイページへ | ログインモーダル表示 |
| 検索結果あり | 結果一覧表示 | Empty状態表示（遷移なし） |
| フィルター適用後 | 一覧更新 | 一覧更新（結果0件でもEmpty表示） |

### フロー図

\`\`\`mermaid
flowchart LR
    subgraph 流入
        Home[ホーム]
        SearchResult[検索結果]
        CategoryList[カテゴリ一覧]
        CourseDetail[講座詳細]
    end
    
    subgraph 現在の画面
        CourseList[講座一覧]
    end
    
    subgraph 流出
        Detail[講座詳細]
        Filter[フィルターモーダル]
        Search[検索結果]
    end
    
    Home -->|講座一覧リンク| CourseList
    SearchResult -->|検索実行| CourseList
    CategoryList -->|カテゴリ選択| CourseList
    CourseDetail -->|戻る| CourseList
    
    CourseList -->|カードクリック| Detail
    CourseList -->|フィルターボタン| Filter
    CourseList -->|検索実行| Search
    Filter -.->|適用/閉じる| CourseList
\`\`\`

### 画面スタック

ナビゲーションスタックの想定：

\`\`\`
[ホーム] → [講座一覧] → [講座詳細]
                ↑
            モーダル: フィルター

または

[カテゴリ一覧] → [講座一覧] → [講座詳細]
\`\`\`

### 特記事項

- 講座詳細からの戻りは講座一覧に戻る（popナビゲーション）
- フィルターモーダルは画面遷移ではなくオーバーレイ表示
- ホームへの遷移はreplaceで、スタックをリセット
- ログインが必要な操作（お気に入り追加等）はログインモーダルを挟む
- 深い階層からホームに戻る場合はスタック全体をリセット
```
