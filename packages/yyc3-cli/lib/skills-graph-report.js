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

/**
 * related_skills 补全 — 候选列表 dry-run 报告 + apply 写回
 * apply 语义：仅在 frontmatter 插入/合并 related_skills 数组行，不动正文。
 * 已有相关声明（四字段任一）则合并去重；无 frontmatter 不处理（非标资产）。
 */
async function suggestCommand(options = {}) {
  const { buildGraph, suggestRelated } = require('./skills-graph');
  console.log('[skills:graph:suggest] Building graph...');
  const g = await buildGraph({});
  const suggestions = suggestRelated(g, { topN: options.topN || 5, minConfidence: options.minConfidence || 4 });
  const totalCands = suggestions.reduce((n, x) => n + x.candidates.length, 0);
  console.log(`[skills:graph:suggest] ${suggestions.length} skills / ${totalCands} candidates (minConfidence=${options.minConfidence || 4}, topN=${options.topN || 5})`);

  const outDir = options.out || 'docs/skill-score';
  await fs.mkdir(outDir, { recursive: true });
  const jsonPath = path.join(outDir, 'related-skills-suggestions.json');
  await fs.writeFile(jsonPath, JSON.stringify({ generatedAt: new Date().toISOString(), applied: !!options.apply, suggestions }, null, 2) + '\n');
  console.log(`[skills:graph:suggest] Suggestions → ${jsonPath}`);

  if (!options.apply) {
    console.log('[skills:graph:suggest] dry-run 完成（未写入任何文件）。加 --apply 执行批量补全');
    return suggestions;
  }

  // apply：写回 SKILL.md frontmatter
  const ROOT = require('./skills-indexer').ROOT || path.resolve(__dirname, '../../..');
  let applied = 0, skipped = 0, merged = 0;
  for (const s of suggestions) {
    const fileAbs = path.join(ROOT, s.file, 'SKILL.md');
    let content;
    try { content = await fs.readFile(fileAbs, 'utf-8'); } catch { skipped++; continue; }
    const m = content.match(/^---\n([\s\S]*?)\n---\n/);
    if (!m) { skipped++; continue; }
    const fmRaw = m[1];
    const names = s.candidates.map((c) => c.name);
    let newFm;
    const existing = fmRaw.match(/^related_skills:\s*(\[.*?\]|\S.*)\s*$/m);
    if (existing) {
      // 合并去重（兼容 inline 数组 / 已是 YAML list）
      let cur = [];
      const inline = existing[1].match(/^\[(.*)\]$/);
      if (inline) cur = inline[1].split(',').map((x) => x.trim().replace(/^['"]|['"]$/g, '')).filter(Boolean);
      else cur = [existing[1].replace(/^['"]|['"]$/g, '').trim()];
      const set = new Set([...cur, ...names]);
      newFm = fmRaw.replace(existing[0], 'related_skills: [' + [...set].join(', ') + ']');
      merged++;
    } else {
      // 追加到 frontmatter 末尾（name 之后语义最优，但末尾最安全）
      newFm = fmRaw + '\nrelated_skills: [' + names.join(', ') + ']';
      applied++;
    }
    const next = content.replace(m[0], '---\n' + newFm + '\n---\n');
    await fs.writeFile(fileAbs, next);
  }
  console.log(`[skills:graph:suggest] applied=${applied} merged=${merged} skipped=${skipped}`);
  // 写后立即重建图验证显式边增长
  const g2 = await buildGraph({});
  console.log(`[skills:graph:suggest] rebuild: explicit=${g2.summary.explicitEdges} isolated=${g2.summary.isolatedNodes} (was explicit=0)`);
  return suggestions;
}

module.exports = { graphCommand, renderMarkdown, suggestCommand };
