# Antigravity-ZH-CN

**Google Antigravity 2.0 桌面客户端一键深度汉化与高性能本地化控制中心**

[![Platform](https://img.shields.io/badge/Platform-macOS%20%7C%20Windows%20%7C%20Linux-blue)](#)
[![Version](https://img.shields.io/badge/Antigravity-v2.28.2%2B-success)](#)
[![Zero Dependency](https://img.shields.io/badge/Dependencies-Zero%20(Pure%20Node.js)-brightgreen)](#)
[![License](https://img.shields.io/badge/License-MIT-gold)](LICENSE)

`Antigravity-ZH-CN` 是专为 **Google Antigravity 2.0** 打造的零外部依赖、非破坏性深度简体中文汉化项目。内置纯 Node.js 原生 `ASAR` 解包/封包引擎（无需联网下载 `npx @electron/asar`），毫秒级完成备份、注入与重打包，并提供可视化 Web 控制中心（`http://localhost:3388`）与命令行一键极速部署。

---

## 核心特性

1. **全景界面与工作流深度汉化**
   - **原生系统层**：macOS 顶部菜单栏、Dock 右键菜单、系统托盘（Tray）、退出确认框、更新提示框、Passkey 通行密钥弹窗、IDE 安装向导、原生右键菜单。
   - **主界面与导航**：侧边栏、工作区（Workspaces）、项目（Projects）、置顶与归档对话、搜索框与排序筛选。
   - **对话与规划模式（Planning Mode）**：斜杠命令（`/`）、上下文提及（`@`）、实施方案（Implementation Plan）、成果演练（Walkthrough）、旁路提问（Side Question / Questionnaire）、会话分屏（Split）与分支派生（Fork）。
   - **系统设置与权限沙盒（Settings & Permissions）**：通用、外观主题、智能体行为、终端沙盒、文件/网络访问策略、黑白名单、模型配额（Models & Quota）、通知与快捷键。
   - **自定义与插件生态（Customizations）**：技能（Skills）、规则（Rules）、插件市场（Plugins & Marketplace）、MCP 服务器、生命周期钩子（Hooks）与子智能体（Subagents）。
   - **辅助面板（Auxiliary Pane）**：概览、后台任务、代码差异对比（Diff / Git Commit / Amend / Push）、产物查看器、终端与内置浏览器。

2. **安全隔离与原版无损自愈**
   - **代码与输入区物理免疫**：自动跳过 `Monaco Editor`、代码块（`PRE` / `CODE`）、终端（`xterm`）、用户输入气泡与模型思考链正文（Thinking Content），绝不污染代码或 Prompt。
   - **双层注入保障**：同时支持 Electron 沙盒 `preload.js` 无依赖注入与 `utils.js` 主世界生命周期兜底注入。
   - **自动备份与一键还原**：首次汉化自动生成纯净官方备份 `app.asar.bak`，随时支持通过控制中心或命令行一键无损还原英文原版。

---

## 快速使用指南

### 方式一：macOS 用户（双击脚本或终端一键汉化）

#### 1. 双击一键极速汉化（免开网页）
直接在 Finder（访达）中双击运行项目根目录下的：
- **`一键汉化.command`**：自动关闭正在运行的 Antigravity、备份原版 `app.asar.bak`、注入最新中文补丁、清除 macOS Gatekeeper 隔离属性并自动重启 Antigravity。

#### 2. 启动可视化 Web 控制中心
在 Finder 中双击 **`双击运行汉化.command`**，或在终端执行：
```bash
chmod +x *.sh *.command
./运行汉化.sh
```
浏览器将自动打开 `http://localhost:3388` 可视化汉化控制面板。

---

### 方式二：Windows 用户

- **可视化控制面板**：双击运行 **`双击运行汉化.bat`**（自动打开 `http://localhost:3388`）。
- **一键快速更新/恢复汉化**：客户端升级后双击 **`一键更新汉化.bat`** 即可秒级恢复中文。

---

### 方式三：命令行极速操作（macOS / Windows / Linux 通用）

```bash
# 立即执行一键汉化并退出（零外部依赖，耗时 < 1 秒）
node localize.js --now

# 一键还原为官方英文原版
node localize.js --restore

# 查看当前客户端版本、路径与汉化状态
node localize.js --check-status

# 官方更新后自动检查并恢复汉化
node localize.js --auto-restore

# 启动本地 Web 可视化控制中心 (http://localhost:3388)
node localize.js
```

---

## 项目结构

```text
Antigravity-ZH-CN/
├── localize.js             # 核心汉化引擎、词库、CLI 与本地控制中心服务端
├── asar-tool.js            # 纯 Node.js 零依赖 ASAR 解包/封包引擎 (保留 unpacked 索引)
├── asar-version.js         # ASAR 包版本元数据安全读取器
├── auto-restore.js         # 版本兼容性校验与官方更新后自动恢复模块
├── package-installer.js    # SHA-256 原子化安装与失败自动回滚模块
├── process-check.js        # 跨平台进程状态严格检测模块
├── release-manager.js      # Release 版本检查与缓存管理模块
├── index.html              # 可视化 Web 控制中心前端界面 (支持深浅色主题切换)
├── 一键汉化.command         # [macOS] Finder 双击一键静默汉化并自动重启
├── 双击运行汉化.command     # [macOS] Finder 双击启动 Web 控制中心
├── 运行汉化.sh              # [macOS/Linux] 终端启动 Web 控制中心脚本
├── 双击运行汉化.bat         # [Windows] 双击启动 Web 控制中心脚本
├── 一键更新汉化.bat         # [Windows] 官方更新后双击极速恢复汉化脚本
└── package.json            # 项目配置与 npm scripts
```

---

## 许可证

本项目基于 [MIT License](LICENSE) 开源。
