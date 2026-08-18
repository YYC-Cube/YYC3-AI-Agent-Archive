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
