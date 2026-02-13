#!/bin/bash

# Cursor から .agents への逆変換スクリプト
# .cursor/ の形式から .agents/ 統一形式に変換
#
# Frontmatter 変換:
#   Cursor (.mdc)         →  .agents (.md)
#   -----------------        ----------------
#   description: ...      →  description: ...
#   globs: "**/*.ts"      →  paths: "**/*.ts"
#   alwaysApply: true     →  (削除)
#   (ファイル名)          →  name: {filename}

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
AGENTS_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
REPO_ROOT="$(cd "$AGENTS_DIR/.." && pwd)"
CURSOR_DIR="$REPO_ROOT/.cursor"

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

echo "=== Reverse sync from Cursor to .agents ==="
echo "Source: $CURSOR_DIR"
echo "Target: $AGENTS_DIR"
echo ""

# Rules の逆変換
echo "Converting Rules from Cursor..."
if [ -d "$CURSOR_DIR/rules" ]; then
    find "$CURSOR_DIR/rules" -type f -name "*.mdc" 2>/dev/null | sort | while read -r cursor_file; do
        filename=$(basename "$cursor_file" .mdc)
        target_file="$AGENTS_DIR/rules/${filename}.md"

        # _base などの特殊ファイルはスキップ
        if [[ "$filename" == _* ]]; then
            log_info "Skipping special file: ${filename}.mdc"
            continue
        fi

        # すでに .agents に存在する場合はスキップ（上書き防止）
        if [ -f "$target_file" ]; then
            log_warning "[${filename}] Already exists in .agents/rules/ - skipping (use --force to overwrite)"
            continue
        fi

        echo "  Processing: ${filename}.mdc → ${filename}.md"

        # frontmatter を .agents 形式に変換
        awk -v filename="$filename" '
        BEGIN {
            in_frontmatter = 0;
            has_frontmatter = 0;
            description = "";
            paths = "";
            content = "";
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
                next;
            }
        }
        in_frontmatter {
            # description を取得
            if ($0 ~ /^description:/) {
                sub(/^description:\s*/, "");
                description = $0;
                next;
            }
            # globs を paths として取得
            if ($0 ~ /^globs:/) {
                sub(/^globs:\s*/, "");
                paths = $0;
                next;
            }
            # alwaysApply はスキップ
            if ($0 ~ /^alwaysApply:/) {
                next;
            }
            next;
        }
        after_frontmatter {
            content = content $0 "\n";
        }
        END {
            # .agents 形式で出力
            print "---";
            print "name: " filename;
            if (description != "") {
                print "description: " description;
            }
            if (paths != "") {
                print "paths: " paths;
            }
            print "---";
            print "";
            printf "%s", content;
        }
        ' "$cursor_file" > "$target_file"

        log_success "  → $target_file"
    done
else
    log_warning "No .cursor/rules directory found"
fi

# Note: Skills, Commands は Cursor が .claude/ から直接読み込むため、
# .cursor/ には存在しない。逆変換の対象外。
# Agents は .cursor/agents/ にシンボリックリンクとして存在するが、
# .agents/agents/ からの逆変換は from-claude.sh で行う。

echo ""
echo "=== Cursor reverse sync complete ==="
echo "Note: Only rules are synced. Skills, Commands, Agents are imported from .claude/"
