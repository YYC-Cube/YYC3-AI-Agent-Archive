/**
 * @file skills-graph.js
 * @description 技能关联维度图分析 — 引用图谱引擎（v2.6.0「关联维度」数据基础）
 *
 * 边模型（双层）:
 *   explicit — frontmatter `related_skills` / `depends_on` 声明的显式引用（权重 2）
 *   implicit — 正文中提及其他技能 name（`name` 或裸词匹配）（权重 1）
 *
 * 指标:
 *   nodes/edges/connectedComponents/isolated — 连通性
 *   hubRank — 简化 PageRank（迭代 20 轮，damping 0.85）识别核心枢纽
 *   domainClusters — 按顶层目录聚合的领域簇（簇内边密度）
 *
 * 输出为纯数据结构，评分集成与 doctor 消费方各自裁剪。
 */
const fs = require('fs').promises;
const path = require('path');
const { scanSkillFiles, parseFrontmatter } = require('./skills-indexer');

/** 显式引用字段（frontmatter，数组或逗号分隔字符串均可） */
const EXPLICIT_FIELDS = ['related_skills', 'related-skills', 'depends_on', 'depends-on'];

function toArray(v) {
  if (Array.isArray(v)) return v.map(String);
  if (typeof v === 'string') return v.split(',').map((s) => s.trim()).filter(Boolean);
  return [];
}

/** 转义正则特殊字符 */
function escapeRe(s) {
  return s.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
}

/**
 * related_skills 候选生成（显式边补全）
 *
 * 从 implicit 边推导置信度：
 *   双向提及（A 提及 B 且 B 提及 A）  +3 —— 最强信号
 *   同领域（顶层目录相同）            +1
 *   每条单向提及                      +1
 * 过滤：confidence < MIN_CONFIDENCE 剔除；每技能取 TOP N（去重、排除已有声明）
 *
 * @param {object} g buildGraph 结果
 * @returns {Array<{name, file, candidates: Array<{name, confidence, reasons}>}>}
 */
function suggestRelated(g, { topN = 5, minConfidence = 4 } = {}) {
  const nodeNames = new Set(Object.keys(g.nodes));
  // name → 已声明 related（不重复推荐）
  const declared = new Map();
  for (const n of Object.keys(g.nodes)) {
    declared.set(n, new Set(g.nodes[n].related || []));
  }
  // 提及计数（双向判断）
  const mentions = new Map(); // src → Map(dst → count)
  for (const e of g.edges) {
    if (!mentions.has(e.src)) mentions.set(e.src, new Map());
    mentions.get(e.src).set(e.dst, (mentions.get(e.src).get(e.dst) || 0) + e.weight);
  }

  const out = [];
  for (const [name, node] of Object.entries(g.nodes)) {
    const cands = [];
    const outs = mentions.get(name) || new Map();
    for (const [dst, cnt] of outs) {
      if (!nodeNames.has(dst) || (declared.get(name) || new Set()).has(dst)) continue;
      const back = (mentions.get(dst) || new Map()).get(name) || 0;
      let conf = cnt;
      const reasons = [];
      if (back > 0) { conf += 3; reasons.push('双向提及'); }
      if (g.nodes[dst].domain === node.domain) { conf += 1; reasons.push('同领域'); }
      if (cnt >= 2) reasons.push('高频提及 ' + cnt);
      cands.push({ name: dst, confidence: conf, reasons: reasons.length ? reasons : ['单向提及'] });
    }
    cands.sort((a, b) => b.confidence - a.confidence);
    const picked = cands.filter((c) => c.confidence >= minConfidence).slice(0, topN);
    if (picked.length) out.push({ name, file: node.file, candidates: picked });
  }
  out.sort((a, b) => b.candidates[0].confidence - a.candidates[0].confidence);
  return out;
}

/**
 * 构建图谱
 * @returns {{nodes: object, edges: Array, summary: object, hubs: Array, clusters: Array}}
 */
