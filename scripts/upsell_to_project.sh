#!/bin/bash

# カラー定義
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# ソースディレクトリ（ユーザーローカル）
SRC_AGENTS="$HOME/.agents"

# 使用方法を表示
usage() {
    echo "使用方法: $0 [OPTIONS]"
    echo ""
    echo "ユーザーローカルの .agents 内のアイテムをプロジェクトにコピーします。"
    echo ""
    echo "オプション:"
    echo "  -p, --path PATH   プロジェクトルートパスを指定"
    echo "  -v, --verbose     詳細な出力"
    echo "  -h, --help        このヘルプメッセージを表示"
    echo ""
    echo "例:"
    echo "  $0                    # カレントディレクトリからプロジェクトを検出"
    echo "  $0 -p /path/to/proj   # 指定パスのプロジェクトにコピー"
    exit 1
}

# オプション解析
VERBOSE=false
PROJECT_PATH=""

while [[ $# -gt 0 ]]; do
    case $1 in
        -p|--path)
            PROJECT_PATH="$2"
            shift 2
            ;;
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        -h|--help)
            usage
            ;;
        *)
            echo -e "${RED}エラー: 不明なオプション: $1${NC}"
            usage
            ;;
    esac
done

# ソースディレクトリの存在確認
if [ ! -d "$SRC_AGENTS" ]; then
    echo -e "${RED}エラー: ユーザーローカルの .agents が見つかりません: $SRC_AGENTS${NC}"
    exit 1
fi

# プロジェクトルートを検出
detect_project_root() {
    local dir="$1"

    # gitルートを探す
    if command -v git &> /dev/null; then
        local git_root
        git_root=$(cd "$dir" 2>/dev/null && git rev-parse --show-toplevel 2>/dev/null)
        if [ -n "$git_root" ]; then
            echo "$git_root"
            return 0
        fi
    fi

    return 1
}

# プロジェクトルートの決定
if [ -n "$PROJECT_PATH" ]; then
    # パスが指定された場合
    if [ ! -d "$PROJECT_PATH" ]; then
        echo -e "${RED}エラー: 指定されたパスが存在しません: $PROJECT_PATH${NC}"
        exit 1
    fi
    PROJECT_ROOT="$PROJECT_PATH"
else
    # カレントディレクトリから検出
    PROJECT_ROOT=$(detect_project_root "$(pwd)")

    if [ -z "$PROJECT_ROOT" ]; then
        echo -e "${YELLOW}警告: gitプロジェクトを検出できませんでした${NC}"
        echo -n "プロジェクトルートパスを入力してください: "
        read -r PROJECT_PATH < /dev/tty

        if [ -z "$PROJECT_PATH" ]; then
            echo -e "${RED}エラー: パスが入力されませんでした${NC}"
            exit 1
        fi

        if [ ! -d "$PROJECT_PATH" ]; then
            echo -e "${RED}エラー: 指定されたパスが存在しません: $PROJECT_PATH${NC}"
            exit 1
        fi

        PROJECT_ROOT="$PROJECT_PATH"
    fi
fi

DEST_AGENTS="$PROJECT_ROOT/.agents"

echo -e "${GREEN}=== プロジェクトへのアップセルスクリプト ===${NC}"
echo "ソース: $SRC_AGENTS"
echo "プロジェクト: $PROJECT_ROOT"
echo ""

# 対象サブフォルダ
SUBDIRS=("agents" "commands" "skills" "rules")

# アイテム情報を格納する配列
declare -a ITEMS=()
declare -a ITEM_PATHS=()
declare -a ITEM_STATUS=()

