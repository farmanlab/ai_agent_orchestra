#!/bin/bash

# AI Agent 統一管理システム - メイン同期スクリプト
# .agents/ の統一形式から各エージェント向けに変換

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# カラー定義
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# オプション
VERBOSE=false
DRY_RUN=false

# ヘルプメッセージ
show_help() {
    cat << EOF
AI Agent Configuration Sync Script

Usage: $0 [OPTIONS] COMMAND

Commands:
  all             Sync to all agents (Claude, Cursor, Copilot)
  claude          Sync to Claude Code only
  cursor          Sync to Cursor only
  copilot         Sync to GitHub Copilot only
  validate        Validate .agents/ directory structure and content
  check-size      Check prompt file sizes and token counts
  check-quality   Check prompt quality and best practices
  init            Initialize directory structure
  install-hooks   Install git pre-commit hook
  clean           Remove all generated files
  prune <path>    Remove a file from .agents/ and all synced copies/symlinks

Options:
  --verbose       Show detailed output
  --dry-run       Show what would be done without making changes
  -h, --help      Show this help message

Examples:
  $0 all                    # Sync to all agents
  $0 claude                 # Sync to Claude Code only
  $0 validate               # Validate configuration files
  $0 check-size             # Check prompt file sizes
  $0 check-quality          # Check prompt quality
  $0 --dry-run all          # Show what would be synced
  $0 --verbose all          # Sync with detailed output
  $0 install-hooks          # Install git hooks
  $0 prune rules/foo.md     # Remove rules/foo.md and synced copies

EOF
    exit 0
}

# ログ関数
log_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

