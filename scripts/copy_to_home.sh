#!/bin/bash

# カラー定義
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# デフォルト設定
DEFAULT_REPO="farmanlab/ai_agent_orchestra"
DEFAULT_BRANCH="main"

# 使用方法を表示
usage() {
    echo "使用方法: $0 [OPTIONS]"
    echo ""
    echo "オプション:"
    echo "  -r, --repo        GitHubリポジトリ (デフォルト: $DEFAULT_REPO)"
    echo "  -b, --branch      ブランチ名 (デフォルト: $DEFAULT_BRANCH)"
    echo "  -d, --here        カレントディレクトリにコピー（デフォルトはホームディレクトリ）"
    echo "  -a, --all         全フォルダを確認なしでコピー"
    echo "  -f, --force       既存ファイルを確認なしで上書き（--all を含む）"
    echo "  -i, --interactive .agents内のagents/commands/skills/rulesを個別に選択"
    echo "  -v, --verbose     詳細な出力（同一ファイルも表示）"
    echo "  -h, --help        このヘルプメッセージを表示"
    echo ""
    echo "このスクリプトは以下のフォルダとファイルをコピーします:"
    echo "  フォルダ: .agents, .claude, .cursor, .github"
    echo "  ファイル: AGENTS.md, CLAUDE.md"
    echo ""
    echo "デフォルトでは各フォルダのコピー前に確認を求めます。"
    echo "-a または -f オプションで確認をスキップできます。"
    echo "-i オプションで .agents 内のアイテムを個別に選択できます。"
    echo ""
    echo "例:"
    echo "  $0                              # フォルダごとに確認"
    echo "  $0 -a                           # 全フォルダを確認なしでコピー"
    echo "  $0 -i                           # agents/skills/rules/commandsを個別選択"
    echo "  $0 -r username/repo -b main -f  # 強制上書き"
    echo "  $0 -v                           # 詳細出力"
    echo "  $0 --here                       # カレントディレクトリにコピー"
    exit 1
}

# オプション解析
FORCE=false
VERBOSE=false
HERE=false
ALL=false
INTERACTIVE=false
REPO="$DEFAULT_REPO"
BRANCH="$DEFAULT_BRANCH"

while [[ $# -gt 0 ]]; do
    case $1 in
        -r|--repo)
            REPO="$2"
            shift 2
            ;;
        -b|--branch)
            BRANCH="$2"
            shift 2
            ;;
        -d|--here)
            HERE=true
            shift
            ;;
        -a|--all)
            ALL=true
            shift
            ;;
        -f|--force)
            FORCE=true
            ALL=true  # --force は --all を含む
            shift
            ;;
        -i|--interactive)
            INTERACTIVE=true
            shift
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

# コピー先ディレクトリの決定
if [ "$HERE" = true ]; then
    TARGET_DIR="$(pwd)"
else
    TARGET_DIR="$HOME"
fi
TEMP_DIR=$(mktemp -d)
ZIP_FILE="$TEMP_DIR/repo.zip"

# クリーンアップ関数
cleanup() {
    rm -rf "$TEMP_DIR"
}

# エラー時のクリーンアップ
trap cleanup EXIT

# コピー対象のフォルダ
FOLDERS=(".agents" ".claude" ".cursor" ".github")

# コピー対象のファイル（ルートレベル）
ROOT_FILES=("AGENTS.md" "CLAUDE.md")

echo -e "${GREEN}=== フォルダコピースクリプト ===${NC}"
echo "リポジトリ: $REPO"
echo "ブランチ: $BRANCH"
echo "コピー先: $TARGET_DIR"
echo ""

# スクリプトがローカルリポジトリ内で実行されているかチェック
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." 2>/dev/null && pwd)"
LOCAL_MODE=false

if [ -d "$SCRIPT_DIR/.agents" ] || [ -d "$SCRIPT_DIR/.claude" ]; then
    echo -e "${GREEN}ローカルモード: リポジトリ内で実行されています${NC}"
    LOCAL_MODE=true
    SRC_DIR="$SCRIPT_DIR"
