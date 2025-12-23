#!/bin/bash

# Cursor 向け変換スクリプト
# .agents/ の統一形式から .cursor/ 向けに変換
# Cursor v2.2+ の新形式に対応:
# - Rules: .cursor/rules/rule-name/RULE.md
# - Skills: .cursor/skills/skill-name/SKILL.md (Agent Skills 標準準拠)

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
AGENTS_DIR="$REPO_ROOT/.agents"
CURSOR_DIR="$REPO_ROOT/.cursor"

echo "=== Converting to Cursor format (v2.2+) ==="
echo "Source: $AGENTS_DIR"
echo "Target: $CURSOR_DIR"
echo ""

# ディレクトリ作成
mkdir -p "$CURSOR_DIR/rules"

# Rules 変換（新形式：.cursor/rules/rule-name/RULE.md）
echo "Converting Rules..."
if [ -d "$AGENTS_DIR/rules" ]; then
    find "$AGENTS_DIR/rules" -type f -name "*.md" | sort | while read -r rule_file; do
        filename=$(basename "$rule_file" .md)
        target_dir="$CURSOR_DIR/rules/$filename"
        target_file="$target_dir/RULE.md"

        echo "  Processing: $filename"

        # ディレクトリを作成（シンボリックリンクの場合は削除）
        [ -L "$target_dir" ] && rm "$target_dir"
        mkdir -p "$target_dir"

        # frontmatter を Cursor RULE.md 形式に変換
        # 単一文字列形式に対応: paths: "**/*.{ts,tsx}"
        awk '
        BEGIN {
            in_frontmatter = 0;
            has_frontmatter = 0;
            has_paths = 0;
            has_description = 0;
            buffered_frontmatter = "";
            globs_value = "";
        }
        /^---$/ {
            if (NR == 1) {
                in_frontmatter = 1;
                has_frontmatter = 1;
                next;
            } else if (in_frontmatter) {
                in_frontmatter = 0;
                # frontmatter を出力
                print "---";
                print buffered_frontmatter;
                # globs を出力（単一文字列形式をそのまま使用）
                if (has_paths == 1 && globs_value != "") {
                    print "globs: " globs_value;
                }
                # alwaysApply を追加
                # description または globs が存在する場合は false
                if (has_description == 0 && has_paths == 0) {
                    print "alwaysApply: true";
                } else {
                    print "alwaysApply: false";
                }
                print "---";
                print "";
                next;
            }
        }
        in_frontmatter {
            # description を保持
            if ($0 ~ /^description:/) {
                has_description = 1;
                buffered_frontmatter = buffered_frontmatter $0 "\n";
                next;
            }
            # paths を検出（単一文字列形式）
            if ($0 ~ /^paths:/) {
                has_paths = 1;
                sub(/^paths:\s*/, "");
                globs_value = $0;
                next;
            }
            # globs を検出（単一文字列形式）
            if ($0 ~ /^globs:/) {
                has_paths = 1;
                sub(/^globs:\s*/, "");
                globs_value = $0;
                next;
            }
            # 不要なフィールドをスキップ
            if ($0 ~ /^name:/) {
                next;
            }
        }
        !in_frontmatter && has_frontmatter {
            print $0;
        }
        !has_frontmatter && NR == 1 {
            # frontmatter がない場合は追加
            print "---";
            print "description: " FILENAME;
            print "alwaysApply: true";
            print "---";
            print "";
            print $0;
        }
        !has_frontmatter && NR > 1 {
            print $0;
        }
        ' "$rule_file" > "$target_file"

        echo "    → $target_file"
    done
fi

# Note: Skills はファイルレベルのシンボリックリンクで管理（sync.sh で作成）

# Commands 変換
echo ""
echo "Converting Commands..."
if [ -d "$AGENTS_DIR/commands" ]; then
    mkdir -p "$CURSOR_DIR/commands"

    find "$AGENTS_DIR/commands" -type f -name "*.md" | while read -r command_file; do
        filename=$(basename "$command_file")
        relative_path="${command_file#$AGENTS_DIR/}"
        target="$CURSOR_DIR/commands/$filename"

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
echo "=== Cursor conversion complete ==="
echo ""
echo "Generated files:"
echo "  .cursor/rules/*/RULE.md (rules)"
echo "  .cursor/commands/*.md (commands)"
