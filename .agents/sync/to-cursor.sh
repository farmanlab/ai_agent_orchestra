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
mkdir -p "$CURSOR_DIR/skills"

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

# Skills 変換（Agent Skills 標準：.cursor/skills/skill-name/SKILL.md）
echo ""
echo "Converting Skills..."
if [ -d "$AGENTS_DIR/skills" ]; then
    find "$AGENTS_DIR/skills" -mindepth 1 -maxdepth 1 -type d | while read -r skill_dir; do
        skill_name=$(basename "$skill_dir")
        target_dir="$CURSOR_DIR/skills/$skill_name"

        # compatibility フィールドで Cursor 向けかを確認（公式仕様準拠）
        if [ -f "$skill_dir/SKILL.md" ]; then
            if grep -q "^compatibility:.*Cursor" "$skill_dir/SKILL.md" || grep -q "^agents:.*cursor" "$skill_dir/SKILL.md" || (! grep -q "^compatibility:" "$skill_dir/SKILL.md" && ! grep -q "^agents:" "$skill_dir/SKILL.md"); then
                : # Cursor 向け、続行
            else
                echo "  Skipping: $skill_name (not for Cursor)"
                continue
            fi
        fi

        echo "  Processing: $skill_name"

        # 既存のディレクトリまたはシンボリックリンクを削除
        [ -L "$target_dir" ] && rm "$target_dir"
        [ -d "$target_dir" ] && rm -rf "$target_dir"

        # ディレクトリを作成
        mkdir -p "$target_dir"

        # SKILL.md を Agent Skills 標準形式でコピー
        # frontmatter は Agent Skills 標準に準拠（name, description, allowed-tools などを保持）
        if [ -f "$skill_dir/SKILL.md" ]; then
            awk '
            BEGIN {
                in_frontmatter = 0;
                has_frontmatter = 0;
                buffered_frontmatter = "";
            }
            /^---$/ {
                if (NR == 1) {
                    in_frontmatter = 1;
                    has_frontmatter = 1;
                    next;
                } else if (in_frontmatter) {
                    in_frontmatter = 0;
                    # frontmatter を出力（Agent Skills 標準に準拠）
                    print "---";
                    # compatibility フィールドを削除（Cursor では不要）
                    gsub(/^compatibility:.*\n/, "", buffered_frontmatter);
                    gsub(/^agents:.*\n/, "", buffered_frontmatter);
                    print buffered_frontmatter;
                    print "---";
                    print "";
                    next;
                }
            }
            in_frontmatter {
                # compatibility と agents フィールドをスキップ（Cursor では不要）
                if ($0 ~ /^(compatibility|agents):/) {
                    next;
                }
                # その他のフィールドは保持（name, description, allowed-tools など）
                buffered_frontmatter = buffered_frontmatter $0 "\n";
                next;
            }
            !in_frontmatter && has_frontmatter {
                print $0;
            }
            !has_frontmatter && NR == 1 {
                # frontmatter がない場合は追加
                print "---";
                print "name: " FILENAME;
                print "description: Skill from " FILENAME;
                print "---";
                print "";
                print $0;
            }
            !has_frontmatter && NR > 1 {
                print $0;
            }
            ' "$skill_dir/SKILL.md" > "$target_dir/SKILL.md"
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
            # .cursor/skills/{skill-name}/ から .agents/skills/{skill-name}/ へは
            # 3階層上がる必要がある: skills/ → .cursor/ → repo-root/
            # さらにサブディレクトリがある場合は追加で上がる
            depth=$(echo "$rel_path" | tr -cd '/' | wc -c)
            rel_prefix=""
            for i in $(seq 0 $((depth + 2))); do
                rel_prefix="../$rel_prefix"
            done
            rel_link_path="${rel_prefix}.agents/skills/$skill_name/$rel_path"

            ln -sf "$rel_link_path" "$target_file"
        done

        echo "    → $target_dir/SKILL.md"
    done

    # 古い .cursor/rules/skill-* ディレクトリを削除（後方互換性のため）
    if [ -d "$CURSOR_DIR/rules" ]; then
        find "$CURSOR_DIR/rules" -type d -name "skill-*" | while read -r old_skill_dir; do
            echo "  Removing old skill location: $old_skill_dir"
            rm -rf "$old_skill_dir"
        done
    fi
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
echo "  .cursor/rules/*/RULE.md (rules)"
echo "  .cursor/skills/*/SKILL.md (Agent Skills)"
echo "  .cursor/commands/*.md (commands)"
