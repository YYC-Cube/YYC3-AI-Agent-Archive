/**
 * @description YYC³ Skill 文件系统加载器
 * @module @yyc3/skill-registry/loader
 *
 * 从文件系统自动扫描、解析、注册 Skill。
 * 支持 Markdown SKILL.md frontmatter 和 JSON 清单。
 */

import { readdirSync, readFileSync, statSync, existsSync } from 'fs';
import { join, extname, basename, dirname } from 'path';
import type { UnifiedSkill, SkillDomain, SkillType, SkillRuntime } from './types.js';
import type { SkillRegistry } from './registry.js';

// ==================== Skill 清单解析 ====================

export interface SkillManifest {
  id?: string;
  name?: string;
  description?: string;
  domain?: string;
  type?: string;
  runtime?: string;
  entry?: string;
  fallback?: string;
  tags?: string[];
  version?: string;
  status?: string;
}

/**
 * 从 SKILL.md frontmatter 中提取清单信息
 */
export function parseFrontmatter(content: string): Record<string, string> {
  const match = content.match(/^---\n([\s\S]*?)\n---/);
  if (!match) return {};

  const frontmatter: Record<string, string> = {};
  const lines = match[1].split('\n');

  for (const line of lines) {
    const colonIdx = line.indexOf(':');
    if (colonIdx === -1) continue;
    const key = line.slice(0, colonIdx).trim();
    const value = line.slice(colonIdx + 1).trim();
    if (key) frontmatter[key] = value;
  }

  return frontmatter;
}

/**
 * 将 frontmatter 映射到 SkillManifest
 */
export function frontmatterToManifest(
  fm: Record<string, string>,
  dirName: string
): SkillManifest {
  return {
    id: fm['id'] || fm['name'] || dirName,
    name: fm['name'] || fm['id'] || dirName,
    description: fm['description'] || '',
    domain: fm['domain'] || inferDomain(dirName),
    type: fm['type'] || inferType(dirName),
    runtime: fm['runtime'] || 'python',
    entry: fm['entry'] || '',
    fallback: fm['fallback'],
    tags: fm['tags'] ? fm['tags'].split(',').map(t => t.trim()) : [],
    version: fm['version'],
    status: fm['status'] || 'active',
  };
}

/**
 * 从目录名推断领域
 */
function inferDomain(dirName: string): string {
  if (dirName.startsWith('glm') || dirName.startsWith('GLM')) {
    if (dirName.includes('ocr')) return 'glm-ocr';
    if (dirName.includes('caption') || dirName.includes('grounding') || dirName.includes('vision'))
      return 'glm-vision';
    if (dirName.includes('gen') || dirName.includes('image')) return 'glm-gen';
    if (dirName.includes('pdf') || dirName.includes('doc') || dirName.includes('prd') || dirName.includes('web'))
      return 'glm-doc';
    if (dirName.includes('stock') || dirName.includes('finance')) return 'glm-finance';
    return 'glm-gen';
  }
  return 'custom';
}

/**
 * 从目录内容推断类型
 */
function inferType(dirName: string): string {
  return 'hybrid';
}

/**
 * 检测目录中的脚本文件，推断运行时
 */
function detectRuntime(skillDir: string): SkillRuntime {
  try {
    const entries = readdirSync(skillDir);
    const hasPython = entries.some(e => e.endsWith('.py'));
    const hasNode = entries.some(e => e.endsWith('.js') || e.endsWith('.ts'));
    const hasShell = entries.some(e => e.endsWith('.sh'));

    if (hasPython) return 'python';
    if (hasNode) return 'node';
    if (hasShell) return 'shell';
  } catch {
    // ignore
  }
  return 'native';
}

/**
 * 查找脚本入口
 */
function findEntry(skillDir: string, runtime: SkillRuntime): string {
  try {
    const scriptsDir = join(skillDir, 'scripts');
    if (existsSync(scriptsDir)) {
      const scripts = readdirSync(scriptsDir);
      const ext =
        runtime === 'python' ? '.py' :
        runtime === 'node' ? '.js' :
        runtime === 'shell' ? '.sh' : '';

      const main = scripts.find(
        s => s.endsWith(ext) && (s.includes('main') || s.includes('cli') || s.includes('run'))
      );
      if (main) return join('scripts', main);

      const first = scripts.find(s => s.endsWith(ext));
      if (first) return join('scripts', first);
    }
  } catch {
    // ignore
  }
  return '';
}

