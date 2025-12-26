#!/bin/bash

# AI Agent 統一管理システム - バリデーションスクリプト
# .agents/ の構造とコンテンツを検証

# Note: set -e is not used here to allow proper error counting

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"
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

# paths フィールド形式の検証（公式仕様: 単一文字列、カンマ区切り）
# YAML配列形式は非推奨
validate_paths_format() {
    local frontmatter="$1"
    local filename="$2"

    # paths フィールドが存在するかチェック
    local paths_line=$(echo "$frontmatter" | grep "^paths:")
    if [ -z "$paths_line" ]; then
        return 0  # paths がない場合はスキップ
    fi

    # paths: の後に値がない（次行に配列がある）場合はエラー
    local paths_value=$(echo "$paths_line" | sed 's/^paths:\s*//')
    if [ -z "$paths_value" ] || [ "$paths_value" = "paths:" ]; then
        # 次の行が配列要素かチェック
        local next_line=$(echo "$frontmatter" | grep -A1 "^paths:" | tail -n1)
        if [[ "$next_line" =~ ^[[:space:]]*-[[:space:]] ]]; then
            log_error "[$filename] paths field uses YAML array format (deprecated)"
            log_info "  Use single string format: paths: \"**/*.{ts,tsx}\""
            return 1
        fi
    fi

    # 値が空の場合
    if [ -z "$paths_value" ]; then
        log_warning "[$filename] paths field is empty"
        return 0
    fi

    return 0
}

