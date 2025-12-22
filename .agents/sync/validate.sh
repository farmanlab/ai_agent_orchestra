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

# YAML frontmatter を抽出（最初の frontmatter のみ）
extract_frontmatter() {
    local file="$1"
    awk '/^---$/{c++;if(c==2)exit;next}c==1' "$file"
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

# name フィールドの文字種検証（公式仕様: lowercase, numbers, hyphens only）
validate_name_format() {
    local name="$1"
    local filename="$2"
    local max_length="${3:-64}"  # デフォルト64文字（Skills仕様）

    if [ -z "$name" ]; then
        return 1
    fi

    # 文字種チェック: lowercase, numbers, hyphens のみ
    if [[ ! "$name" =~ ^[a-z0-9-]+$ ]]; then
        log_error "[$filename] name '$name' must use only lowercase letters, numbers, and hyphens"
        return 1
    fi

    # 文字数チェック
    if [ ${#name} -gt "$max_length" ]; then
        log_error "[$filename] name '$name' exceeds $max_length characters (${#name} chars)"
        return 1
    fi

    return 0
}

# description フィールドの文字数検証（公式仕様: max 1024 chars for Skills）
validate_description_length() {
    local description="$1"
    local filename="$2"
    local max_length="${3:-1024}"

    if [ -z "$description" ]; then
        return 1
    fi

    if [ ${#description} -gt "$max_length" ]; then
        log_warning "[$filename] description exceeds $max_length characters (${#description} chars)"
        return 1
    fi

    return 0
}

# ファイル行数の検証（公式仕様: Cursor推奨 500行以下）
validate_line_count() {
    local file="$1"
    local filename="$2"
    local warn_threshold="${3:-500}"
    local error_threshold="${4:-1000}"

    local line_count=$(wc -l < "$file" | tr -d ' ')

    if [ "$line_count" -gt "$error_threshold" ]; then
        log_error "[$filename] exceeds $error_threshold lines ($line_count lines)"
        return 1
    elif [ "$line_count" -gt "$warn_threshold" ]; then
        log_warning "[$filename] exceeds $warn_threshold lines ($line_count lines) - consider splitting"
        return 0
    fi

    return 0
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
# 公式仕様: Claude Code rules では frontmatter はオプション
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

        # 行数チェック（公式仕様: Cursor推奨 500行以下）
        validate_line_count "$file" "$filename"

        # frontmatter はオプション（Claude Code公式仕様）
        if [ -z "$frontmatter" ]; then
            log_info "[$filename] No frontmatter (optional for rules)"
            continue
        fi

        # frontmatter がある場合のみフィールドをチェック
        local name=$(get_field_value "$frontmatter" "name")
        local description=$(get_field_value "$frontmatter" "description")

        # name がある場合は形式を検証
        if [ -n "$name" ]; then
            validate_name_format "$name" "$filename"
        fi

        # description がある場合は文字数を検証
        if [ -n "$description" ]; then
            validate_description_length "$description" "$filename"
        fi

        # paths フィールドの存在確認（情報提供のみ）
        local has_paths=$(echo "$frontmatter" | grep -c "^paths:" || true)
        if [ "$has_paths" -eq 0 ]; then
            log_info "[$filename] No 'paths' field (rule applies to all files)"
        fi

    done

    log_success "Rules validation complete"
}

# 3. Agents の検証
# 公式仕様: https://code.claude.com/docs/en/sub-agents
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

        # 行数チェック
        validate_line_count "$file" "$filename"

        if [ -z "$frontmatter" ]; then
            log_error "[$filename] No frontmatter found"
            continue
        fi

        # 必須フィールドのチェック（公式仕様: name, description 必須）
        local name=$(get_field_value "$frontmatter" "name")
        local description=$(get_field_value "$frontmatter" "description")
        local tools=$(get_array_field "$frontmatter" "tools")

        if [ -z "$name" ]; then
            log_error "[$filename] Missing required field: name"
        else
            # name フォーマット検証（公式仕様: lowercase letters and hyphens）
            validate_name_format "$name" "$filename"
        fi

        if [ -z "$description" ]; then
            log_error "[$filename] Missing required field: description"
        else
            validate_description_length "$description" "$filename"
        fi

        # tools はオプション（省略時は全ツール継承）
        if [ -z "$tools" ]; then
            log_info "[$filename] No tools defined (inherits all tools)"
        fi

        # model フィールドの検証（公式仕様: sonnet, opus, haiku, inherit）
        local model=$(get_field_value "$frontmatter" "model")
        if [ -n "$model" ] && [[ ! "$model" =~ ^(sonnet|opus|haiku|inherit)$ ]]; then
            log_warning "[$filename] Unusual model value: '$model' (expected: sonnet, opus, haiku, or inherit)"
        fi

    done

    log_success "Agents validation complete"
}

# 4. Skills の検証
# 公式仕様: https://code.claude.com/docs/en/skills
validate_skills() {
    log_info "Validating skills..."

    if [ ! -d "$AGENTS_DIR/skills" ]; then
        log_warning "Skills directory not found"
        return
    fi

    # 各スキルディレクトリをチェック
    for skill_dir in "$AGENTS_DIR/skills"/*/; do
        if [ ! -d "$skill_dir" ]; then
            continue
        fi

        local skill_name=$(basename "$skill_dir")
        local skill_file="$skill_dir/SKILL.md"

        # SKILL.md の存在チェック（公式仕様: 必須）
        if [ ! -f "$skill_file" ]; then
            log_error "[skills/$skill_name] Missing required SKILL.md file"
            continue
        fi

        local frontmatter=$(extract_frontmatter "$skill_file")

        # 行数チェック
        validate_line_count "$skill_file" "skills/$skill_name/SKILL.md"

        if [ -z "$frontmatter" ]; then
            log_error "[skills/$skill_name/SKILL.md] No frontmatter found"
            continue
        fi

        # 必須フィールドのチェック（公式仕様: name, description 必須）
        local name=$(get_field_value "$frontmatter" "name")
        local description=$(get_field_value "$frontmatter" "description")

        if [ -z "$name" ]; then
            log_error "[skills/$skill_name/SKILL.md] Missing required field: name"
        else
            # name フォーマット検証（公式仕様: max 64 chars, lowercase/numbers/hyphens）
            validate_name_format "$name" "skills/$skill_name/SKILL.md" 64
        fi

        if [ -z "$description" ]; then
            log_error "[skills/$skill_name/SKILL.md] Missing required field: description"
        else
            # description 文字数検証（公式仕様: max 1024 chars）
            validate_description_length "$description" "skills/$skill_name/SKILL.md" 1024

            # description にトリガーキーワードが含まれているか確認（推奨）
            if [[ ! "$description" =~ [Uu]se\ when|[Uu]se\ for|[Ww]hen\ working ]]; then
                log_warning "[skills/$skill_name/SKILL.md] description should include trigger keywords (e.g., 'Use when...')"
            fi
        fi

        # allowed-tools の検証（オプション）
        local allowed_tools=$(get_field_value "$frontmatter" "allowed-tools")
        if [ -n "$allowed_tools" ]; then
            log_info "[skills/$skill_name/SKILL.md] allowed-tools: $allowed_tools"
        fi

        # 参照ファイルの存在チェック
        local ref_count=0
        for ref_file in "$skill_dir"*.md; do
            if [ -f "$ref_file" ] && [ "$ref_file" != "$skill_file" ]; then
                ((ref_count++))
            fi
        done
        if [ "$ref_count" -gt 0 ]; then
            log_info "[skills/$skill_name] Found $ref_count additional reference file(s)"
        fi

    done

    log_success "Skills validation complete"
}

# 5. Commands の検証
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

# 6. ファイル命名規則の検証
validate_file_naming() {
    log_info "Validating file naming conventions..."

    # すべての .md ファイルをチェック（skillsはシンボリックリンクで管理、tmpは作業用）
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

# 7. YAML構文の検証
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
    validate_skills
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
