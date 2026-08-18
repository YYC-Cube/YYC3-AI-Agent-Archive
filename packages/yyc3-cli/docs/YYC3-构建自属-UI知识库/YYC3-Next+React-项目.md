# Next.js + React 多项目并行开发：复用体系·代码优化·工程化 教科书级指导文档

## 文档说明

**适用范围**：所有基于 `Next.js 14+ (App Router)` + `React 18+` 构建的同类型业务项目
**核心目标**：实现**架构/UI/代码/测试**四大维度100%标准化复用，消除重复开发、降低维护成本、提升多项目并行开发效率，打造可规模化复制的项目开发体系
**核心原则**：DRY（不重复造轮子）、单一职责、标准化优先、性能无损、TypeScript强约束

---

## 目录

1. 前置基础：统一项目工程化架构（复用根基）
2. 四大核心复用体系（教科书级详细规划）
   2.1 架构复用（顶层骨架复用）
   2.2 UI复用（视觉交互复用）
   2.3 代码复用（逻辑层复用）
   2.4 测试复用（质量体系复用）
3. 代码整理与规范化（复用前提）
4. 多项目并行开发优化方案
5. 复用体系落地实施步骤
6. 质量保障与监控体系
7. 附录：规范速查表 + 工具链推荐

---

# 1. 前置基础：统一项目工程化架构

**复用的核心前提：所有项目必须使用完全一致的Next.js标准架构**，架构不统一，一切复用均无法落地。
本规范强制采用 **Next.js App Router（官方主推）** + 服务端组件优先架构，兼容React 18并发特性。

## 1.1 强制统一目录结构

```
your-project/
├── .env.local              # 环境变量（git忽略）
├── next.config.js          # Next.js核心配置（复用）
├── tsconfig.json           # TypeScript配置（复用）
├── package.json            # 依赖+脚本（复用基础配置）
├── app/                    # 路由层（Next.js核心）
│   ├── layout.tsx          # 根布局（架构复用）
│   ├── page.tsx            # 首页
│   ├── error.tsx           # 全局错误页（复用）
│   ├── loading.tsx         # 全局加载页（复用）
│   └── [route]/            # 业务路由模块
├── components/             # UI组件层（分层复用）
│   ├── atoms/              # 原子组件
│   ├── molecules/          # 分子组件
│   ├── organisms/          # 有机体组件
│   └── templates/          # 页面模板组件
├── hooks/                  # 自定义Hooks（代码复用核心）
├── lib/                    # 工具函数+常量+配置
├── services/               # 接口请求+Server Actions
├── types/                  # TypeScript全局类型
├── styles/                 # 全局样式
├── public/                 # 静态资源
├── tests/                  # 测试文件（测试复用）
└── .github/                # CI/CD配置（复用）
```

## 1.2 强制统一技术栈

| 模块     | 指定技术方案                              | 选型原因                     |
| -------- | ----------------------------------------- | ---------------------------- |
| 框架     | Next.js 14+ (App Router)                  | 服务端组件、路由原生优化     |
| UI框架   | React 18+                                 | 官方适配，并发特性支持       |
| 样式方案 | TailwindCSS + CSS Modules                 | 原子化样式，零冗余，复用性高 |
| 类型系统 | TypeScript 5+                             | 强约束，避免复用代码bug      |
| 状态管理 | Zustand/Jotai（轻量）                     | 替代Redux，极简无模板代码    |
| 请求方案 | Axios + Next.js Server Actions            | 服务端/客户端请求统一封装    |
| 代码校验 | ESLint + Prettier                         | 强制代码风格统一             |
| 测试方案 | Jest + React Testing Library + Playwright | 单元/E2E测试全覆盖           |

## 1.3 强制统一命名规范

1. **组件/类**：`PascalCase`（`Button.tsx`、`UserLayout.tsx`）
2. **变量/函数/Hook**：`camelCase`（`useRequest`、`formatDate`）
3. **文件/路由**：`kebab-case`（`user-list/page.tsx`、`api/login.ts`）
4. **常量/枚举**：`SCREAMING_SNAKE_CASE`（`API_BASE_URL`、`STATUS_ENUM`）

---

# 2. 四大核心复用体系（教科书级规划）

## 2.1 架构复用（顶层骨架复用）

### 核心定义

