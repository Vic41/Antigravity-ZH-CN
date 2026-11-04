#!/bin/bash
# Antigravity-ZH-CN 终端一键汉化脚本 (macOS / Linux)
cd "$(dirname "$0")"

echo "======================================================="
echo "  Antigravity-ZH-CN 一键汉化工具 (macOS / Linux)"
echo "======================================================="
echo ""

node localize.js --now "$@"