// ==================== 目录扫描加载器 ====================

export interface LoaderOptions {
  /** 根目录路径 */
  rootDir: string;
  /** 领域前缀映射（如 { 'GLM-skills/skills': 'glm-*' }） */
  domainMap?: Record<string, SkillDomain>;
  /** 是否递归扫描 */
  recursive?: boolean;
  /** 最大扫描深度 */
  maxDepth?: number;
}

export class SkillLoader {
  constructor(
    private registry: SkillRegistry,
    private options: LoaderOptions
  ) {}

  /**
   * 扫描并加载所有 Skill
   */
  load(): UnifiedSkill[] {
    const loaded: UnifiedSkill[] = [];
    const { rootDir, domainMap, recursive = true, maxDepth = 2 } = this.options;

    if (!existsSync(rootDir)) {
      console.warn(`[SkillLoader] Root directory not found: ${rootDir}`);
      return loaded;
    }

    this.scanDir(rootDir, loaded, domainMap, recursive, maxDepth, 0);
    this.registry.bulkRegister(loaded);
    return loaded;
  }

  private scanDir(
    dir: string,
    loaded: UnifiedSkill[],
    domainMap: Record<string, SkillDomain> | undefined,
    recursive: boolean,
    maxDepth: number,
    currentDepth: number
  ): void {
    if (currentDepth > maxDepth) return;

    let entries: string[];
    try {
      entries = readdirSync(dir);
    } catch {
      return;
    }

    // 如果目录中有 SKILL.md，则将其作为一个 Skill 加载
    if (entries.includes('SKILL.md')) {
      const skill = this.loadSkillFromDir(dir, domainMap);
      if (skill) {
        loaded.push(skill);
        return; // 不继续递归子目录
      }
    }

    if (!recursive) return;

    // 递归扫描子目录
    for (const entry of entries) {
      const fullPath = join(dir, entry);
      try {
        if (!statSync(fullPath).isDirectory()) continue;
      } catch {
        continue;
      }

      // 跳过隐藏目录和 node_modules
      if (entry.startsWith('.') || entry === 'node_modules' || entry === '__pycache__') {
        continue;
      }

      this.scanDir(fullPath, loaded, domainMap, recursive, maxDepth, currentDepth + 1);
    }
  }

  private loadSkillFromDir(
    skillDir: string,
    domainMap: Record<string, SkillDomain> | undefined
  ): UnifiedSkill | null {
    const skillMdPath = join(skillDir, 'SKILL.md');
    const dirName = basename(skillDir);
    const parentName = basename(dirname(skillDir));

    let content = '';
    try {
      content = readFileSync(skillMdPath, 'utf-8');
    } catch {
      return null;
    }

    const fm = parseFrontmatter(content);
    const manifest = frontmatterToManifest(fm, dirName);

    // 从 domainMap 推断领域
    let domain: SkillDomain = (manifest.domain as SkillDomain) || 'custom';
    if (domainMap) {
      for (const [path, dom] of Object.entries(domainMap)) {
        if (skillDir.includes(path)) {
          domain = dom;
          break;
        }
      }
    }

    // 检测运行时和入口
    const runtime = (manifest.runtime as SkillRuntime) || detectRuntime(skillDir);
    const entry = manifest.entry || findEntry(skillDir, runtime);

    // 构建相对路径
    const source = skillDir.replace(this.options.rootDir + '/', '');

    const skill: UnifiedSkill = {
      id: manifest.id || `${domain}-${dirName}`,
      name: manifest.name || dirName,
      description: manifest.description || `Skill: ${dirName}`,
      domain,
      type: (manifest.type as SkillType) || 'hybrid',
      runtime,
      entry,
      source,
      inputs: [],
      outputs: [{ type: 'markdown' }],
      fallback: manifest.fallback,
      tags: manifest.tags || [],
      version: manifest.version || '1.0.0',
      status: (manifest.status as UnifiedSkill['status']) || 'active',
    };

    return skill;
  }
}
