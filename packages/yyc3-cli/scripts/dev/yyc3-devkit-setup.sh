#!/bin/bash

# YYC³ 开发者工具包部署脚本
# 基于 YYC 开发环境构建企业级开发者工具包

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
    ██╗   ██╗██╗   ██╗ ██████╗██████╗ 
    ╚██╗ ██╔╝╚██╗ ██╔╝██╔════╝╚════██╗
     ╚████╔╝  ╚████╔╝ ██║      █████╔╝
      ╚██╔╝    ╚██╔╝  ██║      ╚═══██╗
       ██║      ██║   ╚██████╗██████╔╝
       ╚═╝      ╚═╝    ╚═════╝╚═════╝ 
                                      
    言语云³ 开发者工具包
    YanYu Intelligence Cloud³ Developer Kit
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

    log_success "品牌设计资源创建完成"
}

# 创建项目模板
create_project_templates() {
    log_step "创建项目模板..."
    
    # 创建 Next.js 应用模板
    mkdir -p "$DEVKIT_DIR/templates/frontend/nextjs"
    cat > "$DEVKIT_DIR/templates/frontend/nextjs/package.json" << 'EOF'
{
  "name": "{{name}}",
  "version": "0.1.0",
  "private": true,
  "scripts": {
    "dev": "next dev",
    "build": "next build",
    "start": "next start",
    "lint": "next lint",
    "type-check": "tsc --noEmit",
    "test": "jest",
    "test:watch": "jest --watch",
    "brand-check": "yyc brand-check"
  },
  "dependencies": {
    "next": "14.0.0",
    "react": "^18.2.0",
    "react-dom": "^18.2.0",
    "@yanyucloud/core": "^1.0.0",
    "@yanyucloud/ui": "^1.0.0",
    "clsx": "^2.0.0",
    "tailwind-merge": "^2.0.0"
  },
  "devDependencies": {
    "@types/node": "^20.8.0",
    "@types/react": "^18.2.0",
    "@types/react-dom": "^18.2.0",
    "@yanyucloud/eslint-config": "^1.0.0",
    "@yanyucloud/tsconfig": "^1.0.0",
    "autoprefixer": "^10.4.0",
    "eslint": "^8.50.0",
    "eslint-config-next": "14.0.0",
    "postcss": "^8.4.0",
    "tailwindcss": "^3.3.0",
    "typescript": "^5.2.0",
    "jest": "^29.7.0",
    "@testing-library/react": "^13.4.0",
    "@testing-library/jest-dom": "^6.1.0"
  },
  "keywords": [
    "yyc3",
    "yanyucloud",
    "nextjs",
    "react",
    "typescript"
  ]
}
EOF

    # 创建 Next.js 配置
    cat > "$DEVKIT_DIR/templates/frontend/nextjs/next.config.js" << 'EOF'
/** @type {import('next').NextConfig} */
const nextConfig = {
  experimental: {
    appDir: true,
  },
  images: {
    domains: ['localhost'],
  },
  env: {
    YYC3_VERSION: process.env.npm_package_version,
  },
}

module.exports = nextConfig
EOF

    # 创建 Tailwind 配置
    cat > "$DEVKIT_DIR/templates/frontend/nextjs/tailwind.config.js" << 'EOF'
/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    './pages/**/*.{js,ts,jsx,tsx,mdx}',
    './components/**/*.{js,ts,jsx,tsx,mdx}',
    './app/**/*.{js,ts,jsx,tsx,mdx}',
    './src/**/*.{js,ts,jsx,tsx,mdx}',
  ],
  theme: {
    extend: {
      colors: {
        yyc3: {
          primary: {
            50: '#f0f9ff',
            100: '#e0f2fe',
            200: '#bae6fd',
            300: '#7dd3fc',
            400: '#38bdf8',
            500: '#0ea5e9',
            600: '#0284c7',
            700: '#0369a1',
            800: '#075985',
            900: '#0c4a6e',
          },
          secondary: {
            50: '#fafafa',
            100: '#f4f4f5',
            200: '#e4e4e7',
            300: '#d4d4d8',
            400: '#a1a1aa',
            500: '#71717a',
            600: '#52525b',
            700: '#3f3f46',
            800: '#27272a',
            900: '#18181b',
          },
          accent: {
            50: '#fdf4ff',
            100: '#fae8ff',
            200: '#f5d0fe',
            300: '#f0abfc',
            400: '#e879f9',
            500: '#d946ef',
            600: '#c026d3',
            700: '#a21caf',
            800: '#86198f',
            900: '#701a75',
          },
        },
      },
      fontFamily: {
        sans: ['Inter', 'system-ui', 'sans-serif'],
        mono: ['JetBrains Mono', 'Consolas', 'monospace'],
      },
      animation: {
        'fade-in': 'fadeIn 0.5s ease-in-out',
        'slide-up': 'slideUp 0.3s ease-out',
        'bounce-gentle': 'bounceGentle 2s infinite',
      },
      keyframes: {
        fadeIn: {
          '0%': { opacity: '0' },
          '100%': { opacity: '1' },
        },
        slideUp: {
          '0%': { transform: 'translateY(10px)', opacity: '0' },
          '100%': { transform: 'translateY(0)', opacity: '1' },
        },
        bounceGentle: {
          '0%, 100%': { transform: 'translateY(0)' },
          '50%': { transform: 'translateY(-5px)' },
        },
      },
    },
  },
  plugins: [],
}
EOF

    # 创建主页面
    mkdir -p "$DEVKIT_DIR/templates/frontend/nextjs/app"
    cat > "$DEVKIT_DIR/templates/frontend/nextjs/app/page.tsx" << 'EOF'
/**
 * YYC³ Next.js 应用主页
 * Copyright (c) 2024 YanYu Intelligence Cloud³
 */

import { YYButton, YYCard } from '@yanyucloud/ui';
import { generateId } from '@yanyucloud/core';

