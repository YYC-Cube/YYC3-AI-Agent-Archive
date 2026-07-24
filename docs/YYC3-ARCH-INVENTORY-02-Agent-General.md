---
file: YYC3-ARCH-INVENTORY-02-Agent-General.md
description: YYC³ 通用 Agent 架构可视化清单 — 框架、外部 Agent、角色定义
author: YYC³ 智能架构顾问
version: v1.0.0
created: 2026-07-24
status: stable
tags: [架构清单, Agent, 通用]
---

# YYC³ 通用 Agent 架构可视化清单

> **深栈智启新纪元** — 全栈 Agent 框架定义与外部 Agent 资产

---

## 一、Agent 框架全景

```
┌─────────────────────────────────────────────────────────────────────┐
│                    YYC³ Agent 框架生态全景                          │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │                🏠 核心 Agent 框架（YYC3 原生）               │   │
│  ├─────────────────────────────────────────────────────────────┤   │
│  │                                                             │   │
│  │  agents-hub/ai-family/    →  8 位 AI Family 原生角色        │   │
│  │  packages/                →  TypeScript 核心运行时           │   │
│  │    ├── agent-registry/    →  Agent 注册中心                  │   │
│  │    ├── mcp-runtime/       →  MCP 运行时桥接                  │   │
│  │    ├── skill-registry/    →  Skill 注册与执行               │   │
│  │    ├── skills-legacy/     →  遗留 Skill 引擎                 │   │
│  │    └── skills-registry-legacy/ → 遗留注册中心                │   │
│  │                                                             │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │                🏗️ 外部 Agent 框架（待分类合并）              │   │
│  ├─────────────────────────────────────────────────────────────┤   │
│  │                                                             │   │
│  │  agents-hub/cowagent/     →  CowAgent Python 框架           │   │
│  │    ├── agent/             →  Agent 核心引擎                  │   │
│  │    ├── bridge/            →  多平台桥接                      │   │
│  │    ├── channel/           →  渠道适配（飞书/微信/QQ/Web）    │   │
│  │    ├── cli/               →  命令行工具                      │   │
│  │    └── common/            →  公共工具库                      │   │
│  │                                                             │   │
│  │  agents-hub/qwen/         →  通义千问 Model SDK              │   │
│  │                                                             │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │              📋 Agent 角色定义（外部引用）                    │   │
│  ├─────────────────────────────────────────────────────────────┤   │
│  │  总计 ~1243 个 Agent 定义（据 _agents_index.json）           │   │
│  │  来源：claude-code-templates-main 等外部仓库                 │   │
│  │  分类覆盖：development-code, research, business, security    │   │
│  │  ˎˎˎ                                                            │   │
│  │  20 个一级分类，122 个 Team                                    │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

---

## 二、Agent 注册中心 (`packages/agent-registry/`)

| 文件 | 说明 |
|------|------|
| `packages/agent-registry/registry.json` | Agent 注册中心配置 |

---

## 三、Agent 运行时包 (`packages/`)

```
packages/
├── mcp-runtime/
│   ├── src/
│   │   ├── bridge.ts              # MCP 桥接
│   │   ├── cowagent-bridge.ts     # CowAgent 桥接
│   │   ├── runtime.ts             # 运行时核心
│   │   └── types.ts               # 类型定义
│   ├── package.json
│   ├── tsconfig.json
│   └── tsup.config.ts
│
├── skill-registry/
│   ├── src/
│   │   ├── executor.ts            # Skill 执行器
│   │   ├── loader.ts              # Skill 加载器
│   │   ├── registry.ts            # 注册中心
│   │   └── types.ts               # 类型定义
│   └── package.json
│
├── skills-legacy/
│   ├── src/
│   │   ├── builtin.ts             # 内置 Skill
│   │   ├── chain.ts               # 链式调用
│   │   ├── executor.ts            # 执行器
│   │   ├── manager.ts             # 管理器
│   │   └── types.ts               # 类型定义
│   └── package.json
│
└── skills-registry-legacy/
    ├── src/
    │   ├── executor.ts            # 渐进式执行器
    │   ├── registry.ts            # 注册中心
    │   ├── progressive.ts         # 渐进式披露
    │   └── types.ts               # 类型定义
    └── package.json
```

---

## 四、外部 Agent 资产索引（按分类）

_agents_index.json 统计数据：
- 总 Agent 数：**1243**
- 总 Team 数：**122**
- 总分类数：**20**

| 分类 | 数量 | 示例 |
|------|------|------|
| development-code | 大量 | 3d-artist, CSharpExpert |
| research | 中量 | academic-researcher |
| business | 中量 | 商务/销售类 Agent |
| security | 少量 | 安全审计类 Agent |
| other | 大量 | Thinking-Beast-Mode, WinFormsExpert 等 |

> 📌 外部 Agent 资产位于 `claude-code-templates-main` 等仓库，当前通过 `_agents_index.json` 索引管理。

---

## 五、所属文件清单

| 路径 | 类型 | 状态 |
|------|------|------|
| `agents-hub/ai-family/` | YYC3 原生 8 位 Agent | ✅ 核心资产 |
| `agents-hub/cowagent/` | 外部 Python Agent 框架 | 📦 待归类合并 |
| `agents-hub/qwen/` | 外部 Model SDK | 📦 待归类合并 |
| `packages/agent-registry/` | 注册中心包 | ✅ 核心资产 |
| `packages/mcp-runtime/` | MCP 运行时 | ✅ 核心资产 |
| `packages/skill-registry/` | Skill 注册 | ✅ 核心资产 |
| `packages/skills-legacy/` | 遗留引擎 | 🗄️ 遗留资产 |
| `packages/skills-registry-legacy/` | 遗留注册 | 🗄️ 遗留资产 |
| `_agents_index.json` | 全局 Agent 索引 | ✅ 索引文件 |

> ⚠️ **建议**：将 `cowagent/` 和 `qwen/` 移入 `vendors/` 目录，标注来源和版本。
