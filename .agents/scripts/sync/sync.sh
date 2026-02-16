#!/bin/bash

# AI Agent 統一管理システム - メイン同期スクリプト
# .agents/ の統一形式から各エージェント向けに変換

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
AGENTS_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
REPO_ROOT="$(cd "$AGENTS_DIR/.." && pwd)"
AGENTS_NAME="$(basename "$AGENTS_DIR")"

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
  all             Sync to all agents (Claude, Copilot)
  claude          Sync to Claude Code only
  copilot         Sync to GitHub Copilot only
  reverse         Reverse sync from other agents to .agents/
  reverse-claude  Reverse sync from Claude Code to .agents/
  reverse-copilot Reverse sync from GitHub Copilot to .agents/
  validate        Validate .agents/ directory structure and content
  check-size      Check prompt file sizes and token counts
  check-quality   Check prompt quality and best practices
  init            Initialize directory structure
  install-hooks   Install git pre-commit hook
  clean           Remove all generated files
  plugins         Sync Claude Code plugins to .agents/plugins/
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
  $0 plugins                 # Sync plugins to .agents/plugins/
  $0 --dry-run plugins        # Preview plugin sync
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

# エージェント有効判定（config.yaml ベース）
# config.yaml が無い場合はデフォルトで全エージェント有効
is_agent_enabled() {
    local agent_name="$1"
    local config_file="$AGENTS_DIR/config.yaml"

    if [ ! -f "$config_file" ]; then
        return 0  # config なし → 全有効
    fi

    # grep ベースで enabled: false を検出
    # agents: セクション内で、指定エージェント直下の enabled: false を探す
    local in_agent=false
    while IFS= read -r line; do
        if echo "$line" | grep -q "^  ${agent_name}:"; then
            in_agent=true
            continue
        fi
        if [ "$in_agent" = true ]; then
            if echo "$line" | grep -q "^    enabled: false"; then
                return 1  # 無効
            fi
            if echo "$line" | grep -q "^  [a-z]"; then
                break  # 次のエージェントセクションに入った
            fi
        fi
    done < "$config_file"

    return 0  # デフォルト有効
}

# 初期化
init_dirs() {
    log_info "Initializing directory structure..."

    mkdir -p "$AGENTS_DIR"/{rules,agents,commands,sync}
    log_success "Created $(basename "$AGENTS_DIR")/ directory structure"

    mkdir -p "$REPO_ROOT/.claude"/{rules,agents,commands}
    log_success "Created .claude/ directory structure"

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
        [ -d "$REPO_ROOT/.github/instructions" ] && echo "  .github/instructions/"
        [ -d "$REPO_ROOT/.github/prompts" ] && echo "  .github/prompts/"
        [ -f "$REPO_ROOT/AGENTS.md" ] && echo "  AGENTS.md"
        [ -L "$REPO_ROOT/CLAUDE.md" ] && echo "  CLAUDE.md -> AGENTS.md"
        return
    fi

    rm -rf "$REPO_ROOT/.claude/rules" "$REPO_ROOT/.claude/agents" "$REPO_ROOT/.claude/commands"
    rm -rf "$REPO_ROOT/.github/instructions" "$REPO_ROOT/.github/prompts"
    rm -f "$REPO_ROOT/CLAUDE.md" "$REPO_ROOT/AGENTS.md"

    log_success "Cleanup complete"
}

# 孤立ファイルを検出（.agents/ に対応するソースがないファイル）
# 結果は ORPHANED_FILES 配列に格納
declare -a ORPHANED_FILES=()