export default function HomePage() {
  const pageId = generateId('home');

  return (
    <main className="min-h-screen bg-gradient-to-br from-yyc3-primary-50 to-yyc3-accent-50 p-8">
      <div className="max-w-4xl mx-auto">
        {/* 头部 */}
        <header className="text-center mb-12">
          <h1 className="text-4xl font-bold text-yyc3-primary-900 mb-4">
            欢迎使用 YYC³
          </h1>
          <p className="text-xl text-yyc3-secondary-600">
            言语云³ 开发者工具包 - 构建一致、专业的应用体验
          </p>
        </header>

        {/* 功能卡片 */}
        <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-6 mb-12">
          <YYCard className="p-6 hover:shadow-lg transition-shadow">
            <div className="text-yyc3-primary-600 mb-4">
              <svg className="w-8 h-8" fill="currentColor" viewBox="0 0 20 20">
                <path d="M3 4a1 1 0 011-1h12a1 1 0 011 1v2a1 1 0 01-1 1H4a1 1 0 01-1-1V4zM3 10a1 1 0 011-1h6a1 1 0 011 1v6a1 1 0 01-1 1H4a1 1 0 01-1-1v-6zM14 9a1 1 0 00-1 1v6a1 1 0 001 1h2a1 1 0 001-1v-6a1 1 0 00-1-1h-2z" />
              </svg>
            </div>
            <h3 className="text-lg font-semibold text-yyc3-secondary-900 mb-2">
              组件库
            </h3>
            <p className="text-yyc3-secondary-600 mb-4">
              丰富的 UI 组件库，遵循 YYC³ 设计系统
            </p>
            <YYButton variant="outline" size="sm">
              查看组件
            </YYButton>
          </YYCard>

          <YYCard className="p-6 hover:shadow-lg transition-shadow">
            <div className="text-yyc3-accent-600 mb-4">
              <svg className="w-8 h-8" fill="currentColor" viewBox="0 0 20 20">
                <path fillRule="evenodd" d="M12.316 3.051a1 1 0 01.633 1.265l-4 12a1 1 0 11-1.898-.632l4-12a1 1 0 011.265-.633zM5.707 6.293a1 1 0 010 1.414L3.414 10l2.293 2.293a1 1 0 11-1.414 1.414l-3-3a1 1 0 010-1.414l3-3a1 1 0 011.414 0zm8.586 0a1 1 0 011.414 0l3 3a1 1 0 010 1.414l-3 3a1 1 0 11-1.414-1.414L16.586 10l-2.293-2.293a1 1 0 010-1.414z" clipRule="evenodd" />
              </svg>
            </div>
            <h3 className="text-lg font-semibold text-yyc3-secondary-900 mb-2">
              开发工具
            </h3>
            <p className="text-yyc3-secondary-600 mb-4">
              强大的 CLI 工具和代码生成器
            </p>
            <YYButton variant="outline" size="sm">
              了解工具
            </YYButton>
          </YYCard>

          <YYCard className="p-6 hover:shadow-lg transition-shadow">
            <div className="text-yyc3-success-600 mb-4">
              <svg className="w-8 h-8" fill="currentColor" viewBox="0 0 20 20">
                <path fillRule="evenodd" d="M6.267 3.455a3.066 3.066 0 001.745-.723 3.066 3.066 0 013.976 0 3.066 3.066 0 001.745.723 3.066 3.066 0 012.812 2.812c.051.643.304 1.254.723 1.745a3.066 3.066 0 010 3.976 3.066 3.066 0 00-.723 1.745 3.066 3.066 0 01-2.812 2.812 3.066 3.066 0 00-1.745.723 3.066 3.066 0 01-3.976 0 3.066 3.066 0 00-1.745-.723 3.066 3.066 0 01-2.812-2.812 3.066 3.066 0 00-.723-1.745 3.066 3.066 0 010-3.976 3.066 3.066 0 00.723-1.745 3.066 3.066 0 012.812-2.812zm7.44 5.252a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clipRule="evenodd" />
              </svg>
            </div>
            <h3 className="text-lg font-semibold text-yyc3-secondary-900 mb-2">
              品牌合规
            </h3>
            <p className="text-yyc3-secondary-600 mb-4">
              自动化品牌合规检查和修复
            </p>
            <YYButton variant="outline" size="sm">
              运行检查
            </YYButton>
          </YYCard>
        </div>

        {/* 快速开始 */}
        <YYCard className="p-8 text-center">
          <h2 className="text-2xl font-bold text-yyc3-secondary-900 mb-4">
            快速开始
          </h2>
          <p className="text-yyc3-secondary-600 mb-6">
            使用 YYC³ CLI 创建您的第一个组件
          </p>
          <div className="bg-yyc3-secondary-100 rounded-lg p-4 mb-6 font-mono text-sm text-left">
            <div className="text-yyc3-secondary-500"># 生成新组件</div>
            <div className="text-yyc3-primary-700">yyc generate component MyButton</div>
            <div className="text-yyc3-secondary-500 mt-2"># 运行品牌检查</div>
            <div className="text-yyc3-primary-700">yyc brand-check</div>
          </div>
          <YYButton variant="primary" size="lg">
            查看文档
          </YYButton>
        </YYCard>

        {/* 页面 ID 显示（开发模式） */}
        {process.env.NODE_ENV === 'development' && (
          <div className="mt-8 text-center text-xs text-yyc3-secondary-400">
            页面 ID: {pageId}
          </div>
        )}
      </div>
    </main>
  );
}
EOF

    # 创建布局文件
    cat > "$DEVKIT_DIR/templates/frontend/nextjs/app/layout.tsx" << 'EOF'
/**
 * YYC³ Next.js 应用根布局
 * Copyright (c) 2024 YanYu Intelligence Cloud³
 */

import type { Metadata } from 'next';
import { Inter } from 'next/font/google';
import './globals.css';

const inter = Inter({ subsets: ['latin'] });

