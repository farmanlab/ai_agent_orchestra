#!/bin/bash

# 逆同期スクリプト
# 各エージェントディレクトリから .agents/ への逆変換
#
# 使用方法:
#   ./reverse-sync.sh [source] [--force]
#
# source:
#   all     - すべてのエージェントから逆sync（デフォルト）
#   claude  - Claude Code (.claude/) から逆sync
#   cursor  - Cursor (.cursor/) から逆sync
#   copilot - GitHub Copilot (.github/) から逆sync
#
# オプション:
#   --force - 既存ファイルを上書き
#   --dry-run - 実際には変換せず、対象ファイルを表示

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
AGENTS_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
REPO_ROOT="$(cd "$AGENTS_DIR/.." && pwd)"

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

# 引数解析
SOURCE="all"
FORCE=false
DRY_RUN=false

for arg in "$@"; do
    case $arg in
        --force)
            FORCE=true
            shift
            ;;
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        claude|cursor|copilot|all)
            SOURCE="$arg"
            shift
            ;;
        --help|-h)
            echo "Usage: $0 [source] [--force] [--dry-run]"
            echo ""
            echo "Sources:"
            echo "  all     - Reverse sync from all agents (default)"
            echo "  claude  - Reverse sync from Claude Code (.claude/)"
            echo "  cursor  - Reverse sync from Cursor (.cursor/)"
            echo "  copilot - Reverse sync from GitHub Copilot (.github/)"
            echo ""
            echo "Options:"
            echo "  --force   - Overwrite existing files"
            echo "  --dry-run - Show what would be done without making changes"
            exit 0
            ;;
        *)
            ;;
    esac
done

echo ""
echo "========================================"
echo "  Reverse Sync to .agents/"
echo "========================================"
echo ""
echo "Source: $SOURCE"
echo "Force overwrite: $FORCE"
echo "Dry run: $DRY_RUN"
echo ""

# フォースモードの場合、環境変数を設定
if [ "$FORCE" = true ]; then
    export REVERSE_SYNC_FORCE=true
fi

if [ "$DRY_RUN" = true ]; then
    export REVERSE_SYNC_DRY_RUN=true
fi

# 逆sync実行
case $SOURCE in
    all)
        log_info "Running reverse sync from all agents..."
        echo ""

        # Claude から逆sync
        if [ -d "$REPO_ROOT/.claude" ]; then
            bash "$SCRIPT_DIR/from-claude.sh"
            echo ""
        else
            log_warning "No .claude/ directory found - skipping"
        fi

        # Cursor から逆sync
        if [ -d "$REPO_ROOT/.cursor" ]; then
            bash "$SCRIPT_DIR/from-cursor.sh"
            echo ""
        else
            log_warning "No .cursor/ directory found - skipping"
        fi

        # Copilot から逆sync
        if [ -d "$REPO_ROOT/.github" ]; then
            bash "$SCRIPT_DIR/from-copilot.sh"
            echo ""
        else
            log_warning "No .github/ directory found - skipping"
        fi
        ;;
    claude)
        if [ -d "$REPO_ROOT/.claude" ]; then
            bash "$SCRIPT_DIR/from-claude.sh"
        else
            log_error "No .claude/ directory found"
            exit 1
        fi
        ;;
    cursor)
        if [ -d "$REPO_ROOT/.cursor" ]; then
            bash "$SCRIPT_DIR/from-cursor.sh"
        else
            log_error "No .cursor/ directory found"
            exit 1
        fi
        ;;
    copilot)
        if [ -d "$REPO_ROOT/.github" ]; then
            bash "$SCRIPT_DIR/from-copilot.sh"
        else
            log_error "No .github/ directory found"
            exit 1
        fi
        ;;
esac

echo ""
echo "========================================"
echo "  Reverse Sync Complete"
echo "========================================"
echo ""

# 検証を実行
log_info "Running validation..."
echo ""
bash "$SCRIPT_DIR/validate.sh" || true

echo ""
log_success "Reverse sync completed!"
echo ""
echo "Next steps:"
echo "  1. Review the imported files in .agents/"
echo "  2. Run './sync.sh all' to sync back to all agents"
echo "  3. Commit the changes"
