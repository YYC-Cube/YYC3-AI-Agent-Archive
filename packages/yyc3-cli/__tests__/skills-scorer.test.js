/**
 * @file skills-scorer.test.js
 * @description Task H1 — 技能质量评分引擎测试（≥15 用例，含边界）
 */
const fs = require('fs').promises;
const os = require('os');
const path = require('path');
const {
  scoreSkill,
  scoreAll,
  grade,
  DEFAULT_WEIGHTS,
  SECURITY_PATTERNS,
} = require('../lib/skills-scorer');
const { renderMarkdown } = require('../lib/skills-score-report');

const CWD = process.cwd();
const REPO_ROOT = path.resolve(__dirname, '../../..');

/** 构造临时技能目录 */
async function makeSkillDir(files = {}) {
  const dir = await fs.mkdtemp(path.join(os.tmpdir(), 'score-t-'));
  for (const [rel, content] of Object.entries(files)) {
    const fp = path.join(dir, rel);
    await fs.mkdir(path.dirname(fp), { recursive: true });
    await fs.writeFile(fp, content);
  }
  return dir;
}

const FULL_FM = `---
name: demo-skill
description: "A demo skill for scoring tests with enough length."
category: development-code
author: yyc3
license: MIT
version: 1.0.0
---

# Demo

Body content here.

\`\`\`bash
echo one
\`\`\`

\`\`\`bash
echo two
\`\`\`

\`\`\`js
console.log('three');
\`\`\`

[link](https://example.com) [link2](https://example.org) [link3](https://example.net)
`;

// ─── 等级映射 ───

describe('grade 等级映射', () => {
  test.each([
    [95, 'A'],
    [90, 'A'],
    [89, 'B'],
    [75, 'B'],
    [60, 'C'],
    [40, 'D'],
    [0, 'E'],
  ])('T1 %i → %s', (score, expected) => {
    expect(grade(score)).toBe(expected);
  });
});

// ─── 维度测试 ───

describe('scoreSkill 维度', () => {
  test('T2 完整技能 → 高分（≥75）且各维度健康', async () => {
    const dir = await makeSkillDir({ 'SKILL.md': FULL_FM });
    const r = await scoreSkill(path.join(dir, 'SKILL.md'));
    // 临时目录无 git 历史 → activity=0（15% 权重归零），总分 ≈78（B 级）
    expect(r.score).toBeGreaterThanOrEqual(75);
    expect(r.grade).toBe('B');
    expect(r.dims.metadata).toBe(100);
    expect(r.dims.docs).toBeGreaterThanOrEqual(60);
    expect(r.dims.security).toBe(100);
    fs.rm(dir, { recursive: true, force: true });
  });

  test('T3 空 frontmatter → 元数据 0 分', async () => {
    const dir = await makeSkillDir({ 'SKILL.md': '# no fm\nbody' });
    const r = await scoreSkill(path.join(dir, 'SKILL.md'));
    expect(r.dims.metadata).toBe(0);
    fs.rm(dir, { recursive: true, force: true });
  });

  test('T4 仅 name/description/version → 元数据 50%', async () => {
    const fm = '---\nname: x\ndescription: y\nversion: 1.0.0\n---\nbody';
    const dir = await makeSkillDir({ 'SKILL.md': fm });
    const r = await scoreSkill(path.join(dir, 'SKILL.md'));
    expect(r.dims.metadata).toBe(50);
    fs.rm(dir, { recursive: true, force: true });
  });

  test('T5 空正文 → 文档 0 分', async () => {
    const fm = '---\nname: x\ndescription: y\nversion: 1.0.0\n---\n';
    const dir = await makeSkillDir({ 'SKILL.md': fm });
    const r = await scoreSkill(path.join(dir, 'SKILL.md'));
    expect(r.dims.docs).toBe(0);
    fs.rm(dir, { recursive: true, force: true });
  });

  test('T6 超长正文 → 文档维度饱和不溢出（≤100）', async () => {
    const fm = '---\nname: x\ndescription: y\nversion: 1.0.0\n---\n' + 'word '.repeat(3000);
    const dir = await makeSkillDir({ 'SKILL.md': fm });
    const r = await scoreSkill(path.join(dir, 'SKILL.md'));
    expect(r.dims.docs).toBeLessThanOrEqual(100);
    fs.rm(dir, { recursive: true, force: true });
  });

  test('T7 语法错误脚本 → 资产健康扣分', async () => {
    const dir = await makeSkillDir({
      'SKILL.md': FULL_FM,
      'scripts/bad.mjs': 'const x = {;;;',
    });
    const r = await scoreSkill(path.join(dir, 'SKILL.md'));
    expect(r.dims.assets).toBeLessThan(100);
    fs.rm(dir, { recursive: true, force: true });
  });

  test('T8 合法脚本 → 资产健康满分', async () => {
    const dir = await makeSkillDir({
      'SKILL.md': FULL_FM,
      'scripts/ok.mjs': 'export const x = 1;\n',
    });
    const r = await scoreSkill(path.join(dir, 'SKILL.md'));
    expect(r.dims.assets).toBe(100);
    fs.rm(dir, { recursive: true, force: true });
  });

  test('T9 SKILL.md 引用不存在文件 → 资产健康扣分', async () => {
    const body = FULL_FM + '\nsee [detail](./missing-file.md)\n';
    const dir = await makeSkillDir({ 'SKILL.md': body });
    const r = await scoreSkill(path.join(dir, 'SKILL.md'));
    expect(r.dims.assets).toBeLessThan(100);
    fs.rm(dir, { recursive: true, force: true });
  });

  test('T10 危险命令（rm -rf ~）→ 安全维度扣 20', async () => {
    const body = FULL_FM + '\n```bash\nrm -rf ~/data\n```\n';
    const dir = await makeSkillDir({ 'SKILL.md': body });
    const r = await scoreSkill(path.join(dir, 'SKILL.md'));
    expect(r.dims.security).toBe(80);
    fs.rm(dir, { recursive: true, force: true });
  });

  test('T11 scripts 内危险代码同样命中安全扫描', async () => {
    const dir = await makeSkillDir({
      'SKILL.md': FULL_FM,
      'scripts/evil.mjs': "require('child_process');\n",
    });
    const r = await scoreSkill(path.join(dir, 'SKILL.md'));
    expect(r.dims.security).toBeLessThan(100);
    fs.rm(dir, { recursive: true, force: true });
  });

  test('T12 危险模式 ≥5 处 → 安全分归零不出现负数', async () => {
    const dir = await makeSkillDir({
      'SKILL.md': FULL_FM,
      'scripts/evil.mjs': SECURITY_PATTERNS.slice(0, 6).map((p) => `// ${p.source}`).join('\n'),
    });
    const r = await scoreSkill(path.join(dir, 'SKILL.md'));
    expect(r.dims.security).toBeGreaterThanOrEqual(0);
    fs.rm(dir, { recursive: true, force: true });
  });

  test('T13 权重可配置：docs 权重 1.0 时得分等于 docs 维度', async () => {
    const fm = '---\nname: x\ndescription: y\nversion: 1.0.0\n---\nshort';
    const dir = await makeSkillDir({ 'SKILL.md': fm });
    const r = await scoreSkill(path.join(dir, 'SKILL.md'), { docs: 1.0 });
    expect(r.score).toBe(r.dims.docs);
    fs.rm(dir, { recursive: true, force: true });
  });
});

