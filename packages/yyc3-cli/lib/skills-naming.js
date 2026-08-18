/**
 * @file skills-naming.js
 * @description Skills 命名规范工具 — AYNC 编码 lint 与迁移计划
 *
 * AYNC 统一分类编码：AYNC-[类型]-[类别]-[名称]
 *   类型码：A=Agent Y=Skill N=MCP C=Plugin T=Tool
 *   示例：AYNC-Y-DE-paper-quick-reader
 *
 * 用途：
 *   yyc3 skills naming lint       检查命名合规性（kebab-case + AYNC 编码统计）
 *   yyc3 skills naming migrate    生成 AYNC 迁移计划（默认 dry-run，--apply 执行）
 */
const fs = require('fs').promises;
const path = require('path');
const { scanSkillFiles, parseFrontmatter } = require('./skills-indexer');

/** kebab-case 命名规范：小写字母、数字、连字符 */
const KEBAB_RE = /^[a-z0-9]+(-[a-z0-9]+)*$/;

/** AYNC 编码规范：AYNC-<T>-<CC>-<name> */
const AYNC_RE = /^AYNC-([AYNCT])-[A-Z]{2}-[a-z0-9]+(-[a-z0-9]+)*$/;

/** AYNC 类型码 → 资产类型 */
const AYNC_TYPES = { A: 'Agent', Y: 'Skill', N: 'MCP', C: 'Plugin', T: 'Tool' };

/** 类别名 → 两字母类别码（对齐 ai-family-unified-architecture 设计文档 + 实际值域扩展） */
const CATEGORY_CODES = {
  'development-code': 'DE',
  'document-processing': 'DP',
  'business-productivity': 'BS',
  'ai-ml': 'AI',
  'data-analysis': 'DA',
  'security': 'SC',
  'ui-ux': 'UX',
  'marketing': 'MK',
  'social': 'SO',
  'b2b': 'B2',
  'dev-workflow': 'DV',
  'engineering': 'EN',
  'custom': 'CU',
  // 实际值域扩展（2026-08-18 盘点 24 种类别值全覆盖）
  'project-management': 'PM',
  'devops': 'DO',
  'automation': 'AU',
  'email': 'EM',
  'storage-docs': 'SD',
  'social-media': 'SM',
  'communication': 'CO',
  'analytics': 'AN',
  'crm': 'CR',
  'customer-support': 'CS',
  'education': 'ED',
  'design': 'DS',
  'ecommerce': 'EC',
  'creative-collaboration': 'CC',
  'testing': 'TC',
};

/** 类别名规范化：大小写/变体归并（Education → education, Design Tools → design, Productivity → business-productivity） */
function normalizeCategory(category) {
  if (!category) return 'custom';
  const lower = category.toLowerCase().trim();
  if (lower === 'productivity') return 'business-productivity';
  if (lower === 'design tools') return 'design';
  if (lower === '生活服务') return 'custom';
  if (CATEGORY_CODES[lower]) return lower;
  for (const key of Object.keys(CATEGORY_CODES)) {
    if (lower.includes(key) || key.includes(lower)) return key;
  }
  return 'custom';
}

/** 类别 → AYNC 编码目录名 */
function toAyncName(dirName, category) {
  const code = CATEGORY_CODES[normalizeCategory(category)] || 'CU';
  return `AYNC-Y-${code}-${dirName}`;
}

/**
 * 收集全部技能的命名信息
 */
async function collectNaming() {
  const files = await scanSkillFiles();
  const skills = [];
  for (const f of files) {
    const meta = parseFrontmatter(await fs.readFile(f, 'utf-8'));
    const dir = path.basename(path.dirname(f));
    skills.push({
      dir,
      name: meta.name || dir,
      category: meta.category || '',
      file: f,
    });
  }
  return skills;
}

/**
 * 命名合规性检查
 */
