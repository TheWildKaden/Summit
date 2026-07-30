#!/usr/bin/env bash

set -euo pipefail

cd "$(dirname "$0")"

# =========================
# Summit Build System
# =========================

MODE=${1:-"build"}

SRC="./src/init.luau"
DEV_SRC=${2:-"./main.luau"}

OUTPUT="./dist/Summit.lua"
TEMP="./dist/.temp.lua"

CONFIG="./darklua.json"

HEADER="./build/header.lua"
PACKAGE="./package.json"


# Colors
GREEN='\033[38;2;48;255;106m'
BLUE='\033[38;2;50;231;255m'
RED='\033[38;2;255;74;50m'
GRAY='\033[38;2;150;150;150m'
RESET='\033[0m'


mkdir -p dist build


if ! command -v darklua >/dev/null 2>&1; then
	echo -e "${RED}[ × ]${RESET} Darklua is not installed."
	exit 1
fi


if [ "$MODE" = "dev" ]; then
	INPUT="$DEV_SRC"
	PREFIX="${BLUE}[ DEV ]${RESET}"
else
	INPUT="$SRC"
	PREFIX="${BLUE}[ BUILD ]${RESET}"
fi


if [ ! -f "$INPUT" ]; then
	echo -e "${RED}[ × ]${RESET} Missing input: $INPUT"
	exit 1
fi


if [ ! -f "$CONFIG" ]; then
	echo -e "${RED}[ × ]${RESET} Missing darklua.json"
	exit 1
fi


if [ ! -f "$PACKAGE" ]; then
	echo -e "${RED}[ × ]${RESET} Missing package.json"
	exit 1
fi


VERSION=$(node -p "require('./package.json').version || '0.0.0'")
DESCRIPTION=$(node -p "require('./package.json').description || ''")
REPOSITORY=$(node -p "require('./package.json').repository || ''")
LICENSE=$(node -p "require('./package.json').license || ''")

DATE=$(date '+%Y-%m-%d')


if [ -f "$HEADER" ]; then

	BUILD_HEADER=$(cat "$HEADER")

	BUILD_HEADER="${BUILD_HEADER//'{{VERSION}}'/$VERSION}"
	BUILD_HEADER="${BUILD_HEADER//'{{BUILD_DATE}}'/$DATE}"
	BUILD_HEADER="${BUILD_HEADER//'{{DESCRIPTION}}'/$DESCRIPTION}"
	BUILD_HEADER="${BUILD_HEADER//'{{REPOSITORY}}'/$REPOSITORY}"
	BUILD_HEADER="${BUILD_HEADER//'{{LICENSE}}'/$LICENSE}"

else

	BUILD_HEADER="-- Summit UI Library
-- Version: $VERSION
-- Built: $DATE"

fi


echo -e "${GRAY}[ > ]${RESET} Bundling $INPUT"


START=$(date +%s%N)


if ! darklua process \
	"$INPUT" \
	"$TEMP" \
	--config "$CONFIG"
then

	echo -e "${RED}[ × ]${RESET} Darklua failed"
	rm -f "$TEMP"
	exit 1

fi


END=$(date +%s%N)

TIME=$((($END - $START) / 1000000))


{
	echo "$BUILD_HEADER"
	echo ""
	cat "$TEMP"
} > "$OUTPUT"


rm -f "$TEMP"


SIZE=$(($(wc -c < "$OUTPUT") / 1024))


echo ""
echo -e "${GREEN}[ ✓ ]${RESET} $PREFIX"
echo -e "${GREEN}[ > ]${RESET} Summit built successfully"
echo -e "${GREEN}[ > ]${RESET} Version: $VERSION"
echo -e "${GREEN}[ > ]${RESET} Time: ${TIME}ms"
echo -e "${GREEN}[ > ]${RESET} Size: ${SIZE}KB"
echo -e "${GREEN}[ > ]${RESET} Output: $OUTPUT"
echo ""