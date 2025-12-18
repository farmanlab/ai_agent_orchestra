# 検証観点

プロンプト品質を評価するための14の検証観点です。

## 目次

1. [明確性と具体性](#1-明確性と具体性clarity--specificity)
2. [構造化と可読性](#2-構造化と可読性structure--readability)
3. [具体例の提供](#3-具体例の提供concrete-examples)
4. [スコープの適切性](#4-スコープの適切性appropriate-scope)
5. [Progressive Disclosure](#5-progressive-disclosure段階的開示)
6. [重複と矛盾の回避](#6-重複と矛盾の回避avoid-duplication--conflicts)
7. [Workflow & Feedback Loops](#7-workflow--feedback-loopsワークフローとフィードバックループ)
8. [ファイル命名とパス適用](#8-ファイル命名とパス適用naming--path-targeting)
9. [アクション指向](#9-アクション指向action-oriented)
10. [メタデータの完全性](#10-メタデータの完全性metadata-completeness)
11. [トーンと文体](#11-トーンと文体tone--style)
12. [Template & Examples Pattern](#12-template--examples-patternテンプレートと例)
13. [Anti-patterns Detection](#13-anti-patterns-detectionアンチパターン検出)
14. [Conciseness](#14-conciseness簡潔性)

---

## 1. 明確性と具体性（Clarity & Specificity）

**チェック項目**:
- [ ] 曖昧な表現（「なるべく」「できれば」など）が過度に使われていないか
- [ ] 具体的なアクションが示されているか
- [ ] 「何を」「どのように」が明確か

**公式推奨**:
- Cursor: "Write rules like clear internal documentation, not vague instructions"
- Copilot: "Be clear, concise, and specific"
- Claude: 具体的な例とコンテキストを提供

**チェック方法**:
```bash
# 曖昧な表現パターンを検索
grep -i "できれば\|なるべく\|可能な限り\|consider\|maybe\|perhaps" [file]
```

---

## 2. 構造化と可読性（Structure & Readability）

**チェック項目**:
- [ ] 適切な見出し階層（H1, H2, H3）が使われているか
- [ ] セクションが論理的に整理されているか
- [ ] リスト、コードブロック、表などが適切に使われているか
- [ ] 500行以下に収まっているか（Cursor推奨）

**公式推奨**:
- Cursor: "Keep rules under 500 lines"
- Copilot: "Instructions must be no longer than 2 pages"

**推奨構造**:
```markdown
## Section Title

### Subsection

- Clear bullet points
- Concrete actions

#### Example
\```code
example here
\```
```

---

## 3. 具体例の提供（Concrete Examples）

**チェック項目**:
- [ ] コード例が含まれているか
- [ ] Before/After の比較があるか
- [ ] 実際のユースケースが示されているか

**公式推奨**:
- Cursor: "Include concrete examples with referenced files"
- Copilot: "Provide specific examples"

**推奨パターン**:
```markdown
### Good Example ✅
\```code
// good code
\```

### Bad Example ❌
\```code
// bad code
\```

### Why
Explanation...
```

---

## 4. スコープの適切性（Appropriate Scope）

**チェック項目**:
- [ ] タスク固有の指示になっていないか
- [ ] リポジトリ/プロジェクトレベルの指針か
- [ ] 複数のシナリオに適用可能か

**公式推奨**:
- Copilot: "Instructions must not be task specific"
- 再利用可能で汎用的な指針であるべき

**アンチパターン**:
```markdown
❌ "Fix the bug in login.js line 42"
✅ "Authentication logic should validate tokens before processing"
```

---

## 5. Progressive Disclosure（段階的開示）

**チェック項目**:
- [ ] エントリーポイント（SKILL.md など）は簡潔か（500行以下推奨）
- [ ] 詳細情報は別ファイルに分離されているか
- [ ] 参照リンクが適切に使われているか
- [ ] **参照の深さは1階層までか**（avoid deeply nested references）
- [ ] **100行超のファイルに目次（Table of Contents）があるか**

**公式推奨**:
- Claude Skills: "Keep SKILL.md body under 500 lines for optimal performance"
- Claude Skills: "Keep references one level deep from SKILL.md"
- Claude Skills: "For reference files longer than 100 lines, include a table of contents"

**推奨構造**:
```
skills/
└── skill-name/
    ├── SKILL.md          # 概要とエントリーポイント（< 500行）
    ├── patterns.md       # 詳細なパターン集
    ├── checklist.md      # チェックリスト
    └── examples/         # 具体例集
```

**アンチパターン（深すぎる参照）**:
```markdown
❌ Bad: Too deep
# SKILL.md → advanced.md → details.md → actual info

✅ Good: One level deep
# SKILL.md → advanced.md (actual info)
#         → reference.md (actual info)
#         → examples.md (actual info)
```

**チェック方法**:
```bash
# 参照チェーン深さの確認
grep -n "\[.*\](.*\.md)" [file]

# 100行超ファイルの目次確認
head -20 [file] | grep -i "contents\|table of contents"
```

---

## 6. 重複と矛盾の回避（Avoid Duplication & Conflicts）

**チェック項目**:
- [ ] 複数ファイルで同じ内容が重複していないか
- [ ] 矛盾する指示が存在しないか
- [ ] DRY原則が守られているか

**公式推奨**:
- Copilot: "Avoid potential conflicts between instructions"

**チェック方法**:
```bash
# 重複する可能性のあるキーフレーズを検索
grep -r "must\|should\|always\|never" .agents/ | sort | uniq -c | sort -rn
```

---

## 7. Workflow & Feedback Loops（ワークフローとフィードバックループ）

**チェック項目**:
- [ ] 複雑なタスクに明確なワークフローがあるか
- [ ] チェックリスト形式が活用されているか
- [ ] バリデーション→修正→繰り返しのループが含まれているか
- [ ] 各ステップが実行可能で明確か

**公式推奨**:
- Claude Skills: "Use workflows for complex tasks"
- Claude Skills: "Implement feedback loops (run validator → fix errors → repeat)"
- Claude Skills: "Provide a checklist that Claude can copy and check off"

**推奨パターン**:
````markdown
## Workflow

Copy this checklist and track progress:

\```
Task Progress:
- [ ] Step 1: Analyze requirements
- [ ] Step 2: Create implementation plan
- [ ] Step 3: Validate plan (run validate.py)
- [ ] Step 4: Execute implementation
- [ ] Step 5: Verify output
\```

**Step 1: Analyze requirements**
[Detailed instructions...]

**Step 2: Create implementation plan**
[Detailed instructions...]

If validation fails at Step 3, return to Step 2 and revise.
````

**チェック方法**:
```bash
# ワークフローチェックリストの存在確認
grep -n "- \[ \]" [file]
grep -n "Step [0-9]:" [file]

# フィードバックループの存在確認
grep -ni "if.*fail\|validate\|repeat\|return to" [file]
```

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
agents: [claude, cursor, copilot]
priority: 80  # rules のみ
---
```

**アンチパターン（Description）**:
```yaml
❌ Bad - 一人称（英語）:
description: I can help you process Excel files

❌ Bad - 一人称（日本語）:
description: データを処理できます

❌ Bad - 二人称（英語）:
description: You can use this to process Excel files

❌ Bad - 二人称（日本語）:
description: これを使ってデータ処理してください

❌ Bad - トリガーなし:
description: Processes data
description: データを処理

✅ Good - 第三人称 + トリガー（英語）:
description: Processes Excel files and generates reports. Use when analyzing spreadsheets, tabular data, or .xlsx files.

✅ Good - 第三人称 + トリガー（日本語混在）:
description: Excelファイルを処理してレポートを生成します。スプレッドシートやtabular data、.xlsxファイルを分析する際に使用。
```

**チェック方法**:
```bash
# 一人称・二人称チェック（英語）
grep -n "I can\|I will\|I am\|You can\|You should\|You are" [file]

# 一人称・二人称チェック（日本語）
grep -n "できます\|します（主語なし）\|私は\|弊社は\|してください\|あなたは\|御社は" [file]

# より包括的なチェック
grep -n "I \|You \|できます\|してください" [file]

# nameフィールド検証
# - 64文字以内
# - 小文字・数字・ハイフンのみ
# - "anthropic", "claude"を含まない

# descriptionフィールド検証
# - 1024文字以内
# - XMLタグなし（<, >の検出）
grep -n "<\|>" [file]  # XMLタグ検出
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

\```markdown
# [Analysis Title]

## Executive summary
[One-paragraph overview]

## Key findings
- Finding 1 with data
- Finding 2 with data
\```

## Examples

**Example 1:**
Input: Added user authentication with JWT
Output:
\```
feat(auth): implement JWT-based authentication
Add login endpoint and token validation
\```
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

**公式推奨**:
- Claude Skills: "Always use forward slashes in file paths"
- Claude Skills: "Avoid time-sensitive information"
- Claude Skills: "Avoid offering too many options"
- Claude Skills: "Use fully qualified tool names (ServerName:tool_name) for MCP tools"

**アンチパターン例**:
```markdown
❌ Windows-style paths:
scripts\helper.py
reference\guide.md

✅ Unix-style paths:
scripts/helper.py
reference/guide.md

❌ Time-sensitive:
If you're doing this before August 2025, use old API.
After August 2025, use new API.

✅ Use "old patterns" section:
## Old patterns
<details>
<summary>Legacy v1 API (deprecated 2025-08)</summary>
...
</details>

❌ Too many options:
You can use pypdf, or pdfplumber, or PyMuPDF, or pdf2image...

✅ Provide default:
Use pdfplumber for text extraction.
For scanned PDFs, use pdf2image with pytesseract.

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
grep -ni "before.*20[0-9][0-9]\|after.*20[0-9][0-9]\|until.*20[0-9][0-9]" [file]

# 選択肢過多検出
grep -n "or.*or.*or" [file]

# MCPツール参照確認
grep -n "Use the.*tool" [file]
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
- Claude Skills: "Challenge each piece of information"

**良い例vs悪い例**:
````markdown
✅ Good - Concise (~50 tokens):
## Extract PDF text

Use pdfplumber:

\```python
import pdfplumber
with pdfplumber.open("file.pdf") as pdf:
    text = pdf.pages[0].extract_text()
\```

❌ Bad - Too verbose (~150 tokens):
## Extract PDF text

PDF (Portable Document Format) files are common files containing
text and images. To extract text, you need a library. Many libraries
exist, but we recommend pdfplumber because it's easy and handles
most cases. First install via pip, then use code below...
````

**チェック方法**:
```bash
# トークン数推定（文字数÷4）
wc -c [file]  # 文字数を4で割る

# 冗長パターン検出（英語）
grep -ni "you need to understand\|it is important to note\|please note that\|as you know" [file]

# 冗長パターン検出（日本語）
grep -n "ご存知の通り\|言うまでもなく\|注意してください\|理解する必要があります\|重要なことに\|念のため" [file]

# 両言語対応の簡易チェック
grep -ni "you need\|you must\|important to\|する必要があります\|重要です" [file]
```
