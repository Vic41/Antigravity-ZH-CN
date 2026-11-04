<div align="center">

# 🌌 Antigravity-ZH-CN

### Google Antigravity 2.0 桌面端 · 零依赖一键深度汉化工具

[![Release](https://img.shields.io/badge/汉化包版本-v0.0.2-8b5cf6?style=for-the-badge)](https://github.com/Vic41/Antigravity-ZH-CN/releases)
[![Version](https://img.shields.io/badge/适配客户端-v2.28.2-6366f1?style=for-the-badge)](https://github.com/Vic41/Antigravity-ZH-CN)
[![Platform](https://img.shields.io/badge/平台支持-macOS%20%7C%20Windows%20%7C%20Linux-10b981?style=for-the-badge)](#)
[![Dependencies](https://img.shields.io/badge/外部依赖-0%20(纯%20Node.js%20原生)-f59e0b?style=for-the-badge)](#)

**原生菜单栏 · 设置面板 · 欢迎页 · 对话与智能体全界面 · React 碎片拼接 · 零依赖双引擎直装**

</div>

---

## ✨ 核心特性

1. **全栈三层深度汉化（非仅菜单栏）**
   - **主进程原生层 (`dist/menu.js` / `ipcHandlers.js` / `main.js` / `updater.js`)**：完整汉化 macOS / Windows 顶部应用菜单、Dock 菜单、右键上下文菜单、系统弹窗、WebAuthn 通行密钥窗口与 WSL 状态提示。
   - **沙盒预加载层 (`dist/preload.js` / `wizardPreload.js`) + 主世界注入 (`dist/utils.js`)**：突破 Electron `sandbox: true` 预加载沙盒限制，将自包含的 `MutationObserver` 动态 DOM 翻译引擎与 **React 碎片节点智能拼接器**直接注入渲染器。
   - **静态模板层 (`wizardHtml.js` / `cablev2.js`)**：安装向导与通行密钥扫码页静态 HTML 直译。
2. **极简轻量 · 零第三方依赖**
   - 移除冗余的 Web 服务面板与网络模块，专注纯粹的**一键汉化与一键还原**。
   - 内置纯 Node.js 原生二进制流 ASAR 解包/打包器（[`asar-tool.js`](./asar-tool.js)），无需 `npm install` 或下载 `@electron/asar`，完整保留 `app.asar.unpacked` 标记。
   - 随仓附带预打包 [`app.asar.ready`](./app.asar.ready)，即使电脑**未安装 Node.js**，双击脚本也能自动回退至免环境直装模式。
3. **非破坏性安全备份与防污染校验**
   - 首次汉化前自动备份官方原版至 `app.asar.bak`，并通过二进制特征指纹检测确保原版备份永不被汉化包覆盖污染。

---

## 🚀 外部用户使用指南（3 步极简上手）

### 第一步：前往 Releases 下载对应系统的压缩包

点击本仓库右侧的 **[Releases（发布页）](https://github.com/Vic41/Antigravity-ZH-CN/releases)**，在最新版本下方的 **Assets** 中根据您的系统下载：

- 🍎 **苹果电脑 (macOS)**：点击下载 **`Antigravity-ZH-CN-v0.0.2-macOS.zip`** 并解压
- 🪟 **Windows 电脑**：点击下载 **`Antigravity-ZH-CN-v0.0.2-Windows.zip`** 并解压

> *(注：请直接下载带 `-macOS.zip` 或 `-Windows.zip` 后缀的专用包，里面只包含您当前系统需要的双击脚本，无需下载 `Source code`。)*

---

### 第二步：一键执行汉化

#### 🍎 macOS 用户

1. 打开解压后的文件夹，直接双击 **`一键汉化.command`**。
   - 脚本会自动完成：**安全备份原版 ➔ 注入中文语言包 ➔ 清除签名缓存 ➔ 自动重启 Antigravity**。
   - 若电脑已安装 Node.js，将实时解包当前客户端并注入汉化；若未安装 Node.js，将自动使用内置的 `app.asar.ready` 免环境直装。
2. 如需恢复默认英文原版，直接双击 **`一键还原.command`** 即可。

> **💡 macOS 首次双击提示“无法打开 / 未受信任的开发者”怎么办？**
> 在访达（Finder）中对该 `.command` 文件 **按住 `Control` 键并点击右键 ➔ 选择“打开”**，在弹出框中再次点击“打开”即可。或者在终端运行：
> ```bash
> chmod +x *.command *.sh && xattr -cr . && ./一键汉化.command
> ```

---

#### 🪟 Windows 用户

1. 打开解压后的文件夹，直接双击 **`一键汉化.bat`**。
   - 若电脑已安装 Node.js，将自动解包并注入汉化；若未安装 Node.js，将自动把内置的 `app.asar.ready` 覆盖到 `%LOCALAPPDATA%\Programs\antigravity\resources\app.asar`（并自动创建 `app.asar.bak` 备份）。
2. 如需恢复默认英文原版，直接双击 **`一键还原.bat`** 即可。

---

#### 💻 命令行 / 开发者模式（macOS / Windows / Linux 通用）

如果您的电脑已安装 [Node.js](https://nodejs.org/)（v14.14 及以上），可在项目目录下直接通过终端执行：

```bash
# 一键解包、注入汉化并重新打包部署（默认动作）
node localize.js

# 一键还原为官方英文原版（从 app.asar.bak 恢复）
node localize.js --restore

# 官方客户端自动更新后，快速检测并恢复汉化
node localize.js --auto-restore

# 安全清理客户端渲染缓存（解决个别界面文字未刷新，不伤账号与配置）
node localize.js --clean-cache

# 诊断当前客户端安装状态与版本信息（输出 JSON）
node localize.js --check-status
```

> **自定义客户端安装路径**：如果您的 Antigravity 安装在非默认位置，可通过环境变量 `AGY_APP_DIR` 指定路径：
> ```bash
> AGY_APP_DIR="/your/custom/path" node localize.js
> ```

---

## 📁 项目结构说明

| 文件名 | 作用说明 |
| :--- | :--- |
| [`localize.js`](./localize.js) | 核心汉化引擎（内置 5,300+ 行中英词典、React 碎片拼接器、沙盒注入器与 CLI 入口） |
| [`asar-tool.js`](./asar-tool.js) | 零依赖纯 Node.js 原生 `app.asar` 解包与重打包引擎（保留 `unpacked` 元数据） |
| [`auto-restore.js`](./auto-restore.js) | 客户端版本匹配检测、原版备份防污染校验与原子级恢复模块 |
| [`asar-version.js`](./asar-version.js) | 从 `app.asar` 头部安全读取客户端 `package.json` 版本号 |
| [`process-check.js`](./process-check.js) | 跨平台（macOS / Windows / Linux）进程占用检测工具 |
| [`app.asar.ready`](./app.asar.ready) | 预构建就绪的完整汉化包（供无 Node.js 环境用户直接覆盖安装） |
| [`一键汉化.command`](./一键汉化.command) / [`一键还原.command`](./一键还原.command) | macOS 双击一键汉化 / 一键还原脚本 |
| [`一键汉化.bat`](./一键汉化.bat) / [`一键还原.bat`](./一键还原.bat) | Windows 双击一键汉化 / 一键还原脚本 |

---

## ❓ 常见问题 (FAQ)

1. **为什么之前有些汉化工具只能汉化顶部菜单栏，主界面还是英文？**
   - Antigravity 2.0 的 `BrowserWindow` 默认开启了 Electron 的 `sandbox: true` 沙盒模式，导致 `preload.js` 无法通过 `require('./i18n')` 加载外部脚本。本项目将自包含的 `DOM_TRANSLATOR_INJECTION` 引擎直接内联进 `preload.js` 并配合主世界 `executeJavaScript` 双重保障，彻底解决主界面不汉化的问题。
2. **Antigravity 官方升级新版本后汉化失效了怎么办？**
   - 官方升级会覆盖 `app.asar`。只需再次双击 **`一键汉化.command`**（macOS）或 **`一键汉化.bat`**（Windows），或运行 `node localize.js`，即可对新版本重新完成汉化。
3. **汉化后会影响我的 Google 账号登录、对话记录或插件吗？**
   - **完全不会**。本工具仅对界面展示文本与 DOM 渲染层进行本地化翻译，不触碰任何用户配置、凭证或网络通信。

---

## 📄 开源协议与致谢

- 本项目基于 [MIT License](./LICENSE) 许可。
- 灵感与部分词库架构致敬 [liominsb/Antigravity-Chinese-Localization](https://github.com/liominsb/Antigravity-Chinese-Localization)。
