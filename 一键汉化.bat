@echo off
chcp 65001 >nul
cd /d "%~dp0"
title Antigravity-ZH-CN 一键极速汉化 (Windows)

set "CORE_DIR=."
if exist "core\localize.js" set "CORE_DIR=core"

echo =======================================================
echo   Antigravity-ZH-CN 一键极速汉化 (Windows)
echo =======================================================
echo.

if "%AGY_FORCE_NO_NODE%"=="1" goto :no_node_mode
where node >nul 2>nul
if errorlevel 1 goto :no_node_mode

node "%CORE_DIR%\localize.js" --now
if errorlevel 1 goto :node_failed

echo.
echo 🎉 汉化已完成！正在启动 Antigravity...
if "%AGY_BATCH_NOPAUSE%"=="1" exit /b 0
if exist "%LOCALAPPDATA%\Programs\antigravity\Antigravity.exe" start "" "%LOCALAPPDATA%\Programs\antigravity\Antigravity.exe"
echo.
pause
exit /b 0

:node_failed
echo.
echo [错误] 汉化执行失败，请检查上方错误提示。
if "%AGY_BATCH_NOPAUSE%"=="1" exit /b 1
echo.
pause
exit /b 1

:no_node_mode
echo [提示] 未检测到 Node.js，正在使用内置免环境汉化包直接部署...
set "TARGET_DIR=%LOCALAPPDATA%\Programs\antigravity\resources"
if defined AGY_WIN_RESOURCES_DIR set "TARGET_DIR=%AGY_WIN_RESOURCES_DIR%"
set "APP_EXE=%LOCALAPPDATA%\Programs\antigravity\Antigravity.exe"

if not exist "%TARGET_DIR%\app.asar" goto :missing_target
if not exist "%CORE_DIR%\app.asar.ready" goto :missing_ready

set "READY_VER="
if exist "%CORE_DIR%\READY_VERSION" set /p READY_VER=<"%CORE_DIR%\READY_VERSION"
if defined READY_VER set "READY_VER=%READY_VER: =%"
if not defined READY_VER goto :after_ver_check

powershell -NoProfile -Command "$raw = [IO.File]::ReadAllText($env:TARGET_DIR + '\app.asar'); if ($raw -match ('\x22version\x22\s*:\s*\x22' + [regex]::Escape($env:READY_VER.Trim()) + '\x22')) { exit 0 } else { exit 1 }" >nul 2>nul
if errorlevel 1 goto :version_mismatch

:after_ver_check
taskkill /F /IM Antigravity.exe >nul 2>nul
taskkill /F /IM language_server.exe >nul 2>nul
if not "%AGY_BATCH_NOPAUSE%"=="1" timeout /t 2 /nobreak >nul

if exist "%TARGET_DIR%\app.asar.bak" goto :do_deploy
powershell -NoProfile -Command "$raw = [IO.File]::ReadAllText($env:TARGET_DIR + '\app.asar'); if ($raw.Contains('Antigravity 2.0 Chinese Localization Engine')) { exit 0 } else { exit 1 }" >nul 2>nul
if not errorlevel 1 goto :skip_polluted_backup

copy /Y "%TARGET_DIR%\app.asar" "%TARGET_DIR%\app.asar.bak" >nul
echo [安全备份] 已备份原版文件至 %TARGET_DIR%\app.asar.bak
goto :do_deploy

:skip_polluted_backup
echo [提示] 当前 app.asar 已包含汉化代码，跳过备份以避免污染官方原版备份。

:do_deploy
copy /Y "%CORE_DIR%\app.asar.ready" "%TARGET_DIR%\app.asar.stage" >nul
if errorlevel 1 goto :deploy_failed
move /Y "%TARGET_DIR%\app.asar.stage" "%TARGET_DIR%\app.asar" >nul
if errorlevel 1 goto :deploy_failed

echo.
echo 🎉 免环境一键汉化成功！正在启动 Antigravity...
if "%AGY_BATCH_NOPAUSE%"=="1" exit /b 0
if exist "%APP_EXE%" start "" "%APP_EXE%"
echo.
pause
exit /b 0

:missing_target
echo [错误] 未在目标路径找到 Antigravity: %TARGET_DIR%
if "%AGY_BATCH_NOPAUSE%"=="1" exit /b 1
echo.
pause
exit /b 1

:missing_ready
echo [错误] 未找到内置免环境汉化包 app.asar.ready。
if "%AGY_BATCH_NOPAUSE%"=="1" exit /b 1
echo.
pause
exit /b 1

:version_mismatch
echo [安全拦截] 当前客户端版本与内置汉化包适配版本 (v%READY_VER%) 不一致。
echo 为防止界面异常，已取消覆盖。请安装 Node.js 后重新运行本脚本，或下载对应的新版汉化包。
if "%AGY_BATCH_NOPAUSE%"=="1" exit /b 2
echo.
pause
exit /b 2

:deploy_failed
if exist "%TARGET_DIR%\app.asar.stage" del /F /Q "%TARGET_DIR%\app.asar.stage" >nul 2>nul
echo [错误] 覆盖 app.asar 失败，请确认客户端已退出，或右键以管理员身份运行此脚本。
if "%AGY_BATCH_NOPAUSE%"=="1" exit /b 1
echo.
pause
exit /b 1
