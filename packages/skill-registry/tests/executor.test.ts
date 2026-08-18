/**
 * SkillExecutor 执行器测试 — 降级链与熔断器
 */
import { describe, it, expect } from 'vitest';
import { SkillRegistry } from '../src/registry.js';
import { SkillExecutor } from '../src/executor.js';
import type { UnifiedSkill } from '../src/types.js';

function makeSkill(overrides: Partial<UnifiedSkill> = {}): UnifiedSkill {
  return {
    id: 'X-001',
    name: '执行测试技能',
    description: '用于执行器测试',
    domain: 'custom',
    type: 'hybrid',
    runtime: 'native',
    entry: '',
    inputs: [],
    outputs: [{ type: 'text' }],
    ...overrides,
  };
}

/** 构造一个必然失败的 skill：node 运行时 + 不存在的入口 */
function makeFailingSkill(overrides: Partial<UnifiedSkill> = {}): UnifiedSkill {
  return makeSkill({
    runtime: 'node',
    entry: 'nonexistent-entry.js',
    source: '/nonexistent',
    ...overrides,
  });
}

describe('SkillExecutor', () => {
  it('执行 native 技能成功', async () => {
    const registry = new SkillRegistry();
    registry.register(makeSkill());
    const executor = new SkillExecutor(registry);

    const result = await executor.execute('X-001', { input: 'demo' });
    expect(result.success).toBe(true);
    expect(result.skillId).toBe('X-001');
    expect(result.executedSkillId).toBe('X-001');
    expect(result.callId).toBeTruthy();
  });

  it('技能不存在时返回失败', async () => {
    const registry = new SkillRegistry();
    const executor = new SkillExecutor(registry);

    const result = await executor.execute('NOT-EXIST', {});
    expect(result.success).toBe(false);
    expect(result.error).toContain('not found');
  });

  it('执行失败自动走降级链', async () => {
    const registry = new SkillRegistry();
    registry.register(makeFailingSkill({ id: 'X-FAIL', fallback: 'X-OK' }));
    registry.register(makeSkill({ id: 'X-OK' }));
    const executor = new SkillExecutor(registry);

    const result = await executor.execute('X-FAIL', {});
    expect(result.success).toBe(true);
    expect(result.fellBack).toBe(true);
    expect(result.executedSkillId).toBe('X-OK');
    expect(result.metadata?.originalError).toBeTruthy();
  });

  it('allowFallback=false 时不降级', async () => {
    const registry = new SkillRegistry();
    registry.register(makeFailingSkill({ id: 'X-FAIL2', fallback: 'X-OK2' }));
    registry.register(makeSkill({ id: 'X-OK2' }));
    const executor = new SkillExecutor(registry);

    const result = await executor.execute('X-FAIL2', {}, { allowFallback: false });
    expect(result.success).toBe(false);
    expect(result.fellBack).toBeFalsy();
  });

  it('连续失败后熔断器打开', async () => {
    const registry = new SkillRegistry();
    registry.register(makeFailingSkill({ id: 'X-CB' }));
    const executor = new SkillExecutor(registry, { failureThreshold: 3, recoveryTimeout: 60_000 });

    // 连续失败 3 次（无降级）
    for (let i = 0; i < 3; i++) {
      const r = await executor.execute('X-CB', {}, { allowFallback: false });
      expect(r.success).toBe(false);
    }

    // 熔断器打开：直接拒绝执行
    expect(executor.getCircuitState('X-CB')).toBe('open');
    const blocked = await executor.execute('X-CB', {}, { allowFallback: false });
    expect(blocked.success).toBe(false);
    expect(blocked.error).toContain('Circuit breaker');

    // 重置后恢复
    executor.resetBreaker('X-CB');
    expect(executor.getCircuitState('X-CB')).toBe('closed');
  });

  it('成功执行后熔断器计数复位', async () => {
    const registry = new SkillRegistry();
    registry.register(makeFailingSkill({ id: 'X-MIX' }));
    registry.register(makeSkill({ id: 'X-NATIVE' }));
    const executor = new SkillExecutor(registry, { failureThreshold: 3 });

    await executor.execute('X-MIX', {}, { allowFallback: false }); // 失败 1 次
    expect(executor.getCircuitState('X-MIX')).toBe('closed');

    registry.unregister('X-MIX');
    registry.register(makeSkill({ id: 'X-MIX' })); // 换成 native 成功执行
    const ok = await executor.execute('X-MIX', {});
    expect(ok.success).toBe(true);
  });
});
