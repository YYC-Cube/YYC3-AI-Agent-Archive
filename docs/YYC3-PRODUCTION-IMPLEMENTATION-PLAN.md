---
file: YYC3-PRODUCTION-IMPLEMENTATION-PLAN.md
description: YYC³ 投产实施方案与建议 — 基于当前资产全景与存量项目的全局优化建议
author: YYC³ 智能架构顾问
version: v1.0.0
created: 2026-07-24
status: stable
tags: [投产, 实施方案, CLI, i18n, 闭环, 资产全景]
---

# YYC³ 投产实施方案与建议

> **万象归元于云枢 | 深栈智启新纪元**
> 基于存量资产全景审查 + YYC3-CLI(v2.0.0) + YYC3-i18n-Core(v2.4.0) 自有项目深度分析

> **⚠️ 状态更正（2026-08-18）**：本方案中所有「符号链接引入外部仓库」的做法（packages/yyc3-cli、
> packages/yyc3-i18n → /Users/yanyu/YYC-Cube/...）已**废弃并落地为内联复制**——两个包的实际代码
> 已复制进本仓库 packages/ 目录，符号链接已删除，克隆即可用。文中相关段落仅作历史方案保留，
> 实施状态以 `docs/YYC3-技术栈分析-现状评估-建议计划.md` 第七章实施记录为准。

---

## 一、存量资产全景确认

### 1.1 外部目录迁移确认清单

| # | 外部目录 | 目标位置 | 迁移状态 | 验证 |
|---|----------|----------|:--------:|:----:|
| 1 | `claude-prompts-mcp/` | `mcp-hub/claude-prompts/` | ✅ 已合并+清理 | `mcp-hub/claude-prompts/READMD.md` |
| 2 | `claude-code-templates-main/` | `plugins-hub/official/claude-code-hooks/` | ✅ 55 hooks | `hooks/` 10 子目录 |
| | | `plugins-hub/official/claude-code-mcps/` | ✅ 54 MCP | `mcps/` 10 子目录 |
| 3 | `buildwithclaude/` | `plugins-hub/official/buildwithclaude-*/` | ✅ 8 组 | gsd/ciagent/cashflow/budgetclaw/claude-ops/cc-best/drill-me/all-skills |
| 4 | `agent-browser/` | `tools-hub/browser-agent/` | ✅ Rust CLI | Cargo.toml + src 源码 + bin |
| 5 | `ai-agent/` | `tools-hub/workflow-builder/` | ✅ 完整迁移 | 12 节点 + 36+ shadcn UI |
| 6 | `claude-mem-main/` | `plugins-hub/official/claude-mem/` | ✅ 完整拷贝 | .claude + plugin + docs + cursor-hooks |
| 7 | `lucide/` | `packages/@yyc3/icons/` | ✅ SVG 子集 | 1000+ icons + LICENSE |
| 8 | `chatAgentTools/` | `tools-hub/chat-agent/` | ✅ 已预集成 | — |
| 9 | `autocomplete-tools/` | `tools-hub/autocomplete/` | ✅ 已预集成 | — |
| 10 | `NVIDIA-Skills/` | `skills-hub/ai-ml/nvidia-skills/` | ✅ 202 全量验证 | 索引文档已对齐 |

### 1.2 待人工清理项（外部冗余项目在根目录）

以下项目仍位于 `YYC3-Skills/` 根目录，建议移入 `_external/` 标记：

| 路径 | 说明 | 建议动作 |
|------|------|----------|
| `ClickHouse/` | ClickHouse C++ 数据库源码 | 移入 `_external/ClickHouse/` |
| `SuperPowers/` | Claude Code 外部插件 | 移入 `_external/SuperPowers/` |
| `autocomplete-specs/` | fig 终端补全规范 261 个 | 移入 `_external/autocomplete-specs/` |
| `agents-hub/cowagent/` | CowAgent 框架 | 移入 `_external/agents/cowagent/` |
| `agents-hub/qwen/` | 通义千问 SDK | 移入 `_external/agents/qwen/` |
| `build_tools/` | fish-shell 构建脚本 | 保留在原位或删除 |

---

## 二、自有项目深度分析

