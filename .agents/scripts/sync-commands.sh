#!/bin/bash

# スクリプトの説明
# .agents配下のコマンドファイル(.md)に対して、
# .cursor/commands、.claude/commands、.github/promptsから自動的にシンボリックリンクを作成します
# .github/promptsでは拡張子が.prompt.mdになります
#
# 使い方:
#   ./sync-command-links.sh                    # 全ファイルに対して実行（確認あり）
#   ./sync-command-links.sh path/to/file.md    # 指定したファイルのみ実行

set -e

# ヘルプメッセージを表示する関数
show_help() {
    cat << EOF
Usage: $0 [FILE]

Create symlinks for command files from .agents/ to:
  - .cursor/commands/
  - .claude/commands/
  - .github/prompts/ (as .prompt.md)

Arguments:
  FILE    Optional. Path to a specific .md file in .agents/
          If not specified, all files will be processed (with confirmation)

Examples:
  $0                                    # Sync all files (with confirmation)
  $0 .agents/workflow/new-command.md    # Sync only the specified file

Options:
  -h, --help    Show this help message

EOF
    exit 0
}

# ヘルプオプションのチェック
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    show_help
fi

# リポジトリのルートディレクトリを取得
REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"

# 引数をチェック
TARGET_FILE="$1"

# 対象ディレクトリ
AGENTS_DIR="$REPO_ROOT/.agents"
CURSOR_COMMANDS_DIR="$REPO_ROOT/.cursor/commands"
CLAUDE_COMMANDS_DIR="$REPO_ROOT/.claude/commands"
GITHUB_PROMPTS_DIR="$REPO_ROOT/.github/prompts"

echo "=== Syncing command symlinks ==="
echo "Repository root: $REPO_ROOT"
echo ""

# 各ディレクトリが存在することを確認
mkdir -p "$CURSOR_COMMANDS_DIR"
mkdir -p "$CLAUDE_COMMANDS_DIR"
mkdir -p "$GITHUB_PROMPTS_DIR"

# 既存の壊れたシンボリックリンクを削除する関数
cleanup_broken_links() {
    local dir="$1"
    echo "Cleaning up broken symlinks in $dir..."

    find "$dir" -maxdepth 1 -type l | while read -r link; do
        if [ ! -e "$link" ]; then
            echo "  Removing broken link: $(basename "$link")"
            rm "$link"
        fi
    done
}

# 壊れたシンボリックリンクを削除
cleanup_broken_links "$CURSOR_COMMANDS_DIR"
cleanup_broken_links "$CLAUDE_COMMANDS_DIR"
cleanup_broken_links "$GITHUB_PROMPTS_DIR"
echo ""

# 単一ファイルに対してシンボリックリンクを作成する関数
create_symlinks_for_file() {
    local md_file="$1"

    # ファイルの存在確認
    if [ ! -f "$md_file" ]; then
        echo "Error: File not found: $md_file"
        exit 1
    fi

    # ファイル名を取得
    local filename="$(basename "$md_file")"

    # .agentsからの相対パスを取得
    local relative_path="${md_file#$AGENTS_DIR/}"

    echo "Processing: $relative_path"

    # .cursor/commandsからの相対パスを計算
    local cursor_target="../../.agents/$relative_path"
    local cursor_link="$CURSOR_COMMANDS_DIR/$filename"

    # .claude/commandsからの相対パスを計算
    local claude_target="../../.agents/$relative_path"
    local claude_link="$CLAUDE_COMMANDS_DIR/$filename"

    # .github/promptsからの相対パスを計算（拡張子を.prompt.mdに変更）
    local filename_without_ext="${filename%.md}"
    local github_filename="${filename_without_ext}.prompt.md"
    local github_target="../../.agents/$relative_path"
    local github_link="$GITHUB_PROMPTS_DIR/$github_filename"

    # 既存のシンボリックリンクを削除
    [ -L "$cursor_link" ] && rm "$cursor_link"
    [ -L "$claude_link" ] && rm "$claude_link"
    [ -L "$github_link" ] && rm "$github_link"

    # 新しいシンボリックリンクを作成
    ln -s "$cursor_target" "$cursor_link"
    echo "  Created: .cursor/commands/$filename -> $cursor_target"

    ln -s "$claude_target" "$claude_link"
    echo "  Created: .claude/commands/$filename -> $claude_target"

    ln -s "$github_target" "$github_link"
    echo "  Created: .github/prompts/$github_filename -> $github_target"

    echo ""
}

# 引数がある場合は指定されたファイルのみ処理
if [ -n "$TARGET_FILE" ]; then
    # 相対パスまたは絶対パスを絶対パスに変換
    if [[ "$TARGET_FILE" != /* ]]; then
        TARGET_FILE="$REPO_ROOT/$TARGET_FILE"
    fi

    # ファイルが.agents配下にあるか確認
    if [[ "$TARGET_FILE" != "$AGENTS_DIR"* ]]; then
        echo "Error: Target file must be under .agents directory"
        echo "Target: $TARGET_FILE"
        echo "Expected to be under: $AGENTS_DIR"
        exit 1
    fi

    # README.mdは除外
    if [[ "$(basename "$TARGET_FILE")" == "README.md" ]]; then
        echo "Error: README.md cannot be synced"
        exit 1
    fi

    echo "Target file: $TARGET_FILE"
    echo ""
    create_symlinks_for_file "$TARGET_FILE"
else
    # 引数がない場合は確認を求める
    echo "⚠️  WARNING: This will create/update symlinks for ALL command files in .agents/"
    echo ""
    echo "This will affect the following directories:"
    echo "  - .cursor/commands/"
    echo "  - .claude/commands/"
    echo "  - .github/prompts/"
    echo ""

    # ファイル数を数える
    file_count=$(find "$AGENTS_DIR" -type f -name "*.md" ! -name "README.md" | wc -l | tr -d ' ')
    echo "Number of files to process: $file_count"
    echo ""

    read -p "Do you want to continue? (y/N): " -n 1 -r
    echo

    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Cancelled."
        exit 0
    fi

    echo ""
    echo "Finding command files in .agents..."

    # .agents配下の全ての.mdファイルを検索（README.mdを除く）
    find "$AGENTS_DIR" -type f -name "*.md" ! -name "README.md" | while read -r md_file; do
        create_symlinks_for_file "$md_file"
    done
fi

echo "=== Sync complete ==="
echo ""
echo "Summary:"
echo "  .cursor/commands: $(find "$CURSOR_COMMANDS_DIR" -type l | wc -l | tr -d ' ') symlinks"
echo "  .claude/commands: $(find "$CLAUDE_COMMANDS_DIR" -type l | wc -l | tr -d ' ') symlinks"
echo "  .github/prompts: $(find "$GITHUB_PROMPTS_DIR" -type l | wc -l | tr -d ' ') symlinks"