else
    echo -e "${GREEN}リモートモード: GitHubからダウンロードします${NC}"

    # GitHubからzipをダウンロード
    DOWNLOAD_URL="https://github.com/$REPO/archive/refs/heads/$BRANCH.zip"
    echo -e "${YELLOW}ダウンロード中: $DOWNLOAD_URL${NC}"

    if command -v curl &> /dev/null; then
        curl -L -o "$ZIP_FILE" "$DOWNLOAD_URL" 2>/dev/null
    elif command -v wget &> /dev/null; then
        wget -O "$ZIP_FILE" "$DOWNLOAD_URL" 2>/dev/null
    else
        echo -e "${RED}エラー: curl または wget が必要です${NC}"
        exit 1
    fi

    if [ $? -ne 0 ] || [ ! -f "$ZIP_FILE" ]; then
        echo -e "${RED}エラー: ダウンロードに失敗しました${NC}"
        exit 1
    fi

    echo -e "${GREEN}✓ ダウンロード完了${NC}"

    # zipを展開
    echo -e "${YELLOW}展開中...${NC}"
    unzip -q "$ZIP_FILE" -d "$TEMP_DIR"

    if [ $? -ne 0 ]; then
        echo -e "${RED}エラー: 展開に失敗しました${NC}"
        exit 1
    fi

    # 展開されたディレクトリを見つける
    REPO_NAME=$(basename "$REPO")
    SRC_DIR="$TEMP_DIR/${REPO_NAME}-${BRANCH}"

    if [ ! -d "$SRC_DIR" ]; then
        echo -e "${RED}エラー: 展開されたディレクトリが見つかりません${NC}"
        exit 1
    fi

    echo -e "${GREEN}✓ 展開完了${NC}"
fi

echo ""

# ファイル単位でコピー（上書き確認付き）
copy_file() {
    local src="$1"
    local dest="$2"
    local rel_path="$3"

    if [ -f "$dest" ]; then
        if [ "$FORCE" = true ]; then
            cp -f "$src" "$dest"
            echo -e "  ${GREEN}✓${NC} $rel_path (上書き)"
        else
            # ファイルの差分があるか確認
            if ! diff -q "$src" "$dest" > /dev/null 2>&1; then
                echo -e "  ${YELLOW}?${NC} $rel_path (変更あり)"
                echo ""
                echo -e "  ${YELLOW}--- diff ---${NC}"
                diff --color=always -u "$dest" "$src" | head -50
                echo -e "  ${YELLOW}------------${NC}"
                echo ""
                echo -n "    上書きしますか? (y/N): "
                read answer < /dev/tty
                case $answer in
                    [Yy]*)
                        cp -f "$src" "$dest"
                        echo -e "    ${GREEN}✓${NC} 上書きしました"
                        ;;
                    *)
                        echo -e "    ${YELLOW}✗${NC} スキップしました"
                        ;;
                esac
                echo ""
            else
                # 同一ファイルは verbose 時のみ表示
                if [ "$VERBOSE" = true ]; then
                    echo -e "  ${GREEN}=${NC} $rel_path (同一)"
                fi
            fi
        fi
    else
        # 新規ファイル
        mkdir -p "$(dirname "$dest")"
        cp "$src" "$dest"
        echo -e "  ${GREEN}+${NC} $rel_path (新規)"
    fi
}

