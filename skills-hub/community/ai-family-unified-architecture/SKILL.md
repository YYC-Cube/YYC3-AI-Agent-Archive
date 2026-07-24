---
name: ai-family-unified-architecture
description: "AI-Family 统一架构实施方案 — 对 Agent/Skills/MCP/Plugins/Tools 五类实体进行统一分类、统一标识、统一调用、合并完善、整理去除、修复除错的完整实施计划（v2.0 整合 YYC3-Skills 体系）"
description_zh: "AI-Family 统一架构实施方案（v2.0 整合 YYC3-Skills 体系）— 对 Agent/Skills/MCP/Plugins/Tools 五类实体进行统一分类、统一标识、统一调用、合并完善、整理去除、修复除错"
description_en: "AI-Family Unified Architecture v2.0 (with YYC3-Skills integration)"
version: 2.0.0
category: development-code
---

# AI-Family 统一架构实施方案 v2.0

## 前言：关键发现

**YYC3-Skills 已经实现了我们规划的目标架构**。该子项目作为一个完整的 Monorepo，已具备：
- **Hub 体系**：skills-hub / mcp-hub / plugins-hub / agents-hub / tools-hub 五类聚合
- **注册中心**：`@yyc3/skill-registry`（TypeScript 包）、`packages/agent-registry/registry.json`、`@yyc3/mcp-runtime`
- **统一分类**：SKILL.md 中已含 `category`、`requires` 字段
- **MCP 全链路**：gateway/client/server 三层架构 + 网关管理服务
- **Monorepo 管理**：pnpm workspace + TypeScript 构建

**两大资产体系的关系**：

```
Skills-archive (主仓库)               YYC3-Skills (目标体系)
┌──────────────────┐              ┌──────────────────────┐
│ skills/          │  映射/合并→  │ skills-hub/         │
│ all-skills/      │  ──────────→ │ skills-hub/marketplace │
│ external_plugins/ │  ──────────→ │ plugins-hub/        │
│ claude-plugins/  │  ──────────→ │ plugins-hub/        │
│ agent/           │  ──────────→ │ agents-hub/roles    │
│ buildwithclaude/ │  ──────────→ │ plugins-hub/        │
└──────────────────┘              └──────────────────────┘
```

**核心策略**：**以 YYC3-Skills 为"接收器"**，将主仓库 Assets 归一化映射/迁移至 YYC3-Skills 体系，最终实现 "One Registry to Rule Them All"。

---

## 一、全貌扫描（主仓库 + YYC3-Skills）

### 1.1 双仓库资产规模

| 实体类型 | Skills-archive | YYC3-Skills | 总合计 |
|---------|:------------:|:----------:|:-----:|
| SKILL.md | **1,947** | **6,689** | **8,636** |
| `.ai-family-plugin` | 397 | 585 | **982** |
| plugin.json | 397 | 717 | **1,114** |
| Agents 定义 | 1,243 | ~50+ | **1,293+** |
| MCP Servers | 210 | ~100+ | **310+** |
| Tools | 261 | 1,476+ (autocomplete) | **1,737+** |
| 仓库大小 | 210 MB | 1.2 GB | **1.4 GB** |
| 总文件数 | ~50K | 81,479 | **~130K** |

### 1.2 YYC3-Skills 体系架构

