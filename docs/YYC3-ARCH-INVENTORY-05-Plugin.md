---
file: YYC3-ARCH-INVENTORY-05-Plugin.md
description: YYC³ Plugin 架构可视化清单 — 官方/社区/开发工具全分类
author: YYC³ 智能架构顾问
version: v1.0.0
created: 2026-07-24
status: stable
tags: [架构清单, Plugin, 插件]
---

# YYC³ Plugin 架构可视化清单

> **能力扩展 · 即插即用 · 生态共建**

---

## 一、Plugin 总体架构

```
┌─────────────────────────────────────────────────────────────────────┐
│                    YYC³ Plugin 三层体系                             │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │              🏢 官方插件池 plugins-hub/official/             │   │
│  │              ~80+ 个官方插件 + Claude 扩展                   │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │              🏘️ 社区插件池 plugins-hub/community/           │   │
│  │              ~10+ 个社区贡献插件                             │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │              🛠️ 开发工具插件池 plugins-hub/dev-tools/       │   │
│  │              plugin-dev + plugin-finder                     │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

---

## 二、官方插件详细分类（`plugins-hub/official/`）

### 2.1 LSP 语言服务插件

```
┌─────────────────────────────────────────────────────────────────────┐
│  LSP (Language Server Protocol) 插件                                │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  clangd-lsp/        C/C++ 语言服务器                               │
│  csharp-lsp/        C# 语言服务器                                  │
│  gopls-lsp/         Go 语言服务器                                  │
│  jdtls-lsp/         Java 语言服务器 (JDT)                          │
│  kotlin-lsp/        Kotlin 语言服务器                               │
│  lua-lsp/           Lua 语言服务器                                  │
│  php-lsp/           PHP 语言服务器                                  │
│  pyright-lsp/       Python 语言服务器 (Pyright)                     │
│  ruby-lsp/          Ruby 语言服务器                                 │
│  rust-analyzer-lsp/ Rust 语言服务器                                 │
│  swift-lsp/         Swift 语言服务器                                │
│                                                                     │
│  总计：11 个 LSP 插件                                               │
└─────────────────────────────────────────────────────────────────────┘
```

### 2.2 MCP 服务插件（含 .mcp.json）

```
┌─────────────────────────────────────────────────────────────────────┐
│  MCP 服务插件                                                       │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  asana/.mcp.json          Asana 项目管理                            │
│  context7/.mcp.json       Context7 上下文                           │
│  discord/.mcp.json        Discord 通讯（含 bun 实现）               │
│  fakechat/.mcp.json       模拟聊天                                  │
│  firebase/.mcp.json       Firebase 后端                             │
│  github/.mcp.json         GitHub API                                │
│  gitlab/.mcp.json         GitLab API                                │
│  greptile/.mcp.json       Greptile 代码分析                         │
│  laravel-boost/.mcp.json  Laravel 增强                              │
│  linear/.mcp.json         Linear 项目管理                           │
│  playwright/.mcp.json     Playwright 浏览器自动化                   │
│  repomix-mcp/.mcp.json    Repomix 代码仓库打包                      │
│  serena/.mcp.json         Serena 助手                               │
│  slack/.mcp.json          Slack 通讯                                │
│  supabase/.mcp.json       Supabase 后端                             │
│  telegram/.mcp.json       Telegram 通讯（含 bun 实现）              │
│  example-plugin/.mcp.json 示例插件模板                              │
│                                                                     │
│  总计：17 个 MCP 服务插件                                           │
└─────────────────────────────────────────────────────────────────────┘
```

### 2.3 功能增强插件

```
┌─────────────────────────────────────────────────────────────────────┐
│  功能增强类插件                                                     │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  agent-sdk-dev/           Agent SDK 开发                            │
│  agent-teams/             Agent 团队管理                            │
│  all-agents/              Agent 集合（含 debugger）                 │
│  all-commands/            CLI 命令集合（act/check/docs 等）        │
│  claude-code-setup/       Claude Code 环境配置                     │
│  claude-hud/              Claude HUD 界面                           │
│  claude-md-management/    Markdown 管理                             │
│  claude-plugins/          Claude 插件集合（含外部引用）             │
│  code-review/             代码审核                                  │
│  code-simplifier/         代码简化                                  │
│  commit-commands/         提交命令增强                              │
│  conductor/               Conductor 编排（含管理命令）              │
│  feature-dev/             功能开发                                  │
│  frontend-design/         前端设计                                  │
│  frontend-design-pro/     前端设计进阶                              │
│  hookify/                 Hook 编排系统（Python）                   │
│  learning-output-style/   学习输出风格                              │
│  math-olympiad/           数学奥赛                                  │
│  mcp-server-dev/          MCP Server 开发                          │
│  meigen-ai-design/        名言 AI 设计                              │
│  nextjs-expert/           Next.js 专家                             │
│  payload/                 Payload CMS                               │
│  playground/              游乐场                                    │
│  plugin-dev/              插件开发                                  │
│  pr-review-toolkit/       PR 审核工具集                            │
│  ralph-loop/              Ralph Loop 行为循环                       │
│  security-guidance/       安全指导                                  │
│  skill-creator/           Skill 创建器                               │
│  scientific-skills/       科学技能                                  │
│  superpowers/             SuperPowers 增强                          │
│  superpowers-chrome/      SuperPowers Chrome 扩展                  │
│  taskmaster/              Taskmaster 任务管理                       │
│  dotnet-contribution/     .NET 贡献                                 │
│  llm-application-dev/     LLM 应用开发                              │
│  ui-design/               UI 设计                                   │
│                                                                     │
│  总计：~35 个功能增强插件                                           │
└─────────────────────────────────────────────────────────────────────┘
```

---

## 三、社区插件（`plugins-hub/community/`）

| 插件 | 说明 |
|------|------|
| agent-teams | Agent 团队管理 |
| conductor | 编排引擎 |
| dotnet-contribution | .NET 贡献指南 |
| llm-application-dev | LLM 应用开发 |
| meigen-ai-design | 名言 AI 设计 |
| ui-design | UI 设计 |

---

## 四、开发工具插件（`plugins-hub/dev-tools/`）

| 插件 | 文件 | 说明 |
|------|------|------|
| plugin-dev | `README.md`, `README_zh.md` | 插件开发指南（中英双语） |
| plugin-finder | `CHANGELOG.md`, `DEVELOPMENT.md`, `README.md`, `TESTING.md`, `USAGE_GUIDE.md` | 插件查找器（含完整开发测试文档） |

---

## 五、⚠️ 重复项分析

### Claude Plugins 嵌套重复

```
plugins-hub/official/
├── asana/.mcp.json              ← 权威源
├── discord/.mcp.json
├── github/.mcp.json
├── ... (共 17 个)
│
└── claude-plugins/
    └── external_plugins/
        ├── asana/.mcp.json      ← 🔴 与官方根目录重复
        ├── discord/.mcp.json    ← 🔴 重复
        ├── github/.mcp.json     ← 🔴 重复
        └── ... (共 18 个)
