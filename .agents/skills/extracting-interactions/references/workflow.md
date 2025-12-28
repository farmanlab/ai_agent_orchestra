# インタラクション抽出ワークフロー

Figmaデザインからインタラクション仕様を抽出する詳細な手順です。

## 概要

```
1. spec.md の存在確認
   └─> なければ初期化

2. インタラクティブ要素を特定
   └─> HTML/Figmaからボタン、入力、カード等を抽出

3. コンポーネントバリアントを検出
   └─> Figmaのバリアントプロパティを確認

4. 状態変化を整理
   └─> 各要素の状態遷移を文書化

5. トリガーとアクションを文書化
   └─> ユーザー操作と対応するアクションを整理

6. トランジション/アニメーションを整理
   └─> プロパティ、duration、easingを記録

7. 画面遷移を整理
   └─> 遷移先とアニメーションを文書化

8. spec.md の「インタラクション」セクションを更新
```

---

## Step 0: spec.md の存在確認

### 実行

```bash
# 確認
ls .agents/tmp/{screen-id}/spec.md

# なければ初期化
cp .agents/templates/screen-spec.md .agents/tmp/{screen-id}/spec.md
```

### 検証

- [ ] spec.md が存在する
- [ ] 基本情報が入力されている

---

## Step 1: インタラクティブ要素を特定

### 入力ソース

1. **生成済みHTML** (`index.html`)
2. **Figmaデザイン**

### HTMLから抽出

以下の要素を検索：

```html
<!-- ボタン -->
<button>, <a role="button">, [data-figma-content="button"]

<!-- リンク -->
<a href>, [data-figma-content="link"]

<!-- 入力 -->
<input>, <textarea>, <select>

<!-- インタラクティブカード -->
[data-figma-content="interactive_card"]

<!-- その他 -->
[role="tab"], [role="checkbox"], [role="switch"]
```

### Figmaから抽出

`get_design_context` の結果から：

- コンポーネント名に "Button", "Input", "Card" 等を含むもの
- インスタンスとして使用されているコンポーネント

### 出力形式

```yaml
interactive_elements:
  - id: submit-button
    type: button
    name: 送信ボタン
    figma_node: "1234:5678"
    
  - id: course-card
    type: card
    name: 講座カード
    figma_node: "2345:6789"
    count: 複数（リスト項目）
    
  - id: email-input
    type: input
    name: メールアドレス入力
    figma_node: "3456:7890"
```

### 検証

- [ ] 主要なインタラクティブ要素が特定された
- [ ] 各要素にFigmaノードIDが紐づいている

---

## Step 2: コンポーネントバリアントを検出

### Figmaバリアントの確認

```bash
mcp__figma__get_design_context(fileKey, componentNodeId)
```

### バリアントプロパティの例

```
Button (Component Set)
├── State
│   ├── Default
│   ├── Hover
│   ├── Pressed
│   └── Disabled
├── Variant
│   ├── Primary
│   └── Secondary
└── Size
    ├── Small
    └── Medium
```

### 状態プロパティの検出

以下のプロパティ名を状態として扱う：

| プロパティ名 | 用途 |
|-------------|------|
| State | 一般的な状態 |
| Status | 状態 |
| Hover | hover状態のon/off |
| Pressed | pressed状態のon/off |
| Focus | focus状態のon/off |
| Disabled | disabled状態のon/off |
| Selected | 選択状態 |
| Active | アクティブ状態 |

### 出力形式

```yaml
component_variants:
  - component: Button
    states:
      - name: Default
        node_id: "1234:5678"
      - name: Hover
        node_id: "1234:5679"
      - name: Pressed
        node_id: "1234:5680"
      - name: Disabled
        node_id: "1234:5681"
```

### 検証

- [ ] コンポーネントのバリアントが検出された
- [ ] 各状態のノードIDが取得できた

---

## Step 3: 状態変化を整理

### 各バリアント間の差分分析

```bash
# 各状態のデザイン情報を取得
mcp__figma__get_design_context(fileKey, stateNodeId)
```

### 比較観点

| 観点 | 確認項目 |
|------|----------|
| 色 | 背景色、テキスト色、ボーダー色 |
| サイズ | width, height, padding |
| 形状 | border-radius, border-width |
| 効果 | shadow, opacity |
| 変形 | scale, translate, rotate |
| 表示 | 要素の表示/非表示 |

### 出力形式

```yaml
state_changes:
  - element: 送信ボタン
    from: default
    to: hover
    changes:
      - property: background-color
        from: "#0070e0"
        to: "#005bb5"
      - property: cursor
        from: "default"
        to: "pointer"
        
  - element: 送信ボタン
    from: hover
    to: pressed
    changes:
      - property: transform
        from: "none"
        to: "scale(0.98)"
```

---

## Step 4: トリガーとアクションを文書化

### トリガーの種類

