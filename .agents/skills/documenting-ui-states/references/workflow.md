# UI状態整理ワークフロー

Figmaデザインから状態バリエーションを抽出・整理する詳細な手順です。

## 概要

```
1. Figmaフレーム一覧取得
   └─> 対象画面の全フレームを取得

2. 状態バリエーション検出
   └─> フレーム名から状態を自動分類

3. 各状態のデザイン情報取得
   └─> スクリーンショット + 構造情報

4. 状態一覧の整理
   └─> 条件・表示内容・差分を文書化

5. 未定義状態の特定
   └─> 必要だが存在しない状態を明示

6. 状態遷移の整理
   └─> 遷移条件とトリガーを文書化

7. ドキュメント生成
   └─> ui_states.md
```

---

## Step 1: Figmaフレーム一覧取得

### 入力

- Figma URL（ページまたはセクション）
- または fileKey + nodeId

### 実行

```bash
# URLからfileKeyとnodeIdを抽出
URL: https://figma.com/design/{fileKey}/{fileName}?node-id={nodeId}

# メタデータ取得
mcp__figma__get_metadata(fileKey, nodeId)
```

### 出力例

```xml
<frame name="CourseList" id="1234:5678">
  <frame name="CourseList_Default" id="1234:5679" />
  <frame name="CourseList_Empty" id="1234:5680" />
  <frame name="CourseList_Loading" id="1234:5681" />
  <frame name="CourseList_Error" id="1234:5682" />
</frame>
```

### 検証

- [ ] 子フレームが取得できた
- [ ] フレーム名が確認できた

If フレームが取得できない場合, nodeIdの階層を上げて再試行。

---

## Step 2: 状態バリエーション検出

### 検出ロジック

```
1. フレーム名をパース
2. 状態サフィックスを抽出
3. state-patterns.md のルールでマッピング
```

### 検出パターン

| サフィックス | 状態 |
|-------------|------|
| `_Default`, なし | default |
| `_Empty`, `_NoData` | empty |
| `_Loading`, `_Skeleton` | loading |
| `_Error`, `_Failed` | error |
| `_Success`, `_Complete` | success |
| `_Disabled` | disabled |
| `_Selected`, `_Active` | selected |

### 出力例

```yaml
detected_states:
  - name: default
    frame_name: CourseList_Default
    node_id: "1234:5679"
  - name: empty
    frame_name: CourseList_Empty
    node_id: "1234:5680"
  - name: loading
    frame_name: CourseList_Loading
    node_id: "1234:5681"
  - name: error
    frame_name: CourseList_Error
    node_id: "1234:5682"
```

### 検証

- [ ] 少なくとも1つの状態が検出された
- [ ] default状態が特定された

If 状態が検出できない場合, フレーム名の命名規則をユーザーに確認。

---

## Step 3: 各状態のデザイン情報取得

### 実行

検出した各状態に対して：

```bash
# スクリーンショット取得
mcp__figma__get_screenshot(fileKey, nodeId)

# 構造情報取得（差分分析用）
mcp__figma__get_design_context(fileKey, nodeId)
```

### 取得する情報

| 情報 | 用途 |
|------|------|
| スクリーンショット | 視覚的参照 |
| 構造（要素一覧） | default との差分分析 |
| テキスト内容 | エラーメッセージ等の抽出 |

### 検証

- [ ] 各状態のスクリーンショットが取得できた
- [ ] default状態の構造が取得できた

---

## Step 4: 状態一覧の整理

### 各状態について記載する項目

```markdown
### {状態名}

| 項目 | 内容 |
|------|------|
| 条件 | この状態になる条件 |
| 表示内容 | 主要な表示要素 |
| Figma Node | `{nodeId}` |
| default との差分 | 変更点の説明 |
```

### 差分分析の観点

1. **追加された要素**: empty状態の空メッセージ等
2. **削除された要素**: loading状態でのコンテンツ非表示
3. **変更された要素**: error状態でのスタイル変更
4. **条件付き表示**: 特定条件でのみ表示される要素

### 出力例

```markdown
### empty

| 項目 | 内容 |
|------|------|
| 条件 | 講座データが0件の場合 |
| 表示内容 | 空状態イラスト + 「講座がありません」メッセージ + 「講座を探す」ボタン |
| Figma Node | `1234:5680` |
| default との差分 | 講座リスト部分が空状態UIに置換 |
```

---

## Step 5: 未定義状態の特定

### 判定ロジック

```
1. 画面タイプを判定（一覧/詳細/フォーム等）
2. state-patterns.md の必須状態リストを参照
3. 検出された状態と比較
4. 不足している状態をリストアップ
```

### 画面タイプの判定基準

| 画面タイプ | 判定条件 |
|-----------|----------|
| 一覧画面 | リスト/グリッド構造がある |
| 詳細画面 | 単一オブジェクトの情報表示 |
| フォーム画面 | 入力フィールドがある |
| ダッシュボード | 複数のウィジェット/カードがある |

### 出力例

```markdown
## 未定義状態

| 状態 | 必要性 | 理由 | 推奨対応 |
|------|--------|------|----------|
| loading | 🔴 高 | API通信があるため | スケルトン表示を設計者に確認 |
| partial_error | 🟡 中 | 一部データ取得失敗時 | 成功分表示 + エラーバナーを検討 |
```

---

## Step 6: 状態遷移の整理

### 遷移パターンの抽出

一般的な遷移パターン：

```
初期表示:
  [*] → loading → default | empty | error

リトライ:
  error → loading → default | empty | error

リフレッシュ:
  default → loading → default | empty | error

送信:
  default → loading → success | error
```

### 遷移表の作成

| From | To | トリガー | 条件 |
|------|-----|----------|------|
| [*] | loading | 画面表示 | - |
| loading | default | APIレスポンス | 成功 & データあり |
| loading | empty | APIレスポンス | 成功 & データなし |
| loading | error | APIレスポンス | 失敗 |
| error | loading | リトライボタン | - |
| default | loading | リフレッシュ | - |

### Mermaid図の生成

```mermaid
stateDiagram-v2
    [*] --> loading: 画面表示
    loading --> default: データあり
    loading --> empty: データなし
    loading --> error: API失敗
    error --> loading: リトライ
    default --> loading: リフレッシュ
    empty --> loading: リフレッシュ
```

---

## Step 7: ドキュメント生成

### 出力ファイル

`ui_states.md` を生成。

### テンプレート

出力テンプレートは [REFERENCE.md](REFERENCE.md) を参照。

### 検証チェックリスト

```
- [ ] 全ての検出状態が記載されている
- [ ] 各状態の条件が明確
- [ ] default との差分が明示されている
- [ ] 未定義状態がリストアップされている
- [ ] 状態遷移表が完成している
- [ ] Mermaid図が正しく表示される
```

---

## エラーハンドリング

### フレームが見つからない

```
原因: nodeIdが子フレームを含まない
対処: 親フレーム（ページまたはセクション）のnodeIdを使用
```

### 状態が検出できない

```
原因: フレーム命名規則が不統一
対処: ユーザーにフレーム名の対応表を確認
```

### 差分分析ができない

```
原因: default状態が特定できない
対処: サフィックスなしのフレームをdefaultとして扱う
```
