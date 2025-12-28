# デザイントークン抽出ワークフロー

Figmaデザインからデザイントークンを抽出する詳細な手順です。

## 概要

```
1. spec.md の存在確認
   └─> なければ初期化

2. Figma Variablesを取得
   └─> 定義されている場合はトークン情報を取得

3. カラートークンを抽出
   └─> 画面内の色を収集・整理

4. タイポグラフィトークンを抽出
   └─> フォント情報を収集・整理

5. スペーシングトークンを抽出
   └─> 余白・間隔を収集・整理

6. シャドウトークンを抽出
   └─> ボックスシャドウを収集・整理

7. その他のトークンを抽出
   └─> ボーダー、アニメーション等

8. トークン使用箇所をマッピング
   └─> どの要素でどのトークンが使われているか

9. spec.md の「デザイントークン」セクションを更新
```

---

## Step 0: spec.md の存在確認

### 実行

```bash
ls .outputs/{screen-id}/spec.md
```

---

## Step 1: Figma Variablesを取得

### 実行

```bash
mcp__figma__get_variable_defs(fileKey, nodeId)
```

### 期待される出力

```json
{
  "color/primary/default": "#0070E0",
  "color/text/primary": "#24243F",
  "spacing/md": "16px",
  "typography/body/font-size": "14px"
}
```

### Variablesがない場合

Figma Variablesが定義されていない場合は、以降のステップで画面から直接値を抽出します。

---

## Step 2: カラートークンを抽出

### 情報源

1. **Figma Variables**: `mcp__figma__get_variable_defs`
2. **デザインコンテキスト**: `mcp__figma__get_design_context`
3. **生成済みHTML**: `data-figma-tokens`属性、インラインスタイル

### 抽出対象

| カテゴリ | 確認箇所 |
|---------|---------|
| プライマリ | ボタン背景、アクセントカラー |
| テキスト | 見出し、本文、補足テキスト |
| 背景 | ページ、カード、セクション |
| ボーダー | 区切り線、入力フィールド |
| セマンティック | 成功/エラー/警告メッセージ |

### 出力形式

```yaml
colors:
  primary:
    - name: color/primary/default
      value: "#0070E0"
      source: figma_variable
    - name: color/primary/hover
      value: "#005BB5"
      source: figma_variable
  text:
    - name: color/text/primary
      value: "#24243F"
      source: extracted
      note: 要確認
```

### 検証

- [ ] プライマリカラーが特定された
- [ ] テキスト色が網羅されている
- [ ] 背景色が特定された
- [ ] セマンティックカラーが特定された

---

## Step 3: タイポグラフィトークンを抽出

### 情報源

1. **Figma Variables**: フォント関連変数
2. **デザインコンテキスト**: テキスト要素のスタイル
3. **生成済みHTML**: `data-figma-font`属性

### 抽出対象

| プロパティ | 抽出元 |
|-----------|--------|
| font-family | Figmaテキストスタイル |
| font-size | Figmaテキストスタイル |
| font-weight | Figmaテキストスタイル |
| line-height | Figmaテキストスタイル |
| letter-spacing | Figmaテキストスタイル |

### 出力形式

```yaml
typography:
  heading:
    - name: typography/heading/1
      font-family: "Noto Sans JP"
      font-size: 32px
      font-weight: 700
      line-height: 1.4
      source: figma_text_style
  body:
    - name: typography/body/default
      font-family: "Noto Sans JP"
      font-size: 14px
      font-weight: 400
      line-height: 1.6
      source: extracted
```

### 検証

- [ ] 見出しスタイルが特定された
- [ ] 本文スタイルが特定された
- [ ] ボタン/UIスタイルが特定された

---

## Step 4: スペーシングトークンを抽出

### 情報源

1. **Figma Variables**: スペーシング変数
2. **デザインコンテキスト**: Auto Layout設定、パディング、ギャップ
3. **生成済みHTML**: margin、padding、gap値

### 抽出対象

| 観点 | 確認箇所 |
|------|---------|
| コンポーネント内 | カード内パディング、ボタン内パディング |
| コンポーネント間 | リスト項目間、セクション間 |
| レイアウト | カラム間、グリッドギャップ |

### 出力形式

```yaml
spacing:
  - name: spacing/xs
    value: 8px
    source: figma_variable
  - name: spacing/md
    value: 16px
    source: figma_variable
    usage:
      - カード内パディング
      - ボタン内パディング
```

### 一般的なスペーシングスケール

