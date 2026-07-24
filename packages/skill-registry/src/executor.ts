/**
 * @description YYC³ Skill 执行器 — 含降级熔断机制
 * @module @yyc3/skill-registry/executor
 *
 * 实现 Skill 的安全执行：
 * - 参数验证
 * - 超时控制
 * - 降级链自动执行
 * - 熔断器模式（Circuit Breaker）
 * - 执行结果追踪
 */

import { spawn } from 'child_process';
import type {
  UnifiedSkill,
  SkillExecutionContext,
  SkillExecutionResult,
} from './types.js';
import type { SkillRegistry } from './registry.js';

// ==================== 熔断器 ====================

type CircuitState = 'closed' | 'open' | 'half-open';

interface CircuitBreakerConfig {
  /** 失败阈值（连续失败多少次后熔断） */
  failureThreshold: number;
  /** 熔断恢复时间（毫秒） */
  recoveryTimeout: number;
  /** 半开状态最大探测请求数 */
  halfOpenMaxCalls: number;
}

class CircuitBreaker {
  private state: CircuitState = 'closed';
  private failureCount: number = 0;
  private lastFailureTime: number = 0;
  private halfOpenCalls: number = 0;

  constructor(private config: CircuitBreakerConfig) {}

  canExecute(): boolean {
    switch (this.state) {
      case 'closed':
        return true;
      case 'open': {
        const elapsed = Date.now() - this.lastFailureTime;
        if (elapsed >= this.config.recoveryTimeout) {
          this.state = 'half-open';
          this.halfOpenCalls = 0;
          return true;
        }
        return false;
      }
      case 'half-open':
        return this.halfOpenCalls < this.config.halfOpenMaxCalls;
    }
  }

  recordSuccess(): void {
    this.failureCount = 0;
    if (this.state === 'half-open') {
      this.state = 'closed';
    }
  }

  recordFailure(): void {
    this.failureCount++;
    this.lastFailureTime = Date.now();
    if (this.state === 'half-open') {
      this.state = 'open';
    } else if (this.failureCount >= this.config.failureThreshold) {
      this.state = 'open';
    }
  }

  getState(): CircuitState {
    return this.state;
  }

  reset(): void {
    this.state = 'closed';
    this.failureCount = 0;
    this.lastFailureTime = 0;
    this.halfOpenCalls = 0;
  }
}

// ==================== 执行器 ====================

export class SkillExecutor {
  private breakers: Map<string, CircuitBreaker> = new Map();
  private defaultConfig: CircuitBreakerConfig = {
    failureThreshold: 3,
    recoveryTimeout: 60_000,
    halfOpenMaxCalls: 1,
  };

  constructor(
    private registry: SkillRegistry,
    breakerConfig?: Partial<CircuitBreakerConfig>
  ) {
    if (breakerConfig) {
      this.defaultConfig = { ...this.defaultConfig, ...breakerConfig };
    }
  }

  /**
   * 执行 Skill（含降级链自动执行）
   */
  async execute(
    skillId: string,
    args: Record<string, unknown>,
    context?: Partial<SkillExecutionContext>
  ): Promise<SkillExecutionResult> {
    const ctx: SkillExecutionContext = {
      callId: context?.callId || `call-${Date.now()}-${Math.random().toString(36).slice(2, 8)}`,
      allowFallback: context?.allowFallback ?? true,
      maxFallbackDepth: context?.maxFallbackDepth ?? 3,
      timeout: context?.timeout ?? 30_000,
      cwd: context?.cwd,
      env: context?.env,
      ...context,
    };

    return this.executeWithFallback(skillId, args, ctx, 0);
  }

