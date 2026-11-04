'use strict';

const fs = require('fs');
const fsp = fs.promises;
const path = require('path');
const crypto = require('crypto');
const { execFileSync } = require('child_process');
const { readAsarPackageVersion } = require('./asar-version');

// 特征指纹检测：判断 asar 文件是否已经注入汉化代码
function isLocalizedAsar(filePath) {
  if (!fs.existsSync(filePath)) return false;
  try {
    const buf = fs.readFileSync(filePath);
    return buf.includes(Buffer.from('// Antigravity 2.0 Chinese Localization Engine')) ||
           buf.includes(Buffer.from('menuTranslationMap')) ||
           buf.includes(Buffer.from('DOM_TRANSLATOR_INJECTION'));
  } catch (_) {
    return false;
  }
}

// 计算文件的 SHA256 哈希
async function hashFile(filePath) {
  const hash = crypto.createHash('sha256');
  for await (const chunk of fs.createReadStream(filePath)) {
    hash.update(chunk);
  }
  return hash.digest('hex');
}

// 标准化版本字符串（移除前缀 v/V 与空白）
function normalizeVersion(ver) {
  if (!ver || typeof ver !== 'string') return '';
  return ver.trim().replace(/^[vV]/, '');
}

/**
 * 寻找本地可用的预打包汉化补丁包 (app.asar.ready)
 */
async function findAvailablePatch({ workspaceDir, targetVersion } = {}) {
  const wsDir = workspaceDir || path.resolve(__dirname);
  const readyPath = path.join(wsDir, 'app.asar.ready');

  if (!fs.existsSync(readyPath)) {
    return null;
  }

  try {
    const stat = await fsp.stat(readyPath);
    if (!stat.isFile() || stat.size === 0) {
      return null;
    }
    const patchVersion = readAsarPackageVersion(readyPath);
    const normTarget = normalizeVersion(targetVersion);
    const normPatch = normalizeVersion(patchVersion);
    const isMatch = Boolean(!normTarget || !normPatch || normTarget === normPatch);
    return {
      source: 'ready-file',
      path: readyPath,
      version: patchVersion,
      size: stat.size,
      isMatch
    };
  } catch (_) {
    return null;
  }
}

/**
 * 诊断客户端当前状态
 */
async function checkClientStatus({ appDir, getResourcesDir } = {}) {
  if (!appDir) {
    throw new Error('appDir 参数必填');
  }
  const resDirFn = getResourcesDir || (dir => path.join(dir, 'resources'));
  const resourcesDir = path.resolve(resDirFn(appDir));
  const asarPath = path.join(resourcesDir, 'app.asar');
  const backupPath = path.join(resourcesDir, 'app.asar.bak');

  const isInstalled = fs.existsSync(asarPath);
  if (!isInstalled) {
    return {
      isInstalled: false,
      appDir,
      resourcesDir,
      asarPath,
      appVersion: null,
      isLocalized: false,
      hasBackup: false,
      isUpdateOverwritten: false
    };
  }

  const appVersion = readAsarPackageVersion(asarPath);
  const isLocalized = isLocalizedAsar(asarPath);
  const hasBackup = fs.existsSync(backupPath) && !isLocalizedAsar(backupPath);
  // 当程序已安装但未汉化时，说明是官方原版安装或官方更新覆盖
  const isUpdateOverwritten = !isLocalized;

  return {
    isInstalled: true,
    appDir,
    resourcesDir,
    asarPath,
    backupPath,
    appVersion,
    isLocalized,
    hasBackup,
    isUpdateOverwritten
  };
}

/**
 * 执行自动恢复与安全安装
 */
