/**
 * @file skills-deduper.js
 * @description 去重检测 — SHA256 哈希比对
 */
const fs = require('fs').promises;
const path = require('path');
const crypto = require('crypto');
const ROOT = require('./skills-indexer').ROOT || path.resolve(__dirname, '../..');

async function scanAllFiles(dir, depth) {
  if (depth > 6) return [];
  const results = [];
  const entries = await fs.readdir(dir, { withFileTypes: true }).catch(() => []);
  for (const e of entries) {
    if (e.name.startsWith('.') || e.name === 'node_modules' || e.name === '_external' || e.name === '_archive') continue;
    const fp = path.join(dir, e.name);
    if (e.isDirectory()) results.push(...await scanAllFiles(fp, depth + 1));
    else results.push(fp);
  }
  return results;
}

async function findDuplicates(options) {
  options = options || {};
  console.log('[skills:dedup] Scanning...');
  const all = await scanAllFiles(ROOT, 0);
  console.log('[skills:dedup] Total files: ' + all.length);
  const map = new Map();
  for (const f of all) {
    const hash = crypto.createHash('sha256').update(await fs.readFile(f)).digest('hex');
    if (!map.has(hash)) map.set(hash, []);
    map.get(hash).push(f);
  }
  const dups = [];
  for (const [h, files] of map) { if (files.length > 1) dups.push({ hash: h, files, count: files.length }); }
  dups.sort((a, b) => b.count - a.count);
  console.log('[skills:dedup] Unique: ' + map.size + ', Duplicate groups: ' + dups.length);
  if (dups.length && options.verbose) { for (const d of dups.slice(0, 10)) { console.log('  [' + d.count + 'x]: ' + path.relative(ROOT, d.files[0])); } }
  return { duplicates: dups, totalFiles: all.length, uniqueFiles: map.size };
}

module.exports = { findDuplicates };
