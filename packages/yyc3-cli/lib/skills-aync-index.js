/**
 * @file skills-aync-index.js
 * @description AYNC 统一索引生成器 — 元数据优先的统一分类方案
 *
 * AYNC 编码不要求物理目录重命名（避免引用链破坏），而是通过本索引实现
 * 「一处生成、处处检索」的统一分类视图：
 *   docs/AYNC-INDEX.md   人类可读分组清单
 *   docs/AYNC-INDEX.json 机器可读（code/name/category/version/path）
 *
 * 用法：yyc3 skills index
 */
const fs = require('fs').promises;
const path = require('path');
const { scanSkillFiles, parseFrontmatter, ROOT } = require('./skills-indexer');
const { toAyncName, normalizeCategory } = require('./skills-naming');

/**
 * 生成 AYNC 统一索引
 */
async function generateAyncIndex(options) {
  options = options || {};
  console.log('[skills:index] Scanning...');
  const files = await scanSkillFiles();

  const records = [];
  for (const f of files) {
    const meta = parseFrontmatter(await fs.readFile(f, 'utf-8'));
    const dir = path.basename(path.dirname(f));
    const name = meta.name || dir;
    const category = normalizeCategory(meta.category);
    records.push({
      code: toAyncName(name, meta.category),
      name,
      category,
      rawCategory: meta.category || '',
      version: meta.version || '1.0.0',
      path: path.relative(ROOT, f),
    });
  }
  records.sort((a, b) => a.code.localeCompare(b.code));

  // 机器可读索引
  const jsonPath = path.join(ROOT, 'docs', 'AYNC-INDEX.json');
  await fs.writeFile(jsonPath, JSON.stringify({
    _meta: {
      total: records.length,
      generated_at: new Date().toISOString(),
      scheme: 'AYNC-[type]-[category]-[name]（元数据级编码，非文件系统命名）',
    },
    skills: records,
  }, null, 2));

  // 人类可读索引（按类别分组）
  const byCat = {};
  for (const r of records) (byCat[r.category] = byCat[r.category] || []).push(r);
  const catLines = Object.keys(byCat).sort().map(cat => {
    const items = byCat[cat].map(r => `  - \`${r.code}\` v${r.version} → ${r.path}`).join('\n');
    return `### ${cat}（${byCat[cat].length}）\n\n${items}`;
  }).join('\n\n');

  const md = `# AYNC 统一技能索引\n\n> 生成时间：${new Date().toISOString()} ｜ 技能总数：${records.length} ｜ 类别数：${Object.keys(byCat).length}\n>\n> **方案说明**：AYNC 编码（AYNC-[类型]-[类别]-[名称]）以**元数据级**落地——由 frontmatter\n> category 派生，不重命名物理目录（保护 plugin.json 等引用链）。检索与注册经由\n> skill-registry；本索引由 \`yyc3 skills index\` 随时再生成。\n\n${catLines}\n`;
  const mdPath = path.join(ROOT, 'docs', 'AYNC-INDEX.md');
  await fs.writeFile(mdPath, md);

  console.log('[skills:index] Skills: ' + records.length + ', Categories: ' + Object.keys(byCat).length);
  console.log('[skills:index] Written: docs/AYNC-INDEX.md, docs/AYNC-INDEX.json');
  return { total: records.length, categories: Object.keys(byCat).length };
}

module.exports = { generateAyncIndex };