### 2.1 YYC3-CLI（v2.0.0）—— `/Users/yanyu/YYC-Cube/YYC3-CLI/`

```
┌─────────────────────────────────────────────────────────────────────┐
│  YYC3-CLI v2.0.0 现状                                               │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  入口: bin/yyc3-cli.js                                             │
│  依赖: commander (外部 npm 包)                                      │
│                                                                     │
│  已有结构:                                                          │
│  ├── bin/yyc3-cli.js          ← CLI 入口（commander）              │
│  ├── lib/index.js             ← 命令实现（init/deploy/build/test） │
│  ├── config/                  ← 配置模板                           │
│  │   ├── defaults/            ← 默认配置（eslint/ts/prettier）     │
│  │   ├── environments/        ← 环境变量（docker/local）          │
│  │   ├── security/            ← RBAC/MCP 权限控制                 │
│  │   └── services/            ← Docker 编排                       │
│  ├── docs/                    ← 完整文档体系                       │
│  │   ├── YYC3-CLI-API-文档/   ← API 接口文档                      │
│  │   ├── YYC3-CLI-使用指南/   ← 17 篇使用文档                     │
│  │   ├── YYC3-CLI-标准规范/   ← 分类/执行/标准规范                │
│  │   ├── YYC3-CLI-设计架构/   ← 架构设计文档                      │
│  │   └── YYC3-CLI-审核分析/   ← 审核报告                         │
│  ├── .github/workflows/       ← CI/CD 流水线                     │
│  ├── .husky/                  ← Git hooks                         │
│  └── Public/                  ← 品牌图标（多平台/多品牌）          │
│                                                                     │
│  优势: ✅ 完整文档体系  ✅ 品牌资产  ✅ 安全配置  ✅ CI/CD        │
│  差距: ❌ 依赖 commander     ❌ 未集成 Skills 索引                 │
│        ❌ 无去重检测          ❌ 无注册中心                         │
│        ❌ 未与 YYC3-Skills 工作区关联                              │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

### 2.2 YYC3-i18n-Core（v2.4.0）—— `/Users/yanyu/YYC-Cube/YYC3-i18n-Core/`

```
┌─────────────────────────────────────────────────────────────────────┐
│  YYC3-i18n-Core v2.4.0 现状                                          │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  ⭐ 远超预期 — 成熟的 TypeScript 国际化框架                         │
│                                                                     │
│  核心能力:                                                          │
│  ├── src/engine.ts             ← 核心引擎（缓存+加载+格式化）      │
│  ├── src/lib/icu/              ← ICU MessageFormat 解析器/编译器   │
│  ├── src/lib/ai/               ← AI 翻译（Ollama + OpenAI）        │
│  │   ├── provider.ts           ← 抽象翻译提供商                     │
│  │   ├── ollama-provider.ts    ← Ollama 本地 LLM 翻译              │
│  │   ├── openai-provider.ts    ← OpenAI API 翻译                   │
│  │   └── quality-estimator.ts  ← 翻译质量评估                      │
│  ├── src/lib/mcp/              ← MCP Server 集成                   │
│  │   ├── i18n-tools.ts         ← i18n MCP 工具                     │
│  │   ├── server.ts             ← MCP 服务器                        │
│  │   └── stdio-transport.ts    ← stdio 传输层                      │
│  ├── src/lib/plugins/          ← 插件系统                           │
│  │   ├── missing-key-reporter.ts ← 缺失键报告                      │
│  │   ├── performance-tracker.ts  ← 性能追踪                        │
│  │   └── console-logger.ts       ← 控制台日志                      │
│  ├── src/lib/security/         ← 安全模块                           │
│  │   ├── dangerous-operations.ts ← 危险操作检测                    │
│  │   ├── safe-regex.ts         ← 安全正则                          │
│  │   └── secret-equal.ts       ← 常量时间比较                      │
│  ├── src/lib/rtl-utils.ts      ← RTL 排版工具                      │
│  └── src/locales/              ← 10 语言文件（TypeScript）          │
│      ├── zh-CN.ts              ← 简体中文                          │
│      ├── zh-TW.ts              ← 繁体中文                          │
│      ├── en.ts                 ← 英文                              │
│      ├── ja.ts                 ← 日文                              │
│      ├── ko.ts                 ← 韩文                              │
│      ├── fr.ts                 ← 法文                              │
│      ├── de.ts                 ← 德文                              │
│      ├── es.ts                 ← 西班牙文                          │
│      ├── ru.ts                 ← 俄文                              │
│      ├── ar.ts                 ← 阿拉伯文                          │
│      └── pt-BR.ts              ← 葡萄牙文                          │
│                                                                     │
│  子包:                                                              │
│  ├── packages/i18n-react/       ← React Provider + Trans 组件      │
│  └── packages/cli-integration/  ← CLI 集成命令                     │
│                                                                     │
│  测试: 30+ 测试文件（vitest）覆盖引擎/AI/ICU/安全/插件             │
│  文档: vitepress 文档站 + COMPLIANCE + MIGRATION_GUIDE             │
│                                                                     │
│  优势: ⭐⭐⭐⭐⭐                                                      │
│  ✅ 零依赖核心  ✅ AI 翻译  ✅ MCP 原生  ✅ ICU 标准               │
│  ✅ 插件系统    ✅ 安全审计  ✅ 完整测试  ✅ React 绑定            │
│                                                                     │
│  差距: 仅缺 Skills 翻译键的自动提取 + 与 YYC3-Skills 的集成        │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

