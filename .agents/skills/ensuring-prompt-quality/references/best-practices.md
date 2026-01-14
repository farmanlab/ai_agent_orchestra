# Best Practices まとめ

プロンプトエンジニアリングの共通ベストプラクティスと、エージェント固有の差異をまとめた参照資料です。

## 目次

1. [共通ベストプラクティス](#共通ベストプラクティス)
2. [エージェント固有の差異](#エージェント固有の差異)
3. [クイックリファレンス](#クイックリファレンス)

---

## 共通ベストプラクティス

すべてのエージェント（Claude Code, Cursor, GitHub Copilot）に共通する原則です。

### 簡潔性（Conciseness）

**原則**: "Concise is key - the context window is a public good"

- AIが既に知っている情報を繰り返さない
- 各情報の必要性を吟味する
- トークン数を意識する（1トークン ≈ 4文字）

**推奨**:
```markdown
✅ Good - 簡潔:
Use pdfplumber for PDF text extraction.

❌ Bad - 冗長:
PDF (Portable Document Format) is a file format developed by Adobe.
To extract text, you need a library. We recommend pdfplumber...
```

---

### ファイルサイズ制限

**制限値**:
- **500行以下推奨** (Cursor, Claude Skills)
- **2ページ以下** ≈ 1000行 (GitHub Copilot)

**対策**: Progressive Disclosure で分割

---

### Progressive Disclosure（段階的開示）

**原則**: エントリーポイントは簡潔に、詳細は別ファイルで

**推奨構造**:
```
skills/skill-name/
├── SKILL.md         # < 500行: 概要とエントリーポイント
├── patterns.md      # 詳細なパターン集
└── examples.md      # 具体例
```

**重要**:
- 参照の深さは1階層まで
- 100行超のファイルには目次を追加

**公式引用**:
- "Keep SKILL.md body under 500 lines for optimal performance"
- "Keep references one level deep from SKILL.md"
- "For reference files longer than 100 lines, include a table of contents"

---

### 明確性と具体性（Clarity & Specificity）

**原則**: 曖昧な指示ではなく、明確なドキュメントとして

**推奨**:
```markdown
✅ "Use async/await for asynchronous operations"
❌ "You should probably use async/await maybe"
```

**避けるべき表現**:
- "できれば", "なるべく", "可能な限り"
- "consider", "maybe", "perhaps"

**公式引用**:
- "Write rules like clear internal documentation, not vague instructions"
- "Be clear, concise, and specific"

---

### 具体例の提供（Concrete Examples）

**原則**: Before/After 形式で具体的なコード例を含める

**推奨パターン**:
```markdown
❌ **Bad**:
\```typescript
callback((err, data) => { ... })
\```

✅ **Good**:
\```typescript
const data = await fetchData()
\```

**Why**: async/await は可読性が高く、エラーハンドリングが容易
```

**公式引用**:
- "Include concrete examples with referenced files"
- "Provide input/output pairs like in regular prompting"

---

### スコープの適切性（Appropriate Scope）

**原則**: タスク固有ではなく、リポジトリレベルの汎用的な指針

**推奨**:
```markdown
❌ Task-specific:
"Fix the bug in login.js line 42"

✅ Repository-level:
"Authentication logic should validate JWT tokens before processing"
```

**公式引用**:
- "Instructions must not be task specific"

---

### Workflow & Feedback Loops

**原則**: 複雑なタスクには明確なワークフローとチェックリストを提供

**推奨パターン**:
````markdown
## Workflow

Copy this checklist:

\```
Progress:
- [ ] Step 1: Analyze requirements
- [ ] Step 2: Design solution
- [ ] Step 3: Validate design (run validator)
- [ ] Step 4: Implement
\```

**Step 1: Analyze requirements**
[詳細な手順]

**Step 3: Validate design**
Run validation script.

If validation fails, return to Step 2 and revise.
````

**公式引用**:
- "Use workflows for complex tasks"
- "Implement feedback loops (run validator → fix errors → repeat)"
- "Provide a checklist that Claude can copy and check off"

---

### アンチパターン（Anti-patterns）

#### 1. Windows形式のパス

❌ `scripts\helper.py`
✅ `scripts/helper.py`

**公式引用**: "Always use forward slashes in file paths"

#### 2. 時間依存情報

❌ Bad:
```markdown
If you're doing this before August 2025, use old API.
```

✅ Good:
```markdown
## Old patterns
<details>
<summary>Legacy v1 API (deprecated 2025-08)</summary>
...
</details>
```

**公式引用**: "Avoid time-sensitive information"

#### 3. 選択肢の過剰提示

❌ Bad:
```markdown
You can use pypdf, or pdfplumber, or PyMuPDF, or pdf2image...
```

✅ Good:
```markdown
Use pdfplumber for text extraction.
For scanned PDFs, use pdf2image with pytesseract.
```

**公式引用**: "Avoid offering too many options"

#### 4. 深いネスト参照

❌ Bad: `SKILL.md → advanced.md → details.md → info`
✅ Good: `SKILL.md → advanced.md (実際の情報)`

**公式引用**: "Avoid deeply nested references"

---

### 用語の一貫性

**原則**: プロジェクト内で用語を統一

**公式引用**: "Use consistent terminology"

---

### テンプレートと出力形式

**原則**: 期待する出力形式のテンプレートを提供

**推奨パターン**:
````markdown
ALWAYS use this exact template:

\```markdown
# [Title]

## Summary
[One paragraph]

## Details
- Point 1
- Point 2
\```
````

**公式引用**: "Provide templates for output format"

---

## エージェント固有の差異

共通原則の上に、各エージェントが持つ固有の要件です。

### Claude Code 固有

#### Memory Hierarchy（優先度順）

1. **Enterprise Policy**: 組織レベルの設定（最高優先度）
2. **Project Memory**: `CLAUDE.md`（プロジェクトルート）
3. **Project Rules**: `.claude/rules/*.md`
4. **User Memory**: `~/.claude/rules/*.md`

#### 再帰的読み込み

親ディレクトリの `CLAUDE.md` も自動的に読み込まれる。

#### CLAUDE.local.md

`.gitignore` 対象の個人用メモリファイル。チームに共有しない設定を記述。

#### インポート構文

```markdown
@docs/architecture.md        # 相対パスでインポート
@~/.claude/preferences.md    # ホームディレクトリからインポート
```

- 最大5階層までの深さ制限

#### Quick Memory

`#` プレフィックスで即座にメモリに追加:
```
# このプロジェクトでは pnpm を使用
```

#### 命名規則

**Skill名**: gerund形式（-ing）推奨

例:
- `processing-pdfs` ✅
- `analyzing-spreadsheets` ✅
- `pdf-processor` ❌

**公式引用**: "Use gerund form (verb + -ing) for Skill names"

#### Description フィールド

**必須**: 第三人称 + トリガーキーワード

```yaml
❌ Bad - 一人称（英語）:
description: I can help you process data

❌ Bad - 一人称（日本語）:
description: データを処理できます

❌ Bad - 二人称（英語）:
description: You can use this to process data

❌ Bad - 二人称（日本語）:
description: これを使ってデータ処理してください

✅ Good - 第三人称 + トリガー（英語）:
description: Processes Excel files and generates reports. Use when analyzing spreadsheets or .xlsx files.

✅ Good - 第三人称 + トリガー（日本語混在）:
description: Excelファイルを処理してレポートを生成します。スプレッドシート、.xlsxファイルを分析する際に使用。
```

**公式引用**:
- "Always write in third person"
- "Include both what the Skill does and when to use it (triggers)"

#### YAML Frontmatter 制約

```yaml
name: skill-name    # 64文字以内、小文字・数字・ハイフンのみ、予約語禁止
description: ...    # 1024文字以内、空でない、XMLタグなし
```

**公式引用**:
- "name: Maximum 64 characters, lowercase/numbers/hyphens only"
- "description: Maximum 1024 characters, non-empty, no XML tags"

#### MCPツール参照

完全修飾名を使用:

❌ `Use the bigquery_schema tool`
✅ `Use the BigQuery:bigquery_schema tool`

**公式引用**: "Use fully qualified tool names (ServerName:tool_name) for MCP tools"

#### allowed-tools 構文詳細

```yaml
allowed-tools:
  - Read                     # 全ファイル読み取り可
  - Write                    # 全ファイル書き込み可
  - Bash(pattern:npm*)       # npm で始まるコマンドのみ
  - Bash(pattern:git*)       # git で始まるコマンドのみ
```

**パターン構文**: `Bash(pattern:GLOB)` 形式で許可するコマンドを制限

---

### Cursor 固有

#### ディレクトリ構造

```
.cursor/rules/
├── rule-name.mdc    # .mdc または .md ファイル形式
├── rule-name.md
└── another-rule/
    ├── RULE.md        # メインルール
    ├── patterns.md    # 詳細パターン
    └── examples.md    # 具体例
```

#### Subagents

**保存場所**: `.cursor/agents/` または `~/.cursor/agents/`

**メタデータ**:
```yaml
---
name: code-reviewer
description: Reviews code for quality and best practices
model: claude-3-opus         # 使用モデル
readonly: true               # ファイル編集不可
is_background: false         # バックグラウンド実行
---
```

**特徴**:
- コンテキスト分離: 各サブエージェントは独自のコンテキストを持つ
- 並列実行: 複数のサブエージェントを同時実行可能
- 特化した専門性: 特定タスクに特化したエージェントを定義

#### Team Rules

**優先順位**: Team Rules > Project Rules > User Rules

**管理方法**: Cursor ダッシュボードで設定

#### Frontmatter 形式

```yaml
---
description: What this rule does
alwaysApply: false           # description/globs があれば false
globs: "**/*.ts,**/*.tsx"    # カンマ区切り、単一行
---
```

**注意**: `paths` ではなく `globs`

#### Claude Code Rules との違い

Claude Code の `.claude/rules/*.md` では `paths` フィールドを使用:

```yaml
---
description: What this rule does
paths: "**/*.{ts,tsx}"    # カンマ区切り、ブレース展開可
---
```

**共通**: 両方とも単一文字列（YAML配列ではない）

---

### GitHub Copilot 固有

#### ページ制限

2ページ（約1000行）が上限

#### タスク非依存性の強調

Copilot は特にタスク固有の指示を避けることを強調

**公式引用**: "Instructions must not be task specific"

#### Frontmatter 形式

```yaml
---
applyTo: "**/*.ts,**/*.tsx"  # カンマ区切り
---
```

#### Custom Agents テンプレートライブラリ

4つのテンプレートが用意されている:

1. **Your first custom agent**: 初心者向けの基本テンプレート
2. **Implementation planner**: 実装計画を立てるエージェント
3. **Bug fix teammate**: バグ修正を支援するエージェント
4. **Cleanup specialist**: コード整理・リファクタリングを行うエージェント

---

## クイックリファレンス

### 全エージェント共通

| 項目 | 推奨値 |
|-----|--------|
| ファイルサイズ | 500行以下 |
| スコープ | リポジトリレベル（タスク非依存） |
| 構造 | Progressive Disclosure |
| 例 | Before/After 形式の具体例 |
| 明確性 | 曖昧な表現を避ける |
| 簡潔性 | 既知の情報を繰り返さない |
| パス | Unix形式（/） |
| 時間情報 | 時間依存を避ける |
| 選択肢 | デフォルトを明示 |
| 参照深さ | 1階層まで |

### エージェント別の主な違い

| 項目 | Claude Code | Cursor | Copilot |
|-----|------------|--------|---------|
| **最大サイズ** | 500行 (SKILL.md) | 500行 | 2ページ (~1000行) |
| **命名規則** | gerund形式 (-ing) | - | - |
| **description** | 第三人称 + トリガー | - | - |
| **Frontmatter** | name, description, allowed-tools | description, alwaysApply, globs | applyTo |
| **配列形式** | カンマ区切り文字列 | カンマ区切り文字列 | カンマ区切り文字列 |
| **MCPツール** | 完全修飾名必須 | - | - |
| **Rules格納場所** | `.claude/rules/` | `.cursor/rules/` | `.github/` |
| **ルール優先度** | Enterprise > Project > User | Team > Project > User | - |
| **Subagents** | `.agents/agents/` | `.cursor/agents/` | テンプレートライブラリ |
| **特記事項** | Memory Hierarchy, Quick Memory | Team Rules, コンテキスト分離 | タスク非依存性を特に強調 |

---

## 公式ドキュメント

- **Agent Skills (標準仕様)**: https://agentskills.io/specification
- **Claude Code Skills**: https://code.claude.com/docs/en/skills
- **Claude Code Memory**: https://code.claude.com/docs/en/memory
- **Cursor Skills**: https://cursor.com/docs/context/skills
- **Cursor Rules**: https://cursor.com/docs/context/rules
- **GitHub Copilot Agent Skills**: https://code.visualstudio.com/docs/copilot/customization/agent-skills
- **GitHub Copilot Instructions**: https://docs.github.com/en/copilot/how-tos/configure-custom-instructions/add-repository-instructions