```
YYC3-Skills (pnpm monorepo — @yyc3/* 命名空间)
├── packages/                        # TypeScript 核心包
│   ├── skill-registry/              # @yyc3/skill-registry — 统一 Skill 注册中心
│   ├── mcp-runtime/                 # @yyc3/mcp-runtime — 统一 MCP 运行时
│   ├── agent-registry/              # Agent 注册表 (AG-xxxx 编码)
│   ├── skills-legacy/              # 旧版技能桥接
│   └── skills-registry-legacy/     # 旧版注册中心桥接
│
├── skills-hub/                     # 🧩 技能中枢 (6,689 SKILL.md)
│   ├── marketplace/                # 119 个 Marketplace 技能 (含 category + requires)
│   ├── ai-ml/                      # NVIDIA + 社区 AI/ML 技能
│   ├── yyc3/                       # YYC3 自有技能体系 (五高架构)
│   ├── glm/                        # GLM/智谱 AI 能力
│   ├── dev-workflow/               # 开发工作流技能
│   ├── b2b/                        # B2B 场景技能
│   ├── community/                  # 社区技能 (nano-pdf/himalaya/imsg等)
│   ├── social-search/              # 社交搜索
│   └── ui-ux/                      # UI/UX 设计
│
├── mcp-hub/                        # 🌐 MCP 中枢
│   ├── server/                     # MCP Server (types/tools/registry/auth)
│   ├── client/                     # MCP Client SDK
│   ├── gateway/                    # MCP 网关 (管理/发现/热加载)
│   ├── mcp-servers/                # MCP Server 配置
│   └── claude-prompts/             # Claude Prompts MCP 集成
│
├── plugins-hub/                    # 🔌 插件中枢
│   ├── official/                   # 官方插件
│   ├── community/                  # 社区插件
│   ├── dev-tools/                  # 开发工具插件
│   ├── pskoett/                    # pskoett 插件集 (含 agents/hooks/skills)
│   ├── review/                     # 审查插件
│   ├── knowledge/                  # 知识插件
│   └── superpowers/               # SuperPowers 系列
│
├── agents-hub/                     # 🤖 代理中枢
│   ├── cowagent/                   # CowAgent 多模态 Agent
│   ├── qwen/                       # Qwen 系列 Agent
│   ├── framework/                  # Agent 框架
│   └── roles/                      # 角色定义 (AGT-xxxx 编码)
│
├── tools-hub/                      # 🔧 工具中枢
│   ├── autocomplete/               # 自动补全 (1,476 个 spec)
│   ├── chat-agent/                 # 聊天 Agent 工具
│   ├── code-ide/                   # IDE 工具
│   ├── conductor/                  # Conductor 编排器
│   └── golang-tools/              # Go 工具
│
├── skills/                         # 🧩 核心技能 (47+ 官方技能)
│   ├── skills/
│   ├── spec/
│   └── template/
│
├── autocomplete-specs/             # 1,476 个 CLI 自动补全定义
├── ClickHouse/                     # ClickHouse 代码库
├── SuperPowers/                    # SuperPowers 插件
└── meta/                           # 元数据 (labels/LICENSES/guidelines)
```

### 1.3 YYC3-Skills 核心优势对比

| 维度 | Skills-archive (旧) | YYC3-Skills (新) |
|------|-------------------|-----------------|
| 组织结构 | 碎片化：6+ 目录 | 聚合化：5 个 Hub |
| 注册中心 | marketplace.json (46 entities) | `@yyc3/skill-registry` + `agent-registry` |
| SKILL.md category | 17% 完整 | 8% 完整 (但结构更好) |
| 依赖声明 | 无 | `requires` 字段 (MCP/工具依赖) |
| MCP 实现 | 分散的 JSON 配置 | gateway/client/server 完整链路 |
| 运行时代码 | Rust 引擎 | TypeScript Monorepo |
| 编码体系 | 无 | AGT-xxxx / 规划中 AYNC |

---

## 二、统一分类体系 (v2.0)

### 2.1 AYNC 编码体系（迁入 YYC3 命名空间）

采用 `AYNC-[type][category][seq]` 格式，以 YYC3-Skills 为主体进行统一编码：

```
AYNC-[type]-[category]-[seq]
  │      │       │
  │      │       └─ 4位序号 (0001-9999)
  │      └───────── 2位分类码 (DE=dev, DP=doc, BS=biz, ...)
  └──────────────── 1位类型码 (A=Agent, Y=Skill, N=MCP, C=Plugin, T=Tool)
```

