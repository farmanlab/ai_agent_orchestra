# インタラクションセクション テンプレート

spec.md の「インタラクション」セクションに挿入する内容のテンプレートです。

---

## セクション全体

```markdown
## インタラクション

> **ステータス**: 完了 ✓  
> **生成スキル**: extracting-interactions  
> **更新日**: {{DATE}}

### インタラクティブ要素一覧

| 要素 | 種別 | 状態数 | 備考 |
|------|------|--------|------|
| {{ELEMENT_NAME_1}} | {{ELEMENT_TYPE_1}} | {{STATE_COUNT_1}} | {{ELEMENT_NOTES_1}} |
| {{ELEMENT_NAME_2}} | {{ELEMENT_TYPE_2}} | {{STATE_COUNT_2}} | {{ELEMENT_NOTES_2}} |

### コンポーネント状態

#### {{COMPONENT_NAME_1}}

| 状態 | 視覚変化 | Figma Node |
|------|----------|------------|
| default | {{DEFAULT_VISUAL}} | `{{DEFAULT_NODE}}` |
| hover | {{HOVER_VISUAL}} | `{{HOVER_NODE}}` |
| pressed | {{PRESSED_VISUAL}} | `{{PRESSED_NODE}}` |
| disabled | {{DISABLED_VISUAL}} | `{{DISABLED_NODE}}` |

#### {{COMPONENT_NAME_2}}

| 状態 | 視覚変化 | Figma Node |
|------|----------|------------|
| default | {{DEFAULT_VISUAL}} | `{{DEFAULT_NODE}}` |
| hover | {{HOVER_VISUAL}} | `{{HOVER_NODE}}` |

### トリガーとアクション

| トリガー | 対象要素 | アクション | 条件 |
|----------|----------|-----------|------|
| {{TRIGGER_1}} | {{TARGET_1}} | {{ACTION_1}} | {{CONDITION_1}} |
| {{TRIGGER_2}} | {{TARGET_2}} | {{ACTION_2}} | {{CONDITION_2}} |

### トランジション仕様

| 要素 | プロパティ | duration | easing | 備考 |
|------|-----------|----------|--------|------|
| {{TRANS_ELEMENT_1}} | {{TRANS_PROP_1}} | {{DURATION_1}} | {{EASING_1}} | {{TRANS_NOTES_1}} |
| {{TRANS_ELEMENT_2}} | {{TRANS_PROP_2}} | {{DURATION_2}} | {{EASING_2}} | {{TRANS_NOTES_2}} |

### 画面遷移

| 起点 | アクション | 遷移先 | アニメーション |
|------|----------|--------|---------------|
| この画面 | {{NAV_ACTION_1}} | {{NAV_DEST_1}} | {{NAV_ANIM_1}} |
| この画面 | {{NAV_ACTION_2}} | {{NAV_DEST_2}} | {{NAV_ANIM_2}} |

### 特記事項

- {{SPECIAL_NOTE_1}}
- {{SPECIAL_NOTE_2}}
```

---

## 変数一覧

### 基本情報

| 変数 | 説明 |
|------|------|
| `{{DATE}}` | 更新日 |

### インタラクティブ要素

| 変数 | 説明 |
|------|------|
| `{{ELEMENT_NAME_N}}` | 要素名 |
| `{{ELEMENT_TYPE_N}}` | 種別（button/input/card等） |
| `{{STATE_COUNT_N}}` | 状態数 |
| `{{ELEMENT_NOTES_N}}` | 備考 |

### コンポーネント状態

| 変数 | 説明 |
|------|------|
| `{{COMPONENT_NAME_N}}` | コンポーネント名 |
| `{{XXX_VISUAL}}` | 視覚変化の説明 |
| `{{XXX_NODE}}` | FigmaノードID |

### トリガーとアクション

| 変数 | 説明 |
|------|------|
| `{{TRIGGER_N}}` | トリガー（click/hover/focus等） |
| `{{TARGET_N}}` | 対象要素 |
| `{{ACTION_N}}` | アクション |
| `{{CONDITION_N}}` | 条件 |

### トランジション

| 変数 | 説明 |
|------|------|
| `{{TRANS_ELEMENT_N}}` | 対象要素 |
| `{{TRANS_PROP_N}}` | プロパティ |
| `{{DURATION_N}}` | アニメーション時間 |
| `{{EASING_N}}` | イージング関数 |
| `{{TRANS_NOTES_N}}` | 備考 |