async function executeAutoRestore({
  appDir,
  getResourcesDir,
  workspaceDir,
  isAppRunning,
  stopProcesses,
  forceStop = true,
  candidatePatch = null,
  stopTimeoutMs = 3000
} = {}) {
  const wsDir = workspaceDir || path.resolve(__dirname);
  const status = await checkClientStatus({ appDir, getResourcesDir });

  if (!status.isInstalled) {
    return {
      success: false,
      code: 'NOT_INSTALLED',
      message: `未在目标目录找到 Antigravity 程序：${appDir}`
    };
  }

  if (status.isLocalized) {
    return {
      success: true,
      code: 'ALREADY_LOCALIZED',
      appVersion: status.appVersion,
      message: `当前客户端 (v${status.appVersion || '未知'}) 已处于汉化状态，无需重复安装。`
    };
  }

  // 寻找或使用指定的补丁包
  const patch = candidatePatch || await findAvailablePatch({
    workspaceDir: wsDir,
    targetVersion: status.appVersion
  });

  if (!patch) {
    return {
      success: false,
      code: 'NO_PATCH_FOUND',
      appVersion: status.appVersion,
      message: '本地未找到预打包汉化文件 (app.asar.ready)，请直接运行 node localize.js 重新打包汉化。'
    };
  }

  const appNorm = normalizeVersion(status.appVersion);
  const patchNorm = normalizeVersion(patch.version);

  // 核心安全拦截：版本兼容性校验
  // 如果客户端版本与补丁包版本均明确且不一致，坚决阻止盲目覆盖！
  if (appNorm && patchNorm && appNorm !== patchNorm) {
    return {
      success: false,
      code: 'VERSION_MISMATCH',
      appVersion: status.appVersion,
      patchVersion: patch.version,
      patchPath: patch.path,
      message: `[安全拦截] 客户端已由官方更新为 v${status.appVersion}，但本地预打包文件版本为 v${patch.version}。为防止界面异常，请直接运行 node localize.js 对新版本重新解包汉化。`
    };
  }

  // 检查并关闭运行中进程
  if (typeof isAppRunning === 'function') {
    let running = false;
    try {
      running = await isAppRunning();
    } catch (_) {}

    if (running) {
      if (!forceStop) {
        return {
          success: false,
          code: 'APP_RUNNING',
          message: 'Antigravity 正在运行中，请退出客户端后再执行恢复。'
        };
      }
      if (typeof stopProcesses === 'function') {
        try {
          await stopProcesses();
        } catch (_) {}
        const deadline = Date.now() + stopTimeoutMs;
        while (Date.now() < deadline) {
          try {
            if (!await isAppRunning()) break;
          } catch (_) { break; }
          await new Promise(r => setTimeout(r, 100));
        }
        try {
          if (await isAppRunning()) {
            return {
              success: false,
              code: 'APP_RUNNING',
              message: '未能成功退出 Antigravity 客户端，文件仍在被占用，请先手动退出后再执行恢复。'
            };
          }
        } catch (_) {}
      }
    }
  }

  // 执行安全备份
  const asarPath = status.asarPath;
  const resourcesDir = status.resourcesDir;
  let createdBackupPath = null;
  const standardBackup = path.join(resourcesDir, 'app.asar.bak');

  try {
    const backupExists = fs.existsSync(standardBackup);
    const backupLocalized = backupExists && isLocalizedAsar(standardBackup);
    const backupVersion = backupExists ? readAsarPackageVersion(standardBackup) : null;
    const isDifferentVersion = backupExists && status.appVersion && backupVersion && (status.appVersion !== backupVersion);

    // 如果备份不存在、已被汉化污染、或备份版本与当前官方原版不一致（官方更新覆盖了新版本原版）
    if (!backupExists || backupLocalized || isDifferentVersion) {
      if (backupExists && !backupLocalized) {
        const archivedName = `app.asar.bak.${backupVersion || 'old'}.${Date.now().toString().slice(-6)}`;
        try {
          await fsp.copyFile(standardBackup, path.join(resourcesDir, archivedName));
        } catch (_) {}
      }
      await fsp.copyFile(asarPath, standardBackup);
      createdBackupPath = standardBackup;
    }
  } catch (err) {
    // 备份若失败，不强行写目标
    return {
      success: false,
      code: 'BACKUP_FAILED',
      message: `创建安全原版备份失败: ${err.message}`
    };
  }

  // 原子安装补丁
  const token = `${Date.now()}-${crypto.randomBytes(6).toString('hex')}`;
  const stagePath = path.join(resourcesDir, `.app.asar.restore-${token}.stage`);
  try {
    // 1. 复制到同目录暂存文件
    await fsp.copyFile(patch.path, stagePath);
    // 2. 哈希比对确认复制完整性
    const patchHash = await hashFile(patch.path);
    const stageHash = await hashFile(stagePath);
    if (patchHash !== stageHash) {
      throw new Error('汉化包暂存写入校验失败，SHA256 不一致');
    }
    // 3. 原子重命名覆盖目标
    await fsp.rename(stagePath, asarPath);
    if (process.platform === 'darwin') {
      const appBundleMatch = String(appDir).match(/^.*\.app/);
      if (appBundleMatch) {
        try { execFileSync('xattr', ['-cr', appBundleMatch[0]], { stdio: 'ignore' }); } catch (_) {}
      }
    }

    return {
      success: true,
      code: 'RESTORED',
      appVersion: status.appVersion,
      patchVersion: patch.version,
      patchPath: patch.path,
      backupPath: createdBackupPath || standardBackup,
      message: `汉化补丁 (v${patch.version || status.appVersion || '匹配'}) 已成功安全恢复！`
    };
  } catch (err) {
    // 清理暂存文件
    try {
      if (fs.existsSync(stagePath)) await fsp.unlink(stagePath);
    } catch (_) {}
    return {
      success: false,
      code: 'INSTALL_FAILED',
      message: `覆盖汉化补丁失败: ${err.message}`
    };
  }
}

module.exports = {
  isLocalizedAsar,
  hashFile,
  normalizeVersion,
  findAvailablePatch,
  checkClientStatus,
  executeAutoRestore
};
