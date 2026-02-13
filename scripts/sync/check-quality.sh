#!/bin/bash

# AI Agent 統一管理システム - プロンプト品質チェックスクリプト
# ベストプラクティスに基づいて構成を検証

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
AGENTS_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
REPO_ROOT="$(cd "$AGENTS_DIR/.." && pwd)"

# カラー定義
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# 一時ファイルを使用してカウンタを管理（サブシェル対策）
TOTAL_FILES_FILE=$(mktemp)
HIGH_ISSUES_FILE=$(mktemp)
MEDIUM_ISSUES_FILE=$(mktemp)
LOW_ISSUES_FILE=$(mktemp)

echo "0" > "$TOTAL_FILES_FILE"
echo "0" > "$HIGH_ISSUES_FILE"
echo "0" > "$MEDIUM_ISSUES_FILE"
echo "0" > "$LOW_ISSUES_FILE"

# クリーンアップ
trap 'rm -f "$TOTAL_FILES_FILE" "$HIGH_ISSUES_FILE" "$MEDIUM_ISSUES_FILE" "$LOW_ISSUES_FILE"' EXIT

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

log_detail() {
    echo -e "${CYAN}  →${NC} $1"
}

log_high() {
    echo -e "${RED}🔴${NC} $1"
    local count=$(cat "$HIGH_ISSUES_FILE")
    echo $((count + 1)) > "$HIGH_ISSUES_FILE"
}

log_medium() {
    echo -e "${YELLOW}🟡${NC} $1"
    local count=$(cat "$MEDIUM_ISSUES_FILE")
    echo $((count + 1)) > "$MEDIUM_ISSUES_FILE"
}

log_low() {
    echo -e "${GREEN}🟢${NC} $1"
    local count=$(cat "$LOW_ISSUES_FILE")
    echo $((count + 1)) > "$LOW_ISSUES_FILE"
}

# コンテンツのクリーンアップ（コードブロックを除去）
get_clean_content() {
    local file="$1"
    # コードブロック（```で囲まれた部分）を除去
    sed '/^```/,/^```/d' "$file"
}

# 1. 曖昧な表現のチェック
check_vague_language() {
    local file="$1"
    local filename=$(basename "$file")
    local relative_path="${file#$AGENTS_DIR/}"

    # 日本語の曖昧表現
    local vague_ja="できれば|なるべく|可能な限り|望ましい|推奨される場合がある"
    # 英語の曖昧表現
    local vague_en="consider|maybe|perhaps|possibly|might want to|you could"

    # コードブロックを除去したコンテンツでチェック
    local clean_content=$(get_clean_content "$file")
    local matches=$(echo "$clean_content" | grep -in -E "$vague_ja|$vague_en" 2>/dev/null)

    if [ -n "$matches" ]; then
        # best-practices.md と validation-criteria.md は警告のみ
        if [[ "$filename" == "best-practices.md" ]] || [[ "$filename" == "validation-criteria.md" ]]; then
            log_low "[$relative_path] Vague language detected (potential examples)"
            return 0
        fi

        log_medium "[$relative_path] Vague language detected"
        while IFS= read -r line; do
            log_detail "Line $(echo "$line" | cut -d: -f1): $(echo "$line" | cut -d: -f2- | sed 's/^[[:space:]]*//' | cut -c1-60)..."
        done <<< "$matches"
        return 1
    fi
    return 0
}

# 2. 構造化チェック（見出し階層）
check_structure() {
    local file="$1"
    local filename=$(basename "$file")
    local relative_path="${file#$AGENTS_DIR/}"

    # コードブロックを除去したコンテンツでチェック
    local clean_content=$(get_clean_content "$file")

    # H1の数をチェック（通常1つであるべき）
    local h1_count=$(echo "$clean_content" | grep -c "^# " || echo 0)

    # 見出しなしのチェック
    local heading_count=$(echo "$clean_content" | grep -c "^#" || echo 0)

    if [ "$h1_count" -eq 0 ]; then
        log_medium "[$relative_path] No H1 heading found"
        return 1
    elif [ "$h1_count" -gt 1 ]; then
        log_low "[$relative_path] Multiple H1 headings ($h1_count found)"
        return 1
    fi

    if [ "$heading_count" -lt 3 ]; then
        log_low "[$relative_path] Limited structure (only $heading_count headings)"
        return 1
    fi

    return 0
}

