/**
 * 评分基线生成工具（版本发布时使用）
 *
 * 用法:
 *   node scripts/gen-baseline-v2.5.0.cjs                 # 快照当前分布 → baseline-v2.5.0.json
 *   node scripts/gen-baseline-v2.5.0.cjs --next 2.6.0    # 生成 baseline-v2.6.0.json（doctor GATES.baseline 需同步）
 *
 * 流程（发版推进基线）:
 *   1. 本脚本生成新 baseline-v{N}.json
 *   2. packages/yyc3-cli/lib/doctor.js 的 GATES.baseline 指向新文件
 *   3. 旧 baseline 保留作历史追溯（勿删）
 */
const fs = require('fs').promises;
const path = require('path');

const args = process.argv.slice(2);
let version = '2.5.0';
const nextIdx = args.indexOf('--next');
if (nextIdx !== -1 && args[nextIdx + 1]) version = args[nextIdx + 1];
else {
  // 无 --next 时默认取当前 package.json 版本
  version = require('../package.json').version;
}

(async () => {
  const { scoreAll } = require('../packages/yyc3-cli/lib/skills-scorer');
  const { summary, results } = await scoreAll({});
  const baseline = {
    version,
    note: `v${version} 固化基线 — doctor score 门禁引用此文件（避免报告更新即门禁漂移）；仅在版本发布时更新`,
    summary,
    worst: results.sort((a, b) => a.score - b.score).slice(0, 10)
      .map((r) => ({ file: r.file, score: r.score, grade: r.grade })),
  };
  const out = path.join(__dirname, '..', 'docs', 'skill-score', `baseline-${version}.json`);
  await fs.writeFile(out, JSON.stringify(baseline, null, 2) + '\n');
  console.log(`baseline written: ${path.relative(process.cwd(), out)}`);
  console.log('avg:', summary.average, 'byGrade:', JSON.stringify(summary.byGrade));
  console.log(`\n下一步: 更新 packages/yyc3-cli/lib/doctor.js → GATES.baseline = 'docs/skill-score/baseline-${version}.json'`);
})().catch((e) => { console.error(e); process.exit(1); });
