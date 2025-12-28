# デザイントークンセクション テンプレート

spec.md の「デザイントークン」セクションに挿入する内容のテンプレートです。

---

## セクション全体

```markdown
## デザイントークン

> **ステータス**: 完了 ✓  
> **生成スキル**: extracting-design-tokens  
> **更新日**: {{DATE}}

### カラー

#### プライマリ

| トークン名 | 値 | 用途 |
|-----------|-----|------|
| {{COLOR_PRIMARY_NAME}} | {{COLOR_PRIMARY_VALUE}} | {{COLOR_PRIMARY_USAGE}} |

#### テキスト

| トークン名 | 値 | 用途 |
|-----------|-----|------|
| {{COLOR_TEXT_NAME}} | {{COLOR_TEXT_VALUE}} | {{COLOR_TEXT_USAGE}} |

#### 背景

| トークン名 | 値 | 用途 |
|-----------|-----|------|
| {{COLOR_BG_NAME}} | {{COLOR_BG_VALUE}} | {{COLOR_BG_USAGE}} |

#### セマンティック

| トークン名 | 値 | 用途 |
|-----------|-----|------|
| {{COLOR_SEMANTIC_NAME}} | {{COLOR_SEMANTIC_VALUE}} | {{COLOR_SEMANTIC_USAGE}} |

### タイポグラフィ

| トークン名 | フォント | サイズ | ウェイト | 行間 | 用途 |
|-----------|---------|--------|---------|------|------|
| {{TYPO_NAME}} | {{TYPO_FONT}} | {{TYPO_SIZE}} | {{TYPO_WEIGHT}} | {{TYPO_LINE_HEIGHT}} | {{TYPO_USAGE}} |

### スペーシング

| トークン名 | 値 | 用途 |
|-----------|-----|------|
| {{SPACING_NAME}} | {{SPACING_VALUE}} | {{SPACING_USAGE}} |

### シャドウ

| トークン名 | 値 | 用途 |
|-----------|-----|------|
| {{SHADOW_NAME}} | {{SHADOW_VALUE}} | {{SHADOW_USAGE}} |

### ボーダー

| トークン名 | 値 | 用途 |
|-----------|-----|------|
| {{BORDER_NAME}} | {{BORDER_VALUE}} | {{BORDER_USAGE}} |

### アニメーション

| トークン名 | 値 | 用途 |
|-----------|-----|------|
| {{ANIMATION_NAME}} | {{ANIMATION_VALUE}} | {{ANIMATION_USAGE}} |

### この画面で使用されているトークン

| カテゴリ | トークン | 使用箇所 |
|---------|---------|---------|
| {{USAGE_CATEGORY}} | {{USAGE_TOKEN}} | {{USAGE_ELEMENT}} |

### 特記事項

- {{TOKEN_NOTE_1}}
- {{TOKEN_NOTE_2}}
```

---

## 変数一覧

### カラー

| 変数 | 説明 |
|------|------|
| `{{COLOR_PRIMARY_NAME}}` | プライマリカラートークン名 |
| `{{COLOR_PRIMARY_VALUE}}` | プライマリカラー値 |
| `{{COLOR_PRIMARY_USAGE}}` | 用途 |
| `{{COLOR_TEXT_NAME}}` | テキストカラートークン名 |
| `{{COLOR_TEXT_VALUE}}` | テキストカラー値 |
| `{{COLOR_TEXT_USAGE}}` | 用途 |
| `{{COLOR_BG_NAME}}` | 背景カラートークン名 |
| `{{COLOR_BG_VALUE}}` | 背景カラー値 |
| `{{COLOR_BG_USAGE}}` | 用途 |
| `{{COLOR_SEMANTIC_NAME}}` | セマンティックカラートークン名 |
| `{{COLOR_SEMANTIC_VALUE}}` | セマンティックカラー値 |
| `{{COLOR_SEMANTIC_USAGE}}` | 用途 |

### タイポグラフィ

| 変数 | 説明 |
|------|------|
| `{{TYPO_NAME}}` | タイポグラフィトークン名 |
| `{{TYPO_FONT}}` | フォントファミリー |
| `{{TYPO_SIZE}}` | フォントサイズ |
| `{{TYPO_WEIGHT}}` | フォントウェイト |
| `{{TYPO_LINE_HEIGHT}}` | 行間 |
| `{{TYPO_USAGE}}` | 用途 |

### スペーシング

| 変数 | 説明 |
|------|------|
| `{{SPACING_NAME}}` | スペーシングトークン名 |
| `{{SPACING_VALUE}}` | スペーシング値 |
| `{{SPACING_USAGE}}` | 用途 |

### シャドウ

| 変数 | 説明 |
|------|------|
| `{{SHADOW_NAME}}` | シャドウトークン名 |
| `{{SHADOW_VALUE}}` | シャドウ値 |
| `{{SHADOW_USAGE}}` | 用途 |

### ボーダー

| 変数 | 説明 |
|------|------|
| `{{BORDER_NAME}}` | ボーダートークン名 |
| `{{BORDER_VALUE}}` | ボーダー値 |
| `{{BORDER_USAGE}}` | 用途 |

### アニメーション

| 変数 | 説明 |
|------|------|
| `{{ANIMATION_NAME}}` | アニメーショントークン名 |
| `{{ANIMATION_VALUE}}` | アニメーション値 |
| `{{ANIMATION_USAGE}}` | 用途 |

