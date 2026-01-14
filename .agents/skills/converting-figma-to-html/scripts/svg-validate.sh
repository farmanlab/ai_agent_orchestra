#!/bin/bash
#
# SVG Validation Script
# Figma APIからダウンロードしたSVGファイルの問題を検出する
#
# Usage:
#   ./svg-validate.sh <directory>
#   ./svg-validate.sh assets/
#
# Checks:
#   - width="100%" (should be fixed pixel value)
#   - height="100%" (should be fixed pixel value)
#   - preserveAspectRatio="none" (should be removed)
#   - overflow="visible" (should be removed)
#

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Check if directory is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <directory>"
    echo "Example: $0 assets/"
    exit 1
fi

DIRECTORY="$1"
ERRORS=0
WARNINGS=0

echo "=========================================="
echo "SVG Validation Report"
echo "Directory: $DIRECTORY"
echo "=========================================="
echo ""

# Find all SVG files
SVG_FILES=$(find "$DIRECTORY" -name "*.svg" 2>/dev/null)

if [ -z "$SVG_FILES" ]; then
    echo "No SVG files found in $DIRECTORY"
    exit 0
fi

for svg in $SVG_FILES; do
    FILE_HAS_ERROR=0
    FILE_ERRORS=""

    # Check for width="100%"
    if grep -q 'width="100%"' "$svg"; then
        FILE_HAS_ERROR=1
        FILE_ERRORS="$FILE_ERRORS\n  - width=\"100%\" found (should be fixed pixel value from viewBox)"
        ((ERRORS++))
    fi

    # Check for height="100%"
    if grep -q 'height="100%"' "$svg"; then
        FILE_HAS_ERROR=1
        FILE_ERRORS="$FILE_ERRORS\n  - height=\"100%\" found (should be fixed pixel value from viewBox)"
        ((ERRORS++))
    fi

    # Check for preserveAspectRatio="none"
    if grep -q 'preserveAspectRatio="none"' "$svg"; then
        FILE_HAS_ERROR=1
        FILE_ERRORS="$FILE_ERRORS\n  - preserveAspectRatio=\"none\" found (should be removed)"
        ((ERRORS++))
    fi

    # Check for overflow="visible"
    if grep -q 'overflow="visible"' "$svg"; then
        FILE_HAS_ERROR=1
        FILE_ERRORS="$FILE_ERRORS\n  - overflow=\"visible\" found (should be removed)"
        ((WARNINGS++))
    fi

    # Check for style="display: block;"
    if grep -q 'style="display: block;"' "$svg"; then
        FILE_HAS_ERROR=1
        FILE_ERRORS="$FILE_ERRORS\n  - style=\"display: block;\" found (should be removed)"
        ((WARNINGS++))
    fi

    # Extract viewBox for reference
    VIEWBOX=$(grep -o 'viewBox="[^"]*"' "$svg" | head -1)

    if [ $FILE_HAS_ERROR -eq 1 ]; then
        echo -e "${RED}[ERROR]${NC} $svg"
        if [ -n "$VIEWBOX" ]; then
            echo "  $VIEWBOX"
        fi
        echo -e "$FILE_ERRORS"
        echo ""
    else
        echo -e "${GREEN}[OK]${NC} $svg"
        if [ -n "$VIEWBOX" ]; then
            # Extract width and height from viewBox
            WIDTH=$(echo "$VIEWBOX" | sed 's/.*viewBox="[0-9]* [0-9]* \([0-9]*\) [0-9]*".*/\1/')
            HEIGHT=$(echo "$VIEWBOX" | sed 's/.*viewBox="[0-9]* [0-9]* [0-9]* \([0-9]*\)".*/\1/')
            echo "  Dimensions: ${WIDTH}x${HEIGHT}px"
        fi
    fi
done

echo ""
echo "=========================================="
echo "Summary"
echo "=========================================="
echo "Total SVG files: $(echo "$SVG_FILES" | wc -l | tr -d ' ')"
echo -e "Errors: ${RED}$ERRORS${NC}"
echo -e "Warnings: ${YELLOW}$WARNINGS${NC}"

if [ $ERRORS -gt 0 ]; then
    echo ""
    echo -e "${RED}Fix required:${NC}"
    echo "  1. Replace width=\"100%\" height=\"100%\" with fixed pixel values from viewBox"
    echo "  2. Remove preserveAspectRatio=\"none\""
    echo "  3. Remove overflow=\"visible\" and style=\"display: block;\""
    echo ""
    echo "Example fix:"
    echo "  Before: <svg width=\"100%\" height=\"100%\" preserveAspectRatio=\"none\" viewBox=\"0 0 20 18\">"
    echo "  After:  <svg width=\"20\" height=\"18\" viewBox=\"0 0 20 18\" fill=\"none\">"
    exit 1
fi

echo ""
echo -e "${GREEN}All SVG files are valid!${NC}"
exit 0
