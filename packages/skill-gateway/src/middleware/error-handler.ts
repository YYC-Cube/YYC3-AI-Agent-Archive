/**
 * Skill Gateway — 错误处理中间件
 */
import type { ErrorHandler } from 'hono';
import type { ApiResponse } from '../types.js';

export function errorHandler(): ErrorHandler {
  return (err, c) => {
    const message = err instanceof Error ? err.message : 'Internal Server Error';
    console.error(`[Gateway] Error: ${message}`, err);
    const body: ApiResponse = {
      ok: false,
      error: { code: 'INTERNAL_ERROR', message },
    };
    return c.json(body, 500);
  };
}