---

## 三、资产全景架构（整合后）

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    YYC³ 全栈智能资产全景                                     │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  🎯 YYC3-CLI (自有) — 统一入口                                       │   │
│  │  yyc3-cli.js → 对接 Skills 工作区的 build/validate/registry 命令    │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                               │                                               │
│  ┌────────────────────────────▼─────────────────────────────────────────┐   │
│  │  🌐 YYC3-i18n-Core (自有 v2.4.0) — 国际化基础设施                     │   │
│  │  10 语言 · ICU 标准 · AI 翻译 · MCP 原生 · 插件系统                    │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                               │                                               │
│  ┌────────────────────────────▼─────────────────────────────────────────┐   │
│  │  🏗️ YYC3-Skills 工作区 — 核心资产池                                  │   │
│  │                                                                     │   │
│  │  ┌──────────┬──────────┬──────────┬──────────┬──────────┐         │   │
│  │  │ agents   │ skills   │ plugins  │ tools    │ mcp      │         │   │
│  │  │ 1243+   │ 8700+   │ 80+     │ 6 Hub   │ 210+    │         │   │
│  │  └──────────┴──────────┴──────────┴──────────┴──────────┘         │   │
│  │                                                                     │   │
│  │  ┌──────────────────────────────────────────────────────────────┐   │   │
│  │  │  docs/ 完整文档体系 + 6 份架构清单 + 审核报告               │   │   │
│  │  └──────────────────────────────────────────────────────────────┘   │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  📦 Workflow Builder (已迁移) — 可视化 AI 编排                       │   │
│  │  12 种 AI 节点 + React Flow + shadcn/ui 36+ 组件                     │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  🧠 Claude Mem (已迁移) — 跨会话记忆系统                            │   │
│  │  Plugin/Hooks/Modes + 20+ 语言文档 + 30+ 审计报告                    │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 四、投产实施方案（3 阶段 · 8 周）

### 阶段一：资产归位与 CLI 增强（第 1-2 周）

