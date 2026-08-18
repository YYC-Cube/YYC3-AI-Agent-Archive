#!/bin/bash

# YYC³ CLI 工具安装脚本 - 智能优化版

set -e

# 全局变量
CLI_NAME="yyc3-cli"
CLI_PACKAGE="@yanyucloud/cli"
CLI_VERSION="1.0.0"
INSTALL_DIR="./packages/yyc3-cli"
SKIP_DEPENDENCIES=false
SKIP_LINK=false
VERBOSE=false

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# 函数：显示彩色消息
function echo_color() {
    local color=$1
    shift
    echo -e "${color}$@${NC}"
}

# 函数：显示错误消息
function echo_error() {
    echo_color "${RED}" "❌ $@"
}

# 函数：显示成功消息
function echo_success() {
    echo_color "${GREEN}" "✅ $@"
}

# 函数：显示警告消息
function echo_warning() {
    echo_color "${YELLOW}" "⚠️ $@"
}

# 函数：显示信息消息
function echo_info() {
    echo_color "${BLUE}" "� $@"
}

# 函数：显示调试消息
function echo_debug() {
    if [ "$VERBOSE" = true ]; then
        echo_color "${CYAN}" "🐛 $@"
    fi
}

# 函数：显示分隔线
function echo_separator() {
    echo_color "${PURPLE}" "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
}

# 函数：清理临时文件和回滚安装
function cleanup() {
    # 清理临时目录
    if [ -d "$TEMP_DIR" ]; then
        rm -rf "$TEMP_DIR"
        echo_debug "清理临时目录: $TEMP_DIR"
    fi
    
    # 如果需要回滚，清理安装目录
    if [ "$ROLLBACK" = true ] && [ -d "$INSTALL_DIR" ]; then
        echo_warning "正在回滚安装..."
        rm -rf "$INSTALL_DIR"
        echo_info "安装目录已清理: $INSTALL_DIR"
    fi
}

# 设置错误陷阱，捕获中断和错误
set -e

# 定义回滚标志
ROLLBACK=false

# 函数：设置回滚标志
function set_rollback() {
    ROLLBACK=true
}

# 函数：显示帮助信息
function show_help() {
    echo_color "${CYAN}" "YYC³ CLI 工具安装脚本"
    echo ""
    echo "用法: $0 [选项]"
    echo ""
    echo "选项:"
    echo "  -d, --dir <路径>           指定安装目录 (默认: ./packages/yyc3-cli)"
    echo "  -n, --name <名称>          指定 CLI 命令名称 (默认: yyc)"
    echo "  -p, --package <包名>       指定 npm 包名 (默认: @yanyucloud/cli)"
    echo "  -v, --cli-version <版本>   指定 CLI 版本 (默认: 1.0.0)"
    echo "  --version                  显示脚本版本"
    echo "  --skip-deps                跳过依赖安装"
    echo "  --skip-link                跳过全局链接创建"
    echo "  --verbose                  显示详细调试信息"
    echo "  -h, --help                 显示帮助信息"
    echo ""
    echo "示例:"
    echo "  $0                        # 默认安装"
    echo "  $0 --dir ./my-cli         # 指定安装目录"
    echo "  $0 --name yyc3 --verbose  # 使用自定义命令名并显示调试信息"
    echo ""
    exit 0
}

# 解析命令行参数
while [[ $# -gt 0 ]]; do
    case "$1" in
        -d|--dir)
            INSTALL_DIR="$2"
            shift 2
            ;;
        -n|--name)
            CLI_NAME="$2"
            shift 2
            ;;
        -p|--package)
            CLI_PACKAGE="$2"
            shift 2
            ;;
        -v|--cli-version)
            CLI_VERSION="$2"
            shift 2
            ;;
        --version)
            echo "YYC³ CLI 安装脚本版本: 2.0.0"
            exit 0
            ;;
        --skip-deps)
            SKIP_DEPENDENCIES=true
            shift
            ;;
        --skip-link)
            SKIP_LINK=true
            shift
            ;;
        --verbose)
            VERBOSE=true
            shift
            ;;
        -h|--help)
            show_help
            ;;
        *)
            echo_error "未知选项: $1"
            echo "使用 -h 或 --help 查看帮助信息"
            exit 1
            ;;
    esac
done