# アイテムの差分チェック
check_diff() {
    local src="$1"
    local dest="$2"

    if [ ! -e "$dest" ]; then
        echo "new"
        return
    fi

    if [ -d "$src" ]; then
        # ディレクトリの場合: 全ファイルを比較
        local has_diff=false
        while IFS= read -r src_file; do
            local rel="${src_file#$src/}"
            local dest_file="$dest/$rel"
            if [ ! -f "$dest_file" ]; then
                has_diff=true
                break
            fi
            if ! diff -q "$src_file" "$dest_file" > /dev/null 2>&1; then
                has_diff=true
                break
            fi
        done < <(find "$src" -type f 2>/dev/null)

        # 逆方向もチェック（destにあってsrcにないファイル）
        if [ "$has_diff" = false ]; then
            while IFS= read -r dest_file; do
                local rel="${dest_file#$dest/}"
                local src_file="$src/$rel"
                if [ ! -f "$src_file" ]; then
                    has_diff=true
                    break
                fi
            done < <(find "$dest" -type f 2>/dev/null)
        fi

        if [ "$has_diff" = true ]; then
            echo "update"
        else
            echo "same"
        fi
    else
        # ファイルの場合
        if diff -q "$src" "$dest" > /dev/null 2>&1; then
            echo "same"
        else
            echo "update"
        fi
    fi
}

# アイテム収集
echo -e "${CYAN}アイテムを収集中...${NC}"

for subdir in "${SUBDIRS[@]}"; do
    src_subdir="$SRC_AGENTS/$subdir"
    dest_subdir="$DEST_AGENTS/$subdir"

    if [ ! -d "$src_subdir" ]; then
        continue
    fi

    while IFS= read -r -d '' item_path; do
        item_name=$(basename "$item_path")
        dest_item="$dest_subdir/$item_name"

        status=$(check_diff "$item_path" "$dest_item")

        # 同一のものはスキップ
        if [ "$status" = "same" ]; then
            if [ "$VERBOSE" = true ]; then
                echo -e "  ${GREEN}=${NC} $subdir/$item_name (同一・スキップ)"
            fi
            continue
        fi

        ITEMS+=("$subdir/$item_name")
        ITEM_PATHS+=("$item_path")
        ITEM_STATUS+=("$status")
    done < <(find "$src_subdir" -maxdepth 1 -mindepth 1 \( -type f -o -type d \) -print0 | sort -z)
done