# インタラクティブモード: .agents内のアイテムを個別選択
interactive_select_agents() {
    local src_agents="$1"
    local dest_agents="$2"

    # 選択対象のサブフォルダ
    local AGENT_SUBDIRS=("agents" "commands" "skills" "rules")

    # 選択されたアイテムを記録する配列（通常の配列を使用）
    local SELECTED_ITEMS=()

    echo ""
    echo -e "${GREEN}=== インタラクティブモード ===${NC}"
    echo "各アイテムについて、インストールするかどうか選択してください。"
    echo "(y=はい, n=いいえ, a=このカテゴリ全て, s=このカテゴリスキップ)"
    echo ""

    for subdir in "${AGENT_SUBDIRS[@]}"; do
        local src_subdir="$src_agents/$subdir"
        local dest_subdir="$dest_agents/$subdir"

        if [ ! -d "$src_subdir" ]; then
            continue
        fi

        # サブフォルダ内のアイテム（ファイルまたはディレクトリ）を取得
        local items=()
        while IFS= read -r -d '' item; do
            items+=("$(basename "$item")")
        done < <(find "$src_subdir" -maxdepth 1 -mindepth 1 \( -type f -o -type d \) -print0 | sort -z)

        if [ ${#items[@]} -eq 0 ]; then
            continue
        fi

        echo -e "${YELLOW}━━━ $subdir (${#items[@]}件) ━━━${NC}"

        local skip_category=false
        local all_category=false

        for item in "${items[@]}"; do
            local item_path="$src_subdir/$item"
            local item_name="${item%.md}"  # .md拡張子を除去

            # 説明を取得（.mdファイルの場合はdescriptionを抽出）
            local description=""
            if [ -f "$item_path" ]; then
                description=$(grep -m1 "^description:" "$item_path" 2>/dev/null | sed 's/^description:[[:space:]]*//' | cut -c1-60)
            elif [ -f "$item_path/SKILL.md" ]; then
                description=$(grep -m1 "^description:" "$item_path/SKILL.md" 2>/dev/null | sed 's/^description:[[:space:]]*//' | cut -c1-60)
            fi

            if [ "$all_category" = true ]; then
                SELECTED_ITEMS+=("$subdir/$item")
                echo -e "  ${GREEN}✓${NC} $item_name"
                continue
            fi

            if [ "$skip_category" = true ]; then
                echo -e "  ${YELLOW}✗${NC} $item_name (スキップ)"
                continue
            fi

            # 既存チェック
            local exists_mark=""
            if [ -e "$dest_subdir/$item" ]; then
                exists_mark=" ${YELLOW}(既存)${NC}"
            fi

            echo -e "  ${GREEN}$item_name${NC}$exists_mark"
            if [ -n "$description" ]; then
                echo -e "    ${NC}$description${NC}"
            fi
            echo -n "    インストール? (y/N/a/s): "
            read -r answer < /dev/tty

            case $answer in
                [Yy]*)
                    SELECTED_ITEMS+=("$subdir/$item")
                    echo -e "    ${GREEN}→ 選択${NC}"
                    ;;
                [Aa]*)
                    all_category=true
                    SELECTED_ITEMS+=("$subdir/$item")
                    echo -e "    ${GREEN}→ このカテゴリ全て選択${NC}"
                    ;;
                [Ss]*)
                    skip_category=true
                    echo -e "    ${YELLOW}→ このカテゴリをスキップ${NC}"
                    ;;
                *)
                    echo -e "    ${YELLOW}→ スキップ${NC}"
                    ;;
            esac
        done
        echo ""
    done

    # 選択結果の確認
    local selected_count=${#SELECTED_ITEMS[@]}

    if [ $selected_count -eq 0 ]; then
        echo -e "${YELLOW}選択されたアイテムがありません。${NC}"
        return 1
    fi

    echo -e "${GREEN}━━━ 選択結果 ($selected_count 件) ━━━${NC}"
    for key in "${SELECTED_ITEMS[@]}"; do
        echo -e "  ${GREEN}✓${NC} $key"
    done
    echo ""

    echo -n "この選択でインストールしますか? (Y/n): "
    read -r confirm < /dev/tty
    case $confirm in
        [Nn]*)
            echo -e "${YELLOW}キャンセルしました${NC}"
            return 1
            ;;
    esac

    # 選択されたアイテムをコピー
    echo ""
    echo -e "${GREEN}選択されたアイテムをコピー中...${NC}"

    for key in "${SELECTED_ITEMS[@]}"; do
        local subdir="${key%%/*}"
        local item="${key#*/}"
        local src_item="$src_agents/$subdir/$item"
        local dest_item="$dest_agents/$subdir/$item"

        mkdir -p "$dest_agents/$subdir"

        if [ -d "$src_item" ]; then
            # ディレクトリの場合
            find "$src_item" -type f | while read -r src_file; do
                local rel_path="${src_file#$src_agents/}"
                local dest_file="$dest_agents/${rel_path}"
                copy_file "$src_file" "$dest_file" ".agents/$rel_path"
            done
        else
            # ファイルの場合
            copy_file "$src_item" "$dest_item" ".agents/$subdir/$item"
        fi
    done

    # .agents内のその他のファイル（sync, templates等）もコピー
    echo ""
    echo -e "${GREEN}その他の.agentsファイルをコピー中...${NC}"

    # 除外するサブフォルダ
    local exclude_dirs="agents|commands|skills|rules"

    find "$src_agents" -type f | while read -r src_file; do
        local rel_path="${src_file#$src_agents/}"
        local top_dir="${rel_path%%/*}"

        # 除外対象でなければコピー
        if ! echo "$top_dir" | grep -qE "^($exclude_dirs)$"; then
            local dest_file="$dest_agents/$rel_path"
            copy_file "$src_file" "$dest_file" ".agents/$rel_path"
        fi
    done

    return 0
}

