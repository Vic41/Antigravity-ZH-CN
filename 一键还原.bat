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
if %ERRORLEVEL% equ 0 (
    node "%CORE_DIR%\localize.js" --restore
    echo.
    pause
    exit /b
)

set "TARGET_DIR=%LOCALAPPDATA%\Programs\antigravity\resources"
if not exist "%TARGET_DIR%\app.asar.bak" (
    echo [错误] 未找到安全备份文件: %TARGET_DIR%\app.asar.bak
    echo.
    pause
    exit /b 1
)

taskkill /F /IM Antigravity.exe >nul 2>nul
taskkill /F /IM language_server.exe >nul 2>nul

copy /Y "%TARGET_DIR%\app.asar.bak" "%TARGET_DIR%\app.asar" >nul
if %ERRORLEVEL% equ 0 (
    echo ✅ 已成功恢复为官方英文原版！
) else (
    echo [错误] 恢复文件失败，请右键以管理员身份运行此脚本。
)

echo.
pause
