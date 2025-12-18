# PCでのモバイルデザインプレビュー

## 課題

モバイル向けデザインをPCで確認する際、以下の問題が発生する：

- 固定フッター（`position: fixed`）が画面下部に張り付き、コンテンツとの間に空白ができる
- 縦長のPC画面でモバイルの縦横比が崩れる

## 解決策

**元のHTMLには手を加えず、iframeでデバイスフレーム内に表示する。**

## 実装

```html
<!DOCTYPE html>
<html lang="ja">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Mobile Preview</title>
  <script src="https://cdn.tailwindcss.com"></script>
  <style>
    .device-frame {
      width: 375px;
      height: 812px;
      border-radius: 40px;
      box-shadow:
        0 0 0 12px #1a1a1a,
        0 0 0 14px #333,
        0 25px 50px rgba(0, 0, 0, 0.3);
      overflow: hidden;
      position: relative;
    }

    .device-frame iframe {
      width: 100%;
      height: 100%;
      border: none;
    }

    .preview-background {
      background-color: #1e1e1e;
      background-image:
        radial-gradient(circle at 1px 1px, #333 1px, transparent 0);
      background-size: 20px 20px;
    }
  </style>
</head>
<body class="preview-background min-h-screen flex items-center justify-center p-8">

  <div class="device-frame">
    <iframe src="【元のHTMLファイル名】.html"></iframe>
  </div>

  <div class="fixed bottom-4 left-4 text-white/50 text-sm">
    <p>iPhone 13 mini (375 x 812)</p>
  </div>

</body>
</html>
```

## デバイスサイズ参考値

| デバイス | 幅 | 高さ |
|----------|-----|------|
| iPhone 13 mini | 375px | 812px |
| iPhone 14 | 390px | 844px |
| iPhone 14 Pro Max | 430px | 932px |
| Android (標準) | 360px | 800px |
| Android (大型) | 412px | 915px |

## 出力ファイル構成

```
outputs/
├── component_name.html              # 元のモバイルHTML
├── component_name_preview.html      # プレビュー用ラッパー
└── component_name_tokens.md         # トークンマッピング
```

## メリット

- 元のHTMLを一切変更しない
- fixedフッターが正しくデバイスフレーム内に収まる
- 複数デバイスサイズの切り替えが容易
- デザイナー・クライアントへの共有に適している
