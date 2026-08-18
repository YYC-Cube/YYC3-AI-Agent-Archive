---
@file: YYC3-开发者工具包.sh
@description: YYC³-CLI Shell脚本: YYC3-开发者工具包.sh
@author: YanYuCloudCube Team
@version: v1.0.0
@created: 2026-02-17
@updated: 2026-02-17
@status: published
@tags: [脚本],[Shell],[YYC³-CLI]
---

> ***YanYuCloudCube***
> 言启象限 | 语枢未来
> ***Words Initiate Quadrants, Language Serves as Core for the Future***
> 万象归元于云枢 | 深栈智启新纪元
> ***All things converge in the cloud pivot; Deep stacks ignite a new era of intelligence***

---

#!/bin/bash

# YYC³ 开发者工具包部署脚本
# 基于 YYC³ 开发环境构建企业级开发者工具包
# 作者：YYC³
# 版本：2.0
# 更新日期：2025-07-10

set -e

ROOT_DIR="/Volume2/YYC"
DEVKIT_DIR="/Volume2/YYC/yyc3-devkit"
NAS_IP="192.168.3.45"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[信息]${NC} $1"; }
log_success() { echo -e "${GREEN}[成功]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[警告]${NC} $1"; }
log_error() { echo -e "${RED}[错误]${NC} $1"; }
log_step() { echo -e "${PURPLE}[步骤]${NC} $1"; }
log_highlight() { echo -e "${CYAN}[重点]${NC} $1"; }

# 显示欢迎信息
show_welcome() {
    clear
    echo -e "${CYAN}"
    cat << 'EOF'
    ██╗   ██╗██╗   ██╗ ██████╗██████╗    ██████╗██╗     ██╗
    ╚██╗ ██╔╝╚██╗ ██╔╝██╔════╝╚════██╗  ██╔════╝██║     ██║
     ╚████╔╝  ╚████╔╝ ██║      █████╔╝  ██║     ██║     ██║
      ╚██╔╝    ╚██╔╝  ██║      ╚═══██╗  ██║     ██║     ██║
       ██║      ██║   ╚██████╗██████╔╝  ╚██████╗███████╗██║
       ╚═╝      ╚═╝    ╚═════╝╚═════╝    ╚═════╝╚══════╝╚═╝

    言语云³ 开发者工具包
    YanYu Cloud Cube Developer Kit
    =====================================
EOF
    echo -e "${NC}"
    echo ""
    echo "🚀 构建一致、专业的 YYC³ 生态系统"
    echo "📅 部署时间: $(date)"
    echo "🌐 目标服务器: $NAS_IP"
    echo "📁 安装目录: $DEVKIT_DIR"
    echo ""
}

# 创建项目结构
create_project_structure() {
    log_step "创建 YYC³ 开发者工具包项目结构..."

    # 主目录结构
    mkdir -p "$DEVKIT_DIR"/{design,templates,tools,packages,docs,examples}

    # 设计资源目录
    mkdir -p "$DEVKIT_DIR/design"/{brand,colors,fonts,icons,ui-components,patterns}
    mkdir -p "$DEVKIT_DIR/design/brand"/{logos,guidelines,assets}
    mkdir -p "$DEVKIT_DIR/design/colors"/{palettes,css-vars,scss-mixins}
    mkdir -p "$DEVKIT_DIR/design/fonts"/{web-fonts,configs,examples}
    mkdir -p "$DEVKIT_DIR/design/icons"/{svg,sprite,font}
    mkdir -p "$DEVKIT_DIR/design/ui-components"/{figma,sketch,xd}
    mkdir -p "$DEVKIT_DIR/design/patterns"/{layouts,interactions,animations}

    # 模板目录
    mkdir -p "$DEVKIT_DIR/templates"/{frontend,backend,fullstack,components,modules}
    mkdir -p "$DEVKIT_DIR/templates/frontend"/{nextjs,react,vue,mobile}
    mkdir -p "$DEVKIT_DIR/templates/backend"/{nodejs,microservice,serverless}
    mkdir -p "$DEVKIT_DIR/templates/fullstack"/{nextjs-api,mern,jamstack,electron}
    mkdir -p "$DEVKIT_DIR/templates/components"/{ui,functional,layout,page}
    mkdir -p "$DEVKIT_DIR/templates/modules"/{core,service,data,utility}

    # 工具目录
    mkdir -p "$DEVKIT_DIR/tools"/{cli,generators,ide-extensions,docker}
    mkdir -p "$DEVKIT_DIR/tools/cli"/{src,bin,templates,configs}
    mkdir -p "$DEVKIT_DIR/tools/generators"/{component,api,page,module}
    mkdir -p "$DEVKIT_DIR/tools/ide-extensions"/{vscode,webstorm,sublime}
    mkdir -p "$DEVKIT_DIR/tools/docker"/{dev-env,ci-cd,deployment}

    # NPM 包目录
    mkdir -p "$DEVKIT_DIR/packages"/{core,ui,hooks,forms,utils,configs}

    # 文档目录
    mkdir -p "$DEVKIT_DIR/docs"/{guides,api,tutorials,examples}
    mkdir -p "$DEVKIT_DIR/docs/guides"/{getting-started,best-practices,migration}
    mkdir -p "$DEVKIT_DIR/docs/api"/{components,functions,types}
    mkdir -p "$DEVKIT_DIR/docs/tutorials"/{beginner,intermediate,advanced}

    # 示例项目目录
    mkdir -p "$DEVKIT_DIR/examples"/{basic,intermediate,advanced,real-world}

    log_success "项目结构创建完成"
}

