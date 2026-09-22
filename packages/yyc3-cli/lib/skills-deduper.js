/**
 * @file skills-deduper.js
 * @description 去重检测 — SHA256 哈希比对
 */
const fs = require('fs').promises;
const path = require('path');
const crypto = require('crypto');
const ROOT = require('./skills-indexer').ROOT || path.resolve(__dirname, '../..');

/** 默认忽略目录（构建产物/依赖/归档），Task I3 */
const DEFAULT_EXCLUDES = [
  'node_modules', '.git', '_external', '_archive',
  'dist', 'build', 'coverage', '.turbo', '.next',
];

async function scanAllFiles(dir, depth, excludes) {
  if (depth > 6) return [];
  const results = [];
  const entries = await fs.readdir(dir, { withFileTypes: true }).catch(() => []);
  for (const e of entries) {
    if (e.name.startsWith('.') && e.name !== '.github') continue;
    if (excludes.includes(e.name)) continue;
    // 跳过符号链接（可能是目录链接，readFile 会 EISDIR）
    if (e.isSymbolicLink()) continue;
    const fp = path.join(dir, e.name);
    if (e.isDirectory()) results.push(...await scanAllFiles(fp, depth + 1, excludes));
    else results.push(fp);
  }
  return results;
}

/**
 * 按路径特征分类重复组（Task I3 分类报告）：
 *   license-template — 许可/字体许可模板文件（跨项目天然相同，非冗余缺陷）
 *   reference-asset  — 参考资产目录（agents-hub/tools-hub/mcp-hub/vendor 等上游镜像）
 *   build-artifact   — 构建产物（lockfile/minified/sourcemap）
 *   genuine          — 真实冗余（需人工裁决）
 */
function classifyDuplicates(dups) {
  const REF_DIRS = /(agents-hub|tools-hub|mcp-hub|skills-hub\/_vendor|vendor)\//;
  const BUILD = /(pnpm-lock\.yaml|\.min\.|\.map$|package-lock\.json)/;
  const LICENSE = /(^|\/)(LICENSE|LICENSE\.txt|NOTICE|NOTICE\.txt|OFL\.txt|COPYING)(\.md)?$/i;
  const out = { 'license-template': [], 'reference-asset': [], 'build-artifact': [], genuine: [] };
  for (const d of dups) {
    const rels = d.files.map((f) => path.relative(ROOT, f));
    if (rels.every((r) => LICENSE.test(r))) out['license-template'].push({ ...d, files: rels });
    else if (rels.every((r) => BUILD.test(r))) out['build-artifact'].push({ ...d, files: rels });
    else if (rels.every((r) => REF_DIRS.test(r))) out['reference-asset'].push({ ...d, files: rels });
    else out.genuine.push({ ...d, files: rels });
  }
  return out;
}

async function findDuplicates(options) {
  options = options || {};
  const excludes = options.excludes || DEFAULT_EXCLUDES;
  console.log('[skills:dedup] Scanning...');
  const all = await scanAllFiles(ROOT, 0, excludes);
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
  const classified = classifyDuplicates(dups);
  console.log(
    '[skills:dedup] Unique: ' + map.size + ', Duplicate groups: ' + dups.length +
    ' (license-template: ' + classified['license-template'].length +
    ', reference-asset: ' + classified['reference-asset'].length +
    ', build-artifact: ' + classified['build-artifact'].length +
    ', genuine: ' + classified.genuine.length + ')'
  );
  if (dups.length && options.verbose) {
    for (const d of classified.genuine.slice(0, 10)) { console.log('  [genuine ' + d.count + 'x]: ' + d.files[0]); }
  }
  return { duplicates: dups, totalFiles: all.length, uniqueFiles: map.size, classified };
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
