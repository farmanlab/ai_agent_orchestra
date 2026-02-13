---
name: checking-references
description: Checks for broken file references in skills, agents, rules, and commands. Use when validating internal links after file reorganization or migration.
---

# Checking References Skill

`.agents/` 配下のファイル参照が有効かどうかを検証するスキルです。

## Workflow

参照チェック時にこのチェックリストをコピー:

```
Reference Check:
- [ ] Step 1: 対象パスを確認
- [ ] Step 2: スクリプトを実行
- [ ] Step 3: 結果を確認
- [ ] Step 4: 無効な参照を修正
```

### Step 1: 対象パスを確認

検証対象のパスを決定。省略時は `.agents/` 全体を検証。

```bash
# 対象パスの例
.agents/                              # 全体
.agents/skills/                       # skills のみ
.agents/skills/ensuring-prompt-quality/ # 特定スキル
```

### Step 2: スクリプトを実行

```bash
bash {path}/scripts/check-references.sh [target_dir]
```

**引数:**
- `target_dir` (省略可): 検証対象のパス（デフォルト: `.agents`）

### Step 3: 結果を確認

スクリプトは以下を出力:

| 項目 | 説明 |
|------|------|
| Files checked | 検証したMarkdownファイル数 |
| References found | 検出した参照リンク数 |
| Valid | 有効な参照数 |
| Invalid | 無効な参照数 |

**正常時:** `All references are valid` と表示。

**エラー時:** 無効な参照の一覧を表示:
```
FILE:LINE | REFERENCE | RESOLVED PATH
```

### Step 4: 無効な参照を修正

無効な参照が見つかった場合:

1. **ファイルが移動された場合**: 参照パスを更新
2. **ファイルが削除された場合**: 参照を削除
3. **ファイル名が変更された場合**: 新しい名前に更新

If invalid references are found, fix them and re-run Step 2 to verify.

## 検出対象の参照パターン

| パターン | 例 |
|---------|-----|
| Markdown リンク | `[text](path/to/file.md)` |
| 参照リンク | `[text]: path/to/file.md` |
| インラインパス | `` `path/to/file.md` `` |
| インポート構文 | `@path/to/file.md` |

**抽出対象:**
- 相対パス（`./`, `../`, `references/` など）
- 絶対パス（`/Users/...`）

**除外対象:**
- 外部URL（`http://`, `https://`）
- アンカーのみ（`#section`）
- コードブロック内の例示パス
- プレースホルダー（`skill-name`, `path/to`, `your-`, `my-`, `example`）

## 対象ファイル

以下のディレクトリ内の Markdown ファイルを検証:

```bash
{target_dir}/skills/**/*.md
{target_dir}/agents/**/*.md
{target_dir}/rules/**/*.md
{target_dir}/commands/**/*.md
```
