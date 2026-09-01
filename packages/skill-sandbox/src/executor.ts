/**
 * Skill Sandbox — 核心执行引擎
 *
 * 基于 child_process 实现安全隔离执行
 * 支持 Node / Python / Shell 运行时
 */
import { spawn, execSync } from 'node:child_process';
import type { SandboxRequest, SandboxResult, SandboxRuntime } from './types.js';

/** 运行时命令映射 */
const RUNTIME_COMMANDS: Record<SandboxRuntime, string> = {
  node: 'node',
  python: 'python3',
  shell: 'sh',
  native: '',
};

export class Executor {
  /** 执行沙箱请求 */
  static async execute(request: SandboxRequest, signal?: AbortSignal): Promise<SandboxResult> {
    const startTime = Date.now();

    try {
      const { command, args } = this.buildCommand(request);
      const timeout = request.timeout ?? 30_000;
      const maxOutput = request.maxOutput ?? 1024 * 1024; // 1MB

      return new Promise<SandboxResult>((resolve) => {
        const child = spawn(command, args, {
          env: { ...process.env, ...request.env },
          cwd: request.cwd ?? process.cwd(),
          timeout,
          stdio: ['pipe', 'pipe', 'pipe'],
        });

        let stdout = '';
        let stderr = '';
        let timedOut = false;
        let killed = false;

        const onData = (chunk: Buffer, stream: 'stdout' | 'stderr') => {
          const text = chunk.toString('utf-8');
          if (stream === 'stdout') {
            if (stdout.length < maxOutput) {
              stdout += text;
              if (stdout.length > maxOutput) {
                stdout = stdout.slice(0, maxOutput);
              }
            }
          } else {
            if (stderr.length < maxOutput) {
              stderr += text;
              if (stderr.length > maxOutput) {
                stderr = stderr.slice(0, maxOutput);
              }
            }
          }
        };

        child.stdout?.on('data', (chunk: Buffer) => onData(chunk, 'stdout'));
        child.stderr?.on('data', (chunk: Buffer) => onData(chunk, 'stderr'));

        child.on('error', (err) => {
          if (!killed) {
            resolve({
              ok: false,
              exitCode: -1,
              stdout: stdout.trimEnd(),
              stderr: stderr.trimEnd(),
              duration: Date.now() - startTime,
              timedOut: false,
              error: err.message,
            });
            killed = true;
          }
        });

        child.on('close', (exitCode, signal) => {
          if (killed) return;
          killed = true;

          resolve({
            ok: exitCode === 0,
            exitCode: exitCode ?? -1,
            stdout: stdout.trimEnd(),
            stderr: stderr.trimEnd(),
            duration: Date.now() - startTime,
            timedOut: signal === 'SIGTERM' || timedOut,
            signal: signal ?? undefined,
          });
        });

        // 监听 abort signal
        if (signal) {
          if (signal.aborted) {
            child.kill('SIGTERM');
            return;
          }
          signal.addEventListener('abort', () => {
            child.kill('SIGTERM');
          }, { once: true });
        }

        // 超时
        const timer = setTimeout(() => {
          timedOut = true;
          child.kill('SIGTERM');
        }, timeout);

        child.on('close', () => clearTimeout(timer));

        // 写入 stdin
        if (request.code) {
          child.stdin?.write(request.code);
          child.stdin?.end();
        }
      });
    } catch (err) {
      return {
        ok: false,
        exitCode: -1,
        stdout: '',
        stderr: '',
        duration: Date.now() - startTime,
        timedOut: false,
        error: err instanceof Error ? err.message : 'Unknown execution error',
      };
    }
  }

  /** 构建命令和参数 */
  private static buildCommand(request: SandboxRequest): { command: string; args: string[] } {
    const runtime = RUNTIME_COMMANDS[request.runtime];
    const code = request.code;

    switch (request.runtime) {
      case 'node':
        return { command: runtime, args: ['-e', code] };
      case 'python':
        return { command: runtime, args: ['-c', code] };
      case 'shell':
        return { command: runtime, args: ['-c', code] };
      case 'native':
        return {
          command: code.split(' ')[0],
          args: [...code.split(' ').slice(1), ...(request.args ?? [])],
        };
      default:
        throw new Error(`Unsupported runtime: ${request.runtime}`);
    }
  }

  /** 检查运行时是否可用 */
  static isRuntimeAvailable(runtime: SandboxRuntime): boolean {
    if (runtime === 'native') return true;
    try {
      execSync(`which ${RUNTIME_COMMANDS[runtime]}`, { stdio: 'ignore' });
      return true;
    } catch {
      return false;
    }
  }
}