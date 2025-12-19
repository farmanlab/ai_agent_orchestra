#!/bin/bash

# AI Agent 統一管理システム - バリデーションスクリプト
# .agents/ の構造とコンテンツを検証

# Note: set -e is not used here to allow proper error counting

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
AGENTS_DIR="$REPO_ROOT/.agents"

# カラー定義
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 一時ファイルを使用してエラーカウントを管理（サブシェル対策）
ERROR_COUNT_FILE=$(mktemp)
WARNING_COUNT_FILE=$(mktemp)
echo "0" > "$ERROR_COUNT_FILE"
echo "0" > "$WARNING_COUNT_FILE"

# クリーンアップ
trap 'rm -f "$ERROR_COUNT_FILE" "$WARNING_COUNT_FILE"' EXIT

# ログ関数
log_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

log_success() {
    echo -e "${GREEN}✓${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
    local count=$(cat "$WARNING_COUNT_FILE")
    echo $((count + 1)) > "$WARNING_COUNT_FILE"
}

log_error() {
    echo -e "${RED}✗${NC} $1"
    local count=$(cat "$ERROR_COUNT_FILE")
    echo $((count + 1)) > "$ERROR_COUNT_FILE"
}

# YAML frontmatter を抽出
extract_frontmatter() {
    local file="$1"
    sed -n '/^---$/,/^---$/p' "$file" | sed '1d;$d'
}

# frontmatter からフィールド値を取得
get_field_value() {
    local frontmatter="$1"
    local field="$2"
    echo "$frontmatter" | grep "^${field}:" | sed "s/^${field}:\s*//" | sed 's/^[[:space:]]*//' | sed 's/[[:space:]]*$//'
}

# 配列フィールドを取得（例: agents: [claude, cursor, copilot]）
get_array_field() {
    local frontmatter="$1"
    local field="$2"
    # コメントを削除してから処理（# 以降を削除）
    local value=$(echo "$frontmatter" | grep "^${field}:" | sed 's/#.*//' | sed "s/^${field}:\s*//" | tr -d '[]' | tr ',' '\n' | sed 's/^[[:space:]]*//' | sed 's/[[:space:]]*$//' | grep -v '^$')
    echo "$value"
}

# 1. ディレクトリ構造の検証
validate_directory_structure() {
    log_info "Validating directory structure..."

    local required_dirs=(
        "$AGENTS_DIR/rules"
        "$AGENTS_DIR/agents"
        "$AGENTS_DIR/commands"
        "$AGENTS_DIR/sync"
    )

    local all_valid=true
    for dir in "${required_dirs[@]}"; do
        if [ ! -d "$dir" ]; then
            log_error "Required directory not found: ${dir#$REPO_ROOT/}"
            all_valid=false
        fi
    done

    if [ "$all_valid" = true ]; then
        log_success "Directory structure is valid"
    fi
}

# 2. Rules の検証
validate_rules() {
    log_info "Validating rules..."

    if [ ! -d "$AGENTS_DIR/rules" ]; then
        log_error "Rules directory not found"
        return
    fi

    if ! compgen -G "$AGENTS_DIR/rules/*.md" > /dev/null 2>&1; then
        log_warning "No rule files found"
        return
    fi

    find "$AGENTS_DIR/rules" -type f -name "*.md" | while IFS= read -r file; do
        local filename=$(basename "$file")
        local frontmatter=$(extract_frontmatter "$file")

        if [ -z "$frontmatter" ]; then
            log_error "[$filename] No frontmatter found"
            continue
        fi

        # 必須フィールドのチェック
        local name=$(get_field_value "$frontmatter" "name")
        local description=$(get_field_value "$frontmatter" "description")
        local agents=$(get_array_field "$frontmatter" "agents")
        local priority=$(get_field_value "$frontmatter" "priority")

        if [ -z "$name" ]; then
            log_error "[$filename] Missing required field: name"
        fi

        if [ -z "$description" ]; then
            log_error "[$filename] Missing required field: description"
        fi

        if [ -z "$agents" ]; then
            log_error "[$filename] Missing required field: agents"
        else
            # agents の値を検証
            while IFS= read -r agent; do
                if [[ ! "$agent" =~ ^(claude|cursor|copilot)$ ]]; then
                    log_error "[$filename] Invalid agent value: '$agent' (must be claude, cursor, or copilot)"
                fi
            done <<< "$agents"
        fi

        # priority が数値かチェック（存在する場合）
        if [ -n "$priority" ] && ! [[ "$priority" =~ ^[0-9]+$ ]]; then
            log_error "[$filename] Priority must be a number: $priority"
        fi

        # paths フィールドの存在確認（オプション）
        local has_paths=$(echo "$frontmatter" | grep -c "^paths:" || true)
        if [ "$has_paths" -eq 0 ]; then
            log_warning "[$filename] No 'paths' field (rule applies to all files)"
        fi

    done

    log_success "Rules validation complete"
}

# Note: Skills検証はskillportに移譲されたため削除

