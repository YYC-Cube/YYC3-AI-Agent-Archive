/**
 * MCP Runtime — 独立服务入口
 *
 * 用途：容器化部署（Dockerfile stage: mcp-runtime）
 * 以 Hono + @hono/node-server 暴露 MCP tools/list 与 tools/call HTTP 接口
 */
import { Hono } from 'hono';
import { serve } from '@hono/node-server';
import { UnifiedMCPRuntime } from './runtime.js';

const port = Number(process.env.PORT ?? 3031);

const runtime = new UnifiedMCPRuntime({
  enableSkillBridge: false, // 独立部署时不桥接 Skill Registry（由 Gateway 侧组装）
  enableCowAgent: false,
});
await runtime.initialize();

const app = new Hono();

app.onError((err, c) => {
  const message = err instanceof Error ? err.message : 'Internal Server Error';
  return c.json({ ok: false, error: { code: 'INTERNAL_ERROR', message } }, 500);
});

// 健康检查（Docker HEALTHCHECK 探测路径）
app.get('/health', (c) => {
  const tools = runtime.listAllTools();
  return c.json({
    ok: true,
    data: { status: 'ok', uptime: process.uptime(), tools: tools.length },
  });
});

// MCP tools/list
app.get('/api/v1/tools', (c) => {
  return c.json({ ok: true, data: runtime.listAllSourcedTools() });
});

// MCP tools/call
app.post('/api/v1/tools/call', async (c) => {
  const body = (await c.req.json<{ name: string; args?: Record<string, unknown> }>()) as {
    name: string;
    args?: Record<string, unknown>;
  };
  if (!body?.name) {
    return c.json(
      { ok: false, error: { code: 'BAD_REQUEST', message: 'name is required' } },
      400
    );
  }
  const result = await runtime.callTool(body.name, body.args ?? {});
  return c.json({ ok: !result.isError, data: result });
});

serve({ fetch: app.fetch, port, hostname: '0.0.0.0' });
console.warn(`[MCPRuntime] 启动于 http://0.0.0.0:${port}`);

process.on('SIGTERM', () => process.exit(0));
process.on('SIGINT', () => process.exit(0));