export const metadata: Metadata = {
  title: 'YYC³ 应用',
  description: '基于 YanYu Intelligence Cloud³ 开发者工具包构建',
  keywords: ['YYC³', 'YanYu Intelligence Cloud', '言语云'],
  authors: [{ name: 'YanYu Intelligence Cloud³' }],
  creator: 'YanYu Intelligence Cloud³',
  publisher: 'YanYu Intelligence Cloud³',
  robots: 'index, follow',
  viewport: 'width=device-width, initial-scale=1',
  themeColor: '#0ea5e9',
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="zh-CN" data-theme="light">
      <head>
        <link rel="icon" href="/favicon.ico" />
        <link rel="apple-touch-icon" href="/apple-touch-icon.png" />
        <meta name="brand" content="YYC³" />
        <meta name="generator" content="YYC³ Developer Kit" />
      </head>
      <body className={inter.className}>
        <div id="yyc3-app">
          {children}
        </div>
        <div id="yyc3-portal" />
      </body>
    </html>
  );
}
EOF

    # 创建全局样式
    cat > "$DEVKIT_DIR/templates/frontend/nextjs/app/globals.css" << 'EOF'
/**
 * YYC³ 全局样式
 * Copyright (c) 2024 YanYu Intelligence Cloud³
 */

@import 'tailwindcss/base';
@import 'tailwindcss/components';
@import 'tailwindcss/utilities';

/* YYC³ 设计系统变量 */
@import url('https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap');
@import url('https://fonts.googleapis.com/css2?family=JetBrains+Mono:wght@400;500;600&display=swap');

:root {
  /* YYC³ 品牌色彩 */
  --yyc3-brand-primary: #0ea5e9;
  --yyc3-brand-secondary: #71717a;
  --yyc3-brand-accent: #d946ef;
  
  /* 动画时长 */
  --yyc3-duration-fast: 150ms;
  --yyc3-duration-normal: 300ms;
  --yyc3-duration-slow: 500ms;
  
  /* Z-index 层级 */
  --yyc3-z-dropdown: 1000;
  --yyc3-z-modal: 1050;
  --yyc3-z-tooltip: 1100;
  --yyc3-z-toast: 1200;
}

/* 基础样式重置 */
* {
  box-sizing: border-box;
}

html {
  scroll-behavior: smooth;
}

body {
  font-family: var(--yyc3-font-family-sans);
  line-height: 1.6;
  color: var(--yyc3-text-primary);
  background-color: var(--yyc3-bg-primary);
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
}

/* YYC³ 组件基础样式 */
.yyc3-component {
  position: relative;
}

.yyc3-component[data-loading="true"] {
  pointer-events: none;
  opacity: 0.6;
}

/* 无障碍支持 */
.sr-only {
  position: absolute;
  width: 1px;
  height: 1px;
  padding: 0;
  margin: -1px;
  overflow: hidden;
  clip: rect(0, 0, 0, 0);
  white-space: nowrap;
  border: 0;
}

/* 焦点样式 */
.yyc3-focus {
  outline: 2px solid var(--yyc3-brand-primary);
  outline-offset: 2px;
}

/* 动画类 */
.yyc3-animate-in {
  animation: yyc3-fade-in var(--yyc3-duration-normal) ease-out;
}

.yyc3-animate-out {
  animation: yyc3-fade-out var(--yyc3-duration-normal) ease-in;
}

