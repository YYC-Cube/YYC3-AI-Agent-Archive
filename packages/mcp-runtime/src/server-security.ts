/**
 * MCP Runtime 独立服务 — 安全中间件
 *
 * 依赖方向约束：skill-gateway → mcp-runtime（不可反向），故不能直接复用
 * gateway 的 middleware 包。本模块与其保持【契约一致】：
 * - 同一环境变量 YYC3_API_KEYS / YYC3_TRUSTED_PROXY_HOPS
 * - 同一凭据携带方式（Authorization: Bearer / X-API-Key）
 * - 同一错误码（AUTH_SERVICE_DISABLED 503 / UNAUTHORIZED 401 / FORBIDDEN 403）
 * - 同一 fail-closed 策略与时延恒定比较
 *
 * 独立部署的 MCP 服务无"公开发现端点"需求：/health 公开（容器健康探测），
 * 其余 /api 路径（含 GET tools/list）一律要求认证。
 */
import type { MiddlewareHandler } from 'hono';
import { timingSafeEqual } from 'node:crypto';

// ----------------------------------------------------------------
// 认证
// ----------------------------------------------------------------

/** 时延恒定字符串比较，防止时序侧信道 */
function secureCompare(a: string, b: string): boolean {
  const ba = Buffer.from(a, 'utf-8');
  const bb = Buffer.from(b, 'utf-8');
  if (ba.length !== bb.length) {
    timingSafeEqual(ba, ba);
    return false;
  }
  return timingSafeEqual(ba, bb);
}

/** 从环境变量解析 API Key 列表（逗号分隔） */
export function apiKeysFromEnv(env: string | undefined): string[] {
  return (env ?? '')
    .split(',')
    .map((k) => k.trim())
    .filter((k) => k.length > 0);
}

function extractKey(headers: Headers): string | undefined {
  const bearer = headers.get('authorization');
  if (bearer?.startsWith('Bearer ')) {
    return bearer.slice(7).trim() || undefined;
  }
  return headers.get('x-api-key')?.trim() || undefined;
}

/**
 * fail-closed API Key 认证：保护除 /health 外的全部路径。
 * 未配置任何 key 时返回 503（服务不可用），而非静默放行。
 */
export function mcpApiKeyAuth(apiKeys: string[]): MiddlewareHandler {
  const keys = apiKeys.filter((k) => k.length > 0);

  return async (c, next) => {
    const path = new URL(c.req.url).pathname;
    if (path === '/health' || path === '/') {
      return next();
    }

    if (keys.length === 0) {
      c.status(503);
      return c.json({
        ok: false,
        error: {
          code: 'AUTH_SERVICE_DISABLED',
          message: 'MCP Runtime 未配置 API Key（YYC3_API_KEYS），独立服务端点已禁用',
        },
      });
    }

    const provided = extractKey(c.req.raw.headers);
    if (!provided) {
      c.status(401);
      return c.json({
        ok: false,
        error: {
          code: 'UNAUTHORIZED',
          message: '缺少认证凭据，请通过 Authorization: Bearer <key> 或 X-API-Key 提供',
        },
      });
    }

    if (!keys.some((k) => secureCompare(provided, k))) {
      c.status(403);
      return c.json({ ok: false, error: { code: 'FORBIDDEN', message: 'API Key 无效' } });
    }

    return next();
  };
}

// ----------------------------------------------------------------
// 安全头
// ----------------------------------------------------------------

export function mcpSecurityHeaders(): MiddlewareHandler {
  return async (c, next) => {
    await next();
    c.header('X-Content-Type-Options', 'nosniff');
    c.header('X-Frame-Options', 'DENY');
    c.header('X-XSS-Protection', '0');
    c.header('Referrer-Policy', 'strict-origin-when-cross-origin');
    c.header('Permissions-Policy', 'camera=(), microphone=(), geolocation=()');
    c.res.headers.delete('X-Powered-By');
    c.res.headers.delete('Server');
  };
}

// ----------------------------------------------------------------
// 请求体大小限制（Content-Length 快速拒绝；chunked 计数限流为 P2 项）
// ----------------------------------------------------------------

export function mcpBodySizeLimit(maxBytes = 1024 * 1024): MiddlewareHandler {
  return async (c, next) => {
    const contentLength = Number(c.req.header('content-length') || 0);
    if (contentLength > maxBytes) {
      c.status(413);
      return c.json({
        ok: false,
        error: {
          code: 'PAYLOAD_TOO_LARGE',
          message: `请求体过大，最大允许 ${(maxBytes / 1024 / 1024).toFixed(1)}MB`,
        },
      });
    }
    await next();
  };
}

// ----------------------------------------------------------------
// 受信代理跳数解析（与 gateway resolveClientIp 同契约）
// ----------------------------------------------------------------

export function resolveClientIp(
  headers: { 'x-forwarded-for'?: string; 'x-real-ip'?: string },
  trustedProxyHops: number,
  fallbackIp = '127.0.0.1',
): string {
  if (trustedProxyHops > 0) {
    const xff = headers['x-forwarded-for'];
    if (xff) {
      const chain = xff.split(',').map((s) => s.trim()).filter(Boolean);
      const idx = chain.length - trustedProxyHops;
      if (idx >= 0 && chain[idx]) return chain[idx];
      if (chain.length > 0) return chain[0];
    }
    const realIp = headers['x-real-ip'];
    if (realIp) return realIp.trim();
  }
  return fallbackIp;
}

export function trustedProxyHopsFromEnv(raw: string | undefined): number {
  const n = Number(raw ?? '0');
  return Number.isInteger(n) && n >= 0 ? n : 0;
}

// ----------------------------------------------------------------
// 内存 Token Bucket 限流（独立服务单机部署足够；分布式需求走 gateway 侧 Redis）
// ----------------------------------------------------------------

interface Bucket {
  tokens: number;
  lastRefill: number;
}

export interface MemoryRateLimitOptions {
  windowMs: number;
  maxRequests: number;
  trustedProxyHops?: number;
}

export function mcpRateLimiter(options: MemoryRateLimitOptions): MiddlewareHandler {
  const { windowMs, maxRequests, trustedProxyHops = 0 } = options;
  const buckets = new Map<string, Bucket>();

  return async (c, next) => {
    const key = resolveClientIp(
      {
        'x-forwarded-for': c.req.header('x-forwarded-for'),
        'x-real-ip': c.req.header('x-real-ip'),
      },
      trustedProxyHops,
    );

    const now = Date.now();
    const bucket = buckets.get(key) ?? { tokens: maxRequests, lastRefill: now };
    const elapsed = now - bucket.lastRefill;
    if (elapsed >= windowMs) {
      bucket.tokens = maxRequests;
      bucket.lastRefill = now;
    }
    bucket.tokens -= 1;
    buckets.set(key, bucket);

    c.header('X-RateLimit-Limit', String(maxRequests));
    c.header('X-RateLimit-Remaining', String(Math.max(0, Math.floor(bucket.tokens))));
    c.header('X-RateLimit-Reset', String(Math.ceil((bucket.lastRefill + windowMs) / 1000)));

    if (bucket.tokens < 0) {
      c.status(429);
      c.header('Retry-After', String(Math.ceil(windowMs / 1000)));
      return c.json({
        ok: false,
        error: {
          code: 'RATE_LIMIT_EXCEEDED',
          message: `请求过于频繁，请稍后重试。限制: ${maxRequests} 次/${windowMs / 1000}s`,
        },
      });
    }

    await next();
  };
}
