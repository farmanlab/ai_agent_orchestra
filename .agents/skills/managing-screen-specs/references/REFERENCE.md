# Screen Spec Management Reference

画面仕様書管理の参照ドキュメント索引。

## クイックリファレンス

| ドキュメント | 用途 | 主要コンテンツ |
|-------------|------|---------------|
| [section-mapping.md](section-mapping.md) | セクション責任 | スキル別担当セクション |
| [placeholders.md](placeholders.md) | プレースホルダー | 置換変数一覧 |

## テンプレート

- **[screen-spec.md](../../../templates/screen-spec.md)**: 画面仕様書テンプレート

## セクション構成

| セクション | 担当スキル |
|-----------|-----------|
| 概要 | managing-screen-specs |
| 構造・スタイル | converting-figma-to-html |
| コンテンツ分析 | converting-figma-to-html |
| UI状態 | documenting-ui-states |
| インタラクション | extracting-interactions |
| フォーム仕様 | defining-form-specs |
| APIマッピング | mapping-html-to-api |
| アクセシビリティ | defining-accessibility-requirements |
| デザイントークン | extracting-design-tokens |
| 画面フロー | documenting-screen-flows |

## ファイル構造

```
.agents/
├── templates/
│   └── screen-spec.md          # テンプレート
└── tmp/
    └── {screen-id}/
        ├── spec.md             # 画面仕様書
        ├── index.html          # 参照用HTML
        └── assets/             # 画像等
```

## 使用方法

1. テンプレートをコピーして初期化
2. 各スキルが担当セクションを更新
3. 変更履歴に記録