### 使用箇所

| 変数 | 説明 |
|------|------|
| `{{USAGE_CATEGORY}}` | カテゴリ |
| `{{USAGE_TOKEN}}` | トークン名 |
| `{{USAGE_ELEMENT}}` | 使用要素 |

---

## spec.md 更新時の追加変更

### 1. 完了チェックリスト

```markdown
- [x] デザイントークン (extracting-design-tokens)
```

### 2. 変更履歴

```markdown
| {{DATE}} | デザイントークン | extracting-design-tokensにより生成 |
```

---

## 出力例

```markdown
## デザイントークン

> **ステータス**: 完了 ✓  
> **生成スキル**: extracting-design-tokens  
> **更新日**: 2024-01-15

### カラー

#### プライマリ

| トークン名 | 値 | 用途 |
|-----------|-----|------|
| color/primary/default | #0070E0 | ボタン背景、リンク |
| color/primary/hover | #005BB5 | ボタンホバー |
| color/primary/pressed | #004A99 | ボタン押下 |

#### テキスト

| トークン名 | 値 | 用途 |
|-----------|-----|------|
| color/text/primary | #24243F | 見出し、本文 |
| color/text/secondary | #67717A | 補足テキスト |
| color/text/disabled | #9E9E9E | 非活性テキスト |
| color/text/inverse | #FFFFFF | ボタンテキスト |

#### 背景

| トークン名 | 値 | 用途 |
|-----------|-----|------|
| color/background/primary | #FFFFFF | ページ背景 |
| color/background/secondary | #F8F9F9 | セクション背景 |
| color/background/tertiary | #E8EAED | カード背景 |

#### セマンティック

| トークン名 | 値 | 用途 |
|-----------|-----|------|
| color/success | #2E7D32 | 成功メッセージ |
| color/error | #D32F2F | エラーメッセージ |
| color/warning | #F57C00 | 警告メッセージ |
| color/info | #1976D2 | 情報メッセージ |

### タイポグラフィ

| トークン名 | フォント | サイズ | ウェイト | 行間 | 用途 |
|-----------|---------|--------|---------|------|------|
| typography/heading/1 | Noto Sans JP | 32px | 700 | 1.4 | ページタイトル |
| typography/heading/2 | Noto Sans JP | 24px | 700 | 1.4 | セクション見出し |
| typography/heading/3 | Noto Sans JP | 20px | 600 | 1.4 | カードタイトル |
| typography/body/default | Noto Sans JP | 14px | 400 | 1.6 | 本文 |
| typography/body/small | Noto Sans JP | 12px | 400 | 1.5 | キャプション |
| typography/button | Noto Sans JP | 14px | 600 | 1.0 | ボタン |

### スペーシング

| トークン名 | 値 | 用途 |
|-----------|-----|------|
| spacing/xs | 8px | アイコン-テキスト間 |
| spacing/sm | 12px | 関連要素間 |
| spacing/md | 16px | カード内パディング |
| spacing/lg | 24px | カード間ギャップ |
| spacing/xl | 32px | セクション間 |

### シャドウ

| トークン名 | 値 | 用途 |
|-----------|-----|------|
| shadow/sm | 0 1px 2px rgba(0,0,0,0.05) | 軽いエレベーション |
| shadow/md | 0 4px 6px rgba(0,0,0,0.1) | 講座カード |
| shadow/lg | 0 10px 15px rgba(0,0,0,0.1) | カードホバー |
| shadow/xl | 0 20px 25px rgba(0,0,0,0.15) | モーダル |

### ボーダー

| トークン名 | 値 | 用途 |
|-----------|-----|------|
| border/radius/sm | 4px | ボタン、タグ |
| border/radius/md | 8px | カード、入力フィールド |
| border/radius/lg | 16px | モーダル |
| border/radius/full | 9999px | アバター、ピルボタン |
| border/width/default | 1px | 入力フィールド、区切り線 |
| border/color/default | #E0E0E0 | 入力ボーダー |

### アニメーション

| トークン名 | 値 | 用途 |
|-----------|-----|------|
| animation/duration/fast | 100ms | 即時フィードバック |
| animation/duration/normal | 200ms | ホバー、状態変化 |
| animation/duration/slow | 300ms | モーダル表示 |
| animation/easing/default | ease-out | 標準イージング |

### この画面で使用されているトークン

| カテゴリ | トークン | 使用箇所 |
|---------|---------|---------|
| Color | color/primary/default | 送信ボタン背景、講座リンク |
| Color | color/text/primary | ページタイトル、講座名 |
| Color | color/text/secondary | 講座説明、メタ情報 |
| Color | color/background/secondary | カード背景 |
| Typography | typography/heading/1 | ページタイトル「講座一覧」 |
| Typography | typography/heading/3 | 講座カードタイトル |
| Typography | typography/body/default | 講座説明文 |
| Spacing | spacing/md | カード内パディング |
| Spacing | spacing/lg | カード間ギャップ |
| Shadow | shadow/md | 講座カード |
| Shadow | shadow/lg | カードホバー時 |
| Border | border/radius/md | 講座カード |

### 特記事項

- Figma Variablesから取得: color/*, typography/heading/*, spacing/*
- 画面から抽出（要確認）: shadow/*, animation/*
- フォント「Noto Sans JP」はGoogle Fontsから読み込み
- 画面幅によるタイポグラフィ調整は未定義（レスポンシブ検討時に追加）
```
