const { execSync } = require('child_process');
const fs = require('fs');
const path = require('path');

describe('YYC3 CLI - Core Tests', () => {
  const cliPath = path.join(__dirname, '../bin/yyc3-cli.js');

  test('CLI version check', () => {
    const output = execSync(`node ${cliPath} --version`, { encoding: 'utf-8' }).trim();
    expect(output).toMatch(/^\d+\.\d+\.\d+$/);
  });

  test('CLI help output', () => {
    const output = execSync(`node ${cliPath} --help`, { encoding: 'utf-8' });
    expect(output).toContain('command');
    expect(output).toContain('init');
    expect(output).toContain('deploy');
    expect(output).toContain('skills');
  });

  test('skills 子命令组包含完整命令集', () => {
    const output = execSync(`node ${cliPath} skills --help`, { encoding: 'utf-8' });
    expect(output).toContain('build');
    expect(output).toContain('validate');
    expect(output).toContain('dedup');
    expect(output).toContain('stats');
    expect(output).toContain('naming');
  });

  test('naming 子命令帮助可用', () => {
    const output = execSync(`node ${cliPath} skills naming --help`, { encoding: 'utf-8' });
    expect(output).toContain('lint');
    expect(output).toContain('migrate');
  });

  test('unknown command falls back to help with exit 0', () => {
    // Commander 默认命令为 help：未知命令显示帮助并以 0 退出
    const output = execSync(`node ${cliPath} nonexistent-command`, { encoding: 'utf-8' });
    expect(output).toContain('Usage');
  });
});

describe('YYC3 CLI - P2 修复（端口段 / config set）', () => {
  const cliPath = path.join(__dirname, '../bin/yyc3-cli.js');

  // 团队端口规范「3030 起」：3030-3039 必须在允许区
  test('validatePort 放行团队端口段 3030-3039', () => {
    const { validator } = require('../lib/index');
    expect(validator.validatePort('3030')).toBe(3030);
    expect(validator.validatePort('3031')).toBe(3031);
    expect(validator.validatePort('3032')).toBe(3032);
    expect(validator.validatePort('3039')).toBe(3039);
  });

  test('validatePort 仍拦截 3000-3029 / 3100-3199', () => {
    const { validator } = require('../lib/index');
    expect(() => validator.validatePort('3000')).toThrow('限用范围');
    expect(() => validator.validatePort('3029')).toThrow('限用范围');
    expect(() => validator.validatePort('3100')).toThrow('限用范围');
    expect(() => validator.validatePort('3199')).toThrow('限用范围');
  });

  test('config --set key=value 生效（原死分支修复）', () => {
    // 在临时 HOME 下运行，避免污染真实 ~/.yyc3 配置
    const os = require('os');
    const tmpHome = fs.mkdtempSync(path.join(os.tmpdir(), 'yyc3-cli-home-'));
    const output = execSync(`node ${cliPath} config --set test.p2fix=hello-p2`, {
      encoding: 'utf-8',
      env: { ...process.env, HOME: tmpHome, USERPROFILE: tmpHome },
    });
    expect(output).toContain('hello-p2');
    const getOut = execSync(`node ${cliPath} config --get test.p2fix`, {
      encoding: 'utf-8',
      env: { ...process.env, HOME: tmpHome, USERPROFILE: tmpHome },
    });
    expect(getOut).toContain('hello-p2');
    fs.rmSync(tmpHome, { recursive: true, force: true });
  }, 30_000);

  test('config --set 缺少 = 报用法错误', () => {
    const os = require('os');
    const tmpHome = fs.mkdtempSync(path.join(os.tmpdir(), 'yyc3-cli-home-'));
    let failed = false;
    try {
      execSync(`node ${cliPath} config --set nokey`, {
        encoding: 'utf-8',
        env: { ...process.env, HOME: tmpHome, USERPROFILE: tmpHome },
        stdio: 'pipe',
      });
    } catch (err) {
      failed = true;
      // 输出为「用法: yyc3 config --set <key>=<value>」
      expect(String(err.stderr || err.stdout)).toContain('--set <key>=<value>');
    }
    expect(failed).toBe(true);
    fs.rmSync(tmpHome, { recursive: true, force: true });
  });
});

describe('YYC3 CLI - Package Configuration', () => {
  test('package.json is valid', () => {
    const packageJson = require('../package.json');

    expect(packageJson.name).toBe('yyc3-cli');
    expect(packageJson.version).toMatch(/^\d+\.\d+\.\d+$/);
    expect(packageJson.bin).toBeDefined();
    expect(packageJson.scripts).toHaveProperty('test');
    expect(packageJson.scripts).toHaveProperty('build');
    expect(packageJson.license).toBe('MIT');
  });

  test('project structure is complete', () => {
    const requiredFiles = [
      'package.json',
      'bin/yyc3-cli.js',
      'lib/index.js',
      'lib/skills-indexer.js',
      'lib/skills-validator.js',
      'lib/skills-deduper.js',
      'lib/skills-stats.js',
      'lib/skills-naming.js',
    ];

    requiredFiles.forEach(file => {
      const filePath = path.join(__dirname, '..', file);
      expect(fs.existsSync(filePath)).toBeTruthy();
    });
  });
});