async function buildGraph(options = {}) {
  const files = await scanSkillFiles();
  const nodes = new Map(); // name → {file, domain, body, in:0, out:0}
  for (const f of files) {
    const content = await fs.readFile(f, 'utf-8');
    const fm = parseFrontmatter(content);
    if (!fm.name) continue;
    const m = content.match(/^---\n([\s\S]*?)\n---\n/);
    const rel = path.relative(process.cwd(), path.dirname(f));
    nodes.set(String(fm.name), {
      file: rel,
      domain: rel.split(path.sep).slice(0, 2).join('/'),
      body: m ? content.slice(m[0].length) : content,
      fm,
    });
  }

  // 边构建：explicit 先于 implicit（同类边去重，explicit 优先）
  const edgeMap = new Map(); // "src\x00dst" → {src, dst, kind, weight}
  const addEdge = (src, dst, kind, weight) => {
    if (src === dst || !nodes.has(src) || !nodes.has(dst)) return;
    const key = src + '\x00' + dst;
    const existing = edgeMap.get(key);
    if (!existing || existing.weight < weight) edgeMap.set(key, { src, dst, kind, weight });
  };

  for (const [name, node] of nodes) {
    // explicit：frontmatter 声明
    for (const field of EXPLICIT_FIELDS) {
      for (const ref of toArray(node.fm[field])) addEdge(name, ref, 'explicit', 2);
    }
    // implicit：正文提及（反引号包裹或词边界裸词；仅当目标 name ≥5 字符降低误报）
    for (const target of nodes.keys()) {
      if (target === name || target.length < 5) continue;
      const esc = escapeRe(target);
      if (new RegExp('`' + esc + '`|\\b' + esc + '\\b').test(node.body)) {
        addEdge(name, target, 'implicit', 1);
      }
    }
  }
  const edges = [...edgeMap.values()];

  // 入度/出度
  const degree = { in: new Map(), out: new Map() };
  for (const e of edges) {
    degree.out.set(e.src, (degree.out.get(e.src) || 0) + 1);
    degree.in.set(e.dst, (degree.in.get(e.dst) || 0) + 1);
  }

  // 连通分量（无向视角）+ 孤立节点
  const parent = new Map([...nodes.keys()].map((n) => [n, n]));
  const find = (x) => (parent.get(x) === x ? x : (parent.set(x, find(parent.get(x))), parent.get(x)));
  for (const e of edges) {
    const a = find(e.src), b = find(e.dst);
    if (a !== b) parent.set(a, b);
  }
  const compOf = new Map();
  for (const n of nodes.keys()) {
    const root = find(n);
    compOf.set(root, (compOf.get(root) || 0) + 1);
  }
  const components = [...compOf.values()].sort((a, b) => b - a);
  const isolated = [...nodes.keys()].filter((n) => !(degree.in.get(n) || degree.out.get(n))).length;

  // 简化 PageRank（20 轮迭代）
  const rank = new Map([...nodes.keys()].map((n) => [n, 1 / nodes.size]));
  const outTotal = new Map();
  for (const e of edges) outTotal.set(e.src, (outTotal.get(e.src) || 0) + e.weight);
  const d = 0.85;
  for (let i = 0; i < 20; i++) {
    const next = new Map([...nodes.keys()].map((n) => [n, (1 - d) / nodes.size]));
    for (const e of edges) {
      next.set(e.dst, next.get(e.dst) + (d * rank.get(e.src) * e.weight) / (outTotal.get(e.src) || 1));
    }
    for (const [k, v] of next) rank.set(k, v);
  }
  const hubs = [...rank.entries()]
    .map(([name, score]) => ({ name, hubRank: Math.round(score * 1e5) / 1e5, file: nodes.get(name).file }))
    .sort((a, b) => b.hubRank - a.hubRank)
    .slice(0, 15);

  // 领域簇（顶层目录聚合 + 簇内边数）
  const clusterOf = new Map();
  for (const [name, node] of nodes) {
    if (!clusterOf.has(node.domain)) clusterOf.set(node.domain, { domain: node.domain, nodes: 0, internalEdges: 0 });
    clusterOf.get(node.domain).nodes++;
  }
  for (const e of edges) {
    const c = clusterOf.get(nodes.get(e.src).domain);
    if (c && nodes.get(e.src).domain === nodes.get(e.dst).domain) c.internalEdges++;
  }
  const clusters = [...clusterOf.values()].sort((a, b) => b.internalEdges - a.internalEdges);

  const summary = {
    totalNodes: nodes.size,
    totalEdges: edges.length,
    explicitEdges: edges.filter((e) => e.kind === 'explicit').length,
    implicitEdges: edges.filter((e) => e.kind === 'implicit').length,
    isolatedNodes: isolated,
    components: components.length,
    largestComponent: components[0] || 0,
    edgeDensity: nodes.size > 1 ? +(edges.length / (nodes.size * (nodes.size - 1))).toFixed(6) : 0,
    generatedAt: new Date().toISOString(),
  };
  return {
    nodes: Object.fromEntries(
      [...nodes.entries()].map(([k, v]) => [k, {
        file: v.file,
        domain: v.domain,
        inDeg: degree.in.get(k) || 0,
        outDeg: degree.out.get(k) || 0,
        related: EXPLICIT_FIELDS.flatMap((f) => toArray(v.fm[f])),
      }])
    ),
    edges,
    summary,
    hubs,
    clusters,
  };
}

module.exports = { buildGraph, suggestRelated, EXPLICIT_FIELDS };
