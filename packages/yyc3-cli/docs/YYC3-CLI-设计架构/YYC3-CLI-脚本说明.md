---
@file: YYC3-CLI-工具脚本说明.md
@description: YYC³-CLI YYC3-CLI-工具脚本说明.md
@author: YanYuCloudCube Team
@version: v1.0.0
@created: 2026-02-17
@updated: 2026-02-17
@status: published
@tags: [文档],[YYC³-CLI]
---

> ***YanYuCloudCube***
> 言启象限 | 语枢未来
> ***Words Initiate Quadrants, Language Serves as Core for the Future***
> 万象归元于云枢 | 深栈智启新纪元
> ***All things converge in the cloud pivot; Deep stacks ignite a new era of intelligence***

---

# cat > install-yyc3-cli.sh << 'EOF'
#!/bin/bash

# YYC³ CLI 工具安装脚本

set -e

echo "🚀 安装 YYC³ CLI 工具..."

# 检查 Node.js
if ! command -v node &> /dev/null; then
    echo "❌ 请先安装 Node.js"
    echo "💡 访问 https://nodejs.org/ 下载安装"
    exit 1
fi

# 检查 npm
if ! command -v npm &> /dev/null; then
    echo "❌ 请先安装 npm"
    exit 1
fi

# 创建 CLI 包目录
CLI_DIR="./packages/yyc3-cli"
mkdir -p "$CLI_DIR"/{bin,lib,templates}

# 创建 package.json
cat > "$CLI_DIR/package.json" << 'PKG_EOF'
{
  "name": "@yanyucloud/cli",
  "version": "1.0.0",
  "description": "YYC³ 开发者工具命令行工具",
  "main": "lib/index.js",
  "bin": {
    "yyc": "./bin/yyc.js"
  },
  "scripts": {
    "dev": "node bin/yyc.js",
    "build": "echo 'Build completed'",
    "test": "echo 'No tests yet'"
  },
  "keywords": ["yyc3", "cli", "yanyucloud"],
  "author": "YanYu Intelligence Cloud³",
  "license": "MIT",
  "dependencies": {
    "commander": "^9.4.1",
    "chalk": "^4.1.2",
    "inquirer": "^8.2.5",
    "ora": "^5.4.1",
    "fs-extra": "^11.1.0"
  },
  "engines": {
    "node": ">=14.0.0"
  }
}
PKG_EOF

# 创建 CLI 入口文件
cat > "$CLI_DIR/bin/yyc.js" << 'CLI_EOF'
#!/usr/bin/env node

/**
 * YYC³ CLI 工具
 * Copyright (c) 2024 YanYu Intelligence Cloud³
 */

const { program } = require('commander');
const chalk = require('chalk');
const inquirer = require('inquirer');
const ora = require('ora');
const fs = require('fs-extra');
const path = require('path');

// 版本信息
const { version } = require('../package.json');

// 欢迎信息
const showWelcome = () => {
  console.log(chalk.cyan(`
    ██╗   ██╗██╗   ██╗ ██████╗██████╗
    ╚██╗ ██╔╝╚██╗ ██╔╝██╔════╝╚════██╗
     ╚████╔╝  ╚████╔╝ ██║      █████╔╝
      ╚██╔╝    ╚██╔╝  ██║      ╚═══██╗
       ██║      ██║   ╚██████╗██████╔╝
       ╚═╝      ╚═╝    ╚═════╝╚═════╝

    YYC³ 开发者工具 v${version}
    YanYu Intelligence Cloud³
  `));
};

// 主程序配置
program
  .name('yyc')
  .description('YYC³ 开发者工具命令行工具')
  .version(version)
  .hook('preAction', () => {
    if (!process.argv.includes('--version') && !process.argv.includes('-V')) {
      showWelcome();
    }
  });

// 创建项目命令
program
  .command('create <type> <name>')
  .description('创建新项目')
  .option('-t, --template <template>', '使用指定模板')
  .action(async (type, name, options) => {
    const spinner = ora('正在创建项目...').start();
    
    try {
      await createProject(type, name, options);
      spinner.succeed(`项目 ${chalk.green(name)} 创建成功！`);
      
      console.log(chalk.blue('\n🎉 项目创建完成！'));
      console.log(chalk.yellow('\n📋 下一步：'));
      console.log(`  cd ${name}`);
      console.log(`  npm install`);
      console.log(`  npm run dev`);
    } catch (error) {
      spinner.fail(`项目创建失败: ${error.message}`);
      process.exit(1);
    }
  });