# 创建品牌设计资源
create_brand_assets() {
    log_step "创建品牌设计资源..."

    # 创建 Logo 资源
    cat > "$DEVKIT_DIR/design/brand/logos/logo-usage.md" << 'EOF'
# YYC³ Logo 使用指南

## Logo 变体

### 主 Logo
- `yyc3-logo-primary.svg` - 主要标识
- `yyc3-logo-primary-dark.svg` - 深色背景版本
- `yyc3-logo-primary-light.svg` - 浅色背景版本

### 图标版 Logo
- `yyc3-icon-16.png` - 16x16 favicon
- `yyc3-icon-32.png` - 32x32 favicon
- `yyc3-icon-64.png` - 64x64 应用图标
- `yyc3-icon-128.png` - 128x128 应用图标
- `yyc3-icon-256.png` - 256x256 应用图标

### 使用规范

1. **最小尺寸**: Logo 最小显示尺寸为 24px 高度
2. **安全区域**: Logo 周围保持等于 Logo 高度 1/4 的空白区域
3. **颜色使用**:
   - 主色版本用于品牌展示
   - 单色版本用于特殊场景
   - 反色版本用于深色背景

## 禁止使用

- 不得拉伸或压缩 Logo
- 不得改变 Logo 颜色（除指定变体外）
- 不得在复杂背景上使用透明版本
- 不得添加阴影或特效
EOF

    # 创建色彩系统
    cat > "$DEVKIT_DIR/design/colors/color-palette.json" << 'EOF'
{
  "yyc3": {
    "primary": {
      "50": "#f0f9ff",
      "100": "#e0f2fe",
      "200": "#bae6fd",
      "300": "#7dd3fc",
      "400": "#38bdf8",
      "500": "#0ea5e9",
      "600": "#0284c7",
      "700": "#0369a1",
      "800": "#075985",
      "900": "#0c4a6e"
    },
    "secondary": {
      "50": "#fafafa",
      "100": "#f4f4f5",
      "200": "#e4e4e7",
      "300": "#d4d4d8",
      "400": "#a1a1aa",
      "500": "#71717a",
      "600": "#52525b",
      "700": "#3f3f46",
      "800": "#27272a",
      "900": "#18181b"
    },
    "accent": {
      "50": "#fdf4ff",
      "100": "#fae8ff",
      "200": "#f5d0fe",
      "300": "#f0abfc",
      "400": "#e879f9",
      "500": "#d946ef",
      "600": "#c026d3",
      "700": "#a21caf",
      "800": "#86198f",
      "900": "#701a75"
    },
    "success": {
      "50": "#f0fdf4",
      "100": "#dcfce7",
      "200": "#bbf7d0",
      "300": "#86efac",
      "400": "#4ade80",
      "500": "#22c55e",
      "600": "#16a34a",
      "700": "#15803d",
      "800": "#166534",
      "900": "#14532d"
    },
    "warning": {
      "50": "#fffbeb",
      "100": "#fef3c7",
      "200": "#fde68a",
      "300": "#fcd34d",
      "400": "#fbbf24",
      "500": "#f59e0b",
      "600": "#d97706",
      "700": "#b45309",
      "800": "#92400e",
      "900": "#78350f"
    },
    "error": {
      "50": "#fef2f2",
      "100": "#fee2e2",
      "200": "#fecaca",
      "300": "#fca5a5",
      "400": "#f87171",
      "500": "#ef4444",
      "600": "#dc2626",
      "700": "#b91c1c",
      "800": "#991b1b",
      "900": "#7f1d1d"
    }
  }
}
EOF

    # 创建 CSS 变量文件
    cat > "$DEVKIT_DIR/design/colors/css-variables.css" << 'EOF'
/* YYC³ 设计系统 - CSS 变量 */

:root {
  /* 主色调 */
  --yyc3-primary-50: #f0f9ff;
  --yyc3-primary-100: #e0f2fe;
  --yyc3-primary-200: #bae6fd;
  --yyc3-primary-300: #7dd3fc;
  --yyc3-primary-400: #38bdf8;
  --yyc3-primary-500: #0ea5e9;
  --yyc3-primary-600: #0284c7;
  --yyc3-primary-700: #0369a1;
  --yyc3-primary-800: #075985;
  --yyc3-primary-900: #0c4a6e;

  /* 辅助色调 */
  --yyc3-secondary-50: #fafafa;
  --yyc3-secondary-100: #f4f4f5;
  --yyc3-secondary-200: #e4e4e7;
  --yyc3-secondary-300: #d4d4d8;
  --yyc3-secondary-400: #a1a1aa;
  --yyc3-secondary-500: #71717a;
  --yyc3-secondary-600: #52525b;
  --yyc3-secondary-700: #3f3f46;
  --yyc3-secondary-800: #27272a;
  --yyc3-secondary-900: #18181b;

  /* 强调色 */
  --yyc3-accent-500: #d946ef;
  --yyc3-accent-600: #c026d3;

  /* 语义色彩 */
  --yyc3-success: #22c55e;
  --yyc3-warning: #f59e0b;
  --yyc3-error: #ef4444;
  --yyc3-info: #0ea5e9;

  /* 字体 */
  --yyc3-font-family-sans: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
  --yyc3-font-family-mono: 'JetBrains Mono', 'Fira Code', Consolas, monospace;

  /* 字体大小 */
  --yyc3-text-xs: 0.75rem;
  --yyc3-text-sm: 0.875rem;
  --yyc3-text-base: 1rem;
  --yyc3-text-lg: 1.125rem;
  --yyc3-text-xl: 1.25rem;
  --yyc3-text-2xl: 1.5rem;
  --yyc3-text-3xl: 1.875rem;
  --yyc3-text-4xl: 2.25rem;

  /* 间距 */
  --yyc3-space-1: 0.25rem;
  --yyc3-space-2: 0.5rem;
  --yyc3-space-3: 0.75rem;
  --yyc3-space-4: 1rem;
  --yyc3-space-5: 1.25rem;
  --yyc3-space-6: 1.5rem;
  --yyc3-space-8: 2rem;
  --yyc3-space-10: 2.5rem;
  --yyc3-space-12: 3rem;
  --yyc3-space-16: 4rem;

  /* 圆角 */
  --yyc3-radius-sm: 0.125rem;
  --yyc3-radius: 0.25rem;
  --yyc3-radius-md: 0.375rem;
  --yyc3-radius-lg: 0.5rem;
  --yyc3-radius-xl: 0.75rem;
  --yyc3-radius-2xl: 1rem;
  --yyc3-radius-full: 9999px;

  /* 阴影 */
  --yyc3-shadow-sm: 0 1px 2px 0 rgb(0 0 0 / 0.05);
  --yyc3-shadow: 0 1px 3px 0 rgb(0 0 0 / 0.1), 0 1px 2px -1px rgb(0 0 0 / 0.1);
  --yyc3-shadow-md: 0 4px 6px -1px rgb(0 0 0 / 0.1), 0 2px 4px -2px rgb(0 0 0 / 0.1);
  --yyc3-shadow-lg: 0 10px 15px -3px rgb(0 0 0 / 0.1), 0 4px 6px -4px rgb(0 0 0 / 0.1);
  --yyc3-shadow-xl: 0 20px 25px -5px rgb(0 0 0 / 0.1), 0 8px 10px -6px rgb(0 0 0 / 0.1);
}

/* 深色主题 */
[data-theme="dark"] {
  --yyc3-bg-primary: var(--yyc3-secondary-900);
  --yyc3-bg-secondary: var(--yyc3-secondary-800);
  --yyc3-text-primary: var(--yyc3-secondary-50);
  --yyc3-text-secondary: var(--yyc3-secondary-300);
}

/* 浅色主题 */
[data-theme="light"] {
  --yyc3-bg-primary: var(--yyc3-secondary-50);
  --yyc3-bg-secondary: var(--yyc3-secondary-100);
  --yyc3-text-primary: var(--yyc3-secondary-900);
  --yyc3-text-secondary: var(--yyc3-secondary-600);
}
EOF

    # 创建 SCSS 混合文件
    cat > "$DEVKIT_DIR/design/colors/scss-mixins.scss" << 'EOF'
// YYC³ 设计系统 - SCSS 混合

// 颜色函数
@function yyc3-color($color, $shade: 500) {
  @return var(--yyc3-#{$color}-#{$shade});
}

// 间距混合
@mixin yyc3-spacing($property, $size) {
  #{$property}: var(--yyc3-space-#{$size});
}

// 字体混合
@mixin yyc3-text($size: base, $weight: normal) {
  font-size: var(--yyc3-text-#{$size});
  font-weight: $weight;
  font-family: var(--yyc3-font-family-sans);
}

// 按钮混合
@mixin yyc3-button($variant: primary, $size: md) {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  border-radius: var(--yyc3-radius);
  font-weight: 500;
  transition: all 0.2s ease-in-out;
  cursor: pointer;
  border: none;

  @if $size == sm {
    padding: var(--yyc3-space-2) var(--yyc3-space-3);
    font-size: var(--yyc3-text-sm);
  } @else if $size == lg {
    padding: var(--yyc3-space-3) var(--yyc3-space-6);
    font-size: var(--yyc3-text-lg);
  } @else {
    padding: var(--yyc3-space-2) var(--yyc3-space-4);
    font-size: var(--yyc3-text-base);
  }

  @if $variant == primary {
    background-color: yyc3-color(primary);
    color: white;

    &:hover {
      background-color: yyc3-color(primary, 600);
    }
  } @else if $variant == secondary {
    background-color: yyc3-color(secondary, 100);
    color: yyc3-color(secondary, 900);

    &:hover {
      background-color: yyc3-color(secondary, 200);
    }
  }
}

// 卡片混合
@mixin yyc3-card($padding: 6) {
  background-color: white;
  border-radius: var(--yyc3-radius-lg);
  box-shadow: var(--yyc3-shadow);
  padding: var(--yyc3-space-#{$padding});

  [data-theme="dark"] & {
    background-color: var(--yyc3-secondary-800);
    border: 1px solid var(--yyc3-secondary-700);
  }
}

// 输入框混合
@mixin yyc3-input() {
  width: 100%;
  padding: var(--yyc3-space-3);
  border: 1px solid var(--yyc3-secondary-300);
  border-radius: var(--yyc3-radius);
  font-size: var(--yyc3-text-base);
  transition: border-color 0.2s ease-in-out;

  &:focus {
    outline: none;
    border-color: yyc3-color(primary);
    box-shadow: 0 0 0 3px rgba(14, 165, 233, 0.1);
  }

  [data-theme="dark"] & {
    background-color: var(--yyc3-secondary-800);
    border-color: var(--yyc3-secondary-600);
    color: var(--yyc3-text-primary);
  }
}

// 响应式断点
$yyc3-breakpoints: (
  sm: 640px,
  md: 768px,
  lg: 1024px,
  xl: 1280px,
  2xl: 1536px
);

@mixin yyc3-responsive($breakpoint) {
  @media (min-width: map-get($yyc3-breakpoints, $breakpoint)) {
    @content;
  }
}
EOF

    log_success "品牌设计资源创建完成"
}

# 创建 CLI 工具
create_cli_tool() {
    log_step "创建 YYC³ CLI 工具..."

    # 创建 CLI 包结构
    mkdir -p "$DEVKIT_DIR/tools/cli"/{src,bin,templates,configs}

    # 创建 package.json
    cat > "$DEVKIT_DIR/tools/cli/package.json" << 'EOF'
{
  "name": "@yanyucloud/cli",
  "version": "1.0.0",
  "description": "YYC³ 开发者工具包 CLI",
  "main": "dist/index.js",
  "bin": {
    "yyc": "./bin/yyc.js",
    "yyc3": "./bin/yyc.js"
  },
  "scripts": {
    "build": "tsc",
    "dev": "tsc --watch",
    "start": "node dist/index.js",
    "test": "jest",
    "lint": "eslint src/**/*.ts",
    "format": "prettier --write src/**/*.ts"
  },
  "keywords": [
    "yanyucloud",
    "yyc3",
    "cli",
    "developer-tools",
    "scaffolding"
  ],
  "author": "YanYu Intelligence Cloud",
  "license": "MIT",
  "dependencies": {
    "commander": "^11.0.0",
    "inquirer": "^9.2.0",
    "chalk": "^5.3.0",
    "ora": "^7.0.0",
    "fs-extra": "^11.1.0",
    "mustache": "^4.2.0",
    "semver": "^7.5.0",
    "axios": "^1.5.0",
    "glob": "^10.3.0",
    "yaml": "^2.3.0"
  },
  "devDependencies": {
    "@types/node": "^20.5.0",
    "@types/inquirer": "^9.0.0",
    "@types/fs-extra": "^11.0.0",
    "@types/mustache": "^4.2.0",
    "@types/semver": "^7.5.0",
    "typescript": "^5.1.0",
    "jest": "^29.6.0",
    "@types/jest": "^29.5.0",
    "eslint": "^8.47.0",
    "@typescript-eslint/eslint-plugin": "^6.4.0",
    "@typescript-eslint/parser": "^6.4.0",
    "prettier": "^3.0.0"
  },
  "files": [
    "dist",
    "bin",
    "templates",
    "README.md"
  ],
  "engines": {
    "node": ">=16.0.0"
  }
}
EOF

    # 创建 CLI 入口文件
    cat > "$DEVKIT_DIR/tools/cli/bin/yyc.js" << 'EOF'
#!/usr/bin/env node

const { program } = require('commander');
const chalk = require('chalk');
const { version } = require('../package.json');

// 设置版本
program.version(version, '-v, --version', '显示版本号');

// 全局选项
program
  .option('-d, --debug', '启用调试模式')
  .option('-q, --quiet', '静默模式');

// 创建命令
program
  .command('create <type> <name>')
  .description('创建新项目或组件')
  .option('-t, --template <template>', '指定模板')
  .option('-p, --path <path>', '指定创建路径')
  .action(async (type, name, options) => {
    const { createCommand } = require('../dist/commands/create');
    await createCommand(type, name, options);
  });

// 生成命令
program
  .command('generate <type> <name>')
  .alias('g')
  .description('生成代码文件')
  .option('-p, --path <path>', '指定生成路径')
  .option('-f, --force', '强制覆盖现有文件')
  .action(async (type, name, options) => {
    const { generateCommand } = require('../dist/commands/generate');
    await generateCommand(type, name, options);
  });

// 构建命令
program
  .command('build')
  .description('构建项目')
  .option('-e, --env <env>', '指定环境', 'production')
  .option('-w, --watch', '监听模式')
  .action(async (options) => {
    const { buildCommand } = require('../dist/commands/build');
    await buildCommand(options);
  });

// 开发服务器命令
program
  .command('dev')
  .description('启动开发服务器')
  .option('-p, --port <port>', '指定端口', '3000')
  .option('-h, --host <host>', '指定主机', 'localhost')
  .action(async (options) => {
    const { devCommand } = require('../dist/commands/dev');
    await devCommand(options);
  });

// 代码检查命令
program
  .command('lint')
  .description('代码质量检查')
  .option('-f, --fix', '自动修复')
  .option('--format <format>', '输出格式', 'stylish')
  .action(async (options) => {
    const { lintCommand } = require('../dist/commands/lint');
    await lintCommand(options);
  });

// 品牌检查命令
program
  .command('brand-check')
  .description('品牌合规性检查')
  .option('-f, --fix', '自动修复')
  .option('-r, --report', '生成报告')
  .action(async (options) => {
    const { brandCheckCommand } = require('../dist/commands/brand-check');
    await brandCheckCommand(options);
  });

// 部署命令
program
  .command('deploy')
  .description('部署项目')
  .option('-e, --env <env>', '部署环境', 'production')
  .option('-c, --config <config>', '配置文件路径')
  .action(async (options) => {
    const { deployCommand } = require('../dist/commands/deploy');
    await deployCommand(options);
  });

// 初始化命令
program
  .command('init')
  .description('初始化 YYC³ 项目')
  .option('-f, --force', '强制初始化')
  .action(async (options) => {
    const { initCommand } = require('../dist/commands/init');
    await initCommand(options);
  });

// 升级命令
program
  .command('upgrade')
  .description('升级 YYC³ 工具包')
  .option('-c, --check', '仅检查更新')
  .action(async (options) => {
    const { upgradeCommand } = require('../dist/commands/upgrade');
    await upgradeCommand(options);
  });

// 错误处理
program.on('command:*', () => {
  console.error(chalk.red(`未知命令: ${program.args.join(' ')}`));
  console.log(chalk.yellow('使用 --help 查看可用命令'));
  process.exit(1);
});

// 解析命令行参数
program.parse();

// 如果没有提供命令，显示帮助
if (!process.argv.slice(2).length) {
  program.outputHelp();
}
EOF

    # 创建 TypeScript 配置
    cat > "$DEVKIT_DIR/tools/cli/tsconfig.json" << 'EOF'
{
  "compilerOptions": {
    "target": "ES2020",
    "module": "CommonJS",
    "lib": ["ES2020"],
    "outDir": "./dist",
    "rootDir": "./src",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "declaration": true,
    "declarationMap": true,
    "sourceMap": true,
    "resolveJsonModule": true,
    "moduleResolution": "node"
  },
  "include": [
    "src/**/*"
  ],
  "exclude": [
    "node_modules",
    "dist",
    "**/*.test.ts"
  ]
}
EOF

    # 创建主要命令文件
    mkdir -p "$DEVKIT_DIR/tools/cli/src"/{commands,utils,types,templates}

    # 创建 create 命令
    cat > "$DEVKIT_DIR/tools/cli/src/commands/create.ts" << 'EOF'
import { Command } from 'commander';
import inquirer from 'inquirer';
import chalk from 'chalk';
import ora from 'ora';
import fs from 'fs-extra';
import path from 'path';
import { execSync } from 'child_process';

interface CreateOptions {
  template?: string;
  path?: string;
}

export async function createCommand(type: string, name: string, options: CreateOptions) {
  const spinner = ora('正在创建项目...').start();

  try {
    // 验证项目名称
    if (!isValidProjectName(name)) {
      spinner.fail('项目名称无效');
      return;
    }

    // 确定项目路径
    const projectPath = options.path ? path.resolve(options.path, name) : path.resolve(name);

    // 检查目录是否存在
    if (await fs.pathExists(projectPath)) {
      spinner.stop();
      const { overwrite } = await inquirer.prompt([
        {
          type: 'confirm',
          name: 'overwrite',
          message: `目录 ${name} 已存在，是否覆盖？`,
          default: false
        }
      ]);

      if (!overwrite) {
        console.log(chalk.yellow('操作已取消'));
        return;
      }

      await fs.remove(projectPath);
      spinner.start('正在创建项目...');
    }

    // 根据类型创建项目
    switch (type) {
      case 'app':
        await createApp(name, projectPath, options);
        break;
      case 'component':
        await createComponent(name, projectPath, options);
        break;
      case 'service':
        await createService(name, projectPath, options);
        break;
      case 'fullstack':
        await createFullstack(name, projectPath, options);
        break;
      default:
        throw new Error(`不支持的项目类型: ${type}`);
    }

    spinner.succeed(chalk.green(`项目 ${name} 创建成功！`));

    // 显示后续步骤
    console.log(chalk.cyan('\n后续步骤:'));
    console.log(chalk.white(`  cd ${name}`));
    console.log(chalk.white('  npm install'));
    console.log(chalk.white('  npm run dev'));

  } catch (error) {
    spinner.fail(chalk.red(`创建失败: ${error.message}`));
    process.exit(1);
  }
}

async function createApp(name: string, projectPath: string, options: CreateOptions) {
  const template = options.template || 'nextjs';

  // 选择模板
  if (!options.template) {
    const { selectedTemplate } = await inquirer.prompt([
      {
        type: 'list',
        name: 'selectedTemplate',
        message: '选择应用模板:',
        choices: [
          { name: 'Next.js 应用', value: 'nextjs' },
          { name: 'React 应用', value: 'react' },
          { name: 'Vue 应用', value: 'vue' },
          { name: 'React Native 应用', value: 'react-native' }
        ]
      }
    ]);
    template = selectedTemplate;
  }

  // 复制模板文件
  const templatePath = path.join(__dirname, '../../templates/frontend', template);
  await fs.copy(templatePath, projectPath);

  // 更新 package.json
  const packageJsonPath = path.join(projectPath, 'package.json');
  const packageJson = await fs.readJson(packageJsonPath);
  packageJson.name = name;
  await fs.writeJson(packageJsonPath, packageJson, { spaces: 2 });

  // 安装依赖
  execSync('npm install', { cwd: projectPath, stdio: 'inherit' });
}

async function createComponent(name: string, projectPath: string, options: CreateOptions) {
  // 组件创建逻辑
  const componentTemplate = `
import React from 'react';
import { cn } from '@/lib/utils';

interface ${name}Props {
  className?: string;
  children?: React.ReactNode;
}

export const ${name}: React.FC<${name}Props> = ({
  className,
  children,
  ...props
}) => {
  return (
    <div className={cn('yyc3-${name.toLowerCase()}', className)} {...props}>
      {children}
    </div>
  );
};

${name}.displayName = '${name}';

export default ${name};
`;

  await fs.ensureDir(projectPath);
  await fs.writeFile(path.join(projectPath, `${name}.tsx`), componentTemplate);

  // 创建样式文件
  const styleTemplate = `
.yyc3-${name.toLowerCase()} {
  /* ${name} 组件样式 */
}
`;

  await fs.writeFile(path.join(projectPath, `${name}.module.css`), styleTemplate);

  // 创建测试文件
  const testTemplate = `
import { render, screen } from '@testing-library/react';
import { ${name} } from './${name}';

describe('${name}', () => {
  it('renders correctly', () => {
    render(<${name}>Test content</${name}>);
    expect(screen.getByText('Test content')).toBeInTheDocument();
  });
});
`;

  await fs.writeFile(path.join(projectPath, `${name}.test.tsx`), testTemplate);
}

async function createService(name: string, projectPath: string, options: CreateOptions) {
  // 服务创建逻辑
  const template = options.template || 'nodejs';
  const templatePath = path.join(__dirname, '../../templates/backend', template);
  await fs.copy(templatePath, projectPath);

  // 更新配置
  const packageJsonPath = path.join(projectPath, 'package.json');
  const packageJson = await fs.readJson(packageJsonPath);
  packageJson.name = name;
  await fs.writeJson(packageJsonPath, packageJson, { spaces: 2 });
}

async function createFullstack(name: string, projectPath: string, options: CreateOptions) {
  // 全栈应用创建逻辑
  const template = options.template || 'nextjs-api';
  const templatePath = path.join(__dirname, '../../templates/fullstack', template);
  await fs.copy(templatePath, projectPath);

  // 更新配置
  const packageJsonPath = path.join(projectPath, 'package.json');
  const packageJson = await fs.readJson(packageJsonPath);
  packageJson.name = name;
  await fs.writeJson(packageJsonPath, packageJson, { spaces: 2 });
}

function isValidProjectName(name: string): boolean {
  return /^[a-z0-9-_]+$/.test(name) && name.length > 0 && name.length <= 50;
}
EOF

    # 创建品牌检查命令
    cat > "$DEVKIT_DIR/tools/cli/src/commands/brand-check.ts" << 'EOF'
import chalk from 'chalk';
import ora from 'ora';
import fs from 'fs-extra';
import path from 'path';
import glob from 'glob';

interface BrandCheckOptions {
  fix?: boolean;
  report?: boolean;
}

interface BrandIssue {
  file: string;
  line?: number;
  type: 'error' | 'warning' | 'info';
  message: string;
  rule: string;
}

export async function brandCheckCommand(options: BrandCheckOptions) {
  const spinner = ora('正在检查品牌合规性...').start();

  try {
    const issues: BrandIssue[] = [];

    // 检查文件头
    await checkFileHeaders(issues);

    // 检查命名约定
    await checkNamingConventions(issues);

    // 检查色彩使用
    await checkColorUsage(issues);

    // 检查组件使用
    await checkComponentUsage(issues);

    spinner.stop();

    // 显示结果
    displayResults(issues);

    // 自动修复
    if (options.fix) {
      await autoFix(issues);
    }

    // 生成报告
    if (options.report) {
      await generateReport(issues);
    }

    // 返回退出码
    const hasErrors = issues.some(issue => issue.type === 'error');
    process.exit(hasErrors ? 1 : 0);

  } catch (error) {
    spinner.fail(chalk.red(`品牌检查失败: ${error.message}`));
    process.exit(1);
  }
}

async function checkFileHeaders(issues: BrandIssue[]) {
  const files = glob.sync('**/*.{ts,tsx,js,jsx}', {
    ignore: ['node_modules/**', 'dist/**', '.next/**']
  });

  for (const file of files) {
    const content = await fs.readFile(file, 'utf-8');
    const lines = content.split('\n');

    // 检查是否有版权声明
    const hasCopyright = lines.some(line =>
      line.includes('Copyright') || line.includes('©')
    );

    if (!hasCopyright) {
      issues.push({
        file,
        line: 1,
        type: 'warning',
        message: '缺少版权声明',
        rule: 'copyright-header'
      });
    }

    // 检查是否有 YYC³ 标识
    const hasYYCBrand = lines.some(line =>
      line.includes('YYC³') || line.includes('YanYu Intelligence Cloud')
    );

    if (!hasYYCBrand && file.includes('component')) {
      issues.push({
        file,
        line: 1,
        type: 'info',
        message: '建议添加 YYC³ 品牌标识',
        rule: 'brand-identifier'
      });
    }
  }
}

async function checkNamingConventions(issues: BrandIssue[]) {
  const files = glob.sync('**/*.{ts,tsx}', {
    ignore: ['node_modules/**', 'dist/**', '.next/**']
  });

  for (const file of files) {
    const content = await fs.readFile(file, 'utf-8');

    // 检查组件命名
    const componentMatches = content.match(/export\s+(?:const|function)\s+(\w+)/g);
    if (componentMatches) {
      componentMatches.forEach(match => {
        const componentName = match.split(/\s+/).pop();
        if (componentName && file.includes('component') && !componentName.startsWith('YY')) {
          issues.push({
            file,
            type: 'warning',
            message: `组件 ${componentName} 建议使用 YY 前缀`,
            rule: 'component-naming'
          });
        }
      });
    }

    // 检查 CSS 类名
    const classMatches = content.match(/className=['"`]([^'"`]+)['"`]/g);
    if (classMatches) {
      classMatches.forEach(match => {
        const className = match.match(/['"`]([^'"`]+)['"`]/)?.[1];
        if (className && !className.includes('yyc3-') && !className.includes('YY')) {
          issues.push({
            file,
            type: 'info',
            message: `CSS 类名 ${className} 建议使用 yyc3- 前缀`,
            rule: 'css-naming'
          });
        }
      });
    }
  }
}

async function checkColorUsage(issues: BrandIssue[]) {
  const files = glob.sync('**/*.{css,scss,tsx,jsx}', {
    ignore: ['node_modules/**', 'dist/**', '.next/**']
  });

  const forbiddenColors = ['#ff0000', '#00ff00', '#0000ff', 'red', 'green', 'blue'];

  for (const file of files) {
    const content = await fs.readFile(file, 'utf-8');
    const lines = content.split('\n');

    lines.forEach((line, index) => {
      forbiddenColors.forEach(color => {
        if (line.includes(color) && !line.includes('//') && !line.includes('/*')) {
          issues.push({
            file,
            line: index + 1,
            type: 'error',
            message: `使用了非品牌色彩 ${color}，请使用 YYC³ 设计系统色彩`,
            rule: 'brand-colors'
          });
        }
      });
    });
  }
}

async function checkComponentUsage(issues: BrandIssue[]) {
  const files = glob.sync('**/*.{tsx,jsx}', {
    ignore: ['node_modules/**', 'dist/**', '.next/**']
  });

  for (const file of files) {
    const content = await fs.readFile(file, 'utf-8');

    // 检查是否使用了原生 HTML 元素而不是 YYC³ 组件
    const htmlElements = ['<button', '<input', '<textarea', '<select'];
    const lines = content.split('\n');

    lines.forEach((line, index) => {
      htmlElements.forEach(element => {
        if (line.includes(element) && !line.includes('//')) {
          const elementName = element.replace('<', '').replace(' ', '');
          issues.push({
            file,
            line: index + 1,
            type: 'warning',
            message: `建议使用 YYC³ ${elementName} 组件替代原生 HTML 元素`,
            rule: 'component-usage'
          });
        }
      });
    });
  }
}

function displayResults(issues: BrandIssue[]) {
  if (issues.length === 0) {
    console.log(chalk.green('✅ 品牌合规性检查通过！'));
    return;
  }

  console.log(chalk.yellow(`\n发现 ${issues.length} 个品牌合规性问题:\n`));

  const groupedIssues = issues.reduce((acc, issue) => {
    if (!acc[issue.file]) {
      acc[issue.file] = [];
    }
    acc[issue.file].push(issue);
    return acc;
  }, {} as Record<string, BrandIssue[]>);

  Object.entries(groupedIssues).forEach(([file, fileIssues]) => {
    console.log(chalk.underline(file));

    fileIssues.forEach(issue => {
      const icon = issue.type === 'error' ? '❌' : issue.type === 'warning' ? '⚠️' : 'ℹ️';
      const color = issue.type === 'error' ? chalk.red : issue.type === 'warning' ? chalk.yellow : chalk.blue;

      console.log(`  ${icon} ${color(issue.message)} ${chalk.gray(`(${issue.rule})`)}`);
      if (issue.line) {
        console.log(`     ${chalk.gray(`第 ${issue.line} 行`)}`);
      }
    });

    console.log();
  });

  // 统计信息
  const errorCount = issues.filter(i => i.type === 'error').length;
  const warningCount = issues.filter(i => i.type === 'warning').length;
  const infoCount = issues.filter(i => i.type === 'info').length;

  console.log(chalk.red(`错误: ${errorCount}`));
  console.log(chalk.yellow(`警告: ${warningCount}`));
  console.log(chalk.blue(`信息: ${infoCount}`));
}

async function autoFix(issues: BrandIssue[]) {
  const spinner = ora('正在自动修复问题...').start();

  let fixedCount = 0;

  for (const issue of issues) {
    try {
      switch (issue.rule) {
        case 'copyright-header':
          await addCopyrightHeader(issue.file);
          fixedCount++;
          break;
        case 'brand-identifier':
          await addBrandIdentifier(issue.file);
          fixedCount++;
          break;
        // 其他自动修复规则...
      }
    } catch (error) {
      // 忽略修复失败的问题
    }
  }

  spinner.succeed(chalk.green(`自动修复了 ${fixedCount} 个问题`));
}

async function addCopyrightHeader(file: string) {
  const content = await fs.readFile(file, 'utf-8');
  const header = `/**
 * Copyright (c) ${new Date().getFullYear()} YanYu Intelligence Cloud³
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

`;

  await fs.writeFile(file, header + content);
}

async function addBrandIdentifier(file: string) {
  const content = await fs.readFile(file, 'utf-8');
  const lines = content.split('\n');

  // 在文件开头添加品牌标识注释
  const brandComment = `// YYC³ Component - Part of YanYu Intelligence Cloud³ Design System`;

  if (!content.includes(brandComment)) {
    lines.splice(1, 0, brandComment, '');
    await fs.writeFile(file, lines.join('\n'));
  }
}

async function generateReport(issues: BrandIssue[]) {
  const report = {
    timestamp: new Date().toISOString(),
    summary: {
      total: issues.length,
      errors: issues.filter(i => i.type === 'error').length,
      warnings: issues.filter(i => i.type === 'warning').length,
      info: issues.filter(i => i.type === 'info').length
    },
    issues: issues
  };

  const reportPath = path.join(process.cwd(), 'brand-check-report.json');
  await fs.writeJson(reportPath, report, { spaces: 2 });

  console.log(chalk.green(`\n品牌检查报告已生成: ${reportPath}`));
}
EOF

    chmod +x "$DEVKIT_DIR/tools/cli/bin/yyc.js"

    log_success "CLI 工具创建完成"
}

# 创建 NPM 包
create_npm_packages() {
    log_step "创建 NPM 包..."

    # 创建核心包
    mkdir -p "$DEVKIT_DIR/packages/core/src"
    cat > "$DEVKIT_DIR/packages/core/package.json" << 'EOF'
{
  "name": "@yanyucloud/core",
  "version": "1.0.0",
  "description": "YYC³ 核心工具库",
  "main": "dist/index.js",
  "module": "dist/index.esm.js",
  "types": "dist/index.d.ts",
  "files": [
    "dist"
  ],
  "scripts": {
    "build": "rollup -c",
    "dev": "rollup -c -w",
    "test": "jest",
    "lint": "eslint src/**/*.ts",
    "type-check": "tsc --noEmit"
  },
  "keywords": [
    "yanyucloud",
    "yyc3",
    "utilities",
    "core"
  ],
  "author": "YanYu Intelligence Cloud",
  "license": "MIT",
  "dependencies": {
    "lodash-es": "^4.17.21",
    "date-fns": "^2.30.0",
    "uuid": "^9.0.0"
  },
  "devDependencies": {
    "@types/lodash-es": "^4.17.8",
    "@types/uuid": "^9.0.2",
    "typescript": "^5.1.0",
    "rollup": "^3.28.0",
    "@rollup/plugin-typescript": "^11.1.2",
    "@rollup/plugin-node-resolve": "^15.1.0",
    "@rollup/plugin-commonjs": "^25.0.3",
    "jest": "^29.6.0",
    "@types/jest": "^29.5.0"
  },
  "peerDependencies": {
    "react": ">=16.8.0"
  }
}
EOF

    # 创建核心包主文件
    cat > "$DEVKIT_DIR/packages/core/src/index.ts" << 'EOF'
/**
 * YYC³ 核心工具库
 * Copyright (c) 2024 YanYu Intelligence Cloud³
 */

// 工具函数
export * from './utils';

// 类型定义
export * from './types';

// 常量
export * from './constants';

// 验证器
export * from './validators';

// 格式化器
export * from './formatters';

// 错误处理
export * from './errors';

// 日志系统
export * from './logger';

// 版本信息
export const VERSION = '1.0.0';
export const BRAND = 'YYC³';
EOF

    # 创建工具函数
    cat > "$DEVKIT_DIR/packages/core/src/utils.ts" << 'EOF'
import { debounce, throttle, cloneDeep, merge } from 'lodash-es';
import { format, parseISO, isValid } from 'date-fns';
import { v4 as uuidv4 } from 'uuid';

/**
 * 生成唯一 ID
 */
export function generateId(prefix?: string): string {
  const id = uuidv4();
  return prefix ? `${prefix}-${id}` : id;
}

/**
 * 深度克隆对象
 */
export function deepClone<T>(obj: T): T {
  return cloneDeep(obj);
}

/**
 * 深度合并对象
 */
export function deepMerge<T extends object>(target: T, ...sources: Partial<T>[]): T {
  return merge(target, ...sources);
}

/**
 * 防抖函数
 */
export function createDebounce<T extends (...args: any[]) => any>(
  func: T,
  wait: number
): T {
  return debounce(func, wait) as T;
}

/**
 * 节流函数
 */
export function createThrottle<T extends (...args: any[]) => any>(
  func: T,
  wait: number
): T {
  return throttle(func, wait) as T;
}

/**
 * 格式化日期
 */
export function formatDate(date: string | Date, pattern: string = 'yyyy-MM-dd'): string {
  const dateObj = typeof date === 'string' ? parseISO(date) : date;
  return isValid(dateObj) ? format(dateObj, pattern) : '';
}

/**
 * 安全的 JSON 解析
 */
export function safeJsonParse<T = any>(json: string, defaultValue: T): T {
  try {
    return JSON.parse(json);
  } catch {
    return defaultValue;
  }
}

/**
 * 类名合并工具
 */
export function cn(...classes: (string | undefined | null | false)[]): string {
  return classes.filter(Boolean).join(' ');
}

/**
 * 延迟执行
 */
export function sleep(ms: number): Promise<void> {
  return new Promise(resolve => setTimeout(resolve, ms));
}

/**
 * 数组去重
 */
export function unique<T>(array: T[], key?: keyof T): T[] {
  if (!key) {
    return [...new Set(array)];
  }

  const seen = new Set();
  return array.filter(item => {
    const value = item[key];
    if (seen.has(value)) {
      return false;
    }
    seen.add(value);
    return true;
  });
}

/**
 * 数字格式化
 */
export function formatNumber(
  num: number,
  options: {
    decimals?: number;
    separator?: string;
    prefix?: string;
    suffix?: string;
  } = {}
): string {
  const { decimals = 0, separator = ',', prefix = '', suffix = '' } = options;

  const formatted = num.toFixed(decimals).replace(/\B(?=(\d{3})+(?!\d))/g, separator);
  return `${prefix}${formatted}${suffix}`;
}

/**
 * 字符串截断
 */
export function truncate(str: string, length: number, suffix: string = '...'): string {
  if (str.length <= length) {
    return str;
  }
  return str.slice(0, length - suffix.length) + suffix;
}

/**
 * 首字母大写
 */
export function capitalize(str: string): string {
  return str.charAt(0).toUpperCase() + str.slice(1).toLowerCase();
}

/**
 * 驼峰转短横线
 */
export function camelToKebab(str: string): string {
  return str.replace(/([a-z0-9]|(?=[A-Z]))([A-Z])/g, '$1-$2').toLowerCase();
}

/**
 * 短横线转驼峰
 */
export function kebabToCamel(str: string): string {
  return str.replace(/-([a-z])/g, (_, letter) => letter.toUpperCase());
}
EOF

    # 创建类型定义
    cat > "$DEVKIT_DIR/packages/core/src/types.ts" << 'EOF'
/**
 * YYC³ 核心类型定义
 */

// 基础类型
export type YYCTheme = 'light' | 'dark' | 'auto';
export type YYCSize = 'xs' | 'sm' | 'md' | 'lg' | 'xl';
export type YYCVariant = 'primary' | 'secondary' | 'accent' | 'success' | 'warning' | 'error';
export type YYCColor = 'primary' | 'secondary' | 'accent' | 'success' | 'warning' | 'error' | 'info';

// 组件基础属性
export interface YYCBaseProps {
  className?: string;
  id?: string;
  'data-testid'?: string;
}

// 响应式断点
export interface YYCBreakpoints {
  sm: number;
  md: number;
  lg: number;
  xl: number;
  '2xl': number;
}

// 主题配置
export interface YYCThemeConfig {
  colors: {
    primary: Record<string, string>;
    secondary: Record<string, string>;
    accent: Record<string, string>;
    success: Record<string, string>;
    warning: Record<string, string>;
    error: Record<string, string>;
  };
  fonts: {
    sans: string[];
    mono: string[];
  };
  spacing: Record<string, string>;
  borderRadius: Record<string, string>;
  shadows: Record<string, string>;
  breakpoints: YYCBreakpoints;
}

// API 响应类型
export interface YYCApiResponse<T = any> {
  success: boolean;
  data?: T;
  error?: string;
  message?: string;
  timestamp: string;
}

// 分页类型
export interface YYCPagination {
  page: number;
  pageSize: number;
  total: number;
  totalPages: number;
}

export interface YYCPaginatedResponse<T = any> extends YYCApiResponse<T[]> {
  pagination: YYCPagination;
}

// 表单类型
export interface YYCFormField {
  name: string;
  label: string;
  type: 'text' | 'email' | 'password' | 'number' | 'select' | 'textarea' | 'checkbox' | 'radio';
  required?: boolean;
  placeholder?: string;
  options?: Array<{ label: string; value: string | number }>;
  validation?: {
    min?: number;
    max?: number;
    pattern?: RegExp;
    custom?: (value: any) => string | null;
  };
}

export interface YYCFormConfig {
  fields: YYCFormField[];
  onSubmit: (data: Record<string, any>) => void | Promise<void>;
  initialValues?: Record<string, any>;
  validation?: 'onChange' | 'onBlur' | 'onSubmit';
}

// 事件类型
export interface YYCEvent<T = any> {
  type: string;
  payload: T;
  timestamp: number;
  source?: string;
}

// 日志类型
export type YYCLogLevel = 'debug' | 'info' | 'warn' | 'error';

export interface YYCLogEntry {
  level: YYCLogLevel;
  message: string;
  timestamp: number;
  context?: Record<string, any>;
  error?: Error;
}

// 配置类型
export interface YYCConfig {
  theme: YYCThemeConfig;
  api: {
    baseUrl: string;
    timeout: number;
    retries: number;
  };
  logging: {
    level: YYCLogLevel;
    enabled: boolean;
  };
  features: Record<string, boolean>;
}

// 组件状态类型
export type YYCComponentState = 'idle' | 'loading' | 'success' | 'error';

// 数据状态类型
export interface YYCDataState<T = any> {
  data: T | null;
  loading: boolean;
  error: string | null;
  lastUpdated: number | null;
}

// 用户类型
export interface YYCUser {
  id: string;
  name: string;
  email: string;
  avatar?: string;
  role: string;
  permissions: string[];
  preferences: Record<string, any>;
  createdAt: string;
  updatedAt: string;
}

// 文件类型
export interface YYCFile {
  id: string;
  name: string;
  size: number;
  type: string;
  url: string;
  uploadedAt: string;
  metadata?: Record<string, any>;
}

// 通知类型
export interface YYCNotification {
  id: string;
  type: YYCVariant;
  title: string;
  message: string;
  timestamp: number;
  read: boolean;
  action?: {
    label: string;
    url?: string;
    onClick?: () => void;
  };
  icon?: string;
  group?: string;
}
EOF

    # 创建常量
    cat > "$DEVKIT_DIR/packages/core/src/constants.ts" << 'EOF'
/**
 * YYC³ 核心常量
 */

// 版本信息
export const YYC_VERSION = '1.0.0';
export const YYC_NAME = 'YYC³';
export const YYC_FULL_NAME = 'YanYu Intelligence Cloud³';

// 环境变量
export const ENV_DEVELOPMENT = 'development';
export const ENV_PRODUCTION = 'production';
export const ENV_STAGING = 'staging';

// 日期格式
export const DATE_FORMAT_STANDARD = 'yyyy-MM-dd';
export const DATE_FORMAT_WITH_TIME = 'yyyy-MM-dd HH:mm:ss';
export const DATE_FORMAT_SHORT = 'MM/DD/YYYY';

// 正则表达式
export const REGEX_EMAIL = /^[\\w.-]+@([\\w-]+\\.)+[A-Za-z]{2,}$/;
export const REGEX_URL = /^(https?:\\/\\/)?([\\da-z.-]+)\\.([a-z.]{2,6})([/\\w .-]*)*\\/?$/;
export const REGEX_PHONE = /^1[3-9]\\d{9}$/;
export const REGEX_PASSWORD = /^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)[a-zA-Z\\d]{8,}$/;

// 最大限制
export const MAX_FILE_SIZE = 10 * 1024 * 1024; // 10MB
export const MAX_SEARCH_RESULTS = 100;
export const DEFAULT_PAGE_SIZE = 20;

// 动画时长
export const ANIMATION_DURATION_SHORT = 200; // ms
export const ANIMATION_DURATION_MEDIUM = 300; // ms
export const ANIMATION_DURATION_LONG = 500; // ms

// 超时时间
export const TIMEOUT_SHORT = 1000; // ms
export const TIMEOUT_MEDIUM = 3000; // ms
export const TIMEOUT_LONG = 10000; // ms

// 防抖/节流默认值
export const DEFAULT_DEBOUNCE_TIME = 300; // ms
export const DEFAULT_THROTTLE_TIME = 100; // ms
EOF

    log_success "NPM 包创建完成"
}

# 创建文档和示例
create_docs_and_examples() {
    log_step "创建文档和示例项目..."

    # 创建入门指南
    mkdir -p "$DEVKIT_DIR/docs/guides"
    cat > "$DEVKIT_DIR/docs/guides/getting-started.md" << 'EOF'
# YYC³ 开发者工具包入门指南

## 欢迎使用 YYC³

感谢您选择 YYC³（言语云³）开发者工具包！本工具包旨在帮助开发者快速构建符合企业级标准的应用程序，提供一致的开发体验和高效的开发流程。

## 系统要求

- **Node.js**: v16.0.0 或更高版本
- **npm**: v7.0.0 或更高版本（或 yarn/pnpm）
- **代码编辑器**: VS Code（推荐）或其他支持 TypeScript 的编辑器
- **版本控制**: Git

## 安装工具包

### 方式一：使用 CLI 工具

YYC³ 提供了强大的 CLI 工具来帮助您快速创建项目：

1. 全局安装 CLI 工具：
```bash
npm install -g @yanyucloud/cli
# 或使用 yarn
yarn global add @yanyucloud/cli