# インタラクティブモードの処理フラグ
INTERACTIVE_AGENTS_DONE=false

# 各フォルダをコピー
for folder in "${FOLDERS[@]}"; do
    SRC="$SRC_DIR/$folder"
    DEST="$TARGET_DIR/$folder"

    # コピー元フォルダの存在確認
    if [ ! -d "$SRC" ]; then
        echo -e "${YELLOW}警告: $folder が見つかりません。スキップします。${NC}"
        continue
    fi

    # インタラクティブモードで .agents フォルダの場合は特別処理
    if [ "$INTERACTIVE" = true ] && [ "$folder" = ".agents" ]; then
        if interactive_select_agents "$SRC" "$DEST"; then
            INTERACTIVE_AGENTS_DONE=true
        fi
        echo ""
        continue
    fi

    # フォルダごとに確認（--all または --force がない場合）
    if [ "$ALL" = false ]; then
        # フォルダ内のファイル数をカウント
        file_count=$(find "$SRC" -type f | wc -l | tr -d ' ')
        echo -e "${YELLOW}$folder${NC} ($file_count ファイル) をコピーしますか? (y/N/a=全てyes): "
        read answer < /dev/tty
        case $answer in
            [Aa]*)
                ALL=true
                echo -e "  ${GREEN}✓${NC} 以降のフォルダは確認なしでコピーします"
                ;;
            [Yy]*)
                # このフォルダはコピーする
                ;;
            *)
                echo -e "  ${YELLOW}✗${NC} $folder をスキップしました"
                echo ""
                continue
                ;;
        esac
    fi

    echo -e "${GREEN}$folder を処理中...${NC}"

    # フォルダ内の全ファイルを処理
    find "$SRC" -type f | while read -r src_file; do
        # 相対パスを計算
        rel_path="${src_file#$SRC/}"
        dest_file="$DEST/$rel_path"

        copy_file "$src_file" "$dest_file" "$folder/$rel_path"
    done

    echo ""
done

# ルートレベルのファイルをコピー
echo -e "${GREEN}ルートファイルを処理中...${NC}"
for file in "${ROOT_FILES[@]}"; do
    SRC_FILE="$SRC_DIR/$file"
    DEST_FILE="$TARGET_DIR/$file"

    if [ ! -f "$SRC_FILE" ]; then
        if [ "$VERBOSE" = true ]; then
            echo -e "  ${YELLOW}-${NC} $file が見つかりません。スキップします。"
        fi
        continue
    fi

    copy_file "$SRC_FILE" "$DEST_FILE" "$file"
done
echo ""

echo -e "${GREEN}=== コピー完了 ===${NC}"

# インタラクティブモードで .agents がコピーされた場合は sync を実行
if [ "$INTERACTIVE_AGENTS_DONE" = true ]; then
    SYNC_SCRIPT="$TARGET_DIR/.agents/sync/sync.sh"

    if [ -f "$SYNC_SCRIPT" ]; then
        echo ""
        echo -e "${GREEN}=== 同期処理を実行 ===${NC}"
        echo "各エージェント形式に同期します..."
        echo ""

        # sync.sh を実行
        bash "$SYNC_SCRIPT" all

        if [ $? -eq 0 ]; then
            echo ""
            echo -e "${GREEN}✓ 同期完了${NC}"
        else
            echo ""
            echo -e "${RED}✗ 同期中にエラーが発生しました${NC}"
        fi
    else
        echo ""
        echo -e "${YELLOW}警告: sync.sh が見つかりません: $SYNC_SCRIPT${NC}"
        echo "手動で同期を実行してください: .agents/sync/sync.sh all"
    fi
fi
