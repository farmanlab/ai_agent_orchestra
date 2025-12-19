#!/bin/bash

# AI Agent 統一管理システム - プロンプトサイズチェックスクリプト
# .agents/ のファイルサイズとトークン数を計測

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
AGENTS_DIR="$REPO_ROOT/.agents"

# カラー定義
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# しきい値設定（調整可能）
SINGLE_FILE_LINE_WARNING=500      # 単一ファイルの行数警告
SINGLE_FILE_LINE_ERROR=1000       # 単一ファイルの行数エラー
SINGLE_FILE_TOKEN_WARNING=2000    # 単一ファイルのトークン数警告
SINGLE_FILE_TOKEN_ERROR=4000      # 単一ファイルのトークン数エラー
TOTAL_TOKEN_WARNING=10000         # 全体のトークン数警告
TOTAL_TOKEN_ERROR=20000           # 全体のトークン数エラー

# カウンタ
WARNING_COUNT=0
ERROR_COUNT=0

# ログ関数
log_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

log_success() {
    echo -e "${GREEN}✓${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
    ((WARNING_COUNT++))
}

log_error() {
    echo -e "${RED}✗${NC} $1"
    ((ERROR_COUNT++))
}

log_detail() {
    echo -e "${CYAN}  →${NC} $1"
}

# トークン数を推定（1トークン ≈ 4文字として計算）
estimate_tokens() {
    local file="$1"
    local char_count=$(wc -m < "$file" | tr -d ' ')
    echo $((char_count / 4))
}

# ファイルサイズを人間が読める形式に変換
human_readable_size() {
    local bytes=$1
    if [ $bytes -lt 1024 ]; then
        echo "${bytes}B"
    elif [ $bytes -lt 1048576 ]; then
        echo "$((bytes / 1024))KB"
    else
        echo "$((bytes / 1048576))MB"
    fi
}

# 単一ファイルのチェック（標準出力に情報表示、トークン数はグローバル変数に格納）
check_file() {
    local file="$1"
    local filename=$(basename "$file")
    local relative_path="${file#$AGENTS_DIR/}"

    # 行数、文字数、バイト数を取得
    local line_count=$(wc -l < "$file" | tr -d ' ')
    local char_count=$(wc -m < "$file" | tr -d ' ')
    local byte_count=$(wc -c < "$file" | tr -d ' ')
    local token_count=$(estimate_tokens "$file")

    # サイズ表示
    local size_str=$(human_readable_size $byte_count)

    # 状態判定
    local status="OK"
    local status_color="$GREEN"

    if [ $line_count -ge $SINGLE_FILE_LINE_ERROR ] || [ $token_count -ge $SINGLE_FILE_TOKEN_ERROR ]; then
        status="ERROR"
        status_color="$RED"
        log_error "[$relative_path] File too large: $line_count lines, ~$token_count tokens ($size_str)"
    elif [ $line_count -ge $SINGLE_FILE_LINE_WARNING ] || [ $token_count -ge $SINGLE_FILE_TOKEN_WARNING ]; then
        status="WARN"
        status_color="$YELLOW"
        log_warning "[$relative_path] File getting large: $line_count lines, ~$token_count tokens ($size_str)"
    else
        echo -e "${status_color}✓${NC} $relative_path: $line_count lines, ~$token_count tokens ($size_str)"
    fi

    # トークン数をグローバル変数に格納
    FILE_TOKEN_COUNT=$token_count
}

# カテゴリ別チェック（グローバル変数 CATEGORY_TOKEN_COUNT に結果を格納）
check_category() {
    local category="$1"
    local pattern="$2"

    log_info "Checking ${category}..."

    local total_tokens=0
    local file_count=0

    if [ -d "$AGENTS_DIR/$category" ]; then
        while IFS= read -r file; do
            [ -z "$file" ] && continue
            check_file "$file"
            total_tokens=$((total_tokens + FILE_TOKEN_COUNT))
            file_count=$((file_count + 1))
        done < <(find "$AGENTS_DIR/$category" -type f -name "$pattern" ! -path "*/sync/*")

        if [ $file_count -gt 0 ]; then
            log_detail "Total: $file_count files, ~$total_tokens tokens"
        else
            log_detail "No files found"
        fi
    else
        log_warning "Directory not found: $category"
    fi

    echo ""
    CATEGORY_TOKEN_COUNT=$total_tokens
}

