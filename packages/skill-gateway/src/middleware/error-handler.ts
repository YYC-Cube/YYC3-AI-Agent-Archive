/**
 * Skill Gateway — 错误处理中间件
 */
import type { MiddlewareHandler } from 'hono';
import type { ApiResponse } from '../types.js';

export function errorHandler(): MiddlewareHandler {
  return async (c, next) => {
    try {
      await next();
    } catch (err) {
      const message = err instanceof Error ? err.message : 'Internal Server Error';
      console.error(`[Gateway] Error: ${message}`, err);
      const body: ApiResponse = {
        ok: false,
        error: { code: 'INTERNAL_ERROR', message },
      };
      c.status(500);
      return c.json(body);
    }
  };
}