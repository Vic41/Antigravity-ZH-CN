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

where node >nul 2>nul
if not errorlevel 1 (
    node "%CORE_DIR%\localize.js" --restore
    if not errorlevel 1 (
        if exist "%LOCALAPPDATA%\Programs\antigravity\Antigravity.exe" (
            echo.
            echo 正在重新启动 Antigravity...
            start "" "%LOCALAPPDATA%\Programs\antigravity\Antigravity.exe"
        )
    )
    echo.
    pause
    exit /b
)

set "TARGET_DIR=%LOCALAPPDATA%\Programs\antigravity\resources"
set "APP_EXE=%LOCALAPPDATA%\Programs\antigravity\Antigravity.exe"
if not exist "%TARGET_DIR%\app.asar.bak" (
    echo [错误] 未找到安全备份文件: %TARGET_DIR%\app.asar.bak
    echo.
    pause
    exit /b 1
)

rem 当前已是官方原版时无需还原，避免用旧版本备份覆盖已升级的客户端
set "CUR_LOCALIZED=yes"
if exist "%TARGET_DIR%\app.asar" (
    for /f "usebackq delims=" %%r in (`powershell -NoProfile -ExecutionPolicy Bypass -Command "if (Select-String -LiteralPath '%TARGET_DIR%\app.asar' -SimpleMatch -Pattern 'Antigravity 2.0 Chinese Localization Engine' -Quiet) { 'yes' } else { 'no' }"`) do set "CUR_LOCALIZED=%%r"
)
if /i "%CUR_LOCALIZED%"=="no" (
    echo [提示] 当前 app.asar 已是官方原版（未检测到汉化代码），无需还原。
    echo.
    pause
    exit /b 0
)

taskkill /F /IM Antigravity.exe >nul 2>nul
taskkill /F /IM language_server.exe >nul 2>nul
timeout /t 2 /nobreak >nul

copy /Y "%TARGET_DIR%\app.asar.bak" "%TARGET_DIR%\app.asar.stage" >nul
if errorlevel 1 goto restore_failed
move /Y "%TARGET_DIR%\app.asar.stage" "%TARGET_DIR%\app.asar" >nul
if errorlevel 1 goto restore_failed

echo ✅ 已成功恢复为官方英文原版！
if exist "%APP_EXE%" (
    echo.
    echo 正在重新启动 Antigravity...
    start "" "%APP_EXE%"
)
echo.
pause
exit /b 0

:restore_failed
if exist "%TARGET_DIR%\app.asar.stage" del /F /Q "%TARGET_DIR%\app.asar.stage" >nul 2>nul
echo [错误] 恢复文件失败，请确认客户端已退出，或右键以管理员身份运行此脚本。
echo.
pause
exit /b 1