将Next.js项目的**工程化配置、全局布局、路由体系、基础服务、错误处理**抽离为可复制的脚手架模板，所有新项目直接基于模板创建，实现**底层架构100%复用**。

### 可复用架构模块拆解

1. **工程化配置复用**
   - 复用文件：`next.config.js`、`tsconfig.json`、`.eslintrc`、`prettier.config.js`
   - 复用内容：编译配置、路径别名、严格模式、打包优化规则
2. **全局布局复用**
   - 根布局 `RootLayout`（SEO元数据、html/body结构、全局Provider）
   - 业务布局：权限布局、登录布局、后台管理布局（嵌套布局复用）
3. **路由与异常体系复用**
   - 统一404/500/加载/重定向页面
   - 统一API路由、Server Actions路径规范
4. **基础服务复用**
   - 环境变量规范、全局日志、埋点、权限校验底层逻辑

### 落地实现方案

1. **Git模板仓库**（推荐）：搭建私有 `nextjs-project-template`仓库，新项目直接 `git clone`
2. **Monorepo架构**（多项目并行）：使用 `TurboRepo`管理多项目，共享架构配置
3. **私有NPM包**：将工程化配置发布为私有包，所有项目依赖安装

### 核心复用代码示例

```tsx
// app/layout.tsx （全局根布局，全项目复用）
import type { Metadata } from 'next';
import { Inter } from 'next/font/google';
import '@/styles/globals.css';

// 复用SEO元数据
export const metadata: Metadata = {
  title: '统一品牌标题',
  description: '统一项目描述',
  icons: '/favicon.ico',
};

const inter = Inter({ subsets: ['latin'] });

// 全局布局骨架，所有项目继承
export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="zh-CN">
      <body className={inter.className} suppressHydrationWarning>
        {/* 全局导航/页脚可直接嵌入，全项目复用 */}
        {children}
      </body>
    </html>
  );
}
```

---

## 2.2 UI复用（视觉交互复用）

### 核心定义

基于**原子设计理论**打造分层UI组件库，所有项目共享组件，实现**视觉统一、交互统一、代码复用**，严格遵循Next.js服务端组件优先原则。

### UI组件分层标准（教科书级）

| 层级       | 定义         | 示例                       | 业务耦合 | 复用范围 |
| ---------- | ------------ | -------------------------- | -------- | -------- |
| 原子组件   | 最小UI单元   | Button、Input、Icon        | 无       | 全项目   |
| 分子组件   | 原子组件组合 | SearchBar、FormItem        | 极低     | 全项目   |
| 有机体组件 | 完整功能模块 | Navbar、TableList          | 低       | 同业务线 |
| 模板组件   | 页面骨架     | ListTemplate、FormTemplate | 中       | 同业务线 |
| 页面组件   | 业务数据填充 | 首页、详情页               | 高       | 单项目   |

### UI复用强制规范

1. **服务端组件优先**：无交互组件默认Server Component，交互组件必须声明 `'use client'`
2. **Props强类型**：所有组件必须定义TS接口，必填项+默认值
3. **样式统一**：使用全局Tailwind主题配置，禁止硬编码颜色/间距
4. **无业务侵入**：通用组件不绑定业务逻辑，仅接收Props渲染

### 落地实现方案

1. **私有UI组件库**：搭建 `@company/ui-components`私有npm包，全项目安装使用
2. **组件文档**：使用Storybook生成组件预览+使用文档
3. **主题复用**：抽离 `tailwind.config.js`主题配置为共享包

### 核心复用代码示例

```tsx
// components/atoms/Button.tsx （原子组件，全项目复用）
'use client'; // 仅交互组件声明客户端
import { ButtonHTMLAttributes } from 'react';

// 强类型约束
type ButtonProps = ButtonHTMLAttributes<HTMLButtonElement> & {
  variant?: 'primary' | 'secondary' | 'danger';
  size?: 'sm' | 'md' | 'lg';
};

// 通用样式复用
const variantClasses = {
  primary: 'bg-blue-600 text-white hover:bg-blue-700',
  secondary: 'bg-gray-200 text-gray-800 hover:bg-gray-300',
  danger: 'bg-red-600 text-white hover:bg-red-700',
};

const sizeClasses = {
  sm: 'px-2 py-1 text-sm',
  md: 'px-4 py-2 text-base',
  lg: 'px-6 py-3 text-lg',
};

// 无业务逻辑，纯UI复用
export default function Button({
  variant = 'primary',
  size = 'md',
  className = '',
  ...props
}: ButtonProps) {
  return (
    <button
      className={`rounded-md font-medium transition-colors ${variantClasses[variant]} ${sizeClasses[size]} ${className}`}
      {...props}
    />
  );
}
```