log_success() {
    echo -e "${GREEN}✓${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

log_error() {
    echo -e "${RED}✗${NC} $1"
}

log_verbose() {
    if [ "$VERBOSE" = true ]; then
        echo -e "${BLUE}  →${NC} $1"
    fi
}

# 初期化
init_dirs() {
    log_info "Initializing directory structure..."

    mkdir -p "$REPO_ROOT/.agents"/{rules,agents,commands,sync}
    log_success "Created .agents/ directory structure"

    mkdir -p "$REPO_ROOT/.claude"/{rules,agents,commands}
    log_success "Created .claude/ directory structure"

    mkdir -p "$REPO_ROOT/.cursor"/{rules,commands}
    log_success "Created .cursor/ directory structure"

    mkdir -p "$REPO_ROOT/.github"/{instructions,prompts}
    log_success "Created .github/ directory structure"

    log_success "Initialization complete"
}

# クリーンアップ
clean_generated() {
    log_info "Cleaning generated files..."

    if [ "$DRY_RUN" = true ]; then
        log_warning "DRY RUN: Would remove:"
        [ -d "$REPO_ROOT/.claude/rules" ] && echo "  .claude/rules/"
        [ -d "$REPO_ROOT/.claude/agents" ] && echo "  .claude/agents/"
        [ -d "$REPO_ROOT/.claude/commands" ] && echo "  .claude/commands/"
        [ -d "$REPO_ROOT/.cursor/rules" ] && echo "  .cursor/rules/"
        [ -d "$REPO_ROOT/.cursor/commands" ] && echo "  .cursor/commands/"
        [ -d "$REPO_ROOT/.github/instructions" ] && echo "  .github/instructions/"
        [ -d "$REPO_ROOT/.github/prompts" ] && echo "  .github/prompts/"
        [ -f "$REPO_ROOT/AGENTS.md" ] && echo "  AGENTS.md"
        [ -L "$REPO_ROOT/CLAUDE.md" ] && echo "  CLAUDE.md -> AGENTS.md"
        return
    fi

    rm -rf "$REPO_ROOT/.claude/rules" "$REPO_ROOT/.claude/agents" "$REPO_ROOT/.claude/commands"
    rm -rf "$REPO_ROOT/.cursor/rules" "$REPO_ROOT/.cursor/commands"
    rm -rf "$REPO_ROOT/.github/instructions" "$REPO_ROOT/.github/prompts"
    rm -f "$REPO_ROOT/CLAUDE.md" "$REPO_ROOT/AGENTS.md"

    log_success "Cleanup complete"
}

# 指定ファイルとシンボリックリンク/コピーを削除
prune_file() {
    local target_path="$1"

    if [ -z "$target_path" ]; then
        log_error "Usage: $0 prune <path>"
        log_error "Example: $0 prune rules/foo.md"
        exit 1
    fi

    # .agents/ プレフィックスを除去（あれば）
    target_path="${target_path#.agents/}"

    local source_file="$REPO_ROOT/.agents/$target_path"

    if [ ! -e "$source_file" ]; then
        log_error "File not found: .agents/$target_path"
        exit 1
    fi

    # ファイルタイプを判定（rules, agents, skills, commands）
    local file_type=$(echo "$target_path" | cut -d'/' -f1)
    local filename=$(basename "$target_path")
    local name_without_ext="${filename%.md}"

    log_info "Pruning: .agents/$target_path"

    # 削除対象を収集
    local targets=()
    targets+=("$source_file")

    case "$file_type" in
        rules)
            targets+=("$REPO_ROOT/.claude/rules/$filename")
            targets+=("$REPO_ROOT/.cursor/rules/$filename")
            # Copilot: rules は .github/instructions/*.instructions.md にマッピング
            targets+=("$REPO_ROOT/.github/instructions/${name_without_ext}.instructions.md")
            ;;
        agents)
            targets+=("$REPO_ROOT/.claude/agents/$filename")
            targets+=("$REPO_ROOT/.cursor/agents/$filename")
            # Copilot: agents は .github/agents/*.agents.md にマッピング
            targets+=("$REPO_ROOT/.github/agents/${name_without_ext}.agents.md")
            ;;
        skills)
            # skills はディレクトリの場合がある
            local skill_name=$(echo "$target_path" | cut -d'/' -f2)
            targets+=("$REPO_ROOT/.claude/skills/$skill_name")
            targets+=("$REPO_ROOT/.cursor/skills/$skill_name")
            targets+=("$REPO_ROOT/.github/skills/$skill_name")
            ;;
        commands)
            targets+=("$REPO_ROOT/.claude/commands/$filename")
            targets+=("$REPO_ROOT/.cursor/commands/$filename")
            targets+=("$REPO_ROOT/.github/prompts/$filename")
            ;;
        *)
            log_warning "Unknown file type: $file_type"
            ;;
    esac

    # 削除実行
    for target in "${targets[@]}"; do
        if [ -e "$target" ] || [ -L "$target" ]; then
            if [ "$DRY_RUN" = true ]; then
                log_warning "DRY RUN: Would remove $target"
            else
                rm -rf "$target"
                log_verbose "Removed: $target"
            fi
        fi
    done

    if [ "$DRY_RUN" = true ]; then
        log_warning "DRY RUN: No files were actually removed"
    else
        log_success "Prune complete: .agents/$target_path"
    fi
}

# Git hooks インストール
install_hooks() {
    log_info "Installing git pre-commit hook..."

    HOOK_FILE="$REPO_ROOT/.git/hooks/pre-commit"

    if [ -f "$HOOK_FILE" ]; then
        log_warning "pre-commit hook already exists"
        read -p "Overwrite? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log_info "Cancelled"
            return
        fi
    fi

    cat > "$HOOK_FILE" << 'EOF'
#!/bin/bash
# Auto-sync AI agent configurations

AGENTS_DIR=".agents"

if [ -d "$AGENTS_DIR" ]; then
    echo "Syncing AI agent configurations..."
    "$AGENTS_DIR/sync/sync.sh" all

    # Add generated files to commit
    git add .claude/ .cursor/ .github/ CLAUDE.md AGENTS.md 2>/dev/null || true
fi
EOF

    chmod +x "$HOOK_FILE"
    log_success "Git hook installed: $HOOK_FILE"
}

# Skills シンボリックリンク作成
create_skills_symlinks() {
    log_verbose "Creating skills symlinks..."

    # Claude Code
    if [ ! -L "$REPO_ROOT/.claude/skills" ]; then
        ln -sf ../.agents/skills "$REPO_ROOT/.claude/skills"
        log_verbose "Created .claude/skills symlink"
    fi

    # Cursor
    if [ ! -L "$REPO_ROOT/.cursor/skills" ]; then
        ln -sf ../.agents/skills "$REPO_ROOT/.cursor/skills"
        log_verbose "Created .cursor/skills symlink"
    fi
}