# 3. 具体例の存在チェック
check_examples() {
    local file="$1"
    local filename=$(basename "$file")
    local relative_path="${file#$AGENTS_DIR/}"

    # コードブロックの存在
    local code_blocks=$(grep "^\`\`\`" "$file" 2>/dev/null | wc -l | tr -d ' ')

    # Example セクションの存在
    local example_sections=$(grep -i "example\|例" "$file" 2>/dev/null | wc -l | tr -d ' ')

    if [ "$code_blocks" -eq 0 ] && [ "$example_sections" -eq 0 ]; then
        log_low "[$relative_path] No code examples found"
        return 1
    fi

    return 0
}

# 4. タスク固有の指示チェック
check_task_specific() {
    local file="$1"
    local filename=$(basename "$file")
    local relative_path="${file#$AGENTS_DIR/}"

    # タスク固有のパターン（具体的なファイル名、行番号への言及）
    local task_specific="line [0-9]+|fix.*bug|update.*\.js|change.*function"

    local clean_content=$(get_clean_content "$file")
    local matches=$(echo "$clean_content" | grep -in -E "$task_specific" 2>/dev/null | head -3)

    if [ -n "$matches" ]; then
        log_medium "[$relative_path] Potentially task-specific instructions"
        log_detail "Review for overly specific instructions"
        return 1
    fi

    return 0
}

# 5. ファイルサイズチェック（Cursor 500行推奨）
check_file_size() {
    local file="$1"
    local filename=$(basename "$file")
    local relative_path="${file#$AGENTS_DIR/}"

    local line_count=$(wc -l < "$file" | tr -d ' ')

    if [ $line_count -gt 1000 ]; then
        log_high "[$relative_path] Exceeds 1000 lines ($line_count) - split into multiple files"
        return 2
    elif [ $line_count -gt 500 ]; then
        log_medium "[$relative_path] Exceeds Cursor recommendation ($line_count lines > 500)"
        return 1
    fi

    return 0
}

# 6. Progressive Disclosure チェック
check_progressive_disclosure() {
    local file="$1"
    local dirname=$(dirname "$file")
    local filename=$(basename "$file")
    local relative_path="${file#$AGENTS_DIR/}"

    # Skills の SKILL.md の場合のみチェック
    if [[ "$file" =~ /skills/.*SKILL\.md$ ]]; then
        local line_count=$(wc -l < "$file" | tr -d ' ')

        # 補助ファイルの存在確認
        local supplementary_files=$(find "$dirname" -type f -name "*.md" ! -name "SKILL.md" 2>/dev/null | wc -l | tr -d ' ')

        if [ $line_count -gt 200 ] && [ $supplementary_files -eq 0 ]; then
            log_medium "[$relative_path] Large SKILL.md ($line_count lines) without supplementary files"
            log_detail "Consider splitting into patterns.md, checklist.md, etc."
            return 1
        fi
    fi

    return 0
}

