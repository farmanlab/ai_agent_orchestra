# Prompt Quality Reference

プロンプト品質検証の参照ドキュメント索引。

## クイックリファレンス

| ドキュメント | 用途 | 主要コンテンツ |
|-------------|------|---------------|
| [best-practices.md](best-practices.md) | ベストプラクティス | Claude Code, Cursor, Copilot |
| [validation-criteria.md](validation-criteria.md) | 検証基準 | メタデータ、構造、内容 |
| [validation-criteria-technical.md](validation-criteria-technical.md) | 技術検証 | サイズ、ツール参照 |
| [examples.md](examples.md) | 良い例集 | 模範的なプロンプト |
| [examples-antipatterns.md](examples-antipatterns.md) | アンチパターン | 避けるべきパターン |
| [templates.md](templates.md) | テンプレート | 各種プロンプト雛形 |
| [report-template.md](report-template.md) | レポート形式 | 検証結果出力形式 |

## 検証基準索引

### メタデータ検証

| 項目 | 基準 | 重要度 |
|------|------|--------|
| name | 1-64文字、小文字・ハイフン | 必須 |
| description | 1-1024文字、第三人称+トリガー | 必須 |
| paths/globs | 有効なglobパターン | 推奨 |

### 構造検証

| 項目 | 基準 |
|------|------|
| ファイルサイズ | 500行以下（SKILL.md） |
| 参照深度 | 1階層まで |
| セクション構成 | 概要、Workflow、例 |

### 内容検証

| 項目 | 基準 |
|------|------|
| 具体例 | Good/Bad 比較あり |
| ステップ形式 | 番号付き手順 |
| エラー処理 | リカバリー手順あり |

## ツール別ベストプラクティス

| ツール | 参照先 |
|--------|--------|
| Claude Code | best-practices.md #claude-code |
| Cursor | best-practices.md #cursor |
| GitHub Copilot | best-practices.md #copilot |

## 使用方法

1. プロンプトファイルを読み込み
2. validation-criteria.md で基準確認
3. best-practices.md でツール別チェック
4. report-template.md 形式で結果出力
