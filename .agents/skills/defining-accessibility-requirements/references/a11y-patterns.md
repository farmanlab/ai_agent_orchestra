# アクセシビリティパターン集

コンポーネント別のアクセシビリティ要件パターンを定義します。

## 目次

1. [ランドマーク](#ランドマーク)
2. [ナビゲーション](#ナビゲーション)
3. [ボタン・リンク](#ボタンリンク)
4. [フォーム](#フォーム)
5. [画像・アイコン](#画像アイコン)
6. [テーブル](#テーブル)
7. [モーダル・ダイアログ](#モーダルダイアログ)
8. [タブ](#タブ)
9. [アコーディオン](#アコーディオン)
10. [通知・アラート](#通知アラート)
11. [色とコントラスト](#色とコントラスト)

---

## ランドマーク

### 基本構造

```html
<header role="banner">
  <nav role="navigation" aria-label="メインナビゲーション">...</nav>
</header>

<main role="main">
  <section aria-labelledby="section-title">
    <h2 id="section-title">セクションタイトル</h2>
    ...
  </section>
</main>

<aside role="complementary" aria-label="関連情報">...</aside>

<footer role="contentinfo">...</footer>
```

### ルール

| ランドマーク | 使用条件 | 備考 |
|-------------|---------|------|
| banner | ページに1つ | `<header>` |
| navigation | 複数可 | aria-labelで区別 |
| main | ページに1つ | `<main>` |
| complementary | 補足情報 | `<aside>` |
| contentinfo | ページに1つ | `<footer>` |
| region | 重要セクション | aria-label必須 |
| search | 検索フォーム | `<form role="search">` |

---

## ナビゲーション

### 基本パターン

```html
<nav aria-label="メインナビゲーション">
  <ul>
    <li><a href="/" aria-current="page">ホーム</a></li>
    <li><a href="/about">会社概要</a></li>
    <li><a href="/contact">お問い合わせ</a></li>
  </ul>
</nav>
```

### 属性

| 属性 | 用途 |
|------|------|
| aria-label | ナビゲーションの識別（複数ある場合） |
| aria-current="page" | 現在のページを示す |

### キーボード操作

| キー | 動作 |
|------|------|
| Tab | 次のリンクへ |
| Shift + Tab | 前のリンクへ |
| Enter | リンク先へ移動 |

### スキップリンク

```html
<a href="#main-content" class="skip-link">
  メインコンテンツへスキップ
</a>
```

- 最初のフォーカス可能要素として配置
- フォーカス時のみ表示（視覚的に隠す）

---

## ボタン・リンク

### ボタン

```html
<!-- テキストボタン -->
<button type="button">送信する</button>

<!-- アイコンボタン -->
<button type="button" aria-label="検索">
  <svg aria-hidden="true">...</svg>
</button>

<!-- トグルボタン -->
<button type="button" aria-pressed="false">
  お気に入りに追加
</button>

<!-- 読み込み中 -->
<button type="button" disabled aria-busy="true">
  <span class="spinner" aria-hidden="true"></span>
  送信中...
</button>
```

### リンク

```html
<!-- 通常リンク -->
<a href="/page">ページへ</a>

<!-- 新しいタブで開く -->
<a href="/page" target="_blank" rel="noopener noreferrer">
  外部サイト
  <span class="visually-hidden">（新しいタブで開きます）</span>
</a>

<!-- ダウンロードリンク -->
<a href="/file.pdf" download>
  資料をダウンロード (PDF, 2.5MB)
</a>
```

### 区別

| 要素 | 用途 |
|------|------|
| `<button>` | アクション実行（送信、開閉、削除等） |
| `<a>` | ページ遷移、アンカーリンク |

---

## フォーム

### 入力フィールド

```html
<!-- 基本 -->
<label for="email">メールアドレス</label>
<input type="email" id="email" name="email" 
       aria-describedby="email-hint email-error"
       aria-invalid="false"
       required>
<span id="email-hint">例: example@email.com</span>
<span id="email-error" role="alert" hidden>
  有効なメールアドレスを入力してください
</span>

<!-- 必須表示 -->
<label for="name">
  お名前
  <span aria-hidden="true">*</span>
  <span class="visually-hidden">（必須）</span>
</label>
```

### エラー状態

```html
<input type="email" id="email" 
       aria-invalid="true"
       aria-describedby="email-error">
<span id="email-error" role="alert">
  有効なメールアドレスを入力してください
</span>
```

### グループ化

```html
<!-- ラジオボタングループ -->
<fieldset>
  <legend>お支払い方法</legend>
  <input type="radio" id="credit" name="payment" value="credit">
  <label for="credit">クレジットカード</label>
  <input type="radio" id="bank" name="payment" value="bank">
  <label for="bank">銀行振込</label>
</fieldset>
```

### 属性一覧

| 属性 | 用途 |
|------|------|
| aria-required="true" | 必須フィールド（HTML required属性と併用可） |
| aria-invalid="true" | バリデーションエラー時 |
| aria-describedby | ヘルパーテキスト、エラーメッセージ |
| aria-errormessage | エラーメッセージ要素のID |
| autocomplete | 自動入力ヒント |

---

## 画像・アイコン

### 情報を伝える画像

```html
<img src="chart.png" alt="2024年売上推移グラフ。1月100万円から12月500万円へ増加">
```

### 装飾画像

```html
<img src="decoration.png" alt="" role="presentation">
<!-- または -->
<img src="decoration.png" alt="" aria-hidden="true">
```

### 機能アイコン

```html
<!-- ボタン内アイコン -->
<button aria-label="メニューを開く">
  <svg aria-hidden="true">...</svg>
</button>

<!-- テキスト付きアイコン -->
<button>
  <svg aria-hidden="true">...</svg>
  設定
</button>
```

### 装飾アイコン

```html
<span aria-hidden="true">★</span>
```

### altテキストのガイドライン

| 画像の種類 | altの書き方 |
|-----------|------------|
| 機能的 | 機能を説明（「検索」「閉じる」） |
| 情報的 | 伝える情報を記述 |
| 装飾的 | alt="" |
| 複雑なグラフ | 概要 + 詳細データへのリンク |
| ロゴ | 会社/サービス名 |

---

## テーブル

### 基本パターン

```html
<table>
  <caption>2024年度 売上一覧</caption>
  <thead>
    <tr>
      <th scope="col">月</th>
      <th scope="col">売上</th>
      <th scope="col">前年比</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th scope="row">1月</th>
      <td>100万円</td>
      <td>+10%</td>
    </tr>
  </tbody>
</table>
```

### 属性

| 属性 | 用途 |
|------|------|
| `<caption>` | テーブルのタイトル |
| scope="col" | 列ヘッダー |
| scope="row" | 行ヘッダー |
| aria-describedby | 補足説明 |

---

## モーダル・ダイアログ

### 基本パターン

```html
<div role="dialog" 
     aria-modal="true" 
     aria-labelledby="dialog-title"
     aria-describedby="dialog-desc">
  <h2 id="dialog-title">確認</h2>
  <p id="dialog-desc">本当に削除しますか？</p>
  <button type="button">キャンセル</button>
  <button type="button">削除する</button>
</div>
```

### 必須要件

| 要件 | 説明 |
|------|------|
| role="dialog" | ダイアログであることを示す |
| aria-modal="true" | モーダルであることを示す |
| aria-labelledby | タイトルとの関連付け |
| フォーカストラップ | モーダル内でフォーカスをループ |
| Escapeで閉じる | キーボード操作 |
| 背景の非活性化 | aria-hidden="true" または inert |

### フォーカス管理

1. 開く時: モーダル内の最初のフォーカス可能要素へ
2. 閉じる時: モーダルを開いたトリガー要素へ
3. モーダル内でTab/Shift+Tabでループ

---

## タブ

### 基本パターン

```html
<div role="tablist" aria-label="商品情報">
  <button role="tab" 
          aria-selected="true" 
          aria-controls="panel-1" 
          id="tab-1">
    概要
  </button>
  <button role="tab" 
          aria-selected="false" 
          aria-controls="panel-2" 
          id="tab-2"
          tabindex="-1">
    仕様
  </button>
</div>

<div role="tabpanel" 
     id="panel-1" 
     aria-labelledby="tab-1">
  概要の内容...
</div>

<div role="tabpanel" 
     id="panel-2" 
     aria-labelledby="tab-2"
     hidden>
  仕様の内容...
</div>
```

### キーボード操作

| キー | 動作 |
|------|------|
| ← / → | 前後のタブへ移動 |
| Home | 最初のタブへ |
| End | 最後のタブへ |
| Tab | タブパネル内へ |

### 属性

| 属性 | 用途 |
|------|------|
| aria-selected="true" | 選択中のタブ |
| aria-controls | 制御するパネルのID |
| tabindex="-1" | 非選択タブはTab順序から除外 |

---

## アコーディオン

### 基本パターン

```html
<div class="accordion">
  <h3>
    <button aria-expanded="false" 
            aria-controls="content-1"
            id="accordion-1">
      よくある質問1
    </button>
  </h3>
  <div id="content-1" 
       role="region" 
       aria-labelledby="accordion-1"
       hidden>
    回答の内容...
  </div>
</div>
```

### キーボード操作

| キー | 動作 |
|------|------|
| Enter / Space | 開閉トグル |
| ↑ / ↓ | アコーディオンヘッダー間移動（任意） |

### 属性

| 属性 | 用途 |
|------|------|
| aria-expanded | 展開状態 |
| aria-controls | 制御するコンテンツのID |

---

## 通知・アラート

### 成功/情報通知（polite）

```html
<div role="status" aria-live="polite">
  保存しました
</div>
```

### エラー/警告通知（assertive）

```html
<div role="alert" aria-live="assertive">
  エラーが発生しました
</div>
```

### aria-live値

| 値 | 用途 |
|-----|------|
| off | 通知しない |
| polite | 現在の読み上げ完了後に通知 |
| assertive | 即座に通知（重要な場合のみ） |

### role

| role | 用途 |
|------|------|
| status | 状態変化の通知（aria-live="polite"と同等） |
| alert | 重要な通知（aria-live="assertive"と同等） |
| log | ログ形式の更新 |
| timer | タイマー |

---

## 色とコントラスト

### WCAG基準

| レベル | 通常テキスト | 大きいテキスト | UI要素 |
|--------|------------|--------------|--------|
| AA | 4.5:1 | 3:1 | 3:1 |
| AAA | 7:1 | 4.5:1 | - |

### 大きいテキストの定義

- 18pt (24px) 以上
- 14pt (18.5px) 以上 かつ bold

### 色に依存しない情報伝達

| 状況 | 悪い例 | 良い例 |
|------|--------|--------|
| エラー | 赤色のみ | 赤色 + アイコン + テキスト |
| リンク | 色のみ | 色 + 下線 |
| 必須 | 赤色のみ | 赤色 + アスタリスク(*) |
| 状態 | 緑/赤 | 色 + ラベル（成功/失敗） |

### コントラスト確認ツール

- WebAIM Contrast Checker
- Figma Contrast Plugin
- Chrome DevTools Accessibility

---

## 関連リファレンス

- **[a11y-keyboard.md](a11y-keyboard.md)**: カルーセル、キーボード操作一覧、visually-hidden クラス
