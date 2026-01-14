# フォームテンプレート集

一般的なフォーム構造のテンプレートを定義します。

## 目次

1. [ログインフォーム](#ログインフォーム)
2. [登録フォーム](#登録フォーム)
3. [プロフィール編集](#プロフィール編集)
4. [検索フォーム](#検索フォーム)
5. [問い合わせフォーム](#問い合わせフォーム)
6. [決済フォーム](#決済フォーム)

---

## ログインフォーム

### 基本構造

```yaml
form:
  id: login-form
  method: POST
  action: /api/auth/login
  fields:
    - name: email
      type: email
      label: メールアドレス
      required: true
      autocomplete: email
    - name: password
      type: password
      label: パスワード
      required: true
      autocomplete: current-password
    - name: remember
      type: checkbox
      label: ログイン状態を保持する
      required: false
  submit:
    label: ログイン
    loading: ログイン中...
```

### 関連リンク

- パスワードを忘れた方 → `/forgot-password`
- 新規登録 → `/register`

---

## 登録フォーム

### 基本構造

```yaml
form:
  id: registration-form
  method: POST
  action: /api/auth/register
  fields:
    - name: name
      type: text
      label: 氏名
      required: true
      maxLength: 50
    - name: email
      type: email
      label: メールアドレス
      required: true
      validation:
        - unique: API確認
    - name: password
      type: password
      label: パスワード
      required: true
      minLength: 8
      hint: 8文字以上で入力してください
    - name: passwordConfirm
      type: password
      label: パスワード（確認）
      required: true
      validation:
        - match: password
    - name: terms
      type: checkbox
      label: 利用規約に同意する
      required: true
      link: /terms
  submit:
    label: 登録する
    loading: 登録中...
```

---

## プロフィール編集

### 基本構造

```yaml
form:
  id: profile-form
  method: PUT
  action: /api/users/me
  fields:
    - name: avatar
      type: file
      label: プロフィール画像
      accept: image/*
      maxSize: 5MB
    - name: name
      type: text
      label: 表示名
      required: true
    - name: bio
      type: textarea
      label: 自己紹介
      maxLength: 500
      rows: 4
    - name: birthday
      type: date
      label: 生年月日
    - name: gender
      type: select
      label: 性別
      options:
        - value: ""
          label: 選択してください
        - value: male
          label: 男性
        - value: female
          label: 女性
        - value: other
          label: その他
  submit:
    label: 保存する
    loading: 保存中...
```

---

## 検索フォーム

### 基本構造

```yaml
form:
  id: search-form
  method: GET
  action: /search
  fields:
    - name: q
      type: search
      label: キーワード
      placeholder: 検索...
      autocomplete: off
    - name: category
      type: select
      label: カテゴリ
      options:
        - value: ""
          label: すべて
        - value: product
          label: 商品
        - value: article
          label: 記事
    - name: sort
      type: radio
      label: 並び順
      options:
        - value: relevance
          label: 関連度順
        - value: newest
          label: 新着順
        - value: popular
          label: 人気順
  submit:
    label: 検索
    icon: search
```

---

## 問い合わせフォーム

### 基本構造

```yaml
form:
  id: contact-form
  method: POST
  action: /api/contact
  fields:
    - name: name
      type: text
      label: お名前
      required: true
    - name: email
      type: email
      label: メールアドレス
      required: true
    - name: category
      type: select
      label: お問い合わせ種別
      required: true
      options:
        - value: ""
          label: 選択してください
        - value: general
          label: 一般的なお問い合わせ
        - value: support
          label: サポート
        - value: feedback
          label: ご意見・ご要望
    - name: message
      type: textarea
      label: お問い合わせ内容
      required: true
      minLength: 10
      maxLength: 2000
      rows: 6
  submit:
    label: 送信する
    loading: 送信中...
  success:
    message: お問い合わせを受け付けました
    redirect: /contact/complete
```

---

## 決済フォーム

### 基本構造

```yaml
form:
  id: payment-form
  method: POST
  action: /api/orders
  sections:
    - title: 配送先情報
      fields:
        - name: postalCode
          type: text
          label: 郵便番号
          pattern: /^\d{3}-?\d{4}$/
          autocomplete: postal-code
        - name: address
          type: text
          label: 住所
          required: true
          autocomplete: street-address
    - title: カード情報
      fields:
        - name: cardNumber
          type: text
          label: カード番号
          inputmode: numeric
          autocomplete: cc-number
          mask: "0000 0000 0000 0000"
        - name: expiry
          type: text
          label: 有効期限
          placeholder: MM/YY
          autocomplete: cc-exp
        - name: cvc
          type: text
          label: セキュリティコード
          inputmode: numeric
          autocomplete: cc-csc
          maxLength: 4
  submit:
    label: 支払いを確定する
    loading: 処理中...
```

---

## フォーム共通パターン

### レイアウト

| パターン | 用途 |
|---------|------|
| 縦積み | 標準的なフォーム |
| 横並び | 短いフィールドの組み合わせ（氏名、郵便番号等） |
| グリッド | 複雑な入力項目 |

### 状態

| 状態 | 説明 |
|------|------|
| default | 初期状態 |
| focus | フォーカス中 |
| filled | 入力済み |
| error | エラーあり |
| disabled | 無効 |
| readonly | 読み取り専用 |

### アクセシビリティ

- すべての入力に `<label>` を関連付け
- エラー時は `aria-invalid="true"` + `aria-describedby`
- 必須フィールドは `aria-required="true"`
- グループ化は `<fieldset>` + `<legend>`