```
┌─────────────────────────────────────────────────────────────────────┐
│  第 1 周: 目录清理 + i18n 联动                                      │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  [P0] 目录结构清理                                                   │
│  ├── ClickHouse/ → _external/ClickHouse/                           │
│  ├── SuperPowers/ → _external/SuperPowers/                         │
│  ├── autocomplete-specs/ → _external/autocomplete-specs/           │
│  ├── agents-hub/cowagent/ → _external/agents/cowagent/             │
│  ├── agents-hub/qwen/ → _external/agents/qwen/                     │
│  └── build_tools/ → 删除（非 YYC3 资产）                            │
│                                                                     │
│  [P1] 系统提示词断链修复                                             │
│  ├── 创建 YYC3-Agent.md（被引用但不存在）                           │
│  └── 创建 YYC3-微调数据构建规范.md（被引用但不存在）                │
│                                                                     │
│  [P2] i18n 与 Skills 工作区打通                                     │
│  ├── ~~将 YYC3-i18n-Core 作为 git submodule 引入~~（已改为内联复制） │
│  │   → packages/yyc3-i18n/（实际代码，2026-08-18 落地）            │
│  └── 为 i18n 引擎添加 Skills 专属翻译键（~2000 键）                │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────┐
│  第 2 周: CLI 增强集成                                               │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  [P0] ~~将 YYC3-CLI 链接至工作区~~（已改为内联复制）               │
│  ├── 在 YYC3-Skills 根目录 package.json 添加:                      │
│  │   "bin": { "yyc3": "packages/yyc3-cli/bin/yyc3-cli.js" }        │
│  └── packages/yyc3-cli/（实际代码，2026-08-18 落地）               │
│                                                                     │
│  [P1] 在 YYC3-CLI 中新增 Skills 管理命令                            │
│  ├── yyc3 skills:build    构建全局索引                              │
│  ├── yyc3 skills:validate 验证完整性                                │
│  ├── yyc3 skills:dedup    去重检测                                  │
│  └── yyc3 skills:stats    统计报告                                  │
│                                                                     │
│  [P2] MCP 配置去重                                                  │
│  └── 删除 plugins-hub/official/claude-plugins/external_plugins/    │
│      下 18 组重复配置                                               │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

### 阶段二：能力闭环（第 3-4 周）

```
┌─────────────────────────────────────────────────────────────────────┐
│  第 3 周: i18n 深度集成                                              │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  [P0] 创建 Skills 翻译键权威源（zh-CN）                             │
│  ├── agent.*        ~200 键  — AI Family 8 位 Agent 描述           │
│  ├── skill.*        ~1500 键 — 主要 Skills 分类+描述                │
│  ├── category.*     ~100 键  — 分类体系                             │
│  ├── cli.*          ~100 键  — CLI 命令/输出                        │
│  ├── docs.*         ~100 键  — 文档标签                             │
│  └── brand.*        ~50 键   — 品牌信息                             │
│      总计: ~2050 键                                                  │
│                                                                     │
│  [P1] AI 翻译（使用 i18n-core 内建 AI Provider）                    │
│  ├── en → AI 翻译 → ja/ko (第 1 批 ~4000 键)                       │
│  ├── ja → AI 翻译 → fr/de/es (第 2 批 ~6000 键)                    │
│  └── 质量评估 → 人工抽检 10%                                        │
│                                                                     │
│  [P2] i18n lint 集成到 CI                                           │
│  └── GitHub Actions: 每次 PR 自动检查翻译完整性                      │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────┐
│  第 4 周: 注册中心 + 持续同步                                        │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  [P0] 统一注册中心                                                  │
│  ├── Agent Registry: _agents_index.json（已存在）                   │
│  ├── Skill Registry: _categories.json（已存在，需去重）              │
│  ├── MCP Registry: _mcps_index.json（已存在）                       │
│  └── Tool Registry: _tools_index.json（已存在）                     │
│                                                                     │
│  [P1] 去重清理                                                      │
│  ├── _categories.json → 合并 source:skills + source:other 重复项   │
│  ├── B2B Skills → 删除 b2b-skills/ 保留 b2b-sdr-template/         │
│  └── Agent 文件 → 删除 docs/XXX 副本，保留 agents-hub 权威源      │
│                                                                     │
│  [P2] 上游同步机制                                                  │
│  ├── NVIDIA Skills: crontab 每周拉取 skills.sh.json                │
│  └── buildwithclaude: 监测插件仓库 release 标签                     │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

### 阶段三：智能化投产（第 5-8 周）