**编码存量基线**（基于 Phase0 扫描）：

| 实体类型 | 需编码数量 | 已编码 (YYC3自有) |
|---------|:---------:|:----------------:|
| Skills | 8,636 | 0 (需从 AGT-xxx 迁移) |
| Agents | 1,293 | ~50 (AGT-xxxx 格式) |
| MCP | 310+ | ~30 |
| Plugins | 1,114+ | ~100 |
| Tools | 1,737+ | 0 |

### 2.2 命名空间合并策略

```
旧命名体系 → 新 AYNC 体系
AGT-backend-architect → AYNC-A-DE-0042 (Agent, development-code, #42)
AGT-code-reviewer    → AYNC-A-DE-0043

旧 Directory 名 → 新 Hub 目录
skills/github      → skills-hub/dev-workflow/github/
all-skills/github-automation → skills-hub/marketplace/github-automation/
external_plugins/asana → plugins-hub/official/asana/
claude-plugins/conductor → tools-hub/conductor/
```

### 2.3 统一分类科目表 (Standard Categories)

| 分类码 | 分类名 | 说明 | 适用于 |
|--------|--------|------|--------|
| DE | development-code | 开发编码 | All |
| DP | document-processing | 文档处理 | All |
| BS | business-productivity | 商业生产力 | All |
| EM | email | 邮件 | Skill/Plugin |
| DS | design | 设计 | Skill/Plugin |
| DP2 | deployment | 部署 | Skill/Plugin |
| RE | research | 研究 | Skill/Agent |
| CT | content | 内容创作 | Skill |
| CM | communication | 通信通信 | Skill/Plugin |
| DB | database | 数据库 | Skill/MCP |
| AI | ai-ml | AI/ML | All |
| SE | security | 安全 | Skill/Agent |
| TE | testing | 测试 | Skill/Agent |
| AU | automation | 自动化 | Skill/Plugin |
| DC | devops | DevOps | Skill/Agent |
| CI | cloud-infrastructure | 云基础设施 | Skill/MCP |
| MK | marketing | 营销 | Skill |
| DA | data-analysis | 数据分析 | Skill/Agent |
| FW | framework | 框架 | Plugin/Package |
| GT | gateway | 网关 | MCP |
| RT | runtime | 运行时 | MCP/Package |
| OR | orchestration | 编排编排 | Agent/Tool |
| OT | other | 其他 | All |

---

## 三、统一目录迁移计划

### 3.1 映射表

| 源路径 (Skills-archive) | 目标路径 (YYC3-Skills) | 迁移方式 | 数量 |
|------------------------|----------------------|---------|:---:|
| `skills/*` (286个) | `YYC3-Skills/skills-hub/community/` | 映射 + 去除重复 | 169 个新 |
| `all-skills/skills/*` (99个) | `YYC3-Skills/skills-hub/marketplace/` | 合并 (117个已存在) | 0 个新 |
| `external_plugins/*` (160个) | `YYC3-Skills/plugins-hub/official/` | 迁移 | 160 |
| `claude-plugins/*` (105个) | `YYC3-Skills/plugins-hub/official/` | 迁移 | 105 |
| `buildwithclaude/plugins/*` (138个) | `YYC3-Skills/plugins-hub/community/` | 迁移 | 138 |
| `claude-code-templates/agents/*` | `YYC3-Skills/agents-hub/roles/` | 迁移 | 27 个团队 |
| `buildwithclaude/mcp-servers.json` | `YYC3-Skills/mcp-hub/mcp-servers/` | 拆分 | 199 个 |
| `agent-browser/skills/*` | `YYC3-Skills/skills/` | 迁移 | 5 |

### 3.2 重复消除策略

**117 个技能同时在 Skills-archive/skills 和 YYC3-Skills/marketplace 存在**：

