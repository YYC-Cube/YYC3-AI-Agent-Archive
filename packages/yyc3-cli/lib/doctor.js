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
 * Example 构建（vite-react-zh-cn）— 本地即可捕获 off-by-one 链接 / i18n API 漂移
 * 前置：packages/yyc3-i18n 需已构建（dist/ 存在）；依赖独立 node_modules
 */
function checkExample() {
  const exampleDir = path.join(ROOT, 'packages/yyc3-i18n/examples/vite-react-zh-cn');
  const dist = path.join(ROOT, 'packages/yyc3-i18n/dist/index.js');
  if (!require('fs').existsSync(dist)) {
    return { gate: false, skipped: true, error: `i18n dist 未构建（${path.relative(ROOT, dist)}）— 先运行 pnpm build` };
  }
  const run = (cmd, args, opts = {}) => spawnSync(cmd, args, { cwd: exampleDir, encoding: 'utf-8', timeout: 300_000, ...opts });
  // install 独立于 workspace lockfile（--ignore-workspace）
  const inst = run('pnpm', ['install', '--frozen-lockfile', '--ignore-workspace', '--prefer-offline']);
  if (inst.status !== 0) {
    return { gate: false, error: 'install failed:\n' + (inst.stderr || inst.stdout || '').split('\n').slice(-5).join('\n') };
  }
  const build = run('pnpm', ['run', 'build']);
  const tail = (build.stdout || '').trim().split('\n').slice(-3).join('\n');
  return {
    gate: build.status === 0,
    output: tail,
    error: build.status !== 0 ? (build.stderr || tail || 'unknown error') : null,
  };
}

/**
 * CI Job Summary 可视化 — 检测 GITHUB_STEP_SUMMARY 时自动追加 Markdown 报告
 */
function writeJobSummary(checks, failed) {
  const summaryPath = process.env.GITHUB_STEP_SUMMARY;
  if (!summaryPath) return;
  const fs = require('fs');
  const score = checks.find((c) => c.name === 'score');
  const sr = (score && score.result) || {};
  const lines = ['## 🩺 YYC³ Doctor 质量门禁', ''];
  lines.push(`**结论**: ${failed ? '🔴 存在阻断项' : '🟢 全部通过'}`, '');
  lines.push('| 检查 | 状态 | 耗时 |', '|------|------|------|');
  for (const c of checks) {
    const r = c.result || {};
    const st = !c.ok ? '💥 CRASH' : r.gate === false ? '🔴 FAIL' : r.warn ? '🟡 WARN' : '✅ PASS';
    lines.push(`| ${c.name} | ${st} | ${(c.durationMs / 1000).toFixed(1)}s |`);
  }
  if (sr.average !== undefined) {
    lines.push('', `**评分**: 均分 **${sr.average}**（基线 ${sr.baselineAverage ?? '—'} @ ${sr.baselineSource ? path.basename(sr.baselineSource) : '无'}）`, '');
    lines.push(`等级分布: ${Object.entries(sr.byGrade || {}).map(([g, n]) => `${g}:${n}`).join(' / ')}`);
  }
  if (sr.failures && sr.failures.length) {
    lines.push('', '**阻断明细**:', ...(sr.failures.map((f) => `- ${f}`)));
  }
  if (sr.worst && sr.worst.length) {
    lines.push('', '<details><summary>低分 TOP5（治理参考）</summary>', '', '| 文件 | 分数 | 等级 |', '|------|------|------|');
    for (const w of sr.worst) lines.push(`| ${w.file} | ${w.score} | ${w.grade} |`);
    lines.push('', '</details>');
  }
  fs.appendFileSync(summaryPath, lines.join('\n') + '\n');
}

/**
 * doctor 主入口：五检聚合，返回整体退出码
 */
async function doctorCommand(options = {}) {
  options = options || {};
  console.log('╔══════════════════════════════════════════════════╗');
  console.log('║  YYC³ Doctor — 质量门禁（validate/dedup/score/registry/example）  ║');
  console.log('╚══════════════════════════════════════════════════╝\n');

  const checks = [
    await runCheck('validate', checkValidate),
    await runCheck('dedup', checkDedup),
    await runCheck('score', checkScore),
    await runCheck('registry', checkRegistry),
  ];
  // example 检默认开启（--skip-example 跳过，CI 已单独覆盖时可用）
  if (!options.skipExample) {
    checks.push(await runCheck('example', () => checkExample()));
  }

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
    // advisory 模式：新检查灰度期仅报告不阻断（exit 0），供 CI 渐进接入
    if (options.advisory) {
      console.log('🟡 Doctor (advisory): 存在问题项但按建议模式放行 — 用于新检查灰度验证，勿长期开启\n');
      writeJobSummary(checks, true);
      if (options.json) console.log(JSON.stringify({ ok: true, advisory: true, checks }, null, 2));
      return { ok: true, advisory: true, checks };
    }
    console.log('🔴 Doctor: 存在门禁阻断项，禁止合并/发布\n');
    writeJobSummary(checks, true);
    if (options.json) console.log(JSON.stringify({ ok: false, checks }, null, 2));
    process.exit(1);
  }
  console.log('🟢 Doctor: 全部门禁通过\n');
  writeJobSummary(checks, false);
  if (options.json) console.log(JSON.stringify({ ok: true, checks }, null, 2));
  return { ok: true, checks };
}

module.exports = { doctorCommand, GATES, runCheck };