---

## 2.3 代码复用（逻辑层复用）

### 核心定义

抽离项目中**公共业务逻辑、工具函数、自定义Hooks、请求封装、类型定义**，打造共享逻辑库，实现**零重复代码**，是提升开发效率的核心。

### 代码复用分层拆解

1. **自定义Hooks（最高优先级复用）**
   - 数据请求：`useRequest`、`useInfiniteScroll`
   - 业务逻辑：`useAuth`（权限）、`useForm`（表单）、`useTheme`（主题）
2. **工具函数复用**
   - 日期格式化、数值处理、表单校验、字符串处理、缓存工具
3. **请求层复用**
   - Axios全局封装、请求/响应拦截、通用Server Actions
4. **类型/常量复用**
   - 全局TS类型、接口枚举、路由常量、配置常量

### 代码复用强制规范

1. **单一职责**：一个Hook/函数只实现一个功能
2. **纯函数优先**：无副作用，可测试，易复用
3. **按需引入**：禁止全量导入，优化打包体积
4. **服务端/客户端分离**：Server Actions仅用于服务端，Hooks仅用于客户端

### 落地实现方案

1. **Monorepo共享包**：`packages/shared`，多项目直接引用
2. **私有工具包**：`@company/utils`、`@company/hooks` 发布为npm包

### 核心复用代码示例

```ts
// hooks/useRequest.ts （通用数据请求Hook，全项目复用）
'use client';
import { useState, useEffect } from 'react';

type UseRequestOptions<T> = {
  manual?: boolean; // 是否手动触发
  onSuccess?: (data: T) => void;
};

// 通用请求逻辑，无业务耦合
export function useRequest<T>(
  apiFn: () => Promise<T>,
  options: UseRequestOptions<T> = {}
) {
  const [data, setData] = useState<T | null>(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<Error | null>(null);

  const run = async () => {
    setLoading(true);
    setError(null);
    try {
      const res = await apiFn();
      setData(res);
      options.onSuccess?.(res);
    } catch (err) {
      setError(err as Error);
    } finally {
      setLoading(false);
    }
  };

  // 自动触发请求
  useEffect(() => {
    if (!options.manual) run();
  }, [apiFn, options.manual]);

  return { data, loading, error, run };
}
```

---

## 2.4 测试复用（质量体系复用）

### 核心定义

将**测试配置、测试工具、Mock数据、基础测试用例**抽离为共享测试库，所有项目复用测试体系，降低测试成本，保证复用组件的稳定性。

### 测试复用分层拆解

1. **测试配置复用**：`jest.config.js`、Testing Library全局配置
2. **测试工具复用**：组件渲染封装、Mock请求工具、测试工具函数
3. **用例复用**：通用UI组件/ Hooks的基础测试用例
4. **Mock数据复用**：通用接口Mock、用户信息Mock、路由Mock

### 测试复用强制规范

1. **通用组件测试覆盖率 ≥ 90%**
2. **单元测试优先**：测试纯逻辑，不依赖UI环境
3. **CI/CD自动执行**：复用测试脚本，提交代码自动校验

### 落地实现方案

1. **共享测试包**：`packages/test-utils`，全项目引入
2. **自动化测试**：GitHub Actions复用测试工作流

### 核心复用测试示例

```tsx
// tests/unit/Button.test.tsx （通用组件测试用例，复用）
import { render, screen, fireEvent } from '@testing-library/react';
import Button from '@/components/atoms/Button';

// 复用测试逻辑
describe('Button Component', () => {
  it('renders correctly with default props', () => {
    render(<Button>测试按钮</Button>);
    expect(screen.getByText('测试按钮')).toBeInTheDocument();
  });

  it('triggers onClick event', () => {
    const handleClick = jest.fn();
    render(<Button onClick={handleClick}>点击</Button>);
    fireEvent.click(screen.getByText('点击'));
    expect(handleClick).toHaveBeenCalledTimes(1);
  });
});
```

---

# 3. 代码整理与规范化（复用前提）

无规范的代码无法复用，本章节为**代码整理标准化流程**，所有项目强制执行。

