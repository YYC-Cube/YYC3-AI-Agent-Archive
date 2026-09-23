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
  if (typeof v === 'string') {
    // inline 数组（`[a, b]`）剥离外层方括号（parseFrontmatter 为纯文本解析，不展开 YAML 流式序列）
    const s = v.trim().replace(/^\[|\]$/g, '');
    return s.split(',').map((x) => x.trim().replace(/^["'\[]|["'\]]$/g, '').trim()).filter(Boolean);
  }
  return [];
}

/** 转义正则特殊字符 */
function escapeRe(s) {
  return s.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
}

/**
 * 名称家族键：优先共享首两段（如 nemo-mbridge-*），否则共享末段（如 *-automation）
 * 仅当家族规模 >= 2 才构成配对信号（单词名/孤立家族不配对）
 */
function familyKeys(name) {
  const parts = name.split('-');
  const keys = [];
  if (parts.length >= 3) keys.push('p:' + parts.slice(0, 2).join('-'));
  if (parts.length >= 2) keys.push('s:' + parts[parts.length - 1]);
  return keys;
}

/** 语义停用词（英文功能词 + 平台通用词，中文字符按整体切分） */
const STOPWORDS = new Set([
  'the', 'a', 'an', 'and', 'or', 'of', 'for', 'to', 'in', 'on', 'with', 'your', 'you',
  'this', 'that', 'is', 'are', 'it', 'as', 'by', 'from', 'at', 'be', 'can', 'use',
  'using', 'how', 'skill', 'claude', 'code', 'tool', 'tools', 'into', 'when', 'create',
  'manage', 'help', 'based', 'get', 'data', 'search',
]);

/** description/category → 词元集合（长度 ≥2，去停用词；中文按连续段切词） */
function textTokens(...texts) {
  const out = new Set();
  for (const t of texts) {
    for (const w of String(t || '').toLowerCase().split(/[^a-z0-9\u4e00-\u9fff]+/)) {
      // 连续中文段按 2-gram 拆分增强匹配（中文无空格分界）
      if (/^[\u4e00-\u9fff]+$/.test(w)) {
        if (w.length === 1) continue;
        for (let i = 0; i + 2 <= w.length; i++) out.add(w.slice(i, i + 2));
        if (w.length <= 3) out.add(w);
      } else if (w.length >= 2 && !STOPWORDS.has(w)) {
        out.add(w);
      }
    }
  }
  return out;
}

/**
 * related_skills 候选生成（显式边补全）
 *
 * 三条信号线（前者优先，弱信号仅作兜底）：
 * 1. 提及信号（implicit 边推导置信度）：
 *   双向提及（A 提及 B 且 B 提及 A）  +3 —— 最强信号
 *   同领域（顶层目录相同）            +1
 *   每条单向提及                      +1
 * 2. 家族信号（孤立节点兜底）：
 *   同名称家族（共享首两段或末段，家族 >= 2 成员） +4
 *   双重家族命中                      +1
 *   同领域                            +1
 * 3. 语义信号（家族配对后仍无候选的孤立节点兜底）：
 *   description+category 词重叠数 = 置信度（≥4 才入候选，过滤低重叠噪声）
 *   同类（category 相同且非大类）    +1
 *
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

  // 名称家族索引（familyKey → 成员列表，仅保留 >= 2 成员的家族）
  const families = new Map();
  for (const n of nodeNames) {
    for (const k of familyKeys(n)) {
      if (!families.has(k)) families.set(k, []);
      families.get(k).push(n);
    }
  }
  for (const [k, arr] of families) if (arr.length < 2) families.delete(k);

  // 语义索引（惰性构建：仅当有孤立节点需要语义兜底时才分词全库）
  let semanticIndex = null; // name → {tokens, category}
  const buildSemanticIndex = () => {
    if (semanticIndex) return semanticIndex;
    semanticIndex = new Map();
    for (const [n, node] of Object.entries(g.nodes)) {
      semanticIndex.set(n, {
        tokens: textTokens(node.description, node.category),
        category: node.category,
      });
    }
    return semanticIndex;
  };

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
    // 家族信号：仅当无提及边时（孤立节点兜底，避免家族噪声稀释强信号）
    if (outs.size === 0) {
      const famSet = new Map(); // dst → 信号累计
      for (const k of familyKeys(name)) {
        for (const m of families.get(k) || []) {
          if (m === name || !nodeNames.has(m) || (declared.get(name) || new Set()).has(m)) continue;
          famSet.set(m, (famSet.get(m) || 0) + 1);
        }
      }
      for (const [dst, famHits] of famSet) {
        let conf = 4 + (famHits - 1); // 首段+末段双重命中加分
        const reasons = ['名称家族'];
        if (famHits >= 2) reasons.push('双重家族命中');
        if (g.nodes[dst].domain === node.domain) { conf += 1; reasons.push('同领域'); }
        cands.push({ name: dst, confidence: conf, reasons });
      }
      // 语义信号：家族配对后仍无候选 → description+category 词重叠兜底
      if (!cands.length) {
        const idx = buildSemanticIndex();
        const mine = idx.get(name);
        if (mine && mine.tokens.size >= 3) {
          for (const [dst, info] of idx) {
            if (dst === name || (declared.get(name) || new Set()).has(dst)) continue;
            let inter = 0;
            for (const t of mine.tokens) if (info.tokens.has(t)) inter++;
            if (inter < 4) continue; // 低重叠是噪声（同类模板词）
            const reasons = ['语义重叠 ' + inter];
            let conf = inter;
            // 同类加分仅对细分类目（大类 649 个 development-code 无区分度）
            if (info.category && info.category === mine.category && info.category !== 'development-code') {
              conf += 1; reasons.push('同类目');
            }
            cands.push({ name: dst, confidence: conf, reasons });
          }
        }
      }
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
        description: v.fm.description || '',
        category: v.fm.category || '',
      }])
    ),
    edges,
    summary,
    hubs,
    clusters,
  };
}

module.exports = { buildGraph, suggestRelated, EXPLICIT_FIELDS };
