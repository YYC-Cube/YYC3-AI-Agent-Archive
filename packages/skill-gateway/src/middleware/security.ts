/**
 * Skill Gateway — 安全中间件
 *
 * 提供: 速率限制 / 安全头 / 请求体大小限制
 */
import type { MiddlewareHandler } from 'hono';
import type { ApiResponse } from '../types.js';

// ================================================================
// 1. 速率限制 (Token Bucket)
// ================================================================

interface RateLimitConfig {
  windowMs: number;
  maxRequests: number;
  keyGenerator?: (c: Parameters<MiddlewareHandler>[0]) => string;
}

interface Bucket {
  tokens: number;
  lastRefill: number;
}

export function rateLimiter(config: RateLimitConfig = {
  windowMs: 60_000,
  maxRequests: 100,
}): MiddlewareHandler {
  const buckets = new Map<string, Bucket>();
  const { windowMs, maxRequests, keyGenerator } = config;

  // 定期清理过期桶
  const cleanupInterval = setInterval(() => {
    const now = Date.now();
    for (const [key, bucket] of buckets) {
      if (now - bucket.lastRefill > windowMs * 2) {
        buckets.delete(key);
      }
    }
  }, windowMs * 5);
  if (cleanupInterval.unref) cleanupInterval.unref();

  return async (c, next) => {
    const key = keyGenerator
      ? keyGenerator(c)
      : c.req.header('x-forwarded-for') || c.req.header('x-real-ip') || '127.0.0.1';

    const now = Date.now();
    let bucket = buckets.get(key);

    if (!bucket) {
      bucket = { tokens: maxRequests, lastRefill: now };
      buckets.set(key, bucket);
    }

    // Token Bucket 算法: 按时间恢复 tokens
    const elapsed = now - bucket.lastRefill;
    const refillTokens = (elapsed / windowMs) * maxRequests;
    bucket.tokens = Math.min(maxRequests, bucket.tokens + refillTokens);
    bucket.lastRefill = now;

    bucket.tokens -= 1;

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

    await next();
  };
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