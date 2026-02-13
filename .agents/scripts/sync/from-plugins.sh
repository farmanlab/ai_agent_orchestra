#!/bin/bash

# Claude Code プラグインから skills/agents/commands を取り込む
# enabledPlugins の情報を元に .agents/plugins/ にシンボリックリンクを作成

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

# オプション
VERBOSE=false
DRY_RUN=false
COPY_MODE=false
SCOPE="all"  # project|user|all

# ログ関数
log_info() { echo -e "${BLUE}ℹ${NC} $1" >&2; }
log_success() { echo -e "${GREEN}✓${NC} $1" >&2; }
log_warning() { echo -e "${YELLOW}⚠${NC} $1" >&2; }
log_error() { echo -e "${RED}✗${NC} $1" >&2; }
log_verbose() { [ "$VERBOSE" = true ] && echo -e "${BLUE}  →${NC} $1" >&2; }

# ヘルプ
show_help() {
    cat << EOF
Plugin Sync Script - Import skills/agents/commands from Claude Code plugins

Usage: $0 [OPTIONS]

Options:
  --scope <project|user|all>  Scope to process (default: all)
  --dry-run                   Show what would be done without making changes
  --copy                      Copy files instead of creating symlinks
  --verbose                   Show detailed output
  -h, --help                  Show this help message

Examples:
  $0                          # Sync all scopes
  $0 --scope project          # Project plugins only
  $0 --scope user             # User plugins only
  $0 --dry-run                # Preview changes
EOF
    exit 0
}

# installed_plugins.json のパス
INSTALLED_PLUGINS_JSON="$HOME/.claude/plugins/installed_plugins.json"

# jq の存在確認
check_jq() {
    if ! command -v jq &> /dev/null; then
        log_error "jq is required but not installed. Install with: brew install jq"
        exit 1
    fi
}

# settings.json から enabledPlugins を取得
# $1: settings.json のパス
get_enabled_plugins() {
    local settings_file="$1"
    if [ ! -f "$settings_file" ]; then
        log_verbose "Settings file not found: $settings_file"
        return
    fi

    jq -r '.enabledPlugins // {} | to_entries[] | select(.value == true) | .key' "$settings_file" 2>/dev/null
}

# プラグイン名からインストールパスを取得
# $1: プラグイン識別子 (例: context7@claude-plugins-official)
get_install_path() {
    local plugin_id="$1"
    if [ ! -f "$INSTALLED_PLUGINS_JSON" ]; then
        log_verbose "installed_plugins.json not found"
        return
    fi

    # 最新のインストールパスを取得（配列の最後のエントリ）
    jq -r --arg id "$plugin_id" \
        '.plugins[$id] // [] | last | .installPath // empty' \
        "$INSTALLED_PLUGINS_JSON" 2>/dev/null
}

# プラグインの短縮名を取得 (@ の前の部分)
get_plugin_short_name() {
    echo "$1" | cut -d'@' -f1
}

# プラグイン内の同期対象ディレクトリを検出
# $1: プラグインのインストールパス
# 出力: 見つかったコンポーネントタイプ (skills, agents, commands) を改行区切りで出力
detect_components() {
    local install_path="$1"
    for component in skills agents commands; do
        if [ -d "$install_path/$component" ]; then
            # 中身が空でないか確認
            if [ -n "$(ls -A "$install_path/$component" 2>/dev/null)" ]; then
                echo "$component"
            fi
        fi
    done
}

# 名前の衝突チェック
# $1: コンポーネントタイプ (skills, agents, commands)
# $2: コンポーネント名
# $3: 出力先ルート (.agents/ のパス)
check_name_conflict() {
    local component_type="$1"
    local component_name="$2"
    local agents_root="$3"

    if [ -e "$agents_root/$component_type/$component_name" ] && \
       [ ! -L "$agents_root/$component_type/$component_name" ]; then
        return 0  # 衝突あり
    fi
    return 1  # 衝突なし
}

# シンボリックリンクまたはコピーを作成
# $1: ソースパス
# $2: ターゲットパス
create_link_or_copy() {
    local source="$1"
    local target="$2"

    if [ "$DRY_RUN" = true ]; then
        if [ "$COPY_MODE" = true ]; then
            log_info "DRY RUN: Would copy $source → $target"
        else
            log_info "DRY RUN: Would symlink $target → $source"
        fi
        return
    fi

    # 既存のシンボリックリンクを削除
    if [ -L "$target" ]; then
        rm "$target"
    fi

    if [ "$COPY_MODE" = true ]; then
        cp -R "$source" "$target"
        log_verbose "Copied: $source → $target"
    else
        ln -sf "$source" "$target"
        log_verbose "Symlinked: $target → $source"
    fi
}

