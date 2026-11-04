#!/bin/bash
# Antigravity-ZH-CN Web 控制中心启动脚本 (macOS / Linux)
cd "$(dirname "$0")"

echo "======================================================="
echo "  Antigravity-ZH-CN 本地化控制中心"
echo "======================================================="
echo ""
echo "正在启动本地化后台服务..."
echo "正在默认浏览器中打开控制面板: http://localhost:3388"
echo ""

if [ "$(uname)" = "Darwin" ]; then
  (sleep 0.6 && open "http://localhost:3388") &
elif which xdg-open > /dev/null 2>&1; then
  (sleep 0.6 && xdg-open "http://localhost:3388") &
elif which gnome-open > /dev/null 2>&1; then
  (sleep 0.6 && gnome-open "http://localhost:3388") &
fi

node localize.js

if [ $? -ne 0 ]; then
  echo ""
  echo "[错误] 启动本地化服务失败，请确认系统已安装 Node.js (https://nodejs.org)。"
  echo ""
  read -p "按回车键退出..."
fi