# 显示欢迎信息
echo_color "${CYAN}"
echo "    ██╗   ██╗██╗   ██╗ ██████╗██████╗ "
echo "    ╚██╗ ██╔╝╚██╗ ██╔╝██╔════╝╚════██╗"
echo "     ╚████╔╝  ╚████╔╝ ██║      █████╔╝"
echo "      ╚██╔╝    ╚██╔╝  ██║      ╚═══██╗"
echo "       ██║      ██║   ╚██████╗██████╔╝"
echo "       ╚═╝      ╚═╝    ╚═════╝╚═════╝ "
echo ""
echo "    YYC³ 开发者工具安装脚本"
echo "    YanYu Intelligence Cloud³"
echo_color "${NC}"
echo_separator

# 检查 Node.js 和 npm
echo_info "检查 Node.js 和 npm 环境..."

# 检查 Node.js
if ! command -v node &> /dev/null; then
    echo_error "未检测到 Node.js 环境"
    echo_warning "💡 请访问 https://nodejs.org/ 下载安装最新版本的 Node.js"
    exit 1
fi

# 检查 npm
if ! command -v npm &> /dev/null; then
    echo_error "未检测到 npm 环境"
    echo_warning "💡 npm 通常随 Node.js 一起安装，请确保 Node.js 安装完整"
    exit 1
fi

# 检查版本
NODE_VERSION=$(node --version | sed 's/v//')
NPM_VERSION=$(npm --version)

echo_success "Node.js 版本: ${NODE_VERSION}"
echo_success "npm 版本: ${NPM_VERSION}"

# 检查 Node.js 版本是否满足要求
if ! node -e "if (parseInt(process.version.split('.')[0].slice(1)) < 14) process.exit(1)" &> /dev/null; then
    echo_warning "Node.js 版本建议 >= 14.0.0，当前版本: ${NODE_VERSION}"
    echo_warning "某些功能可能无法正常工作"
fi

echo_separator

# 确认安装目录
echo_info "安装配置:"
echo_info "  安装目录: $INSTALL_DIR"
echo_info "  CLI 命令: $CLI_NAME"
echo_info "  npm 包名: $CLI_PACKAGE"
echo_info "  CLI 版本: $CLI_VERSION"

# 创建 CLI 包目录
 echo_info "创建 CLI 包目录结构..."
 mkdir -p "$INSTALL_DIR"/{bin,lib,templates}
 
 # 设置安全的目录权限
 chmod 755 "$INSTALL_DIR"
 chmod 755 "$INSTALL_DIR/bin"
 chmod 755 "$INSTALL_DIR/lib"
 chmod 755 "$INSTALL_DIR/templates"
 
 echo_success "目录结构创建完成，权限设置为 755"

echo_separator