async function lintNaming(options) {
  options = options || {};
  console.log('[skills:naming] Scanning...');
  const skills = await collectNaming();

  const nonKebab = skills.filter(s => !KEBAB_RE.test(s.name));
  const withCategory = skills.filter(s => !!s.category);
  const ayncCompliant = skills.filter(s => AYNC_RE.test(s.dir));

  console.log('[skills:naming] Total skills: ' + skills.length);
  console.log('[skills:naming] kebab-case 合规: ' + (skills.length - nonKebab.length) + '/' + skills.length);
  console.log('[skills:naming] AYNC 元数据覆盖（category）: ' + withCategory.length + '/' + skills.length + ' (' + Math.round((withCategory.length / skills.length) * 100) + '%)');
  console.log('[skills:naming] AYNC 目录命名（已决策为非必需）: ' + ayncCompliant.length + '/' + skills.length);
  console.log('[skills:naming] 统一索引: yyc3 skills index → docs/AYNC-INDEX.md');

  if (options.verbose) {
    if (nonKebab.length) {
      console.log('\n  非 kebab-case 命名（前 20 条）:');
      for (const s of nonKebab.slice(0, 20)) console.log('    - ' + s.name + '  (' + path.relative(process.cwd(), s.file) + ')');
    }
    const missingCat = skills.filter(s => !s.category);
    if (missingCat.length) {
      console.log('\n  缺少 category（前 20 条）:');
      for (const s of missingCat.slice(0, 20)) console.log('    - ' + s.name + '  (' + path.relative(process.cwd(), s.file) + ')');
    }
  }

  return {
    total: skills.length,
    kebabCompliant: skills.length - nonKebab.length,
    ayncCompliant: ayncCompliant.length,
    missingCategory: skills.length - withCategory.length,
    violations: nonKebab,
  };
}

/**
 * AYNC 迁移计划（默认 dry-run）
 */
async function migrateNaming(options) {
  options = options || {};
  const apply = !!options.apply;
  console.log('[skills:naming] ' + (apply ? 'APPLYING' : 'Planning (dry-run)') + ' AYNC migration...');

  const skills = await collectNaming();
  const alreadyAync = new Set(
    skills.filter(s => AYNC_RE.test(s.dir)).map(s => s.dir)
  );

  const plans = [];
  for (const s of skills) {
    if (alreadyAync.has(s.dir)) continue;
    const target = toAyncName(s.dir, s.category);
    if (target === s.dir) continue;
    plans.push({ from: path.dirname(s.file), to: path.join(path.dirname(path.dirname(s.file)), target), dir: s.dir, target });
  }

  console.log('[skills:naming] 待迁移: ' + plans.length + ' / ' + skills.length + '（已合规 ' + alreadyAync.size + '）');

  if (options.verbose || !apply) {
    for (const p of plans.slice(0, options.verbose ? plans.length : 20)) {
      console.log('  ' + (apply ? 'RENAMED' : 'PLAN') + ': ' + p.dir + ' → ' + p.target);
    }
    if (!options.verbose && plans.length > 20) console.log('  ... 其余 ' + (plans.length - 20) + ' 条使用 --verbose 查看');
  }

  if (!apply) {
    console.log('\n[note] 这是 dry-run。确认后执行: yyc3 skills naming migrate --apply');
    return { planned: plans.length, applied: 0 };
  }

  // 执行迁移
  let applied = 0;
  const errors = [];
  for (const p of plans) {
    try {
      await fs.access(p.to).catch(async () => {
        await fs.rename(p.from, p.to);
        applied++;
      });
    } catch (e) {
      errors.push({ dir: p.dir, msg: e.message });
    }
  }

  console.log('[skills:naming] 已迁移: ' + applied + ', 失败: ' + errors.length);
  for (const e of errors.slice(0, 10)) console.log('  ERROR: ' + e.dir + ' - ' + e.msg);
  return { planned: plans.length, applied, errors };
}

module.exports = { lintNaming, migrateNaming, toAyncName, normalizeCategory, KEBAB_RE, AYNC_RE, CATEGORY_CODES };