# 3. Agents の検証
validate_agents() {
    log_info "Validating agents..."

    if [ ! -d "$AGENTS_DIR/agents" ]; then
        log_error "Agents directory not found"
        return
    fi

    if ! compgen -G "$AGENTS_DIR/agents/*.md" > /dev/null 2>&1; then
        log_warning "No agent files found"
        return
    fi

    find "$AGENTS_DIR/agents" -type f -name "*.md" | while IFS= read -r file; do
        local filename=$(basename "$file")
        local frontmatter=$(extract_frontmatter "$file")

        if [ -z "$frontmatter" ]; then
            log_error "[$filename] No frontmatter found"
            continue
        fi

        # 必須フィールドのチェック
        local name=$(get_field_value "$frontmatter" "name")
        local description=$(get_field_value "$frontmatter" "description")
        local tools=$(get_array_field "$frontmatter" "tools")
        local agents=$(get_array_field "$frontmatter" "agents")

        if [ -z "$name" ]; then
            log_error "[$filename] Missing required field: name"
        fi

        if [ -z "$description" ]; then
            log_error "[$filename] Missing required field: description"
        fi

        if [ -z "$tools" ]; then
            log_warning "[$filename] No tools defined"
        fi

        if [ -z "$agents" ]; then
            log_error "[$filename] Missing required field: agents"
        else
            # agents の値を検証
            while IFS= read -r agent; do
                if [[ ! "$agent" =~ ^(claude|cursor|copilot)$ ]]; then
                    log_error "[$filename] Invalid agent value: '$agent'"
                fi
            done <<< "$agents"
        fi

        # model フィールドの検証（オプション）
        local model=$(get_field_value "$frontmatter" "model")
        if [ -n "$model" ] && [[ ! "$model" =~ ^(sonnet|opus|haiku)$ ]]; then
            log_warning "[$filename] Unusual model value: '$model' (typically sonnet, opus, or haiku)"
        fi

    done

    log_success "Agents validation complete"
}

# 4. Commands の検証
validate_commands() {
    log_info "Validating commands..."

    if [ ! -d "$AGENTS_DIR/commands" ]; then
        log_error "Commands directory not found"
        return
    fi

    if ! compgen -G "$AGENTS_DIR/commands/*.md" > /dev/null 2>&1; then
        log_warning "No command files found"
        return
    fi

    find "$AGENTS_DIR/commands" -type f -name "*.md" | while IFS= read -r file; do
        local filename=$(basename "$file")
        local frontmatter=$(extract_frontmatter "$file")

        if [ -z "$frontmatter" ]; then
            log_error "[$filename] No frontmatter found"
            continue
        fi

        # 必須フィールドのチェック
        local description=$(get_field_value "$frontmatter" "description")

        if [ -z "$description" ]; then
            log_error "[$filename] Missing required field: description"
        fi

        # name フィールドはオプション（descriptionがあれば十分）

    done

    log_success "Commands validation complete"
}

# 5. ファイル命名規則の検証
validate_file_naming() {
    log_info "Validating file naming conventions..."

    # すべての .md ファイルをチェック（skillsはskillportで管理、tmpは作業用）
    find "$AGENTS_DIR" -type f -name "*.md" ! -path "*/sync/*" ! -path "*/skills/*" ! -path "*/tmp/*" | while IFS= read -r file; do
        local filename=$(basename "$file")

        # ファイル名に空白やアルファベット以外の特殊文字が含まれていないかチェック
        if [[ "$filename" =~ [[:space:]] ]]; then
            log_warning "[$filename] Filename contains spaces"
        fi

        # README.md を除外して、一般的なマークダウンファイルは小文字とハイフンのみを推奨
        if [[ "$filename" != "README.md" ]] && [[ "$filename" =~ [A-Z] ]]; then
            log_warning "[$filename] Filename contains uppercase letters (lowercase-with-hyphens is recommended)"
        fi

    done

    log_success "File naming validation complete"
}

# 6. YAML構文の検証
validate_yaml_syntax() {
    log_info "Validating YAML syntax..."

    find "$AGENTS_DIR" -type f -name "*.md" ! -path "*/sync/*" ! -path "*/skills/*" ! -path "*/tmp/*" ! -name "README.md" | while IFS= read -r file; do
        local filename=$(basename "$file")
        local dirname=$(basename "$(dirname "$file")")

        # frontmatter の区切り (---) をチェック
        local delimiter_count=$(grep -c "^---$" "$file" || true)

        if [ "$delimiter_count" -lt 2 ]; then
            log_error "[$filename] Invalid frontmatter delimiters (expected at least 2 '---' lines)"
            continue
        fi

        # frontmatter が最初に来ているかチェック
        local first_line=$(head -n 1 "$file")
        if [ "$first_line" != "---" ]; then
            log_error "[$filename] Frontmatter must start at the beginning of the file"
        fi

    done

    log_success "YAML syntax validation complete"
}

# メイン検証処理
main() {
    echo ""
    echo "========================================"
    echo "  AI Agent Configuration Validation"
    echo "========================================"
    echo ""

    if [ ! -d "$AGENTS_DIR" ]; then
        log_error ".agents/ directory not found"
        exit 1
    fi

    validate_directory_structure
    echo ""
    validate_rules
    echo ""
    validate_agents
    echo ""
    validate_commands
    echo ""
    validate_file_naming
    echo ""
    validate_yaml_syntax

    echo ""
    echo "========================================"
    echo "  Validation Summary"
    echo "========================================"
    echo ""

    local ERROR_COUNT=$(cat "$ERROR_COUNT_FILE")
    local WARNING_COUNT=$(cat "$WARNING_COUNT_FILE")

    if [ "$ERROR_COUNT" -eq 0 ] && [ "$WARNING_COUNT" -eq 0 ]; then
        log_success "All validations passed! ✨"
        echo ""
        exit 0
    else
        if [ "$ERROR_COUNT" -gt 0 ]; then
            echo -e "${RED}✗${NC} Found $ERROR_COUNT error(s)"
        fi
        if [ "$WARNING_COUNT" -gt 0 ]; then
            echo -e "${YELLOW}⚠${NC} Found $WARNING_COUNT warning(s)"
        fi
        echo ""

        if [ "$ERROR_COUNT" -gt 0 ]; then
            echo -e "${RED}Validation failed. Please fix the errors above.${NC}"
            exit 1
        else
            echo -e "${YELLOW}Validation completed with warnings.${NC}"
            exit 0
        fi
    fi
}

main "$@"
