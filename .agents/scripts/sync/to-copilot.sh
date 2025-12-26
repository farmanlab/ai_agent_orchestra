#!/bin/bash

# GitHub Copilot 向け変換スクリプト
# .agents/ の統一形式から .github/ 向けに変換

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"
AGENTS_DIR="$REPO_ROOT/.agents"
GITHUB_DIR="$REPO_ROOT/.github"

echo "=== Converting to GitHub Copilot format ==="
echo "Source: $AGENTS_DIR"
echo "Target: $GITHUB_DIR"
echo ""

# ディレクトリ作成
mkdir -p "$GITHUB_DIR/instructions"

# copilot-instructions.md 生成（グローバルルール）
echo "Generating copilot-instructions.md..."
COPILOT_INSTRUCTIONS="$GITHUB_DIR/copilot-instructions.md"

cat > "$COPILOT_INSTRUCTIONS" << 'EOF'
# Project Instructions

<!-- Auto-generated from .agents/rules/ - Do not edit directly -->

EOF

# globs 指定のないルールを統合
if [ -d "$AGENTS_DIR/rules" ]; then
    find "$AGENTS_DIR/rules" -type f -name "*.md" | while read -r rule_file; do
        # globs または paths フィールドがあるかチェック
        if ! grep -q "^globs:" "$rule_file" && ! grep -q "^paths:" "$rule_file"; then
            echo "" >> "$COPILOT_INSTRUCTIONS"

            # frontmatter を除いてコンテンツを出力
            awk '
            BEGIN { in_frontmatter = 0; skip = 0; }
            /^---$/ {
                if (NR == 1) {
                    in_frontmatter = 1;
                    skip = 1;
                    next;
                } else if (in_frontmatter) {
                    in_frontmatter = 0;
                    skip = 1;
                    next;
                }
            }
            in_frontmatter { next; }
            !skip { print $0; }
            skip {
                if (NF > 0) {
                    skip = 0;
                    print $0;
                }
            }
            ' "$rule_file" >> "$COPILOT_INSTRUCTIONS"
        fi
    done
fi

echo "  → $COPILOT_INSTRUCTIONS"

# path-specific instructions 生成
echo ""
echo "Generating path-specific instructions..."
if [ -d "$AGENTS_DIR/rules" ]; then
    find "$AGENTS_DIR/rules" -type f -name "*.md" | while read -r rule_file; do
        filename=$(basename "$rule_file" .md)

        # globs または paths フィールドがある場合のみ変換
        if grep -q "^globs:" "$rule_file" || grep -q "^paths:" "$rule_file"; then
            target="$GITHUB_DIR/instructions/${filename}.instructions.md"

            echo "  Processing: $filename"

            # frontmatter を Copilot 形式に変換
            # 単一文字列形式に対応: paths: "**/*.{ts,tsx}"
            awk '
            BEGIN {
                in_frontmatter = 0;
                has_frontmatter = 0;
                applyTo_value = "";
            }
            /^---$/ {
                if (NR == 1) {
                    in_frontmatter = 1;
                    has_frontmatter = 1;
                    print "---";
                    next;
                } else if (in_frontmatter) {
                    in_frontmatter = 0;
                    # applyTo を出力
                    if (applyTo_value != "") {
                        print "applyTo: " applyTo_value;
                    }
                    print "---";
                    print "";
                    next;
                }
            }
            in_frontmatter {
                # globs を applyTo に変換（単一文字列形式）
                if ($0 ~ /^globs:/) {
                    sub(/^globs:\s*/, "");
                    applyTo_value = $0;
                    next;
                }
                # paths を applyTo に変換（単一文字列形式）
                if ($0 ~ /^paths:/) {
                    sub(/^paths:\s*/, "");
                    applyTo_value = $0;
                    next;
                }
                # 不要なフィールドをスキップ
                if ($0 ~ /^(name|description):/) {
                    next;
                }
            }
            !in_frontmatter {
                print $0;
            }
            ' "$rule_file" > "$target"

            echo "    → $target"
        fi
    done
fi

# AGENTS.md 生成
echo ""
echo "Generating AGENTS.md..."
AGENTS_MD="$REPO_ROOT/AGENTS.md"

cat > "$AGENTS_MD" << 'EOF'
# AI Agent Instructions

<!-- Auto-generated from .agents/agents/ - Do not edit directly -->

EOF

if [ -d "$AGENTS_DIR/agents" ]; then
    find "$AGENTS_DIR/agents" -type f -name "*.md" | sort | while read -r agent_file; do
        # エージェント名を取得
        agent_name=$(awk '/^name:/ { sub(/^name: */, ""); print; exit }' "$agent_file")
        if [ -z "$agent_name" ]; then
            agent_name=$(basename "$agent_file" .md)
        fi

        echo "" >> "$AGENTS_MD"
        echo "## $agent_name" >> "$AGENTS_MD"
        echo "" >> "$AGENTS_MD"

        # frontmatter を除いてコンテンツを出力
        awk '
        BEGIN { in_frontmatter = 0; skip = 0; }
        /^---$/ {
            if (NR == 1) {
                in_frontmatter = 1;
                skip = 1;
                next;
            } else if (in_frontmatter) {
                in_frontmatter = 0;
                skip = 1;
                next;
            }
        }
        in_frontmatter { next; }
        !skip { print $0; }
        skip {
            if (NF > 0) {
                skip = 0;
                print $0;
            }
        }
        ' "$agent_file" >> "$AGENTS_MD"

        echo "" >> "$AGENTS_MD"
        echo "---" >> "$AGENTS_MD"
        echo "" >> "$AGENTS_MD"
    done
fi

echo "  → $AGENTS_MD"

# CLAUDE.md をシンボリックリンクとして作成
echo ""
echo "Creating CLAUDE.md symlink..."
CLAUDE_MD="$REPO_ROOT/CLAUDE.md"
[ -L "$CLAUDE_MD" ] && rm "$CLAUDE_MD"
[ -f "$CLAUDE_MD" ] && rm "$CLAUDE_MD"
ln -s AGENTS.md "$CLAUDE_MD"
echo "  → $CLAUDE_MD -> AGENTS.md"

# Commands 変換（GitHub Prompts）
echo ""
echo "Converting Commands to GitHub Prompts..."
if [ -d "$AGENTS_DIR/commands" ]; then
    mkdir -p "$GITHUB_DIR/prompts"

    find "$AGENTS_DIR/commands" -type f -name "*.md" | while read -r command_file; do
        filename=$(basename "$command_file" .md)
        relative_path="${command_file#$AGENTS_DIR/}"
        target="$GITHUB_DIR/prompts/${filename}.prompt.md"

        echo "  Processing: $filename"

        # 既存のシンボリックリンクまたはファイルを削除
        [ -L "$target" ] && rm "$target"
        [ -f "$target" ] && rm "$target"

        # GitHub Prompts は .prompt.md 拡張子が必要なのでコピー
        # （シンボリックリンクでは拡張子変更できないため）
        cp "$command_file" "$target"

        echo "    → $target (copy, .prompt.md)"
    done
fi

echo ""
echo "=== GitHub Copilot conversion complete ==="
echo ""
echo "Generated files:"
echo "  .github/copilot-instructions.md"
echo "  .github/instructions/*.instructions.md"
echo "  .github/prompts/*.prompt.md"
echo "  AGENTS.md"
echo "  CLAUDE.md -> AGENTS.md"
