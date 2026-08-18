/**
 * @file extract-skills-keys.cjs
 * @description Skills 翻译键提取器 — CommonJS 模块
 */
const fs = require('fs').promises;
const path = require('path');

const ROOT = path.resolve(__dirname, '..');
const SKILLS_HUB = path.join(ROOT, 'skills-hub');
const OUTPUT = path.join(ROOT, 'locales');

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

async function scanSKILL(dir) {
  const results = [];
  async function walk(d) {
    const entries = await fs.readdir(d, { withFileTypes: true }).catch(() => []);
    for (const e of entries) {
      const fp = path.join(d, e.name);
      if (e.isDirectory()) { if (!e.name.startsWith('.') && e.name !== 'node_modules' && e.name !== '_external') await walk(fp); }
      else if (e.name === 'SKILL.md') results.push(fp);
    }
  }
  await walk(dir);
  return results;
}

function sanitizeKey(s) {
  if (!s) return 'unknown';
  return s.replace(/[^a-zA-Z0-9\u4e00-\u9fff_-]/g, '_').replace(/_+/g, '_').replace(/^_|_$/g, '').toLowerCase();
}

async function main() {
  console.log('[extract] Scanning skills-hub...');
  const files = await scanSKILL(SKILLS_HUB);
  console.log('[extract] Found ' + files.length + ' SKILL.md files');

  const keys = {};
  let count = 0;

  // Skills 键
  for (const f of files) {
    const rel = path.relative(ROOT, f);
    const parts = rel.split(path.sep);
    const sub = parts[1] || 'other';
    const name = parts.slice(2, -1).join('.') || sanitizeKey(path.basename(path.dirname(f)));
    const content = await fs.readFile(f, 'utf-8');
    const meta = parseFM(content);
    const skillId = sanitizeKey(meta.name || name);
    const prefix = 'skill.' + sanitizeKey(sub) + '.' + skillId;
    keys[prefix + '.name'] = (meta.name || name).slice(0, 100);
    keys[prefix + '.desc'] = (meta.description_zh || meta.description || '').slice(0, 300);
    keys[prefix + '.category'] = meta.category || 'Uncategorized';
    count++;
  }

  console.log('[i18n:extract] Skills scanned: ' + count);

  // Agent 键
  const agents = {
    'agent.tianshu': { name: '元启·天枢', role: '总指挥 · 决策中枢', phone: '0379-0206' },
    'agent.qianhang': { name: '言启·千行', role: '首席导航员 · 意图之门', phone: '0379-0106' },
    'agent.allthings': { name: '语枢·万物', role: '首席思考者 · 洞察之源', phone: '0379-0107' },
    'agent.prophet': { name: '预见·先知', role: '首席预言家 · 趋势之眼', phone: '0379-0108' },
    'agent.bole': { name: '千里·伯乐', role: '首席推荐官 · 知遇之人', phone: '0379-0109' },
    'agent.guardian': { name: '智云·守护', role: '首席安全官 · 免疫系统', phone: '0379-0207' },
    'agent.grandmaster': { name: '格物·宗师', role: '首席质量官 · 进化导师', phone: '0379-0208' },
    'agent.grace': { name: '创想·灵韵', role: '首席创意官 · 灵感之源', phone: '0379-0209' },
  };
  for (const [p, d] of Object.entries(agents)) {
    keys[p + '.name'] = d.name; keys[p + '.role'] = d.role; keys[p + '.phone'] = d.phone;
  }

  // 品牌键
  Object.assign(keys, {
    'brand.slogan.primary': '万象归元于云枢',
    'brand.slogan.secondary': '深栈智启新纪元',
    'brand.name.full': 'YYC³ 言语云立方',
    'brand.name.short': 'YYC³',
    'brand.family.motto': '亦师亦友亦伯乐，一言一语一协同',
  });

  // CLI 键
  Object.assign(keys, {
    'cli.build.progress': '正在构建 {type} 索引...',
    'cli.build.done': '构建完成: {count} 项',
    'cli.validate.passing': '通过: {count}',
    'cli.validate.failing': '失败: {count}',
    'cli.dedup.found': '发现 {count} 组重复',
    'cli.stats.total': '总计: {count}',
    'cli.error.notFound': '文件 {path} 未找到',
  });

  // 排序
  const sorted = {};
  for (const k of Object.keys(keys).sort()) sorted[k] = keys[k];

  // 写入
  await fs.mkdir(OUTPUT, { recursive: true });
  await fs.writeFile(path.join(OUTPUT, 'zh-CN.json'), JSON.stringify(sorted, null, 2), 'utf-8');

  // 统计
  const dist = {};
  for (const k of Object.keys(sorted)) { const p = k.split('.')[0]; dist[p] = (dist[p] || 0) + 1; }

  console.log('\n[extract] ✅ Done: ' + Object.keys(sorted).length + ' keys');
  console.log('[extract] Distribution:');
  for (const [c, n] of Object.entries(dist).sort((a, b) => b[1] - a[1])) console.log('  ' + c + ': ' + n);
  return sorted;
}

if (require.main === module) main().catch(e => { console.error(e); process.exit(1); });
module.exports = { main };