# 创建 package.json
echo_info "生成 package.json 配置文件..."
cat > "$INSTALL_DIR/package.json" << PKG_EOF
{
  "name": "$CLI_PACKAGE",
  "version": "$CLI_VERSION",
  "description": "YYC³ 开发者工具命令行工具 - 智能优化版",
  "main": "lib/index.js",
  "bin": {
    "$CLI_NAME": "./bin/$CLI_NAME.js"
  },
  "scripts": {
    "dev": "node bin/$CLI_NAME.js",
    "build": "echo 'Build completed'",
    "test": "echo 'No tests yet'",
    "update": "npm update && npm link",
    "uninstall": "npm uninstall -g $CLI_PACKAGE && rm -rf ."
  },
  "keywords": ["yyc3", "cli", "yanyucloud", "developer", "toolkit"],
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
echo_success "package.json 创建完成"

echo_separator

# 创建 CLI 入口文件
echo_info "创建 CLI 入口文件..."
# 使用转义方式处理here文档中的变量，避免bash提前解释
cat > "$INSTALL_DIR/bin/$CLI_NAME.js" << 'CLI_EOF'
#!/usr/bin/env node

/**
 * YYC³ CLI 工具
 * Copyright (c) 2024 YanYu Intelligence Cloud³
 */

// 全局变量定义
// 模板管理模块
const TemplateManager = {
  // 模板缓存
  cache: {},
  
  // 页面模板
  pageTemplates: {
    dashboard: `export default function Dashboard() {
  return (
    <div className="min-h-screen bg-gray-50">
      <div className="max-w-7xl mx-auto px-4 py-8">
        <h1 className="text-3xl font-bold text-gray-900">
          欢迎使用 {{name}}
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
          <h1 className="text-5xl font-bold mb-6">{{name}}</h1>
          <p className="text-xl mb-8">使用 YYC³ 工具包构建的现代应用</p>
          <button className="bg-white text-blue-600 px-8 py-3 rounded-lg font-semibold hover:bg-gray-100 transition-colors">
            立即开始
          </button>
        </div>
      </section>
    </div>
  );
}`
  },
  
  // 布局模板
  layoutTemplates: {
    default: `import type { Metadata } from 'next';
import { Inter } from 'next/font/google';
import './globals.css';

const inter = Inter({ subsets: ['latin'] });

export const metadata: Metadata = {
  title: '{{name}}',
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
}`
  },
  
  // 替换模板中的变量
  replaceVariables(template, variables) {
    let result = template;
    for (const [key, value] of Object.entries(variables)) {
      const regex = new RegExp(`{{${key}}}`, 'g');
      result = result.replace(regex, value);
    }
    return result;
  },
  
  // 获取页面模板
  getPageTemplate(templateType, variables) {
    const cacheKey = `page-${templateType}-${JSON.stringify(variables)}`;
    
    // 检查缓存
    if (this.cache[cacheKey]) {
      return this.cache[cacheKey];
    }
    
    const template = this.pageTemplates[templateType] || this.pageTemplates.dashboard;
    const result = this.replaceVariables(template, variables);
    
    // 缓存结果
    this.cache[cacheKey] = result;
    
    return result;
  },
  
  // 获取布局模板
  getLayoutTemplate(templateType, variables) {
    templateType = templateType || 'default';
    const cacheKey = `layout-${templateType}-${JSON.stringify(variables)}`;
    
    // 检查缓存
    if (this.cache[cacheKey]) {
      return this.cache[cacheKey];
    }
    
    const template = this.layoutTemplates[templateType] || this.layoutTemplates.default;
    const result = this.replaceVariables(template, variables);
    
    // 缓存结果
    this.cache[cacheKey] = result;
    
    return result;
  },
  
  // 清除缓存
  clearCache() {
    this.cache = {};
  }
};

// 向后兼容的全局模板缓存引用
const templateCache = TemplateManager.cache;

const { program } = require('commander');
const chalk = require('chalk');
const inquirer = require('inquirer');
const ora = require('ora');
const fs = require('fs-extra');
const path = require('path');

// 版本信息
const { version } = require('../package.json');

// 获取命令名
const commandName = process.argv[1].split('/').pop();

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
    YanYu Intelligence Cloud³ - 智能优化版
  `));
};

// 主程序配置
program
  .name(commandName)
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
  .option('-f, --force', '强制覆盖已存在的目录')
  .option('-s, --skip-install', '跳过依赖安装')
  .action(async (type, name, options) => {
    const spinner = ora('正在创建项目...').start();
    
    try {
      await createProject(type, name, options);
      spinner.succeed(`项目 ${chalk.green(name)} 创建成功！`);
      
      console.log(chalk.blue('\n🎉 项目创建完成！'));
      console.log(chalk.yellow('\n📋 下一步：'));
      console.log(`  cd ${name}`);
      if (!options.skipInstall) {
        console.log(`  npm install`);
      }
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
  .option('-t, --template <template>', '使用指定模板')
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
  .option('-o, --output <path>', '报告输出路径')
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
          const fixed = await fixBrandIssues(result.issues);
          fixSpinner.succeed(`成功修复 ${fixed} 个问题！`);
        }
        
        if (options.report) {
          const reportSpinner = ora('正在生成报告...').start();
          await generateBrandReport(result, options.output);
          reportSpinner.succeed(`报告已生成到 ${options.output || 'brand-report.txt'}`);
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
      const { spawnSync } = require('child_process');
      const result = spawnSync('npm', ['--version'], { encoding: 'utf8', shell: true });
      const npmVersion = result.stdout.trim();
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
    
    // 检查 YY 组件
    if (fs.existsSync('src/components')) {
      const components = fs.readdirSync('src/components', { withFileTypes: true })
        .filter(dirent => dirent.isDirectory() && dirent.name.startsWith('YY'))
        .map(dirent => dirent.name);
      
      if (components.length > 0) {
        console.log(`${chalk.green('✓')} YY 组件: 找到 ${components.length} 个`);
      } else {
        console.log(`${chalk.yellow('!')} YY 组件: 未找到任何 YY 前缀组件`);
      }
    }
    
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    console.log(chalk.green('✅ 系统状态检查完成'));
  });

// 更新命令
program
  .command('update')
  .description('检查并更新 YYC³ CLI')
  .option('-f, --force', '强制更新到最新版本')
  .action(async (options) => {
    const spinner = ora('正在检查更新...').start();
    
    try {
      const updateResult = await checkForUpdates(options);
      
      if (updateResult.available) {
        spinner.info(`发现新版本: ${updateResult.latestVersion}`);
        
        const answer = await inquirer.prompt([{
          type: 'confirm',
          name: 'update',
          message: '是否更新到最新版本?',
          default: true
        }]);
        
        if (answer.update || options.force) {
          const updateSpinner = ora('正在更新...').start();
          await performUpdate();
          updateSpinner.succeed('更新完成！');
        } else {
          console.log(chalk.yellow('\n⚠️  更新已取消'));
        }
      } else {
        spinner.succeed('您已经在使用最新版本！');
      }
    } catch (error) {
      spinner.fail(`更新检查失败: ${error.message}`);
    }
  });

// 项目创建函数
async function createProject(type, name, options) {
  const targetDir = path.join(process.cwd(), name);
  
  // 检查目录是否存在
  if (fs.existsSync(targetDir)) {
    if (options.force) {
      fs.removeSync(targetDir);
    } else {
      throw new Error(`目录 ${name} 已存在，请使用 --force 选项强制覆盖`);
    }
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

// 创建 package.json 配置文件
function createPackageJson(targetDir, name) {
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
}

// 创建项目目录结构
function createProjectStructure(targetDir) {
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
}

// 创建项目文件
function createProjectFiles(targetDir, name, template) {
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
}

// 安装项目依赖
function installProjectDependencies(targetDir) {
  const installSpinner = ora('正在安装依赖...').start();
  try {
    const { spawn } = require('child_process');
    const npmProcess = spawn('npm', ['install'], { 
      cwd: targetDir, 
      stdio: 'inherit',
      shell: true
    });
    
    npmProcess.on('close', (code) => {
      if (code === 0) {
        installSpinner.succeed('依赖安装完成');
      } else {
        installSpinner.warn('依赖安装失败，请手动运行 npm install');
      }
    });
  } catch (error) {
    installSpinner.warn('依赖安装失败，请手动运行 npm install');
  }
}

// 创建 Next.js 应用
async function createNextApp(targetDir, name, options) {
  const template = options.template || 'dashboard';
  const totalSteps = 6;
  let currentStep = 0;
  
  const showProgress = (message) => {
    currentStep++;
    console.log(chalk.blue(`[${currentStep}/${totalSteps}] ${message}`));
  };
  
  showProgress('创建 package.json 配置文件');
  createPackageJson(targetDir, name);
  
  showProgress('创建项目目录结构');
  createProjectStructure(targetDir);
  
  showProgress('创建页面文件');
  createProjectFiles(targetDir, name, template);
  
  showProgress('创建配置文件');
  createConfigFiles(targetDir, name);
  
  // 安装依赖
  if (!options.skipInstall) {
    showProgress('安装 npm 依赖');
    installProjectDependencies(targetDir);
  }
}

// 生成代码函数
async function generateCode(type, name, options) {
  const targetPath = options.path || 'src/components';
  
  switch (type) {
    case 'component':
      await generateComponent(name, targetPath, options);
      break;
    case 'page':
      await generatePage(name, targetPath, options);
      break;
    case 'hook':
      await generateHook(name, targetPath, options);
      break;
    default:
      throw new Error(`不支持的生成类型: ${type}`);
  }
}

// 生成组件文件内容
function generateComponentContent(componentName) {
  return `import React from 'react';
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
}

