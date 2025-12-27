# HTML Screenshot & Comparison Tools

FigmaデザインとHTMLの視覚的比較を行うためのツール群。

## セットアップ

```bash
cd ~/.agents/scripts/html-screenshot
npm install
```

## ツール

### 1. screenshot.js - HTMLスクリーンショット取得

```bash
node screenshot.js <html-file-path> [output-path] [options]

# Options:
#   --width=N       Viewport width (default: 375)
#   --height=N      Viewport height (default: 812)
#   --no-full-page  Capture only viewport

# Examples:
node screenshot.js ./top.html
node screenshot.js ./top.html ./output.png --width=375
```

### 2. compare.js - 画像比較

```bash
node compare.js <image1> <image2> [diff-output]

# Examples:
node compare.js html_screenshot.png figma_screenshot.png
node compare.js html.png figma.png diff.png
```

## 出力

### screenshot.js
- PNG形式のスクリーンショット
- Retinaクオリティ (deviceScaleFactor: 2)

### compare.js
- 差分ピクセル数と割合
- 判定結果:
  - ✅ PIXEL PERFECT (0%)
  - 🟡 NEARLY PERFECT (< 1%)
  - 🟠 NOTICEABLE (< 5%)
  - 🔴 SIGNIFICANT (>= 5%)
- オプションで差分画像を出力（赤色で差分表示）

## comparing-figma-html エージェントでの使用

エージェントは以下のフローで使用:

1. `mcp__figma__get_screenshot` でFigmaスクリーンショット取得
2. `screenshot.js` でHTMLスクリーンショット取得
3. `compare.js` で差分を計算
4. 差分が大きい箇所を特定してレポート
