/**
 * @file skills-mcp-export.test.js
 * @description Task G1 — MCP Registry server.json 导出引擎测试（≥10 用例，含边界）
 */
const path = require('path');
const os = require('os');
const fs2 = require('fs').promises;
const {
  exportMcp,
  skillToServer,
  buildRegistryOutput,
  NAMESPACE,
  SCHEMA_URL,
} = require('../lib/skills-mcp-export');

const CWD = process.cwd();

// ─── 纯函数单元测试 ───

describe('skillToServer 映射', () => {
  test('T1 完整 frontmatter → 标准 server.json', () => {
    const s = skillToServer(
      {
        name: 'My Skill',
        title: '我的技能',
        description: 'Line1\nLine2',
        version: '1.2.3',
        category: 'dev',
        license: 'MIT',
      },
      path.join(CWD, 'skills-hub/x/SKILL.md')
    );
    expect(s.$schema).toBe(SCHEMA_URL);
    expect(s.name).toBe(`${NAMESPACE}/my-skill`);
    expect(s.title).toBe('我的技能');
    expect(s.description).toBe('Line1 Line2');
    expect(s.version).toBe('1.2.3');
    expect(s._meta[`${NAMESPACE}/category`]).toBe('dev');
    expect(s._meta[`${NAMESPACE}/license`]).toBe('MIT');
    expect(s._meta[`${NAMESPACE}/source`]).toContain('SKILL.md');
  });

  test('T2 空 frontmatter → 全缺省兜底', () => {
    const s = skillToServer({}, '/tmp/x/SKILL.md');
    expect(s.name).toBe(`${NAMESPACE}/unnamed`);
    expect(s.title).toBe('Untitled skill');
    expect(s.version).toBe('0.0.0');
    expect(s._meta[`${NAMESPACE}/category`]).toBe('uncategorized');
  });

  test('T3 超长描述 → 折叠并截断至 500 字符', () => {
    const long = Array.from({ length: 100 }, (_, i) => `word${i} `).join('');
    const s = skillToServer({ name: 'long', description: long }, '/t/SKILL.md');
    expect(s.description.length).toBeLessThanOrEqual(500);
  });

  test('T4 非法版本号 → 兜底 0.0.0', () => {
    const s = skillToServer({ name: 'a', version: 'abc' }, '/t/SKILL.md');
    expect(s.version).toBe('0.0.0');
  });

  test('T5 特殊字符 name → slug 化', () => {
    const s = skillToServer({ name: 'My__Skill!! 你好' }, '/t/SKILL.md');
    expect(s.name).toBe(`${NAMESPACE}/my-skill`);
  });

  test('T6 缺 license → _meta 无 license 键', () => {
    const s = skillToServer({ name: 'a' }, '/t/SKILL.md');
    expect(s._meta[`${NAMESPACE}/license`]).toBeUndefined();
  });
});

// ─── 集成：buildRegistryOutput + exportMcp ───

describe('buildRegistryOutput（真实 skills-hub）', () => {
  test(
    'T7 全量扫描 → servers 均唯一且格式合法',
    async () => {
      const { servers, total } = await buildRegistryOutput();
      expect(total).toBeGreaterThan(500);
      const names = servers.map((s) => s.name);
      expect(new Set(names).size).toBe(names.length); // name 全局唯一
      for (const s of servers) {
        expect(s.$schema).toBe(SCHEMA_URL);
        expect(s.name).toMatch(/^io\.github\.yyc-cube\/[a-z0-9-]+$/);
        expect(typeof s.description).toBe('string');
        expect(s.description.length).toBeGreaterThan(0);
        expect(s.version).toMatch(/^\d+\.\d+\.\d+$/);
      }
    },
    60_000
  );
});

describe('exportMcp 导出落盘', () => {
  test(
    'T8 写出 registry.json + 逐 slug 文件，数量一致',
    async () => {
      const repoRoot = path.resolve(__dirname, '../../..');
      const outDir = path.join(repoRoot, 'public/registry');
      const { total, exported, outDir: got } = await exportMcp({ out: 'public/registry' });
      expect(got).toBe(outDir);
      expect(exported).toBe(total);
      const registry = JSON.parse(await fs2.readFile(path.join(outDir, 'registry.json'), 'utf-8'));
      expect(registry.servers).toHaveLength(exported);
      expect(registry.$schema).toBe(SCHEMA_URL);
      const files = await fs2.readdir(outDir);
      // + registry.json + index.html（Pages 浏览页，非导出产物）
      expect(files.length).toBe(exported + 2);
    },
    60_000
  );

  test(
    'T9 自定义 out 目录生效',
    async () => {
      const tmp = await fs2.mkdtemp(path.join(os.tmpdir(), 'mcp-exp-'));
      const { exported, outDir } = await exportMcp({ out: tmp });
      expect(outDir).toBe(tmp);
      const files = await fs2.readdir(tmp);
      expect(files).toContain('registry.json');
      expect(files.length).toBe(exported + 1);
      await fs2.rm(tmp, { recursive: true, force: true });
    },
    60_000
  );
});

test('T10 常量符合官方规范', () => {
  expect(NAMESPACE).toBe('io.github.yyc-cube');
  expect(SCHEMA_URL).toBe(
    'https://static.modelcontextprotocol.io/schemas/2025-12-11/server.schema.json'
  );
});