# メイン処理
main() {
    echo ""
    echo "========================================"
    echo "  AI Agent Prompt Size Check"
    echo "========================================"
    echo ""

    if [ ! -d "$AGENTS_DIR" ]; then
        log_error ".agents/ directory not found"
        exit 1
    fi

    # 設定表示
    log_info "Thresholds:"
    echo -e "  ${CYAN}Single file warning:${NC} $SINGLE_FILE_LINE_WARNING lines or $SINGLE_FILE_TOKEN_WARNING tokens"
    echo -e "  ${CYAN}Single file error:${NC} $SINGLE_FILE_LINE_ERROR lines or $SINGLE_FILE_TOKEN_ERROR tokens"
    echo -e "  ${CYAN}Total warning:${NC} $TOTAL_TOKEN_WARNING tokens"
    echo -e "  ${CYAN}Total error:${NC} $TOTAL_TOKEN_ERROR tokens"
    echo ""

    # カテゴリ別チェック
    check_category "rules" "*.md"
    local rules_tokens=$CATEGORY_TOKEN_COUNT

    check_category "agents" "*.md"
    local agents_tokens=$CATEGORY_TOKEN_COUNT

    check_category "commands" "*.md"
    local commands_tokens=$CATEGORY_TOKEN_COUNT

    # 合計計算
    local total_tokens=$((rules_tokens + agents_tokens + commands_tokens))

    echo "========================================"
    echo "  Summary"
    echo "========================================"
    echo ""

    echo -e "${CYAN}Category Breakdown:${NC}"
    echo -e "  Rules:    ~${rules_tokens} tokens"
    echo -e "  Agents:   ~${agents_tokens} tokens"
    echo -e "  Commands: ~${commands_tokens} tokens"
    echo ""
    echo -e "${CYAN}Total:    ~${total_tokens} tokens${NC}"
    echo ""

    # 全体のしきい値チェック
    if [ $total_tokens -ge $TOTAL_TOKEN_ERROR ]; then
        log_error "Total token count exceeds error threshold ($TOTAL_TOKEN_ERROR)"
    elif [ $total_tokens -ge $TOTAL_TOKEN_WARNING ]; then
        log_warning "Total token count exceeds warning threshold ($TOTAL_TOKEN_WARNING)"
    else
        log_success "Total token count is within acceptable range"
    fi

    echo ""

    # 最終結果
    if [ $ERROR_COUNT -eq 0 ] && [ $WARNING_COUNT -eq 0 ]; then
        log_success "All size checks passed! ✨"
        echo ""
        exit 0
    else
        if [ $ERROR_COUNT -gt 0 ]; then
            echo -e "${RED}✗${NC} Found $ERROR_COUNT error(s)"
        fi
        if [ $WARNING_COUNT -gt 0 ]; then
            echo -e "${YELLOW}⚠${NC} Found $WARNING_COUNT warning(s)"
        fi
        echo ""

        echo -e "${CYAN}Recommendations:${NC}"
        echo "  - Consider breaking large files into smaller, focused modules"
        echo "  - Move detailed documentation to reference files (progressive disclosure)"
        echo "  - Remove redundant or outdated content"
        echo "  - Use links to external documentation where appropriate"
        echo ""

        if [ $ERROR_COUNT -gt 0 ]; then
            echo -e "${RED}Size check failed. Please reduce file sizes.${NC}"
            exit 1
        else
            echo -e "${YELLOW}Size check completed with warnings.${NC}"
            exit 0
        fi
    fi
}

main "$@"
