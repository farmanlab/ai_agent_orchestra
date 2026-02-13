#!/bin/bash
#
# Check References Script
# .agents/ 配下のファイル参照が有効かどうかを検証
#
# Usage:
#   ./check-references.sh [target_dir]
#   ./check-references.sh .agents/skills/
#

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

# Default target directory
TARGET_DIR="${1:-.agents}"

# Check if directory exists
if [[ ! -d "$TARGET_DIR" ]]; then
  echo -e "${RED}Error: Directory not found: $TARGET_DIR${NC}"
  exit 1
fi

echo "=========================================="
echo "  Reference Check Report"
echo "=========================================="
echo ""
echo "Target: $TARGET_DIR"
echo "Date: $(date +%Y-%m-%d)"
echo ""

# Find all markdown files in skills, agents, rules, commands
FILES=$(find "$TARGET_DIR" \( -path "*/skills/*" -o -path "*/agents/*" -o -path "*/rules/*" -o -path "*/commands/*" \) -name "*.md" -type f 2>/dev/null | sort)

if [[ -z "$FILES" ]]; then
  echo -e "${YELLOW}No markdown files found in $TARGET_DIR${NC}"
  exit 0
fi

FILE_COUNT=$(echo "$FILES" | wc -l | tr -d ' ')
TOTAL_REFS=0
VALID_REFS=0
INVALID_REFS=0
ERROR_FILE=$(mktemp)

echo "$FILES" | while read -r file; do
  [[ -z "$file" ]] && continue
  DIR=$(dirname "$file")

  # Extract markdown links using perl
  # Exclude: URLs, anchors, example paths (skill-name, path/to, your-, my-, example)
  REFS=$(perl -ne 'while (/\[[^\]]*\]\(([^)]+)\)/g) { print "$1\n"; }' "$file" 2>/dev/null \
    | grep -v '^http' \
    | grep -v '^#' \
    | grep -v '^mailto:' \
    | grep -E '\.(md|sh|js|py|html|css|json|yaml|yml)$' \
    | grep -v 'skill-name' \
    | grep -v 'path/to' \
    | grep -v 'your-' \
    | grep -v 'my-' \
    | grep -v 'example' \
    | grep -v '\.\*' \
    | grep -v 'command-name')

  echo "$REFS" | while read -r ref; do
    [[ -z "$ref" ]] && continue

    # Handle anchor links (file.md#section)
    REF_FILE="${ref%%#*}"
    [[ -z "$REF_FILE" ]] && continue

    # Resolve path
    RESOLVED=$(python3 -c "import os; print(os.path.normpath(os.path.join('$DIR', '$REF_FILE')))" 2>/dev/null || echo "$DIR/$REF_FILE")

    if [[ -f "$RESOLVED" ]] || [[ -d "$RESOLVED" ]]; then
      echo "VALID" >> "$ERROR_FILE"
    else
      LINE=$(grep -n "$ref" "$file" 2>/dev/null | head -1 | cut -d: -f1)
      LINE=${LINE:-"?"}
      echo "INVALID|$file:$LINE|$ref|$RESOLVED" >> "$ERROR_FILE"
    fi
  done
done

# Count results
VALID_REFS=$(grep -c "^VALID$" "$ERROR_FILE" 2>/dev/null | tr -d '[:space:]' || echo 0)
INVALID_REFS=$(grep -c "^INVALID|" "$ERROR_FILE" 2>/dev/null | tr -d '[:space:]' || echo 0)
# Ensure numeric values
VALID_REFS=${VALID_REFS:-0}
INVALID_REFS=${INVALID_REFS:-0}
[[ ! "$VALID_REFS" =~ ^[0-9]+$ ]] && VALID_REFS=0
[[ ! "$INVALID_REFS" =~ ^[0-9]+$ ]] && INVALID_REFS=0
TOTAL_REFS=$((VALID_REFS + INVALID_REFS))

echo "Summary"
echo "=========================================="
echo "Files checked:    $FILE_COUNT"
echo "References found: $TOTAL_REFS"
echo -e "Valid:            ${GREEN}$VALID_REFS${NC}"
echo -e "Invalid:          ${RED}$INVALID_REFS${NC}"
echo ""

if [[ $INVALID_REFS -eq 0 ]]; then
  echo -e "${GREEN}✅ All references are valid${NC}"
  rm -f "$ERROR_FILE"
  exit 0
else
  echo -e "${RED}❌ Invalid references found:${NC}"
  echo ""
  echo "FILE:LINE | REFERENCE | RESOLVED PATH"
  echo "----------------------------------------------------------------------"
  grep "^INVALID|" "$ERROR_FILE" | while IFS='|' read -r _ file ref resolved; do
    echo "$file | $ref | $resolved"
  done

  echo ""
  echo "Fix suggestions:"
  echo "  1. If file was moved: Update the reference path"
  echo "  2. If file was deleted: Remove the reference"
  echo "  3. If file was renamed: Update to the new name"
  rm -f "$ERROR_FILE"
  exit 1
fi
