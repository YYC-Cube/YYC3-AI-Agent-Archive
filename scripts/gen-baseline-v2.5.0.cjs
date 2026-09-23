/**
 * 一次性脚本：生成 v2.5.0 评分基线（快照当前 summary 分布）
 * 输出: docs/skill-score/baseline-v2.5.0.json
 */
const fs = require('fs').promises;
const path = require('path');
const { scoreAll } = require('../packages/yyc3-cli/lib/skills-scorer');

(async () => {
  const { summary, results } = await scoreAll({});
  const baseline = {
    version: '2.5.0',
    note: 'v2.5.0 固化基线 — doctor score 门禁引用此文件（避免报告更新即门禁漂移）；仅在版本发布时更新',
    summary,
    worst: results.sort((a, b) => a.score - b.score).slice(0, 10)
      .map((r) => ({ file: r.file, score: r.score, grade: r.grade })),
  };
  const out = path.join(__dirname, '..', 'docs', 'skill-score', 'baseline-v2.5.0.json');
  await fs.writeFile(out, JSON.stringify(baseline, null, 2) + '\n');
  console.log('baseline written:', out);
  console.log('avg:', summary.average, 'byGrade:', JSON.stringify(summary.byGrade));
})().catch((e) => { console.error(e); process.exit(1); });
