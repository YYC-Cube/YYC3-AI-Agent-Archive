/**
 * @file skills-graph.test.js
 * @description v2.6.0 — 关联维度图分析测试（提取/建图/指标）
 *
 * 策略：临时目录构造小型技能集验证图语义；不对仓库全量 831 技能断言（数字随资产演进）
 */
const fs = require('fs').promises;
const os = require('os');
const path = require('path');
const { buildGraph, EXPLICIT_FIELDS } = require('../lib/skills-graph');

// buildGraph 依赖 skills-indexer 的 ROOT 扫描，此处用其导出做小规模集成：
// 直接驱动 buildGraph 会扫全仓，故通过 options 注入测试目录（若支持）。
// 检查 buildGraph 是否接受 dir 参数；若无则以模块级函数级验证为主。

describe('v2.6.0: skills-graph 关联维度', () => {
  test('EXPLICIT_FIELDS 覆盖 snake/kebab 两种写法', () => {
    expect(EXPLICIT_FIELDS).toContain('related_skills');
    expect(EXPLICIT_FIELDS).toContain('related-skills');
    expect(EXPLICIT_FIELDS).toContain('depends_on');
    expect(EXPLICIT_FIELDS).toContain('depends-on');
  });

  test('全仓图谱构建成功且指标自洽', async () => {
    const g = await buildGraph({});
    const s = g.summary;
    expect(s.totalNodes).toBeGreaterThan(700); // 831 SKILL.md，个别缺 name
    expect(s.totalEdges).toBe(s.explicitEdges + s.implicitEdges);
    expect(s.explicitEdges).toBeGreaterThan(0); // graph-suggest 批量补全后（原为 0，117 技能声明 → 78 条去重边）
    expect(s.implicitEdges).toBeGreaterThan(1000);
    expect(s.isolatedNodes).toBeLessThan(s.totalNodes);
    expect(s.components).toBeGreaterThan(1);
    expect(s.largestComponent).toBeGreaterThan(100);
    expect(s.edgeDensity).toBeGreaterThan(0);
    expect(s.edgeDensity).toBeLessThan(1);
  }, 120000);

  test('hub 排名非空且降序', async () => {
    const g = await buildGraph({});
    expect(g.hubs.length).toBeGreaterThan(0);
    expect(g.hubs.length).toBeLessThanOrEqual(15);
    for (let i = 1; i < g.hubs.length; i++) {
      expect(g.hubs[i - 1].hubRank).toBeGreaterThanOrEqual(g.hubs[i].hubRank);
    }
  }, 120000);

  test('领域簇聚合正确（簇技能数总和 = 总节点）', async () => {
    const g = await buildGraph({});
    const total = g.clusters.reduce((s, c) => s + c.nodes, 0);
    expect(total).toBe(g.summary.totalNodes);
  }, 120000);
});