// 生成代码命令
program
  .command('generate <type> <name>')
  .alias('g')
  .description('生成代码')
  .option('-p, --path <path>', '生成路径')
  .action(async (type, name, options) => {
    const spinner = ora(`正在生成 ${type}...`).start();
    
    try {
      await generateCode(type, name, options);
      spinner.succeed(`${type} ${chalk.green(name)} 生成成功！`);
    } catch (error) {
      spinner.fail(`生成失败: ${error.message}`);
      process.exit(1);
    }
  });

// 品牌检查命令
program
  .command('brand-check')
  .description('检查品牌合规性')
  .option('--fix', '自动修复问题')
  .option('--report', '生成报告')
  .action(async (options) => {
    const spinner = ora('正在检查品牌合规性...').start();
    
    try {
      const result = await checkBrandCompliance(options);
      
      if (result.issues.length === 0) {
        spinner.succeed('品牌合规性检查通过！');
      } else {
        spinner.warn(`发现 ${result.issues.length} 个问题`);
        console.log(chalk.yellow('\n⚠️  发现以下问题：'));
        result.issues.forEach(issue => {
          console.log(`  ${chalk.red('•')} ${issue}`);
        });
        
        if (options.fix) {
          const fixSpinner = ora('正在自动修复...').start();
          await fixBrandIssues(result.issues);
          fixSpinner.succeed('问题修复完成！');
        }
      }
    } catch (error) {
      spinner.fail(`检查失败: ${error.message}`);
      process.exit(1);
    }
  });

// 状态命令
program
  .command('status')
  .description('查看系统状态')
  .action(() => {
    console.log(chalk.blue('📊 系统状态检查'));
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    
    // Node.js 版本
    console.log(`${chalk.green('✓')} Node.js: ${process.version}`);
    
    // npm 版本
    try {
      const { execSync } = require('child_process');
      const npmVersion = execSync('npm --version', { encoding: 'utf8' }).trim();
      console.log(`${chalk.green('✓')} npm: v${npmVersion}`);
    } catch (error) {
      console.log(`${chalk.red('✗')} npm: 不可用`);
    }
    
    // 当前目录
    console.log(`${chalk.green('✓')} 当前目录: ${process.cwd()}`);
    
    // 检查项目配置
    if (fs.existsSync('package.json')) {
      try {
        const pkg = JSON.parse(fs.readFileSync('package.json', 'utf8'));
        console.log(`${chalk.green('✓')} 项目: ${pkg.name || '未命名'}@${pkg.version || '0.0.0'}`);
      } catch (error) {
        console.log(`${chalk.yellow('!')} package.json 格式错误`);
      }
    } else {
      console.log(`${chalk.yellow('!')} 未找到 package.json`);
    }
    
    // 检查 YYC³ 配置
    if (fs.existsSync('yyc3.config.js')) {
      console.log(`${chalk.green('✓')} YYC³ 配置: 已找到`);
    } else {
      console.log(`${chalk.yellow('!')} YYC³ 配置: 未找到`);
    }
    
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    console.log(chalk.green('✅ 系统状态检查完成'));
  });

// 项目创建函数
async function createProject(type, name, options) {
  const targetDir = path.join(process.cwd(), name);
  
  // 检查目录是否存在
  if (fs.existsSync(targetDir)) {
    throw new Error(`目录 ${name} 已存在`);
  }
  
  // 创建目录
  fs.ensureDirSync(targetDir);
  
  switch (type) {
    case 'app':
      await createNextApp(targetDir, name, options);
      break;
    case 'component':
      await createComponentLibrary(targetDir, name, options);
      break;
    case 'package':
      await createPackage(targetDir, name, options);
      break;
    default:
      throw new Error(`不支持的项目类型: ${type}`);
  }
}