## 3.1 代码风格强制校验

1. 提交前自动格式化：`pre-commit`钩子 + ESLint + Prettier
2. 禁止禁用校验：`/* eslint-disable */` 需要审批
3. 严格TS模式：禁用 `any`、开启 `strict: true`

## 3.2 文件整理规范

1. 一个文件一个导出：单一组件/函数/ Hook
2. 按复用粒度归类：禁止将通用组件写在业务页面中
3. 定期清理冗余：删除未使用的文件、依赖、代码

## 3.3 注释规范

1. **JSDoc注释**：公共组件/函数/ Hook必须编写注释
2. 复杂逻辑必须注释：说明实现思路
3. 禁止无意义注释：精简、准确

## 3.4 Git规范

1. 分支规范：`main`（生产）、`develop`（开发）、`feature/xxx`（功能）
2. 提交规范：`feat: 新增xx组件`、`fix: 修复xxbug`、`refactor: 重构xx代码`
3. PR规范：必须通过代码审查才能合并

---

# 4. 多项目并行开发优化方案

## 4.1 并行开发架构：Monorepo + TurboRepo

1. 多项目共享代码：组件、Hook、工具直接复用，无需复制
2. 增量构建：TurboRepo缓存，构建速度提升80%
3. 任务并行：同时运行多个项目的开发/构建/测试任务

## 4.2 团队任务拆分（并行协作）

1. **架构组**：维护脚手架模板、工程化配置
2. **UI组**：开发通用组件库，全项目复用
3. **逻辑组**：开发共享Hook、工具函数、请求层
4. **业务组**：基于复用模块快速开发业务页面
5. **测试组**：维护共享测试用例，自动化测试

## 4.3 Next.js专属性能优化（复用+性能兼顾）

1. **服务端组件**：减少客户端JS体积，提升加载速度
2. **自动代码分割**：Next.js原生路由分割，按需加载
3. **图片优化**：`next/image`复用，自动压缩/懒加载
4. **数据缓存**：ISR/路由缓存复用，降低服务端压力

---

# 5. 复用体系落地实施步骤（5阶段）

## 阶段1：标准化（1-2周）

统一所有项目的架构、技术栈、命名、目录规范，完成老项目改造

## 阶段2：抽离复用模块（2-3周）

搭建脚手架模板 → 开发UI组件库 → 抽离共享Hook/工具 → 搭建测试库

## 阶段3：集成落地（1-2周）

新项目直接基于模板创建；老项目接入共享组件/代码

## 阶段4：维护迭代（持续）

版本管理复用模块，向下兼容，更新组件文档

## 阶段5：监控优化（持续）

统计复用率、性能监控、修复bug、迭代复用模块

---

# 6. 质量保障与监控体系

1. **版本管理**：语义化版本 `MAJOR.MINOR.PATCH`，不破坏旧项目
2. **自动化测试**：CI/CD触发测试，复用组件无bug才能发布
3. **复用率统计**：统计架构/UI/代码复用率，目标≥80%
4. **性能监控**：Next.js Analytics监控复用组件性能
5. **文档同步**：组件/规范文档实时更新，全员可查

---

# 7. 附录

## 7.1 规范速查表

| 维度 | 核心规范                         |
| ---- | -------------------------------- |
| 架构 | App Router、统一布局、错误页复用 |
| UI   | 原子设计、服务端组件优先         |
| 代码 | Hook复用、纯函数、TS强约束       |
| 测试 | 覆盖率≥90%、Mock复用            |
| 提交 | 规范Commit、ESLint自动校验       |

## 7.2 推荐工具链

1. 项目管理：TurboRepo（Monorepo）
2. 组件文档：Storybook
3. 代码校验：ESLint + Prettier + Husky
4. 测试：Jest + React Testing Library
5. 部署：Vercel（Next.js官方部署）

---

# 总结

本指导文档是 **Next.js + React 多项目开发的标准化教科书**，核心价值：

1. **四大复用**：架构/UI/代码/测试全维度覆盖，彻底消除重复开发
2. **并行高效**：Monorepo+任务拆分，多项目同时开发效率翻倍
3. **质量可控**：强规范+自动化测试，保证复用代码稳定性
4. **规模化复制**：新项目从「周级开发」降至「天级上线」

严格遵循本规范，可实现同框架项目的**低成本、高效率、高质量**规模化开发。
