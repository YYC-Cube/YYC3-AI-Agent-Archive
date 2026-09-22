/**
 * @file skills-score-report.js
 * @description Task H1 — 评分报告生成（JSON + Markdown，含分布统计与低分 TOP20）
 */
const fs = require('fs').promises;
const path = require('path');
const { scoreAll } = require('./skills-scorer');

const ROOT = require('./skills-indexer') && require('./skills-indexer').ROOT
  ? require('./skills-indexer').ROOT
  : path.resolve(__dirname, '../..');

/** 生成 Markdown 报告 */
function renderMarkdown(summary, results, lowTop = 20) {
  const lines = [];
  lines.push('# 技能质量评分报告');
  lines.push('');
  lines.push(`> 生成时间: ${summary.generatedAt} | 引擎: yyc3-cli skills score（五维加权）`);
  lines.push('');
  lines.push('## 总览');
  lines.push('');
  lines.push('| 指标 | 值 |');
  lines.push('|------|------|');
  lines.push(`| 技能总数 | ${summary.total} |`);
  lines.push(`| 平均分 | ${summary.average} |`);
  lines.push(
    `| 等级分布 | A:${summary.byGrade.A} B:${summary.byGrade.B} C:${summary.byGrade.C} D:${summary.byGrade.D} E:${summary.byGrade.E} |`
  );
  lines.push('');
  lines.push('## 权重配置');
  lines.push('');
  lines.push('| 维度 | 权重 |');
  lines.push('|------|------|');
  for (const [k, w] of Object.entries(summary.weights)) {
    lines.push(`| ${k} | ${Math.round(w * 100)}% |`);
  }
  lines.push('');
  lines.push(`## 低分 TOP${lowTop}（优先治理清单）`);
  lines.push('');
  lines.push('| 分数 | 等级 | 文件 | 最弱维度 |');
  lines.push('|------|------|------|----------|');
  const dimNames = {
    metadata: '元数据',
    docs: '文档',
    assets: '资产',
    activity: '活跃度',
    security: '安全',
  };
  const low = [...results].sort((a, b) => a.score - b.score).slice(0, lowTop);
  for (const r of low) {
    const weakest = Object.entries(r.dims).sort((a, b) => a[1] - b[1])[0];
    lines.push(`| ${r.score} | ${r.grade} | ${r.file} | ${dimNames[weakest[0]]}(${weakest[1]}) |`);
  }
  lines.push('');
  return lines.join('\n');
}

/**
 * 评分主入口：CLI `skills score`
 * @param {object} options
 * @param {string} [options.out] 报告输出目录（默认 docs/skill-score）
 * @param {boolean} [options.json] 仅输出 JSON
 */
async function scoreCommand(options = {}) {
  const { results, summary } = await scoreAll(options);
  const outDir = path.resolve(ROOT, options.out || 'docs/skill-score');
  await fs.mkdir(outDir, { recursive: true });

  const jsonPath = path.join(outDir, 'score-report.json');
  await fs.writeFile(jsonPath, JSON.stringify({ summary, results }, null, 2) + '\n');
  console.log(
    `[skills:score] Total: ${summary.total}, Avg: ${summary.average}, ` +
      `A:${summary.byGrade.A} B:${summary.byGrade.B} C:${summary.byGrade.C} D:${summary.byGrade.D} E:${summary.byGrade.E}`
  );

  if (!options.json) {
    const mdPath = path.join(outDir, 'score-report.md');
    await fs.writeFile(mdPath, renderMarkdown(summary, results));
    console.log(`[skills:score] Report → ${path.relative(ROOT, jsonPath)} + score-report.md`);
  }
  return { results, summary, outDir };
}

module.exports = { scoreCommand, renderMarkdown };