1. **以 YYC3-Skills 版本为主**：YYC3-Skills 的 SKILL.md 结构更规范（含 `requires`、`category`）
2. **反向合并字段**：将 Skills-archive 中的 `description_zh`、`version` 补充到 YYC3-Skills 版本
3. **删除旧版本**：全部在 Skills-archive 中删除

### 3.3 独有的高价值资产（需保留并迁移）

| 资产 | 所在位置 | 迁移到 |
|------|---------|--------|
| Rust Agent 引擎 | `agent/` | `YYC3-Skills/agents-hub/framework/yyc3-engine/` |
| 中英文双语 SKILL.md | `skills/*` | 反向补充到 marketplace |
| agent-browser 技能 | `agent-browser/skills/` | `YYC3-Skills/skills/` |
| claude-mem-main | `claude-mem-main/` | `YYC3-Skills/packages/memory-engine/` |
| ai-agent UI | `ai-agent/` | `YYC3-Skills/packages/agent-ui/` |

---

## 四、统一元数据标准 (v2.0 with YYC3 enhancements)

### 4.1 SKILL.md 完整元数据

```yaml
---
name: skill-name
version: 1.0.0
aync_id: AYNC-Y-DE-0001
category: development-code

# 多语言描述
description: "English description"
description_zh: 中文描述
description_en: English description

# 依赖声明 (YYC3扩展)
requires:
  mcp: [mcp-server-name]     # 需要哪些 MCP Server
  tools: [tool-name]         # 需要哪些 Tools
  skills: [skill-name]       # 需要哪些 Sub-Skills
  
# 平台兼容性
platforms: [node, python, docker]
runtime: node|python|docker

# 作者信息 (YYC3扩展)
author:
  name: Author Name
  email: author@example.com
provider: yyc3|community|official

# 标签
tags: [tag1, tag2]
---
```

### 4.2 plugin.json 增强标准

```json
{
  "name": "plugin-name",
  "description": "Plugin description",
  "version": "1.0.0",
  "aync_id": "AYNC-C-DE-0042",
  "category": "development-code",
  "author": {
    "name": "Author",
    "email": "author@example.com"
  },
  "type": "official|community|pskoett",
  "dependencies": {
    "skills": ["skill-a"],
    "mcps": ["mcp-server-x"]
  },
  "compatibility": {
    "min_engine_version": "1.0.0",
    "platforms": ["macos", "linux"],
    "node": ">=20.0.0"
  },
  "hooks": ["hook-name"],
  "commands": ["command-name"],
  "agents": ["agent-name"]
}
```

---

## 五、实施路线 (7 阶段)

### Phase 0 ✅ 已完成

| 任务 | 产出 | 状态 |
|------|------|------|
| 主仓库全量扫描 | `_categories.json`, `_agents_index.json` | ✅ |
| MCP 扫描 | `_mcps_index.json` | ✅ |
| Tools 扫描 | `_tools_index.json` | ✅ |
| AYNC 基线 | `aync_registry.json` (3,662 entities) | ✅ |
| YYC3-Skills 深度扫描 | 本文件 | ✅ |

### Phase 1 🚧 主仓库 → YYC3-Skills 映射就绪

| 任务 | 步骤 |
|------|------|
| 1.1 去重扫描 | 确认 117 个 marketpl marketplace 重复技能的差异字段 |
| 1.2 反向字段补充 | 将 description_zh/version 从 skills/ 映射到 marketplace |
| 1.3 外部引用更新 | 更新所有 market marketplace.json 指向新位置 |
| 1.4 物理迁移 | `external_plugins` → `plugins-hub/official/` |

### Phase 2 元数据标准化 (全量 8,636 SKILL.md)

| 任务 | 规模 | 工具 |
|------|:----:|------|
| 2.1 category 补全 | 8,096 个 (94%) | `metadata_check.py` 批量修复 |
| 2.2 version 补全 | 6,500+ | 默认 v1.0.0 |
| 2.3 `requires` 字段生成 | 基于内容分析 | 新脚本 |
| 2.4 description_zh 补全 | 7,000+ | LLM 批量翻译 |
| 2.5 AYNC ID 嵌入 | 8,636 | `assign_aync_ids.py` |

