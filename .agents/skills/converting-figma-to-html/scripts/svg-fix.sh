#!/bin/bash
#
# SVG Fix Script
# Figma APIからダウンロードしたSVGファイルの問題を自動修正する
#
# Usage:
#   ./svg-fix.sh <directory>
#   ./svg-fix.sh assets/
#
# Fixes:
#   - width="100%" → width="<viewBox width>"
#   - height="100%" → height="<viewBox height>"
#   - Removes preserveAspectRatio="none"
#   - Removes overflow="visible"
#   - Removes style="display: block;"
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
FIXED=0

echo "=========================================="
echo "SVG Auto-Fix"
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
    NEEDS_FIX=0

    # Check if file needs fixing
    if grep -q 'width="100%"\|height="100%"\|preserveAspectRatio="none"\|overflow="visible"\|style="display: block;"' "$svg"; then
        NEEDS_FIX=1
    fi

    if [ $NEEDS_FIX -eq 0 ]; then
        echo -e "${GREEN}[SKIP]${NC} $svg (already valid)"
        continue
    fi

    echo -e "${YELLOW}[FIXING]${NC} $svg"

    # Extract viewBox dimensions
    VIEWBOX=$(grep -o 'viewBox="[^"]*"' "$svg" | head -1)
    if [ -z "$VIEWBOX" ]; then
        echo -e "  ${RED}Warning: No viewBox found, cannot determine dimensions${NC}"
        continue
    fi

    # Parse viewBox: "0 0 width height"
    WIDTH=$(echo "$VIEWBOX" | sed 's/viewBox="[0-9]* [0-9]* \([0-9]*\) [0-9]*"/\1/')
    HEIGHT=$(echo "$VIEWBOX" | sed 's/viewBox="[0-9]* [0-9]* [0-9]* \([0-9]*\)"/\1/')

    echo "  viewBox dimensions: ${WIDTH}x${HEIGHT}px"

    # Create backup
    cp "$svg" "${svg}.bak"

    # Apply fixes
    # 1. Remove preserveAspectRatio="none"
    sed -i '' 's/ preserveAspectRatio="none"//g' "$svg"

    # 2. Remove overflow="visible"
    sed -i '' 's/ overflow="visible"//g' "$svg"

    # 3. Remove style="display: block;"
    sed -i '' 's/ style="display: block;"//g' "$svg"

    # 4. Replace width="100%" with actual width
    sed -i '' "s/width=\"100%\"/width=\"${WIDTH}\"/g" "$svg"

    # 5. Replace height="100%" with actual height
    sed -i '' "s/height=\"100%\"/height=\"${HEIGHT}\"/g" "$svg"

    # 6. Ensure fill="none" is present if not already
    if ! grep -q 'fill="none"' "$svg"; then
        # Add fill="none" after viewBox
        sed -i '' 's/\(viewBox="[^"]*"\)/\1 fill="none"/g' "$svg"
    fi

    # Remove backup if successful
    rm "${svg}.bak"

    echo -e "  ${GREEN}Fixed!${NC} Set to ${WIDTH}x${HEIGHT}px"
    ((FIXED++))
done

echo ""
echo "=========================================="
echo "Summary"
echo "=========================================="
echo "Total SVG files: $(echo "$SVG_FILES" | wc -l | tr -d ' ')"
echo -e "Fixed: ${GREEN}$FIXED${NC}"

if [ $FIXED -gt 0 ]; then
    echo ""
    echo "Run validation to confirm:"
    echo "  .agents/skills/converting-figma-to-html/scripts/svg-validate.sh $DIRECTORY"
fi

exit 0
