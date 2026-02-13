#!/bin/bash

# Claude Code から .agents への逆変換スクリプト
# .claude/ の形式から .agents/ 統一形式に変換
#
# Frontmatter 変換:
#   Claude (.md)           →  .agents (.md)
#   -----------------         ----------------
#   paths: "**/*.ts"       →  paths: "**/*.ts"
#   (ファイル名)           →  name: {filename}
#   (なし)                 →  description: (ファイル名から生成)

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
AGENTS_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
REPO_ROOT="$(cd "$AGENTS_DIR/.." && pwd)"
CLAUDE_DIR="$REPO_ROOT/.claude"

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

echo "=== Reverse sync from Claude Code to .agents ==="
echo "Source: $CLAUDE_DIR"
echo "Target: $AGENTS_DIR"
echo ""

# Rules の逆変換
echo "Converting Rules from Claude..."
if [ -d "$CLAUDE_DIR/rules" ]; then
    find "$CLAUDE_DIR/rules" -type f -name "*.md" 2>/dev/null | sort | while read -r claude_file; do
        filename=$(basename "$claude_file" .md)
        target_file="$AGENTS_DIR/rules/${filename}.md"

        # シンボリックリンクの場合はスキップ
        if [ -L "$claude_file" ]; then
            log_info "Skipping symlink: ${filename}.md"
            continue
        fi

        # _base などの特殊ファイルはスキップ
        if [[ "$filename" == _* ]]; then
            log_info "Skipping special file: ${filename}.md"
            continue
        fi

        # すでに .agents に存在する場合はスキップ（上書き防止）
        if [ -f "$target_file" ]; then
            log_warning "[${filename}] Already exists in .agents/rules/ - skipping (use --force to overwrite)"
            continue
        fi

        echo "  Processing: ${filename}.md"

        # frontmatter を .agents 形式に変換
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
            # paths を取得
            if ($0 ~ /^paths:/) {
                sub(/^paths:\s*/, "");
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
            # frontmatter がない場合も最初の見出しを取得
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
            # description は最初の見出しから生成、なければファイル名を使用
            if (first_heading != "") {
                print "description: " first_heading;
            } else {
                # ハイフンをスペースに変換して description を生成
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
        ' "$claude_file" > "$target_file"

        log_success "  → $target_file"
    done
else
    log_warning "No .claude/rules directory found"
fi

# Agents の逆変換
echo ""
echo "Converting Agents from Claude..."
if [ -d "$CLAUDE_DIR/agents" ]; then
    find "$CLAUDE_DIR/agents" -type f -name "*.md" 2>/dev/null | sort | while read -r claude_file; do
        filename=$(basename "$claude_file" .md)
        target_file="$AGENTS_DIR/agents/${filename}.md"

        # シンボリックリンクの場合はスキップ
        if [ -L "$claude_file" ]; then
            log_info "Skipping symlink: ${filename}.md"
            continue
        fi

        # すでに .agents に存在する場合はスキップ
        if [ -f "$target_file" ]; then
            log_warning "[${filename}] Already exists in .agents/agents/ - skipping"
            continue
        fi

        echo "  Processing: ${filename}.md"

        # そのままコピー（Claude agents は frontmatter が .agents と同じ形式）
        cp "$claude_file" "$target_file"

        log_success "  → $target_file"
    done
else
    log_warning "No .claude/agents directory found"
fi

# Skills の逆変換
echo ""
echo "Converting Skills from Claude..."
if [ -d "$CLAUDE_DIR/skills" ]; then
    find "$CLAUDE_DIR/skills" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | while read -r skill_dir; do
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
    log_warning "No .claude/skills directory found"
fi

# Commands の逆変換
echo ""
echo "Converting Commands from Claude..."
if [ -d "$CLAUDE_DIR/commands" ]; then
    find "$CLAUDE_DIR/commands" -type f -name "*.md" 2>/dev/null | sort | while read -r claude_file; do
        filename=$(basename "$claude_file" .md)
        target_file="$AGENTS_DIR/commands/${filename}.md"

        # シンボリックリンクの場合はスキップ
        if [ -L "$claude_file" ]; then
            log_info "Skipping symlink: ${filename}.md"
            continue
        fi

        # すでに .agents に存在する場合はスキップ
        if [ -f "$target_file" ]; then
            log_warning "[${filename}] Already exists in .agents/commands/ - skipping"
            continue
        fi

        echo "  Processing: ${filename}.md"

        # そのままコピー
        cp "$claude_file" "$target_file"

        log_success "  → $target_file"
    done
else
    log_warning "No .claude/commands directory found"
fi

echo ""
echo "=== Claude Code reverse sync complete ==="
