# Design Tokens Reference

デザイントークン抽出の参照ドキュメント索引。

## クイックリファレンス

| ドキュメント | 用途 | 主要コンテンツ |
|-------------|------|---------------|
| [token-categories.md](token-categories.md) | トークン分類 | カラー、タイポグラフィ、スペーシング等 |
| [workflow.md](workflow.md) | 作業手順 | ステップバイステップのワークフロー |
| [section-template.md](section-template.md) | 出力テンプレート | spec.md セクション形式 |

## トークンカテゴリ索引

### カラートークン

| カテゴリ | 例 | 用途 |
|---------|-----|------|
| primary | `--color-primary-500` | ブランドカラー、CTA |
| secondary | `--color-secondary-300` | サブアクション |
| neutral | `--color-gray-100` | 背景、ボーダー |
| semantic | `--color-error`, `--color-success` | 状態表示 |

### タイポグラフィトークン

| プロパティ | トークン例 |
|-----------|-----------|
| font-family | `--font-family-sans`, `--font-family-mono` |
| font-size | `--font-size-sm`, `--font-size-lg` |
| font-weight | `--font-weight-normal`, `--font-weight-bold` |
| line-height | `--line-height-tight`, `--line-height-relaxed` |

### スペーシングトークン

| サイズ | 値 | 用途 |
|--------|-----|------|
| xs | 4px | インラインスペース |
| sm | 8px | コンパクト要素間 |
| md | 16px | 標準要素間 |
| lg | 24px | セクション間 |
| xl | 32px | 大きなセクション間 |

### その他トークン

- **シャドウ**: `--shadow-sm`, `--shadow-md`, `--shadow-lg`
- **ボーダー**: `--border-radius-sm`, `--border-width`
- **アニメーション**: `--duration-fast`, `--easing-default`

## 使用方法

1. Figmaから変数/スタイルを抽出
2. token-categories.md でカテゴリを特定
3. 命名規則に従いトークン名を決定
4. section-template.md 形式で出力
