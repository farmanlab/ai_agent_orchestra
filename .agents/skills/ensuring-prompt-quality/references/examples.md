# 良い例・悪い例集

プロンプト作成時の参考となる具体例集です。

## 目次

1. [Description の書き方](#1-description-の書き方)
2. [Progressive Disclosure](#2-progressive-disclosure)
3. [Workflow & Checklist](#3-workflow--checklist)
4. [具体例の提供](#4-具体例の提供)
5. [品質チェックリスト](#5-品質チェックリスト)

**アンチパターンと全体例**: [examples-antipatterns.md](examples-antipatterns.md)

---

## 1. Description の書き方

### ❌ 悪い例

```yaml
# 一人称（英語）
description: I can help you process Excel files

# 一人称（日本語）
description: データを処理できます

# 二人称（英語）
description: You can use this to analyze data

# 二人称（日本語）
description: これを使ってデータ分析してください

# トリガー不足（英語）
description: Processes data

# トリガー不足（日本語）
description: データを処理

# 曖昧
description: Helps with files
description: ファイルを処理
```

### ✅ 良い例

```yaml
# 第三人称 + 具体的 + トリガー（英語）
description: Processes Excel files and generates reports. Use when analyzing spreadsheets, tabular data, or .xlsx files.

# 第三人称 + 具体的 + トリガー（日本語混在）
description: Excelファイルを処理してレポートを生成します。スプレッドシート、表形式データ、.xlsxファイルを分析する際に使用。

# 第三人称 + 何をするか + いつ使うか（英語）
description: Validates TypeScript code for type safety. Use when reviewing pull requests, before commits, or during code audits.

# 第三人称 + 何をするか + いつ使うか（日本語混在）
description: TypeScriptコードの型安全性を検証します。プルリクエストのレビュー、コミット前、コード監査時に使用。

# Agentの場合（英語）
description: Conducts technical research and analysis. Use when selecting libraries, investigating architectures, or analyzing problems.

# Agentの場合（日本語混在）
description: 技術調査と分析を実施します。ライブラリ選定、アーキテクチャ調査、問題分析時に使用。
```

---

## 2. Progressive Disclosure

### ❌ 悪い例 - 1ファイルに詰め込み

```
skills/data-processing/
└── SKILL.md  (850行) ← 長すぎる

内容:
- 基本概念 (50行)
- 詳細な処理パターン (400行)
- 全てのエッジケース (200行)
- 具体例 (200行)
```

### ❌ 悪い例 - 深すぎる参照

```
skills/data-processing/
├── SKILL.md
├── advanced.md
└── details/
    ├── patterns.md
    └── edge-cases/
        └── special.md  ← 3階層深い

SKILL.md → advanced.md → patterns.md → special.md
```

### ✅ 良い例 - 適切な分割

```
skills/data-processing/
├── SKILL.md           (180行) ← 簡潔なエントリーポイント
├── patterns.md        (250行) ← 詳細パターン
├── edge-cases.md      (150行) ← エッジケース
└── examples.md        (200行) ← 具体例

SKILL.md → patterns.md (1階層)
        → edge-cases.md (1階層)
        → examples.md (1階層)
```

**SKILL.md の内容例**:
```markdown
# Data Processing Skill

このスキルはExcelファイルの処理と分析を支援します。

## 基本原則

1. pandasを使用してデータを読み込む
2. データ型を明示的に指定
3. エラーハンドリングを実装

## 詳細ガイド

- **`patterns.md`**: 一般的な処理パターン
- **`edge-cases.md`**: エッジケースの対処法
- **`examples.md`**: 実装例

## クイックスタート

\```python
import pandas as pd
df = pd.read_excel("file.xlsx")
\```
```

---

## 3. Workflow & Checklist

### ❌ 悪い例 - 曖昧なステップ

```markdown
## 実装手順

1. データを確認
2. 処理を実行
3. 完了
```

### ❌ 悪い例 - チェックリストなし

```markdown
## 実装手順

まずデータを読み込んで、それから処理をして、最後に保存します。
エラーがあれば修正してください。
```

### ✅ 良い例 - 明確なWorkflow + Checklist

````markdown
## Implementation Workflow

Copy this checklist and track your progress:

\```
Implementation Progress:
- [ ] Step 1: データ検証（schema確認、型チェック）
- [ ] Step 2: 前処理（欠損値処理、正規化）
- [ ] Step 3: 処理実行（変換、集計）
- [ ] Step 4: テスト実行（unit test + integration test）
- [ ] Step 5: レビュー（コード品質、パフォーマンス）
\```

**Step 1: データ検証**
- `pd.read_excel()` でファイルを読み込み
- `df.dtypes` で型を確認
- `df.isnull().sum()` で欠損値を確認

**Step 2: 前処理**
- 欠損値: `df.fillna()` または `df.dropna()`
- 型変換: `df.astype()`
- 正規化: `df['col'] = (df['col'] - mean) / std`

**Step 3: 処理実行**
[詳細な処理手順...]

**Step 4: テスト実行**
```bash
pytest tests/
```

If tests fail, return to Step 2 and revise preprocessing.

**Step 5: レビュー**
- コードレビュー: `pylint script.py`
- パフォーマンス: `python -m cProfile script.py`

If issues found, return to Step 3 and optimize.
````

---

## 4. 具体例の提供

### ❌ 悪い例 - 抽象的すぎる

```markdown
## エラーハンドリング

エラーが発生した場合は適切に処理してください。
```

### ❌ 悪い例 - 説明のみでコードなし

```markdown
## エラーハンドリング

try-catchブロックを使用してエラーをキャッチし、
適切なログを出力してから、ユーザーに通知します。
```

### ✅ 良い例 - Before/After + コード例

```markdown
## エラーハンドリング

❌ **Bad**:
\```python
data = pd.read_excel("file.xlsx")
result = process(data)
\```

問題: ファイルが存在しない場合にクラッシュする

✅ **Good**:
\```python
import logging
from pathlib import Path

def process_file(filepath: str):
    try:
        if not Path(filepath).exists():
            raise FileNotFoundError(f"File not found: {filepath}")

        data = pd.read_excel(filepath)
        result = process(data)
        return result

    except FileNotFoundError as e:
        logging.error(f"File error: {e}")
        raise

    except pd.errors.EmptyDataError:
        logging.warning(f"Empty file: {filepath}")
        return None

    except Exception as e:
        logging.error(f"Unexpected error: {e}")
        raise
\```

**Why**:
- ファイルの存在確認
- 適切な例外処理
- ログ出力で問題追跡可能
```

---

## 5. 品質チェックリスト

プロンプト作成時の確認項目:

```
Quality Checklist:
- [ ] descriptionは第三人称で記述
- [ ] トリガーキーワードを含む
- [ ] nameは小文字・数字・ハイフンのみ（Skillはgerund形式推奨）
- [ ] ファイルサイズは500行以下
- [ ] 具体的なコード例を含む
- [ ] Before/After形式の比較あり
- [ ] Workflow + チェックリスト提供（複雑なタスク）
- [ ] フィードバックループあり（検証→修正→繰り返し）
- [ ] Unix形式のパス（/）
- [ ] 時間依存情報なし
- [ ] 選択肢は明確なデフォルト提示
- [ ] MCPツールは完全修飾名
- [ ] 冗長な説明を排除
- [ ] Progressive Disclosure適用（>500行の場合）
```
