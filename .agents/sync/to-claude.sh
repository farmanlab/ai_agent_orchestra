#!/bin/bash

# Claude Code 向け変換スクリプト
# .agents/ の統一形式から .claude/ 向けに変換

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
AGENTS_DIR="$REPO_ROOT/.agents"
CLAUDE_DIR="$REPO_ROOT/.claude"

echo "=== Converting to Claude Code format ==="
echo "Source: $AGENTS_DIR"
echo "Target: $CLAUDE_DIR"
echo ""

# ディレクトリ作成
mkdir -p "$CLAUDE_DIR/rules"

# Rules 変換
echo "Converting Rules..."
if [ -d "$AGENTS_DIR/rules" ]; then
    find "$AGENTS_DIR/rules" -type f -name "*.md" | while read -r rule_file; do
        filename=$(basename "$rule_file")
        target="$CLAUDE_DIR/rules/$filename"

        echo "  Processing: $filename"

        # frontmatter を Claude Code 形式に変換
        # globs を paths に変換し、不要なフィールドを削除
        awk '
        BEGIN {
            in_frontmatter = 0;
            has_frontmatter = 0;
            has_paths = 0;
            buffered_content = "";
            after_frontmatter = 0;
        }
        /^---$/ {
            if (NR == 1) {
                in_frontmatter = 1;
                has_frontmatter = 1;
                next;
            } else if (in_frontmatter) {
                in_frontmatter = 0;
                after_frontmatter = 1;
                # paths がある場合のみ frontmatter を出力
                if (has_paths) {
                    print "---";
                    print buffered_content;
                    print "---";
                    print "";
                }
                buffered_content = "";
                next;
            }
        }
        in_frontmatter {
            # globs を paths に変換（単一行の配列形式）
            if ($0 ~ /^globs: *\[/) {
                has_paths = 1;
                sub(/^globs:/, "paths:");
                buffered_content = buffered_content $0 "\n";
                next;
            }
            # paths フィールドを保持
            if ($0 ~ /^paths:/) {
                has_paths = 1;
                buffered_content = buffered_content $0 "\n";
                next;
            }
            # 配列要素を保持
            if ($0 ~ /^  - / && has_paths) {
                buffered_content = buffered_content $0 "\n";
                next;
            }
            # 不要なフィールドをスキップ
            if ($0 ~ /^(name|description|globs):/) {
                next;
            }
        }
        !in_frontmatter && after_frontmatter {
            print $0;
        }
        !in_frontmatter && !has_frontmatter {
            print $0;
        }
        ' "$rule_file" > "$target"

        echo "    → $target"
    done
fi

# Agents 変換
# Note: agents はファイルレベルのシンボリックリンクで管理（sync.sh で作成）
echo ""
echo "Converting Agents..."
echo "  (Managed via file-level symlinks in sync.sh)"

# CLAUDE.md は手動管理（リポジトリガイドとして使用）
# このリポジトリでは .claude/rules/ によるモジュラールール方式を採用しているため、
# CLAUDE.md の自動生成は無効化しています。
# CLAUDE.md はリポジトリのアーキテクチャとワークフローを説明する目的で手動作成されます。

# Commands 変換
echo ""
echo "Converting Commands..."
if [ -d "$AGENTS_DIR/commands" ]; then
    mkdir -p "$CLAUDE_DIR/commands"

    find "$AGENTS_DIR/commands" -type f -name "*.md" | while read -r command_file; do
        filename=$(basename "$command_file")
        relative_path="${command_file#$AGENTS_DIR/}"
        target="$CLAUDE_DIR/commands/$filename"

        echo "  Processing: $filename"

        # 既存のシンボリックリンクまたはファイルを削除
        [ -L "$target" ] && rm "$target"
        [ -f "$target" ] && rm "$target"

        # シンボリックリンクを作成
        rel_path="../../.agents/$relative_path"
        ln -s "$rel_path" "$target"

        echo "    → $target (symlink)"
    done
fi

echo ""
echo "=== Claude Code conversion complete ==="
echo ""
echo "Generated files:"
echo "  .claude/rules/"
echo "  .claude/agents/"
echo "  .claude/commands/"
