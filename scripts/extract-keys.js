const fs = require('fs').promises;
const path = require('path');

async function scanSKILL(dir) {
  const results = [];
  async function walk(d, depth) {
    if (depth > 8) return;
    const entries = await fs.readdir(d, { withFileTypes: true }).catch(() => []);
    for (const e of entries) {
      if (e.name.startsWith('.') || e.name === 'node_modules' || e.name === '_external') continue;
      const fp = path.join(d, e.name);
      if (e.isDirectory()) await walk(fp, depth + 1);
      else if (e.name === 'SKILL.md') results.push(fp);
    }
  }
  await walk(dir, 0);
  return results;
}

async function main() {
  const root = path.resolve(__dirname, '..');
  console.log('Scanning ' + path.join(root, 'skills-hub'));
  const files = await scanSKILL(path.join(root, 'skills-hub'));
  console.log('Found ' + files.length + ' files');

  const keys = {};
  for (const f of files) {
    const content = await fs.readFile(f, 'utf-8');
    const m = content.match(/^---\n([\s\S]*?)\n---\n/);
    if (!m) continue;
    const meta = {};
    for (const l of m[1].split('\n')) {
      const i = l.indexOf(':');
      if (i < 0) continue;
      meta[l.slice(0, i).trim()] = l.slice(i + 1).trim().replace(/^["']|["']$/g, '');
    }
    if (!meta.name) continue;
    const rel = path.relative(root, f);
    const parts = rel.split('/');
    const sub = parts[1] || 'unknown';
    const id = meta.name.replace(/[^a-zA-Z0-9\u4e00-\u9fff]/g, '_').replace(/_+/g, '_').toLowerCase();
    keys['skill.' + sub + '.' + id + '.name'] = String(meta.name).slice(0, 100);
    keys['skill.' + sub + '.' + id + '.desc'] = String(meta.description_zh || meta.description || '').slice(0, 300);
  }

  // Agent keys
  const agents = [
    ['tianshu', '元启·天枢', '总指挥 · 决策中枢'],
    ['qianhang', '言启·千行', '首席导航员 · 意图之门'],
    ['allthings', '语枢·万物', '首席思考者 · 洞察之源'],
    ['prophet', '预见·先知', '首席预言家 · 趋势之眼'],
    ['bole', '千里·伯乐', '首席推荐官 · 知遇之人'],
    ['guardian', '智云·守护', '首席安全官 · 免疫系统'],
    ['grandmaster', '格物·宗师', '首席质量官 · 进化导师'],
    ['grace', '创想·灵韵', '首席创意官 · 灵感之源'],
  ];
  for (const [id, name, role] of agents) {
    keys['agent.' + id + '.name'] = name;
    keys['agent.' + id + '.role'] = role;
  }

  keys['brand.slogan.primary'] = '万象归元于云枢';
  keys['brand.slogan.secondary'] = '深栈智启新纪元';
  keys['brand.name.full'] = 'YYC3 言语云立方';

  const sorted = {};
  for (const k of Object.keys(keys).sort()) sorted[k] = keys[k];
  await fs.mkdir(path.join(root, 'locales'), { recursive: true });
  await fs.writeFile(path.join(root, 'locales', 'zh-CN.json'), JSON.stringify(sorted, null, 2));
  console.log('Done: wrote ' + Object.keys(sorted).length + ' keys');
}

main().catch(e => { console.error(e.message); process.exit(1); });
