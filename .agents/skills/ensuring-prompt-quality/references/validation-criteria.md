# 検証観点（コンテンツ品質）

プロンプトのコンテンツ品質を評価するための観点（1-7）です。

技術的な要件（メタデータ、命名規則、アンチパターン）については [validation-criteria-technical.md](validation-criteria-technical.md) を参照してください。

## 目次

1. [明確性と具体性](#1-明確性と具体性clarity--specificity)
2. [構造化と可読性](#2-構造化と可読性structure--readability)
3. [具体例の提供](#3-具体例の提供concrete-examples)
4. [スコープの適切性](#4-スコープの適切性appropriate-scope)
5. [Progressive Disclosure](#5-progressive-disclosure段階的開示)
6. [重複と矛盾の回避](#6-重複と矛盾の回避avoid-duplication--conflicts)
7. [Workflow & Feedback Loops](#7-workflow--feedback-loopsワークフローとフィードバックループ)

**技術要件（8-14）**: [validation-criteria-technical.md](validation-criteria-technical.md)

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

```
Task Progress:
- [ ] Step 1: Analyze requirements
- [ ] Step 2: Create implementation plan
- [ ] Step 3: Validate plan (run validate.py)
- [ ] Step 4: Execute implementation
- [ ] Step 5: Verify output
```

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