# スコープに対してプラグイン同期を実行
# $1: scope (project|user)
sync_scope() {
    local scope="$1"
    local settings_file
    local output_root

    case "$scope" in
        project)
            settings_file="$REPO_ROOT/.claude/settings.json"
            output_root="$AGENTS_DIR/plugins"
            ;;
        user)
            settings_file="$HOME/.claude/settings.json"
            output_root="$HOME/.agents/plugins"
            ;;
        *)
            log_error "Invalid scope: $scope"
            return 1
            ;;
    esac

    log_info "Processing $scope scope..."

    # enabledPlugins を取得
    local plugins
    plugins=$(get_enabled_plugins "$settings_file")

    if [ -z "$plugins" ]; then
        log_verbose "No enabled plugins found for $scope scope"
        return 0
    fi

    # 出力ディレクトリを作成
    if [ "$DRY_RUN" != true ]; then
        mkdir -p "$output_root"
    fi

    local synced_count=0
    local skipped_count=0

    while IFS= read -r plugin_id; do
        [ -z "$plugin_id" ] && continue

        local short_name
        short_name=$(get_plugin_short_name "$plugin_id")

        log_verbose "Checking plugin: $plugin_id (short: $short_name)"

        # インストールパスを取得
        local install_path
        install_path=$(get_install_path "$plugin_id")

        if [ -z "$install_path" ]; then
            log_warning "Install path not found for: $plugin_id"
            continue
        fi

        if [ ! -d "$install_path" ]; then
            log_warning "Install path does not exist: $install_path"
            continue
        fi

        log_verbose "Install path: $install_path"

        # コンポーネントを検出
        local components
        components=$(detect_components "$install_path")

        if [ -z "$components" ]; then
            log_verbose "No skills/agents/commands found in: $plugin_id"
            continue
        fi

        # プラグインの出力ディレクトリを作成
        local plugin_output="$output_root/$short_name"
        if [ "$DRY_RUN" != true ]; then
            mkdir -p "$plugin_output"
        fi

        while IFS= read -r component_type; do
            [ -z "$component_type" ] && continue

            local source_dir="$install_path/$component_type"
            local target="$plugin_output/$component_type"

            # .agents/ 本体との名前衝突チェック
            local agents_root
            if [ "$scope" = "project" ]; then
                agents_root="$AGENTS_DIR"
            else
                agents_root="$HOME/.agents"
            fi

            # 各コンポーネント内のアイテムをチェック
            local has_conflict=false
            for item in "$source_dir"/*; do
                [ -e "$item" ] || continue
                local item_name
                item_name=$(basename "$item")
                if check_name_conflict "$component_type" "$item_name" "$agents_root"; then
                    log_warning "Name conflict: $component_type/$item_name (plugin: $short_name) — skipped"
                    has_conflict=true
                fi
            done

            # ディレクトリレベルでシンボリックリンク作成
            create_link_or_copy "$source_dir" "$target"
            synced_count=$((synced_count + 1))

        done <<< "$components"

        log_success "Plugin synced: $short_name ($scope)"

    done <<< "$plugins"

    if [ $synced_count -eq 0 ]; then
        log_verbose "No plugin components to sync for $scope scope"
    else
        log_success "$scope: $synced_count component(s) synced"
    fi
}

# 孤立プラグインディレクトリの検出と削除
# .agents/plugins/ にあるが enabledPlugins にないプラグインを検出
cleanup_orphaned_plugins() {
    local scope="$1"
    local settings_file
    local output_root

    case "$scope" in
        project)
            settings_file="$REPO_ROOT/.claude/settings.json"
            output_root="$AGENTS_DIR/plugins"
            ;;
        user)
            settings_file="$HOME/.claude/settings.json"
            output_root="$HOME/.agents/plugins"
            ;;
    esac

    [ ! -d "$output_root" ] && return 0

    # 有効なプラグインの短縮名リストを取得
    local enabled_names=""
    if [ -f "$settings_file" ]; then
        enabled_names=$(get_enabled_plugins "$settings_file" | while IFS= read -r id; do
            get_plugin_short_name "$id"
        done)
    fi

    for plugin_dir in "$output_root"/*/; do
        [ -d "$plugin_dir" ] || continue
        local dir_name
        dir_name=$(basename "$plugin_dir")

        if ! echo "$enabled_names" | grep -qx "$dir_name"; then
            if [ "$DRY_RUN" = true ]; then
                log_warning "DRY RUN: Would remove orphaned plugin dir: $plugin_dir"
            else
                rm -rf "$plugin_dir"
                log_verbose "Removed orphaned plugin dir: $plugin_dir"
            fi
        fi
    done
}

# メイン処理
main() {
    check_jq

    log_info "Syncing Claude Code plugins..."

    case "$SCOPE" in
        all)
            sync_scope "project"
            sync_scope "user"
            cleanup_orphaned_plugins "project"
            cleanup_orphaned_plugins "user"
            ;;
        project|user)
            sync_scope "$SCOPE"
            cleanup_orphaned_plugins "$SCOPE"
            ;;
        *)
            log_error "Invalid scope: $SCOPE"
            exit 1
            ;;
    esac

    log_success "Plugin sync complete"
}

# オプション解析
while [[ $# -gt 0 ]]; do
    case $1 in
        --scope)
            SCOPE="$2"
            shift 2
            ;;
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --copy)
            COPY_MODE=true
            shift
            ;;
        --verbose)
            VERBOSE=true
            shift
            ;;
        -h|--help)
            show_help
            ;;
        *)
            log_error "Unknown option: $1"
            show_help
            ;;
    esac
done

main
