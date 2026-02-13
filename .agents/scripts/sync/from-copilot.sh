#!/bin/bash

# GitHub Copilot から .agents への逆変換スクリプト
# .github/ の形式から .agents/ 統一形式に変換
#
# Frontmatter 変換:
#   Copilot (.instructions.md)  →  .agents (.md)
#   -------------------------      ----------------
#   applyTo: "**/*.ts"          →  paths: "**/*.ts"
#   (ファイル名)                →  name: {filename}
#
# copilot-instructions.md:
#   frontmatter を追加して .agents/rules/copilot-instructions.md にコピー

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
AGENTS_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
REPO_ROOT="$(cd "$AGENTS_DIR/.." && pwd)"
GITHUB_DIR="$REPO_ROOT/.github"

# カラー定義
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${BLUE}ℹ${NC} $1"; }
log_success() { echo -e "${GREEN}✓${NC} $1"; }
log_warning() { echo -e "${YELLOW}⚠${NC} $1"; }
log_error() { echo -e "${RED}✗${NC} $1"; }

echo "=== Reverse sync from GitHub Copilot to .agents ==="
echo "Source: $GITHUB_DIR"
echo "Target: $AGENTS_DIR"
echo ""

# copilot-instructions.md の逆変換
echo "Converting copilot-instructions.md to rules..."
COPILOT_INSTRUCTIONS="$GITHUB_DIR/copilot-instructions.md"
TARGET_INSTRUCTIONS="$AGENTS_DIR/rules/copilot-instructions.md"

if [ -f "$COPILOT_INSTRUCTIONS" ]; then
    # シンボリックリンクの場合はスキップ
    if [ -L "$COPILOT_INSTRUCTIONS" ]; then
        log_info "copilot-instructions.md is a symlink - skipping"
    # Auto-generated マーカーがある場合はスキップ
    elif grep -q "Auto-generated from .agents" "$COPILOT_INSTRUCTIONS" 2>/dev/null; then
        log_info "copilot-instructions.md is auto-generated - skipping"
    # すでに .agents に存在する場合はスキップ
    elif [ -f "$TARGET_INSTRUCTIONS" ]; then
        log_warning "[copilot-instructions] Already exists in .agents/rules/ - skipping"
    else
        mkdir -p "$AGENTS_DIR/rules"

        # frontmatter を追加してコピー
        {
            echo "---"
            echo "name: copilot-instructions"
            echo "description: GitHub Copilot instructions"
            echo "---"
            echo ""
            cat "$COPILOT_INSTRUCTIONS"
        } > "$TARGET_INSTRUCTIONS"

        log_success "  → $TARGET_INSTRUCTIONS"
    fi
else
    log_warning "No .github/copilot-instructions.md found"
fi

