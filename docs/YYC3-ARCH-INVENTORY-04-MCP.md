---
file: YYC3-ARCH-INVENTORY-04-MCP.md
description: YYC³ MCP 架构可视化清单 — MCP Server 分类与配置管理
author: YYC³ 智能架构顾问
version: v1.0.0
created: 2026-07-24
status: stable
tags: [架构清单, MCP, 协议层]
---

# YYC³ MCP 架构可视化清单

> **MCP 标准协议层** — 能力解耦 · 标准连接 · 第六层核心

---

## 一、MCP 在九层架构中的位置

```
┌─────────────────────────────────────────────────────────────┐
│  第九层 · 治理与演进层                                       │
│  第八层 · 用户交互层                                         │
│  第七层 · AI Family 智能体层                                  │
│  ═══════════════════════════════════════════════════════════ │
│  第六层 · MCP 标准协议层 ◄━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  MCP Client │ MCP Server │ Transport  │ Protocol    │   │
│  │  (Agent端)  │ (Skill端)  │ (SSE/WS)   │ (JSON-RPC)  │   │
│  └─────────────────────────────────────────────────────┘   │
│  ═══════════════════════════════════════════════════════════ │
│  第五层 · Skill 原子能力层                                   │
│  第四层 · AI 引擎底座层                                      │
│  第三层 · 核心服务层                                         │
│  第二层 · 数据存储层                                         │
│  第一层 · 基础设施层                                         │
└─────────────────────────────────────────────────────────────┘
```

---

## 二、MCP Server 全景分类（据 `_mcps_index.json`）

总 Server 数：**210**
配置来源：**14 个配置文件**
部署方式：**Docker 199 / Node 1 / Other 10**

```
┌─────────────────────────────────────────────────────────────────────┐
│                    MCP Server 按类别分布                            │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  ☁️ 云基础设施 (Cloud Infrastructure)          ~25 个                │
│  ├── aks                  Azure Kubernetes Service                   │
│  ├── aws-*               AWS 系列服务                               │
│  ├── gcp-*               GCP 系列服务                               │
│  ├── cloudflare          Cloudflare                                  │
│  ├── supabase            Supabase                                    │
│  ├── firebase            Firebase                                    │
│  └── ...                                                             │
│                                                                     │
│  🗄️ 数据库 (Database)                              ~20 个            │
│  ├── astra-db            DataStax Astra DB                           │
│  ├── airtable-mcp-server Airtable                                    │
│  ├── postgres            PostgreSQL                                  │
│  ├── redis               Redis                                       │
│  ├── qdrant              Qdrant 向量数据库                           │
│  ├── elasticsearch       Elasticsearch                               │
│  └── ...                                                             │
│                                                                     │
│  🛠️ 开发工具 (Developer Tools)                    ~30 个              │
│  ├── github              GitHub                                      │
│  ├── gitlab              GitLab                                      │
│  ├── linear              Linear                                      │
│  ├── jira                Jira                                        │
│  ├── playwright          Playwright                                  │
│  ├── ast-grep            AST 代码搜索                                │
│  └── ...                                                             │
│                                                                     │
│  🤖 AI 与 ML (AI/ML)                              ~20 个              │
│  ├── arxiv-mcp-server    arXiv 论文搜索                              │
│  ├── perplexity          Perplexity AI                               │
│  ├── apify-mcp-server    Apify 网页抓取                              │
│  ├── browser-use         浏览器自动化                                │
│  └── ...                                                             │
│                                                                     │
│  💬 通讯协同 (Communication)                       ~15 个             │
│  ├── discord             Discord                                     │
│  ├── slack               Slack                                       │
│  ├── telegram            Telegram                                    │
│  ├── asana               Asana                                       │
│  ├── atlassian           Confluence + Jira                           │
│  └── ...                                                             │
│                                                                     │
│  🔧 工具与实用 (Utilities)                         ~40 个             │
│  ├── 3d-printer          3D 打印机                                   │
│  ├── api-gateway         API 网关                                    │
│  ├── api-mcp-server      Hostinger API                               │
│  ├── audiense-insights   受众洞察                                    │
│  ├── atlas-docs          文档索引                                    │
│  └── ...                                                             │
│                                                                     │
│  🌐 浏览器与自动化 (Browser Automation)             ~15 个            │
│  ├── apify-mcp-server    网页抓取                                    │
│  ├── playwright          浏览器自动化                                 │
│  ├── browser-use         浏览器使用                                   │
│  ├── serp                SERP 搜索                                   │
│  └── ...                                                             │
│                                                                     │
│  🔐 安全 (Security)                               ~10 个              │
│  ├── security-guidance   安全指导                                    │
│  └── ...                                                             │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

---

## 三、MCP 配置文件分布

### 3.1 主要配置源

| 配置文件 | Server 数 | 部署类型 |
|----------|-----------|----------|
| `buildwithclaude/mcp-servers.json` | 199 | 多类型 |
| 其他 13 个配置 | 11 | Mixed |

### 3.2 本地 .mcp.json 文件分布

```
┌─────────────────────────────────────────────────────────────────────┐
│                    .mcp.json 文件分布                                │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  plugins-hub/official/                                              │
│  ├── asana/.mcp.json                                                │
│  ├── context7/.mcp.json                                             │
│  ├── discord/.mcp.json                                              │
│  ├── fakechat/.mcp.json                                             │
│  ├── firebase/.mcp.json                                             │
│  ├── github/.mcp.json                                               │
│  ├── gitlab/.mcp.json                                               │
│  ├── greptile/.mcp.json                                             │
│  ├── laravel-boost/.mcp.json                                        │
│  ├── linear/.mcp.json                                               │
│  ├── playwright/.mcp.json                                           │
│  ├── repomix-mcp/.mcp.json                                          │
│  ├── serena/.mcp.json                                               │
│  ├── slack/.mcp.json                                                │
│  ├── supabase/.mcp.json                                             │
│  ├── telegram/.mcp.json                                             │
│  ├── example-plugin/.mcp.json                                       │
│  └── claude-plugins/external_plugins/ (18个重复)                    │
│                                                                     │
│  tools-hub/code-ide/                                                 │
│  ├── plugins/marketplaces/codebuddy-plugins-official/               │
│  ├── plugins/marketplaces/cb_teams_marketplace/                     │
│  └── ...                                                             │
│                                                                     │
│  skills/skills/                                                      │
│  ├── godot-mcp/.mcp.json                                            │
│  └── github/.mcp.json                                               │
│                                                                     │
│  agents-hub/roles/                                                   │
│  └── claude-code-agents/plugins/runapi-mcp/.mcp.json                │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

