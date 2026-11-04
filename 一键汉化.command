#!/bin/bash
# macOS Finder 双击一键汉化 Antigravity 并自动重启
cd "$(dirname "$0")"

echo "======================================================="
echo "  Antigravity-ZH-CN 一键极速汉化 (macOS)"
echo "======================================================="
echo ""

node localize.js --now

if [ $? -eq 0 ]; then
  if [ -d "/Applications/Antigravity.app" ]; then
    xattr -cr "/Applications/Antigravity.app" 2>/dev/null || true
    echo ""
    echo "正在重新启动 Antigravity.app ..."
    open -a "/Applications/Antigravity.app"
  fi
  echo ""
  echo "🎉 汉化已完成！"
else
  echo ""
  echo "[错误] 汉化执行失败，请查看上方日志信息。"
  read -p "按回车键关闭窗口..."
fi
