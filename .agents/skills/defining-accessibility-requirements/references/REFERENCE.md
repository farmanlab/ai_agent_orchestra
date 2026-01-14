# Accessibility Requirements Reference

アクセシビリティ要件定義の参照ドキュメント索引。

## クイックリファレンス

| ドキュメント | 用途 | 主要コンテンツ |
|-------------|------|---------------|
| [a11y-patterns.md](a11y-patterns.md) | コンポーネント別パターン | ボタン、フォーム、モーダル等のARIA設定 |
| [a11y-keyboard.md](a11y-keyboard.md) | キーボード操作 | フォーカス管理、ショートカット、トラップ |
| [workflow.md](workflow.md) | 作業手順 | ステップバイステップのワークフロー |
| [section-template.md](section-template.md) | 出力テンプレート | spec.md セクション形式 |

## パターン別索引

### コンポーネントパターン（a11y-patterns.md）

- **ボタン**: `role="button"`, `aria-pressed`, `aria-expanded`
- **フォーム**: `aria-label`, `aria-describedby`, `aria-invalid`
- **モーダル**: `role="dialog"`, `aria-modal`, フォーカストラップ
- **タブ**: `role="tablist"`, `aria-selected`, キーボードナビ
- **アコーディオン**: `aria-expanded`, `aria-controls`

### キーボードパターン（a11y-keyboard.md）

- **フォーカス順序**: tabindex 管理
- **フォーカストラップ**: モーダル内閉じ込め
- **スキップリンク**: メインコンテンツへジャンプ
- **ショートカット**: Escape, Enter, Space, Arrow keys

## 使用方法

1. コンポーネント種別を特定
2. a11y-patterns.md で該当パターンを参照
3. キーボード操作は a11y-keyboard.md を確認
4. section-template.md 形式で出力
