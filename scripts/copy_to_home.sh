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
    echo "  -f, --force    既存ファイルを確認なしで上書き"
    echo "  -h, --help     このヘルプメッセージを表示"
    echo ""
    echo "このスクリプトは以下のフォルダをホームディレクトリにコピーします:"
    echo "  .agents, .claude, .cursor, .github"
    echo ""
    echo "例:"
    echo "  $0 -r username/repo -b main -f"
    exit 1
}

# オプション解析
FORCE=false
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
        -f|--force)
            FORCE=true
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

HOME_DIR="$HOME"
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
echo "コピー先: $HOME_DIR"
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

# 各フォルダをコピー
for folder in "${FOLDERS[@]}"; do
    SRC="$SRC_DIR/$folder"
    DEST="$HOME_DIR/$folder"

    # コピー元フォルダの存在確認
    if [ ! -d "$SRC" ]; then
        echo -e "${YELLOW}警告: $folder が見つかりません。スキップします。${NC}"
        continue
    fi

    # コピー先フォルダの存在確認
    if [ -d "$DEST" ]; then
        if [ "$FORCE" = true ]; then
            echo -e "${YELLOW}$folder を上書きコピーします...${NC}"
            cp -rf "$SRC" "$HOME_DIR/"
            echo -e "${GREEN}✓ $folder をコピーしました${NC}"
        else
            echo -e "${YELLOW}$folder は既に存在します。${NC}"
            read -p "上書きしますか? (y/N): " answer
            case $answer in
                [Yy]*)
                    cp -rf "$SRC" "$HOME_DIR/"
                    echo -e "${GREEN}✓ $folder をコピーしました${NC}"
                    ;;
                *)
                    echo -e "${YELLOW}✗ $folder のコピーをスキップしました${NC}"
                    ;;
            esac
        fi
    else
        echo -e "${GREEN}$folder をコピーします...${NC}"
        cp -r "$SRC" "$HOME_DIR/"
        echo -e "${GREEN}✓ $folder をコピーしました${NC}"
    fi
    echo ""
done

echo -e "${GREEN}=== コピー完了 ===${NC}"
