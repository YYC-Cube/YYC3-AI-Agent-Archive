/**
 * Skill Gateway — Skills CRUD 路由
 *
 * GET    /api/v1/skills          — 列表/搜索
 * GET    /api/v1/skills/stats    — 统计信息
 * GET    /api/v1/skills/domains  — 领域列表
 * GET    /api/v1/skills/:id      — 获取单个
 * POST   /api/v1/skills/reload   — 重新加载
 */
import type { SkillSearchOptions } from '@yyc3/skill-registry';
import { Hono } from 'hono';
import '../context.js';
import type { ApiResponse, SkillQueryParams } from '../types.js';

export const skillsRoutes = new Hono();

// GET /api/v1/skills — 列表/搜索
skillsRoutes.get('/', (c) => {
  const registry = c.get('registry');
  const query = c.req.query() as unknown as SkillQueryParams;

  const options: SkillSearchOptions = {};
  if (query.q) options.query = query.q;
  if (query.domain) options.domain = query.domain as SkillSearchOptions['domain'];
  if (query.type) options.type = query.type as SkillSearchOptions['type'];
  if (query.runtime) options.runtime = query.runtime as SkillSearchOptions['runtime'];
  if (query.status) options.status = query.status as SkillSearchOptions['status'];

  let skills = registry.search(options);

  const page = Math.max(1, Number(query.page) || 1);
  const pageSize = Math.min(100, Math.max(1, Number(query.pageSize) || 20));
  const total = skills.length;
  const start = (page - 1) * pageSize;
  skills = skills.slice(start, start + pageSize);

  const body: ApiResponse = {
    ok: true,
    data: skills,
    meta: { page, pageSize, total, timestamp: new Date().toISOString() },
  };
  return c.json(body);
});

// GET /api/v1/skills/stats — 统计信息
skillsRoutes.get('/stats', (c) => {
  const registry = c.get('registry');
  const stats = registry.getStats();
  const body: ApiResponse = { ok: true, data: stats };
  return c.json(body);
});

// GET /api/v1/skills/domains — 领域列表
skillsRoutes.get('/domains', (c) => {
  const registry = c.get('registry');
  const stats = registry.getStats();
  const domains = Object.keys(stats.byDomain).sort();
  const body: ApiResponse = { ok: true, data: domains };
  return c.json(body);
});

// GET /api/v1/skills/:id — 获取单个
skillsRoutes.get('/:id', (c) => {
  const registry = c.get('registry');
  const id = c.req.param('id');
  const skill = registry.get(id);
  if (!skill) {
    const body: ApiResponse = { ok: false, error: { code: 'NOT_FOUND', message: `Skill '${id}' not found` } };
    c.status(404);
    return c.json(body);
  }
  const body: ApiResponse = { ok: true, data: skill };
  return c.json(body);
});

// POST /api/v1/skills/reload — 重新加载
skillsRoutes.post('/reload', (c) => {
  const loader = c.get('loader');
  loader.load();
  const registry = c.get('registry');
  const stats = registry.getStats();
  const body: ApiResponse = {
    ok: true,
    data: { reloaded: stats.totalSkills },
    meta: { timestamp: new Date().toISOString() },
  };
  return c.json(body);
});
