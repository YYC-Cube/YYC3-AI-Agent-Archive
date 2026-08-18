# YYC3-CLI i18n 集成指南

> 将 `@yyc3/i18n-core` 命令注入 YYC3-CLI 的 `yyc3 i18n` 子命令组

## 集成步骤

### 1. 复制 i18n 命令模块

```bash
cp packages/cli-integration/i18n-commands.js /Users/yanyu/YYC-Cube/YYC3-CLI/lib/i18n.js
```

### 2. 在 bin/yyc3-cli.js 中注册 i18n 命令组

在 `program.parse()` 之前添加：

```javascript
// ===== i18n 命令组 =====
const { initI18n, extractKeys, auditCoverage } = require('../lib/i18n');

const i18n = program.command('i18n').description('🌐 i18n 国际化管理工具');

// yyc3 i18n init
i18n
  .command('init [path]')
  .description('初始化 i18n 配置')
  .option('-l, --locales <locales>', '支持的语言 (逗号分隔)', 'en,zh-CN')
  .option('--react', '同时安装 React 组件包', false)
  .action(async (projectPath, options) => {
    try {
      await initI18n(projectPath, options);
      console.log('\n✅ i18n 初始化完成！');
    } catch (error) {
      console.error(`\n🔴 i18n 初始化失败: ${error.message}`);
      process.exit(1);
    }
  });

// yyc3 i18n extract
i18n
  .command('extract [source]')
  .description('从源码提取翻译键')
  .option('-o, --output <file>', '输出文件路径', 'locales/extracted-keys.json')
  .action(async (source, options) => {
    try {
      await extractKeys(source, options);
    } catch (error) {
      console.error(`\n🔴 提取失败: ${error.message}`);
      process.exit(1);
    }
  });

// yyc3 i18n audit
i18n
  .command('audit [dir]')
  .description('审计翻译覆盖率')
  .option('-o, --output <file>', '报告输出路径')
  .action(async (dir, options) => {
    try {
      await auditCoverage(dir, options);
    } catch (error) {
      console.error(`\n🔴 审计失败: ${error.message}`);
      process.exit(1);
    }
  });
```

### 3. 添加 glob 依赖

```bash
cd /Users/yanyu/YYC-Cube/YYC3-CLI
pnpm add glob
```

### 4. 使用

```bash
# 初始化 i18n（默认 en + zh-CN）
yyc3 i18n init . --locales en,zh-CN,ja --react

# 提取翻译键
yyc3 i18n extract "src/**/*.{ts,tsx}" --output locales/keys.json

# 审计覆盖率
yyc3 i18n audit src/locales --output coverage-report.json
```

## 命令一览

| 命令 | 功能 | 对应 i18n-core 模块 |
|------|------|-------------------|
| `yyc3 i18n init` | 创建 locales/ + 引擎配置 | `I18nEngine` 构造 |
| `yyc3 i18n extract` | 从 t() 调用提取键 | `i18n-audit.ts` |
| `yyc3 i18n audit` | 覆盖率/缺失键报告 | `i18n-audit.ts` |

## 后续 Phase 2 计划

- `yyc3 i18n translate --provider openai` — AI 批量翻译
- `yyc3 i18n mcp serve` — 启动 MCP Server
- `yyc3 i18n diff` — Git diff 翻译变更
