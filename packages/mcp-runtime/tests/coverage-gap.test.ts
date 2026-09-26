/**
 * 覆盖率缺口补充测试 — CI coverage job 分支覆盖率门禁（≥75%）
 *
 * 覆盖此前未覆盖的分支：
 * - resolveClientIp：hops > XFF 链长时回退 chain[0]；x-real-ip 兜底
 * - mcpRateLimiter：TTL 清理回调（过期桶删除 + 未过期桶保留）
 * - CowAgentMCPBridge：子进程 stdout/stderr data 回调 + close code=0/≠0
 * - UnifiedMCPRuntime：enableCowAgent 初始化、cowagent 调用路由、getTool 命中/未命中
 * - createMcpServerApp：onError Error 透传、args 非 object 容错、call 成功响应
 */
import { execFileSync } from 'node:child_process';
import { mkdirSync, mkdtempSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { afterEach, describe, expect, it, vi } from 'vitest';
import { Hono } from 'hono';
import { CowAgentMCPBridge } from '../src/cowagent-bridge.js';
import { UnifiedMCPRuntime } from '../src/runtime.js';
import { createMcpServerApp } from '../src/server-app.js';
import { mcpRateLimiter, resolveClientIp } from '../src/server-security.js';

/** 检测 python3 是否可用（CowAgent 桥接依赖；CI ubuntu-latest 与本机均预装） */
let python3Available = false;
try {
  execFileSync('python3', ['--version'], { stdio: 'ignore' });
  python3Available = true;
} catch {
  python3Available = false;
}

/** 在临时目录构造可被 wrapper `from agent.tools.<name> import *` 成功导入的假模块树 */
function makeFakeCowagentRoot(): string {
  const root = mkdtempSync(join(tmpdir(), 'cowagent-fake-'));
  mkdirSync(join(root, 'agent', 'tools'), { recursive: true });
  writeFileSync(join(root, 'agent', '__init__.py'), '');
  writeFileSync(join(root, 'agent', 'tools', '__init__.py'), '');
  // 工具模块本身无需实现——wrapper 导入成功后自行打印 JSON 到 stdout 并退出 0
  writeFileSync(join(root, 'agent', 'tools', 'bash.py'), 'PASS = True\n');
  return root;
}

describe('覆盖率缺口补充 — server-security', () => {
  it('resolveClientIp：hops 超过 XFF 链长时回退首跳（chain[0]）', () => {
    // 链长 2，hops=5 → idx = 2-5 = -3 < 0 → chain.length > 0 → chain[0]
    expect(resolveClientIp({ 'x-forwarded-for': '10.0.0.1, 10.0.0.2' }, 5)).toBe('10.0.0.1');
  });

  it('resolveClientIp：无 XFF 时回退 x-real-ip（含 trim）', () => {
    expect(resolveClientIp({ 'x-real-ip': '  203.0.113.9  ' }, 1)).toBe('203.0.113.9');
  });

  it('mcpRateLimiter：TTL 清理回调删除过期桶并保留活跃桶', async () => {
    vi.useFakeTimers({ toFake: ['setInterval', 'setTimeout', 'clearInterval', 'clearTimeout', 'Date'] });
    try {
      const windowMs = 60_000;
      const limiter = mcpRateLimiter({ windowMs, maxRequests: 1, trustedProxyHops: 1 });
      const app = new Hono();
      app.use('*', limiter);
      app.get('/', (c) => c.text('ok'));

      // hops=1：key 取 XFF 倒数第 1 跳 = 各自 ip（直连伪造的前缀被忽略）
      const hdr = (ip: string) => ({ 'x-forwarded-for': `x, ${ip}` });

      // t=0：IP-A 建桶并耗尽（tokens 1→0，再请求 429）
      expect((await app.request('/', { headers: hdr('1.1.1.1') })).status).toBe(200);
      expect((await app.request('/', { headers: hdr('1.1.1.1') })).status).toBe(429);

      // t=200s：IP-B 建活跃桶
      vi.advanceTimersByTime(200_000);
      expect((await app.request('/', { headers: hdr('2.2.2.2') })).status).toBe(200);

      // t=300s = windowMs*5：TTL 回调触发
      // IP-A：300s - 0 > 2×60s → 删除（true 分支）
      // IP-B：300s - 200s = 100s ≤ 120s → 保留（false 分支）
      vi.advanceTimersByTime(100_000);

      // IP-A 桶已被清理 → 新桶满额 200（旧桶若残留则 429）
      expect((await app.request('/', { headers: hdr('1.1.1.1') })).status).toBe(200);
      // IP-B 桶保留且按 Token Bucket 连续补充已回满 → 200
      expect((await app.request('/', { headers: hdr('2.2.2.2') })).status).toBe(200);
    } finally {
      vi.useRealTimers();
    }
  });
});

describe('覆盖率缺口补充 — CowAgentMCPBridge 子进程流', () => {
  it('python3 子进程成功：stdout data 回调 + close code=0 走成功分支', async () => {
    if (!python3Available) return; // 环境无 python3 时跳过（CI/本机均预装）
    const root = makeFakeCowagentRoot();
    const bridge = new CowAgentMCPBridge({ cowagentRoot: root, pythonPath: 'python3' });
    const result = await bridge.handleToolCall({
      id: 'call-ok',
      name: 'cowagent_bash',
      arguments: { command: 'echo hi' },
    });
    const text = result.content[0].text ?? '';
    // 沙箱（本机开发）会拦截 spawn python3 → ENOENT；CI ubuntu 无沙箱真实执行覆盖 data/close 分支
    if (text.startsWith('Error: spawn')) return;
    expect(result.isError).toBeFalsy();
    expect(text).toContain('"status": "ok"');
  });

  it('python3 子进程失败：stderr data 回调 + close code≠0 走错误分支', async () => {
    if (!python3Available) return;
    // 不存在的 cwd：wrapper 内 import 失败 → stderr JSON + exit 1
    const bridge = new CowAgentMCPBridge({
      cowagentRoot: '/nonexistent-cowagent-root',
      pythonPath: 'python3',
    });
    const result = await bridge.handleToolCall({
      id: 'call-err',
      name: 'cowagent_bash',
      arguments: {},
    });
    const text = result.content[0].text ?? '';
    if (text.startsWith('Error: spawn')) return; // 同上：沙箱 soft-skip，CI 真实执行
    expect(result.isError).toBe(true);
    expect(text).toContain('status');
  });
});

describe('覆盖率缺口补充 — UnifiedMCPRuntime cowagent 路由与 getTool', () => {
  it('enableCowAgent 初始化桥接、callTool 路由到 cowagent 分支、getTool 命中/未命中', async () => {
    const runtime = new UnifiedMCPRuntime({
      enableSkillBridge: false,
      enableCowAgent: true,
      cowagentRoot: '/nonexistent-cowagent-root',
    });
    await runtime.initialize();

    // 桥接已建立，工具已索引
    const tools = runtime.listAllTools();
    expect(tools.some((t) => t.name.startsWith('cowagent_'))).toBe(true);

    // getTool 命中与未命中
    expect(runtime.getTool('cowagent_bash')?.name).toBe('cowagent_bash');
    expect(runtime.getTool('no-such-tool')).toBeUndefined();

    // cowagent 来源调用分支（spawn 失败返回进程错误，不走 "No executor"）
    const result = await runtime.callTool('cowagent_bash', {});
    expect(result.isError).toBe(true);
    expect(result.content[0].text).not.toContain('No executor available');
  });
});

describe('覆盖率缺口补充 — server-app onError / args 容错 / 成功响应', () => {
  const KEY = 'gap-test-key';
  const auth = { 'Content-Type': 'application/json', 'X-API-Key': KEY };

  async function makeApp(customExecutor?: unknown): Promise<Hono> {
    const runtime = new UnifiedMCPRuntime({
      enableSkillBridge: false,
      enableCowAgent: false,
      customTools: [
        {
          tool: {
            name: 'custom_echo',
            description: 'test tool',
            inputSchema: { type: 'object', properties: {} },
          },
          source: 'custom',
          sourceId: 'custom_echo',
        },
      ],
      customExecutor: customExecutor as never,
    });
    await runtime.initialize();
    return createMcpServerApp(runtime, { apiKeys: [KEY] });
  }

  it('callTool 成功：args 非 object 容错为 {} 并返回 ok=true', async () => {
    const app = await makeApp(async (call: { id: string }) => ({
      id: call.id,
      content: [{ type: 'text', text: 'pong' }],
    }));
    // args 传字符串（非 object）→ 容错为 {}
    const res = await app.request('/api/v1/tools/call', {
      method: 'POST',
      headers: auth,
      body: JSON.stringify({ name: 'custom_echo', args: 'not-an-object' }),
    });
    expect(res.status).toBe(200);
    const body = await res.json();
    expect(body.ok).toBe(true);
    expect(body.data.content[0].text).toBe('pong');
  });

  it('executor 抛 Error：onError 兜底 INTERNAL_ERROR 并透传 message', async () => {
    const app = await makeApp(async () => {
      throw new Error('boom');
    });
    const res = await app.request('/api/v1/tools/call', {
      method: 'POST',
      headers: auth,
      body: JSON.stringify({ name: 'custom_echo', args: {} }),
    });
    expect(res.status).toBe(500);
    const body = await res.json();
    expect(body.error.code).toBe('INTERNAL_ERROR');
    expect(body.error.message).toBe('boom');
  });
});

afterEach(() => {
  vi.useRealTimers();
});