| トリガー | 説明 | 対応するFigma設定 |
|----------|------|------------------|
| click | クリック/タップ | On Click |
| hover | マウスオーバー | On Hover |
| focus | フォーカス取得 | - |
| blur | フォーカス喪失 | - |
| mousedown | マウスダウン | While Pressing |
| mouseup | マウスアップ | - |
| change | 値変更 | - |
| submit | フォーム送信 | - |

### アクションの種類

| アクション | 説明 |
|-----------|------|
| 状態変更 | コンポーネントの状態を変更 |
| 画面遷移 | 別の画面へ遷移 |
| モーダル表示 | モーダル/ダイアログを表示 |
| モーダル非表示 | モーダル/ダイアログを閉じる |
| API呼び出し | サーバーと通信 |
| 値更新 | データの更新 |
| 外部リンク | 外部URLを開く |

### 出力形式

```markdown
| トリガー | 対象要素 | アクション | 条件 | 備考 |
|----------|----------|-----------|------|------|
| click | 送信ボタン | フォーム送信 | バリデーション成功 | loading状態に遷移 |
| click | 講座カード | 詳細画面へ遷移 | - | パラメータ: courseId |
| hover | 講座カード | hover状態に変更 | - | タッチデバイス非対応 |
| focus | メール入力 | focus状態に変更 | - | ラベルアニメーション |
| blur | メール入力 | バリデーション実行 | - | エラー時error状態 |
```

---

## Step 5: トランジション/アニメーションを整理

### Figmaプロトタイプ設定の確認

Figmaプロトタイプが設定されている場合：

- **Animation**: Instant, Dissolve, Smart Animate, Move In/Out, Push, Slide In/Out
- **Duration**: ms単位
- **Easing**: Linear, Ease In, Ease Out, Ease In And Out, Custom Bezier

### 標準値の適用

Figmaに設定がない場合、interaction-patterns.md の標準値を適用。

### 出力形式

```markdown
| 要素 | プロパティ | duration | easing | 備考 |
|------|-----------|----------|--------|------|
| ボタン | background-color | 150ms | ease-out | hover時 |
| ボタン | transform | 100ms | ease | pressed時 |
| カード | box-shadow | 200ms | ease | hover時 |
| カード | transform | 200ms | ease | translateY(-2px) |
| モーダル | opacity | 300ms | ease-in-out | 表示時 |
| モーダル | transform | 300ms | ease-out | scale(0.95→1) |
```

---

## Step 6: 画面遷移を整理

### Figmaプロトタイプリンクの確認

```bash
mcp__figma__get_metadata(fileKey, nodeId)
```

プロトタイプ接続がある場合、遷移先フレームを特定。

### 遷移タイプ

| タイプ | 説明 | アニメーション |
|--------|------|---------------|
| push | 新画面を右からスライドイン | translateX(100%→0) |
| pop | 現画面を右へスライドアウト | translateX(0→100%) |
| modal | モーダルとして表示 | fade + scale |
| replace | 置き換え | fade |
| none | アニメーションなし | instant |

### 出力形式

```markdown
| 起点 | アクション | 遷移先 | タイプ | 備考 |
|------|----------|--------|--------|------|
| 講座一覧 | カードクリック | 講座詳細 | push | パラメータ: courseId |
| 講座詳細 | 戻るボタン | 講座一覧 | pop | - |
| 任意 | ログインボタン | ログインモーダル | modal | オーバーレイ表示 |
```

---

## Step 7: spec.md の「インタラクション」セクションを更新

### 更新手順

1. **セクションを特定**

```markdown
<!-- 
================================================================================
SECTION: インタラクション
Generated by: extracting-interactions
================================================================================
-->

## インタラクション
```

2. **ステータスを更新**

```markdown
> **ステータス**: 完了 ✓  
> **生成スキル**: extracting-interactions  
> **更新日**: {DATE}
```

3. **プレースホルダー `{{INTERACTIONS_CONTENT}}` を内容に置換**

4. **完了チェックリストを更新**

```markdown
- [x] インタラクション (extracting-interactions)
```

5. **変更履歴に追記**

```markdown
| {DATE} | インタラクション | extracting-interactionsにより生成 |
```

### 検証

- [ ] セクションが更新されている
- [ ] ステータスが「完了 ✓」
- [ ] 全てのインタラクティブ要素が記載
- [ ] トランジション仕様が記載
- [ ] 完了チェックリストが更新
- [ ] 変更履歴に追記

---

## エラーハンドリング

### バリアントが見つからない

```
原因: コンポーネントがバリアントを持っていない
対処: 単一状態として記録、または設計者に確認
```

### Figmaプロトタイプがない

```
原因: プロトタイプが未設定
対処: interaction-patterns.md の標準値を適用
     「プロトタイプ未設定」として備考に記載
```

### 状態の差分が不明確

```
原因: バリアント間の視覚的差分が小さい
対処: スクリーンショットで確認し、可能な範囲で記載
```