  /**
   * 带降级链的递归执行
   */
  private async executeWithFallback(
    skillId: string,
    args: Record<string, unknown>,
    ctx: SkillExecutionContext,
    depth: number
  ): Promise<SkillExecutionResult> {
    const skill = this.registry.get(skillId);
    if (!skill) {
      return {
        callId: ctx.callId,
        skillId,
        success: false,
        output: null,
        error: `Skill not found: ${skillId}`,
      };
    }

    // 检查熔断器
    const breaker = this.getOrCreateBreaker(skillId);
    if (!breaker.canExecute()) {
      // 尝试降级
      if (ctx.allowFallback && skill.fallback && depth < (ctx.maxFallbackDepth ?? 3)) {
        return this.executeWithFallback(skill.fallback, args, ctx, depth + 1);
      }
      return {
        callId: ctx.callId,
        skillId,
        success: false,
        output: null,
        error: `Circuit breaker is open for skill: ${skillId}`,
        fellBack: depth > 0,
        executedSkillId: depth > 0 ? skillId : undefined,
      };
    }

    // 执行
    const startTime = Date.now();
    try {
      const result = await this.executeSkill(skill, args, ctx);
      const duration = Date.now() - startTime;

      if (result.success) {
        breaker.recordSuccess();
      } else {
        breaker.recordFailure();
        // 执行失败，尝试降级
        if (ctx.allowFallback && skill.fallback && depth < (ctx.maxFallbackDepth ?? 3)) {
          const fallbackResult = await this.executeWithFallback(
            skill.fallback,
            args,
            ctx,
            depth + 1
          );
          return {
            ...fallbackResult,
            fellBack: true,
            executedSkillId: fallbackResult.executedSkillId || skill.fallback,
            metadata: {
              ...fallbackResult.metadata,
              originalError: result.error,
              originalDuration: duration,
            },
          };
        }
      }

      return {
        ...result,
        duration,
        fellBack: depth > 0,
        executedSkillId: skillId,
      };
    } catch (error) {
      breaker.recordFailure();
      const errorMsg = error instanceof Error ? error.message : String(error);
      const duration = Date.now() - startTime;

      // 尝试降级
      if (ctx.allowFallback && skill.fallback && depth < (ctx.maxFallbackDepth ?? 3)) {
        const fallbackResult = await this.executeWithFallback(
          skill.fallback,
          args,
          ctx,
          depth + 1
        );
        return {
          ...fallbackResult,
          fellBack: true,
          executedSkillId: fallbackResult.executedSkillId || skill.fallback,
          metadata: {
            ...fallbackResult.metadata,
            originalError: errorMsg,
            originalDuration: duration,
          },
        };
      }

      return {
        callId: ctx.callId,
        skillId,
        success: false,
        output: null,
        error: errorMsg,
        duration,
        fellBack: depth > 0,
        executedSkillId: skillId,
      };
    }
  }

  /**
   * 执行单个 Skill
   */
  private async executeSkill(
    skill: UnifiedSkill,
    args: Record<string, unknown>,
    ctx: SkillExecutionContext
  ): Promise<SkillExecutionResult> {
    switch (skill.runtime) {
      case 'python':
        return this.executeScript('python3', skill, args, ctx);
      case 'node':
        return this.executeScript('node', skill, args, ctx);
      case 'shell':
        return this.executeScript('bash', skill, args, ctx);
      case 'native':
        return {
          callId: ctx.callId,
          skillId: skill.id,
          success: true,
          output: { message: 'Native skill executed (placeholder)', skill: skill.id, args },
        };
      default:
        return {
          callId: ctx.callId,
          skillId: skill.id,
          success: false,
          output: null,
          error: `Unsupported runtime: ${skill.runtime}`,
        };
    }
  }

  /**
   * 通过子进程执行脚本
   */
  private executeScript(
    command: string,
    skill: UnifiedSkill,
    args: Record<string, unknown>,
    ctx: SkillExecutionContext
  ): Promise<SkillExecutionResult> {
    return new Promise(resolve => {
      if (!skill.entry) {
        resolve({
          callId: ctx.callId,
          skillId: skill.id,
          success: false,
          output: null,
          error: `No entry point defined for skill: ${skill.id}`,
        });
        return;
      }

      const entryPath = skill.source
        ? `${skill.source}/${skill.entry}`
        : skill.entry;

      const proc = spawn(command, [entryPath, JSON.stringify(args)], {
        cwd: ctx.cwd,
        env: { ...process.env, ...ctx.env },
        timeout: ctx.timeout,
      });

      let stdout = '';
      let stderr = '';

      proc.stdout.on('data', data => {
        stdout += data.toString();
      });

      proc.stderr.on('data', data => {
        stderr += data.toString();
      });

      proc.on('error', err => {
        resolve({
          callId: ctx.callId,
          skillId: skill.id,
          success: false,
          output: null,
          error: `Process error: ${err.message}`,
        });
      });

      proc.on('close', code => {
        if (code === 0) {
          resolve({
            callId: ctx.callId,
            skillId: skill.id,
            success: true,
            output: stdout.trim() || stderr.trim(),
          });
        } else {
          resolve({
            callId: ctx.callId,
            skillId: skill.id,
            success: false,
            output: null,
            error: stderr.trim() || `Process exited with code ${code}`,
          });
        }
      });
    });
  }

  /**
   * 获取或创建熔断器
   */
  private getOrCreateBreaker(skillId: string): CircuitBreaker {
    if (!this.breakers.has(skillId)) {
      this.breakers.set(skillId, new CircuitBreaker(this.defaultConfig));
    }
    return this.breakers.get(skillId)!;
  }

  /**
   * 获取熔断器状态
   */
  getCircuitState(skillId: string): CircuitState | undefined {
    return this.breakers.get(skillId)?.getState();
  }

  /**
   * 重置指定 Skill 的熔断器
   */
  resetBreaker(skillId: string): void {
    this.breakers.get(skillId)?.reset();
  }
}
