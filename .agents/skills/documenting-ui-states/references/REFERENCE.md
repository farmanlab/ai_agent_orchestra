# UI States Reference

UI状態定義の参照ドキュメント索引。

## クイックリファレンス

| ドキュメント | 用途 | 主要コンテンツ |
|-------------|------|---------------|
| [state-patterns.md](state-patterns.md) | 状態パターン | 状態種別、検出ルール |
| [workflow.md](workflow.md) | 作業手順 | ステップバイステップのワークフロー |
| [section-template.md](section-template.md) | 出力テンプレート | spec.md セクション形式 |

## 状態パターン索引

### 標準状態

| 状態 | 説明 | Figmaフレーム名パターン |
|------|------|------------------------|
| **default** | 通常状態 | `Default`, `Normal`, `Active` |
| **loading** | 読み込み中 | `Loading`, `Skeleton` |
| **empty** | データなし | `Empty`, `No Data`, `Zero State` |
| **error** | エラー発生 | `Error`, `Failed` |
| **success** | 成功完了 | `Success`, `Complete` |
| **disabled** | 無効状態 | `Disabled`, `Inactive` |

### コンポーネント状態

| コンポーネント | 状態一覧 |
|---------------|---------|
| ボタン | default, hover, pressed, disabled, loading |
| 入力フィールド | default, focus, filled, error, disabled |
| リスト | default, loading, empty, error |
| カード | default, selected, hover |

### 状態遷移

```
default → loading → success/error
         ↓
       empty (データなしの場合)
```

## Figma検出ルール

1. フレーム名に状態キーワードを検索
2. バリアントプロパティ `State=` を確認
3. レイヤー名 `state/` プレフィックスを検出

## 使用方法

1. Figmaデザインから状態バリエーションを特定
2. state-patterns.md で該当パターンを参照
3. 各状態の表示条件を定義
4. section-template.md 形式で出力
