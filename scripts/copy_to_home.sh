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
    echo "  -f, --force    既存ファイルを確認なしで上書き"
    echo "  -v, --verbose  詳細な出力（同一ファイルも表示）"
    echo "  -h, --help     このヘルプメッセージを表示"
    echo ""
    echo "このスクリプトは以下のフォルダをコピーします:"
    echo "  .agents, .claude, .cursor, .github"
    echo ""
    echo "例:"
    echo "  $0 -r username/repo -b main -f"
    echo "  $0 -v                           # 詳細出力"
    echo "  $0 --here                       # カレントディレクトリにコピー"
    exit 1
}

# オプション解析
FORCE=false
VERBOSE=false
HERE=false
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
        -f|--force)
            FORCE=true
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

echo -e "${GREEN}=== コピー完了 ===${NC}"
