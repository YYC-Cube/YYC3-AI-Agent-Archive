const { exec } = require('child_process');
const util = require('util');
const execPromise = util.promisify(exec);
const path = require('path');

describe('YYC3 CLI - Integration Tests', () => {
  const cliPath = path.join(__dirname, '../bin/yyc3-cli.js');

  test('CLI loads and responds to version', async () => {
    const { stdout } = await execPromise(`node ${cliPath} --version`);
    expect(stdout.trim()).toMatch(/^\d+\.\d+\.\d+$/);
  });

  test('CLI help shows available commands', async () => {
    const { stdout } = await execPromise(`node ${cliPath} --help`);
    expect(stdout).toContain('init');
    expect(stdout).toContain('deploy');
    expect(stdout).toContain('skills');
  });

  test('skills validate 可执行（扫描 skills-hub）', async () => {
    // 集成冒烟：validate 扫描真实 skills-hub 并输出统计
    const { stdout } = await execPromise(`node ${cliPath} skills validate`, {
      maxBuffer: 10 * 1024 * 1024,
      cwd: path.join(__dirname, '../../..'),
    });
    expect(stdout).toContain('[skills:validate]');
  }, 120_000);

  test('unknown command falls back to help', async () => {
    // 默认 help 命令兜底：未知命令显示帮助，退出码 0
    const { stdout } = await execPromise(`node ${cliPath} xyz-nonexistent`);
    expect(stdout).toContain('Usage');
  });
});
