#!/bin/bash

# Cursor 向け変換スクリプト
# .agents/ の統一形式から .cursor/rules/ 向けに変換
# Cursor v2.2+ の新形式（.cursor/rules/rule-name/RULE.md）に対応

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
        awk '
        BEGIN {
            in_frontmatter = 0;
            has_frontmatter = 0;
            has_paths = 0;
            has_description = 0;
            buffered_frontmatter = "";
            globs_array = "";
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
                # globs をカンマ区切りの単一行形式で出力
                if (has_paths == 1 && globs_array != "") {
                    print "globs: " globs_array;
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
            # paths を検出（ヘッダーのみ、配列要素は後で処理）
            if ($0 ~ /^paths:/) {
                has_paths = 1;
                next;
            }
            # 配列要素を収集してカンマ区切りに変換
            if ($0 ~ /^  - /) {
                has_paths = 1;
                # "  - \"pattern\"" から pattern 部分を抽出
                gsub(/^  - /, "", $0);
                if (globs_array == "") {
                    globs_array = $0;
                } else {
                    globs_array = globs_array ", " $0;
                }
                next;
            }
            # 不要なフィールドをスキップ
            if ($0 ~ /^(name|agents|priority):/) {
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

# Skills 変換（新形式：.cursor/rules/skill-name/RULE.md）
echo ""
echo "Converting Skills..."
if [ -d "$AGENTS_DIR/skills" ]; then
    find "$AGENTS_DIR/skills" -mindepth 1 -maxdepth 1 -type d | while read -r skill_dir; do
        skill_name=$(basename "$skill_dir")
        target_dir="$CURSOR_DIR/rules/skill-$skill_name"

        echo "  Processing: skill-$skill_name"

        # 既存のディレクトリまたはシンボリックリンクを削除
        [ -L "$target_dir" ] && rm "$target_dir"
        [ -d "$target_dir" ] && rm -rf "$target_dir"

        # シンボリックリンクを作成（Progressive disclosure を維持）
        rel_path="../../.agents/skills/$skill_name"

        # SKILL.md を RULE.md に変換してコピー
        # （frontmatter形式が異なるため、シンボリックリンクではなくコピー）
        mkdir -p "$target_dir"

        # SKILL.md を RULE.md に変換（frontmatterをCursor形式に変換）
        if [ -f "$skill_dir/SKILL.md" ]; then
            awk '
            BEGIN {
                in_frontmatter = 0;
                has_frontmatter = 0;
                has_paths = 0;
                has_description = 0;
                buffered_frontmatter = "";
                globs_array = "";
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
                    # globs をカンマ区切りの単一行形式で出力
                    if (has_paths == 1 && globs_array != "") {
                        print "globs: " globs_array;
                    }
                    # description または globs が存在する場合は alwaysApply: false
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
                # paths を検出
                if ($0 ~ /^paths:/) {
                    has_paths = 1;
                    next;
                }
                # 配列要素を収集してカンマ区切りに変換
                if ($0 ~ /^  - /) {
                    has_paths = 1;
                    gsub(/^  - /, "", $0);
                    if (globs_array == "") {
                        globs_array = $0;
                    } else {
                        globs_array = globs_array ", " $0;
                    }
                    next;
                }
                # 不要なフィールドをスキップ（name, triggers, agents など）
                if ($0 ~ /^(name|triggers|agents|priority):/) {
                    next;
                }
            }
            !in_frontmatter && has_frontmatter {
                print $0;
            }
            !has_frontmatter && NR == 1 {
                # frontmatter がない場合は追加
                print "---";
                print "description: Skill from " FILENAME;
                print "alwaysApply: true";
                print "---";
                print "";
                print $0;
            }
            !has_frontmatter && NR > 1 {
                print $0;
            }
            ' "$skill_dir/SKILL.md" > "$target_dir/RULE.md"
        fi

        # その他のファイルとサブディレクトリをシンボリックリンク
        find "$skill_dir" -type f ! -name "SKILL.md" | while read -r file; do
            # スキルディレクトリからの相対パスを取得
            rel_path="${file#$skill_dir/}"
            target_file="$target_dir/$rel_path"
            target_file_dir=$(dirname "$target_file")

            # ターゲット側のディレクトリを作成
            mkdir -p "$target_file_dir"

            # 相対パスでシンボリックリンクを作成
            # .cursor/rules/{skill-name}/ から .agents/skills/{skill-name}/ へは
            # 3階層上がる必要がある: rules/ → .cursor/ → repo-root/
            # さらにサブディレクトリがある場合は追加で上がる
            depth=$(echo "$rel_path" | tr -cd '/' | wc -c)
            rel_prefix=""
            for i in $(seq 0 $((depth + 2))); do
                rel_prefix="../$rel_prefix"
            done
            rel_link_path="${rel_prefix}.agents/skills/$skill_name/$rel_path"

            ln -sf "$rel_link_path" "$target_file"
        done

        echo "    → $target_dir/RULE.md"
    done
fi

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
echo "  .cursor/rules/*/RULE.md (new format)"
echo "  .cursor/commands/*.md"
