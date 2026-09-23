/**
 * @file skills-graph-report.js
 * @description 关联维度图分析报告 — JSON + Markdown 双输出
 */
const fs = require('fs').promises;
const path = require('path');
const { buildGraph } = require('./skills-graph');

function renderMarkdown(g) {
  const s = g.summary;
  const L = [];
  L.push('# 技能关联维度图分析报告', '');
  L.push(`> 生成时间: ${s.generatedAt} · 数据基础：831 技能全量正文扫描`, '');
  L.push('## 一、图谱总览', '');
  L.push('| 指标 | 值 | 说明 |', '|------|----|------|');
  L.push(`| 节点（技能） | ${s.totalNodes} | 全量 SKILL.md |`);
  L.push(`| 边（引用关系） | ${s.totalEdges} | explicit ${s.explicitEdges} + implicit ${s.implicitEdges} |`);
  L.push(`| 孤立节点 | ${s.isolatedNodes} | 无任何入/出边的技能 |`);
  L.push(`| 连通分量 | ${s.components} | 最大分量 ${s.largestComponent} 节点 |`);
  L.push(`| 边密度 | ${s.edgeDensity} | 实际边 / 理论完全图边 |`);
  L.push('', '## 二、核心枢纽 TOP15（hubRank）', '');
  L.push('| # | 技能 | hubRank | 路径 |', '|---|------|---------|------|');
  g.hubs.forEach((h, i) => L.push(`| ${i + 1} | \`${h.name}\` | ${h.hubRank} | ${h.file} |`));
  L.push('', '## 三、领域簇（按簇内边密度排序 TOP15）', '');
  L.push('| 领域目录 | 技能数 | 簇内边 |', '|----------|--------|--------|');
  g.clusters.slice(0, 15).forEach((c) => L.push(`| ${c.domain} | ${c.nodes} | ${c.internalEdges} |`));
  L.push('', '## 四、治理建议', '');
  L.push(`- 孤立技能 ${s.isolatedNodes} 个：补充 related_skills 或在正文中引用相邻技能可提升可发现性`);
  L.push('- 显式声明边占比极低（' + (s.totalEdges ? ((s.explicitEdges / s.totalEdges) * 100).toFixed(1) : 0) + '%）：frontmatter related_skills 是当前空白，建议新技能规范要求声明');
  L.push('- 本报告为「关联维度」数据基础，v2.6.0 评分集成候选（暂不计分，先积累数据）', '');
  return L.join('\n') + '\n';
}

async function graphCommand(options = {}) {
  console.log('[skills:graph] Building association graph...');
  const g = await buildGraph({});
  const s = g.summary;
  console.log(`[skills:graph] nodes=${s.totalNodes} edges=${s.totalEdges} (explicit=${s.explicitEdges}, implicit=${s.implicitEdges}) isolated=${s.isolatedNodes} components=${s.components}`);
  const outDir = options.out || 'docs/skill-score';
  await fs.mkdir(outDir, { recursive: true });
  const jsonPath = path.join(outDir, 'graph-report.json');
  await fs.writeFile(jsonPath, JSON.stringify(g, null, 2) + '\n');
  console.log(`[skills:graph] Report → ${jsonPath}`);
  if (!options.json) {
    const mdPath = path.join(outDir, 'graph-report.md');
    await fs.writeFile(mdPath, renderMarkdown(g));
    console.log(`[skills:graph] Report → ${mdPath}`);
  }
  return g;
}

module.exports = { graphCommand, renderMarkdown };