# 配列フィールド形式の検証（単一行のインライン配列形式を推奨）
# YAML複数行配列形式は非推奨
validate_array_field_format() {
    local frontmatter="$1"
    local filename="$2"
    local field="$3"

    # フィールドが存在するかチェック
    local field_line=$(echo "$frontmatter" | grep "^${field}:")
    if [ -z "$field_line" ]; then
        return 0  # フィールドがない場合はスキップ
    fi

    # field: の後に値がない（次行に配列がある）場合はエラー
    local field_value=$(echo "$field_line" | sed "s/^${field}:\s*//")
    if [ -z "$field_value" ] || [ "$field_value" = "${field}:" ]; then
        # 次の行が配列要素かチェック
        local next_line=$(echo "$frontmatter" | grep -A1 "^${field}:" | tail -n1)
        if [[ "$next_line" =~ ^[[:space:]]*-[[:space:]] ]]; then
            log_error "[$filename] $field field uses YAML multi-line array format (deprecated)"
            log_info "  Use inline array format: $field: [item1, item2]"
            return 1
        fi
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
        "$AGENTS_DIR/scripts/sync"
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

    # 再帰的に .md ファイルを検索
    local rule_files=$(find "$AGENTS_DIR/rules" -type f -name "*.md" 2>/dev/null)
    if [ -z "$rule_files" ]; then
        log_warning "No rule files found"
        return
    fi

    find "$AGENTS_DIR/rules" -type f -name "*.md" | while IFS= read -r file; do
        local relative_path="${file#$AGENTS_DIR/rules/}"
        local frontmatter=$(extract_frontmatter "$file")

        # 行数チェック（公式仕様: Cursor推奨 500行以下）
        validate_line_count "$file" "rules/$relative_path"

        # frontmatter はオプション（Claude Code公式仕様）
        if [ -z "$frontmatter" ]; then
            log_info "[rules/$relative_path] No frontmatter (optional for rules)"
            continue
        fi

        # frontmatter がある場合のみフィールドをチェック
        local name=$(get_field_value "$frontmatter" "name")
        local description=$(get_field_value "$frontmatter" "description")

        # name がある場合は形式を検証
        if [ -n "$name" ]; then
            validate_name_format "$name" "rules/$relative_path"
        fi

        # description がある場合は文字数を検証
        if [ -n "$description" ]; then
            validate_description_length "$description" "rules/$relative_path"
        fi

        # paths フィールドの存在確認と形式検証
        local has_paths=$(echo "$frontmatter" | grep -c "^paths:" || true)
        if [ "$has_paths" -eq 0 ]; then
            log_info "[rules/$relative_path] No 'paths' field (rule applies to all files)"
        else
            # paths 形式を検証（単一文字列であること）
            validate_paths_format "$frontmatter" "rules/$relative_path"
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

    # 再帰的に .md ファイルを検索
    local agent_files=$(find "$AGENTS_DIR/agents" -type f -name "*.md" 2>/dev/null)
    if [ -z "$agent_files" ]; then
        log_warning "No agent files found"
        return
    fi

    find "$AGENTS_DIR/agents" -type f -name "*.md" | while IFS= read -r file; do
        local relative_path="${file#$AGENTS_DIR/agents/}"
        local frontmatter=$(extract_frontmatter "$file")

        # 行数チェック
        validate_line_count "$file" "agents/$relative_path"

        if [ -z "$frontmatter" ]; then
            log_error "[agents/$relative_path] No frontmatter found"
            continue
        fi

        # 必須フィールドのチェック（公式仕様: name, description 必須）
        local name=$(get_field_value "$frontmatter" "name")
        local description=$(get_field_value "$frontmatter" "description")
        local tools=$(get_array_field "$frontmatter" "tools")

        if [ -z "$name" ]; then
            log_error "[agents/$relative_path] Missing required field: name"
        else
            # name フォーマット検証（公式仕様: lowercase letters and hyphens）
            validate_name_format "$name" "agents/$relative_path"
        fi

        if [ -z "$description" ]; then
            log_error "[agents/$relative_path] Missing required field: description"
        else
            validate_description_length "$description" "agents/$relative_path"
        fi

        # tools はオプション（省略時は全ツール継承）
        if [ -z "$tools" ]; then
            log_info "[agents/$relative_path] No tools defined (inherits all tools)"
        fi

        # tools と skills の形式検証（インライン配列形式を推奨）
        validate_array_field_format "$frontmatter" "agents/$relative_path" "tools"
        validate_array_field_format "$frontmatter" "agents/$relative_path" "skills"

        # model フィールドの検証（公式仕様: sonnet, opus, haiku, inherit）
        local model=$(get_field_value "$frontmatter" "model")
        if [ -n "$model" ] && [[ ! "$model" =~ ^(sonnet|opus|haiku|inherit)$ ]]; then
            log_warning "[agents/$relative_path] Unusual model value: '$model' (expected: sonnet, opus, haiku, or inherit)"
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

    # 再帰的に SKILL.md ファイルを検索
    local skill_files=$(find "$AGENTS_DIR/skills" -type f -name "SKILL.md" 2>/dev/null)
    if [ -z "$skill_files" ]; then
        log_warning "No skill files found"
        return
    fi

    # 各 SKILL.md ファイルをチェック
    find "$AGENTS_DIR/skills" -type f -name "SKILL.md" | while IFS= read -r skill_file; do
        local skill_dir=$(dirname "$skill_file")
        local relative_dir="${skill_dir#$AGENTS_DIR/skills/}"
        local relative_path="skills/$relative_dir/SKILL.md"

        local frontmatter=$(extract_frontmatter "$skill_file")

        # 行数チェック
        validate_line_count "$skill_file" "$relative_path"

        if [ -z "$frontmatter" ]; then
            log_error "[$relative_path] No frontmatter found"
            continue
        fi

        # 必須フィールドのチェック（公式仕様: name, description 必須）
        local name=$(get_field_value "$frontmatter" "name")
        local description=$(get_field_value "$frontmatter" "description")

        if [ -z "$name" ]; then
            log_error "[$relative_path] Missing required field: name"
        else
            # name フォーマット検証（公式仕様: max 64 chars, lowercase/numbers/hyphens）
            validate_name_format "$name" "$relative_path" 64
        fi

        if [ -z "$description" ]; then
            log_error "[$relative_path] Missing required field: description"
        else
            # description 文字数検証（公式仕様: max 1024 chars）
            validate_description_length "$description" "$relative_path" 1024

            # description にトリガーキーワードが含まれているか確認（推奨）
            if [[ ! "$description" =~ [Uu]se\ when|[Uu]se\ for|[Ww]hen\ working ]]; then
                log_warning "[$relative_path] description should include trigger keywords (e.g., 'Use when...')"
            fi
        fi

        # allowed-tools の検証（オプション）
        local allowed_tools=$(get_field_value "$frontmatter" "allowed-tools")
        if [ -n "$allowed_tools" ]; then
            log_info "[$relative_path] allowed-tools: $allowed_tools"
        fi

        # 参照ファイルの存在チェック（再帰的）
        local ref_count=$(find "$skill_dir" -type f -name "*.md" ! -name "SKILL.md" 2>/dev/null | wc -l | tr -d ' ')
        if [ "$ref_count" -gt 0 ]; then
            log_info "[skills/$relative_dir] Found $ref_count additional reference file(s)"
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

    # 再帰的に .md ファイルを検索
    local command_files=$(find "$AGENTS_DIR/commands" -type f -name "*.md" 2>/dev/null)
    if [ -z "$command_files" ]; then
        log_warning "No command files found"
        return
    fi

    find "$AGENTS_DIR/commands" -type f -name "*.md" | while IFS= read -r file; do
        local relative_path="${file#$AGENTS_DIR/commands/}"
        local frontmatter=$(extract_frontmatter "$file")

        if [ -z "$frontmatter" ]; then
            log_error "[commands/$relative_path] No frontmatter found"
            continue
        fi

        # 必須フィールドのチェック
        local description=$(get_field_value "$frontmatter" "description")

        if [ -z "$description" ]; then
            log_error "[commands/$relative_path] Missing required field: description"
        fi

        # name フィールドはオプション（descriptionがあれば十分）

    done

    log_success "Commands validation complete"
}

# 6. ファイル命名規則の検証
validate_file_naming() {
    log_info "Validating file naming conventions..."

    # すべての .md ファイルをチェック（skillsはシンボリックリンクで管理、tmpは作業用、promptsは参照ファイル）
    find "$AGENTS_DIR" -type f -name "*.md" ! -path "*/sync/*" ! -path "*/skills/*" ! -path "*/tmp/*" ! -path "*/prompts/*" ! -path "*/scripts/*" | while IFS= read -r file; do
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

    find "$AGENTS_DIR" -type f -name "*.md" ! -path "*/sync/*" ! -path "*/skills/*" ! -path "*/tmp/*" ! -path "*/prompts/*" ! -path "*/scripts/*" ! -name "README.md" | while IFS= read -r file; do
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
