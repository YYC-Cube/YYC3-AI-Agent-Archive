/**
 * Skill Sandbox — 输入净化器
 *
 * 负责检测和阻止危险代码、命令注入、路径遍历等攻击
 */
import type { SandboxRuntime, SandboxPolicy } from './types.js';

/** 危险模式列表 */
const DANGEROUS_PATTERNS: Record<SandboxRuntime, RegExp[]> = {
  python: [
    /__import__\s*\(\s*['"]os['"]\s*\)/,
    /__import__\s*\(\s*['"]subprocess['"]\s*\)/,
    /__import__\s*\(\s*['"]sys['"]\s*\)/,
    /__import__\s*\(\s*['"]shutil['"]\s*\)/,
    /os\.system\s*\(/,
    /os\.popen\s*\(/,
    /subprocess\.(call|Popen|run|check_output)\s*\(/,
    /eval\s*\(/,
    /exec\s*\(/,
    /compile\s*\(/,
    /open\s*\([^)]*['"]w/,
    /shutil\.(rmtree|move|copy)\s*\(/,
    /os\.(remove|unlink|rmdir|chmod|chown)\s*\(/,
    /socket\./,
    /requests\.(get|post|put|delete|patch)\s*\(/,
    /urllib\./,
  ],
  node: [
    /require\s*\(\s*['"]child_process['"]\s*\)/,
    /require\s*\(\s*['"]fs['"]\s*\)/,
    /require\s*\(\s*['"]net['"]\s*\)/,
    /require\s*\(\s*['"]http['"]\s*\)/,
    /require\s*\(\s*['"]https['"]\s*\)/,
    /require\s*\(\s*['"]dgram['"]\s*\)/,
    /process\.(exit|kill|abort)\s*\(/,
    /eval\s*\(/,
    /Function\s*\(/,
    /__proto__/,
    /constructor\s*\[/,
    /import\s*\(/,
  ],
  shell: [
    /rm\s+(-rf?\s+)?[~/]/,
    /mkfs\./,
    /dd\s+if=/,
    />\s*\/dev\//,
    /curl\s+.*\|\s*(ba)?sh/,
    /wget\s+.*\|\s*(ba)?sh/,
    /chmod\s+777/,
    /chown\s+root/,
    /:\s*\(\)\s*\{/,
    /\$\(\s*\)\s*\{/,
    /sudo\s+/,
    /passwd\s+/,
    /reboot/,
    /shutdown/,
    /kill\s+-9/,
    /mkfifo\s+/,
    /nc\s+-[el]/,
  ],
  native: [],
};

/** 黑名单命令 */
const BLOCKED_COMMANDS = new Set([
  'rm', 'rmdir', 'mkfs', 'dd', 'shutdown', 'reboot',
  'kill', 'pkill', 'killall', 'sudo', 'su', 'passwd',
  'chmod', 'chown', 'mount', 'umount', 'mkfifo',
  'groupadd', 'groupdel', 'groupmod', 'useradd', 'userdel', 'usermod',
  'ifdown', 'ifup', 'route', 'sysctl', 'systemctl',
  'lvremove', 'pvremove', 'vgremove',
]);

export class Sanitizer {
  private blockedCommands: Set<string>;
  private policy: SandboxPolicy;

  constructor(policy: SandboxPolicy = 'strict', extraBlocked: string[] = []) {
    this.policy = policy;
    this.blockedCommands = new Set([...BLOCKED_COMMANDS, ...extraBlocked]);
  }

  /** 净化代码，返回 { safe, reason } */
  validate(code: string, runtime: SandboxRuntime): { safe: boolean; reason?: string } {
    if (this.policy === 'permissive') {
      return { safe: true };
    }

    // 检查长度
    if (code.length > 100_000) {
      return { safe: false, reason: 'Code exceeds maximum length (100KB)' };
    }

    // 检查危险模式
    const patterns = DANGEROUS_PATTERNS[runtime];
    for (const pattern of patterns) {
      if (pattern.test(code)) {
        return { safe: false, reason: `Dangerous pattern detected: ${pattern.source}` };
      }
    }

    // 检查路径遍历
    if (/\.\.\/|\.\.\\/.test(code)) {
      return { safe: false, reason: 'Path traversal detected' };
    }

    return { safe: true };
  }

  /** 净化命令行参数 */
  sanitizeArgs(args: string[]): string[] {
    return args.map(arg => this.sanitizeArg(arg));
  }

  /** 净化单个参数 */
  sanitizeArg(arg: string): string {
    // 移除 shell 特殊字符
    return arg.replace(/[;&|`$(){}[\]<>!\\]/g, '');
  }

  /** 检查命令是否被禁止 */
  isCommandBlocked(command: string): boolean {
    const base = command.split('/').pop()?.split(' ')[0] ?? '';
    return this.blockedCommands.has(base.toLowerCase());
  }

  /** 净化环境变量 */
  sanitizeEnv(env: Record<string, string>): Record<string, string> {
    const sanitized: Record<string, string> = {};
    for (const [key, value] of Object.entries(env)) {
      // 只允许字母数字和下划线组成的 key
      if (/^[A-Za-z_][A-Za-z0-9_]*$/.test(key)) {
        sanitized[key] = this.sanitizeArg(value);
      }
    }
    return sanitized;
  }
}