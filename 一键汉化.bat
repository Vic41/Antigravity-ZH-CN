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

where node >nul 2>nul
if not errorlevel 1 (
    node "%CORE_DIR%\localize.js" --now
    if not errorlevel 1 (
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

echo [提示] 未检测到 Node.js，正在使用内置免环境汉化包直接部署...
set "TARGET_DIR=%LOCALAPPDATA%\Programs\antigravity\resources"
set "APP_EXE=%LOCALAPPDATA%\Programs\antigravity\Antigravity.exe"
if not exist "%TARGET_DIR%\app.asar" (
    echo [错误] 未在默认路径找到 Antigravity: %TARGET_DIR%
    echo.
    pause
    exit /b 1
)

if not exist "%CORE_DIR%\app.asar.ready" (
    echo [错误] 未找到内置免环境汉化包 app.asar.ready。
    echo.
    pause
    exit /b 1
)

rem 版本校验：客户端版本与内置汉化包适配版本不一致时拒绝覆盖
set "APP_VER="
set "READY_VER="
set "CUR_LOCALIZED=no"
if exist "%APP_EXE%" (
    for /f "usebackq delims=" %%v in (`powershell -NoProfile -ExecutionPolicy Bypass -Command "try { $v=[version](Get-Item -LiteralPath '%APP_EXE%').VersionInfo.ProductVersion; '{0}.{1}.{2}' -f $v.Major,$v.Minor,$v.Build } catch { '' }"`) do set "APP_VER=%%v"
)
if exist "%CORE_DIR%\READY_VERSION" set /p READY_VER=<"%CORE_DIR%\READY_VERSION"
if defined READY_VER set "READY_VER=%READY_VER: =%"

if defined APP_VER if defined READY_VER if /i not "%APP_VER%"=="%READY_VER%" (
    echo [安全拦截] 当前客户端版本为 v%APP_VER%，但内置汉化包适配的是 v%READY_VER%。
    echo 为防止界面异常，已取消覆盖。请安装 Node.js 后重新运行本脚本（将自动对当前版本重新汉化），或下载适配 v%APP_VER% 的新版汉化包。
    echo.
    pause
    exit /b 1
)
if not defined APP_VER echo [提示] 无法读取客户端版本，无法确认与汉化包是否一致，将继续部署。
if not defined READY_VER echo [提示] 未找到汉化包版本信息，无法确认与客户端是否一致，将继续部署。

taskkill /F /IM Antigravity.exe >nul 2>nul
taskkill /F /IM language_server.exe >nul 2>nul
timeout /t 2 /nobreak >nul

rem 防污染：当前 app.asar 已是汉化版时，不把它当作原版备份
if not exist "%TARGET_DIR%\app.asar.bak" (
    for /f "usebackq delims=" %%r in (`powershell -NoProfile -ExecutionPolicy Bypass -Command "if (Select-String -LiteralPath '%TARGET_DIR%\app.asar' -SimpleMatch -Pattern 'Antigravity 2.0 Chinese Localization Engine' -Quiet) { 'yes' } else { 'no' }"`) do set "CUR_LOCALIZED=%%r"
)
if not exist "%TARGET_DIR%\app.asar.bak" (
    if /i "%CUR_LOCALIZED%"=="yes" (
        echo [提示] 当前 app.asar 已包含汉化代码，跳过备份以避免污染官方原版备份。
    ) else (
        copy /Y "%TARGET_DIR%\app.asar" "%TARGET_DIR%\app.asar.bak" >nul
        echo [安全备份] 已备份原版文件至 %TARGET_DIR%\app.asar.bak
    )
)

rem 先写入同目录暂存文件再替换，避免复制中途失败导致 app.asar 损坏
copy /Y "%CORE_DIR%\app.asar.ready" "%TARGET_DIR%\app.asar.stage" >nul
if errorlevel 1 goto deploy_failed
move /Y "%TARGET_DIR%\app.asar.stage" "%TARGET_DIR%\app.asar" >nul
if errorlevel 1 goto deploy_failed

echo.
echo 🎉 免环境一键汉化成功！正在启动 Antigravity...
if exist "%APP_EXE%" (
    start "" "%APP_EXE%"
)
echo.
pause
exit /b 0

:deploy_failed
if exist "%TARGET_DIR%\app.asar.stage" del /F /Q "%TARGET_DIR%\app.asar.stage" >nul 2>nul
echo [错误] 覆盖 app.asar 失败，请确认客户端已退出，或右键以管理员身份运行此脚本。
echo.
pause
exit /b 1