// 创建 Next.js 应用
async function createNextApp(targetDir, name, options) {
  const template = options.template || 'dashboard';
  
  // 创建 package.json
  const packageJson = {
    name: name,
    version: '0.1.0',
    private: true,
    scripts: {
      dev: 'next dev',
      build: 'next build',
      start: 'next start',
      lint: 'next lint'
    },
    dependencies: {
      'next': '^14.0.0',
      'react': '^18.2.0',
      'react-dom': '^18.2.0',
      '@yanyucloud/ui': '^1.0.0'
    },
    devDependencies: {
      '@types/node': '^20.0.0',
      '@types/react': '^18.2.0',
      '@types/react-dom': '^18.2.0',
      'typescript': '^5.2.0',
      'tailwindcss': '^3.3.0',
      'autoprefixer': '^10.4.0',
      'postcss': '^8.4.0'
    }
  };
  
  fs.writeFileSync(
    path.join(targetDir, 'package.json'),
    JSON.stringify(packageJson, null, 2)
  );
  
  // 创建目录结构
  const dirs = [
    'src/app',
    'src/components',
    'src/lib',
    'src/styles',
    'public'
  ];
  
  dirs.forEach(dir => {
    fs.ensureDirSync(path.join(targetDir, dir));
  });
  
  // 创建页面文件
  const pageContent = getPageTemplate(template, name);
  fs.writeFileSync(
    path.join(targetDir, 'src/app/page.tsx'),
    pageContent
  );
  
  // 创建布局文件
  const layoutContent = getLayoutTemplate(name);
  fs.writeFileSync(
    path.join(targetDir, 'src/app/layout.tsx'),
    layoutContent
  );
  
  // 创建配置文件
  createConfigFiles(targetDir, name);
}

// 生成代码函数
async function generateCode(type, name, options) {
  const targetPath = options.path || 'src/components';
  
  switch (type) {
    case 'component':
      await generateComponent(name, targetPath);
      break;
    case 'page':
      await generatePage(name, targetPath);
      break;
    case 'hook':
      await generateHook(name, targetPath);
      break;
    default:
      throw new Error(`不支持的生成类型: ${type}`);
  }
}

// 生成组件
async function generateComponent(name, targetPath) {
  // 确保组件名以 YY 开头
  const componentName = name.startsWith('YY') ? name : `YY${name}`;
  
  const componentContent = `import React from 'react';
import { cn } from '@/lib/utils';

export interface ${componentName}Props {
  children?: React.ReactNode;
  className?: string;
}

export const ${componentName}: React.FC<${componentName}Props> = ({
  children,
  className,
}) => {
  return (
    <div className={cn('yyc3-${componentName.toLowerCase()}', className)}>
      {children}
    </div>
  );
};

${componentName}.displayName = '${componentName}';
`;
  
  const componentDir = path.join(targetPath, componentName);
  fs.ensureDirSync(componentDir);
  fs.writeFileSync(
    path.join(componentDir, `${componentName}.tsx`),
    componentContent
  );
  
  console.log(`组件 ${chalk.green(componentName)} 已生成到 ${componentDir}`);
}

// 品牌合规检查
async function checkBrandCompliance(options) {
  const issues = [];
  
  // 检查组件命名
  if (fs.existsSync('src/components')) {
    const files = await fs.readdir('src/components', { recursive: true });
    for (const file of files) {
      if (file.endsWith('.tsx') || file.endsWith('.jsx')) {
        const filePath = path.join('src/components', file);
        const content = await fs.readFile(filePath, 'utf8');
        
        if (!content.includes('YY') && !content.includes('yyc3-')) {
          issues.push(`${file}: 组件未使用 YY 前缀或 yyc3- 类名`);
        }
      }
    }
  }
  
  // 检查包名
  if (fs.existsSync('package.json')) {
    const pkg = JSON.parse(await fs.readFile('package.json', 'utf8'));
    if (pkg.name && !pkg.name.startsWith('@yanyucloud/')) {
      issues.push('package.json: 包名未使用 @yanyucloud/ 作用域');
    }
  }
  
  return { issues };
}

// 获取页面模板
function getPageTemplate(template, name) {
  const templates = {
    dashboard: `export default function Dashboard() {
  return (
    <div className="min-h-screen bg-gray-50">
      <div className="max-w-7xl mx-auto px-4 py-8">
        <h1 className="text-3xl font-bold text-gray-900">
          欢迎使用 ${name}
        </h1>
        <p className="mt-4 text-gray-600">
          这是一个使用 YYC³ 工具包创建的仪表板应用
        </p>
      </div>
    </div>
  );
}`,
    landing: `export default function LandingPage() {
  return (
    <div className="min-h-screen">
      <section className="bg-gradient-to-r from-blue-600 to-purple-600 text-white py-20">
        <div className="max-w-4xl mx-auto text-center px-4">
          <h1 className="text-5xl font-bold mb-6">${name}</h1>
          <p className="text-xl mb-8">使用 YYC³ 工具包构建的现代应用</p>
          <button className="bg-white text-blue-600 px-8 py-3 rounded-lg font-semibold hover:bg-gray-100 transition-colors">
            立即开始
          </button>
        </div>
      </section>
    </div>
  );
}`
  };
  
  return templates[template] || templates.dashboard;
}

