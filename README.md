# Antigravity-ZH-CN

**Google Antigravity 2.0 桌面客户端一键深度汉化与可视化控制中心**

[![GitHub Repo](https://img.shields.io/badge/GitHub-Vic41%2FAntigravity--ZH--CN-blue?logo=github)](https://github.com/Vic41/Antigravity-ZH-CN)
[![Platform](https://img.shields.io/badge/适用平台-macOS%20%7C%20Windows%20%7C%20Linux-informational)](#)
[![Version](https://img.shields.io/badge/支持版本-Antigravity%20v2.28.2%2B-success)](#)
[![Zero Dependency](https://img.shields.io/badge/外部依赖-0%20(纯原生%20Node.js)-brightgreen)](#)
[![License](https://img.shields.io/badge/开源协议-MIT-gold)](LICENSE)

专为 **Google Antigravity 2.0** 打造的零外部依赖、非破坏性深度简体中文汉化工具。
- **全界面深度覆盖**：完整汉化顶部菜单栏、系统托盘、左侧会话与项目栏、对话与规划模式（Planning Mode）、斜杠命令（`/`）、上下文提及（`@`）、系统设置（150+ 项）、权限沙盒、插件市场（Skills / Rules / Plugins / MCP / Hooks）以及右侧辅助面板（Diff 对比、Git 提交、终端与浏览器）。
- **代码与输入绝对安全**：物理隔离代码编辑器（Monaco）、代码块、终端与用户输入框，绝不误翻或篡改您的代码与提问内容。
- **无损备份与一键还原**：首次汉化自动备份官方原版 `app.asar.bak`，随时可一键无损恢复为纯英文原版。

---

## 🚀 小白快速上手指南（4 种方式任选其一）

### 方式一：AI 一句话全自动安装（最推荐，零动手）

如果您已经打开了英文版 Antigravity，直接复制下面这段话，粘贴到 Antigravity 的聊天输入框发送给 AI 即可：

```text
帮我安装 https://github.com/Vic41/Antigravity-ZH-CN 的汉化补丁：请将该仓库克隆到本地，执行 node localize.js --now --no-kill 完成一键汉化，完成后提醒我重启客户端即可。
```

> 发送后，Antigravity 内部的 AI 智能体会自动帮您下载本仓库并注入中文补丁，您只需按 `Cmd + Q`（Mac）或关闭重开软件即可变成全中文！

---

### 方式二：下载压缩包 -> 双击图标一键汉化（适合普通用户）

#### 第一步：下载并解压本项目
1. 点击本页面右上角绿色的 **`<> Code`** 按钮，再点击 **`Download ZIP`** 下载压缩包。
2. 将下载好的 `.zip` 压缩包解压到任意文件夹（如桌面或下载目录）。

#### 第二步：根据您的电脑系统双击对应文件

##### 🍎 macOS 苹果电脑用户
打开解压后的文件夹，里面有两个可直接双击的 `.command` 图标：
- **想直接一键完成汉化**：双击 **`一键汉化.command`**
  - 脚本会自动关闭正在运行的 Antigravity、备份英文原版、打入中文补丁、自动修复 macOS 签名拦截，并**自动为您重新打开汉化后的 Antigravity**。
- **想打开可视化网页控制台**：双击 **`双击运行汉化.command`**
  - 浏览器会自动弹出可视化控制面板（`http://localhost:3388`），点击页面上的 **「一键汉化」** 按钮即可。

> **💡 Mac 首次双击提示“无法打开”怎么办？**
> 如果 macOS 弹窗提示“无法验证开发者”，只需**按住键盘 `Control` 键（或右键）点击该文件 -> 选择「打开」**，在弹出的窗口中再点一次「打开」即可；或者打开「终端」输入 `chmod +x *.command *.sh` 回车。

##### 🪟 Windows 电脑用户
打开解压后的文件夹：
- **首次汉化或打开可视化控制台**：双击 **`双击运行汉化.bat`**
  - 浏览器会自动打开可视化控制面板（`http://localhost:3388`），点击 **「一键汉化」** 即可完成部署。
- **软件官方升级后恢复中文**：双击 **`一键更新汉化.bat`**
  - 无需打开网页，自动校验版本并秒级恢复中文界面。

---

### 方式三：免环境直接替换文件（适合未安装 Node.js 的电脑）

如果您电脑上没有安装 Node.js，且不想运行任何脚本，可以直接使用预制好的 `app.asar.ready`（或从 Releases 下载 `app.asar`）进行手动覆盖：

1. **完全退出**正在运行的 Antigravity 软件。
2. 打开 Antigravity 的安装目录中的 `Resources` 文件夹：
   - **macOS 路径**：打开访达（Finder）-> 应用程序 -> 右键点击 `Antigravity.app` -> 选择 **「显示包内容」** -> 依次进入 `Contents/Resources/`
   - **Windows 路径**：按 `Win + R` 输入 `%LOCALAPPDATA%\Programs\antigravity\resources\` 回车
3. 先将原本的 `app.asar` 复制一份改名为 `app.asar.bak`（作为英文版备份）。
4. 将本项目的 `app.asar.ready` 复制进去，并改名为 **`app.asar`** 覆盖原文件。
5. 重新启动 Antigravity 即可看到全中文界面！

---

### 方式四：终端命令行一键极速模式（适合开发者）

在终端（Terminal / PowerShell）中复制粘贴以下命令即可：

```bash
# 1. 克隆仓库并进入目录
git clone --depth=1 https://github.com/Vic41/Antigravity-ZH-CN.git
cd Antigravity-ZH-CN

# 2. 立即执行一键汉化（纯 Node.js 原生解包封包，耗时 < 1 秒）
node localize.js --now
```

#### 全部命令行参数说明

| 命令 | 功能说明 |
| :--- | :--- |
| `node localize.js` | 启动本地可视化 Web 控制面板（`http://localhost:3388`） |
| `node localize.js --now` | 立即全自动备份、解包、注入中文补丁并重打包部署 |
| `node localize.js --restore` | 从安全备份 `app.asar.bak` 一键还原为官方纯英文原版 |
| `node localize.js --auto-restore` | 官方更新后自动检查版本兼容性并安全恢复汉化 |
| `node localize.js --check-status` | 查看当前客户端路径、版本号、备份状态与汉化状态 |

---

## 🖥️ 可视化 Web 控制中心功能一览

启动 `双击运行汉化.command`（Mac）、`双击运行汉化.bat`（Windows）或 `运行汉化.sh` 后，浏览器会打开 `http://localhost:3388` 控制中心，提供以下一键操作：

- **一键汉化**：自动关闭占用进程、创建原版备份并注入最新全量中文词库。
- **还原英文原版**：毫秒级将软件恢复为官方纯英文状态。
- **一键恢复（更新被覆盖后）**：当 Antigravity 自动更新导致界面变回英文时，顶部会亮起提醒横幅，点击即可恢复。
- **启动应用 / 强制释放占用**：一键启动客户端，或强制清理后台残留的 `language_server` 锁文件进程。
- **安全清理缓存**：清理临时渲染与 GPU 缓存（保留您的账号登录状态、历史对话与项目设置）。
- **深色 / 浅色主题切换**：右上角随时切换控制面板外观。

---

## ❓ 常见问题解答（FAQ）

### Q1：Antigravity 官方自动更新后，界面又变回英文了怎么办？
官方升级时会用新版的英文 `app.asar` 覆盖本地文件。您只需要：
- **Mac 用户**：再次双击一下 **`一键汉化.command`**；
- **Windows 用户**：再次双击一下 **`一键更新汉化.bat`**（或打开控制面板点击「一键汉化」）；
- **命令行用户**：运行一次 `node localize.js --now`。
工具会自动用新版官方文件更新备份，并重新注入汉化补丁。

### Q2：macOS 汉化后打开软件提示“Antigravity 已损坏，无法打开”怎么办？
这是因为 macOS 的 Gatekeeper 检测到应用包内文件被修改。本项目的 `一键汉化.command` 和 `localize.js` 已内置自动修复逻辑；如果您是手动替换的文件，只需打开「终端」运行下面这一行命令即可解除拦截：
```bash
xattr -cr /Applications/Antigravity.app
```

### Q3：如何彻底卸载汉化、恢复官方原版？
有三种方法任选其一：
1. 在可视化控制中心（`http://localhost:3388`）点击 **「还原英文原版」**；
2. 在终端运行 `node localize.js --restore`；
3. 手动打开 `Resources` 目录，删除当前的 `app.asar`，把同目录下的备份文件 `app.asar.bak` 改名为 `app.asar` 即可。

---

## 📂 项目目录结构

```text
Antigravity-ZH-CN/
├── 一键汉化.command         # [macOS] Finder 双击一键静默汉化 + 签名修复 + 自动重启
├── 双击运行汉化.command     # [macOS] Finder 双击启动可视化网页控制中心
├── 运行汉化.sh              # [macOS/Linux] 终端启动可视化网页控制中心脚本
├── 双击运行汉化.bat         # [Windows] 双击启动可视化网页控制中心脚本
├── 一键更新汉化.bat         # [Windows] 官方更新后双击极速恢复汉化脚本
├── localize.js             # 核心汉化引擎、5300+ 行词库、CLI 与本地控制中心服务
├── asar-tool.js            # 纯 Node.js 零依赖 ASAR 解包/封包引擎 (保留 unpacked 索引)
├── index.html              # 可视化 Web 控制中心前端界面 (支持深浅色主题)
├── auto-restore.js         # 版本兼容性校验与官方更新后自动恢复模块
├── package-installer.js    # SHA-256 原子化安装与失败自动回滚模块
├── asar-version.js         # ASAR 包版本元数据安全读取器
├── process-check.js        # 跨平台进程状态严格检测模块
├── release-manager.js      # Release 版本检查与缓存管理模块
└── package.json            # 项目配置与 npm scripts
```

---

## 📄 开源协议

本项目基于 [MIT License](LICENSE) 开源。