### Phase 3 注册中心打通

**以 `@yyc3/skill-registry` 为核心枢纽**：

```
@yyc3/skill-registry (TypeScript)
    │
    ├── registry.json (8,636 个技能的注册表)
    ├── loader.ts      (加载文件系统)
    ├── executor.ts    (执行引擎，含降级熔断)
    └── types.ts       (类型定义)
    
    ┌── 读取 ──► YYC3-Skills/skills-hub/  ←── (主数据源)
    │               (8,636 SKILL.md)
    │
    ├── 读取 ──► YYC3-Skills/plugins-hub/  ←── (1,114 plugin.json)
    │
    ├── 读取 ──► YYC3-Skills/agents-hub/   ←── (1,293 Agents)
    │
    ├── 读取 ──► YYC3-Skills/tools-hub/    ←── (1,737 Tools)
    │
    └── 读取 ──► YYC3-Skills/mcp-hub/      ←── (310 MCPs)
```

### Phase 4 MCP 网关集成

`@yyc3/mcp-runtime` 作为 MCP 统一入口：

```
@yyc3/mcp-runtime
    │
    ├── MCP Gateway (管理/发现/热加载/健康检查)
    ├── MCP Client  (与各 MCP Server 通信)
    ├── MCP Server  (注册/鉴权/限流)
    │
    └── 桥接 ──► YYC3-Skills/mcp-hub/ (210+ MCP 配置)
```

### Phase 5 AYNC 全量编码

在 `aync_registry.json` 基础上，为所有实体分配 AYNC 编码并嵌入元数据：

```bash
python3 assign_aync_ids.py --source aync_registry.json --output YYC3-Skills/
# 产出:
#   YYC3-Skills/aync_registry.json (全量 10,000+)
#   各 skills-hub/*/SKILL.md 中嵌入 aync_id
#   各 plugins-hub/*/plugin.json 中嵌入 aync_id
```

### Phase 6 统一调用入口

以 `@yyc3/skill-registry` + `@yyc3/mcp-runtime` 为基础，构建统一调用层：

```typescript
// 统一调用示例
import { globalSkillRegistry } from '@yyc3/skill-registry';
import { MCPService } from '@yyc3/mcp-runtime';
import { AgentRegistry } from '@yyc3/agent-registry';

// 1. 根据 AYNC ID 查找任何实体
const entity = globalRegistry.resolve('AYNC-Y-DE-0001');

// 2. 根据类型和名称查找
const skill = globalSkillRegistry.findByName('github-automation');

// 3. 根据分类查找
const allDesign = globalSkillRegistry.search({ category: 'design' });

// 4. 执行
const result = await skillExecutor.execute(skill, { action: 'review-code' });
```

### Phase 7 工具链整合 (autocomplete-specs)

YYC3-Skills 中 1,476 个 autocomplete specs 应整合到工具调用链：

```
工具调用请求
    │
    ├── Tools 实现 (agent/tools/ + chatAgentTools/)
    ├── CLI 自动补全 (autocomplete-specs 1,476个)
    └── MCP Server 暴露的工具
```

---

## 六、现有脚本适配

| 脚本 | 主仓库 | YYC3-Skills | 适配方式 |
|------|-------|------------|---------|
| `metadata_check.py` | ✅ 可用 | 🔧 需适配 | 增加 `requires` 字段校验 |
| `generate_categories.py` | ✅ 可用 | 🔧 需适配 | 增加 `skills-hub/marketplace` 等路径 |
| `dedup_check.sh` | ✅ 可用 | 🔧 需适配 | 增加 YYC3-Skills 目录检查 |
| `agent_indexer.py` | ✅ 可用 | ✅ 可扩展 | 覆盖 agents-hub/ |
| `mcp_indexer.py` | ✅ 可用 | ✅ 可扩展 | 覆盖 mcp-hub/ |
| `tool_indexer.py` | ✅ 可用 | ✅ 可扩展 | 覆盖 tools-hub/ |
| `generate_aync_registry.py` | ✅ 可用 | ✅ 可扩展 | 新增 YYC3-Skills 路径 |

