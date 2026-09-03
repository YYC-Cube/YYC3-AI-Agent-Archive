/**
 * Skill Gateway — 执行路由
 *
 * POST   /api/v1/execute           — 执行 Skill
 * POST   /api/v1/execute/mcp/list  — 列出 MCP 工具
 * POST   /api/v1/execute/mcp/call  — 调用 MCP 工具
 */
import { Hono } from 'hono';
import '../context.js';
import type { ApiResponse, SkillExecuteRequest, SkillExecuteResult } from '../types.js';
import type { SkillExecutionContext } from '@yyc3/skill-registry';

export const executeRoutes = new Hono();

// POST /api/v1/execute — 执行 Skill
executeRoutes.post('/', async (c) => {
  const registry = c.get('registry');
  const executor = c.get('executor');
  const config = c.get('gatewayConfig');

  const body = await c.req.json<SkillExecuteRequest>();
  if (!body.skillId || !body.params) {
    const resp: ApiResponse = {
      ok: false,
      error: { code: 'BAD_REQUEST', message: 'skillId and params are required' },
    };
    c.status(400);
    return c.json(resp);
  }

  const skill = registry.get(body.skillId);
  if (!skill) {
    const resp: ApiResponse = {
      ok: false,
      error: { code: 'NOT_FOUND', message: `Skill '${body.skillId}' not found` },
    };
    c.status(404);
    return c.json(resp);
  }

  const timeout = Math.min(body.timeout ?? config.defaultTimeout, config.maxTimeout);
  const start = Date.now();

  try {
    const ctx: SkillExecutionContext = {
      callId: `gw-${Date.now()}-${Math.random().toString(36).slice(2, 8)}`,
      timeout,
    };
    const output = await executor.execute(body.skillId, body.params, ctx);
    const result: SkillExecuteResult = {
      skillId: body.skillId,
      duration: Date.now() - start,
      output,
      error: output.success ? undefined : (output.error ?? 'Execution failed'),
    };
    const resp: ApiResponse<SkillExecuteResult> = {
      ok: output.success,
      data: result,
      ...(output.success
        ? {}
        : { error: { code: 'EXECUTION_ERROR', message: result.error ?? 'Execution failed' } }),
    };
    if (!output.success) {
      c.status(500);
    }
    return c.json(resp);
  } catch (err) {
    const errorMsg = err instanceof Error ? err.message : 'Execution failed';
    const result: SkillExecuteResult = {
      skillId: body.skillId,
      duration: Date.now() - start,
      output: null,
      error: errorMsg,
    };
    const resp: ApiResponse = { ok: false, data: result, error: { code: 'EXECUTION_ERROR', message: errorMsg } };
    c.status(500);
    return c.json(resp);
  }
});

// POST /api/v1/execute/mcp/list — 列出 MCP 工具
executeRoutes.post('/mcp/list', (c) => {
  const mcpRuntime = c.get('mcpRuntime');
  if (!mcpRuntime) {
    const resp: ApiResponse = {
      ok: false,
      error: { code: 'NOT_AVAILABLE', message: 'MCP Runtime not configured' },
    };
    c.status(503);
    return c.json(resp);
  }
  const tools = mcpRuntime.listAllTools();
  const resp: ApiResponse = { ok: true, data: tools };
  return c.json(resp);
});

// POST /api/v1/execute/mcp/call — 调用 MCP 工具
executeRoutes.post('/mcp/call', async (c) => {
  const mcpRuntime = c.get('mcpRuntime');
  if (!mcpRuntime) {
    const resp: ApiResponse = {
      ok: false,
      error: { code: 'NOT_AVAILABLE', message: 'MCP Runtime not configured' },
    };
    c.status(503);
    return c.json(resp);
  }

  const body = await c.req.json<{ name: string; args: Record<string, unknown> }>();
  if (!body.name || !body.args) {
    const resp: ApiResponse = {
      ok: false,
      error: { code: 'BAD_REQUEST', message: 'name and args are required' },
    };
    c.status(400);
    return c.json(resp);
  }

  try {
    const result = await mcpRuntime.callTool(body.name, body.args);
    const resp: ApiResponse = { ok: true, data: result };
    return c.json(resp);
  } catch (err) {
    const resp: ApiResponse = {
      ok: false,
      error: {
        code: 'MCP_ERROR',
        message: err instanceof Error ? err.message : 'MCP call failed',
      },
    };
    c.status(500);
    return c.json(resp);
  }
});