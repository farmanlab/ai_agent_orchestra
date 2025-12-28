# キーボード操作とユーティリティ

アクセシビリティのためのキーボード操作パターンとユーティリティクラス。

## 目次

1. [カルーセル](#カルーセル)
2. [キーボード操作一覧](#キーボード操作一覧)
3. [visually-hidden クラス](#visually-hidden-クラス)

---

## カルーセル

### 基本パターン

```html
<div role="region"
     aria-roledescription="カルーセル"
     aria-label="おすすめ商品">

  <div aria-live="polite">
    <div role="group"
         aria-roledescription="スライド"
         aria-label="1 / 5">
      スライド内容...
    </div>
  </div>

  <button aria-label="前のスライド">←</button>
  <button aria-label="次のスライド">→</button>

  <!-- ページネーション -->
  <div role="tablist" aria-label="スライド選択">
    <button role="tab" aria-selected="true" aria-label="スライド1">●</button>
    <button role="tab" aria-selected="false" aria-label="スライド2">○</button>
  </div>
</div>
```

### 要件

- 自動再生は停止可能にする
- 現在位置を示す（1 / 5 等）
- キーボード操作可能

---

## キーボード操作一覧

### 共通

| キー | 動作 |
|------|------|
| Tab | 次のフォーカス可能要素へ |
| Shift + Tab | 前のフォーカス可能要素へ |
| Enter | リンク移動、ボタン実行 |
| Space | ボタン実行、チェックボックス切替 |
| Escape | モーダル閉じる、キャンセル |

### 方向キー

| コンポーネント | ← / → | ↑ / ↓ |
|--------------|-------|-------|
| タブ | タブ切り替え | - |
| メニュー | サブメニュー開閉 | 項目移動 |
| ラジオボタン | 選択移動 | 選択移動 |
| スライダー | 値変更 | 値変更 |
| グリッド | セル移動 | セル移動 |

---

## visually-hidden クラス

視覚的に隠しつつスクリーンリーダーには読み上げさせる：

```css
.visually-hidden {
  position: absolute;
  width: 1px;
  height: 1px;
  padding: 0;
  margin: -1px;
  overflow: hidden;
  clip: rect(0, 0, 0, 0);
  white-space: nowrap;
  border: 0;
}
```

### 使用例

- スキップリンク（フォーカス時は表示）
- アイコンボタンの補足テキスト
- 追加の文脈情報
