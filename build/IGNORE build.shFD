#!/bin/bash

set -e

MODE=${1:-"build"}

# Colors
GREEN='\033[38;2;48;255;106m'
YELLOW='\033[38;2;255;210;50m'
BLUE='\033[38;2;50;231;255m'
RED='\033[38;2;255;74;50m'
GRAY='\033[38;2;150;150;150m'
RESET='\033[0m'

ROOT="$(pwd)"

SRC="./src/init.lua"
DEV_SRC=${2:-"./main.lua"}

OUTPUT="./dist/library.lua"
TEMP="./dist/.temp.lua"

CONFIG="./build/darklua.config.json"
PACKAGE_OUT="./build/package.lua"
HEADER="./build/header.lua"


mkdir -p dist build


echo "-- Generated from package.json | build.sh" > "$PACKAGE_OUT"
echo "" >> "$PACKAGE_OUT"
echo "return [[" >> "$PACKAGE_OUT"
cat package.json >> "$PACKAGE_OUT"
echo "]]" >> "$PACKAGE_OUT"


if [ "$MODE" = "dev" ]; then
    INPUT="$DEV_SRC"
    PREFIX="${YELLOW}[ DEV ]${RESET}"
else
    INPUT="$SRC"
    PREFIX="${BLUE}[ BUILD ]${RESET}"
fi


if [ ! -f "$INPUT" ]; then
    echo -e "${RED}[ × ]${RESET} Missing input file: $INPUT"
    exit 1
fi


if [ ! -f package.json ]; then
    echo -e "${RED}[ × ]${RESET} Missing package.json"
    exit 1
fi


PACKAGE=$(node -e "
const p=require('./package.json');
console.log(JSON.stringify({
version:p.version||'0.0.0',
description:p.description||'',
repository:p.repository||'',
license:p.license||''
}))
")


VERSION=$(echo "$PACKAGE" | node -pe "
JSON.parse(require('fs').readFileSync(0,'utf8')).version
")


DATE=$(date '+%Y-%m-%d')


if [ -f "$HEADER" ]; then
    BUILD_HEADER=$(cat "$HEADER" | node -e "
const pkg=$PACKAGE;
let h=require('fs').readFileSync(0,'utf8');

h=h.replace(/{{VERSION}}/g,pkg.version)
 .replace(/{{BUILD_DATE}}/g,'$DATE')
 .replace(/{{DESCRIPTION}}/g,pkg.description)
 .replace(/{{REPOSITORY}}/g,pkg.repository)
 .replace(/{{LICENSE}}/g,pkg.license)

console.log(h)
")
else
    BUILD_HEADER="-- Vlint UI Library
-- Version: $VERSION
-- Built: $DATE"
fi


echo -e "${GRAY}[ > ]${RESET} Bundling $INPUT"


START=$(date +%s%N)


if ! darklua process "$INPUT" "$TEMP" --config "$CONFIG"; then
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
echo -e "[ $(date '+%H:%M:%S') ]"
echo -e "${GREEN}[ ✓ ]${RESET} $PREFIX"
echo -e "${GREEN}[ > ]${RESET} Build completed"
echo -e "${GREEN}[ > ]${RESET} Version: $VERSION"
echo -e "${GREEN}[ > ]${RESET} Time: ${TIME}ms"
echo -e "${GREEN}[ > ]${RESET} Size: ${SIZE}KB"
echo -e "${GREEN}[ > ]${RESET} Output: $OUTPUT"
echo ""