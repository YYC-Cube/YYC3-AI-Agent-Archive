/**
 * Agent Runtime — 独立服务入口
 *
 * 用途：容器化部署（Dockerfile stage: agent-runtime）
 * 以 Hono + @hono/node-server 暴露 Agent 生命周期与对话 HTTP 接口
 */
import { Hono } from 'hono';
import { serve } from '@hono/node-server';
import { AgentRuntime } from './runtime.js';
import { AI_FAMILY_PROFILES } from './family-registry.js';
import type { AgentProfile } from './types.js';

const port = Number(process.env.PORT ?? 3032);

const runtime = new AgentRuntime({ autoHeartbeat: true });
const app = new Hono();

app.onError((err, c) => {
  const message = err instanceof Error ? err.message : 'Internal Server Error';
  return c.json({ ok: false, error: { code: 'INTERNAL_ERROR', message } }, 500);
});

// 健康检查（Docker HEALTHCHECK 探测路径）
app.get('/health', (c) => {
  return c.json({
    ok: true,
    data: { status: 'ok', uptime: process.uptime(), agents: runtime.listAgents().length },
  });
});

// 列出可用 Family 档案
app.get('/api/v1/profiles', (c) => {
  return c.json({ ok: true, data: AI_FAMILY_PROFILES });
});

// 创建智能体
app.post('/api/v1/agents', async (c) => {
  const body = await c.req.json<{ profileName?: string; id?: string }>();
  const profile: AgentProfile | undefined = AI_FAMILY_PROFILES.find(
    (p) => p.nameEN === body?.profileName || p.nameCN === body?.profileName
  );
  if (!profile) {
    return c.json(
      {
        ok: false,
        error: { code: 'NOT_FOUND', message: `Unknown profile: ${body?.profileName}` },
      },
      404
    );
  }
  const agent = runtime.createAgent(profile, body.id);
  return c.json({ ok: true, data: { id: agent.id, status: agent.status } });
});

// 列出已创建智能体
app.get('/api/v1/agents', (c) => {
  return c.json({ ok: true, data: runtime.listAgents().map((a) => ({ id: a.id, status: a.status })) });
});

serve({ fetch: app.fetch, port, hostname: '0.0.0.0' });
console.warn(`[AgentRuntime] 启动于 http://0.0.0.0:${port}`);

process.on('SIGTERM', () => process.exit(0));
process.on('SIGINT', () => process.exit(0));
