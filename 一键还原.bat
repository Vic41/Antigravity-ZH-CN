@echo off
chcp 65001 >nul
cd /d "%~dp0"
title Antigravity-ZH-CN 一键还原英文原版 (Windows)

set "CORE_DIR=."
if exist "core\localize.js" set "CORE_DIR=core"

echo =======================================================
echo   Antigravity-ZH-CN 一键还原英文原版 (Windows)
echo =======================================================
echo.

if "%AGY_FORCE_NO_NODE%"=="1" goto :no_node_restore
where node >nul 2>nul
if errorlevel 1 goto :no_node_restore

node "%CORE_DIR%\localize.js" --restore
if errorlevel 1 goto :node_restore_failed

if "%AGY_BATCH_NOPAUSE%"=="1" exit /b 0
if exist "%LOCALAPPDATA%\Programs\antigravity\Antigravity.exe" start "" "%LOCALAPPDATA%\Programs\antigravity\Antigravity.exe"
echo.
pause
exit /b 0

:node_restore_failed
if "%AGY_BATCH_NOPAUSE%"=="1" exit /b 1
echo.
pause
exit /b 1

:no_node_restore
set "TARGET_DIR=%LOCALAPPDATA%\Programs\antigravity\resources"
if defined AGY_WIN_RESOURCES_DIR set "TARGET_DIR=%AGY_WIN_RESOURCES_DIR%"
set "APP_EXE=%LOCALAPPDATA%\Programs\antigravity\Antigravity.exe"

if not exist "%TARGET_DIR%\app.asar.bak" goto :missing_backup
if not exist "%TARGET_DIR%\app.asar" goto :do_restore

powershell -NoProfile -Command "$raw = [IO.File]::ReadAllText($env:TARGET_DIR + '\app.asar'); if ($raw.Contains('Antigravity 2.0 Chinese Localization Engine')) { exit 0 } else { exit 1 }" >nul 2>nul
if errorlevel 1 goto :already_clean

:do_restore
taskkill /F /IM Antigravity.exe >nul 2>nul
taskkill /F /IM language_server.exe >nul 2>nul
if not "%AGY_BATCH_NOPAUSE%"=="1" timeout /t 2 /nobreak >nul

copy /Y "%TARGET_DIR%\app.asar.bak" "%TARGET_DIR%\app.asar.stage" >nul
if errorlevel 1 goto :restore_failed
move /Y "%TARGET_DIR%\app.asar.stage" "%TARGET_DIR%\app.asar" >nul
if errorlevel 1 goto :restore_failed

echo ✅ 已成功恢复为官方英文原版！
if "%AGY_BATCH_NOPAUSE%"=="1" exit /b 0
if exist "%APP_EXE%" start "" "%APP_EXE%"
echo.
pause
exit /b 0

:already_clean
echo [提示] 当前 app.asar 已是官方原版（未检测到汉化代码），无需还原。
if "%AGY_BATCH_NOPAUSE%"=="1" exit /b 0
echo.
pause
exit /b 0

:missing_backup
echo [错误] 未找到安全备份文件: %TARGET_DIR%\app.asar.bak
if "%AGY_BATCH_NOPAUSE%"=="1" exit /b 1
echo.
pause
exit /b 1

:restore_failed
if exist "%TARGET_DIR%\app.asar.stage" del /F /Q "%TARGET_DIR%\app.asar.stage" >nul 2>nul
echo [错误] 恢复文件失败，请确认客户端已退出，或右键以管理员身份运行此脚本。
if "%AGY_BATCH_NOPAUSE%"=="1" exit /b 1
echo.
pause
exit /b 1
