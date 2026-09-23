#!/usr/bin/env node
/**
 * @file doctor.js
 * @description YYC³ 质量门禁 — 四检聚合（validate / dedup / score / registry）
 *
 * 从「信息输出」升级为「CI 可用的质量门禁」：
 *   1. validate  — frontmatter 完整性（errors > 0 → fail）
 *   2. dedup     — genuine 冗余组阈值（>3600 WARN 不阻断；>4000 → fail，防冗余回潮）
 *   3. score     — 五维评分基线对比（均分下降 >2 分 或 E 级新增 → fail，不回退策略）
 *   4. registry  — MCP Registry schema 校验（复用 scripts/validate-mcp-registry.mjs）
 *
 * 退出码：0 = 全绿；1 = 任一门禁阻断
 */
const { spawnSync } = require('child_process');
const path = require('path');

const ROOT = path.resolve(__dirname, '../../..');

// 门禁阈值（集中配置，便于演进）
const GATES = {
  dedup: { genuineWarn: 3600, genuineFail: 4000 },
  score: { avgDropMax: 2, minAvg: 78 }, // 均分下降 >2 或绝对值 <78 → fail
  // 固定基线优先（版本固化，报告更新不漂移）；缺失时回落最近报告
  baseline: 'docs/skill-score/baseline-v2.5.0.json',
  baselineFallback: 'docs/skill-score/score-report.json',
};

/**
 * 运行单个检查，捕获结构化结果（子模块自身 console 输出保留，便于审计）
 */
async function runCheck(name, fn) {
  const started = Date.now();
  try {
    const result = await fn();
    return { name, ok: true, durationMs: Date.now() - started, result };
  } catch (error) {
    return { name, ok: false, durationMs: Date.now() - started, error: error.message };
  }
}

async function checkValidate() {
  const { validateAll } = require('./skills-validator');
  const r = await validateAll({});
  return { gate: r.errors.length === 0, errors: r.errors.length, warnings: r.warnings.length, total: r.total };
}

async function checkDedup() {
  const { findDuplicates } = require('./skills-deduper');
  const r = await findDuplicates({});
  const genuine = r.classified.genuine.length;
  return {
    gate: genuine <= GATES.dedup.genuineFail,
    warn: genuine > GATES.dedup.genuineWarn,
    genuine,
    totalGroups: r.duplicates.length,
  };
}

async function checkScore() {
  const fs = require('fs').promises;
  const { scoreAll } = require('./skills-scorer');

  const { results, summary } = await scoreAll({});

  // 基线对比（固定基线优先，回落最近报告）
  let baseline = null;
  let baselineSource = null;
  for (const rel of [GATES.baseline, GATES.baselineFallback]) {
    try {
      const raw = await fs.readFile(path.join(ROOT, rel), 'utf-8');
      baseline = JSON.parse(raw).summary;
      baselineSource = rel;
      break;
    } catch {
      // 尝试下一个候选
    }
  }

  const failures = [];
  if (summary.average < GATES.score.minAvg) {
    failures.push(`均分 ${summary.average} < 最低线 ${GATES.score.minAvg}`);
  }
  if (baseline && baseline.average - summary.average > GATES.score.avgDropMax) {
    failures.push(`均分较基线 ${baseline.average} 下降 ${baseline.average - summary.average} 分（> ${GATES.score.avgDropMax}）`);
  }
  if (summary.byGrade.E > 0) {
    failures.push(`E 级技能 ${summary.byGrade.E} 个（基线为 0，不允许新增）`);
  }
  if (baseline && summary.byGrade.D > baseline.byGrade.D) {
    failures.push(`D 级 ${summary.byGrade.D} 个较基线 ${baseline.byGrade.D} 增长`);
  }

  return {
    gate: failures.length === 0,
    failures,
    average: summary.average,
    baselineAverage: baseline ? baseline.average : null,
    baselineSource,
    byGrade: summary.byGrade,
    total: summary.total,
    // 评分明细（负向测试与漂移排查用）
    worst: results.sort((a, b) => a.score - b.score).slice(0, 5).map((r) => ({ file: r.file, score: r.score, grade: r.grade })),
  };
}

function checkRegistry() {
  const script = path.join(ROOT, 'scripts/validate-mcp-registry.mjs');
  const r = spawnSync(process.execPath, [script], { encoding: 'utf-8' });
  return {
    gate: r.status === 0,
    output: (r.stdout || '').trim().split('\n').slice(-3).join('\n'),
    error: r.status !== 0 ? (r.stderr || r.stdout || 'unknown error') : null,
  };
}

/**
 * doctor 主入口：四检聚合，返回整体退出码
 */
async function doctorCommand(options = {}) {
  options = options || {};
  console.log('╔══════════════════════════════════════════════════╗');
  console.log('║  YYC³ Doctor — 质量门禁（validate/dedup/score/registry）  ║');
  console.log('╚══════════════════════════════════════════════════╝\n');

  const checks = [
    await runCheck('validate', checkValidate),
    await runCheck('dedup', checkDedup),
    await runCheck('score', checkScore),
    await runCheck('registry', checkRegistry),
  ];

  console.log('\n────────────── 门禁汇总 ──────────────');
  let failed = false;
  for (const c of checks) {
    const r = c.result || {};
    let status = '✅ PASS';
    if (!c.ok) { status = '💥 CRASH'; failed = true; }
    else if (r.gate === false) { status = '🔴 FAIL'; failed = true; }
    else if (r.warn) { status = '🟡 WARN'; }
    console.log(`${status}  ${c.name.padEnd(9)} (${(c.durationMs / 1000).toFixed(1)}s)`);

    if (c.name === 'score' && r.failures) {
      for (const f of r.failures) console.log(`         └─ ${f}`);
    }
  }

  console.log('──────────────────────────────────────');
  if (failed) {
    console.log('🔴 Doctor: 存在门禁阻断项，禁止合并/发布\n');
    if (options.json) console.log(JSON.stringify({ ok: false, checks }, null, 2));
    process.exit(1);
  }
  console.log('🟢 Doctor: 全部门禁通过\n');
  if (options.json) console.log(JSON.stringify({ ok: true, checks }, null, 2));
  return { ok: true, checks };
}

module.exports = { doctorCommand, GATES, runCheck };
