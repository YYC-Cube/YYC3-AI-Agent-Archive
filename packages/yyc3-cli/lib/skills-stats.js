/**
 * @file skills-stats.js
 * @description Skills 统计报告
 */
const fs = require('fs').promises;
const path = require('path');
const { scanSkillFiles, parseFrontmatter } = require('./skills-indexer');
const ROOT = require('./skills-indexer').ROOT || path.resolve(__dirname, '../..');

async function generateStats(options) {
  options = options || {};
  console.log('[skills:stats] Generating...');
  const files = await scanSkillFiles();
  const hubs = {}, cats = {};
  let fmOk = 0, fmFail = 0;
  for (const f of files) {
    const content = await fs.readFile(f, 'utf-8');
    if (content.startsWith('---')) { fmOk++; const m = parseFrontmatter(content); const c = m.category || 'Uncategorized'; cats[c] = (cats[c] || 0) + 1; }
    else fmFail++;
    const rel = path.relative(ROOT, f);
    const hub = rel.split('/')[0];
    hubs[hub] = (hubs[hub] || 0) + 1;
  }
  console.log('[skills:stats] Total: ' + files.length);
  console.log('[skills:stats] Frontmatter OK: ' + fmOk + ', Missing: ' + fmFail);
  console.log('[skills:stats] Categories: ' + Object.keys(cats).length);
  if (options.verbose) {
    console.log('\nHub distribution:');
    for (const [k, v] of Object.entries(hubs).sort((a, b) => b[1] - a[1])) console.log('  ' + k + ': ' + v);
    console.log('\nTop categories:');
    const top = Object.entries(cats).sort((a, b) => b[1] - a[1]).slice(0, 15);
    for (const [k, v] of top) console.log('  ' + k + ': ' + v);
  }
  return { total: files.length, frontmatterOk: fmOk, frontmatterMissing: fmFail, categories: Object.keys(cats).length };
}

module.exports = { generateStats };