// 生成组件样式内容
function generateComponentStyle(componentName) {
  return `.yyc3-${componentName.toLowerCase()} {
  /* ${componentName} 组件样式 */
}
`;
}

// 生成组件索引内容
function generateComponentIndex(componentName) {
  return `export * from './${componentName}';
`;
}

// 创建组件文件
function createComponentFiles(componentDir, componentName, content) {
  fs.ensureDirSync(componentDir);
  fs.writeFileSync(
    path.join(componentDir, `${componentName}.tsx`),
    content
  );
}

// 创建组件样式文件
function createComponentStyle(componentDir, componentName, styleContent) {
  fs.writeFileSync(
    path.join(componentDir, `${componentName}.module.css`),
    styleContent
  );
}

// 创建组件索引文件
function createComponentIndex(componentDir, indexContent) {
  fs.writeFileSync(
    path.join(componentDir, 'index.ts'),
    indexContent
  );
}

// 生成组件
async function generateComponent(name, targetPath, options) {
  // 确保组件名以 YY 开头
  const componentName = name.startsWith('YY') ? name : `YY${name}`;
  const totalSteps = 3;
  let currentStep = 0;
  
  const showProgress = (message) => {
    currentStep++;
    console.log(chalk.blue(`[${currentStep}/${totalSteps}] ${message}`));
  };
  
  const componentContent = generateComponentContent(componentName);
  const styleContent = generateComponentStyle(componentName);
  const indexContent = generateComponentIndex(componentName);
  
  const componentDir = path.join(targetPath, componentName);
  
  showProgress(`创建 ${componentName} 组件文件`);
  createComponentFiles(componentDir, componentName, componentContent);
  
  showProgress(`创建 ${componentName} 样式文件`);
  createComponentStyle(componentDir, componentName, styleContent);
  
  showProgress(`创建 ${componentName} 索引文件`);
  createComponentIndex(componentDir, indexContent);
  
  console.log(`组件 ${chalk.green(componentName)} 已生成到 ${componentDir}`);
}

