/**
 * @file fix-frontmatter.cjs
 * @description SKILL.md frontmatter 批量修复工具
 *
 * 处理三类常见缺陷：
 *   1. 无 frontmatter        → 从 H1 标题/blockquote 摘要生成并插入
 *   2. 缺 name               → 补目录名（kebab-case 校验）
 *   3. 缺 description        → 从 description_zh / description_en 回填
 *   4. 缺 version            → 补 1.0.0
 *
 * 用法：
 *   node scripts/fix-frontmatter.cjs           # 执行修复
 *   node scripts/fix-frontmatter.cjs --dry-run # 仅输出计划
 */
const fs = require('fs');
const path = require('path');

const ROOT = path.resolve(__dirname, '..');
const CLI_LIB = path.join(ROOT, 'packages/yyc3-cli/lib');
const { scanSkillFiles } = require(CLI_LIB + '/skills-indexer');

const DRY_RUN = process.argv.includes('--dry-run');

/** 简易 frontmatter 解析（与 CLI validator 同口径：仅顶层 key: value） */
function parseFm(content) {
  const m = content.match(/^---\r?\n([\s\S]*?)\r?\n---/);
  if (!m) return { hasFm: false, fm: {}, body: content, raw: '' };
  const fm = {};
  for (const line of m[1].split(/\r?\n/)) {
    const i = line.indexOf(':');
    if (i < 0 || /^\s/.test(line)) continue; // 跳过缩进续行
    const k = line.slice(0, i).trim();
    const v = line.slice(i + 1).trim().replace(/^["']|["']$/g, '');
    if (k) fm[k] = v;
  }
  return { hasFm: true, fm, raw: m[1], body: content.slice(m[0].length) };
}

/** YAML 单行值转义：含特殊字符时用双引号包裹 */
function yamlValue(v) {
  const s = String(v).replace(/\s+/g, ' ').trim();
  if (/[:#"'[\]{}]/.test(s) || s !== s.trim()) {
    return '"' + s.replace(/\\/g, '\\\\').replace(/"/g, '\\"') + '"';
  }
  return s;
}

/** 从正文提取摘要：首个 blockquote 或首个非标题段落 */
function extractSummary(body) {
  const lines = body.split(/\r?\n/).map(l => l.trim());
  // H1 标题
  const h1 = lines.find(l => /^#\s+/.test(l));
  const title = h1 ? h1.replace(/^#\s+/, '').split(/[—–\-|]/)[0].trim() : '';
  // 首个 blockquote
  const bq = [];
  let inBq = false;
  for (const l of lines) {
    if (l.startsWith('>')) { bq.push(l.replace(/^>\s?/, '')); inBq = true; }
    else if (inBq && l === '') break;
    else if (inBq) break;
  }
  if (bq.length) {
    return { title, summary: bq.join(' ').slice(0, 280) };
  }
  // 首个非空非标题非表格非代码段落
  const para = [];
  let inCode = false;
  for (const l of lines) {
    if (l.startsWith('```')) { inCode = !inCode; continue; }
    if (inCode || !l || l.startsWith('#') || l.startsWith('|') || l.startsWith('---')) continue;
    para.push(l);
    if (para.length >= 2) break;
  }
  return { title, summary: para.join(' ').slice(0, 280) };
}

function kebab(dirName) {
  return dirName.toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/^-|-$/g, '');
}

async function main() {
  const files = await scanSkillFiles();
  console.log('[fix:frontmatter] Scanning ' + files.length + ' SKILL.md files' + (DRY_RUN ? ' (dry-run)' : ''));

  const fixed = [];
  const skipped = [];

  for (const file of files) {
    const content = fs.readFileSync(file, 'utf-8');
    const { hasFm, fm, raw, body } = parseFm(content);
    const dirName = path.basename(path.dirname(file));
    const changes = [];

    let newRaw = raw;
    let newBody = body;

    if (!hasFm) {
      // 情形 1：完全无 frontmatter → 生成
      const { title, summary } = extractSummary(content);
      const name = kebab(dirName);
      const desc = summary || title || ('Skill: ' + name);
      const fmBlock = [
        '---',
        'name: ' + name,
        'description: ' + yamlValue(desc),
        'version: 1.0.0',
        '---',
        '',
      ].join('\n');
      newRaw = fmBlock;
      newBody = content; // 无 frontmatter 时 body 即全文
      changes.push('create(name,description,version)');
    } else {
      const lines = newRaw.split(/\r?\n/);

      // 情形 2：缺 name
      if (!fm['name']) {
        const name = kebab(dirName);
        lines.unshift('name: ' + name);
        changes.push('add name=' + name);
      }

      // 情形 3：缺/空 description → 从双语字段回填
      if (!fm['description']) {
        // 先移除既有的空值行（后值覆盖前值会导致回填失效）
        const emptyIdx = lines.findIndex(l => /^description:\s*$/.test(l));
        if (emptyIdx >= 0) lines.splice(emptyIdx, 1);
        // 再移除本工具此前插入的重复行（幂等重入保护）
        const dupIdx = lines.findIndex(l => /^description: /.test(l));
        if (dupIdx === -1) {
          const fallback = fm['description_zh'] || fm['description_en'];
          if (fallback) {
            lines.splice(1, 0, 'description: ' + yamlValue(fallback));
            changes.push('add description<-description_' + (fm['description_zh'] ? 'zh' : 'en'));
          } else {
            const { title, summary } = extractSummary(body);
            const desc = summary || title || ('Skill: ' + (fm['name'] || dirName));
            lines.splice(1, 0, 'description: ' + yamlValue(desc));
            changes.push('add description<-body');
          }
        } else {
          changes.push('clean duplicate description');
        }
      }

      // 情形 4：缺 version
      if (!fm['version']) {
        const idx = lines.findIndex(l => /^name:/.test(l));
        lines.splice(idx + 1, 0, 'version: 1.0.0');
        changes.push('add version=1.0.0');
      } else if (!/^\d+\.\d+\.\d+/.test(fm['version'])) {
        // 情形 5：两段式版本号 → 规范化为 SemVer（1.2 → 1.2.0）
        const normalized = fm['version'].replace(/^v?(\d+)\.(\d+)$/, '$1.$2.0');
        if (/^\d+\.\d+\.\d+/.test(normalized)) {
          const vIdx = lines.findIndex(l => /^version:/.test(l));
          lines[vIdx] = 'version: ' + normalized;
          changes.push('normalize version ' + fm['version'] + '->' + normalized);
        }
      }

      newRaw = lines.join('\n');
    }

    if (changes.length === 0) continue;

    const rel = path.relative(ROOT, file);
    if (DRY_RUN) {
      fixed.push({ file: rel, changes });
    } else {
      // 重组：frontmatter 块 + 正文
      const output = hasFm
        ? '---\n' + newRaw + '\n---\n' + newBody.replace(/^\r?\n/, '')
        : newRaw + '\n' + newBody.replace(/^\r?\n/, '');
      fs.writeFileSync(file, output, 'utf-8');
      fixed.push({ file: rel, changes });
    }
  }

  console.log('[fix:frontmatter] Fixed: ' + fixed.length + ', Skipped: ' + skipped.length);
  for (const f of fixed) {
    console.log('  ' + (DRY_RUN ? 'PLAN' : 'FIXED') + ': ' + f.file + ' (' + f.changes.join(', ') + ')');
  }
}

main().catch(e => { console.error(e); process.exit(1); });
