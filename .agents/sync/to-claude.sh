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
mkdir -p "$CLAUDE_DIR"/{rules,skills,agents}

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
            if ($0 ~ /^(name|description|agents|priority|globs):/) {
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

# Skills 変換
echo ""
echo "Converting Skills..."
if [ -d "$AGENTS_DIR/skills" ]; then
    mkdir -p "$CLAUDE_DIR/skills"

    find "$AGENTS_DIR/skills" -mindepth 1 -maxdepth 1 -type d | while read -r skill_dir; do
        skill_name=$(basename "$skill_dir")
        target_dir="$CLAUDE_DIR/skills/$skill_name"

        echo "  Processing: $skill_name"

        # 既存のシンボリックリンクまたはディレクトリを削除
        [ -L "$target_dir" ] && rm "$target_dir"
        [ -d "$target_dir" ] && rm -rf "$target_dir"

        # ディレクトリを作成
        mkdir -p "$target_dir"

        # SKILL.md を変換（frontmatterをClaude形式に変換）
        if [ -f "$skill_dir/SKILL.md" ]; then
            awk '
            BEGIN {
                in_frontmatter = 0;
                has_frontmatter = 0;
                buffered_frontmatter = "";
                in_allowed_field = 0;
            }
            /^---$/ {
                if (NR == 1) {
                    in_frontmatter = 1;
                    has_frontmatter = 1;
                    next;
                } else if (in_frontmatter) {
                    in_frontmatter = 0;
                    # frontmatter を出力（末尾の改行を除去）
                    print "---";
                    gsub(/\n$/, "", buffered_frontmatter);
                    print buffered_frontmatter;
                    print "---";
                    print "";
                    next;
                }
            }
            in_frontmatter {
                # コメント行や空行はスキップ（保持しない）
                if ($0 ~ /^#/ || NF == 0) {
                    next;
                }
                # name, description, allowed-tools を保持（公式仕様準拠）
                if ($0 ~ /^name:/ || $0 ~ /^description:/ || $0 ~ /^allowed-tools:/) {
                    buffered_frontmatter = buffered_frontmatter $0 "\n";
                    in_allowed_field = 1;
                    next;
                }
                # 不要なフィールド（compatibility, triggers, agents, priority など）
                # compatibility は Claude が含まれているかのフィルタリングに使用済み
                if ($0 ~ /^compatibility:/ || $0 ~ /^triggers:/ || $0 ~ /^agents:/ || $0 ~ /^priority:/ || $0 ~ /^paths:/) {
                    in_allowed_field = 0;
                    next;
                }
                # 配列要素
                if ($0 ~ /^  - /) {
                    if (in_allowed_field == 1) {
                        buffered_frontmatter = buffered_frontmatter $0 "\n";
                    }
                    next;
                }
                # その他のフィールド（新しいフィールドが来たらリセット）
                if ($0 ~ /^[a-zA-Z]/) {
                    in_allowed_field = 0;
                }
            }
            !in_frontmatter && has_frontmatter {
                print $0;
            }
            !has_frontmatter && NR == 1 {
                # frontmatter がない場合はそのまま出力
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
            # .claude/skills/{skill-name}/ から .agents/skills/{skill-name}/ へは
            # 3階層上がる必要がある: skills/ → .claude/ → repo-root/
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
fi

# Agents 変換
echo ""
echo "Converting Agents..."
if [ -d "$AGENTS_DIR/agents" ]; then
    find "$AGENTS_DIR/agents" -type f -name "*.md" | while read -r agent_file; do
        filename=$(basename "$agent_file")
        target="$CLAUDE_DIR/agents/$filename"

        echo "  Processing: $filename"

        # frontmatter を Claude Code 形式でそのまま保持
        # compatibility フィールドをフィルタリング用に確認（公式仕様準拠）
        # "Claude" が含まれているか、compatibility/agents フィールドがない場合は変換
        if grep -q "^compatibility:.*Claude" "$agent_file" || grep -q "^agents:.*claude" "$agent_file" || (! grep -q "^compatibility:" "$agent_file" && ! grep -q "^agents:" "$agent_file"); then
            # claude が含まれているか、agents フィールドがない場合は変換
            awk '
            BEGIN { in_frontmatter = 0; }
            /^---$/ {
                if (NR == 1) {
                    in_frontmatter = 1;
                    print $0;
                    next;
                } else if (in_frontmatter) {
                    in_frontmatter = 0;
                    print $0;
                    next;
                }
            }
            in_frontmatter {
                # compatibility, agents フィールドは削除（フィルタリングに使っただけ）
                if ($0 ~ /^compatibility:/ || $0 ~ /^agents:/) {
                    next;
                }
                print $0;
            }
            !in_frontmatter {
                print $0;
            }
            ' "$agent_file" > "$target"

            echo "    → $target"
        else
            echo "    (Skipped: not for Claude Code)"
        fi
    done
fi

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
echo "  .claude/skills/"
echo "  .claude/agents/"
echo "  .claude/commands/"
echo "  CLAUDE.md (Copilot compatibility)"
