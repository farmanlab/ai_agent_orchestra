---
name: downloading-figma-assets
description: Downloads images, icons, and SVGs from Figma designs. Use when extracting visual assets from Figma for implementation.
---

# Figmaアセットダウンロード

FigmaデザインからPNG画像、SVGアイコン、その他のビジュアルアセットを抽出・ダウンロードする手順。

## 目次

- [Workflow](#workflow)
- [前提条件](#前提条件)
- [方法1: MCP経由でアセットURL取得（推奨）](#方法1-mcp経由でアセットurl取得推奨)
- [方法2: Figma API経由でSVGエクスポート](#方法2-figma-api経由でsvgエクスポート)
- [方法3: スクリーンショットスクリプト](#方法3-スクリーンショットスクリプト)
- [SVGの後処理](#svgの後処理)
- [よくあるアセットタイプ](#よくあるアセットタイプ)
- [トラブルシューティング](#トラブルシューティング)

## Workflow

Copy this checklist:

```
Asset Download Progress:
- [ ] Step 1: アセットタイプを特定
- [ ] Step 2: 取得方法を選択
- [ ] Step 3: アセットをダウンロード
- [ ] Step 4: SVG後処理（必要な場合）
- [ ] Step 5: 出力を確認
```

**Step 1: アセットタイプを特定**

| タイプ | 推奨方法 |
|--------|----------|
| アイコン（SVG） | MCP経由（方法1） |
| 写真・画像 | MCP経由（方法1） |
| イラスト | Figma API（方法2） |
| スクリーンショット | スクリプト（方法3） |

**Step 2: 取得方法を選択**

- **方法1（推奨）**: MCP経由 - 最も簡単、認証不要
- **方法2**: Figma API - MCPで`null`が返る場合
- **方法3**: スクリーンショット - 特定ビューが必要な場合

**Step 3-5**: 選択した方法のセクションに従って実行

If SVG icons appear white on white background, proceed to [SVGの後処理](#svgの後処理).

## 前提条件

- Figma MCP接続が有効
- FIGMA_TOKEN（API経由でエクスポートする場合）

## 方法1: MCP経由でアセットURL取得（推奨）

### Step 1: デザインコンテキスト取得

```bash
mcp__figma__get_design_context(fileKey, nodeId, clientLanguages="html,css")
```

### Step 2: アセットURLの抽出

レスポンスから `https://www.figma.com/api/mcp/asset/` で始まるURLを抽出：

```javascript
// レスポンス例
const imgHome = "https://www.figma.com/api/mcp/asset/4e601326-51bf-43b1-aa59-a0273109c3db";
const imgNotification = "https://www.figma.com/api/mcp/asset/d10837ed-2c6c-4dcd-96c4-b0b9e39efb79";
```

### Step 3: ダウンロードスクリプト

```javascript
const https = require('https');
const fs = require('fs');
const path = require('path');

const assets = {
  'icon-name': 'https://www.figma.com/api/mcp/asset/xxxxx',
  // 他のアセット
};

const outDir = './icons';

function download(name, url) {
  return new Promise((resolve, reject) => {
    const file = fs.createWriteStream(path.join(outDir, name + '.svg'));
    https.get(url, (res) => {
      if (res.statusCode === 302 || res.statusCode === 301) {
        download(name, res.headers.location).then(resolve).catch(reject);
        return;
      }
      res.pipe(file);
      file.on('finish', () => { file.close(); resolve(); });
    }).on('error', reject);
  });
}

async function main() {
  fs.mkdirSync(outDir, { recursive: true });
  for (const [name, url] of Object.entries(assets)) {
    await download(name, url);
    console.log('Downloaded:', name);
  }
}

main();
```

**注意**: MCPアセットURLは実際にはSVG形式で返されることが多い（拡張子に関わらず）。

## 方法2: Figma API経由でSVGエクスポート

### Step 1: ノードIDの特定

**HTMLから抽出する場合（推奨）:**

HTMLの `data-figma-icon-svg` 属性にはノードIDが格納されている：

```html
<span class="icon" data-figma-icon-svg="3428:18627" data-figma-node="3428:18627"></span>
```

```bash
# HTMLからノードIDを抽出
grep -oP 'data-figma-icon-svg="\K[^"]+' dashboard.html | sort -u
# 出力: 3428:18627, 491:2101, ...
```

**Figma MCPから取得する場合:**

```bash
mcp__figma__get_metadata(fileKey, nodeId)
```

### Step 2: SVGエクスポートAPI呼び出し

```javascript
const https = require('https');

const TOKEN = process.env.FIGMA_TOKEN;
const FILE_KEY = 'your-file-key';
const NODE_IDS = '123:456,789:012'; // カンマ区切り

const url = `https://api.figma.com/v1/images/${FILE_KEY}?ids=${encodeURIComponent(NODE_IDS)}&format=svg`;

https.get(url, { headers: { 'X-Figma-Token': TOKEN } }, (res) => {
  let data = '';
  res.on('data', chunk => data += chunk);
  res.on('end', () => {
    const response = JSON.parse(data);
    console.log(response.images);
    // { "123:456": "https://...", "789:012": "https://..." }
  });
});
```

**注意**: インスタンスノードやラスター画像を含むノードは`null`が返される場合がある。

## 方法3: スクリーンショットスクリプト

`~/.agents/scripts/html-screenshot/figma-screenshot.js` を使用：

```bash
node figma-screenshot.js --file-key=xxx --node-id=123:456 --token=$FIGMA_TOKEN output.png
```

## SVGの後処理

### 問題: 白いfill

Figmaからエクスポートされたアイコンは `fill="var(--fill-0, white)"` を含むことがある。
白背景では見えなくなる。

### 解決: currentColorに置換

```bash
cd icons/
for f in *.svg; do
  sed -i '' 's/fill="var(--fill-0, white)"/fill="currentColor"/g' "$f"
done
```

### currentColorの利点

```html
<!-- 親要素のcolorを継承 -->
<span style="color: #0b41a0;">
  <svg>...</svg>
</span>
```

## よくあるアセットタイプ

| タイプ | 取得方法 | 形式 |
|--------|----------|------|
| アイコン | MCP asset URL | SVG |
| 写真/画像 | MCP asset URL | PNG/JPG |
| イラスト | Figma API export | SVG |
| スクリーンショット | figma-screenshot.js | PNG |

## トラブルシューティング

| 問題 | 原因 | 解決策 |
|------|------|--------|
| SVGが白く表示 | `fill="white"` | `currentColor`に置換 |
| API exportがnull | ラスター含むノード | MCP asset URLを使用 |
| ダウンロード失敗 | リダイレクト未対応 | 302/301をフォロー |
| トークンエラー | FIGMA_TOKEN未設定 | 環境変数またはオプションで指定 |

## 出力例

```
project/
└── icons/
    ├── home.svg
    ├── notification.svg
    ├── all-courses.svg
    ├── my-courses.svg
    ├── mypage.svg
    ├── todo-plan.svg
    ├── circle-check.svg
    ├── info.svg
    └── forward.svg
```

## 関連スキル

- [converting-figma-to-html](../converting-figma-to-html/SKILL.md): HTML変換
- [extracting-design-tokens](../extracting-design-tokens/SKILL.md): デザイントークン抽出
