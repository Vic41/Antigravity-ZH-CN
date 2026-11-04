#!/bin/bash
# macOS Finder 双击一键汉化 Antigravity 并自动重启
cd "$(dirname "$0")"

CORE_DIR="."
if [ -f "core/localize.js" ]; then
  CORE_DIR="core"
fi

echo "======================================================="
echo "  Antigravity-ZH-CN 一键极速汉化 (macOS)"
echo "======================================================="
echo ""

if command -v node >/dev/null 2>&1; then
  node "$CORE_DIR/localize.js" --now
  EXIT_CODE=$?
elif [ -f "$CORE_DIR/app.asar.ready" ] && [ -d "/Applications/Antigravity.app/Contents/Resources" ]; then
  echo "[提示] 未检测到 Node.js，正在使用内置免环境汉化包直接部署..."
  RES_DIR="/Applications/Antigravity.app/Contents/Resources"
  APP_VER=$(/usr/libexec/PlistBuddy -c "Print :CFBundleShortVersionString" "/Applications/Antigravity.app/Contents/Info.plist" 2>/dev/null | tr -d '[:space:]')
  READY_VER=""
  if [ -f "$CORE_DIR/READY_VERSION" ]; then
    READY_VER=$(tr -d '[:space:]' < "$CORE_DIR/READY_VERSION")
  fi
  if [ -n "$APP_VER" ] && [ -n "$READY_VER" ] && [ "$APP_VER" != "$READY_VER" ]; then
    echo "[安全拦截] 当前客户端版本为 v$APP_VER，但内置汉化包适配的是 v$READY_VER。"
    echo "为防止界面异常，已取消覆盖。请安装 Node.js 后重新运行本脚本（将自动对当前版本重新汉化），或下载适配 v$APP_VER 的新版汉化包。"
    EXIT_CODE=1
  else
    if [ -z "$APP_VER" ] || [ -z "$READY_VER" ]; then
      echo "[提示] 无法确认客户端与汉化包的版本是否一致，将继续部署。"
    fi
    pkill -xi antigravity 2>/dev/null || true
    pkill -xi language_server 2>/dev/null || true
    sleep 2
    if [ ! -f "$RES_DIR/app.asar.bak" ]; then
      if grep -q -a -F "Antigravity 2.0 Chinese Localization Engine" "$RES_DIR/app.asar" 2>/dev/null; then
        echo "[提示] 当前 app.asar 已包含汉化代码，跳过备份以避免污染官方原版备份。"
      else
        cp "$RES_DIR/app.asar" "$RES_DIR/app.asar.bak"
        echo "[安全备份] 已备份原版文件至 app.asar.bak"
      fi
    fi
    cp "$CORE_DIR/app.asar.ready" "$RES_DIR/.app.asar.stage" && mv -f "$RES_DIR/.app.asar.stage" "$RES_DIR/app.asar"
    EXIT_CODE=$?
    rm -f "$RES_DIR/.app.asar.stage" 2>/dev/null
  fi
else
  echo "[错误] 未找到汉化核心组件或 Antigravity 未安装在 /Applications/Antigravity.app。"
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