# path-specific instructions の逆変換
echo ""
echo "Converting path-specific instructions to rules..."
if [ -d "$GITHUB_DIR/instructions" ]; then
    find "$GITHUB_DIR/instructions" -type f -name "*.instructions.md" 2>/dev/null | sort | while read -r instruction_file; do
        # .instructions.md を除去してファイル名を取得
        filename=$(basename "$instruction_file" .instructions.md)
        target_file="$AGENTS_DIR/rules/${filename}.md"

        # シンボリックリンクの場合はスキップ
        if [ -L "$instruction_file" ]; then
            log_info "Skipping symlink: ${filename}.instructions.md"
            continue
        fi

        # すでに .agents に存在する場合はスキップ
        if [ -f "$target_file" ]; then
            log_warning "[${filename}] Already exists in .agents/rules/ - skipping"
            continue
        fi

        echo "  Processing: ${filename}.instructions.md → ${filename}.md"

        # frontmatter を .agents 形式に変換（applyTo → paths）
        awk -v filename="$filename" '
        BEGIN {
            in_frontmatter = 0;
            has_frontmatter = 0;
            paths = "";
            content = "";
            after_frontmatter = 0;
            first_heading = "";
        }
        /^---$/ {
            if (NR == 1) {
                in_frontmatter = 1;
                has_frontmatter = 1;
                next;
            } else if (in_frontmatter) {
                in_frontmatter = 0;
                after_frontmatter = 1;
                next;
            }
        }
        in_frontmatter {
            # applyTo を paths として取得
            if ($0 ~ /^applyTo:/) {
                sub(/^applyTo:\s*/, "");
                paths = $0;
                next;
            }
            next;
        }
        after_frontmatter {
            # 最初の見出しを description として使用
            if (first_heading == "" && $0 ~ /^#+ /) {
                first_heading = $0;
                gsub(/^#+ /, "", first_heading);
            }
            content = content $0 "\n";
        }
        !has_frontmatter {
            if (first_heading == "" && $0 ~ /^#+ /) {
                first_heading = $0;
                gsub(/^#+ /, "", first_heading);
            }
            content = content $0 "\n";
        }
        END {
            # .agents 形式で出力
            print "---";
            print "name: " filename;
            if (first_heading != "") {
                print "description: " first_heading;
            } else {
                desc = filename;
                gsub(/-/, " ", desc);
                print "description: " desc;
            }
            if (paths != "") {
                print "paths: " paths;
            }
            print "---";
            print "";
            printf "%s", content;
        }
        ' "$instruction_file" > "$target_file"

        log_success "  → $target_file"
    done
else
    log_warning "No .github/instructions directory found"
fi

# Skills の逆変換
echo ""
echo "Converting Skills from Copilot..."
if [ -d "$GITHUB_DIR/skills" ]; then
    find "$GITHUB_DIR/skills" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | while read -r skill_dir; do
        skill_name=$(basename "$skill_dir")
        target_dir="$AGENTS_DIR/skills/${skill_name}"

        # シンボリックリンクの場合はスキップ
        if [ -L "$skill_dir" ]; then
            log_info "Skipping symlink: ${skill_name}"
            continue
        fi

        # すでに .agents に存在する場合はスキップ
        if [ -d "$target_dir" ]; then
            log_warning "[${skill_name}] Already exists in .agents/skills/ - skipping"
            continue
        fi

        echo "  Processing: ${skill_name}/"

        # ディレクトリをコピー
        mkdir -p "$target_dir"
        cp -r "$skill_dir"/* "$target_dir"/ 2>/dev/null || true

        log_success "  → $target_dir/"
    done
else
    log_warning "No .github/skills directory found"
fi

# Agents の逆変換
echo ""
echo "Converting Agents from Copilot..."
if [ -d "$GITHUB_DIR/agents" ]; then
    find "$GITHUB_DIR/agents" -type f -name "*.agents.md" 2>/dev/null | sort | while read -r copilot_file; do
        # .agents.md の拡張子を .md に変換
        filename=$(basename "$copilot_file" .agents.md)
        target_file="$AGENTS_DIR/agents/${filename}.md"

        # シンボリックリンクの場合はスキップ
        if [ -L "$copilot_file" ]; then
            log_info "Skipping symlink: ${filename}.agents.md"
            continue
        fi

        # すでに .agents に存在する場合はスキップ
        if [ -f "$target_file" ]; then
            log_warning "[${filename}] Already exists in .agents/agents/ - skipping"
            continue
        fi

        echo "  Processing: ${filename}.agents.md → ${filename}.md"

        # そのままコピー
        cp "$copilot_file" "$target_file"

        log_success "  → $target_file"
    done
else
    log_warning "No .github/agents directory found"
fi

# Prompts/Commands の逆変換
echo ""
echo "Converting Prompts to Commands..."
if [ -d "$GITHUB_DIR/prompts" ]; then
    mkdir -p "$AGENTS_DIR/commands"

    find "$GITHUB_DIR/prompts" -type f -name "*.prompt.md" 2>/dev/null | sort | while read -r prompt_file; do
        # .prompt.md を除去してファイル名を取得
        filename=$(basename "$prompt_file" .prompt.md)
        target_file="$AGENTS_DIR/commands/${filename}.md"

        # シンボリックリンクの場合はスキップ
        if [ -L "$prompt_file" ]; then
            log_info "Skipping symlink: ${filename}.prompt.md"
            continue
        fi

        # すでに .agents に存在する場合はスキップ
        if [ -f "$target_file" ]; then
            log_warning "[${filename}] Already exists in .agents/commands/ - skipping"
            continue
        fi

        echo "  Processing: ${filename}.prompt.md → ${filename}.md"

        # そのままコピー
        cp "$prompt_file" "$target_file"

        log_success "  → $target_file"
    done
else
    log_warning "No .github/prompts directory found"
fi

echo ""
echo "=== GitHub Copilot reverse sync complete ==="