```

### External Project 未归类

```
plugins-hub/official/
├── superpowers/              ← 与 YYC3-Skills 根目录 SuperPowers/ 重复
└── ralph-loop/               ← 外部项目
```

> ⚠️ **建议**：
> 1. 保留 `plugins-hub/official/` 根目录为唯一插件配置源
> 2. 删除 `claude-plugins/external_plugins/` 下重复项
> 3. 将 `SuperPowers/` 统一移至 `plugins-hub/` 体系

---

## 六、Plugin 与 MCP 的关系

```
┌─────────────────────────────────────────────────────────────────────┐
│                    Plugin ↔ MCP 映射关系                            │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  Plugin（打包单元）                   MCP Server（运行时）           │
│  ┌────────────────────┐             ┌────────────────────┐         │
│  │  Plugin 清单        │  ────────▶  │  MCP Server 配置   │         │
│  │  ├── README.md     │             │  ├── .mcp.json     │         │
│  │  ├── LICENSE       │             │  │  "command":     │         │
│  │  ├── SKILL.md      │             │  │  "args": [...]  │         │
│  │  └── .mcp.json     │             │  │  "env": {...}   │         │
│  └────────────────────┘             └────────────────────┘         │
│                                                                     │
│  有 .mcp.json 的 Plugin → 可部署为 MCP Server                      │
│  无 .mcp.json 的 Plugin → 仅能力描述/开发指南                      │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```
