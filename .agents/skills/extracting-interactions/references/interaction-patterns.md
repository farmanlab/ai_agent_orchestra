# インタラクションパターン集

一般的なUIコンポーネントのインタラクションパターンを定義します。

## 目次

1. [ボタン](#ボタン)
2. [入力フィールド](#入力フィールド)
3. [カード](#カード)
4. [ナビゲーション](#ナビゲーション)
5. [モーダル/ダイアログ](#モーダルダイアログ)
6. [フィードバック](#フィードバック)
7. [トランジション標準値](#トランジション標準値)

---

## ボタン

### 状態一覧

| 状態 | トリガー | 視覚変化 |
|------|----------|----------|
| default | - | 基本スタイル |
| hover | マウスオーバー | 背景色変化、カーソル変更 |
| focus | Tab/クリック | フォーカスリング表示 |
| pressed/active | マウスダウン | scale縮小、背景色変化 |
| disabled | 非活性条件 | opacity低下、カーソル変更 |
| loading | 処理中 | スピナー表示、テキスト非表示 |

### 状態遷移図

```mermaid
stateDiagram-v2
    default --> hover: mouseenter
    hover --> default: mouseleave
    hover --> pressed: mousedown
    pressed --> hover: mouseup
    default --> focus: focus
    focus --> default: blur
    default --> disabled: 条件成立
    disabled --> default: 条件解除
    default --> loading: 処理開始
    loading --> default: 処理完了
```

### トランジション

| プロパティ | duration | easing |
|-----------|----------|--------|
| background-color | 150ms | ease-out |
| transform | 100ms | ease |
| opacity | 150ms | ease |

### バリアント検出パターン

```
Button
├── State=Default / State=Hover / State=Pressed / State=Disabled
├── Variant=Primary / Variant=Secondary / Variant=Tertiary
└── Size=Small / Size=Medium / Size=Large
```

---

## 入力フィールド

### 状態一覧

| 状態 | トリガー | 視覚変化 |
|------|----------|----------|
| default | - | 基本スタイル |
| hover | マウスオーバー | ボーダー色変化 |
| focus | フォーカス | ボーダー強調、ラベル移動 |
| filled | 入力あり | 値表示 |
| error | バリデーション失敗 | 赤ボーダー、エラーメッセージ |
| disabled | 非活性 | 背景グレー、入力不可 |
| readonly | 読み取り専用 | 編集不可、スタイル変化 |

### 状態遷移図

```mermaid
stateDiagram-v2
    default --> hover: mouseenter
    hover --> default: mouseleave
    default --> focus: focus
    focus --> filled: 入力
    focus --> default: blur（空）
    filled --> focus: focus
    filled --> error: バリデーション失敗
    error --> focus: focus
    error --> filled: バリデーション成功
```

### トランジション

| プロパティ | duration | easing |
|-----------|----------|--------|
| border-color | 150ms | ease |
| box-shadow | 150ms | ease |
| transform (label) | 200ms | ease-out |

### バリアント検出パターン

```
Input / TextField
├── State=Default / State=Focus / State=Filled / State=Error / State=Disabled
├── Type=Text / Type=Password / Type=Email / Type=Number
└── Size=Small / Size=Medium / Size=Large
```

---

## カード

### 状態一覧

| 状態 | トリガー | 視覚変化 |
|------|----------|----------|
| default | - | 基本スタイル |
| hover | マウスオーバー | 影強調、わずかな上昇 |
| pressed | クリック中 | 影縮小 |
| selected | 選択 | ボーダー/背景変化 |
| disabled | 非活性 | opacity低下 |

### トランジション

| プロパティ | duration | easing |
|-----------|----------|--------|
| box-shadow | 200ms | ease |
| transform | 200ms | ease |

### バリアント検出パターン

```
Card
├── State=Default / State=Hover / State=Selected
└── Variant=Elevated / Variant=Outlined / Variant=Filled
```

---

## ナビゲーション

### タブ

| 状態 | トリガー | 視覚変化 |
|------|----------|----------|
| default | - | 非選択スタイル |
| hover | マウスオーバー | 背景色変化 |
| selected | クリック | 下線/背景強調、フォントウェイト変化 |
| disabled | 非活性 | opacity低下 |

### アコーディオン

| 状態 | トリガー | 視覚変化 |
|------|----------|----------|
| collapsed | - | コンテンツ非表示、アイコン→ |
| expanded | クリック | コンテンツ表示、アイコン↓ |

### トランジション

| 要素 | プロパティ | duration | easing |
|------|-----------|----------|--------|
| タブインジケーター | transform | 200ms | ease-out |
| アコーディオンコンテンツ | height, opacity | 300ms | ease-in-out |
| アコーディオンアイコン | transform (rotate) | 200ms | ease |

### バリアント検出パターン

```
Tab
├── State=Default / State=Selected / State=Disabled
└── Selected=true / Selected=false

Accordion
├── State=Collapsed / State=Expanded
└── Open=true / Open=false
```

---

## モーダル/ダイアログ

### 状態一覧

| 状態 | トリガー | 視覚変化 |
|------|----------|----------|
| hidden | - | 非表示 |
| visible | 開くアクション | 表示、背景オーバーレイ |
| closing | 閉じるアクション | フェードアウト |

### アニメーション

| タイプ | 表示 | 非表示 |
|--------|------|--------|
| fade | opacity 0→1 | opacity 1→0 |
| scale | scale 0.95→1 + fade | scale 1→0.95 + fade |
| slide-up | translateY(20px)→0 + fade | translateY(0)→20px + fade |

### トランジション

| プロパティ | duration | easing |
|-----------|----------|--------|
| opacity | 200-300ms | ease-in-out |
| transform | 200-300ms | ease-out |

### バリアント検出パターン

```
Modal / Dialog
├── Visible=true / Visible=false
└── Size=Small / Size=Medium / Size=Large / Size=Fullscreen
```

---

## フィードバック

### トースト/スナックバー

| 状態 | トリガー | 視覚変化 |
|------|----------|----------|
| hidden | - | 非表示 |
| entering | 表示開始 | スライドイン |
| visible | 表示中 | 完全表示 |
| exiting | 自動/手動閉じ | スライドアウト |

### アニメーション

| 位置 | 表示 | 非表示 |
|------|------|--------|
| top | translateY(-100%)→0 | translateY(0)→-100% |
| bottom | translateY(100%)→0 | translateY(0)→100% |

### トランジション

| プロパティ | duration | easing |
|-----------|----------|--------|
| transform | 300ms | ease-out (in) / ease-in (out) |
| opacity | 300ms | ease |

### ツールチップ

| 状態 | トリガー | 視覚変化 |
|------|----------|----------|
| hidden | - | 非表示 |
| visible | hover/focus (遅延後) | フェードイン |

### トランジション

| プロパティ | duration | easing | delay |
|-----------|----------|--------|-------|
| opacity | 150ms | ease | 300-500ms (表示) / 0ms (非表示) |

---

## トランジション標準値

### Duration

| カテゴリ | 値 | 用途 |
|----------|-----|------|
| instant | 0-100ms | 即時フィードバック |
| fast | 100-200ms | ボタン、小さな変化 |
| normal | 200-300ms | 標準的なUI変化 |
| slow | 300-500ms | モーダル、大きな変化 |
| deliberate | 500ms+ | 強調、注目を集める |

### Easing

| 名前 | CSS値 | 用途 |
|------|-------|------|
| ease | ease | 汎用 |
| ease-out | ease-out | 要素の登場 |
| ease-in | ease-in | 要素の退場 |
| ease-in-out | ease-in-out | 状態変化 |
| linear | linear | 連続アニメーション |

### 推奨組み合わせ

| インタラクション | duration | easing |
|-----------------|----------|--------|
| ボタンhover | 150ms | ease-out |
| カードhover | 200ms | ease |
| モーダル表示 | 300ms | ease-out |
| モーダル非表示 | 200ms | ease-in |
| ページ遷移 | 300-400ms | ease-in-out |
| ドロップダウン | 200ms | ease-out |
| アコーディオン | 300ms | ease-in-out |

---

## Figmaプロトタイプ設定との対応

| Figma設定 | 仕様書での表現 |
|-----------|---------------|
| On Click | click トリガー |
| On Hover | hover トリガー |
| While Pressing | pressed 状態 |
| Smart Animate | プロパティ間の補間 |
| Instant | duration: 0ms |
| Dissolve | opacity アニメーション |
| Move In/Out | transform: translate アニメーション |
| Push | 画面遷移 push |
| Slide In/Out | transform: translate アニメーション |

### Figma Easing対応

| Figma | CSS |
|-------|-----|
| Linear | linear |
| Ease In | ease-in |
| Ease Out | ease-out |
| Ease In And Out | ease-in-out |
| Ease In Back | cubic-bezier(0.6, -0.28, 0.735, 0.045) |
| Ease Out Back | cubic-bezier(0.175, 0.885, 0.32, 1.275) |
| Custom Bezier | cubic-bezier(...) |
