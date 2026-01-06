---
name: team-knowledge-extraction
description: Extracts team knowledge from PR reviews and Issue discussions. Used by GitHub Actions workflow for automated knowledge capture.
---

# Team Knowledge Extraction

チーム活動（PRレビュー、Issue議論）から有用なパターンを抽出し、rules/skills/agents/commands として提案する。

## 目次

1. [Input Data](#input-data)
2. [Detection Criteria](#detection-criteria)
3. [Constraints](#constraints)
4. [Output Formats](#output-formats)
5. [Execution Steps](#execution-steps)

## Input Data

- `/tmp/pr_data.json` - PRレビュー・コメント
- `/tmp/issues.json` - Issue議論
- `/tmp/agents_changes.txt` - 最近の.agents/変更
- `/tmp/existing_rules.txt` - 既存ルール名（重複回避用）
- `/tmp/existing_skills.txt` - 既存スキル名
- `/tmp/existing_agents.txt` - 既存エージェント名
- `/tmp/existing_commands.txt` - 既存コマンド名

## Detection Criteria

### RULES - コーディング規約・標準
- 繰り返し指摘（同じフィードバック2回以上）
- 明示的な規約（"always", "never", "must", "禁止", "必ず"）
- エラーパターンと修正方法

**検出例**:
```
// PRレビューコメント（2回出現）
> "Use pnpm instead of npm" - @reviewer1 (PR #42)
> "Please use pnpm" - @reviewer1 (PR #58)
```
→ 抽出: `package-manager.md` - "Use pnpm for all package operations"

### SKILLS - 再利用可能なワークフロー
- 複数ステップのプロセス（3ステップ以上）
- チェックリスト形式の詳細な手順

**検出例**:
```
// Issue議論で詳細な手順が説明された
> "デプロイ手順: 1. テスト実行 2. ビルド 3. S3アップロード 4. CloudFront invalidation"
```
→ 抽出: `deploying-to-production/SKILL.md`

### AGENTS - 自律的なタスクハンドラー
- 複数ツールを必要とする複雑なタスク
- 専門的な役割（レビュアー、アナライザー等）

**検出例**:
```
// PRで繰り返し要求されたタスク
> "セキュリティチェックを実行して" (PR #30, #45, #52)
```
→ 抽出: `security-checker.md` - tools: [Read, Grep, Bash]

### COMMANDS - ユーザー起動の操作
- 頻繁にリクエストされる操作
- 引数を持つCLIスタイルのタスク

**検出例**:
```
// Issueで繰り返しリクエスト
> "/release v1.2.3 を実行したい"
> "リリースノート生成コマンドがほしい"
```
→ 抽出: `release.md` - `/release <version>`

## Constraints

1. 1回あたり最大3件の提案
2. existing_*.txt に類似が存在する場合はスキップ
3. 一般的なベストプラクティスはスキップ - プロジェクト固有のみ
4. 具体的なエビデンス（引用）が必要

## Output Formats

各提案について、実際のファイル + メタデータJSONを作成する。

### Rules (.agents/rules/{name}.md)

```markdown
---
description: "Enforces X. Use when Y."
paths: "**/*.kt"  # optional
---

# Title

Description.

## Requirements
- Requirement 1

## Examples

### Bad
\`\`\`code
bad example
\`\`\`

### Good
\`\`\`code
good example
\`\`\`
```

### Skills (.agents/skills/{name}/SKILL.md)

```markdown
---
name: skill-name
description: "Does X. Use when Y."
---

# Title

## Workflow
\`\`\`
- [ ] Step 1: ...
- [ ] Step 2: ...
\`\`\`
```

### Agents (.agents/agents/{name}.md)

```markdown
---
name: agent-name
description: "Does X. Use when Y."
tools: [Read, Write, Grep, Glob]
---

# Agent Title

## Role
Description of role.

## Tasks
1. Task 1
2. Task 2

## Process
### Step 1: ...
```

### Commands (.agents/commands/{name}.md)

```markdown
---
name: command-name
description: "Does X. Use when Y."
---

# Command Title

## Usage
\`\`\`bash
/command-name <arg>
\`\`\`

## Process
1. Step 1
2. Step 2
```

### Metadata (/tmp/proposals/{name}.json)

```json
{
  "type": "rule|skill|agent|command",
  "name": "kebab-case-name",
  "title": "Human Readable Title",
  "file_path": ".agents/{type}s/{name}.md",
  "source": "PR #123, Issue #45",
  "confidence": "high|medium",
  "detection_reason": "Why extracted...",
  "evidence": [{"quote": "...", "author": "@user", "source": "PR #123"}],
  "occurrences": 3,
  "contributors": ["@user1"]
}
```

## Execution Steps

Copy this checklist:

```
Progress:
- [ ] Step 1: mkdir -p /tmp/proposals
- [ ] Step 2: Input データを読み込み分析
- [ ] Step 3: 各提案についてファイル作成
- [ ] Step 4: validate.sh を実行して検証
- [ ] Step 5: 結果を報告
```

**Step 1: 準備**
```bash
mkdir -p /tmp/proposals
```

**Step 2: 分析**
- `/tmp/pr_data.json` と `/tmp/issues.json` を読み込み
- Detection Criteria に基づいてパターンを抽出
- 既存ファイルリストと照合して重複を除外

**Step 3: ファイル作成**
各提案について:
- `.agents/{type}s/{name}.md` に実際のファイルを作成
- `/tmp/proposals/{name}.json` にメタデータJSONを作成

**Step 4: 検証**
```bash
.agents/sync/validate.sh
```

**If validation fails:**
- エラーメッセージを確認
- 該当ファイルのフォーマットを修正
- Step 4 を再実行

**Step 5: 報告**
作成したファイルとメタデータの一覧を出力
