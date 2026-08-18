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
    // 跳过符号链接（可能是目录链接，readFile 会 EISDIR）
    if (e.isSymbolicLink()) continue;
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

module.exports = { findDuplicates, findNameCollisions };

/**
 * 同名技能冲突分析（注册中心级）
 * 分类：IDENT（SKILL.md 字节相同，仅存储冗余）/ VARIANT（内容有差异，存在版本遮蔽风险）
 */
async function findNameCollisions(options) {
  options = options || {};
  const { scanSkillFiles, parseFrontmatter } = require('./skills-indexer');
  const files = await scanSkillFiles();
  const byName = {};
  for (const f of files) {
    const meta = parseFrontmatter(await fs.readFile(f, 'utf-8'));
    const name = meta.name || path.basename(path.dirname(f));
    (byName[name] = byName[name] || []).push(f);
  }

  const groups = [];
  for (const [name, paths] of Object.entries(byName)) {
    if (paths.length < 2) continue;
    const contents = [];
    for (const p of paths) contents.push(await fs.readFile(p, 'utf-8'));
    const identical = contents.every(c => c === contents[0]);
    groups.push({ name, kind: identical ? 'IDENT' : 'VARIANT', paths: paths.map(p => path.relative(ROOT, p)) });
  }
  groups.sort((a, b) => (a.kind === b.kind ? a.name.localeCompare(b.name) : a.kind === 'VARIANT' ? -1 : 1));

  const ident = groups.filter(g => g.kind === 'IDENT').length;
  const variant = groups.filter(g => g.kind === 'VARIANT').length;
  console.log('[skills:dedup] Name collisions: ' + groups.length + ' groups (VARIANT: ' + variant + ', IDENT: ' + ident + ')');
  if (options.verbose) {
    for (const g of groups) {
      console.log('  [' + g.kind + '] ' + g.name);
      for (const p of g.paths) console.log('      - ' + p);
    }
  }
  return { groups, identCount: ident, variantCount: variant };
}
