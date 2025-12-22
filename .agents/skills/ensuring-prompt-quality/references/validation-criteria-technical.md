# 検証観点（技術要件）

プロンプトの技術的な品質を評価するための観点（8-14）です。

基本的なコンテンツ品質については [validation-criteria.md](validation-criteria.md) を参照してください。

## 目次

1. [ファイル命名とパス適用](#8-ファイル命名とパス適用naming--path-targeting)
2. [アクション指向](#9-アクション指向action-oriented)
3. [メタデータの完全性](#10-メタデータの完全性metadata-completeness)
4. [トーンと文体](#11-トーンと文体tone--style)
5. [Template & Examples Pattern](#12-template--examples-patternテンプレートと例)
6. [Anti-patterns Detection](#13-anti-patterns-detectionアンチパターン検出)
7. [Conciseness](#14-conciseness簡潔性)

---

## 8. ファイル命名とパス適用（Naming & Path Targeting）

**チェック項目**:
- [ ] ファイル名が内容を明確に表しているか
- [ ] Skill名はgerund形式（-ing）を使用しているか
- [ ] paths/globs が適切に設定されているか
- [ ] 対象範囲が明確か

**公式推奨**:
- Claude Skills: "Use gerund form (verb + -ing) for Skill names"
- Examples: `processing-pdfs`, `analyzing-spreadsheets`, `managing-databases`

**推奨パターン**:
```yaml
# Skills - gerund form推奨
✅ Good:
- processing-pdfs
- analyzing-spreadsheets
- managing-databases
- testing-code

❌ Avoid:
- helper
- utils
- tools
- documents

# Rules
paths:
  - "**/*.ts"
  - "**/*.tsx"

# 明確なファイル名
architecture.md  # ✅ 明確
rules.md        # ❌ 曖昧
```

---

## 9. アクション指向（Action-Oriented）

**チェック項目**:
- [ ] 動詞から始まる指示が多いか
- [ ] チェックリスト形式が活用されているか
- [ ] 実行可能なステップが示されているか

**推奨パターン**:
```markdown
## Before Implementation
1. 要件の理解を確認
2. 影響範囲を特定
3. 既存コードのパターンを確認

## Code Quality
- 自己文書化コードを心がける
- マジックナンバー禁止
- 適切なエラーハンドリング
```

---

## 10. メタデータの完全性（Metadata Completeness）

**チェック項目**:
- [ ] 必須フィールドが全て存在するか
- [ ] **nameフィールド: 64文字以内、小文字・数字・ハイフンのみ、予約語なし**
- [ ] **descriptionフィールド: 1024文字以内、空でない、XMLタグなし**
- [ ] **descriptionは第三人称で記述されているか**（"I can", "You can"を避ける）
- [ ] **descriptionにトリガーキーワードが含まれているか**
- [ ] agents フィールドが適切か

**公式推奨**:
- Claude Skills: "name: Maximum 64 characters, lowercase/numbers/hyphens only"
- Claude Skills: "description: Maximum 1024 characters, non-empty, no XML tags"
- Claude Skills: "Always write in third person"
- Claude Skills: "Include both what the Skill does and when to use it (triggers)"

**必須メタデータ**:
```yaml
---
name: rule-name  # 64文字以内、小文字・数字・ハイフン、予約語禁止
description: Processes Excel files and generates reports. Use when analyzing spreadsheets or .xlsx files.  # 第三人称、トリガー含む、1024文字以内
---
```

**アンチパターン（Description）**:
```yaml
❌ Bad - 一人称:
description: I can help you process Excel files

❌ Bad - 二人称:
description: You can use this to process Excel files

❌ Bad - トリガーなし:
description: Processes data

✅ Good - 第三人称 + トリガー:
description: Processes Excel files and generates reports. Use when analyzing spreadsheets or .xlsx files.
```

**チェック方法**:
```bash
# 一人称・二人称チェック
grep -n "I can\|I will\|You can\|You should" [file]

# XMLタグ検出
grep -n "<\|>" [file]
```

---

## 11. トーンと文体（Tone & Style）

**チェック項目**:
- [ ] 命令形が適切に使われているか
- [ ] プロフェッショナルなトーンか
- [ ] 一貫した文体か

**推奨**:
```markdown
✅ "Use async/await for asynchronous operations"
❌ "You should probably use async/await maybe"
```

---

## 12. Template & Examples Pattern（テンプレートと例）

**チェック項目**:
- [ ] 出力フォーマットのテンプレートが提供されているか
- [ ] 入力/出力のペア例があるか
- [ ] 例は具体的で実用的か

**公式推奨**:
- Claude Skills: "Provide templates for output format"
- Claude Skills: "Provide input/output pairs like in regular prompting"

**推奨パターン**:
````markdown
## Report structure template

ALWAYS use this exact template:

```markdown
# [Analysis Title]

## Executive summary
[One-paragraph overview]

## Key findings
- Finding 1 with data
- Finding 2 with data
```
````

**チェック方法**:
```bash
# テンプレート提供確認
grep -ni "template\|format\|structure" [file]

# 入出力例確認
grep -n "Example\|Input:\|Output:" [file]
```

---

## 13. Anti-patterns Detection（アンチパターン検出）

**チェック項目**:
- [ ] Windows形式のパス（バックスラッシュ）を使用していないか
- [ ] 時間依存情報（日付、バージョン指定など）が含まれていないか
- [ ] 選択肢を過度に提示していないか
- [ ] MCPツール参照時に完全修飾名を使用しているか

**アンチパターン例**:
```markdown
❌ Windows-style paths:
scripts\helper.py

✅ Unix-style paths:
scripts/helper.py

❌ Time-sensitive:
If you're doing this before August 2025, use old API.

✅ Use "old patterns" section:
<details>
<summary>Legacy v1 API (deprecated)</summary>
...
</details>

❌ Too many options:
You can use pypdf, or pdfplumber, or PyMuPDF...

✅ Provide default:
Use pdfplumber for text extraction.

❌ MCP tool without server name:
Use the bigquery_schema tool

✅ MCP tool with fully qualified name:
Use the BigQuery:bigquery_schema tool
```

**チェック方法**:
```bash
# Windows形式パス検出
grep -n "\\\\" [file]

# 時間依存情報検出
grep -ni "before.*20[0-9][0-9]\|after.*20[0-9][0-9]" [file]

# 選択肢過多検出
grep -n "or.*or.*or" [file]
```

---

## 14. Conciseness（簡潔性）

**チェック項目**:
- [ ] 冗長な説明を避けているか
- [ ] Claudeが既に知っている情報を再説明していないか
- [ ] トークン数が適切か（1トークン ≈ 4文字）

**公式推奨**:
- Claude Skills: "Concise is key - the context window is a public good"
- Claude Skills: "Only add context Claude doesn't already have"

**良い例vs悪い例**:
````markdown
✅ Good - Concise (~50 tokens):
## Extract PDF text

Use pdfplumber:

```python
import pdfplumber
with pdfplumber.open("file.pdf") as pdf:
    text = pdf.pages[0].extract_text()
```

❌ Bad - Too verbose (~150 tokens):
## Extract PDF text

PDF (Portable Document Format) files are common files containing
text and images. To extract text, you need a library...
````

**チェック方法**:
```bash
# トークン数推定（文字数÷4）
wc -c [file]

# 冗長パターン検出
grep -ni "you need to understand\|it is important to note" [file]
```
