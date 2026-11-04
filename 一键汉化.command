#!/bin/bash
# macOS Finder 双击一键汉化 Antigravity 并自动重启
cd "$(dirname "$0")"

echo "======================================================="
echo "  Antigravity-ZH-CN 一键极速汉化 (macOS)"
echo "======================================================="
echo ""

if command -v node >/dev/null 2>&1; then
  node localize.js --now
  EXIT_CODE=$?
elif [ -f "app.asar.ready" ] && [ -d "/Applications/Antigravity.app/Contents/Resources" ]; then
  echo "[提示] 未检测到 Node.js，正在使用内置免环境汉化包 (app.asar.ready) 直接部署..."
  pkill -xi antigravity 2>/dev/null || true
  pkill -xi language_server 2>/dev/null || true
  if [ ! -f "/Applications/Antigravity.app/Contents/Resources/app.asar.bak" ]; then
    cp "/Applications/Antigravity.app/Contents/Resources/app.asar" "/Applications/Antigravity.app/Contents/Resources/app.asar.bak"
    echo "[安全备份] 已备份原版文件至 app.asar.bak"
  fi
  cp "app.asar.ready" "/Applications/Antigravity.app/Contents/Resources/app.asar"
  EXIT_CODE=$?
else
  echo "[错误] 未检测到 Node.js 且未找到免环境汉化包。"
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
  echo "🎉 汉化已完成！"
else
  echo ""
  echo "[错误] 汉化执行失败，请查看上方日志信息。"
  read -p "按回车键关闭窗口..."
fi
