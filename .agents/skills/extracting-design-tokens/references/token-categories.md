# トークンカテゴリと命名規則

デザイントークンのカテゴリ分類と命名規則を定義します。

## 目次

1. [命名規則](#命名規則)
2. [カラー](#カラー)
3. [タイポグラフィ](#タイポグラフィ)
4. [スペーシング](#スペーシング)
5. [シャドウ](#シャドウ)
6. [ボーダー](#ボーダー)
7. [アニメーション](#アニメーション)
8. [その他](#その他)

---

## 命名規則

### 基本形式

```
{category}/{subcategory}/{variant}
```

### ルール

| ルール | 説明 | 例 |
|--------|------|-----|
| 小文字 | 全て小文字を使用 | `color/primary` |
| ケバブケース | 複数語はハイフン区切り | `font-size/body-large` |
| スラッシュ区切り | 階層はスラッシュで区切る | `color/text/primary` |
| セマンティック | 用途を示す名前 | `color/success` not `color/green` |

### 階層構造

```
カテゴリ（大分類）
└── サブカテゴリ（中分類）
    └── バリアント（具体的な状態・用途）
```

例：
```
color
├── primary
│   ├── default
│   ├── hover
│   └── pressed
├── text
│   ├── primary
│   ├── secondary
│   └── disabled
└── background
    ├── primary
    └── secondary
```

---

## カラー

### プライマリ/セカンダリ

| トークン | 説明 |
|---------|------|
| `color/primary/default` | プライマリカラー（デフォルト） |
| `color/primary/hover` | プライマリカラー（ホバー） |
| `color/primary/pressed` | プライマリカラー（押下） |
| `color/primary/disabled` | プライマリカラー（非活性） |
| `color/secondary/default` | セカンダリカラー |
| `color/secondary/hover` | セカンダリカラー（ホバー） |

### テキスト

| トークン | 説明 | 典型的な値 |
|---------|------|-----------|
| `color/text/primary` | 主要テキスト | #24243F |
| `color/text/secondary` | 補足テキスト | #67717A |
| `color/text/tertiary` | 補助テキスト | #9E9E9E |
| `color/text/disabled` | 非活性テキスト | #BDBDBD |
| `color/text/inverse` | 反転テキスト（暗背景上） | #FFFFFF |
| `color/text/link` | リンクテキスト | #0070E0 |
| `color/text/link-hover` | リンクホバー | #005BB5 |

### 背景

| トークン | 説明 | 典型的な値 |
|---------|------|-----------|
| `color/background/primary` | 主要背景 | #FFFFFF |
| `color/background/secondary` | セカンダリ背景 | #F8F9F9 |
| `color/background/tertiary` | 第三背景 | #E8EAED |
| `color/background/inverse` | 反転背景 | #24243F |
| `color/background/overlay` | オーバーレイ | rgba(0,0,0,0.5) |

### ボーダー

| トークン | 説明 | 典型的な値 |
|---------|------|-----------|
| `color/border/default` | デフォルトボーダー | #E0E0E0 |
| `color/border/strong` | 強調ボーダー | #BDBDBD |
| `color/border/focus` | フォーカスボーダー | #0070E0 |

### セマンティック

| トークン | 説明 | 典型的な値 |
|---------|------|-----------|
| `color/success/default` | 成功 | #2E7D32 |
| `color/success/background` | 成功背景 | #E8F5E9 |
| `color/error/default` | エラー | #D32F2F |
| `color/error/background` | エラー背景 | #FFEBEE |
| `color/warning/default` | 警告 | #F57C00 |
| `color/warning/background` | 警告背景 | #FFF3E0 |
| `color/info/default` | 情報 | #1976D2 |
| `color/info/background` | 情報背景 | #E3F2FD |

---

## タイポグラフィ

### 見出し

| トークン | サイズ | ウェイト | 用途 |
|---------|--------|---------|------|
| `typography/heading/1` | 32-40px | 700 | ページタイトル |
| `typography/heading/2` | 24-28px | 700 | セクション見出し |
| `typography/heading/3` | 20-22px | 600 | サブセクション見出し |
| `typography/heading/4` | 18px | 600 | 小見出し |
| `typography/heading/5` | 16px | 600 | 最小見出し |

### 本文

| トークン | サイズ | ウェイト | 用途 |
|---------|--------|---------|------|
| `typography/body/large` | 16-18px | 400 | 強調本文 |
| `typography/body/default` | 14-16px | 400 | 標準本文 |
| `typography/body/small` | 12-14px | 400 | 小さい本文 |

### 補助

| トークン | サイズ | ウェイト | 用途 |
|---------|--------|---------|------|
| `typography/caption` | 12px | 400 | キャプション |
| `typography/overline` | 10-12px | 600 | オーバーライン |
| `typography/label` | 12-14px | 500 | ラベル |

### UI

| トークン | サイズ | ウェイト | 用途 |
|---------|--------|---------|------|
| `typography/button/default` | 14px | 600 | ボタン |
| `typography/button/small` | 12px | 600 | 小ボタン |
| `typography/link` | 14px | 400 | リンク |

### 個別プロパティ

```
typography/font-family/primary: "Noto Sans JP", sans-serif
typography/font-family/secondary: "Inter", sans-serif
typography/font-family/mono: "Roboto Mono", monospace

typography/font-size/xs: 10px
typography/font-size/sm: 12px
typography/font-size/md: 14px
typography/font-size/lg: 16px
typography/font-size/xl: 20px
typography/font-size/2xl: 24px
typography/font-size/3xl: 32px

typography/font-weight/regular: 400
typography/font-weight/medium: 500
typography/font-weight/semibold: 600
typography/font-weight/bold: 700

typography/line-height/tight: 1.2
typography/line-height/normal: 1.5
typography/line-height/relaxed: 1.75

typography/letter-spacing/tight: -0.02em
typography/letter-spacing/normal: 0
typography/letter-spacing/wide: 0.05em
```

---

## スペーシング

### 基本スケール

| トークン | 値 | 説明 |
|---------|-----|------|
| `spacing/0` | 0 | なし |
| `spacing/px` | 1px | 最小 |
| `spacing/0.5` | 2px | - |
| `spacing/1` | 4px | - |
| `spacing/2` | 8px | - |
| `spacing/3` | 12px | - |
| `spacing/4` | 16px | - |
| `spacing/5` | 20px | - |
| `spacing/6` | 24px | - |
| `spacing/8` | 32px | - |
| `spacing/10` | 40px | - |
| `spacing/12` | 48px | - |
| `spacing/16` | 64px | - |

### セマンティック（推奨）

| トークン | 値 | 用途 |
|---------|-----|------|
| `spacing/2xs` | 4px | 最小間隔 |
| `spacing/xs` | 8px | アイコン-テキスト間 |
| `spacing/sm` | 12px | 関連要素間 |
| `spacing/md` | 16px | コンポーネント内 |
| `spacing/lg` | 24px | セクション間 |
| `spacing/xl` | 32px | 大セクション間 |
| `spacing/2xl` | 48px | ページセクション間 |
| `spacing/3xl` | 64px | 大きな余白 |

---

## シャドウ

### エレベーション

| トークン | 値 | 用途 |
|---------|-----|------|
| `shadow/none` | none | シャドウなし |
| `shadow/xs` | 0 1px 2px rgba(0,0,0,0.05) | 微小 |
| `shadow/sm` | 0 1px 3px rgba(0,0,0,0.1) | 小 |
| `shadow/md` | 0 4px 6px rgba(0,0,0,0.1) | 中（カード） |
| `shadow/lg` | 0 10px 15px rgba(0,0,0,0.1) | 大（ドロップダウン） |
| `shadow/xl` | 0 20px 25px rgba(0,0,0,0.1) | 特大（モーダル） |
| `shadow/2xl` | 0 25px 50px rgba(0,0,0,0.25) | 最大 |
| `shadow/inner` | inset 0 2px 4px rgba(0,0,0,0.05) | 内側 |

### 状態

| トークン | 値 | 用途 |
|---------|-----|------|
| `shadow/focus` | 0 0 0 3px rgba(0,112,224,0.4) | フォーカスリング |
| `shadow/hover` | 0 4px 12px rgba(0,0,0,0.15) | ホバー時 |

---

## ボーダー

### 角丸

| トークン | 値 | 用途 |
|---------|-----|------|
| `border/radius/none` | 0 | 角丸なし |
| `border/radius/sm` | 2px | 小 |
| `border/radius/md` | 4px | 標準（ボタン、入力） |
| `border/radius/lg` | 8px | 大（カード） |
| `border/radius/xl` | 12px | 特大 |
| `border/radius/2xl` | 16px | モーダル |
| `border/radius/full` | 9999px | 円形、ピル型 |

### 線幅

| トークン | 値 | 用途 |
|---------|-----|------|
| `border/width/none` | 0 | ボーダーなし |
| `border/width/thin` | 1px | 標準 |
| `border/width/medium` | 2px | 強調 |
| `border/width/thick` | 4px | 特に強調 |

### スタイル

| トークン | 値 |
|---------|-----|
| `border/style/solid` | solid |
| `border/style/dashed` | dashed |
| `border/style/dotted` | dotted |

---

## アニメーション

### Duration

| トークン | 値 | 用途 |
|---------|-----|------|
| `animation/duration/instant` | 0ms | 即時 |
| `animation/duration/fast` | 100ms | 素早いフィードバック |
| `animation/duration/normal` | 200ms | 標準 |
| `animation/duration/slow` | 300ms | ゆっくり |
| `animation/duration/slower` | 500ms | より遅く |

### Easing

| トークン | 値 | 用途 |
|---------|-----|------|
| `animation/easing/linear` | linear | 一定速度 |
| `animation/easing/ease` | ease | 汎用 |
| `animation/easing/ease-in` | ease-in | 開始がゆっくり |
| `animation/easing/ease-out` | ease-out | 終了がゆっくり |
| `animation/easing/ease-in-out` | ease-in-out | 開始と終了がゆっくり |

### セマンティック

| トークン | 説明 |
|---------|------|
| `animation/enter` | 要素の登場（duration: 200ms, easing: ease-out） |
| `animation/exit` | 要素の退場（duration: 150ms, easing: ease-in） |
| `animation/hover` | ホバー（duration: 150ms, easing: ease-out） |

---

## その他

### Z-index

| トークン | 値 | 用途 |
|---------|-----|------|
| `z-index/base` | 0 | ベース |
| `z-index/dropdown` | 1000 | ドロップダウン |
| `z-index/sticky` | 1100 | スティッキー要素 |
| `z-index/fixed` | 1200 | 固定要素 |
| `z-index/modal-backdrop` | 1300 | モーダル背景 |
| `z-index/modal` | 1400 | モーダル |
| `z-index/popover` | 1500 | ポップオーバー |
| `z-index/tooltip` | 1600 | ツールチップ |
| `z-index/toast` | 1700 | トースト |

### Opacity

| トークン | 値 | 用途 |
|---------|-----|------|
| `opacity/disabled` | 0.5 | 非活性 |
| `opacity/hover` | 0.8 | ホバー時の透過 |
| `opacity/overlay` | 0.5 | オーバーレイ |

### Breakpoints

| トークン | 値 | 説明 |
|---------|-----|------|
| `breakpoint/sm` | 640px | モバイル |
| `breakpoint/md` | 768px | タブレット |
| `breakpoint/lg` | 1024px | 小デスクトップ |
| `breakpoint/xl` | 1280px | デスクトップ |
| `breakpoint/2xl` | 1536px | 大画面 |

---

## Figma Variablesとの対応

### Figma Variablesの構造

```
Collection: Primitives
├── colors
│   ├── blue-500: #0070E0
│   └── gray-900: #24243F
└── spacing
    └── 4: 16px

Collection: Semantic
├── color
│   ├── primary: {Primitives.colors.blue-500}
│   └── text-primary: {Primitives.colors.gray-900}
└── spacing
    └── md: {Primitives.spacing.4}
```

### 対応表

| Figma Variable | トークン名 |
|---------------|-----------|
| `color/primary` | `color/primary/default` |
| `color/text/primary` | `color/text/primary` |
| `spacing/md` | `spacing/md` |

### data-figma-tokens属性

HTMLに埋め込まれるトークン情報：

```html
<button data-figma-tokens="background: color/primary/default; color: color/text/inverse; padding: spacing/md; border-radius: border/radius/md">
```