detect_orphaned_files() {
    ORPHANED_FILES=()

    # Claude Code: rules
    if [ -d "$REPO_ROOT/.claude/rules" ]; then
        for file in "$REPO_ROOT/.claude/rules"/*.md; do
            [ -e "$file" ] || continue
            filename=$(basename "$file" .md)
            if [ ! -f "$AGENTS_DIR/rules/${filename}.md" ]; then
                ORPHANED_FILES+=("$file")
            fi
        done
    fi

    # Claude Code: agents
    if [ -d "$REPO_ROOT/.claude/agents" ]; then
        for file in "$REPO_ROOT/.claude/agents"/*.md; do
            [ -e "$file" ] || continue
            filename=$(basename "$file")
            if [ ! -f "$AGENTS_DIR/agents/$filename" ]; then
                ORPHANED_FILES+=("$file")
            fi
        done
    fi

    # Claude Code: commands
    if [ -d "$REPO_ROOT/.claude/commands" ]; then
        for file in "$REPO_ROOT/.claude/commands"/*.md; do
            [ -e "$file" ] || continue
            filename=$(basename "$file")
            if [ ! -f "$AGENTS_DIR/commands/$filename" ]; then
                ORPHANED_FILES+=("$file")
            fi
        done
    fi

    # Claude Code: skills (directories)
    if [ -d "$REPO_ROOT/.claude/skills" ]; then
        for dir in "$REPO_ROOT/.claude/skills"/*/; do
            [ -d "$dir" ] || continue
            dirname=$(basename "$dir")
            if [ ! -d "$AGENTS_DIR/skills/$dirname" ]; then
                ORPHANED_FILES+=("$dir")
            fi
        done
    fi

    # GitHub Copilot: instructions (.instructions.md)
    if [ -d "$REPO_ROOT/.github/instructions" ]; then
        for file in "$REPO_ROOT/.github/instructions"/*.instructions.md; do
            [ -e "$file" ] || continue
            filename=$(basename "$file" .instructions.md)
            if [ ! -f "$AGENTS_DIR/rules/${filename}.md" ]; then
                ORPHANED_FILES+=("$file")
            fi
        done
    fi

    # GitHub Copilot: prompts (commands) - .prompt.md extension
    if [ -d "$REPO_ROOT/.github/prompts" ]; then
        for file in "$REPO_ROOT/.github/prompts"/*.prompt.md; do
            [ -e "$file" ] || continue
            # foo.prompt.md -> foo.md
            filename=$(basename "$file" .prompt.md)
            if [ ! -f "$AGENTS_DIR/commands/${filename}.md" ]; then
                ORPHANED_FILES+=("$file")
            fi
        done
    fi

    # GitHub Copilot: agents (.agents.md)
    if [ -d "$REPO_ROOT/.github/agents" ]; then
        for file in "$REPO_ROOT/.github/agents"/*.agents.md; do
            [ -e "$file" ] || continue
            filename=$(basename "$file" .agents.md)
            if [ ! -f "$AGENTS_DIR/agents/${filename}.md" ]; then
                ORPHANED_FILES+=("$file")
            fi
        done
    fi
}

# 孤立ファイルを確認付きで削除
cleanup_orphaned_files() {
    detect_orphaned_files

    if [ ${#ORPHANED_FILES[@]} -eq 0 ]; then
        log_verbose "No orphaned files found"
        return 0
    fi

    echo ""
    log_warning "Found ${#ORPHANED_FILES[@]} orphaned file(s) (no source in $AGENTS_NAME/):"
    echo ""
    for file in "${ORPHANED_FILES[@]}"; do
        # REPO_ROOT からの相対パスを表示
        relative_path="${file#$REPO_ROOT/}"
        echo "  - $relative_path"
    done
    echo ""

    if [ "$DRY_RUN" = true ]; then
        log_warning "DRY RUN: Would prompt to delete these files"
        return 0
    fi

    # 確認プロンプト
    printf "Delete these orphaned files? [y/N]: "
    read -r response
    case "$response" in
        [yY][eE][sS]|[yY])
            for file in "${ORPHANED_FILES[@]}"; do
                rm -rf "$file"
                relative_path="${file#$REPO_ROOT/}"
                log_verbose "Deleted: $relative_path"
            done
            log_success "Deleted ${#ORPHANED_FILES[@]} orphaned file(s)"

            ;;
        *)
            log_info "Skipped deletion of orphaned files"
            ;;
    esac
}

# 指定ファイルとシンボリックリンク/コピーを削除
prune_file() {
    local target_path="$1"

    if [ -z "$target_path" ]; then
        log_error "Usage: $0 prune <path>"
        log_error "Example: $0 prune rules/foo.md"
        exit 1
    fi

    # agents dir プレフィックスを除去（あれば）
    target_path="${target_path#${AGENTS_NAME}/}"

    local source_file="$AGENTS_DIR/$target_path"

    if [ ! -e "$source_file" ]; then
        log_error "File not found: $AGENTS_NAME/$target_path"
        exit 1
    fi

    # ファイルタイプを判定（rules, agents, skills, commands）
    local file_type=$(echo "$target_path" | cut -d'/' -f1)
    local filename=$(basename "$target_path")
    local name_without_ext="${filename%.md}"

    log_info "Pruning: $AGENTS_NAME/$target_path"

    # 削除対象を収集
    local targets=()
    targets+=("$source_file")

    case "$file_type" in
        rules)
            targets+=("$REPO_ROOT/.claude/rules/$filename")
            # Copilot: rules は .github/instructions/*.instructions.md にマッピング
            targets+=("$REPO_ROOT/.github/instructions/${name_without_ext}.instructions.md")
            ;;
        agents)
            targets+=("$REPO_ROOT/.claude/agents/$filename")
            # Copilot: agents は .github/agents/*.agents.md にマッピング
            targets+=("$REPO_ROOT/.github/agents/${name_without_ext}.agents.md")
            ;;
        skills)
            # skills はディレクトリの場合がある
            local skill_name=$(echo "$target_path" | cut -d'/' -f2)
            targets+=("$REPO_ROOT/.claude/skills/$skill_name")
            targets+=("$REPO_ROOT/.github/skills/$skill_name")
            ;;
        commands)
            targets+=("$REPO_ROOT/.claude/commands/$filename")
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
        log_success "Prune complete: $AGENTS_NAME/$target_path"
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
    git add .claude/ .github/ CLAUDE.md AGENTS.md 2>/dev/null || true
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
        ln -sf ../$AGENTS_NAME/skills "$REPO_ROOT/.claude/skills"
        log_verbose "Created .claude/skills symlink"
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
    # .claude/skills がディレクトリレベルのシンボリックリンクの場合はスキップ
    if [ -L "$REPO_ROOT/.claude/skills" ]; then
        log_verbose ".claude/skills is a directory symlink to $AGENTS_NAME/skills — skipping individual symlinks"
    else
        mkdir -p "$REPO_ROOT/.claude/skills"
        for skill_dir in "$AGENTS_DIR/skills"/*/; do
            if [ -d "$skill_dir" ]; then
                skill_name=$(basename "$skill_dir")
                target="$REPO_ROOT/.claude/skills/$skill_name"
                # 既存のディレクトリやファイルを削除してからシンボリックリンクを作成
                if [ -e "$target" ] && [ ! -L "$target" ]; then
                    rm -rf "$target"
                    log_verbose "Removed existing directory/file: $target"
                fi
                # 壊れたシンボリックリンクを削除
                if [ -L "$target" ] && [ ! -e "$target" ]; then
                    rm "$target"
                    log_verbose "Removed broken symlink: $target"
                fi
                if [ ! -L "$target" ]; then
                    ln -sf "../../$AGENTS_NAME/skills/$skill_name" "$target"
                    log_verbose "Created .claude/skills/$skill_name symlink"
                fi
            fi
        done
    fi

    # Agents symlinks (file-level)
    # .claude/agents がディレクトリレベルのシンボリックリンクの場合はスキップ
    if [ -L "$REPO_ROOT/.claude/agents" ]; then
        log_verbose ".claude/agents is a directory symlink to $AGENTS_NAME/agents — skipping individual symlinks"
    else
        mkdir -p "$REPO_ROOT/.claude/agents"
        for agent_file in "$AGENTS_DIR/agents"/*.md; do
            if [ -f "$agent_file" ]; then
                filename=$(basename "$agent_file")
                target="$REPO_ROOT/.claude/agents/$filename"
                # 壊れたシンボリックリンクを削除
                if [ -L "$target" ] && [ ! -e "$target" ]; then
                    rm "$target"
                    log_verbose "Removed broken symlink: $target"
                fi
                if [ ! -L "$target" ]; then
                    ln -sf "../../$AGENTS_NAME/agents/$filename" "$target"
                    log_verbose "Created .claude/agents/$filename symlink"
                fi
            fi
        done
    fi

    # Plugin components: skills
    if [ -L "$REPO_ROOT/.claude/skills" ]; then
        log_verbose "Skipping plugin skills for .claude/ (directory symlink)"
    else
        sync_plugin_components "$REPO_ROOT/.claude/skills" "skills"
    fi

    # Plugin components: agents
    if [ -L "$REPO_ROOT/.claude/agents" ]; then
        log_verbose "Skipping plugin agents for .claude/ (directory symlink)"
    else
        sync_plugin_components "$REPO_ROOT/.claude/agents" "agents"
    fi

    # Plugin components: commands
    mkdir -p "$REPO_ROOT/.claude/commands"
    sync_plugin_components "$REPO_ROOT/.claude/commands" "commands"

    log_success "Claude Code sync complete"
}

# プラグイン同期
sync_plugins() {
    local settings_file="$REPO_ROOT/.claude/settings.json"
    if [ ! -f "$settings_file" ]; then
        log_verbose "No .claude/settings.json — skipping plugin sync"
        return 0
    fi

    log_info "Syncing Claude Code plugins..."

    local plugin_script="$SCRIPT_DIR/from-plugins.sh"

    if [ ! -f "$plugin_script" ]; then
        log_warning "from-plugins.sh not found — skipping plugin sync"
        return 0
    fi

    chmod +x "$plugin_script"

    local args=("--scope" "project")
    [ "$VERBOSE" = true ] && args+=("--verbose")
    [ "$DRY_RUN" = true ] && args+=("--dry-run")

    "$plugin_script" "${args[@]}"
}

# プラグインコンポーネントのシンボリックリンク作成ヘルパー
# $1: 対象ディレクトリ (例: .claude, .github)
# $2: コンポーネントタイプ (skills, agents, commands)
# $3: リンク作成関数名またはサフィックス変換パターン
sync_plugin_components() {
    local target_root="$1"
    local component_type="$2"
    local rename_pattern="${3:-}" # 省略時はそのまま

    local plugins_dir="$AGENTS_DIR/plugins"
    [ ! -d "$plugins_dir" ] && return 0

    for plugin_dir in "$plugins_dir"/*/; do
        [ -d "$plugin_dir" ] || continue
        local plugin_name
        plugin_name=$(basename "$plugin_dir")

        local component_source="$plugin_dir/$component_type"
        # シンボリックリンクの場合はリンク先を確認
        if [ -L "$component_source" ]; then
            [ ! -e "$component_source" ] && continue
        elif [ ! -d "$component_source" ]; then
            continue
        fi

        # コンポーネント内の各アイテムをリンク
        for item in "$component_source"/*; do
            [ -e "$item" ] || continue
            local item_name
            item_name=$(basename "$item")
            local target

            case "$rename_pattern" in
                "agents.md")
                    # .github/agents/ 向け: foo.md → foo.agents.md
                    local name_without_ext="${item_name%.md}"
                    target="$target_root/${name_without_ext}.agents.md"
                    ;;
                "instructions.md")
                    # .github/instructions/ 向け: foo.md → foo.instructions.md
                    local name_without_ext="${item_name%.md}"
                    target="$target_root/${name_without_ext}.instructions.md"
                    ;;
                "prompt.md")
                    # .github/prompts/ 向け: foo.md → foo.prompt.md
                    local name_without_ext="${item_name%.md}"
                    target="$target_root/${name_without_ext}.prompt.md"
                    ;;
                *)
                    target="$target_root/$item_name"
                    ;;
            esac

            # 既にリンクが存在する場合はスキップ（壊れたリンクは削除）
            if [ -L "$target" ] && [ ! -e "$target" ]; then
                rm "$target"
            fi
            if [ -L "$target" ]; then
                continue
            fi
            # 実ファイル/ディレクトリが存在する場合はスキップ+警告
            if [ -e "$target" ]; then
                log_verbose "Plugin component skipped (exists): $target"
                continue
            fi

            if [ "$DRY_RUN" = true ]; then
                log_verbose "DRY RUN: Would symlink $target → $item"
            else
                ln -sf "$item" "$target"
                log_verbose "Plugin symlink: $target → $item (plugin: $plugin_name)"
            fi
        done
    done
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
    for skill_dir in "$AGENTS_DIR/skills"/*/; do
        if [ -d "$skill_dir" ]; then
            skill_name=$(basename "$skill_dir")
            target="$REPO_ROOT/.github/skills/$skill_name"
            # 既存のディレクトリやファイルを削除してからシンボリックリンクを作成
            if [ -e "$target" ] && [ ! -L "$target" ]; then
                rm -rf "$target"
                log_verbose "Removed existing directory/file: $target"
            fi
            # 壊れたシンボリックリンクを削除
            if [ -L "$target" ] && [ ! -e "$target" ]; then
                rm "$target"
                log_verbose "Removed broken symlink: $target"
            fi
            if [ ! -L "$target" ]; then
                ln -sf "../../$AGENTS_NAME/skills/$skill_name" "$target"
                log_verbose "Created .github/skills/$skill_name symlink"
            fi
        fi
    done

    # Agents symlinks (file-level, renamed to *.agents.md)
    mkdir -p "$REPO_ROOT/.github/agents"
    for agent_file in "$AGENTS_DIR/agents"/*.md; do
        if [ -f "$agent_file" ]; then
            filename=$(basename "$agent_file" .md)
            # 旧形式 (*.agent.md) のシンボリックリンクを削除
            old_target="$REPO_ROOT/.github/agents/${filename}.agent.md"
            [ -L "$old_target" ] && rm "$old_target"
            target="$REPO_ROOT/.github/agents/${filename}.agents.md"
            # 壊れたシンボリックリンクを削除
            if [ -L "$target" ] && [ ! -e "$target" ]; then
                rm "$target"
                log_verbose "Removed broken symlink: $target"
            fi
            if [ ! -L "$target" ]; then
                ln -sf "../../$AGENTS_NAME/agents/${filename}.md" "$target"
                log_verbose "Created .github/agents/${filename}.agents.md symlink"
            fi
        fi
    done

    # Plugin components: skills
    sync_plugin_components "$REPO_ROOT/.github/skills" "skills"

    # Plugin components: agents (renamed to *.agents.md)
    sync_plugin_components "$REPO_ROOT/.github/agents" "agents" "agents.md"

    # Plugin components: commands (renamed to *.prompt.md)
    mkdir -p "$REPO_ROOT/.github/prompts"
    sync_plugin_components "$REPO_ROOT/.github/prompts" "commands" "prompt.md"

    log_success "GitHub Copilot sync complete"
}

# 全エージェントへの同期
sync_all() {
    echo ""
    echo "========================================"
    echo "  AI Agent Configuration Sync"
    echo "========================================"
    echo ""

    sync_plugins
    echo ""

    if is_agent_enabled claude; then
        sync_to_claude
        echo ""
    else
        log_info "Claude Code sync skipped (disabled in config.yaml)"
        echo ""
    fi

    if is_agent_enabled copilot; then
        sync_to_copilot
    else
        log_info "GitHub Copilot sync skipped (disabled in config.yaml)"
    fi

    # 孤立ファイルの検出と確認付き削除
    cleanup_orphaned_files

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
        all|claude|copilot|plugins|reverse|reverse-claude|reverse-copilot|validate|check-size|check-quality|init|install-hooks|clean)
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
        cleanup_orphaned_files
        ;;
    copilot)
        sync_to_copilot
        cleanup_orphaned_files
        ;;
    plugins)
        sync_plugins
        ;;
    reverse)
        "$SCRIPT_DIR/reverse-sync.sh" all
        ;;
    reverse-claude)
        "$SCRIPT_DIR/reverse-sync.sh" claude
        ;;
    reverse-copilot)
        "$SCRIPT_DIR/reverse-sync.sh" copilot
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
