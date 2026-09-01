/**
 * Skill Gateway API — 类型定义
 * @module @yyc3/skill-gateway
 */

import type { SkillSearchOptions, SkillRegistryStats } from '@yyc3/skill-registry';

/** API 统一响应格式 */
export interface ApiResponse<T = unknown> {
  ok: boolean;
  data?: T;
  error?: { code: string; message: string; details?: unknown };
  meta?: { page?: number; pageSize?: number; total?: number; timestamp: string };
}

/** 技能查询参数 */
export interface SkillQueryParams {
  q?: string;
  domain?: string;
  type?: string;
  runtime?: string;
  status?: string;
  page?: number;
  pageSize?: number;
}

/** 技能执行请求 */
export interface SkillExecuteRequest {
  skillId: string;
  params: Record<string, unknown>;
  timeout?: number;
}

/** 技能执行结果 */
export interface SkillExecuteResult {
  skillId: string;
  duration: number;
  output: unknown;
  error?: string;
}

/** Gateway 配置 */
export interface GatewayConfig {
  port?: number;
  host?: string;
  skillsRootDir?: string;
  maxSkillsDepth?: number;
  defaultTimeout?: number;
  maxTimeout?: number;
  corsOrigins?: string[];
}

/** 健康检查响应 */
export interface HealthResponse {
  status: 'ok' | 'degraded' | 'down';
  uptime: number;
  version: string;
  skills: {
    total: number;
    byDomain: Record<string, number>;
    byType: Record<string, number>;
  };
}