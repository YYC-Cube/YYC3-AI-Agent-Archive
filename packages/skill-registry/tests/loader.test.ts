/**
 * SkillLoader 文件系统加载器测试 — 使用临时目录构建真实 SKILL.md 结构
 */
import { describe, it, expect, beforeAll, afterAll } from 'vitest';
import { mkdtempSync, mkdirSync, writeFileSync, rmSync } from 'fs';
import { join } from 'path';
import { tmpdir } from 'os';
import { SkillRegistry } from '../src/registry.js';
import { SkillLoader } from '../src/loader.js';

let root: string;

beforeAll(() => {
  root = mkdtempSync(join(tmpdir(), 'yyc3-skills-'));
});

afterAll(() => {
  rmSync(root, { recursive: true, force: true });
});

function writeSkill(dir: string, frontmatter: string): void {
  mkdirSync(join(root, dir), { recursive: true });
  writeFileSync(join(root, dir, 'SKILL.md'), `---\n${frontmatter}\n---\n\n# Skill\n`);
}

describe('SkillLoader', () => {
  it('加载简单 SKILL.md', () => {
    writeSkill('simple-skill', 'name: simple-skill\ndescription: 简单技能\nversion: 1.0.0');
    const registry = new SkillRegistry();
    new SkillLoader(registry, { rootDir: root, recursive: true, maxDepth: 3 }).load();

    const skill = registry.get('simple-skill');
    expect(skill).toBeDefined();
    expect(skill!.name).toBe('simple-skill');
    expect(skill!.description).toBe('简单技能');
    expect(skill!.version).toBe('1.0.0');
    expect(skill!.status).toBe('active');
  });

  it('正确解析多行 description（真实仓库格式）', () => {
    writeSkill(
      'multiline-skill',
      'name: multiline-skill\nversion: 2.1.0\ndescription: >\n  AI 论文速读工具，\n  支持三档深度模式。\nallowed-tools: [read_file, execute_command]'
    );

    const registry = new SkillRegistry();
    new SkillLoader(registry, { rootDir: root, recursive: true, maxDepth: 3 }).load();

    const skill = registry.get('multiline-skill');
    expect(skill).toBeDefined();
    expect(skill!.description).toBe('AI 论文速读工具， 支持三档深度模式。');
  });

  it('通过 category 映射领域', () => {
    writeSkill('cat-skill', 'name: cat-skill\ncategory: business-productivity');
    const registry = new SkillRegistry();
    new SkillLoader(registry, { rootDir: root, recursive: true, maxDepth: 3 }).load();

    const skill = registry.get('cat-skill');
    expect(skill!.domain).toBe('marketplace');
  });

  it('通过 domainMap 路径映射领域', () => {
    mkdirSync(join(root, 'glm-skills/glm-ocr-demo'), { recursive: true });
    writeFileSync(join(root, 'glm-skills/glm-ocr-demo/SKILL.md'), '---\nname: glm-ocr-demo\n---\n');

    const registry = new SkillRegistry();
    new SkillLoader(registry, {
      rootDir: root,
      recursive: true,
      maxDepth: 3,
      domainMap: { 'glm-skills': 'glm-ocr' },
    }).load();

    expect(registry.get('glm-ocr-demo')!.domain).toBe('glm-ocr');
  });

  it('目录名推断 GLM 领域', () => {
    writeSkill('glm-stock-analysis', 'name: glm-stock-analysis');
    const registry = new SkillRegistry();
    new SkillLoader(registry, { rootDir: root, recursive: true, maxDepth: 3 }).load();

    expect(registry.get('glm-stock-analysis')!.domain).toBe('glm-finance');
  });

  it('跳过隐藏目录与 node_modules', () => {
    writeSkill('.hidden-skill', 'name: hidden-skill');
    writeSkill('node_modules/pkg-skill', 'name: pkg-skill');
    mkdirSync(join(root, 'visible'), { recursive: true });

    const registry = new SkillRegistry();
    new SkillLoader(registry, { rootDir: root, recursive: true, maxDepth: 3 }).load();

    expect(registry.has('hidden-skill')).toBe(false);
    expect(registry.has('pkg-skill')).toBe(false);
  });

  it('rootDir 不存在时返回空数组且不抛错', () => {
    const registry = new SkillRegistry();
    const loaded = new SkillLoader(registry, {
      rootDir: join(root, 'not-exist'),
      recursive: true,
    }).load();
    expect(loaded).toEqual([]);
  });

  it('含 SKILL.md 的目录不再递归子目录', () => {
    writeSkill('parent-skill', 'name: parent-skill');
    writeSkill('parent-skill/nested-skill', 'name: nested-skill');

    const registry = new SkillRegistry();
    new SkillLoader(registry, { rootDir: root, recursive: true, maxDepth: 5 }).load();

    expect(registry.has('parent-skill')).toBe(true);
    expect(registry.has('nested-skill')).toBe(false);
  });

  it('source 记录相对路径', () => {
    writeSkill('src-skill', 'name: src-skill');
    const registry = new SkillRegistry();
    new SkillLoader(registry, { rootDir: root, recursive: true, maxDepth: 3 }).load();

    expect(registry.get('src-skill')!.source).toBe('src-skill');
  });
});
