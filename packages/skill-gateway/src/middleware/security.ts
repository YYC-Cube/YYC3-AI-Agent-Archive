/**
 * Skill Gateway — 安全中间件
 *
 * 提供: 速率限制 / 安全头 / 请求体大小限制
 */
import type { MiddlewareHandler } from 'hono';
import type { ApiResponse } from '../types.js';
import { createRateLimitStore, MemoryStore, type RateLimitStore } from './rate-limit-store.js';

// ================================================================
// 1. 速率限制 (Token Bucket + 可插拔存储)
// ================================================================

interface RateLimitConfig {
  windowMs: number;
  maxRequests: number;
  /** 自定义存储后端（默认按 REDIS_URL 环境变量自动选择） */
  store?: RateLimitStore;
  keyGenerator?: (c: Parameters<MiddlewareHandler>[0]) => string;
}

interface CreatedRateLimiter extends MiddlewareHandler {
  /** 释放底层存储资源（server.ts 关闭时调用） */
  close: () => Promise<void>;
}

export function rateLimiter(config: RateLimitConfig = {
  windowMs: 60_000,
  maxRequests: 100,
}): CreatedRateLimiter {
  const { windowMs, maxRequests, keyGenerator } = config;

  // 存储异步初始化：首个请求前若未就绪则临时用内存桶，就绪后切换
  let store: RateLimitStore = new MemoryStore(windowMs);
  let backendName: 'redis' | 'memory' = 'memory';
  const ownedStore = config.store ? undefined : createRateLimitStore(windowMs);
  ownedStore
    ?.then(({ store: s, backend }) => {
      // 异步切换：保留内存桶中已扣减状态无必要（初始化窗口极短）
      const old = store;
      store = s;
      backendName = backend;
      if (old !== s) void old.close();
    })
    .catch(() => {
      // createRateLimitStore 内部已降级，此处仅兜底
    });

  const middleware = (async (c, next) => {
    const key = keyGenerator
      ? keyGenerator(c)
      : c.req.header('x-forwarded-for') || c.req.header('x-real-ip') || '127.0.0.1';

    let bucket: { tokens: number; lastRefill: number };
    try {
      bucket = await store.consume(key, { windowMs, maxRequests });
    } catch {
      // Redis 运行时故障：fail-open 记录并放行（高可用优先）
      bucket = { tokens: maxRequests - 1, lastRefill: Date.now() };
    }

    if (bucket.tokens < 0) {
      const resp: ApiResponse = {
        ok: false,
        error: {
          code: 'RATE_LIMIT_EXCEEDED',
          message: `请求过于频繁，请稍后重试。限制: ${maxRequests} 次/${windowMs / 1000}s`,
        },
      };
      c.status(429);
      c.header('Retry-After', String(Math.ceil(windowMs / 1000)));
      return c.json(resp);
    }

    c.header('X-RateLimit-Limit', String(maxRequests));
    c.header('X-RateLimit-Remaining', String(Math.floor(bucket.tokens)));
    c.header('X-RateLimit-Reset', String(Math.ceil((bucket.lastRefill + windowMs) / 1000)));
    c.header('X-RateLimit-Backend', backendName);

    await next();
  }) as CreatedRateLimiter;

  middleware.close = async () => {
    if (ownedStore) {
      const { store: s } = await ownedStore;
      await s.close();
    } else if (config.store) {
      await config.store.close();
    }
  };

  return middleware;
}

// ================================================================
// 2. 安全头 (Helmet-like)
// ================================================================

export function securityHeaders(): MiddlewareHandler {
  return async (c, next) => {
    await next();

    // 防止 MIME 类型嗅探
    c.header('X-Content-Type-Options', 'nosniff');
    // 防止点击劫持
    c.header('X-Frame-Options', 'DENY');
    // XSS 保护
    c.header('X-XSS-Protection', '0');
    // 引用策略
    c.header('Referrer-Policy', 'strict-origin-when-cross-origin');
    // 权限策略
    c.header('Permissions-Policy', 'camera=(), microphone=(), geolocation=()');
    // 移除服务端标识
    c.res.headers.delete('X-Powered-By');
    c.res.headers.delete('Server');
  };
}

// ================================================================
// 3. 请求体大小限制
// ================================================================

export function bodySizeLimit(maxBytes: number = 1024 * 1024): MiddlewareHandler {
  return async (c, next) => {
    const contentLength = Number(c.req.header('content-length') || 0);
    if (contentLength > maxBytes) {
      const resp: ApiResponse = {
        ok: false,
        error: {
          code: 'PAYLOAD_TOO_LARGE',
          message: `请求体过大，最大允许 ${(maxBytes / 1024 / 1024).toFixed(1)}MB`,
        },
      };
      c.status(413);
      return c.json(resp);
    }
    await next();
  };
}
