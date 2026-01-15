#!/bin/bash

# Cursor 向け変換スクリプト
# .agents/ の統一形式から .cursor/ 向けに変換
# Cursor v2.2+ の新形式に対応:
# - Rules: .cursor/rules/rule-name/RULE.md
# - Skills: .cursor/skills/skill-name/SKILL.md (Agent Skills 標準準拠)

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"
AGENTS_DIR="$REPO_ROOT/.agents"
CURSOR_DIR="$REPO_ROOT/.cursor"

echo "=== Converting to Cursor format (v2.2+) ==="
echo "Source: $AGENTS_DIR"
echo "Target: $CURSOR_DIR"
echo ""

# ディレクトリ作成
mkdir -p "$CURSOR_DIR/rules"

# Rules 変換
# 現在は他エージェントと同じフラット構造（.cursor/rules/rule-name.md）を使用
# Cursor が新形式（rule-name/RULE.md）に正式対応したら、下記のコメントアウトを戻す

echo "Converting Rules..."
if [ -d "$AGENTS_DIR/rules" ]; then
    find "$AGENTS_DIR/rules" -type f -name "*.md" | sort | while read -r rule_file; do
        filename=$(basename "$rule_file" .md)
        target_file="$CURSOR_DIR/rules/${filename}.mdc"

        echo "  Processing: ${filename}.mdc"

        # 既存のシンボリックリンク、ディレクトリ、または古い .md ファイルを削除
        [ -L "$target_file" ] && rm "$target_file"
        [ -f "$CURSOR_DIR/rules/${filename}.md" ] && rm "$CURSOR_DIR/rules/${filename}.md"
        [ -d "$CURSOR_DIR/rules/$filename" ] && rm -rf "$CURSOR_DIR/rules/$filename"

        # frontmatter を Cursor 形式に変換
        # paths → globs に変換し、alwaysApply を追加
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
                # globs を出力
                if (has_paths == 1 && globs_value != "") {
                    print "globs: " globs_value;
                }
                # alwaysApply を追加
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
            if ($0 ~ /^description:/) {
                has_description = 1;
                buffered_frontmatter = buffered_frontmatter $0 "\n";
                next;
            }
            if ($0 ~ /^paths:/) {
                has_paths = 1;
                sub(/^paths:\s*/, "");
                globs_value = $0;
                next;
            }
            if ($0 ~ /^globs:/) {
                has_paths = 1;
                sub(/^globs:\s*/, "");
                globs_value = $0;
                next;
            }
            if ($0 ~ /^name:/) {
                next;
            }
        }
        !in_frontmatter && has_frontmatter {
            print $0;
        }
        !has_frontmatter && NR == 1 {
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

# ==============================================================================
# [FUTURE] Cursor が rule-name/RULE.md 構造に正式対応したら以下を有効化
# ==============================================================================
#
# # Rules 変換（新形式：.cursor/rules/rule-name/RULE.md）
# echo "Converting Rules..."
# if [ -d "$AGENTS_DIR/rules" ]; then
#     find "$AGENTS_DIR/rules" -type f -name "*.md" | sort | while read -r rule_file; do
#         filename=$(basename "$rule_file" .md)
#         target_dir="$CURSOR_DIR/rules/$filename"
#         target_file="$target_dir/RULE.md"
#
#         echo "  Processing: $filename"
#
#         # ディレクトリを作成（シンボリックリンクの場合は削除）
#         [ -L "$target_dir" ] && rm "$target_dir"
#         mkdir -p "$target_dir"
#
#         # frontmatter を Cursor RULE.md 形式に変換
#         awk '
#         BEGIN {
#             in_frontmatter = 0;
#             has_frontmatter = 0;
#             has_paths = 0;
#             has_description = 0;
#             buffered_frontmatter = "";
#             globs_value = "";
#         }
#         /^---$/ {
#             if (NR == 1) {
#                 in_frontmatter = 1;
#                 has_frontmatter = 1;
#                 next;
#             } else if (in_frontmatter) {
#                 in_frontmatter = 0;
#                 print "---";
#                 print buffered_frontmatter;
#                 if (has_paths == 1 && globs_value != "") {
#                     print "globs: " globs_value;
#                 }
#                 if (has_description == 0 && has_paths == 0) {
#                     print "alwaysApply: true";
#                 } else {
#                     print "alwaysApply: false";
#                 }
#                 print "---";
#                 print "";
#                 next;
#             }
#         }
#         in_frontmatter {
#             if ($0 ~ /^description:/) {
#                 has_description = 1;
#                 buffered_frontmatter = buffered_frontmatter $0 "\n";
#                 next;
#             }
#             if ($0 ~ /^paths:/) {
#                 has_paths = 1;
#                 sub(/^paths:\s*/, "");
#                 globs_value = $0;
#                 next;
#             }
#             if ($0 ~ /^globs:/) {
#                 has_paths = 1;
#                 sub(/^globs:\s*/, "");
#                 globs_value = $0;
#                 next;
#             }
#             if ($0 ~ /^name:/) {
#                 next;
#             }
#         }
#         !in_frontmatter && has_frontmatter {
#             print $0;
#         }
#         !has_frontmatter && NR == 1 {
#             print "---";
#             print "description: " FILENAME;
#             print "alwaysApply: true";
#             print "---";
#             print "";
#             print $0;
#         }
#         !has_frontmatter && NR > 1 {
#             print $0;
#         }
#         ' "$rule_file" > "$target_file"
#
#         echo "    → $target_file"
#     done
# fi
# ==============================================================================

# Note: Skills と Commands は Cursor が .claude/ から直接読み込むため sync 不要
# Agents は sync.sh でシンボリックリンクを作成

echo ""
echo "=== Cursor conversion complete ==="
echo ""
echo "Generated files:"
echo "  .cursor/rules/*.mdc (rules)"
echo "  .cursor/agents/*.md (agents, symlinks)"
echo ""
echo "Note: skills と commands は .claude/ から直接読み込まれます"
