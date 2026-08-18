#!/usr/bin/env node

/**
 * @file yyc3-cli.js
 * @description YYC³ CLI 主入口点
 * @module cli/entry
 * @author YYC³
 * @version 2.0.0
 * @created 2025-01-30
 * @updated 2025-01-30
 * @copyright Copyright (c) 2025 YYC³
 * @license MIT
 */

const { program } = require('commander');
const pkg = require('../package.json');
const { initProject, deployProject, buildProject, runTests, configureSettings } = require('../lib/index');
const { buildIndex } = require('../lib/skills-indexer');
const { validateAll } = require('../lib/skills-validator');
const { findDuplicates, findNameCollisions } = require('../lib/skills-deduper');
const { generateStats } = require('../lib/skills-stats');
const { lintNaming, migrateNaming } = require('../lib/skills-naming');

// 设置全局错误处理
process.on('uncaughtException', (error) => {
  console.error(`\n🔴 未捕获的异常: ${error.message}`);
  console.error(`📋 堆栈跟踪:\n${error.stack}`);
  process.exit(1);
});

process.on('unhandledRejection', (reason, promise) => {
  console.error(`\n🔴 未处理的 Promise 拒绝: ${reason}`);
  process.exit(1);
});

program
  .name('yyc3')
  .version(pkg.version)
  .description('YYC³ 命令行界面 - 言启象限 | 语枢未来')
  .usage('<command> [options]')
  .helpOption('-h, --help', '显示帮助信息')
  .addHelpCommand('help [command]', '显示指定命令的帮助信息');

// init 命令
program
  .command('init [project-name]')
  .description('初始化新的 YYC³ 项目')
  .option('-t, --template <template>', '指定项目模板 (default: "basic")', 'basic')
  .option('-p, --port <port>', '指定服务端口 (default: 3200)', parseInt)
  .option('-y, --yes', '跳过确认提示', false)
  .action(async (projectName, options) => {
    try {
      await initProject(projectName, options);
      console.log(`\n✅ YYC³ 项目 "${projectName || '新项目'}" 初始化完成！`);
      console.log('🚀 开始你的 YYC³ 之旅：');
      console.log('   cd ' + (projectName || '新项目'));
      console.log('   npm run dev\n');
    } catch (error) {
      console.error(`\n🔴 初始化失败: ${error.message}`);
      process.exit(1);
    }
  });

// deploy 命令
program
  .command('deploy [environment]')
  .description('部署 YYC³ 应用到指定环境')
  .option('-e, --env <env>', '部署环境 (dev/staging/prod)', 'dev')
  .option('-f, --force', '强制部署（跳过检查）', false)
  .option('-c, --config <path>', '自定义配置文件路径')
  .action(async (environment, options) => {
    try {
      await deployProject(environment, options);
      console.log(`\n✅ 部署到 ${environment || options.env} 环境完成！`);
    } catch (error) {
      console.error(`\n🔴 部署失败: ${error.message}`);
      process.exit(1);
    }
  });

// build 命令
program
  .command('build')
  .description('构建 YYC³ 应用')
  .option('-m, --mode <mode>', '构建模式 (development/production)', 'production')
  .option('-o, --output <dir>', '输出目录', 'dist')
  .option('-a, --analyze', '启用包分析', false)
  .action(async (options) => {
    try {
      await buildProject(options);
      console.log('\n✅ 构建完成！');
    } catch (error) {
      console.error(`\n🔴 构建失败: ${error.message}`);
      process.exit(1);
    }
  });

// test 命令
program
  .command('test')
  .description('运行 YYC³ 测试套件')
  .option('-w, --watch', '监听模式', false)
  .option('-c, --coverage', '生成覆盖率报告', false)
  .option('-u, --update', '更新快照', false)
  .action(async (options) => {
    try {
      await runTests(options);
      console.log('\n✅ 测试运行完成！');
    } catch (error) {
      console.error(`\n🔴 测试失败: ${error.message}`);
      process.exit(1);
    }
  });

// config 命令
program
  .command('config')
  .description('配置 YYC³ 设置')
  .option('-g, --get <key>', '获取配置值')
  .option('-s, --set <key> <value>', '设置配置值')
  .option('-l, --list', '列出所有配置', false)
  .option('-r, --reset', '重置为默认配置', false)
  .action(async (options) => {
    try {
      await configureSettings(options);
      if (options.list) console.log('\n✅ 配置列表已显示');
      else if (options.get) console.log('\n✅ 配置值获取成功');
      else if (options.set) console.log('\n✅ 配置设置成功');
      else if (options.reset) console.log('\n✅ 配置重置完成');
    } catch (error) {
      console.error(`\n🔴 配置操作失败: ${error.message}`);
      process.exit(1);
    }
  });

// skills 命令组
const skills = program.command('skills').description('Skills 工作区管理');

skills
  .command('build')
  .description('构建 Skills 索引')
  .option('-o, --output <path>', '输出路径')
  .action(async (options) => {
    try { await buildIndex(options); } catch (e) { console.error('Error:', e.message); process.exit(1); }
  });

skills
  .command('validate')
  .description('验证 Skills 完整性')
  .option('-v, --verbose', '详细输出')
  .action(async (options) => {
    try { await validateAll(options); } catch (e) { console.error('Error:', e.message); process.exit(1); }
  });

skills
  .command('dedup')
  .description('检测重复文件')
  .option('-v, --verbose', '详细输出')
  .option('--names', '分析同名技能冲突（IDENT/VARIANT 分类）', false)
  .action(async (options) => {
    try {
      if (options.names) { await findNameCollisions(options); }
      else { await findDuplicates(options); }
    } catch (e) { console.error('Error:', e.message); process.exit(1); }
  });

skills
  .command('stats')
  .description('生成统计报告')
  .option('-v, --verbose', '详细输出')
  .action(async (options) => {
    try { await generateStats(options); } catch (e) { console.error('Error:', e.message); process.exit(1); }
  });

// naming 命令组（AYNC 编码）
const naming = skills.command('naming').description('命名规范工具（AYNC 编码）');

naming
  .command('lint')
  .description('检查命名合规性（kebab-case + AYNC 编码统计）')
  .option('-v, --verbose', '详细输出违规清单')
  .action(async (options) => {
    try { await lintNaming(options); } catch (e) { console.error('Error:', e.message); process.exit(1); }
  });

naming
  .command('migrate')
  .description('生成 AYNC 命名迁移计划（默认 dry-run）')
  .option('--apply', '执行迁移（默认 dry-run）', false)
  .option('-v, --verbose', '输出完整迁移清单')
  .action(async (options) => {
    try { await migrateNaming(options); } catch (e) { console.error('Error:', e.message); process.exit(1); }
  });

// 默认命令（显示帮助）
program
  .command('help', { isDefault: true })
  .description('显示帮助信息')
  .action(() => {
    program.help();
  });

// 解析命令行参数
program.parse(process.argv);

// 如果没有提供任何参数，显示帮助
if (!process.argv.slice(2).length) {
  program.help();
}
