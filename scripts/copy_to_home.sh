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
    echo "  -r, --repo     GitHubリポジトリ (デフォルト: $DEFAULT_REPO)"
    echo "  -b, --branch   ブランチ名 (デフォルト: $DEFAULT_BRANCH)"
    echo "  -d, --here     カレントディレクトリにコピー（デフォルトはホームディレクトリ）"
    echo "  -a, --all      全フォルダを確認なしでコピー"
    echo "  -f, --force    既存ファイルを確認なしで上書き（--all を含む）"
    echo "  -v, --verbose  詳細な出力（同一ファイルも表示）"
    echo "  -h, --help     このヘルプメッセージを表示"
    echo ""
    echo "このスクリプトは以下のフォルダとファイルをコピーします:"
    echo "  フォルダ: .agents, .claude, .cursor, .github"
    echo "  ファイル: AGENTS.md, CLAUDE.md"
    echo ""
    echo "デフォルトでは各フォルダのコピー前に確認を求めます。"
    echo "-a または -f オプションで確認をスキップできます。"
    echo ""
    echo "例:"
    echo "  $0                              # フォルダごとに確認"
    echo "  $0 -a                           # 全フォルダを確認なしでコピー"
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

# 各フォルダをコピー
for folder in "${FOLDERS[@]}"; do
    SRC="$SRC_DIR/$folder"
    DEST="$TARGET_DIR/$folder"

    # コピー元フォルダの存在確認
    if [ ! -d "$SRC" ]; then
        echo -e "${YELLOW}警告: $folder が見つかりません。スキップします。${NC}"
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
