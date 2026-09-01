/**
 * Skill Sandbox — 安全隔离执行环境
 *
 * 提供安全沙箱执行能力，包括：
 * - 多运行时支持 (Node/Python/Shell/Native)
 * - 代码安全检测（危险模式拦截）
 * - 输入净化（命令注入防护）
 * - 资源限制（超时/输出截断）
 * - 进程隔离（child_process）
 */
import { EventEmitter } from 'node:events';
import { Sanitizer } from './sanitizer.js';
import { Executor } from './executor.js';
import type {
  SandboxRequest,
  SandboxResult,
  SandboxConfig,
  SandboxRuntime,
  SandboxPolicy,
  SandboxEvents,
} from './types.js';

const DEFAULT_CONFIG: SandboxConfig = {
  defaultTimeout: 30_000,
  maxTimeout: 300_000,
  maxOutput: 1024 * 1024, // 1MB
  policy: 'strict',
  blockedCommands: [],
  allowedEnv: ['PATH', 'HOME', 'USER', 'LANG', 'TZ'],
  workDir: '/tmp/yyc3-sandbox',
};

export class SkillSandbox extends EventEmitter {
  readonly config: SandboxConfig;
  readonly sanitizer: Sanitizer;

  constructor(config: Partial<SandboxConfig> = {}) {
    super();
    this.config = { ...DEFAULT_CONFIG, ...config };
    this.sanitizer = new Sanitizer(this.config.policy, this.config.blockedCommands);
  }

  /** 执行代码 */
  async execute(request: SandboxRequest, signal?: AbortSignal): Promise<SandboxResult> {
    // 1. 安全检测
    const validation = this.sanitizer.validate(request.code, request.runtime);
    if (!validation.safe) {
      this.emit('execution:blocked', request, validation.reason ?? 'Blocked by security policy');
      return {
        ok: false,
        exitCode: -1,
        stdout: '',
        stderr: validation.reason ?? 'Blocked',
        duration: 0,
        timedOut: false,
        error: `SECURITY_BLOCKED: ${validation.reason}`,
      };
    }

    // 2. 参数净化
    const sanitizedRequest: SandboxRequest = {
      ...request,
      args: request.args ? this.sanitizer.sanitizeArgs(request.args) : undefined,
      env: request.env ? this.sanitizer.sanitizeEnv(request.env) : undefined,
      timeout: Math.min(request.timeout ?? this.config.defaultTimeout, this.config.maxTimeout),
      maxOutput: request.maxOutput ?? this.config.maxOutput,
    };

    // 3. 执行
    this.emit('execution:start', sanitizedRequest);

    const result = await Executor.execute(sanitizedRequest, signal);

    if (result.timedOut) {
      this.emit('execution:timeout', sanitizedRequest);
    } else if (!result.ok) {
      this.emit('execution:error', sanitizedRequest, result.error ?? result.stderr);
    } else {
      this.emit('execution:complete', result);
    }

    return result;
  }

  /** 检查运行时是否可用 */
  static isRuntimeAvailable(runtime: SandboxRuntime): boolean {
    return Executor.isRuntimeAvailable(runtime);
  }

  /** 获取安全策略 */
  getPolicy(): SandboxPolicy {
    return this.config.policy;
  }
}

// 重新导出类型
export type {
  SandboxRequest,
  SandboxResult,
  SandboxConfig,
  SandboxRuntime,
  SandboxPolicy,
  SandboxEvents,
} from './types.js';
export { Sanitizer } from './sanitizer.js';
export { Executor } from './executor.js';