```
┌─────────────────────────────────────────────────────────────────────┐
│  第 5-6 周: Workflow Builder 生态化                                  │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  [P0] 连接 AI Family 8 位 Agent 至可视化画布                        │
│  ├── 言启·千行  → 入口节点                                          │
│  ├── 元启·天枢  → 编排节点                                          │
│  ├── 语枢·万物  → 分析节点                                          │
│  └── ...共 8 个 Agent 节点                                          │
│                                                                     │
│  [P1] i18n 国际化面板                                               │
│  └── Workflow Builder 前端接入 YYC3-i18n-Core                       │
│                                                                     │
│  [P2] 导出为 Skill 链                                               │
│  └── 可视化工作流 → 可执行 Skill 编排 YAML                          │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────┐
│  第 7-8 周: 验收体系 + 文档站                                        │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  [P0] 智能验收流水线                                                │
│  ├── GitHub Actions: PR 触发全量验证                                │
│  │   ├── Skills frontmatter 完整性检查                              │
│  │   ├── 交叉引用链接断裂检查                                        │
│  │   ├── 重复文件检测                                               │
│  │   └── i18n 翻译完整性检查                                        │
│  └── 质量门禁: 上述任何一项失败则阻断合并                            │
│                                                                     │
│  [P1] 统一文档站（vitepress）                                       │
│  ├── docs.yyc3.com                                                 │
│  ├── Agent 档案 / Skills 目录 / CLI 指南 / i18n 文档               │
│  └── 多语言文档站（zh-CN + en 优先）                                │
│                                                                     │
│  [P2] 混沌工程演练                                                  │
│  └── 按 YYC3-混沌工程演练规范.md 执行自动化演练                    │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

---

## 五、YYC3-CLI 增强实施建议

### 5.1 当前 CLI vs 目标 CLI

```
维度          当前 YYC3-CLI              目标 YYC3-CLI
─────        ───────────────            ─────────────────
入口          bin/yyc3-cli.js            bin/yyc3-cli.js（保持不变）
解析器        commander（外部依赖）      commander（继续使用，不做零依赖改造）
增强命令      init/deploy/build/test     + skills:build / skills:validate / skills:dedup / skills:stats
集成对象      通用项目                   YYC3-Skills 工作区
文档          ✅ 完整                   ✅ + Skills 管理章节
CI/CD         ✅                        ✅ + i18n lint / 去重检测
```

### 5.2 需要新增的文件

```
YYC3-CLI/
├── lib/
│   ├── index.js                  ← 已有（init/deploy/build/test）
│   ├── skills-indexer.js         ← 新增（索引构建引擎）
│   ├── skills-validator.js       ← 新增（完整性验证）
│   ├── skills-deduper.js         ← 新增（去重检测，SHA256 哈希）
│   ├── skills-stats.js           ← 新增（统计报告）
│   └── i18n-sync.js              ← 新增（对接 YYC3-i18n-Core）
```

### 5.3 推荐：不自研零依赖 CLI 的原因

| 因素 | 保持 commander | 改造零依赖 |
|------|:-------------:|:----------:|
| 重写成本 | 0 | 高（子命令/帮助/参数校验都需要手写） |
| 维护成本 | 低（成熟生态） | 高 |
| 功能完备性 | ⭐⭐⭐⭐⭐ | ⭐⭐ |
| 可移植性 | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| **建议** | **✅ 推荐** | ❌ 不推荐 |

> 结论：**保持 commander 作为 CLI 解析器**，零依赖策略仅应用于 i18n 核心引擎。YYC3-i18n-Core 已实现零依赖核心，验证了该策略的可行性。

---

## 六、YYC3-i18n-Core 集成实施建议

### 6.1 当前 i18n 架构评价

| 指标 | 评价 |
|------|------|
| 架构完整性 | ⭐⭐⭐⭐⭐ 成熟度远超预期 |
| 零依赖核心 | ✅ engine.ts 零外部依赖 |
| AI 翻译 | ✅ Ollama + OpenAI 双提供商 |
| MCP 集成 | ✅ 原生 MCP Server 支持 |
| ICU 标准 | ✅ 完整 MessageFormat 解析器 |
| 测试覆盖 | ✅ 30+ 测试文件 |
| 安全审计 | ✅ 常量时比较 / 安全正则 |
| 文档 | ✅ vitepress 文档站 |

### 6.2 集成动作（只需 3 步）

```bash
# 第 1 步：内联复制（已执行，替代原符号链接方案）
# cp -r /Users/yanyu/YYC-Cube/YYC3-i18n-Core packages/yyc3-i18n（排除 .git/node_modules）

# 第 2 步：在 package.json 中添加 workspace 引用
# "packages": [
#   "packages/yyc3-i18n"
# ]

