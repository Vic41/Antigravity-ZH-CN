'use strict';

const fs = require('fs');
const path = require('path');

/**
 * Pure Node.js ASAR unpacker & packer (Zero external dependencies).
 * Preserves `unpacked` metadata entries from the original ASAR header so
 * `app.asar.unpacked` companions work without duplicating unpacked files.
 */
function extractAsar(asarPath, destDir) {
  const fd = fs.openSync(asarPath, 'r');
  try {
    const headerBuf = Buffer.alloc(16);
    fs.readSync(fd, headerBuf, 0, 16, 0);
    const headerSize = headerBuf.readUInt32LE(4);
    const jsonSize = headerBuf.readUInt32LE(12);
    const jsonBuf = Buffer.alloc(jsonSize);
    fs.readSync(fd, jsonBuf, 0, jsonSize, 16);
    const header = JSON.parse(jsonBuf.toString('utf8'));
    const dataOffset = 8 + headerSize;

    function walk(node, currentPath) {
      if (node && node.files && typeof node.files === 'object') {
        fs.mkdirSync(currentPath, { recursive: true });
        for (const [name, child] of Object.entries(node.files)) {
          walk(child, path.join(currentPath, name));
        }
      } else if (node && typeof node.link === 'string') {
        try {
          if (fs.existsSync(currentPath) || fs.lstatSync(currentPath)) {
            fs.unlinkSync(currentPath);
          }
        } catch (_) {}
        fs.mkdirSync(path.dirname(currentPath), { recursive: true });
        fs.symlinkSync(node.link, currentPath);
      } else if (node) {
        if (node.unpacked) {
          return;
        }
        const offset = Number(node.offset || 0);
        const size = Number(node.size || 0);
        const buf = Buffer.alloc(size);
        if (size > 0) {
          fs.readSync(fd, buf, 0, size, dataOffset + offset);
        }
        fs.mkdirSync(path.dirname(currentPath), { recursive: true });
        fs.writeFileSync(currentPath, buf);
        if (node.executable && process.platform !== 'win32') {
          try {
            fs.chmodSync(currentPath, 0o755);
          } catch (_) {}
        }
      }
    }

    walk(header, destDir);
    // Save original header metadata so packAsar can preserve `unpacked` entries
    fs.writeFileSync(
      path.join(destDir, '.asar_orig_header.json'),
      JSON.stringify(header),
      'utf8'
    );
    return header;
  } finally {
    fs.closeSync(fd);
  }
}

function packAsar(srcDir, outAsarPath, origHeader = null) {
  const savedHeaderPath = path.join(srcDir, '.asar_orig_header.json');
  if (!origHeader && fs.existsSync(savedHeaderPath)) {
    try {
      origHeader = JSON.parse(fs.readFileSync(savedHeaderPath, 'utf8'));
    } catch (_) {}
  }

  const chunks = [];
  let currentOffset = 0;

  function buildNode(origNode, currentPath) {
    let stat = null;
    try {
      stat = fs.lstatSync(currentPath);
    } catch (_) {}

    if ((origNode && origNode.files) || (stat && stat.isDirectory())) {
      const files = {};
      const origFiles = (origNode && origNode.files) || {};
      const diskNames =
        stat && stat.isDirectory()
          ? fs.readdirSync(currentPath).filter((n) => n !== '.asar_orig_header.json')
          : [];
      const allNames = Array.from(new Set([...Object.keys(origFiles), ...diskNames]));
      for (const name of allNames) {
        const origChild = origFiles[name];
        const childPath = path.join(currentPath, name);
        if (origChild && origChild.unpacked) {
          files[name] = origChild;
        } else {
          let childExists = false;
          try {
            fs.lstatSync(childPath);
            childExists = true;
          } catch (_) {}
          if (childExists) {
            files[name] = buildNode(origChild, childPath);
          }
        }
      }
      return { files };
    }

    if (stat && stat.isSymbolicLink()) {
      return { link: fs.readlinkSync(currentPath) };
    }

    const data = fs.readFileSync(currentPath);
    const size = data.length;
    const offset = String(currentOffset);
    currentOffset += size;
    chunks.push(data);
    const entry = { size, offset };
    if (
      (origNode && origNode.executable) ||
      (stat && process.platform !== 'win32' && (stat.mode & 0o111) !== 0)
    ) {
      entry.executable = true;
    }
    return entry;
  }

  const newHeader = buildNode(origHeader || {}, srcDir);
  const headerJsonBuf = Buffer.from(JSON.stringify(newHeader), 'utf8');
  const jsonLen = headerJsonBuf.length;
  const paddingLen = (4 - (jsonLen % 4)) % 4;
  const alignedJsonLen = jsonLen + paddingLen;
  const headerSize = alignedJsonLen + 8;

  const prefixBuf = Buffer.alloc(16);
  prefixBuf.writeUInt32LE(4, 0);
  prefixBuf.writeUInt32LE(headerSize, 4);
  prefixBuf.writeUInt32LE(alignedJsonLen + 4, 8);
  prefixBuf.writeUInt32LE(jsonLen, 12);

  const fd = fs.openSync(outAsarPath, 'w');
  try {
    fs.writeSync(fd, prefixBuf);
    fs.writeSync(fd, headerJsonBuf);
    if (paddingLen > 0) {
      fs.writeSync(fd, Buffer.alloc(paddingLen, 0));
    }
    for (const chunk of chunks) {
      if (chunk.length > 0) {
        fs.writeSync(fd, chunk);
      }
    }
  } finally {
    fs.closeSync(fd);
  }
}

module.exports = {
  extractAsar,
  packAsar
};