# アイテムがない場合
if [ ${#ITEMS[@]} -eq 0 ]; then
    echo ""
    echo -e "${GREEN}すべてのアイテムがプロジェクトと同一です。コピーするものはありません。${NC}"
    exit 0
fi

# 表を表示
echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
printf "${BOLD}%-4s %-12s %-30s %-10s${NC}\n" "No." "カテゴリ" "アイテム名" "ステータス"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

for i in "${!ITEMS[@]}"; do
    num=$((i + 1))
    full_path="${ITEMS[$i]}"
    category="${full_path%%/*}"
    item_name="${full_path#*/}"
    status="${ITEM_STATUS[$i]}"

    # 名前から .md を除去（表示用）
    display_name="${item_name%.md}"

    # ステータスに色をつける
    if [ "$status" = "new" ]; then
        status_display="${GREEN}新規${NC}"
    else
        status_display="${YELLOW}更新${NC}"
    fi

    printf "%-4s %-12s %-30s " "$num" "$category" "$display_name"
    echo -e "$status_display"
done

echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "操作:"
echo "  - 番号をカンマ区切りで入力 (例: 1,3,5)"
echo "  - 範囲指定も可能 (例: 1-5,8,10-12)"
echo "  - 'a' で全て選択"
echo "  - 'q' でキャンセル"
echo ""
echo -n "アップセルする番号を入力: "
read -r input < /dev/tty

# 入力の解析
if [ "$input" = "q" ] || [ -z "$input" ]; then
    echo -e "${YELLOW}キャンセルしました${NC}"
    exit 0
fi

# 選択された番号を解析
declare -a SELECTED=()

if [ "$input" = "a" ]; then
    # 全選択
    for i in "${!ITEMS[@]}"; do
        SELECTED+=($((i + 1)))
    done
else
    # カンマ区切りで分割
    IFS=',' read -ra parts <<< "$input"
    for part in "${parts[@]}"; do
        # 空白を除去
        part=$(echo "$part" | tr -d ' ')

        if [[ "$part" =~ ^([0-9]+)-([0-9]+)$ ]]; then
            # 範囲指定
            start="${BASH_REMATCH[1]}"
            end="${BASH_REMATCH[2]}"
            for ((n=start; n<=end; n++)); do
                if [ "$n" -ge 1 ] && [ "$n" -le ${#ITEMS[@]} ]; then
                    SELECTED+=("$n")
                fi
            done
        elif [[ "$part" =~ ^[0-9]+$ ]]; then
            # 単一番号
            if [ "$part" -ge 1 ] && [ "$part" -le ${#ITEMS[@]} ]; then
                SELECTED+=("$part")
            fi
        fi
    done
fi

# 重複を除去
SELECTED=($(echo "${SELECTED[@]}" | tr ' ' '\n' | sort -nu))

if [ ${#SELECTED[@]} -eq 0 ]; then
    echo -e "${YELLOW}有効な番号が選択されませんでした${NC}"
    exit 0
fi

# 選択内容の確認
echo ""
echo -e "${CYAN}選択されたアイテム:${NC}"
for num in "${SELECTED[@]}"; do
    idx=$((num - 1))
    echo -e "  ${GREEN}✓${NC} ${ITEMS[$idx]}"
done
echo ""
echo -n "これらをプロジェクトにコピーしますか? (Y/n): "
read -r confirm < /dev/tty

case $confirm in
    [Nn]*)
        echo -e "${YELLOW}キャンセルしました${NC}"
        exit 0
        ;;
esac

# コピー実行
echo ""
echo -e "${GREEN}コピー中...${NC}"

for num in "${SELECTED[@]}"; do
    idx=$((num - 1))
    full_path="${ITEMS[$idx]}"
    src_path="${ITEM_PATHS[$idx]}"
    status="${ITEM_STATUS[$idx]}"

    category="${full_path%%/*}"
    item_name="${full_path#*/}"

    dest_path="$DEST_AGENTS/$category/$item_name"

    # ディレクトリ作成
    mkdir -p "$(dirname "$dest_path")"

    if [ -d "$src_path" ]; then
        # ディレクトリの場合
        if [ -d "$dest_path" ]; then
            rm -rf "$dest_path"
        fi
        cp -r "$src_path" "$dest_path"
    else
        # ファイルの場合
        cp "$src_path" "$dest_path"
    fi

    if [ "$status" = "new" ]; then
        echo -e "  ${GREEN}+${NC} $full_path (新規)"
    else
        echo -e "  ${YELLOW}↑${NC} $full_path (更新)"
    fi
done

echo ""
echo -e "${GREEN}=== コピー完了 ===${NC}"

# sync スクリプトの実行確認
SYNC_SCRIPT="$DEST_AGENTS/sync/sync.sh"
if [ ! -f "$SYNC_SCRIPT" ]; then
    SYNC_SCRIPT="$DEST_AGENTS/scripts/sync/sync.sh"
fi

if [ -f "$SYNC_SCRIPT" ]; then
    echo ""
    echo -n ".claude, .cursor, .github への同期を実行しますか? (Y/n): "
    read -r sync_confirm < /dev/tty

    case $sync_confirm in
        [Nn]*)
            echo -e "${YELLOW}同期をスキップしました${NC}"
            echo "手動で実行する場合: $SYNC_SCRIPT all"
            ;;
        *)
            echo ""
            echo -e "${GREEN}同期を実行中...${NC}"
            bash "$SYNC_SCRIPT" all
            if [ $? -eq 0 ]; then
                echo -e "${GREEN}✓ 同期完了${NC}"
            else
                echo -e "${RED}✗ 同期中にエラーが発生しました${NC}"
            fi
            ;;
    esac
else
    echo ""
    echo -e "${YELLOW}注意: sync.sh が見つかりませんでした${NC}"
    echo ".claude, .cursor, .github への同期が必要な場合は手動で行ってください。"
fi