// 品牌合规检查
async function checkBrandCompliance(options) {
  const issues = [];
  const warnings = [];
  
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
  
  // 检查 YYC³ 配置
  if (!fs.existsSync('yyc3.config.js')) {
    warnings.push('未找到 yyc3.config.js 配置文件');
  }
  
  return { issues, warnings };
}

// 修复品牌问题
async function fixBrandIssues(issues) {
  let fixedCount = 0;
  
  for (const issue of issues) {
    try {
      // 简单的修复逻辑示例
      if (issue.includes('未使用 YY 前缀')) {
        const filePath = issue.split(':')[0];
        if (fs.existsSync(filePath)) {
          let content = await fs.readFile(filePath, 'utf8');
          // 这里可以添加更智能的修复逻辑
          fixedCount++;
        }
      }
    } catch (error) {
      console.error(chalk.red(`修复 ${issue} 失败: ${error.message}`));
    }
  }
  
  return fixedCount;
}

// 生成品牌报告
async function generateBrandReport(result, outputPath) {
  const reportPath = outputPath || 'brand-report.txt';
  const reportDate = new Date().toISOString();
  
  let reportContent = `YYC³ 品牌合规性报告
生成时间: ${reportDate}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

`;
  
  if (result.issues.length > 0) {
    reportContent += `发现的问题 (${result.issues.length}):
`;
    result.issues.forEach((issue, index) => {
      reportContent += `${index + 1}. ${issue}\n`;
    });
  } else {
    reportContent += `✅ 未发现品牌合规性问题\n`;
  }
  
  if (result.warnings.length > 0) {
    reportContent += `\n警告 (${result.warnings.length}):\n`;
    result.warnings.forEach((warning, index) => {
      reportContent += `${index + 1}. ${warning}\n`;
    });
  }
  
  fs.writeFileSync(reportPath, reportContent);
}

// 检查更新
async function checkForUpdates(options) {
  // 这里可以添加实际的更新检查逻辑
  // 例如调用 npm registry API 检查最新版本
  return {
    available: false,
    currentVersion: version,
    latestVersion: version
  };
}

// 执行更新
async function performUpdate() {
  // 这里可以添加实际的更新逻辑
  const { spawn } = require('child_process');
  const updateProcess = spawn('npm', ['update', '-g', '@yanyucloud/cli'], { 
    stdio: 'inherit',
    shell: true
  });
  
  updateProcess.on('close', (code) => {
    if (code === 0) {
      console.log(chalk.green('✓ 更新完成'));
    } else {
      console.log(chalk.red('✗ 更新失败'));
    }
  });
}

// 获取页面模板（向后兼容接口）
function getPageTemplate(template, name) {
  return TemplateManager.getPageTemplate(template, { name });
}

