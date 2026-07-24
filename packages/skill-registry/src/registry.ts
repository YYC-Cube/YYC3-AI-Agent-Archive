/**
 * @description YYC³ 统一 Skill 注册中心
 * @module @yyc3/skill-registry/registry
 *
 * 实现 Skill 的标准化注册、发现、分类管理与搜索。
 * 对齐 MCP 架构，可桥接为 MCP Tool。
 */

import type {
  UnifiedSkill,
  SkillDomain,
  SkillType,
  SkillRuntime,
  SkillStatus,
  SkillSearchOptions,
  SkillRegistryStats,
  SkillEventMap,
} from './types.js';

type EventHandler<T> = (payload: T) => void;

export class SkillRegistry {
  private skills: Map<string, UnifiedSkill> = new Map();
  private domainIndex: Map<SkillDomain, Set<string>> = new Map();
  private tagIndex: Map<string, Set<string>> = new Map();
  private listeners: { [K in keyof SkillEventMap]?: Set<EventHandler<SkillEventMap[K]>> } = {};

  /**
   * 注册一个 Skill
   */
  register(skill: UnifiedSkill): void {
    this.skills.set(skill.id, skill);

    // 索引：按领域
    if (!this.domainIndex.has(skill.domain)) {
      this.domainIndex.set(skill.domain, new Set());
    }
    this.domainIndex.get(skill.domain)!.add(skill.id);

    // 索引：按标签
    if (skill.tags) {
      for (const tag of skill.tags) {
        if (!this.tagIndex.has(tag)) {
          this.tagIndex.set(tag, new Set());
        }
        this.tagIndex.get(tag)!.add(skill.id);
      }
    }

    this.emit('skill:registered', { skill });
  }

  /**
   * 批量注册
   */
  bulkRegister(skills: UnifiedSkill[]): void {
    for (const skill of skills) {
      this.register(skill);
    }
  }

  /**
   * 注销 Skill
   */
  unregister(id: string): boolean {
    const skill = this.skills.get(id);
    if (!skill) return false;

    this.skills.delete(id);
    this.domainIndex.get(skill.domain)?.delete(id);

    if (skill.tags) {
      for (const tag of skill.tags) {
        this.tagIndex.get(tag)?.delete(id);
      }
    }

    this.emit('skill:unregistered', { id });
    return true;
  }

  /**
   * 获取 Skill
   */
  get(id: string): UnifiedSkill | undefined {
    return this.skills.get(id);
  }

  /**
   * 获取所有 Skill
   */
  getAll(): UnifiedSkill[] {
    return Array.from(this.skills.values());
  }

  /**
   * 是否存在
   */
  has(id: string): boolean {
    return this.skills.has(id);
  }

  /**
   * 按领域获取
   */
  getByDomain(domain: SkillDomain): UnifiedSkill[] {
    const ids = this.domainIndex.get(domain);
    if (!ids) return [];
    return Array.from(ids)
      .map(id => this.skills.get(id)!)
      .filter(Boolean);
  }

  /**
   * 按标签获取
   */
  getByTag(tag: string): UnifiedSkill[] {
    const ids = this.tagIndex.get(tag);
    if (!ids) return [];
    return Array.from(ids)
      .map(id => this.skills.get(id)!)
      .filter(Boolean);
  }

  /**
   * 搜索 Skill
   */
  search(options: SkillSearchOptions = {}): UnifiedSkill[] {
    let results = Array.from(this.skills.values());

    // 文本搜索
    if (options.query) {
      const q = options.query.toLowerCase();
      results = results.filter(
        s =>
          s.name.toLowerCase().includes(q) ||
          s.description.toLowerCase().includes(q) ||
          s.id.toLowerCase().includes(q) ||
          (s.tags?.some(t => t.toLowerCase().includes(q)) ?? false)
      );
    }

    // 按领域筛选
    if (options.domain) {
      results = results.filter(s => s.domain === options.domain);
    }

    // 按类型筛选
    if (options.type) {
      results = results.filter(s => s.type === options.type);
    }

    // 按运行时筛选
    if (options.runtime) {
      results = results.filter(s => s.runtime === options.runtime);
    }

    // 按状态筛选（默认仅返回 active）
    if (options.status) {
      results = results.filter(s => (s.status ?? 'active') === options.status);
    } else {
      results = results.filter(s => (s.status ?? 'active') === 'active');
    }

    // 按标签筛选
    if (options.tags && options.tags.length > 0) {
      results = results.filter(s =>
        options.tags!.some(t => s.tags?.includes(t))
      );
    }

    // 分页
    const offset = options.offset ?? 0;
    const limit = options.limit ?? results.length;
    return results.slice(offset, offset + limit);
  }

  /**
   * 获取降级链
   */
  getFallbackChain(id: string, maxDepth: number = 5): string[] {
    const chain: string[] = [id];
    let current = id;
    let depth = 0;

    while (depth < maxDepth) {
      const skill = this.skills.get(current);
      if (!skill?.fallback) break;
      if (chain.includes(skill.fallback)) break; // 防止循环
      chain.push(skill.fallback);
      current = skill.fallback;
      depth++;
    }

    return chain;
  }

  /**
   * 获取注册中心统计信息
   */
  getStats(): SkillRegistryStats {
    const stats: SkillRegistryStats = {
      totalSkills: this.skills.size,
      byDomain: {},
      byType: {},
      byRuntime: {},
      byStatus: {},
      withEvals: 0,
      withFallback: 0,
    };

    for (const skill of this.skills.values()) {
      stats.byDomain[skill.domain] = (stats.byDomain[skill.domain] ?? 0) + 1;
      stats.byType[skill.type] = (stats.byType[skill.type] ?? 0) + 1;
      stats.byRuntime[skill.runtime] = (stats.byRuntime[skill.runtime] ?? 0) + 1;
      const status = skill.status ?? 'active';
      stats.byStatus[status] = (stats.byStatus[status] ?? 0) + 1;
      if (skill.evals) stats.withEvals++;
      if (skill.fallback) stats.withFallback++;
    }

    return stats;
  }

  /**
   * 导出注册表（用于序列化/持久化）
   */
  export(): UnifiedSkill[] {
    return this.getAll();
  }

  /**
   * 导入注册表
   */
  import(skills: UnifiedSkill[]): void {
    this.bulkRegister(skills);
  }

  // ==================== 事件系统 ====================

  on<K extends keyof SkillEventMap>(
    event: K,
    handler: EventHandler<SkillEventMap[K]>
  ): () => void {
    if (!this.listeners[event]) {
      this.listeners[event] = new Set() as any;
    }
    this.listeners[event]!.add(handler as any);
    return () => this.off(event, handler);
  }

  off<K extends keyof SkillEventMap>(
    event: K,
    handler: EventHandler<SkillEventMap[K]>
  ): void {
    this.listeners[event]?.delete(handler as any);
  }

  private emit<K extends keyof SkillEventMap>(
    event: K,
    payload: SkillEventMap[K]
  ): void {
    this.listeners[event]?.forEach(handler => {
      try {
        handler(payload as any);
      } catch (e) {
        console.error(`[SkillRegistry] Event handler error for "${String(event)}":`, e);
      }
    });
  }
}

/** 全局注册中心实例 */
export const globalSkillRegistry = new SkillRegistry();