# 第 3 步：安装依赖 & 验证
cd packages/yyc3-i18n
pnpm install
pnpm test    # 验证 30+ 测试全部通过
```

### 6.3 新增：Skills 翻译键提取器

需要在 YYC3-i18n-Core 中新增一个工具：

```
packages/yyc3-i18n/
├── src/
│   ├── ...                         ← 现有文件不变
│   └── lib/
│       └── extractors/
│           └── skills-extractor.ts ← 新增：SKILL.md frontmatter 扫描
└── scripts/
    └── extract-skills-keys.ts      ← 新增：批量提取脚本
```

```typescript
// skills-extractor.ts 核心逻辑（伪代码）
// 1. 递归扫描 skills-hub/**/SKILL.md
// 2. 提取 frontmatter: name, description, category
// 3. 按命名规范生成翻译键：
//    skill.{目录}.{文件名}.name
//    skill.{目录}.{文件名}.desc
// 4. 输出 JSON 作为 zh-CN 权威源
```

---

## 七、实施路线图（甘特图）

```
任务\周次                   W1    W2    W3    W4    W5    W6    W7    W8
─────────────────────────  ────  ────  ────  ────  ────  ────  ────  ────
目录清理 (ClickHouse等)     ████  ████
系统提示词断链修复           ████  ████
CLI symlink 链接            ████
CLI skills 命令新增               ████  ████
MCP 配置去重                      ████  ████
i18n submodule 引入         ████
Skills 翻译键创建                  ████  ████
AI 翻译 + 人工审核                        ████  ████
i18n CI 集成                               ████
注册中心去重                             ████  ████
上游同步机制                                     ████  ████
Workflow Agent 节点集成                          ████  ████
Workflow i18n 集成                                     ████
智能验收流水线                                           ████  ████
统一文档站                                                     ████  ████
混沌工程演练                                                         ████

里程碑                   M1:清理完成  M2:CLI增强  M3:i18n完成  M4:投产上线
```

---

## 八、投产验证标准

### 8.1 技术验收

| 检查项 | 标准 | 方法 |
|--------|------|------|
| 目录整洁度 | 无外部项目在根目录 | `ls -d _external/` 存在 |
| 索引一致性 | 索引 JSON 与文件系统 1:1 | `yyc3 skills:validate` |
| 零重复 | 无 SHA256 相同文件 | `yyc3 skills:dedup` |
| i18n 覆盖率 | 所有键在 10 语言中 ≥95% | `yyc3 i18n lint` |
| 引用完整性 | 无断链交叉引用 | `yyc3 validate links` |
| MCP 配置 | 无重复 .mcp.json | `yyc3 validate duplicates` |

### 8.2 业务验收

| 检查项 | 标准 |
|--------|------|
| AI Family 8 位 Agent | 可被 Workflow Builder 拖拽编排 |
| Skills 查询 | 5 秒内返回分类结果 |
| i18n 切换 | 即时切换语言，零闪白 |
| CLI 构建 | 10 秒内完成全量索引构建 |
| CLI 去重 | 扫描 10000+ 文件 < 30 秒 |

---

## 九、建议总结

### 关键建议（按优先级）

1. **保留 YYC3-CLI 的 commander 依赖** — 不自研零依赖 CLI，将精力集中在 Skills 管理命令的扩展上
2. **YYC3-i18n-Core 直接 submodule 接入** — v2.4.0 已成熟到可直接投产，仅需新增 Skills 翻译键提取器
3. **目录清理在本周执行** — 6 个外部项目移入 `_external/`，立即可提升根目录整洁度
4. **Workflow Builder 连接 AI Family** — 这是最直观的可视化产出，8 周内可交付
5. **智能验收 CI 流水线** — PR 门槛，防止新引入重复/断裂引用

### 不需要做

- ❌ 不自研零依赖 CLI（i18n-core 已实现零依赖核心即可）
- ❌ 不重写现有 Python 索引脚本（通过 CLI 包装调用）
- ❌ 不删除现有 _*.json 索引（兼容性过渡）

---

*基于 YYC³ 五维五高五标五化核心机制 · 万象归元于云枢*
