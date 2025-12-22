---
name: ensuring-prompt-quality
description: Provides expertise in prompt engineering best practices for Claude Code, Cursor, and GitHub Copilot. Use after creating or editing rules, skills, agents in .agents/ directory for self-review. Also use when asked to 品質チェック, プロンプト検証, or レビュー prompt files.
compatibility: Claude Code
allowed-tools: Read Grep Glob WebFetch WebSearch
---

# Prompt Quality Skill

このスキルは、AI エージェント向けプロンプト（rules, skills, agents, commands）の作成と品質検証に関する専門知識を提供します。

## 対象エージェント

- **Claude Code**: Skills, Agents, Rules, Commands
- **Cursor**: Rules (`.cursor/rules/`)
- **GitHub Copilot**: Instructions (`.github/copilot-instructions.md`, `AGENTS.md`)

## 公式ドキュメント

最新のベストプラクティスは以下の公式ドキュメントを参照：

- **Agent Skills (標準仕様)**: https://agentskills.io/specification
- **Claude Code Skills**: https://code.claude.com/docs/en/skills
- **Claude Code Memory**: https://code.claude.com/docs/en/memory
- **Cursor Skills**: https://cursor.com/docs/context/skills
- **Cursor Rules**: https://cursor.com/docs/context/rules
- **GitHub Copilot Agent Skills**: https://code.visualstudio.com/docs/copilot/customization/agent-skills
- **GitHub Copilot Instructions**: https://docs.github.com/en/copilot/how-tos/configure-custom-instructions/add-repository-instructions

## 核心原則

### 1. Conciseness（簡潔性）

> "Concise is key - the context window is a public good"

- Claudeが既に知っている情報を繰り返さない
- 各情報の必要性を吟味する
- トークン数を意識する（1トークン ≈ 4文字）

### 2. Progressive Disclosure（段階的開示）

- エントリーポイントは簡潔に（500行以下推奨）
- 詳細情報は別ファイルに分離
- 参照の深さは1階層まで
- 100行超のファイルには目次を追加

### 3. 第三人称の原則

- description は必ず第三人称で記述
- "I can", "You can" を避ける
- "何をするか" と "いつ使うか" を明示

### 4. アクション指向

- 動詞から始まる具体的な指示
- 実行可能なステップを提示
- チェックリスト形式を活用

## ファイルサイズ制限

| エージェント | 制限 | 備考 |
|------------|------|------|
| Cursor | 500行 | rules 推奨 |
| Copilot | 2ページ (~1000行) | instructions 上限 |
| Claude Skills | 500行 | SKILL.md 推奨 |

## 参照ファイル

詳細な検証基準とベストプラクティスは以下を参照：

- **[validation-criteria.md](references/validation-criteria.md)**: 検証観点1-7（コンテンツ品質）
- **[validation-criteria-technical.md](references/validation-criteria-technical.md)**: 検証観点8-14（技術要件）
- **[best-practices.md](references/best-practices.md)**: 公式推奨事項まとめ
- **[examples.md](references/examples.md)**: 良い例・悪い例集（基本パターン）
- **[examples-antipatterns.md](references/examples-antipatterns.md)**: アンチパターンと全体例

## Workflow

プロンプトの作成・検証時にこのチェックリストをコピーして進捗を追跡してください：

```
Prompt Quality Workflow:
- [ ] Step 1: 要件を明確化（目的、対象、トリガー）
- [ ] Step 2: 既存パターンを調査（同様のファイルを確認）
- [ ] Step 3: メタデータを設計（name, description, paths/globs）
- [ ] Step 4: コンテンツを作成（具体例、Workflow含む）
- [ ] Step 5: 品質チェック（14観点で検証）
- [ ] Step 6: ファイルサイズ確認（500行以下）
- [ ] Step 7: 公式ドキュメント準拠を確認
```

**Step 1: 要件を明確化**
- 何をするプロンプトか
- いつ使うか（トリガー）
- どのエージェント向けか

**Step 2: 既存パターンを調査**
- Glob/Grep で類似ファイルを検索
- 既存の構造とスタイルを確認

**Step 3: メタデータを設計**
- name: 小文字・ハイフン、64文字以内
- description: 第三人称 + トリガー、1024文字以内
- paths/globs: 対象ファイルパターン

**Step 4: コンテンツを作成**
- Before/After 形式の具体例を含める
- 複雑なタスクには Workflow を追加
- 100行超なら目次を追加

**Step 5: 品質チェック**
- [validation-criteria.md](references/validation-criteria.md) の14観点で検証
- アンチパターンがないか確認
- 冗長な説明を削除

**Step 6: ファイルサイズ確認**
- 500行以下か確認
- 超過する場合は Progressive Disclosure で分割

**Step 7: 公式ドキュメント準拠を確認**
- 最新の公式ドキュメントと照合
- エージェント固有の要件を満たしているか

If validation fails at Step 5, return to Step 4 and revise content.

## メタデータ要件

### Claude Skills/Agents

```yaml
---
name: skill-name              # 64文字以内、小文字・数字・ハイフンのみ
description: Third-person description. Use when...  # 1024文字以内、第三人称、トリガー含む
allowed-tools: [Read, Write]  # Skills のみ
tools: [Read, Write]          # Agents のみ
---
```

### Claude Code Rules (`.claude/rules/`)

```yaml
---
paths: src/api/**/*.ts       # パス固有のルール（グロブパターン）
---

# API 開発ルール
- All API endpoints must include input validation
```

**インポート構文:**
```markdown
@docs/architecture.md        # 相対パス
@~/.claude/preferences.md    # ホームディレクトリ
```

### Cursor Rules

```yaml
---
description: What this rule does
alwaysApply: false           # description/globs があれば false
globs: "**/*.ts"             # カンマ区切り、単一行
---
```

**ルールタイプ:**

| タイプ | 適用条件 | 設定 |
|--------|---------|------|
| Always Apply | 全チャットセッション | `alwaysApply: true` |
| Apply Intelligently | Agent判断（説明文参考） | `description` のみ |
| Apply to Specific Files | ファイルパターンマッチ | `globs` 指定 |
| Apply Manually | @メンション時 | 両方なし |

### GitHub Copilot

```yaml
---
applyTo: "**/*.ts"           # カンマ区切り
excludeAgent: "code-review"  # code-review or coding-agent を除外（オプション）
---
```

**プロンプトファイル** (Preview):
```
.github/prompts/
└── my-prompt.prompt.md      # ファイル参照: #file:path
```

## 使用上の注意

### アンチパターン

- ❌ Windows形式のパス（`\` → `/` を使用）
- ❌ 時間依存情報（"before 2025" など）
- ❌ 選択肢の過剰提示（デフォルトを明示）
- ❌ 深いネスト参照（2階層以上）

### 推奨パターン

- ✅ Before/After 形式の具体例
- ✅ ワークフローチェックリスト
- ✅ フィードバックループ
- ✅ 出力テンプレート