@keyframes yyc3-fade-in {
  from {
    opacity: 0;
    transform: translateY(4px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

@keyframes yyc3-fade-out {
  from {
    opacity: 1;
    transform: translateY(0);
  }
  to {
    opacity: 0;
    transform: translateY(-4px);
  }
}

/* 滚动条样式 */
::-webkit-scrollbar {
  width: 8px;
  height: 8px;
}

::-webkit-scrollbar-track {
  background: var(--yyc3-secondary-100);
}

::-webkit-scrollbar-thumb {
  background: var(--yyc3-secondary-300);
  border-radius: 4px;
}

::-webkit-scrollbar-thumb:hover {
  background: var(--yyc3-secondary-400);
}

/* 深色主题支持 */
[data-theme="dark"] {
  color-scheme: dark;
}

[data-theme="dark"] ::-webkit-scrollbar-track {
  background: var(--yyc3-secondary-800);
}

[data-theme="dark"] ::-webkit-scrollbar-thumb {
  background: var(--yyc3-secondary-600);
}

[data-theme="dark"] ::-webkit-scrollbar-thumb:hover {
  background: var(--yyc3-secondary-500);
}

/* 打印样式 */
@media print {
  .yyc3-no-print {
    display: none !important;
  }
  
  .yyc3-component {
    break-inside: avoid;
  }
}

/* 高对比度模式支持 */
@media (prefers-contrast: high) {
  .yyc3-component {
    border: 1px solid currentColor;
  }
}

/* 减少动画偏好支持 */
@media (prefers-reduced-motion: reduce) {
  *,
  *::before,
  *::after {
    animation-duration: 0.01ms !important;
    animation-iteration-count: 1 !important;
    transition-duration: 0.01ms !important;
  }
}
EOF

    log_success "项目模板创建完成"
}

# 创建 UI 组件库
create_ui_components() {
    log_step "创建 UI 组件库..."
    
    # 创建 UI 包结构
    mkdir -p "$DEVKIT_DIR/packages/ui/src"/{components,hooks,utils,types,styles}
    
    # 创建 UI 包配置
    cat > "$DEVKIT_DIR/packages/ui/package.json" << 'EOF'
{
  "name": "@yanyucloud/ui",
  "version": "1.0.0",
  "description": "YYC³ UI 组件库",
  "main": "dist/index.js",
  "module": "dist/index.esm.js",
  "types": "dist/index.d.ts",
  "files": [
    "dist",
    "styles"
  ],
  "scripts": {
    "build": "rollup -c",
    "dev": "rollup -c -w",
    "test": "jest",
    "lint": "eslint src/**/*.{ts,tsx}",
    "type-check": "tsc --noEmit",
    "storybook": "storybook dev -p 6006",
    "build-storybook": "storybook build"
  },
  "keywords": [
    "yanyucloud",
    "yyc3",
    "ui",
    "components",
    "react"
  ],
  "author": "YanYu Intelligence Cloud",
  "license": "MIT",
  "dependencies": {
    "@yanyucloud/core": "^1.0.0",
    "clsx": "^2.0.0",
    "react-aria": "^3.30.0",
    "react-stately": "^3.28.0",
    "framer-motion": "^10.16.0"
  },
  "devDependencies": {
    "@types/react": "^18.2.0",
    "@types/react-dom": "^18.2.0",
    "react": "^18.2.0",
    "react-dom": "^18.2.0",
    "typescript": "^5.2.0",
    "rollup": "^3.28.0",
    "@rollup/plugin-typescript": "^11.1.2",
    "@rollup/plugin-node-resolve": "^15.1.0",
    "@rollup/plugin-commonjs": "^25.0.3",
    "jest": "^29.7.0",
    "@testing-library/react": "^13.4.0",
    "@testing-library/jest-dom": "^6.1.0",
    "@storybook/react": "^7.5.0",
    "@storybook/react-vite": "^7.5.0"
  },
  "peerDependencies": {
    "react": ">=16.8.0",
    "react-dom": ">=16.8.0"
  }
}
EOF

    # 创建按钮组件
    cat > "$DEVKIT_DIR/packages/ui/src/components/Button.tsx" << 'EOF'
/**
 * YYC³ 按钮组件
 * Copyright (c) 2024 YanYu Intelligence Cloud³
 */

import React, { forwardRef } from 'react';
import { motion, MotionProps } from 'framer-motion';
import { cn } from '@yanyucloud/core';
import type { YYCBaseProps, YYCSize, YYCVariant } from '@yanyucloud/core';

export interface YYButtonProps 
  extends YYCBaseProps, 
    Omit<React.ButtonHTMLAttributes<HTMLButtonElement>, 'size'>,
    MotionProps {
  /** 按钮变体 */
  variant?: YYCVariant | 'outline' | 'ghost' | 'link';
  /** 按钮尺寸 */
  size?: YYCSize;
  /** 是否为加载状态 */
  loading?: boolean;
  /** 是否为全宽按钮 */
  fullWidth?: boolean;
  /** 左侧图标 */
  leftIcon?: React.ReactNode;
  /** 右侧图标 */
  rightIcon?: React.ReactNode;
  /** 子元素 */
  children?: React.ReactNode;
}

const buttonVariants = {
  primary: 'bg-yyc3-primary-500 text-white hover:bg-yyc3-primary-600 focus:ring-yyc3-primary-500',
  secondary: 'bg-yyc3-secondary-500 text-white hover:bg-yyc3-secondary-600 focus:ring-yyc3-secondary-500',
  accent: 'bg-yyc3-accent-500 text-white hover:bg-yyc3-accent-600 focus:ring-yyc3-accent-500',
  success: 'bg-yyc3-success-500 text-white hover:bg-yyc3-success-600 focus:ring-yyc3-success-500',
  warning: 'bg-yyc3-warning-500 text-white hover:bg-yyc3-warning-600 focus:ring-yyc3-warning-500',
  error: 'bg-yyc3-error-500 text-white hover:bg-yyc3-error-600 focus:ring-yyc3-error-500',
  outline: 'border-2 border-yyc3-primary-500 text-yyc3-primary-500 hover:bg-yyc3-primary-50 focus:ring-yyc3-primary-500',
  ghost: 'text-yyc3-primary-500 hover:bg-yyc3-primary-50 focus:ring-yyc3-primary-500',
  link: 'text-yyc3-primary-500 hover:text-yyc3-primary-600 underline-offset-4 hover:underline focus:ring-yyc3-primary-500',
};

const buttonSizes = {
  xs: 'px-2 py-1 text-xs',
  sm: 'px-3 py-1.5 text-sm',
  md: 'px-4 py-2 text-base',
  lg: 'px-6 py-3 text-lg',
  xl: 'px-8 py-4 text-xl',
};

export const YYButton = forwardRef<HTMLButtonElement, YYButtonProps>(
  (
    {
      variant = 'primary',
      size = 'md',
      loading = false,
      fullWidth = false,
      leftIcon,
      rightIcon,
      children,
      className,
      disabled,
      ...props
    },
    ref
  ) => {
    const isDisabled = disabled || loading;

    return (
      <motion.button
        ref={ref}
        className={cn(
          // 基础样式
          'yyc3-component inline-flex items-center justify-center',
          'font-medium rounded-lg transition-all duration-200',
          'focus:outline-none focus:ring-2 focus:ring-offset-2',
          'disabled:opacity-50 disabled:cursor-not-allowed',
          'active:scale-95',
          
          // 变体样式
          buttonVariants[variant],
          
          // 尺寸样式
          buttonSizes[size],
          
          // 全宽样式
          fullWidth && 'w-full',
          
          // 加载状态样式
          loading && 'cursor-wait',
          
          className
        )}
        disabled={isDisabled}
        data-variant={variant}
        data-size={size}
        data-loading={loading}
        whileHover={{ scale: isDisabled ? 1 : 1.02 }}
        whileTap={{ scale: isDisabled ? 1 : 0.98 }}
        {...props}
      >
        {/* 左侧图标 */}
        {leftIcon && !loading && (
          <span className="mr-2 flex-shrink-0">
            {leftIcon}
          </span>
        )}
        
        {/* 加载指示器 */}
        {loading && (
          <span className="mr-2 flex-shrink-0">
            <svg
              className="animate-spin h-4 w-4"
              xmlns="http://www.w3.org/2000/svg"
              fill="none"
              viewBox="0 0 24 24"
            >
              <circle
                className="opacity-25"
                cx="12"
                cy="12"
                r="10"
                stroke="currentColor"
                strokeWidth="4"
              />
              <path
                className="opacity-75"
                fill="currentColor"
                d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"
              />
            </svg>
          </span>
        )}
        
        {/* 按钮文本 */}
        {children && (
          <span className={cn(
            'flex-1',
            (leftIcon || loading || rightIcon) && 'mx-1'
          )}>
            {children}
          </span>
        )}
        
        {/* 右侧图标 */}
        {rightIcon && !loading && (
          <span className="ml-2 flex-shrink-0">
            {rightIcon}
          </span>
        )}
      </motion.button>
    );
  }
);

YYButton.displayName = 'YYButton';

export default YYButton;
EOF

    # 创建卡片组件
    cat > "$DEVKIT_DIR/packages/ui/src/components/Card.tsx" << 'EOF'
/**
 * YYC³ 卡片组件
 * Copyright (c) 2024 YanYu Intelligence Cloud³
 */

import React, { forwardRef } from 'react';
import { motion, MotionProps } from 'framer-motion';
import { cn } from '@yanyucloud/core';
import type { YYCBaseProps } from '@yanyucloud/core';

export interface YYCardProps 
  extends YYCBaseProps, 
    React.HTMLAttributes<HTMLDivElement>,
    MotionProps {
  /** 卡片变体 */
  variant?: 'default' | 'outlined' | 'elevated' | 'filled';
  /** 是否可悬停 */
  hoverable?: boolean;
  /** 是否可点击 */
  clickable?: boolean;
  /** 内边距 */
  padding?: 'none' | 'sm' | 'md' | 'lg' | 'xl';
  /** 子元素 */
  children?: React.ReactNode;
}

const cardVariants = {
  default: 'bg-white border border-yyc3-secondary-200',
  outlined: 'bg-transparent border-2 border-yyc3-secondary-300',
  elevated: 'bg-white shadow-lg border-0',
  filled: 'bg-yyc3-secondary-50 border-0',
};

const cardPadding = {
  none: '',
  sm: 'p-3',
  md: 'p-4',
  lg: 'p-6',
  xl: 'p-8',
};

export const YYCard = forwardRef<HTMLDivElement, YYCardProps>(
  (
    {
      variant = 'default',
      hoverable = false,
      clickable = false,
      padding = 'md',
      children,
      className,
      ...props
    },
    ref
  ) => {
    return (
      <motion.div
        ref={ref}
        className={cn(
          // 基础样式
          'yyc3-component rounded-lg transition-all duration-200',
          
          // 变体样式
          cardVariants[variant],
          
          // 内边距
          cardPadding[padding],
          
          // 交互样式
          hoverable && 'hover:shadow-md hover:-translate-y-1',
          clickable && 'cursor-pointer hover:shadow-md hover:-translate-y-1 active:translate-y-0',
          
          // 深色主题支持
          '[data-theme="dark"] &': {
            default: 'bg-yyc3-secondary-800 border-yyc3-secondary-700',
            outlined: 'border-yyc3-secondary-600',
            elevated: 'bg-yyc3-secondary-800 shadow-xl',
            filled: 'bg-yyc3-secondary-700',
          }[variant],
          
          className
        )}
        data-variant={variant}
        data-hoverable={hoverable}
        data-clickable={clickable}
        whileHover={hoverable || clickable ? { y: -2 } : undefined}
        whileTap={clickable ? { y: 0 } : undefined}
        {...props}
      >
        {children}
      </motion.div>
    );
  }
);

YYCard.displayName = 'YYCard';

// 卡片头部组件
export interface YYCardHeaderProps extends YYCBaseProps, React.HTMLAttributes<HTMLDivElement> {
  title?: string;
  subtitle?: string;
  action?: React.ReactNode;
  children?: React.ReactNode;
}

export const YYCardHeader = forwardRef<HTMLDivElement, YYCardHeaderProps>(
  ({ title, subtitle, action, children, className, ...props }, ref) => {
    return (
      <div
        ref={ref}
        className={cn(
          'yyc3-component flex items-start justify-between',
          'pb-4 border-b border-yyc3-secondary-200',
          '[data-theme="dark"] & border-yyc3-secondary-700',
          className
        )}
        {...props}
      >
        <div className="flex-1">
          {title && (
            <h3 className="text-lg font-semibold text-yyc3-secondary-900 [data-theme='dark'] & text-yyc3-secondary-100">
              {title}
            </h3>
          )}
          {subtitle && (
            <p className="text-sm text-yyc3-secondary-600 [data-theme='dark'] & text-yyc3-secondary-400 mt-1">
              {subtitle}
            </p>
          )}
          {children}
        </div>
        {action && (
          <div className="ml-4 flex-shrink-0">
            {action}
          </div>
        )}
      </div>
    );
  }
);

YYCardHeader.displayName = 'YYCardHeader';

// 卡片内容组件
export interface YYCardContentProps extends YYCBaseProps, React.HTMLAttributes<HTMLDivElement> {
  children?: React.ReactNode;
}

export const YYCardContent = forwardRef<HTMLDivElement, YYCardContentProps>(
  ({ children, className, ...props }, ref) => {
    return (
      <div
        ref={ref}
        className={cn('yyc3-component py-4', className)}
        {...props}
      >
        {children}
      </div>
    );
  }
);

YYCardContent.displayName = 'YYCardContent';

// 卡片底部组件
export interface YYCardFooterProps extends YYCBaseProps, React.HTMLAttributes<HTMLDivElement> {
  children?: React.ReactNode;
}

export const YYCardFooter = forwardRef<HTMLDivElement, YYCardFooterProps>(
  ({ children, className, ...props }, ref) => {
    return (
      <div
        ref={ref}
        className={cn(
          'yyc3-component flex items-center justify-end',
          'pt-4 border-t border-yyc3-secondary-200',
          '[data-theme="dark"] & border-yyc3-secondary-700',
          className
        )}
        {...props}
      >
        {children}
      </div>
    );
  }
);

YYCardFooter.displayName = 'YYCardFooter';

export default YYCard;
EOF

    # 创建输入框组件
    cat > "$DEVKIT_DIR/packages/ui/src/components/Input.tsx" << 'EOF'
/**
 * YYC³ 输入框组件
 * Copyright (c) 2024 YanYu Intelligence Cloud³
 */

import React, { forwardRef, useState } from 'react';
import { cn } from '@yanyucloud/core';
import type { YYCBaseProps, YYCSize } from '@yanyucloud/core';

export interface YYInputProps 
  extends YYCBaseProps, 
    Omit<React.InputHTMLAttributes<HTMLInputElement>, 'size'> {
  /** 输入框尺寸 */
  size?: YYCSize;
  /** 标签 */
  label?: string;
  /** 错误信息 */
  error?: string;
  /** 帮助文本 */
  helperText?: string;
  /** 左侧图标 */
  leftIcon?: React.ReactNode;
  /** 右侧图标 */
  rightIcon?: React.ReactNode;
  /** 是否必填 */
  required?: boolean;
  /** 是否全宽 */
  fullWidth?: boolean;
}

const inputSizes = {
  xs: 'px-2 py-1 text-xs',
  sm: 'px-3 py-1.5 text-sm',
  md: 'px-3 py-2 text-base',
  lg: 'px-4 py-3 text-lg',
  xl: 'px-5 py-4 text-xl',
};

export const YYInput = forwardRef<HTMLInputElement, YYInputProps>(
  (
    {
      size = 'md',
      label,
      error,
      helperText,
      leftIcon,
      rightIcon,
      required = false,
      fullWidth = false,
      className,
      id,
      ...props
    },
    ref
  ) => {
    const [focused, setFocused] = useState(false);
    const inputId = id || `yyc3-input-${Math.random().toString(36).substr(2, 9)}`;
    const hasError = Boolean(error);

    return (
      <div className={cn('yyc3-component', fullWidth && 'w-full')}>
        {/* 标签 */}
        {label && (
          <label
            htmlFor={inputId}
            className={cn(
              'block text-sm font-medium mb-2',
              hasError 
                ? 'text-yyc3-error-600' 
                : 'text-yyc3-secondary-700 [data-theme="dark"] & text-yyc3-secondary-300'
            )}
          >
            {label}
            {required && (
              <span className="text-yyc3-error-500 ml-1">*</span>
            )}
          </label>
        )}

        {/* 输入框容器 */}
        <div className="relative">
          {/* 左侧图标 */}
          {leftIcon && (
            <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
              <span className={cn(
                'text-yyc3-secondary-400',
                hasError && 'text-yyc3-error-400'
              )}>
                {leftIcon}
              </span>
            </div>
          )}

          {/* 输入框 */}
          <input
            ref={ref}
            id={inputId}
            className={cn(
              // 基础样式
              'yyc3-component block w-full rounded-lg border transition-all duration-200',
              'focus:outline-none focus:ring-2 focus:ring-offset-0',
              'disabled:opacity-50 disabled:cursor-not-allowed',
              'placeholder:text-yyc3-secondary-400',
              
              // 尺寸样式
              inputSizes[size],
              
              // 图标间距
              leftIcon && 'pl-10',
              rightIcon && 'pr-10',
              
              // 状态样式
              hasError ? [
                'border-yyc3-error-300 text-yyc3-error-900',
                'focus:border-yyc3-error-500 focus:ring-yyc3-error-500',
                '[data-theme="dark"] & border-yyc3-error-600 text-yyc3-error-100',
              ] : [
                'border-yyc3-secondary-300 text-yyc3-secondary-900',
                'focus:border-yyc3-primary-500 focus:ring-yyc3-primary-500',
                '[data-theme="dark"] & border-yyc3-secondary-600 bg-yyc3-secondary-800 text-yyc3-secondary-100',
              ],
              
              // 聚焦状态
              focused && !hasError && 'ring-2 ring-yyc3-primary-500 border-yyc3-primary-500',
              
              className
            )}
            onFocus={(e) => {
              setFocused(true);
              props.onFocus?.(e);
            }}
            onBlur={(e) => {
              setFocused(false);
              props.onBlur?.(e);
            }}
            aria-invalid={hasError}
            aria-describedby={
              error ? `${inputId}-error` : 
              helperText ? `${inputId}-helper` : undefined
            }
            {...props}
          />

          {/* 右侧图标 */}
          {rightIcon && (
            <div className="absolute inset-y-0 right-0 pr-3 flex items-center pointer-events-none">
              <span className={cn(
                'text-yyc3-secondary-400',
                hasError && 'text-yyc3-error-400'
              )}>
                {rightIcon}
              </span>
            </div>
          )}
        </div>

        {/* 错误信息 */}
        {error && (
          <p
            id={`${inputId}-error`}
            className="mt-2 text-sm text-yyc3-error-600 [data-theme='dark'] & text-yyc3-error-400"
          >
            {error}
          </p>
        )}

        {/* 帮助文本 */}
        {helperText && !error && (
          <p
            id={`${inputId}-helper`}
            className="mt-2 text-sm text-yyc3-secondary-500 [data-theme='dark'] & text-yyc3-secondary-400"
          >
            {helperText}
          </p>
        )}
      </div>
    );
  }
);

YYInput.displayName = 'YYInput';

export default YYInput;
EOF

    # 创建组件库入口文件
    cat > "$DEVKIT_DIR/packages/ui/src/index.ts" << 'EOF'
/**
 * YYC³ UI 组件库
 * Copyright (c) 2024 YanYu Intelligence Cloud³
 */

// 导出组件
export { YYButton } from './components/Button';
export { YYCard, YYCardHeader, YYCardContent, YYCardFooter } from './components/Card';
export { YYInput } from './components/Input';

// 导出类型
export type { YYButtonProps } from './components/Button';
export type { YYCardProps, YYCardHeaderProps, YYCardContentProps, YYCardFooterProps } from './components/Card';
export type { YYInputProps } from './components/Input';

// 导出工具函数
export * from './utils';

// 导出 Hooks
export * from './hooks';

// 版本信息
export const UI_VERSION = '1.0.0';
EOF

    log_success "UI 组件库创建完成"
}

# 创建部署和管理脚本
create_deployment_scripts() {
    log_step "创建部署和管理脚本..."
    
    # 创建主部署脚本
    cat > "$DEVKIT_DIR/scripts/deploy-devkit.sh" << 'EOF'
#!/bin/bash

# YYC³ 开发者工具包部署脚本

set -e

DEVKIT_DIR="/Volume2/YYC/yyc3-devkit"
REGISTRY_URL="http://192.168.3.45:4873"
BUILD_DIR="$DEVKIT_DIR/dist"

log_info() { echo -e "\033[0;34m[信息]\033[0m $1"; }
log_success() { echo -e "\033[0;32m[成功]\033[0m $1"; }
log_error() { echo -e "\033[0;31m[错误]\033[0m $1"; }

# 构建所有包
build_packages() {
    log_info "构建 NPM 包..."
    
    # 构建核心包
    cd "$DEVKIT_DIR/packages/core"
    npm run build
    
    # 构建 UI 包
    cd "$DEVKIT_DIR/packages/ui"
    npm run build
    
    # 构建 CLI 工具
    cd "$DEVKIT_DIR/tools/cli"
    npm run build
    
    log_success "所有包构建完成"
}

# 发布包到私有仓库
publish_packages() {
    log_info "发布包到私有仓库..."
    
    # 发布核心包
    cd "$DEVKIT_DIR/packages/core"
    npm publish --registry="$REGISTRY_URL"
    
    # 发布 UI 包
    cd "$DEVKIT_DIR/packages/ui"
    npm publish --registry="$REGISTRY_URL"
    
    # 发布 CLI 工具
    cd "$DEVKIT_DIR/tools/cli"
    npm publish --registry="$REGISTRY_URL"
    
    log_success "所有包发布完成"
}

# 部署文档站点
deploy_docs() {
    log_info "部署文档站点..."
    
    # 构建文档
    cd "$DEVKIT_DIR/docs"
    npm run build
    
    # 复制到 Web 服务器目录
    cp -r dist/* /volume1/web/yyc3-docs/
    
    log_success "文档站点部署完成"
}

# 主函数
main() {
    echo "🚀 开始部署 YYC³ 开发者工具包..."
    
    build_packages
    publish_packages
    deploy_docs
    
    echo "✅ YYC³ 开发者工具包部署完成！"
    echo "📚 文档地址: http://192.168.3.45/yyc3-docs"
    echo "📦 NPM 仓库: $REGISTRY_URL"
}

main "$@"
EOF

    # 创建监控脚本
    cat > "$DEVKIT_DIR/scripts/monitor-devkit.sh" << 'EOF'
#!/bin/bash

# YYC³ 开发者工具包监控脚本

DEVKIT_DIR="/Volume2/YYC/yyc3-devkit"
LOG_FILE="/volume1/logs/yyc3-devkit.log"
ALERT_WEBHOOK="${WECHAT_WEBHOOK_URL}"

log_with_timestamp() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# 检查服务状态
check_services() {
    local status=0
    
    # 检查 NPM 仓库
    if ! curl -s "http://192.168.3.45:4873" > /dev/null; then
        log_with_timestamp "❌ NPM 仓库服务异常"
        status=1
    else
        log_with_timestamp "✅ NPM 仓库服务正常"
    fi
    
    # 检查文档站点
    if ! curl -s "http://192.168.3.45/yyc3-docs" > /dev/null; then
        log_with_timestamp "❌ 文档站点异常"
        status=1
    else
        log_with_timestamp "✅ 文档站点正常"
    fi
    
    # 检查磁盘空间
    local disk_usage=$(df /Volume2 | awk 'NR==2 {print $5}' | sed 's/%//')
    if [ "$disk_usage" -gt 80 ]; then
        log_with_timestamp "⚠️ 磁盘使用率过高: ${disk_usage}%"
        status=1
    else
        log_with_timestamp "✅ 磁盘使用率正常: ${disk_usage}%"
    fi
    
    return $status
}

# 发送告警
send_alert() {
    local message="$1"
    
    if [ -n "$ALERT_WEBHOOK" ]; then
        curl -X POST "$ALERT_WEBHOOK" \
            -H "Content-Type: application/json" \
            -d "{\"msgtype\":\"text\",\"text\":{\"content\":\"YYC³ 开发者工具包告警: $message\"}}"
    fi
}

# 主监控循环
main() {
    log_with_timestamp "🔍 开始 YYC³ 开发者工具包监控..."
    
    while true; do
        if ! check_services; then
            send_alert "服务状态检查失败，请检查系统状态"
        fi
        
        # 每5分钟检查一次
        sleep 300
    done
}

main "$@"
EOF

    # 创建备份脚本
    cat > "$DEVKIT_DIR/scripts/backup-devkit.sh" << 'EOF'
#!/bin/bash

# YYC³ 开发者工具包备份脚本

DEVKIT_DIR="/Volume2/YYC/yyc3-devkit"
BACKUP_DIR="/volume1/backups/yyc3-devkit"
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_NAME="yyc3-devkit-backup-$DATE"

log_info() { echo -e "\033[0;34m[信息]\033[0m $1"; }
log_success() { echo -e "\033[0;32m[成功]\033[0m $1"; }

# 创建备份
create_backup() {
    log_info "创建 YYC³ 开发者工具包备份..."
    
    # 创建备份目录
    mkdir -p "$BACKUP_DIR"
    
    # 压缩整个工具包目录
    tar -czf "$BACKUP_DIR/$BACKUP_NAME.tar.gz" \
        -C "$(dirname "$DEVKIT_DIR")" \
        "$(basename "$DEVKIT_DIR")" \
        --exclude="node_modules" \
        --exclude="dist" \
        --exclude=".git"
    
    log_success "备份创建完成: $BACKUP_DIR/$BACKUP_NAME.tar.gz"
}

# 清理旧备份
cleanup_old_backups() {
    log_info "清理旧备份文件..."
    
    # 保留最近7天的备份
    find "$BACKUP_DIR" -name "yyc3-devkit-backup-*.tar.gz" -mtime +7 -delete
    
    log_success "旧备份清理完成"
}

# 主函数
main() {
    create_backup
    cleanup_old_backups
    
    echo "📦 YYC³ 开发者工具包备份完成！"
    echo "📁 备份位置: $BACKUP_DIR/$BACKUP_NAME.tar.gz"
}

main "$@"
EOF

    chmod +x "$DEVKIT_DIR/scripts"/*.sh
    
    log_success "部署和管理脚本创建完成"
}

# 创建配置文件和文档
create_configs_and_docs() {
    log_step "创建配置文件和文档..."
    
    # 创建主配置文件
    cat > "$DEVKIT_DIR/yyc3-devkit.config.js" << 'EOF'
/**
 * YYC³ 开发者工具包配置
 * Copyright (c) 2024 YanYu Intelligence Cloud³
 */

module.exports = {
  // 版本信息
  version: '1.0.0',
  name: 'YYC³ Developer Kit',
  
  // 服务配置
  services: {
    registry: {
      url: 'http://192.168.3.45:4873',
      scope: '@yanyucloud'
    },
    docs: {
      url: 'http://192.168.3.45/yyc3-docs',
      port: 3001
    },
    storybook: {
      port: 6006
    }
  },
  
  // 构建配置
  build: {
    outDir: 'dist',
    sourcemap: true,
    minify: true,
    target: 'es2020'
  },
  
  // 品牌配置
  brand: {
    name: 'YYC³',
    fullName: 'YanYu Intelligence Cloud³',
    colors: {
      primary: '#0ea5e9',
      secondary: '#71717a',
      accent: '#d946ef'
    },
    fonts: {
      sans: ['Inter', 'system-ui', 'sans-serif'],
      mono: ['JetBrains Mono', 'Consolas', 'monospace']
    }
  },
  
  // CLI 配置
  cli: {
    defaultTemplate: 'nextjs',
    componentPrefix: 'YY',
    generateTests: true,
    generateStories: true
  },
  
  // 代码质量配置
  quality: {
    eslint: {
      extends: ['@yanyucloud/eslint-config']
    },
    prettier: {
      printWidth: 80,
      tabWidth: 2,
      semi: true,
      singleQuote: true,
      trailingComma: 'es5'
    },
    brandCheck: {
      enabled: true,
      autoFix: false,
      rules: {
        'copyright-header': 'warn',
        'brand-identifier': 'info',
        'component-naming': 'warn',
        'css-naming': 'info',
        'brand-colors': 'error',
        'component-usage': 'warn'
      }
    }
  },
  
  // 部署配置
  deployment: {
    registry: {
      url: 'http://192.168.3.45:4873',
      publishConfig: {
        access: 'restricted'
      }
    },
    docs: {
      buildCommand: 'npm run build',
      outputDir: 'dist',
      deployPath: '/volume1/web/yyc3-docs'
    }
  },
  
  // 监控配置
  monitoring: {
    enabled: true,
    interval: 300000, // 5分钟
    alerts: {
      webhook: process.env.WECHAT_WEBHOOK_URL,
      diskThreshold: 80,
      memoryThreshold: 85
    }
  },
  
  // 备份配置
  backup: {
    enabled: true,
    schedule: '0 2 * * *', // 每天凌晨2点
    retention: 7, // 保留7天
    excludes: ['node_modules', 'dist', '.git']
  }
};
EOF

    # 创建 README 文件
    cat > "$DEVKIT_DIR/README.md" << 'EOF'
# YYC³ 开发者工具包

<div align="center">
  <h1>🚀 YanYu Intelligence Cloud³ Developer Kit</h1>
  <p>构建一致、专业的 YYC³ 生态系统</p>
  
  [![Version](https://img.shields.io/badge/version-1.0.0-blue.svg)](https://github.com/yanyucloud/devkit)
  [![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
  [![TypeScript](https://img.shields.io/badge/TypeScript-Ready-blue.svg)](https://www.typescriptlang.org/)
</div>

## 📋 目录

- [简介](#简介)
- [特性](#特性)
- [快速开始](#快速开始)
- [项目结构](#项目结构)
- [使用指南](#使用指南)
- [API 文档](#api-文档)
- [贡献指南](#贡献指南)
- [许可证](#许可证)

## 🎯 简介

YYC³ 开发者工具包是一套全面的资源集合，旨在帮助开发者高效地构建符合言语云³品牌标准的应用和模块。工具包提供从设计资源到代码模板、从开发工具到文档生成的全流程支持。

### 核心价值

- **品牌一致性**: 确保所有开发产出符合 YYC³ 品牌标准
- **开发效率**: 提供预配置工具和模板，加速开发流程
- **质量保证**: 内置最佳实践和质量检查机制
- **学习曲线降低**: 通过示例和文档简化新开发者的入门过程

## ✨ 特性

### 🎨 设计系统
- 完整的品牌视觉资源
- 统一的色彩系统和字体规范
- 可复用的 UI 组件库
- 响应式设计模式

### 🛠️ 开发工具
- 强大的 CLI 工具
- 代码生成器
- 品牌合规性检查
- IDE 扩展支持

### 📦 NPM 包生态
- `@yanyucloud/core` - 核心工具库
- `@yanyucloud/ui` - UI 组件库
- `@yanyucloud/cli` - 命令行工具
- `@yanyucloud/eslint-config` - 代码规范

### 🏗️ 项目模板
- Next.js 应用模板
- React 组件库模板
- Node.js 服务模板
- 全栈应用模板

## 🚀 快速开始

### 安装 CLI 工具

\`\`\`bash
# 全局安装
npm install -g @yanyucloud/cli

# 验证安装
yyc --version

# 创建新项目
yyc create app my-project

# 开发模式
cd my-project && npm run dev
EOF

    log_success "README.md 创建完成"
}

main "$@"