### 3.3 ⚠️ 重复的 MCP 配置

`plugins-hub/official/claude-plugins/external_plugins/` 下与 `plugins-hub/official/` 根目录存在 18+ 组重复 MCP 配置：

| 重复项 | plugins-hub/official/ | plugins-hub/official/claude-plugins/external_plugins/ |
|--------|----------------------|------------------------------------------------------|
| asana | ✅ | ✅ |
| context7 | ✅ | ✅ |
| discord | ✅ | ✅ |
| fakechat | ✅ | ✅ |
| firebase | ✅ | ✅ |
| github | ✅ | ✅ |
| gitlab | ✅ | ✅ |
| greptile | ✅ | ✅ |
| laravel-boost | ✅ | ✅ |
| linear | ✅ | ✅ |
| playwright | ✅ | ✅ |
| serena | ✅ | ✅ |
| slack | ✅ | ✅ |
| supabase | ✅ | ✅ |
| telegram | ✅ | ✅ |
| repomix-mcp | ✅ | ✅ |

> ⚠️ **建议**：保留 `plugins-hub/official/` 根目录为唯一权威源，删除 `claude-plugins/external_plugins/` 下副本。

---

## 四、MCP 在 YYC3 中的角色定位

```
┌───────────────────┐     ┌───────────────────┐     ┌───────────────────┐
│   AI Family       │ ──▶ │   MCP 标准协议层   │ ──▶ │   Skill 能力池    │
│   Agent 层        │     │   (Layer 6)        │     │   (Layer 5)       │
│                   │     │                   │     │                   │
│   元启·天枢       │     │   JSON-RPC        │     │   社区 Skills     │
│   言启·千行       │     │   SSE/WebSocket   │     │   市场 Skills     │
│   语枢·万物       │     │   服务发现        │     │   NVIDIA Skills   │
│   预见·先知       │     │   权限校验        │     │   B2B Skills      │
│   千里·伯乐       │     │   负载均衡        │     │                   │
│   智云·守护       │     │                   │     │                   │
│   格物·宗师       │     │                   │     │                   │
│   创想·灵韵       │     │                   │     │                   │
└───────────────────┘     └───────────────────┘     └───────────────────┘
```

---

## 五、所属文件清单

| 文件 | 说明 | 状态 |
|------|------|------|
| `_mcps_index.json` | 全局 MCP Server 索引（210 个） | ✅ 索引 |
| `tools-hub/code-ide/mcp.json` | IDE MCP 配置 | ✅ 本地 |
| `tools-hub/conductor/` | Conductor 规则与技能 | 📦 外部 |
| `plugins-hub/official/*/.mcp.json` | 官方插件 MCP 配置 | ✅ 本地 |
| `plugins-hub/official/claude-plugins/external_plugins/*/.mcp.json` | Claude 官方插件（重复） | ⚠️ 待去重 |
| `skills/skills/*/.mcp.json` | Skill MCP 配置 | ✅ 本地 |
