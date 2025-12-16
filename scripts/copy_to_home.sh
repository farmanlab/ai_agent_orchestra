#!/bin/bash

# カラー定義
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# 使用方法を表示
usage() {
    echo "使用方法: $0 [OPTIONS]"
    echo ""
    echo "オプション:"
    echo "  -f, --force    既存ファイルを確認なしで上書き"
    echo "  -h, --help     このヘルプメッセージを表示"
    echo ""
    echo "このスクリプトは以下のフォルダをホームディレクトリにコピーします:"
    echo "  .agents, .claude, .cursor, .github"
    exit 1
}

# オプション解析
FORCE=false
while [[ $# -gt 0 ]]; do
    case $1 in
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

# スクリプトのディレクトリを取得
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOME_DIR="$HOME"

# コピー対象のフォルダ
FOLDERS=(".agents" ".claude" ".cursor" ".github")

echo -e "${GREEN}=== フォルダコピースクリプト ===${NC}"
echo "コピー元: $SCRIPT_DIR"
echo "コピー先: $HOME_DIR"
echo ""

# 各フォルダをコピー
for folder in "${FOLDERS[@]}"; do
    SRC="$SCRIPT_DIR/$folder"
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