### 画面遷移

| 変数 | 説明 |
|------|------|
| `{{NAV_ACTION_N}}` | 遷移トリガーとなるアクション |
| `{{NAV_DEST_N}}` | 遷移先画面 |
| `{{NAV_ANIM_N}}` | 遷移アニメーション |

### 特記事項

| 変数 | 説明 |
|------|------|
| `{{SPECIAL_NOTE_N}}` | 特記事項 |

---

## spec.md 更新時の追加変更

セクション更新と同時に以下も更新：

### 1. 完了チェックリスト

```markdown
- [x] インタラクション (extracting-interactions)
```

### 2. 変更履歴

```markdown
| {{DATE}} | インタラクション | extracting-interactionsにより生成 |
```

---

## 出力例

```markdown
## インタラクション

> **ステータス**: 完了 ✓  
> **生成スキル**: extracting-interactions  
> **更新日**: 2024-01-15

### インタラクティブ要素一覧

| 要素 | 種別 | 状態数 | 備考 |
|------|------|--------|------|
| 送信ボタン | button | 5 | Primary, default/hover/pressed/disabled/loading |
| 講座カード | card | 2 | default/hover |
| メールフィールド | input | 4 | default/focus/filled/error |
| タブメニュー | tab | 3 | default/hover/selected |

### コンポーネント状態

#### 送信ボタン

| 状態 | 視覚変化 | Figma Node |
|------|----------|------------|
| default | 背景 #0070e0, テキスト白, 角丸 8px | `1234:5678` |
| hover | 背景 #005bb5 | `1234:5679` |
| pressed | scale(0.98), 背景 #004a99 | `1234:5680` |
| disabled | opacity 0.5, cursor: not-allowed | `1234:5681` |
| loading | スピナー表示, テキスト非表示 | `1234:5682` |

#### 講座カード

| 状態 | 視覚変化 | Figma Node |
|------|----------|------------|
| default | 背景白, shadow: 0 2px 4px rgba(0,0,0,0.1) | `2345:6789` |
| hover | shadow: 0 4px 12px rgba(0,0,0,0.15), translateY(-2px) | `2345:6790` |

#### メールフィールド

| 状態 | 視覚変化 | Figma Node |
|------|----------|------------|
| default | ボーダー #E0E0E0, 背景白 | `3456:7890` |
| focus | ボーダー #0070e0, ラベル上部移動 | `3456:7891` |
| filled | ラベル上部固定, 値表示 | `3456:7892` |
| error | ボーダー #D32F2F, エラーメッセージ表示 | `3456:7893` |

### トリガーとアクション

| トリガー | 対象要素 | アクション | 条件 |
|----------|----------|-----------|------|
| click | 送信ボタン | フォーム送信 → loading状態 | バリデーション成功時 |
| click | 講座カード | 講座詳細画面へ遷移 | - |
| hover | 講座カード | hover状態に変更 | デスクトップのみ |
| focus | メールフィールド | focus状態に変更 | - |
| blur | メールフィールド | バリデーション実行 | 値が入力されている場合 |
| click | タブ項目 | タブ切り替え | - |

### トランジション仕様

| 要素 | プロパティ | duration | easing | 備考 |
|------|-----------|----------|--------|------|
| 送信ボタン | background-color | 150ms | ease-out | hover時 |
| 送信ボタン | transform | 100ms | ease | pressed時 |
| 講座カード | box-shadow, transform | 200ms | ease | hover時 |
| メールフィールド | border-color | 150ms | ease | focus時 |
| メールフィールド | transform (label) | 200ms | ease-out | フローティングラベル |
| タブインジケーター | transform | 200ms | ease-out | タブ切り替え時 |

### 画面遷移

| 起点 | アクション | 遷移先 | アニメーション |
|------|----------|--------|---------------|
| この画面 | カードクリック | 講座詳細画面 | push (右からスライド, 300ms) |
| この画面 | 送信成功 | 完了画面 | fade (200ms) |

### 特記事項

- hover状態はタッチデバイスでは無効化を推奨
- loading状態中はボタンクリック無効
- タブ切り替え時はコンテンツもフェードアニメーション
- エラー時はフィールドにフォーカスを移動
```