# 7. メタデータの完全性チェック
check_metadata() {
    local file="$1"
    local filename=$(basename "$file")
    local relative_path="${file#$AGENTS_DIR/}"

    # frontmatter の抽出（ファイルの先頭にある場合のみ）
    local frontmatter=""
    if [ "$(head -n 1 "$file")" = "---" ]; then
        frontmatter=$(sed -n '2,/^---$/p' "$file" | sed '$d')
    fi

    if [ -z "$frontmatter" ]; then
        # Skills の補助ファイルはスキップ
        if [[ "$file" =~ /skills/ ]] && [[ "$filename" != "SKILL.md" ]]; then
            return 0
        fi
        log_high "[$relative_path] Missing frontmatter"
        return 2
    fi

    # description の存在
    local has_description=$(echo "$frontmatter" | grep -c "^description:" || echo 0)
    if [ "$has_description" -eq 0 ]; then
        log_high "[$relative_path] Missing description field"
        return 2
    fi

    # description が具体的か（最低10文字）
    local description=$(echo "$frontmatter" | grep "^description:" | sed 's/description:\s*//' | head -n 1)
    local desc_length=${#description}
    if [ "$desc_length" -lt 10 ]; then
        log_medium "[$relative_path] Description too short ($desc_length chars)"
        return 1
    fi

    return 0
}

# 8. paths フィールド形式チェック
check_paths_format() {
    local file="$1"
    local filename=$(basename "$file")
    local relative_path="${file#$AGENTS_DIR/}"

    # frontmatter の抽出
    local frontmatter=""
    if [ "$(head -n 1 "$file")" = "---" ]; then
        frontmatter=$(sed -n '2,/^---$/p' "$file" | sed '$d')
    fi

    if [ -z "$frontmatter" ]; then
        return 0
    fi

    # paths フィールドの形式をチェック
    local paths_line=$(echo "$frontmatter" | grep "^paths:")
    if [ -z "$paths_line" ]; then
        return 0  # paths がない場合はスキップ
    fi

    # paths: の後に値がない（次行に配列がある）場合
    local paths_value=$(echo "$paths_line" | sed 's/^paths:\s*//')
    if [ -z "$paths_value" ]; then
        # 次の行が配列要素かチェック
        local next_line=$(echo "$frontmatter" | grep -A1 "^paths:" | tail -n1)
        if [[ "$next_line" =~ ^[[:space:]]*-[[:space:]] ]]; then
            log_high "[$relative_path] paths uses YAML array format (use single string)"
            log_detail "Expected: paths: \"**/*.{ts,tsx}\""
            return 2
        fi
    fi

    return 0
}

# 10. 重複キーフレーズチェック
check_duplication() {
    local category="$1"

    log_info "Checking for duplication in $category..."

    # 重要なキーフレーズを抽出
    local key_phrases=$(grep -rh "^- \|^## \|must \|should \|always \|never " "$AGENTS_DIR/$category" 2>/dev/null | \
                        sed 's/^[[:space:]]*//' | \
                        sort | uniq -c | sort -rn | head -10)

    if [ -n "$key_phrases" ]; then
        local duplicates=$(echo "$key_phrases" | awk '$1 > 2 {print}')
        if [ -n "$duplicates" ]; then
            log_low "Potential duplication in $category:"
            while IFS= read -r line; do
                log_detail "$line"
            done <<< "$duplicates"
        fi
    fi
}

# 9. アクション指向チェック（Action-Oriented）
check_action_oriented() {
    local file="$1"
    local filename=$(basename "$file")
    local relative_path="${file#$AGENTS_DIR/}"

    local clean_content=$(get_clean_content "$file")

    # 動詞から始まる行の割合
    local total_lines=$(echo "$clean_content" | grep -E "^- |^[0-9]\." | wc -l | tr -d ' ')

    if [ "$total_lines" -eq 0 ]; then
        return 0  # リスト項目がない場合はスキップ
    fi

    # 動詞パターン（日本語・英語）
    local action_verbs="^- [A-Z]|^- (Use|Add|Remove|Update|Check|Verify|Ensure|Avoid|Include|Implement)|^- (使用|追加|削除|更新|確認|検証|回避|含める|実装)"
    local action_lines=$(echo "$clean_content" | grep -E "$action_verbs" | wc -l | tr -d ' ')

    local ratio=$((action_lines * 100 / total_lines))

    if [ "$ratio" -lt 30 ]; then
        log_low "[$relative_path] Low action-oriented ratio ($ratio% of list items)"
        return 1
    fi

    return 0
}

# ファイル単位の総合チェック
check_file_quality() {
    local file="$1"
    local filename=$(basename "$file")
    local relative_path="${file#$AGENTS_DIR/}"

    local count=$(cat "$TOTAL_FILES_FILE")
    echo $((count + 1)) > "$TOTAL_FILES_FILE"

    local issues=0

    # 各チェックを実行
    check_vague_language "$file" || ((issues++))
    check_structure "$file" || ((issues++))
    check_examples "$file" || ((issues++))
    check_task_specific "$file" || ((issues++))
    check_file_size "$file" || ((issues++))
    check_progressive_disclosure "$file" || ((issues++))
    check_metadata "$file" || ((issues++))
    check_paths_format "$file" || ((issues++))
    check_action_oriented "$file" || ((issues++))

    # 問題がなければ成功メッセージ
    if [ $issues -eq 0 ]; then
        log_success "$relative_path - All quality checks passed ✨"
    fi

    return $issues
}

# カテゴリ別チェック
check_category() {
    local category="$1"

    log_info "Checking $category quality..."
    echo ""

    if [ ! -d "$AGENTS_DIR/$category" ]; then
        log_warning "Directory not found: $category"
        return
    fi

    find "$AGENTS_DIR/$category" -type f -name "*.md" ! -path "*/sync/*" | while IFS= read -r file; do
        check_file_quality "$file"
    done

    # 重複チェック
    echo ""
    check_duplication "$category"
    echo ""
}

# メイン処理
main() {
    echo ""
    echo "========================================"
    echo "  AI Agent Prompt Quality Check"
    echo "========================================"
    echo ""

    if [ ! -d "$AGENTS_DIR" ]; then
        log_error ".agents/ directory not found"
        exit 1
    fi

    log_info "Checking against best practices from:"
    log_detail "✓ Cursor: Keep rules under 500 lines"
    log_detail "✓ GitHub Copilot: Max 2 pages, not task-specific"
    log_detail "✓ Claude Code: Concrete examples, structured format"
    echo ""

    echo -e "${CYAN}💡 Tip:${NC} For checks against the ${CYAN}latest${NC} official documentation,"
    echo -e "   use the ${CYAN}prompt-quality-checker${NC} agent in Claude Code."
    echo -e "   It fetches current guidelines from Cursor, Copilot, and Claude docs."
    echo ""

    # カテゴリ別チェック
    check_category "rules"
    check_category "skills"
    check_category "agents"
    check_category "commands"

    # サマリー
    echo "========================================"
    echo "  Quality Check Summary"
    echo "========================================"
    echo ""

    local TOTAL_FILES=$(cat "$TOTAL_FILES_FILE")
    local HIGH_ISSUES=$(cat "$HIGH_ISSUES_FILE")
    local MEDIUM_ISSUES=$(cat "$MEDIUM_ISSUES_FILE")
    local LOW_ISSUES=$(cat "$LOW_ISSUES_FILE")

    echo -e "${CYAN}Files Checked:${NC} $TOTAL_FILES"
    echo ""

    if [ "$HIGH_ISSUES" -gt 0 ]; then
        echo -e "${RED}🔴 High Priority Issues:${NC} $HIGH_ISSUES"
    fi
    if [ "$MEDIUM_ISSUES" -gt 0 ]; then
        echo -e "${YELLOW}🟡 Medium Priority Issues:${NC} $MEDIUM_ISSUES"
    fi
    if [ "$LOW_ISSUES" -gt 0 ]; then
        echo -e "${GREEN}🟢 Low Priority Issues:${NC} $LOW_ISSUES"
    fi
    echo ""

    # 総合評価
    local total_issues=$((HIGH_ISSUES + MEDIUM_ISSUES + LOW_ISSUES))

    if [ "$total_issues" -eq 0 ]; then
        log_success "All quality checks passed! Excellent work! ✨"
        echo ""
        exit 0
    else
        if [ "$HIGH_ISSUES" -eq 0 ]; then
            echo -e "${CYAN}Recommendations:${NC}"
            echo "  - Address medium priority issues to improve quality"
            echo "  - Low priority issues are optional improvements"
            echo ""
            echo -e "${GREEN}Quality check completed with minor issues.${NC}"
            exit 0
        else
            echo -e "${CYAN}Recommendations:${NC}"
            echo "  - Fix high priority issues (missing metadata, excessive size)"
            echo "  - Review medium priority issues (structure, clarity)"
            echo "  - Consider best practices from Cursor, Copilot, Claude docs"
            echo ""
            echo -e "${RED}Quality check found issues requiring attention.${NC}"
            exit 1
        fi
    fi
}

main "$@"
