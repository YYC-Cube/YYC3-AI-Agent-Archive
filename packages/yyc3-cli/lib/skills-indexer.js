/**
 * @file skills-indexer.js
 * @description Skills 索引构建引擎
 */
const fs = require('fs').promises;
const fsSync = require('fs');
const path = require('path');

/**
 * 解析仓库根目录 — 兼容两种布局：
 *   Monorepo:  <repo>/packages/yyc3-cli/lib → 根为 <repo>
 *   独立仓库:  <YYC3-CLI>/lib              → 根为 <YYC3-CLI>
 * 判定依据：根目录下存在 skills-hub/
 */
function resolveRoot() {
  const candidates = [
    path.resolve(__dirname, '../../..'),  // monorepo: packages/yyc3-cli/lib
    path.resolve(__dirname, '../..'),     // standalone: lib
  ];
  for (const root of candidates) {
    if (fsSync.existsSync(path.join(root, 'skills-hub'))) return root;
  }
  return candidates[0];
}

const ROOT = resolveRoot();
const SKILLS_HUB = path.join(ROOT, 'skills-hub');

async function scanSkillFiles(baseDir) {
  const results = []; const dir = baseDir || SKILLS_HUB;
  async function walk(d) {
    const entries = await fs.readdir(d, { withFileTypes: true });
    for (const e of entries) {
      const fp = path.join(d, e.name);
      if (e.isDirectory()) { if (!e.name.startsWith('.')) await walk(fp); }
      else if (e.name === 'SKILL.md') results.push(fp);
    }
  }
  await walk(dir); return results;
}

function parseFrontmatter(content) {
  const m = content.match(/^---\n([\s\S]*?)\n---\n/);
  if (!m) return {};
  const r = {};
  for (const l of m[1].split('\n')) {
    // 跳过缩进续行与嵌套块（如 metadata: 下的子字段），避免子级键覆盖顶层键
    if (/^\s/.test(l) || l.trim().startsWith('#')) continue;
    const i = l.indexOf(':'); if (i < 0) continue;
    const key = l.slice(0, i).trim();
    const value = l.slice(i + 1).trim().replace(/^["']|["']$/g, '');
    if (key && value !== undefined) r[key] = value;
  }
  return r;
}

async function buildIndex(options) {
  options = options || {};
  console.log('[skills:build] Scanning...');
  const files = await scanSkillFiles();
  console.log('[skills:build] Found ' + files.length + ' files');
  const cats = {};
  for (const f of files) {
    const meta = parseFrontmatter(await fs.readFile(f, 'utf-8'));
    const cat = meta.category || 'Uncategorized';
    if (!cats[cat]) cats[cat] = [];
    cats[cat].push({ name: meta.name, path: path.relative(ROOT, f), category: cat, version: meta.version || '1.0.0' });
  }
  const out = { _meta: { total: files.length, categories: Object.keys(cats).length, generated_at: new Date().toISOString() }, categories: cats };
  const outPath = options.output || path.join(ROOT, '_categories.json');
  await fs.writeFile(outPath, JSON.stringify(out, null, 2));
  console.log('[skills:build] Done: ' + files.length + ' skills in ' + Object.keys(cats).length + ' categories');
  return out;
}

module.exports = { buildIndex, scanSkillFiles, parseFrontmatter, ROOT, SKILLS_HUB };
