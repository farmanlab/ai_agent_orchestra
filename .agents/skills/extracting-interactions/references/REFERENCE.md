# Interactions Reference

インタラクション抽出の参照ドキュメント索引。

## クイックリファレンス

| ドキュメント | 用途 | 主要コンテンツ |
|-------------|------|---------------|
| [interaction-patterns.md](interaction-patterns.md) | インタラクションパターン | トリガー、アクション、状態遷移 |
| [workflow.md](workflow.md) | 作業手順 | ステップバイステップのワークフロー |
| [section-template.md](section-template.md) | 出力テンプレート | spec.md セクション形式 |

## インタラクションパターン索引

### トリガー種別

| トリガー | イベント | 用途 |
|---------|---------|------|
| click/tap | `onClick` | ボタン、リンク |
| hover | `onMouseEnter/Leave` | ツールチップ、プレビュー |
| focus | `onFocus/Blur` | フォーム、キーボードナビ |
| scroll | `onScroll` | 無限スクロール、パララックス |
| swipe | `onSwipe*` | カルーセル、削除 |

### アクション種別

| アクション | 説明 | 例 |
|-----------|------|-----|
| navigate | 画面遷移 | `push('/detail')` |
| toggle | 状態切り替え | メニュー開閉 |
| submit | データ送信 | フォーム送信 |
| fetch | データ取得 | API呼び出し |
| animate | アニメーション | フェード、スライド |

### 状態遷移パターン

```
idle → hover → active → complete
  ↓              ↓
loading      error
```

### data-figma-interaction 属性

```html
<button
  data-figma-interaction="click:navigate"
  data-figma-target="/next-screen"
  data-figma-transition="push"
>
```

## 使用方法

1. Figmaプロトタイプからインタラクションを特定
2. interaction-patterns.md で該当パターンを参照
3. トリガー→アクション→結果を定義
4. section-template.md 形式で出力