```
4px → spacing/2xs または spacing/1
8px → spacing/xs または spacing/2
12px → spacing/sm または spacing/3
16px → spacing/md または spacing/4
24px → spacing/lg または spacing/6
32px → spacing/xl または spacing/8
48px → spacing/2xl または spacing/12
```

---

## Step 5: シャドウトークンを抽出

### 情報源

1. **Figma Variables**: エフェクト変数
2. **デザインコンテキスト**: Drop shadow、Inner shadow設定

### 抽出対象

| 要素 | 確認箇所 |
|------|---------|
| カード | ベースシャドウ |
| ボタン | ホバー時シャドウ |
| モーダル | 強調シャドウ |
| ドロップダウン | フローティングシャドウ |

### 出力形式

```yaml
shadows:
  - name: shadow/md
    value: "0 4px 6px rgba(0,0,0,0.1)"
    source: figma_effect
    usage:
      - 講座カード
  - name: shadow/lg
    value: "0 10px 15px rgba(0,0,0,0.1)"
    source: extracted
    usage:
      - カードホバー
```

### Figmaシャドウ値の変換

Figma形式:
```
Drop Shadow
  X: 0
  Y: 4
  Blur: 6
  Spread: 0
  Color: #000000, 10%
```

CSS形式:
```css
box-shadow: 0 4px 6px 0 rgba(0, 0, 0, 0.1);
```

---

## Step 6: その他のトークンを抽出

### ボーダー

```yaml
border:
  radius:
    - name: border/radius/md
      value: 8px
      usage: カード、ボタン
  width:
    - name: border/width/default
      value: 1px
      usage: 入力フィールド、区切り線
  color:
    - name: border/color/default
      value: "#E0E0E0"
      usage: 入力フィールド
```

### アニメーション

```yaml
animation:
  duration:
    - name: animation/duration/normal
      value: 200ms
      usage: ホバートランジション
  easing:
    - name: animation/easing/default
      value: ease-out
      usage: 標準トランジション
```

---

## Step 7: トークン使用箇所をマッピング

### マッピング表の作成

画面内の各要素とトークンの対応を整理：

```markdown
| 要素 | プロパティ | トークン |
|------|-----------|---------|
| ページタイトル | color | color/text/primary |
| ページタイトル | typography | typography/heading/1 |
| 送信ボタン | background | color/primary/default |
| 送信ボタン | color | color/text/inverse |
| 送信ボタン | padding | spacing/md |
| 送信ボタン | border-radius | border/radius/md |
| 講座カード | background | color/background/primary |
| 講座カード | shadow | shadow/md |
| 講座カード | border-radius | border/radius/lg |
| 講座カード | padding | spacing/lg |
```

### HTMLからのトークン抽出

`data-figma-tokens`属性がある場合：

```html
<button data-figma-tokens="background: color/primary/default; padding: spacing/md">
```

解析して対応表に追加。

---

## Step 8: spec.md の「デザイントークン」セクションを更新

### 更新手順

1. **セクションを特定**

```markdown
<!-- 
================================================================================
SECTION: デザイントークン
Generated by: extracting-design-tokens
================================================================================
-->

## デザイントークン
```

2. **ステータスを更新**

```markdown
> **ステータス**: 完了 ✓  
> **生成スキル**: extracting-design-tokens  
> **更新日**: {DATE}
```

3. **プレースホルダー `{{DESIGN_TOKENS_CONTENT}}` を内容に置換**

4. **完了チェックリストを更新**

```markdown
- [x] デザイントークン (extracting-design-tokens)
```

5. **変更履歴に追記**

```markdown
| {DATE} | デザイントークン | extracting-design-tokensにより生成 |
```

### 検証

- [ ] セクションが更新されている
- [ ] ステータスが「完了 ✓」
- [ ] カラートークンが網羅されている
- [ ] タイポグラフィトークンが網羅されている
- [ ] スペーシングトークンが網羅されている
- [ ] 使用箇所がマッピングされている

---

## エラーハンドリング

### Figma Variablesが取得できない

```
原因: ファイルにVariablesが定義されていない、または権限がない
対処:
1. 画面から直接値を抽出
2. 一般的な命名規則でトークン名を推測
3. 「Figma Variables未定義」として備考に記載
```

### トークン名が推測できない

```
対処:
1. token-categories.md の命名規則を参照
2. 類似の用途から推測
3. 「要確認」として明示
```

### 同じ値が複数の用途で使われている

```
対処:
1. 用途別に別トークンとして記載
2. または汎用トークンとして1つにまとめる
3. 「統合検討」として備考に記載
```
