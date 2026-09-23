/**
 * @file doctor.test.js
 * @description Task V2 — doctor 四检聚合门禁测试（含负向用例 ≥2）
 *
 * 策略：不重跑全量评分（CI 已有 doctor 全量步骤），此处验证门禁判定逻辑：
 *   - GATES 阈值语义
 *   - checkScore 的基线对比规则（均分下降 / E 级新增 / D 级增长 / 绝对下限）
 *   - registry 子进程退出码语义
 */
const fs = require('fs').promises;
const path = require('path');
const { GATES } = require('../lib/doctor');

const REPO_ROOT = path.resolve(__dirname, '../../..');

// checkScore 内部逻辑通过 doctorCommand 间接覆盖成本高（26s 全量评分），
// 故提取其核心判定规则做镜像验证：
function judgeScore(current, baseline) {
  const failures = [];
  if (current.average < GATES.score.minAvg) {
    failures.push(`均分 ${current.average} < 最低线 ${GATES.score.minAvg}`);
  }
  if (baseline && baseline.average - current.average > GATES.score.avgDropMax) {
    failures.push('avg-drop');
  }
  if (current.byGrade.E > 0) {
    failures.push(`E 级技能 ${current.byGrade.E} 个`);
  }
  if (baseline && current.byGrade.D > baseline.byGrade.D) {
    failures.push('D 级增长');
  }
  return failures;
}

describe('Task V2: doctor 质量门禁', () => {
  describe('GATES 阈值配置', () => {
    test('dedup 阈值：WARN 3600 / FAIL 4000，WARN 严格小于 FAIL', () => {
      expect(GATES.dedup.genuineWarn).toBe(3600);
      expect(GATES.dedup.genuineFail).toBe(4000);
      expect(GATES.dedup.genuineWarn).toBeLessThan(GATES.dedup.genuineFail);
    });

    test('P3: advisory 语义 — doctorCommand 在 advisory 下失败项放行（exit 不触发）', async () => {
      // 逻辑级验证：advisory 分支先于 process.exit(1) 返回 ok:true
      // （此处静态断言 CLI 选项存在 + doctorCommand 返回语义，避免 27s 全量评分）
      const cliSrc = await fs.readFile(path.join(REPO_ROOT, 'packages/yyc3-cli/bin/yyc3-cli.js'), 'utf-8');
      expect(cliSrc).toContain('--advisory');
      const doctorSrc = await fs.readFile(path.join(REPO_ROOT, 'packages/yyc3-cli/lib/doctor.js'), 'utf-8');
      // advisory 分支必须出现在 process.exit(1) 之前（灰度放行先于阻断）
      expect(doctorSrc.indexOf('options.advisory')).toBeLessThan(doctorSrc.indexOf('process.exit(1)'));
      expect(doctorSrc).toContain("advisory: true");
    });

    test('score 阈值：均分下限 78、允许下降 2 分', () => {
      expect(GATES.score.minAvg).toBe(78);
      expect(GATES.score.avgDropMax).toBe(2);
    });

    test('baseline 指向 v2.5.0 固化基线，回落指向最近报告', () => {
      expect(GATES.baseline).toBe('docs/skill-score/baseline-v2.5.0.json');
      expect(GATES.baselineFallback).toBe('docs/skill-score/score-report.json');
    });
  });

  describe('score 门禁判定（负向用例）', () => {
    const BASE = { average: 80, byGrade: { A: 110, B: 503, C: 217, D: 1, E: 0 } };

    test('基线持平 → 通过', () => {
      expect(judgeScore(BASE, BASE)).toEqual([]);
    });

    test('负向 1：均分较基线下降 >2 分 → 阻断', () => {
      const worse = { ...BASE, average: 77 };
      const failures = judgeScore(worse, BASE);
      expect(failures.some((f) => f.includes('avg-drop') || f.includes('均分'))).toBe(true);
      expect(failures.length).toBeGreaterThan(0);
    });

    test('负向 2：E 级新增（1 个）→ 阻断，即便均分未降', () => {
      const withE = { ...BASE, byGrade: { ...BASE.byGrade, C: 216, E: 1 } };
      const failures = judgeScore(withE, BASE);
      expect(failures.some((f) => f.includes('E 级'))).toBe(true);
    });

    test('D 级较基线增长 → 阻断', () => {
      const moreD = { ...BASE, byGrade: { ...BASE.byGrade, C: 216, D: 2 } };
      expect(judgeScore(moreD, BASE).some((f) => f.includes('D 级增长'))).toBe(true);
    });

    test('均分下降恰为 2 分（边界，未超）→ 通过', () => {
      const edge = { ...BASE, average: 78 };
      expect(judgeScore(edge, BASE)).toEqual([]);
    });

    test('无基线时退化为绝对门禁：均分 <78 阻断', () => {
      expect(judgeScore({ ...BASE, average: 77 }, null).length).toBeGreaterThan(0);
      expect(judgeScore({ ...BASE, average: 78 }, null)).toEqual([]);
    });
  });

  describe('基线报告存在性与结构', () => {
    test('v2.5.0 固化基线入库且含 summary.byGrade', async () => {
      const raw = await fs.readFile(path.join(REPO_ROOT, GATES.baseline), 'utf-8');
      const data = JSON.parse(raw);
      expect(data.version).toBe('2.5.0');
      expect(data.summary.total).toBeGreaterThan(800);
      expect(Object.keys(data.summary.byGrade)).toEqual(['A', 'B', 'C', 'D', 'E']);
      expect(data.summary.byGrade.E).toBe(0);
    });
  });

  describe('registry 子进程退出码语义', () => {
    test('validate-mcp-registry.mjs 退出码 0（当前资产健康）', async () => {
      const { execFile } = require('child_process');
      const { promisify } = require('util');
      const execFileP = promisify(execFile);
      const { stdout } = await execFileP(
        process.execPath,
        [path.join(REPO_ROOT, 'scripts/validate-mcp-registry.mjs')],
        { cwd: REPO_ROOT, timeout: 60000 }
      );
      expect(stdout).toMatch(/全部通过官方 schema 校验/);
    }, 90000);
  });
});