# Claude Code への同期
sync_to_claude() {
    log_info "Syncing to Claude Code..."

    if [ "$DRY_RUN" = true ]; then
        log_warning "DRY RUN: Would execute to-claude.sh"
        return
    fi

    if [ ! -f "$SCRIPT_DIR/to-claude.sh" ]; then
        log_error "to-claude.sh not found"
        return 1
    fi

    chmod +x "$SCRIPT_DIR/to-claude.sh"

    if [ "$VERBOSE" = true ]; then
        "$SCRIPT_DIR/to-claude.sh"
    else
        "$SCRIPT_DIR/to-claude.sh" > /dev/null 2>&1
    fi

    # Skills symlinks (file-level)
    mkdir -p "$REPO_ROOT/.claude/skills"
    for skill_dir in "$REPO_ROOT/.agents/skills"/*/; do
        if [ -d "$skill_dir" ]; then
            skill_name=$(basename "$skill_dir")
            target="$REPO_ROOT/.claude/skills/$skill_name"
            if [ ! -L "$target" ]; then
                ln -sf "../../.agents/skills/$skill_name" "$target"
                log_verbose "Created .claude/skills/$skill_name symlink"
            fi
        fi
    done

    # Agents symlinks (file-level)
    mkdir -p "$REPO_ROOT/.claude/agents"
    for agent_file in "$REPO_ROOT/.agents/agents"/*.md; do
        if [ -f "$agent_file" ]; then
            filename=$(basename "$agent_file")
            target="$REPO_ROOT/.claude/agents/$filename"
            if [ ! -L "$target" ]; then
                ln -sf "../../.agents/agents/$filename" "$target"
                log_verbose "Created .claude/agents/$filename symlink"
            fi
        fi
    done

    log_success "Claude Code sync complete"
}

# Cursor への同期
sync_to_cursor() {
    log_info "Syncing to Cursor..."

    if [ "$DRY_RUN" = true ]; then
        log_warning "DRY RUN: Would execute to-cursor.sh"
        return
    fi

    if [ ! -f "$SCRIPT_DIR/to-cursor.sh" ]; then
        log_error "to-cursor.sh not found"
        return 1
    fi

    chmod +x "$SCRIPT_DIR/to-cursor.sh"

    if [ "$VERBOSE" = true ]; then
        "$SCRIPT_DIR/to-cursor.sh"
    else
        "$SCRIPT_DIR/to-cursor.sh" > /dev/null 2>&1
    fi

    # Skills symlinks (file-level)
    mkdir -p "$REPO_ROOT/.cursor/skills"
    for skill_dir in "$REPO_ROOT/.agents/skills"/*/; do
        if [ -d "$skill_dir" ]; then
            skill_name=$(basename "$skill_dir")
            target="$REPO_ROOT/.cursor/skills/$skill_name"
            if [ ! -L "$target" ]; then
                ln -sf "../../.agents/skills/$skill_name" "$target"
                log_verbose "Created .cursor/skills/$skill_name symlink"
            fi
        fi
    done

    # Agents symlinks (file-level)
    mkdir -p "$REPO_ROOT/.cursor/agents"
    for agent_file in "$REPO_ROOT/.agents/agents"/*.md; do
        if [ -f "$agent_file" ]; then
            filename=$(basename "$agent_file")
            target="$REPO_ROOT/.cursor/agents/$filename"
            if [ ! -L "$target" ]; then
                ln -sf "../../.agents/agents/$filename" "$target"
                log_verbose "Created .cursor/agents/$filename symlink"
            fi
        fi
    done

    log_success "Cursor sync complete"
}

# Copilot への同期
sync_to_copilot() {
    log_info "Syncing to GitHub Copilot..."

    if [ "$DRY_RUN" = true ]; then
        log_warning "DRY RUN: Would execute to-copilot.sh"
        return
    fi

    if [ ! -f "$SCRIPT_DIR/to-copilot.sh" ]; then
        log_error "to-copilot.sh not found"
        return 1
    fi

    chmod +x "$SCRIPT_DIR/to-copilot.sh"

    if [ "$VERBOSE" = true ]; then
        "$SCRIPT_DIR/to-copilot.sh"
    else
        "$SCRIPT_DIR/to-copilot.sh" > /dev/null 2>&1
    fi

    # Skills symlinks (file-level)
    mkdir -p "$REPO_ROOT/.github/skills"
    for skill_dir in "$REPO_ROOT/.agents/skills"/*/; do
        if [ -d "$skill_dir" ]; then
            skill_name=$(basename "$skill_dir")
            target="$REPO_ROOT/.github/skills/$skill_name"
            if [ ! -L "$target" ]; then
                ln -sf "../../.agents/skills/$skill_name" "$target"
                log_verbose "Created .github/skills/$skill_name symlink"
            fi
        fi
    done

    # Agents symlinks (file-level, renamed to *.agents.md)
    mkdir -p "$REPO_ROOT/.github/agents"
    for agent_file in "$REPO_ROOT/.agents/agents"/*.md; do
        if [ -f "$agent_file" ]; then
            filename=$(basename "$agent_file" .md)
            target="$REPO_ROOT/.github/agents/${filename}.agents.md"
            if [ ! -L "$target" ]; then
                ln -sf "../../.agents/agents/${filename}.md" "$target"
                log_verbose "Created .github/agents/${filename}.agents.md symlink"
            fi
        fi
    done

    log_success "GitHub Copilot sync complete"
}

# 全エージェントへの同期
sync_all() {
    echo ""
    echo "========================================"
    echo "  AI Agent Configuration Sync"
    echo "========================================"
    echo ""

    sync_to_claude
    echo ""
    sync_to_cursor
    echo ""
    sync_to_copilot

    echo ""
    log_success "All agents synced successfully"
    echo ""
}

# バリデーション実行
run_validation() {
    log_info "Running validation..."

    if [ ! -f "$SCRIPT_DIR/validate.sh" ]; then
        log_error "validate.sh not found"
        return 1
    fi

    chmod +x "$SCRIPT_DIR/validate.sh"
    "$SCRIPT_DIR/validate.sh"
}

# サイズチェック実行
run_size_check() {
    log_info "Running size check..."

    if [ ! -f "$SCRIPT_DIR/check-size.sh" ]; then
        log_error "check-size.sh not found"
        return 1
    fi

    chmod +x "$SCRIPT_DIR/check-size.sh"
    "$SCRIPT_DIR/check-size.sh"
}

# 品質チェック実行
run_quality_check() {
    log_info "Running quality check..."

    if [ ! -f "$SCRIPT_DIR/check-quality.sh" ]; then
        log_error "check-quality.sh not found"
        return 1
    fi

    chmod +x "$SCRIPT_DIR/check-quality.sh"
    "$SCRIPT_DIR/check-quality.sh"
}

# オプション解析
while [[ $# -gt 0 ]]; do
    case $1 in
        --verbose)
            VERBOSE=true
            shift
            ;;
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        -h|--help)
            show_help
            ;;
        all|claude|cursor|copilot|validate|check-size|check-quality|init|install-hooks|clean)
            COMMAND=$1
            shift
            ;;
        prune)
            COMMAND=$1
            shift
            PRUNE_TARGET="$1"
            shift 2>/dev/null || true
            ;;
        *)
            log_error "Unknown option: $1"
            show_help
            ;;
    esac
done

# コマンド実行
case $COMMAND in
    all)
        sync_all
        ;;
    claude)
        sync_to_claude
        ;;
    cursor)
        sync_to_cursor
        ;;
    copilot)
        sync_to_copilot
        ;;
    validate)
        run_validation
        ;;
    check-size)
        run_size_check
        ;;
    check-quality)
        run_quality_check
        ;;
    init)
        init_dirs
        ;;
    install-hooks)
        install_hooks
        ;;
    clean)
        clean_generated
        ;;
    prune)
        prune_file "$PRUNE_TARGET"
        ;;
    *)
        log_error "No command specified"
        show_help
        ;;
esac