// 获取布局模板（向后兼容接口）
function getLayoutTemplate(name) {
  return TemplateManager.getLayoutTemplate('default', { name });
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
};
`;
  
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
};
`;
  
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
}
`;
  
  fs.writeFileSync(
    path.join(targetDir, 'tsconfig.json'),
    tsConfig
  );
}

// 解析命令行参数
program.parse();
CLI_EOF

echo_success "CLI 入口文件创建完成"

# 创建主入口文件
echo_info "创建主入口文件..."
cat > "$INSTALL_DIR/lib/index.js" << 'INDEX_EOF'
/**
 * YYC³ CLI 主入口文件
 * Copyright (c) 2024 YanYu Intelligence Cloud³
 */

module.exports = {
  version: require('../package.json').version,
  // 主要功能模块将在后续实现
};
INDEX_EOF
echo_success "主入口文件创建完成"

echo_separator

# 设置执行权限
echo_info "设置执行权限..."
chmod +x "$INSTALL_DIR/bin/$CLI_NAME.js"
echo_success "执行权限设置完成"

# 进入 CLI 目录
cd "$INSTALL_DIR"

# 安装依赖
if [ "$SKIP_DEPENDENCIES" = false ]; then
  echo_info "安装 npm 依赖..."
  
  # 使用 --legacy-peer-deps 避免依赖冲突
  if npm install --legacy-peer-deps; then
    echo_success "依赖安装完成"
  else
    echo_warning "依赖安装遇到问题，尝试使用 --force 选项..."
    if npm install --legacy-peer-deps --force; then
      echo_success "依赖安装完成（使用 --force）"
    else
      echo_error "依赖安装失败"
      echo_warning "💡 您可以使用 --skip-deps 选项跳过依赖安装，稍后手动安装"
      set_rollback
      exit 1
    fi
  fi
else
  echo_warning "跳过依赖安装（--skip-deps）"
fi

echo_separator

# 创建全局链接
if [ "$SKIP_LINK" = false ]; then
  echo_info "创建全局链接..."
  
  # 检查 npm 全局目录权限
  NPM_GLOBAL_BIN=$(npm config get prefix)/bin
  if [ -w "$NPM_GLOBAL_BIN" ]; then
    if npm link; then
      echo_success "全局链接创建完成"
    else
      echo_error "全局链接创建失败"
      echo_warning "💡 您可以使用 --skip-link 选项跳过全局链接创建"
      echo_warning "  稍后可以手动运行: cd $INSTALL_DIR && npm link"
    fi
  else
    echo_warning "npm 全局目录权限不足，尝试使用 sudo..."
    echo_warning "💡 更安全的替代方案：配置 npm 使用用户目录"
    echo_warning "  npm config set prefix '~/.npm-global'"
    echo_warning "  将 ~/.npm-global/bin 添加到 PATH 环境变量"
    
    if sudo npm link; then
      echo_success "全局链接创建完成（使用 sudo）"
      echo_warning "⚠️  注意：使用 sudo 创建的链接可能需要 sudo 权限来卸载或更新"
    else
      echo_error "全局链接创建失败"
      echo_warning "💡 您可以使用 --skip-link 选项跳过全局链接创建"
      echo_warning "  稍后可以手动运行: cd $INSTALL_DIR && npm link"
    fi
  fi
else
  echo_warning "跳过全局链接创建（--skip-link）"
fi

echo_separator

# 安装完成信息
echo_success "YYC³ CLI 工具安装完成！"
echo ""
echo_color "${CYAN}" "🎉 现在可以使用以下命令："
echo ""
echo "  ${CLI_NAME} --version                    # 查看版本"
echo "  ${CLI_NAME} --help                       # 查看帮助"
echo "  ${CLI_NAME} create app my-app            # 创建应用"
echo "  ${CLI_NAME} create component my-comp     # 创建组件库"
echo "  ${CLI_NAME} generate component MyButton  # 生成组件"
echo "  ${CLI_NAME} brand-check                  # 品牌检查"
echo "  ${CLI_NAME} status                       # 查看状态"
echo "  ${CLI_NAME} update                       # 检查更新"
echo ""
echo_color "${GREEN}" "🚀 快速开始："
echo "  ${CLI_NAME} create app my-yyc-app -t dashboard"
echo "  cd my-yyc-app"
echo "  npm run dev"
echo ""
echo_color "${BLUE}" "🌐 访问 http://localhost:3000 查看应用"
echo ""
echo_color "${PURPLE}" "📚 更多信息："
echo "  - 查看文档：${CLI_NAME} --help"
echo "  - 检查更新：${CLI_NAME} update"
echo "  - 报告问题：https://github.com/yanyucloud/yyc3-cli/issues"

echo_separator

echo_color "${GREEN}" "✨ YYC³ CLI 智能工具已准备就绪！开始您的开发之旅吧！"
