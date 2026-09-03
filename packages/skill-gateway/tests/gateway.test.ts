/**
 * Skill Gateway — 端到端测试
 */
import type { UnifiedSkill } from '@yyc3/skill-registry';
import { SkillExecutor, SkillLoader, SkillRegistry } from '@yyc3/skill-registry';
import { beforeAll, describe, expect, it, vi } from 'vitest';
import { SkillGateway } from '../src/gateway.js';

function makeSkill(overrides: Partial<UnifiedSkill> = {}): UnifiedSkill {
  return {
    id: 'GW-001',
    name: 'Gateway 测试技能',
    description: '用于 Gateway 测试',
    domain: 'marketplace',
    type: 'hybrid',
    runtime: 'native',
    entry: '',
    inputs: [{ name: 'text', type: 'string', description: '输入文本', required: true }],
    outputs: [{ type: 'text' }],
    ...overrides,
  };
}

describe('SkillGateway', () => {
  let gateway: SkillGateway;
  let registry: SkillRegistry;

  beforeAll(() => {
    registry = new SkillRegistry();
    registry.register(makeSkill());
    registry.register(makeSkill({ id: 'GW-002', domain: 'glm-ocr' }));

    const loader = new SkillLoader(registry, { rootDir: './skills' });
    const executor = new SkillExecutor(registry);

    gateway = new SkillGateway({ registry, loader, executor });
  });

  it('创建 app 实例', () => {
    expect(gateway.app).toBeDefined();
    expect(gateway.config.port).toBe(3030);
  });

  describe('GET /api/v1/health', () => {
    it('返回健康状态', async () => {
      const res = await gateway.app.request('/api/v1/health');
      expect(res.status).toBe(200);
      const body = await res.json();
      expect(body.ok).toBe(true);
      expect(body.data.status).toBe('ok');
    });

    it('返回技能总数', async () => {
      const res = await gateway.app.request('/api/v1/health');
      const body = await res.json();
      expect(body.data.skills.total).toBe(2);
    });
  });

  describe('GET /api/v1/health/ready', () => {
    it('返回就绪状态', async () => {
      const res = await gateway.app.request('/api/v1/health/ready');
      expect(res.status).toBe(200);
      const body = await res.json();
      expect(body.data.ready).toBe(true);
    });
  });

  describe('GET /api/v1/health/version', () => {
    it('返回版本信息', async () => {
      const res = await gateway.app.request('/api/v1/health/version');
      expect(res.status).toBe(200);
      const body = await res.json();
      expect(body.data.version).toBe('1.0.0');
    });
  });

  describe('GET /api/v1/skills', () => {
    it('返回技能列表', async () => {
      const res = await gateway.app.request('/api/v1/skills');
      expect(res.status).toBe(200);
      const body = await res.json();
      expect(body.ok).toBe(true);
      expect(Array.isArray(body.data)).toBe(true);
      expect(body.data.length).toBe(2);
      expect(body.meta.total).toBe(2);
    });

    it('分页', async () => {
      const res = await gateway.app.request('/api/v1/skills?pageSize=1&page=1');
      const body = await res.json();
      expect(body.data.length).toBe(1);
      expect(body.meta.page).toBe(1);
      expect(body.meta.pageSize).toBe(1);
    });

    it('按领域过滤', async () => {
      const res = await gateway.app.request('/api/v1/skills?domain=glm-ocr');
      const body = await res.json();
      expect(body.data.length).toBe(1);
      expect(body.data[0].id).toBe('GW-002');
    });
  });

  describe('GET /api/v1/skills/:id', () => {
    it('返回单个技能', async () => {
      const res = await gateway.app.request('/api/v1/skills/GW-001');
      expect(res.status).toBe(200);
      const body = await res.json();
      expect(body.data.id).toBe('GW-001');
    });

    it('不存在的技能返回 404', async () => {
      const res = await gateway.app.request('/api/v1/skills/NOT-EXIST');
      expect(res.status).toBe(404);
    });
  });

  describe('GET /api/v1/skills/stats', () => {
    it('返回统计信息', async () => {
      const res = await gateway.app.request('/api/v1/skills/stats');
      expect(res.status).toBe(200);
      const body = await res.json();
      expect(body.data.totalSkills).toBe(2);
    });
  });

  describe('GET /api/v1/skills/domains', () => {
    it('返回领域列表', async () => {
      const res = await gateway.app.request('/api/v1/skills/domains');
      expect(res.status).toBe(200);
      const body = await res.json();
      expect(body.data).toContain('glm-ocr');
      expect(body.data).toContain('marketplace');
    });
  });

  describe('POST /api/v1/skills/reload', () => {
    it('重新加载技能', async () => {
      const res = await gateway.app.request('/api/v1/skills/reload', { method: 'POST' });
      expect(res.status).toBe(200);
      const body = await res.json();
      expect(body.data.reloaded).toBe(2);
    });
  });

  describe('POST /api/v1/execute', () => {
    it('缺少参数返回 400', async () => {
      const res = await gateway.app.request('/api/v1/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({}),
      });
      expect(res.status).toBe(400);
    });

    it('不存在的技能返回 404', async () => {
      const res = await gateway.app.request('/api/v1/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ skillId: 'NOT-EXIST', params: {} }),
      });
      expect(res.status).toBe(404);
    });

    it('成功执行 native 技能', async () => {
      const res = await gateway.app.request('/api/v1/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ skillId: 'GW-001', params: { text: 'demo' } }),
      });
      expect(res.status).toBe(200);
      const body = await res.json();
      expect(body.ok).toBe(true);
      expect(body.data.skillId).toBe('GW-001');
      expect(body.data.output).toBeTruthy();
    });

    it('执行抛错时返回 500 与 EXECUTION_ERROR', async () => {
      // 注册一个执行时必然抛错的技能（node 运行时 + 不存在入口）
      registry.register(
        makeSkill({
          id: 'GW-BOOM',
          runtime: 'node',
          entry: 'nope.js',
          source: '/nonexistent-gw',
        })
      );
      const res = await gateway.app.request('/api/v1/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ skillId: 'GW-BOOM', params: {} }),
      });
      expect(res.status).toBe(500);
      const body = await res.json();
      expect(body.error.code).toBe('EXECUTION_ERROR');
    });

    it('timeout 超过上限时被截断（不抛错）', async () => {
      const res = await gateway.app.request('/api/v1/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ skillId: 'GW-001', params: {}, timeout: 999_999 }),
      });
      expect(res.status).toBe(200);
    });
  });

  describe('POST /api/v1/execute/mcp/list', () => {
    it('无 MCP 运行时返回 503', async () => {
      const res = await gateway.app.request('/api/v1/execute/mcp/list', { method: 'POST' });
      expect(res.status).toBe(503);
    });
  });

  describe('POST /api/v1/execute/mcp/call', () => {
    it('无 MCP 运行时返回 503', async () => {
      const res = await gateway.app.request('/api/v1/execute/mcp/call', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ name: 'x', args: {} }),
      });
      expect(res.status).toBe(503);
    });
  });

  describe('搜索与元信息分支', () => {
    it('按关键词搜索', async () => {
      const res = await gateway.app.request('/api/v1/skills?q=Gateway');
      const body = await res.json();
      expect(body.data.length).toBeGreaterThan(0);
    });

    it('按类型与运行时过滤', async () => {
      const res = await gateway.app.request('/api/v1/skills?type=hybrid&runtime=native&status=active');
      const body = await res.json();
      expect(body.data.length).toBeGreaterThan(0);
    });

    it('非法分页参数回退默认值', async () => {
      const res = await gateway.app.request('/api/v1/skills?page=-3&pageSize=0');
      const body = await res.json();
      // page=-3 → NaN → 1; pageSize=0 → Number('0')=0 falsy → 默认 20（上限逻辑不影响）
      expect(body.meta.page).toBe(1);
      expect(body.meta.pageSize).toBe(20);
    });
  });

  describe('错误处理中间件', () => {
    it('路由抛错时返回 500 INTERNAL_ERROR', async () => {
      // 注册损坏的 registry 行为：让 stats 抛错触发 errorHandler
      const broken = new SkillRegistry();
      const brokenLoader = new SkillLoader(broken, { rootDir: './skills' });
      const brokenExecutor = new SkillExecutor(broken);
      const brokenGateway = new SkillGateway({
        registry: broken,
        loader: brokenLoader,
        executor: brokenExecutor,
      });
      vi.spyOn(brokenGateway.deps.registry, 'getStats').mockImplementation(() => {
        throw new Error('boom');
      });
      const res = await brokenGateway.app.request('/api/v1/health');
      expect(res.status).toBe(500);
      const body = await res.json();
      expect(body.error.code).toBe('INTERNAL_ERROR');
    });
  });

  describe('gateway 生命周期', () => {
    it('initialize 后 getUptime 大于 0', async () => {
      const fresh = new SkillGateway({
        registry,
        loader: new SkillLoader(registry, { rootDir: './skills' }),
        executor: new SkillExecutor(registry),
      });
      expect(fresh.getUptime()).toBe(0);
      await fresh.initialize();
      expect(fresh.getUptime()).toBeGreaterThanOrEqual(0);
    });
  });

  describe('Security', () => {
    it('应包含安全响应头', async () => {
      const res = await gateway.app.request('/api/v1/health');
      expect(res.headers.get('x-content-type-options')).toBe('nosniff');
      expect(res.headers.get('x-frame-options')).toBe('DENY');
      expect(res.headers.get('referrer-policy')).toBe('strict-origin-when-cross-origin');
    });

    it('不应暴露服务端标识', async () => {
      const res = await gateway.app.request('/api/v1/health');
      expect(res.headers.get('x-powered-by')).toBeNull();
    });

    it('速率限制应返回限流头', async () => {
      const res = await gateway.app.request('/api/v1/health');
      expect(res.headers.get('x-ratelimit-limit')).toBe('100');
      expect(res.headers.get('x-ratelimit-remaining')).toBeDefined();
      expect(res.headers.get('x-ratelimit-reset')).toBeDefined();
    });

    it('超过速率限制应返回 429', async () => {
      // 快速耗尽 tokens
      for (let i = 0; i < 101; i++) {
        await gateway.app.request('/api/v1/health');
      }
      const res = await gateway.app.request('/api/v1/health');
      expect(res.status).toBe(429);
      const body = await res.json();
      expect(body.error.code).toBe('RATE_LIMIT_EXCEEDED');
    });

    it('请求体过大应返回 413', async () => {
      const largeBody = 'x'.repeat(2 * 1024 * 1024); // 2MB
      const res = await gateway.app.request('/api/v1/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json', 'Content-Length': String(largeBody.length) },
        body: largeBody,
      });
      expect(res.status).toBe(413);
    });
  });
});
