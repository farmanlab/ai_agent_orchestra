# アンチパターンと全体例

簡潔性、アンチパターン、プロンプト全体の良い例・悪い例を集めた参照資料です。

基本パターンについては [examples.md](examples.md) を参照してください。

## 目次

1. [簡潔性](#1-簡潔性)
2. [アンチパターン](#2-アンチパターン)
3. [プロンプト全体の例](#3-プロンプト全体の例)

---

## 1. 簡潔性

### ❌ 悪い例 - 冗長すぎる

```markdown
## PDF からテキストを抽出する方法

PDF (Portable Document Format) は、Adobe Systems によって開発された
ファイル形式で、文書をデバイスや環境に依存せずに表示するために使用
されます。PDFファイルには、テキスト、画像、ベクターグラフィックス、
フォントなどの情報が含まれています。

テキストを抽出するには、専用のライブラリが必要です。Pythonには
いくつかのPDF処理ライブラリがありますが、その中でも pdfplumber は
使いやすく、多くのケースで十分な機能を持っています。

まず、pipを使用してインストールする必要があります。pipはPythonの
パッケージマネージャーで、コマンドラインから簡単にライブラリを
インストールできます。

インストールが完了したら、以下のコードを使用してテキストを抽出
できます...

(推定150トークン以上)
```

### ✅ 良い例 - 簡潔で必要十分

```markdown
## PDF テキスト抽出

`pdfplumber` を使用:

\```python
import pdfplumber

with pdfplumber.open("file.pdf") as pdf:
    text = pdf.pages[0].extract_text()
    print(text)
\```

複数ページ:
\```python
all_text = ""
for page in pdf.pages:
    all_text += page.extract_text()
\```

(推定30トークン)
```

---

## 2. アンチパターン

### アンチパターン 1: Windows形式のパス

❌ **Bad**:
```markdown
参照: `docs\guides\setup.md`
実行: `python scripts\process.py`
```

✅ **Good**:
```markdown
参照: `docs/guides/setup.md`
実行: `python scripts/process.py`
```

---

### アンチパターン 2: 時間依存情報

❌ **Bad**:
```markdown
2025年8月以前は旧APIを使用:
\```python
from old_api import process
\```

2025年8月以降は新APIを使用:
\```python
from new_api import process
\```
```

✅ **Good**:
```markdown
## 現在の推奨

\```python
from new_api import process
\```

<details>
<summary>旧API (deprecated 2025-08)</summary>

\```python
from old_api import process
\```

**Note**: 旧APIは2025年8月に非推奨になりました。新規実装では使用しないでください。
</details>
```

---

### アンチパターン 3: 選択肢過多

❌ **Bad**:
```markdown
PDFライブラリは、pypdf、pdfplumber、PyMuPDF、pdf2image、
pdfminer.six、camelot-py、tabula-py など多数あります。
プロジェクトに応じて選択してください。
```

✅ **Good**:
```markdown
PDF処理には `pdfplumber` を使用:

\```python
import pdfplumber
with pdfplumber.open("file.pdf") as pdf:
    text = pdf.pages[0].extract_text()
\```

**特殊ケース**:
- スキャンPDF → `pdf2image` + `pytesseract`
- 表抽出 → `camelot-py` または `tabula-py`
```

---

### アンチパターン 4: MCP ツール参照

❌ **Bad**:
```markdown
Use the bigquery_schema tool to get table schema.
```

✅ **Good**:
```markdown
Use the BigQuery:bigquery_schema tool to get table schema.
```

**理由**: MCP ツールは完全修飾名 `ServerName:tool_name` で参照する必要があります。

---

## 3. プロンプト全体の例

### ❌ 悪い例 - 問題が多い

```yaml
---
name: DataProcessor  # ← PascalCaseは不可
description: I can help you process data  # ← 一人称、トリガーなし
---

# Data Processing

このツールを使うと、いろいろなデータを処理できます。
できればpandasを使ってください。

手順:
1. データを読む
2. 処理する
3. 保存する

参照: `guides\setup.md`  # ← Windows形式パス
```

**問題点**:
1. name が PascalCase（小文字・ハイフンのみ）
2. description が一人称
3. トリガーキーワードがない
4. 内容が曖昧
5. Workflowが不明確
6. 具体例がない
7. Windows形式のパス

---

### ✅ 良い例 - ベストプラクティス準拠

```yaml
---
name: processing-data  # ← gerund形式
description: Processes tabular data using pandas. Use when analyzing CSV/Excel files or performing data transformations.  # ← 第三人称 + トリガー
allowed-tools: [Read, Write, Bash]
---

# Data Processing Skill

pandasを使用したデータ処理の専門知識を提供します。

## クイックスタート

\```python
import pandas as pd

# CSV読み込み
df = pd.read_csv("data.csv")

# 基本的な処理
df_clean = df.dropna().reset_index(drop=True)
\```

## 詳細ガイド

- **[patterns.md](patterns.md)**: 一般的な処理パターン
- **[transformations.md](transformations.md)**: データ変換テクニック
- **[examples.md](examples.md)**: 実装例

## Workflow

Copy this checklist:

\```
Data Processing Progress:
- [ ] Step 1: Load and validate data
- [ ] Step 2: Clean and transform
- [ ] Step 3: Analyze and aggregate
- [ ] Step 4: Export results
\```

**Step 1: Load and validate**

\```python
import pandas as pd

df = pd.read_csv("data.csv")
print(df.info())  # 型とnull確認
\```

**Step 2: Clean and transform**

\```python
# 欠損値処理
df_clean = df.dropna(subset=['important_col'])

# 型変換
df_clean['date'] = pd.to_datetime(df_clean['date'])
\```

**Step 3: Analyze and aggregate**

\```python
# グループ集計
summary = df_clean.groupby('category').agg({
    'value': ['sum', 'mean', 'count']
})
\```

**Step 4: Export results**

\```python
summary.to_csv("results.csv", index=False)
\```

If any step fails, review the error and return to the previous step.
```

**良い点**:
1. name がgerund形式 + 小文字・ハイフン
2. description が第三人称 + トリガー明示
3. クイックスタートで概要把握
4. Progressive Disclosureで詳細は別ファイル
5. Workflowとチェックリスト提供
6. 具体的なコード例
7. フィードバックループあり
8. Unix形式のパス
