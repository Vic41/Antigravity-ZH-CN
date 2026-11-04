@echo off
chcp 65001 >nul
cd /d "%~dp0"
title Antigravity-ZH-CN 一键极速汉化 (Windows)

echo =======================================================
echo   Antigravity-ZH-CN 一键极速汉化 (Windows)
echo =======================================================
echo.

where node >nul 2>nul
if %ERRORLEVEL% equ 0 (
    node localize.js --now
    if %ERRORLEVEL% equ 0 (
        echo.
        echo 🎉 汉化已完成！正在启动 Antigravity...
        if exist "%LOCALAPPDATA%\Programs\antigravity\Antigravity.exe" (
            start "" "%LOCALAPPDATA%\Programs\antigravity\Antigravity.exe"
        )
    ) else (
        echo.
        echo [错误] 汉化执行失败，请检查上方错误提示。
    )
    echo.
    pause
    exit /b
)

echo [提示] 未检测到 Node.js，正在尝试使用内置免环境汉化包 (app.asar.ready)...
set "TARGET_DIR=%LOCALAPPDATA%\Programs\antigravity\resources"
if not exist "%TARGET_DIR%\app.asar" (
    echo [错误] 未在默认路径找到 Antigravity: %TARGET_DIR%
    echo 请安装 Node.js ^(https://nodejs.org^) 后重试，或手动将 app.asar.ready 复制为 resources\app.asar。
    echo.
    pause
    exit /b 1
)

if not exist "app.asar.ready" (
    echo [错误] 未找到内置免环境汉化包 app.asar.ready。
    echo.
    pause
    exit /b 1
)

taskkill /F /IM Antigravity.exe >nul 2>nul
taskkill /F /IM language_server.exe >nul 2>nul

if not exist "%TARGET_DIR%\app.asar.bak" (
    copy /Y "%TARGET_DIR%\app.asar" "%TARGET_DIR%\app.asar.bak" >nul
    echo [安全备份] 已备份原版文件至 %TARGET_DIR%\app.asar.bak
)

copy /Y "app.asar.ready" "%TARGET_DIR%\app.asar" >nul
if %ERRORLEVEL% equ 0 (
    echo.
    echo 🎉 免环境一键汉化成功！正在启动 Antigravity...
    if exist "%LOCALAPPDATA%\Programs\antigravity\Antigravity.exe" (
        start "" "%LOCALAPPDATA%\Programs\antigravity\Antigravity.exe"
    )
) else (
    echo [错误] 覆盖 app.asar 失败，请右键以管理员身份运行此脚本。
)

echo.
pause