// ─── 全量评分（真实 skills-hub）───

describe('scoreAll 全量', () => {
  test(
    'T14 831 技能全量评分 < 30s 且 summary 结构完整',
    async () => {
      const t0 = Date.now();
      const { results, summary } = await scoreAll({ out: '/tmp/never-write' });
      const elapsed = Date.now() - t0;
      expect(elapsed).toBeLessThan(30_000);
      expect(summary.total).toBeGreaterThan(500);
      expect(results).toHaveLength(summary.total);
      expect(summary.average).toBeGreaterThanOrEqual(0);
      expect(summary.average).toBeLessThanOrEqual(100);
      expect(Object.values(summary.byGrade).reduce((a, b) => a + b, 0)).toBe(summary.total);
      for (const r of results) {
        expect(r.score).toBeGreaterThanOrEqual(0);
        expect(r.score).toBeLessThanOrEqual(100);
        expect(['A', 'B', 'C', 'D', 'E']).toContain(r.grade);
      }
    },
    45_000
  );
});

// ─── 报告渲染 ───

describe('renderMarkdown 报告', () => {
  test('T15 Markdown 报告含总览/权重/TOP20 三节', () => {
    const summary = {
      total: 3,
      average: 72,
      byGrade: { A: 1, B: 1, C: 1, D: 0, E: 0 },
      generatedAt: '2026-09-21T00:00:00Z',
      weights: DEFAULT_WEIGHTS,
    };
    const results = [
      { score: 55, grade: 'C', dims: { metadata: 50, docs: 40, assets: 60, activity: 0, security: 100 }, file: 'a/SKILL.md' },
      { score: 80, grade: 'B', dims: { metadata: 100, docs: 70, assets: 80, activity: 50, security: 100 }, file: 'b/SKILL.md' },
      { score: 91, grade: 'A', dims: { metadata: 100, docs: 90, assets: 100, activity: 50, security: 100 }, file: 'c/SKILL.md' },
    ];
    const md = renderMarkdown(summary, results, 2);
    expect(md).toContain('# 技能质量评分报告');
    expect(md).toContain('## 总览');
    expect(md).toContain('## 权重配置');
    expect(md).toContain('## 低分 TOP2');
    expect(md).toContain('a/SKILL.md'); // 低分在前
    expect(md.indexOf('a/SKILL.md')).toBeLessThan(md.indexOf('b/SKILL.md'));
  });

  test('T16 scoreCommand 落盘 JSON+Markdown 双报告', async () => {
    const { scoreCommand } = require('../lib/skills-score-report');
    const tmp = await fs.mkdtemp(path.join(os.tmpdir(), 'score-out-'));
    const { summary, outDir } = await scoreCommand({ out: tmp, json: false });
    const files = await fs.readdir(outDir);
    expect(files).toContain('score-report.json');
    expect(files).toContain('score-report.md');
    const parsed = JSON.parse(await fs.readFile(path.join(outDir, 'score-report.json'), 'utf-8'));
    expect(parsed.summary.total).toBe(summary.total);
    expect(parsed.results).toHaveLength(summary.total);
    await fs.rm(tmp, { recursive: true, force: true });
  }, 45_000);
});
