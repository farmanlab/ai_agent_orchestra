---
name: check-references
description: Checks for broken file references in skills, agents, rules, and commands. Use when validating internal links after reorganization.
---

# Check References Command

`.agents/` 配下のファイル参照が有効かどうかを検証するコマンドです。

## Usage

```bash
/check-references [path]
```

**Arguments:**
- `path` (省略可): 検証対象のパス（省略時は `.agents/` 全体）

**Examples:**
```bash
/check-references
/check-references .agents/skills/
/check-references .agents/skills/ensuring-prompt-quality/
```

## Process

### Step 1: 対象ファイルを収集

以下のディレクトリ内の Markdown ファイルを収集：

```bash
Glob: pattern=".agents/skills/**/*.md"
Glob: pattern=".agents/agents/**/*.md"
Glob: pattern=".agents/rules/**/*.md"
Glob: pattern=".agents/commands/**/*.md"
```

### Step 2: 参照パスを抽出

各ファイルから以下のパターンで参照を抽出：

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
- コードブロック内の例示

### Step 3: パスの存在確認

抽出した各パスについて：

1. 参照元ファイルの位置を基準に相対パスを解決
2. ファイルの存在を確認
3. 存在しない場合はエラーとして記録

```bash
# パス解決例
# 参照元: .agents/skills/my-skill/SKILL.md
# 参照: references/patterns.md
# 解決後: .agents/skills/my-skill/references/patterns.md
```

### Step 4: 結果をレポート

## Output Format

### 正常時

```markdown
## Reference Check Report

**対象:** .agents/
**検証日:** YYYY-MM-DD

### Summary

| 項目 | 件数 |
|------|------|
| 検証ファイル数 | 42 |
| 参照リンク数 | 128 |
| 有効 | 128 |
| 無効 | 0 |

✅ **すべての参照が有効です**
```

### エラー時

```markdown
## Reference Check Report

**対象:** .agents/
**検証日:** YYYY-MM-DD

### Summary

| 項目 | 件数 |
|------|------|
| 検証ファイル数 | 42 |
| 参照リンク数 | 128 |
| 有効 | 125 |
| 無効 | 3 |

### ❌ 無効な参照

| ファイル | 参照パス | 解決後パス |
|---------|---------|-----------|
| skills/my-skill/SKILL.md:15 | `references/old-file.md` | .agents/skills/my-skill/references/old-file.md |
| agents/my-agent.md:42 | `../skills/missing/SKILL.md` | .agents/skills/missing/SKILL.md |
| rules/my-rule.md:8 | `templates/gone.md` | .agents/rules/templates/gone.md |

### 修正方法

1. ファイルが移動された場合: 参照パスを更新
2. ファイルが削除された場合: 参照を削除
3. ファイル名が変更された場合: 新しい名前に更新
```

## Error Handling

**ファイルが見つからない:**
```
対象ディレクトリが存在しません: .agents/skills/
```

**パーミッションエラー:**
```
読み取り権限がありません: .agents/private/secret.md
```

## Implementation

以下のスクリプトを使用して検証を実行：

```bash
#!/bin/bash
# .agents/scripts/check-references.sh

TARGET_DIR="${1:-.agents}"

echo "## Reference Check Report"
echo ""
echo "**対象:** $TARGET_DIR"
echo "**検証日:** $(date +%Y-%m-%d)"
echo ""

# Find all markdown files
FILES=$(find "$TARGET_DIR" -name "*.md" -type f 2>/dev/null)
FILE_COUNT=$(echo "$FILES" | grep -c ".")

TOTAL_REFS=0
VALID_REFS=0
INVALID_REFS=0
ERRORS=""

for file in $FILES; do
  DIR=$(dirname "$file")

  # Extract markdown links: [text](path)
  REFS=$(grep -oE '\[([^\]]+)\]\(([^)]+)\)' "$file" | grep -oE '\]\([^)]+\)' | sed 's/](//' | sed 's/)//' | grep -v '^http' | grep -v '^#')

  for ref in $REFS; do
    ((TOTAL_REFS++))

    # Resolve relative path
    if [[ "$ref" == /* ]]; then
      RESOLVED="$ref"
    else
      RESOLVED="$DIR/$ref"
    fi

    # Normalize path
    RESOLVED=$(cd "$(dirname "$RESOLVED")" 2>/dev/null && pwd)/$(basename "$RESOLVED") 2>/dev/null || RESOLVED="$DIR/$ref"

    if [[ -f "$RESOLVED" ]] || [[ -d "$RESOLVED" ]]; then
      ((VALID_REFS++))
    else
      ((INVALID_REFS++))
      LINE=$(grep -n "$ref" "$file" | head -1 | cut -d: -f1)
      ERRORS="$ERRORS\n| $file:$LINE | \`$ref\` | $RESOLVED |"
    fi
  done
done

echo "### Summary"
echo ""
echo "| 項目 | 件数 |"
echo "|------|------|"
echo "| 検証ファイル数 | $FILE_COUNT |"
echo "| 参照リンク数 | $TOTAL_REFS |"
echo "| 有効 | $VALID_REFS |"
echo "| 無効 | $INVALID_REFS |"
echo ""

if [[ $INVALID_REFS -eq 0 ]]; then
  echo "✅ **すべての参照が有効です**"
else
  echo "### ❌ 無効な参照"
  echo ""
  echo "| ファイル | 参照パス | 解決後パス |"
  echo "|---------|---------|-----------|"
  echo -e "$ERRORS"
fi
```

## Notes

- シンボリックリンクは解決してから検証
- ディレクトリへの参照も有効として扱う
- `#anchor` 付きのリンクはファイル部分のみ検証