// 获取布局模板
function getLayoutTemplate(name) {
  return `import type { Metadata } from 'next';
import { Inter } from 'next/font/google';
import './globals.css';

const inter = Inter({ subsets: ['latin'] });

export const metadata: Metadata = {
  title: '${name}',
  description: '使用 YYC³ 工具包创建的应用',
  creator: 'YanYu Intelligence Cloud³',
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="zh-CN">
      <body className={inter.className}>
        {children}
      </body>
    </html>
  );
}`;
}

// 创建配置文件
function createConfigFiles(targetDir, name) {
  // YYC³ 配置
  const yyc3Config = `module.exports = {
  brand: {
    name: '${name}',
    theme: 'light',
  },
  components: {
    prefix: 'YY',
    generateTests: true,
    generateStories: false,
  },
  build: {
    outDir: 'dist',
    sourcemap: true,
  },
};`;
  
  fs.writeFileSync(
    path.join(targetDir, 'yyc3.config.js'),
    yyc3Config
  );
  
  // Tailwind 配置
  const tailwindConfig = `/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    './src/**/*.{js,ts,jsx,tsx,mdx}',
  ],
  theme: {
    extend: {
      colors: {
        'yyc3-primary': '#0ea5e9',
        'yyc3-secondary': '#71717a',
        'yyc3-accent': '#d946ef',
      },
    },
  },
  plugins: [],
};`;
  
  fs.writeFileSync(
    path.join(targetDir, 'tailwind.config.js'),
    tailwindConfig
  );
  
  // TypeScript 配置
  const tsConfig = `{
  "compilerOptions": {
    "target": "es5",
    "lib": ["dom", "dom.iterable", "es6"],
    "allowJs": true,
    "skipLibCheck": true,
    "strict": true,
    "noEmit": true,
    "esModuleInterop": true,
    "module": "esnext",
    "moduleResolution": "bundler",
    "resolveJsonModule": true,
    "isolatedModules": true,
    "jsx": "preserve",
    "incremental": true,
    "plugins": [
      {
        "name": "next"
      }
    ],
    "baseUrl": ".",
    "paths": {
      "@/*": ["./src/*"]
    }
  },
  "include": ["next-env.d.ts", "**/*.ts", "**/*.tsx", ".next/types/**/*.ts"],
  "exclude": ["node_modules"]
}`;
  
  fs.writeFileSync(
    path.join(targetDir, 'tsconfig.json'),
    tsConfig
  );
}

// 解析命令行参数
program.parse();
CLI_EOF

# 创建主入口文件
cat > "$CLI_DIR/lib/index.js" << 'INDEX_EOF'
/**
 * YYC³ CLI 主入口文件
 * Copyright (c) 2024 YanYu Intelligence Cloud³
 */

module.exports = {
  version: require('../package.json').version,
  createProject: require('./create-project'),
  generateCode: require('./generate-code'),
  checkBrand: require('./brand-check'),
};
INDEX_EOF

# 设置执行权限
chmod +x "$CLI_DIR/bin/yyc.js"

# 进入 CLI 目录
cd "$CLI_DIR"

# 安装依赖
echo "📦 安装依赖..."
npm install

# 创建全局链接
echo "🔗 创建全局链接..."
npm link

echo "✅ YYC³ CLI 工具安装完成！"
echo ""
echo "🎉 现在可以使用以下命令："
echo ""
echo "  yyc --version                    # 查看版本"
echo "  yyc --help                       # 查看帮助"
echo "  yyc create app my-app            # 创建应用"
echo "  yyc create component my-comp     # 创建组件库"
echo "  yyc generate component MyButton  # 生成组件"
echo "  yyc brand-check                  # 品牌检查"
echo "  yyc status                       # 查看状态"
echo ""
echo "🚀 快速开始："
echo "  yyc create app my-yyc-app"
echo "  cd my-yyc-app"
echo "  npm install"
echo "  npm run dev"
echo ""
echo "🌐 访问 http://localhost:3000 查看应用"
EOF

chmod +x install-yyc3-cli.sh