---

## 七、执行看板

### 阶段依赖关系

```
Phase 0 (基线) ──→ Phase 1 (映射) ──→ Phase 2 (标准化) ──→ Phase 3 (注册中心)
                                                                  │
                                                                  ▼
                                           Phase 4 (MCP) ◄── Phase 3 (注册中心)
                                                                  │
                                                                  ▼
                                           Phase 5 (AYNC) ←── Phase 3 + 4
                                                                  │
                                                                  ▼
                                           Phase 6 (调用入口) ←── Phase 5
                                                                  │
                                                                  ▼
                                           Phase 7 (工具链) ←── Phase 6
```

### 优先级矩阵

| 优先级 | 任务 | 价值 | 工作量 | 前置依赖 |
|--------|------|:----:|:-----:|---------|
| **P0** | Phase0 完成 ✅ | 高 | 2天 | 无 |
| **P1** | Phase1: 117个重复技能去重 | 高 | 1天 | P0 |
| **P1** | Phase2: category/version 补全 | 高 | 3天 | P0 |
| **P2** | Phase3: @yyc3/skill-registry 增强 | 高 | 5天 | P1+P2 |
| **P2** | Phase4: MCP 网关集成 | 高 | 5天 | P1 |
| **P3** | Phase5: AYNC 全量编码 | 中 | 3天 | P3 |
| **P3** | Phase6: 统一调用入口 | 中 | 5天 | P5 |
| **P4** | Phase7: 工具链整合 | 低 | 3天 | P6 |

### 当前状态

```
Phase 0 ████████████████████████████████░░░░░░░░ 80% (基线完成)
Phase 1 ██░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░  5% (待启动)
Phase 2 ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░  0%
Phase 3 ████████░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ 15% (@yyc3/skill-registry 已存在)
Phase 4 ████████░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ 15% (@yyc3/mcp-runtime 已存在)
Phase 5 ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░  0%
Phase 6 ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░  0%
Phase 7 ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░  0%
```

---

## 八、脚本与命令速查

```bash
# 主仓库基线
cd /Users/yanyu/Downloads/YYC3-Claude-Code/Skills-archive
python3 metadata_check.py                # 元数据校验
python3 generate_categories.py           # 分类索引
bash dedup_check.sh                      # 去重检查
python3 agent_indexer.py                 # Agent 扫描
python3 mcp_indexer.py                   # MCP 扫描
python3 tool_indexer.py                  # Tool 扫描
python3 generate_aync_registry.py        # AYNC 基线

# YYC3-Skills 适配扫描
python3 -c "
import json, pathlib
# 加载两个仓库的资产清单
# 比对重复
# 生成迁移计划
"

# 未来: 统一调用
# npm install @yyc3/skill-registry @yyc3/mcp-runtime
```

---

## 附录：YYC3-Skills 与主仓库重复技能列表

已完成 117 个 Marketplace 技能的重复识别，详细清单见：
- [YYC3-Skills/skills-hub/marketplace/](file:///Users/yanyu/Downloads/YYC3-Claude-Code/Skills-archive/YYC3-Skills/skills-hub/marketplace/) (119 个)
- 与 [Skills-archive/skills/](file:///Users/yanyu/Downloads/YYC3-Claude-Code/Skills-archive/skills/) 比较：117 个重叠（98%）

**这 117 个技能应以 YYC3-Skills 版本为主版本**，反向吸收主仓库的 `description_zh` 和 `version` 字段。
