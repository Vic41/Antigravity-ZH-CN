#!/bin/bash
# macOS Finder 双击一键还原 Antigravity 官方英文原版
cd "$(dirname "$0")"

echo "======================================================="
echo "  Antigravity-ZH-CN 一键还原英文原版 (macOS)"
echo "======================================================="
echo ""

if command -v node >/dev/null 2>&1; then
  node localize.js --restore
  EXIT_CODE=$?
elif [ -f "/Applications/Antigravity.app/Contents/Resources/app.asar.bak" ]; then
  echo "[提示] 正在从安全备份 (app.asar.bak) 恢复官方英文原版..."
  pkill -xi antigravity 2>/dev/null || true
  pkill -xi language_server 2>/dev/null || true
  cp "/Applications/Antigravity.app/Contents/Resources/app.asar.bak" "/Applications/Antigravity.app/Contents/Resources/app.asar"
  EXIT_CODE=$?
else
  echo "[错误] 未找到安全备份文件 app.asar.bak，无法还原。"
  EXIT_CODE=1
fi

if [ $EXIT_CODE -eq 0 ]; then
  if [ -d "/Applications/Antigravity.app" ]; then
    xattr -cr "/Applications/Antigravity.app" 2>/dev/null || true
    echo ""
    echo "正在重新启动 Antigravity.app ..."
    open -a "/Applications/Antigravity.app"
  fi
  echo ""
  echo "✅ 已恢复为官方英文原版！"
else
  echo ""
  echo "[错误] 还原失败，请查看上方日志信息。"
  read -p "按回车键关闭窗口..."
fi
