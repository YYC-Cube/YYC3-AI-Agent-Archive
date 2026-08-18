/**
 * @file extract-skills-keys.js
 * @description Skills 翻译键提取器 — 扫描 SKILL.md frontmatter 生成 i18n locale JSON
 * @module scripts/skills-extractor
 */
const fs = require('fs').promises;
const path = require('path');
const crypto = require('crypto');

const ROOT = path.resolve(__dirname, '../..');
const SKILLS_HUB = path.join(ROOT, 'skills-hub');
const AGENTS_HUB = path.join(ROOT, 'agents-hub');
const OUTPUT = path.resolve(__dirname, '../locales');

/**
 * 解析 frontmatter
 */
function parseFM(content) {
  const m = content.match(/^---\n([\s\S]*?)\n---\n/);
  if (!m) return {};
  const r = {};
  for (const l of m[1].split('\n')) {
    const i = l.indexOf(':'); if (i < 0) continue;
    r[l.slice(0, i).trim()] = l.slice(i + 1).trim().replace(/^["']|["']$/g, '');
  }
  return r;
}

/**
 * 递归扫描 SKILL.md
 */
async function scanSKILL(baseDir) {
  const results = [];
  async function walk(dir) {
    const entries = await fs.readdir(dir, { withFileTypes: true }).catch(() => []);
    for (const e of entries) {
      const fp = path.join(dir, e.name);
      if (e.isDirectory()) { if (!e.name.startsWith('.')) await walk(fp); }
      else if (e.name === 'SKILL.md') results.push(fp);
    }
  }
  await walk(baseDir);
  return results;
}

/**
 * 生成翻译键
 * skill.{hub}.{dirname}.name
 * skill.{hub}.{dirname}.desc
 * skill.{hub}.{dirname}.category
 */
function genSkillKeys(files) {
  const keys = {};
  for (const f of files) {
    const rel = path.relative(ROOT, f);
    const parts = rel.split(path.sep);
    const hub = parts[0]; // skills-hub
    const subHub = parts[1]; // community / marketplace / ai-ml / b2b
    const dirName = parts[2] || parts[1];
    const skillName = parts.slice(2, -1).join('.') || path.basename(path.dirname(f));
    
    const content = fs.readFileSync(f, 'utf-8');
    const meta = parseFM(content);
    const name = meta.name || skillName;
    const desc = meta.description || '';
    const cat = meta.category || 'Uncategorized';
    const descZH = meta.description_zh || desc;
    
    const prefix = `skill.${subHub || 'other'}.${sanitizeKey(skillName)}`;
    keys[`${prefix}.name`] = typeof name === 'string' ? name : String(name);
    keys[`${prefix}.desc`] = typeof descZH === 'string' ? descZH.slice(0, 300) : String(descZH).slice(0, 300);
    keys[`${prefix}.category`] = cat;
  }
  return keys;
}

/**
 * Agent 翻译键
 */
function genAgentKeys() {
  const agents = {
    'agent.tianshu':       { name: '元启·天枢',   role: '总指挥 · 决策中枢',         phone: '0379-0206', layer: '全局中枢层' },
    'agent.qianhang':      { name: '言启·千行',   role: '首席导航员 · 意图之门',     phone: '0379-0106', layer: '接入网关层' },
    'agent.allthings':     { name: '语枢·万物',   role: '首席思考者 · 洞察之源',     phone: '0379-0107', layer: '专业执行层' },
    'agent.prophet':       { name: '预见·先知',   role: '首席预言家 · 趋势之眼',     phone: '0379-0108', layer: '专业执行层' },
    'agent.bole':          { name: '千里·伯乐',   role: '首席推荐官 · 知遇之人',     phone: '0379-0109', layer: '专业执行层' },
    'agent.guardian':      { name: '智云·守护',   role: '首席安全官 · 免疫系统',     phone: '0379-0207', layer: '专业执行层' },
    'agent.grandmaster':   { name: '格物·宗师',   role: '首席质量官 · 进化导师',     phone: '0379-0208', layer: '专业执行层' },
    'agent.grace':         { name: '创想·灵韵',   role: '首席创意官 · 灵感之源',     phone: '0379-0209', layer: '专业执行层' },
  };
  const keys = {};
  for (const [prefix, data] of Object.entries(agents)) {
    keys[`${prefix}.name`] = data.name;
    keys[`${prefix}.role`] = data.role;
    keys[`${prefix}.phone`] = data.phone;
    keys[`${prefix}.layer`] = data.layer;
  }
  return keys;
}

/**
 * CLI 翻译键
 */
function genCLIKeys() {
  return {
    'cli.build.progress':     '正在构建 {type} 索引...',
    'cli.build.done':         '构建完成: {count} 项',
    'cli.validate.start':     '验证 Skills 完整性...',
    'cli.validate.passing':   '通过: {count}',
    'cli.validate.failing':   '失败: {count}',
    'cli.dedup.start':        '检测重复文件...',
    'cli.dedup.found':        '发现 {count} 组重复',
    'cli.dedup.unique':       '唯一文件: {count}',
    'cli.stats.total':        '总计: {count}',
    'cli.stats.fmOk':         'Frontmatter 完整: {count}',
    'cli.stats.fmMissing':    'Frontmatter 缺失: {count}',
    'cli.stats.categories':   '分类数: {count}',
    'cli.error.notFound':     '文件 {path} 未找到',
    'cli.error.failed':       '操作失败: {msg}',
    'cli.doctor.healthy':     '健康状态: 正常',
    'cli.doctor.unhealthy':   '健康状态: 异常',
  };
}

/**
 * 品牌翻译键
 */
function genBrandKeys() {
  return {
    'brand.slogan.primary':   '万象归元于云枢',
    'brand.slogan.secondary': '深栈智启新纪元',
    'brand.name.full':        'YYC³ 言语云立方',
    'brand.name.short':       'YYC³',
    'brand.tagline':          '言启千行代码，语枢万物智能',
    'brand.family.motto':     '亦师亦友亦伯乐，一言一语一协同',
    'brand.family.vision':    '人机共生，智慧同行',
  };
}

/**
 * 文档翻译键
 */
function genDocKeys() {
  const docs = [
    ['docs.arch.overview', '架构总览'],
    ['docs.arch.nineLayer', '九层全栈架构'],
    ['docs.arch.agent', '多智能体整体架构'],
    ['docs.guide.quickstart', '快速入门'],
    ['docs.guide.installation', '安装指南'],
    ['docs.spec.frontmatter', 'Frontmatter 规范'],
    ['docs.spec.naming', '命名规范'],
    ['docs.spec.skill', 'Skill 标准模板'],
    ['docs.ops.deploy', '部署指南'],
    ['docs.ops.monitor', '监控运维'],
  ];
  const keys = {};
  for (const [k, v] of docs) keys[k] = v;
  return keys;
}

function sanitizeKey(s) {
  return s.replace(/[^a-zA-Z0-9\u4e00-\u9fff_-]/g, '_').replace(/_+/g, '_').replace(/^_|_$/g, '');
}

async function main() {
  console.log('[extract] Scanning skills-hub for SKILL.md files...');
  
  const skillFiles = await scanSKILL(SKILLS_HUB);
  console.log('[extract] Found ' + skillFiles.length + ' SKILL.md files');
  
  console.log('[extract] Generating translation keys...');
  const keys = {
    ...genBrandKeys(),
    ...genAgentKeys(),
    ...genCLIKeys(),
    ...genDocKeys(),
    ...genSkillKeys(skillFiles),
  };
  
  console.log('[extract] Total keys: ' + Object.keys(keys).length);
  
  // 按字母序排序
  const sorted = {};
  for (const k of Object.keys(keys).sort()) sorted[k] = keys[k];
  
  // 输出
  await fs.mkdir(OUTPUT, { recursive: true });
  const outPath = path.join(OUTPUT, 'zh-CN.json');
  await fs.writeFile(outPath, JSON.stringify(sorted, null, 2), 'utf-8');
  console.log('[extract] Written to ' + outPath);
  
  // 输出统计
  const cats = {};
  for (const k of Object.keys(sorted)) {
    const prefix = k.split('.')[0];
    cats[prefix] = (cats[prefix] || 0) + 1;
  }
  console.log('\n[extract] Key distribution:');
  for (const [cat, count] of Object.entries(cats).sort((a, b) => b[1] - a[1])) {
    console.log('  ' + cat + ': ' + count);
  }
  
  return sorted;
}

if (require.main === module) main().catch(e => { console.error(e); process.exit(1); });
module.exports = { main, genSkillKeys, genAgentKeys, genCLIKeys, genBrandKeys };
