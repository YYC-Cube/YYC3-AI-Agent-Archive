<div align="center">
  <img src="Public/Family-001.png" alt="YYC³ Family" width="100%" style="max-width: 896px; border-radius: 12px;" />
</div>

<br/>

<div align="center">

# YYC³-CLI — 智能应用全文档架构生成引擎

> **_YanYuCloudCube_**
>
> **言启象限 | 语枢未来**
>
> _Words Initiate Quadrants, Language Serves as Core for Future_
>
> **万象归元于云枢 | 深栈智启新纪元**
>
> _All things converge in cloud pivot; Deep stacks ignite a new era of intelligence_

---

[![Release](https://img.shields.io/badge/Release-v2.0.0-7B68EE?style=for-the-badge&logo=vercel)](https://github.com/YYC-Cube/YYC3-CLI/releases)
[![License](https://img.shields.io/badge/License-MIT-44CC11?style=for-the-badge&logo=open-source-initiative)](LICENSE)
[![Node](https://img.shields.io/badge/Node-%3E%3D16.0.0-339933?style=for-the-badge&logo=node.js)](https://nodejs.org)
[![NPM](https://img.shields.io/badge/NPM-%3E%3D8.0.0-CB3837?style=for-the-badge&logo=npm)](https://npmjs.com)
[![Build](https://img.shields.io/badge/Build-Passing-22AD5C?style=for-the-badge&logo=github-actions)](https://github.com/YYC-Cube/YYC3-CLI/actions)
[![Tests](https://img.shields.io/badge/Tests-Jest-99425B?style=for-the-badge&logo=jest)](https://jestjs.io)
[![Code Style](https://img.shields.io/badge/Code%20Style-Prettier-FF69B4?style=for-the-badge&logo=prettier)](https://prettier.io)
[![ESLint](https://img.shields.io/badge/Lint-ESLint-4B32C3?style=for-the-badge&logo=eslint)](https://eslint.org)
[![Standard](https://img.shields.io/badge/Standard-YYC%C2%B3%20v2.1.0-0052CC?style=for-the-badge&logo=markdown)](docs/YYC3-团队通用-标准规范/YYC3-团队核心-五维驱动.md)
[![PRs](https://img.shields.io/badge/PRs-Welcome-FF6B6B?style=for-the-badge&logo=git)](https://github.com/YYC-Cube/YYC3-CLI/pulls)
[![AI Ready](https://img.shields.io/badge/AI-Ready-00B4D8?style=for-the-badge&logo=openai)](docs/YYC3-团队通用-标准规范/YYC3-团队核心-五维驱动.md)

---

</div>

## 📋 目录

- [项目概述](#项目概述)
- [核心架构 — 五高五标五化五维](#核心架构--五高五标五化五维)
- [功能特性](#功能特性)
- [快速开始](#快速开始)
- [命令行指南](#命令行指南)
- [文档体系](#文档体系)
- [AI 智能化能力](#ai-智能化能力)
- [技术栈](#技术栈)
- [项目结构](#项目结构)
- [贡献指南](#贡献指南)
- [许可证与团队](#许可证与团队)

---

## 项目概述

**YYC³-CLI** 是一个基于「五高五标五化五维」核心机制构建的**智能化企业级文档全生命周期生成引擎**。它不仅仅是一个命令行工具，更是 YYC³（YanYuCloudCube）智能应用链中负责**文档自动化生成、标准化管理、智能化运维**的关键基础设施。

### 核心定位

| 维度　　　　　 | 说明　　　　　　　　　　　　　　　　　 |
| ----------------| ----------------------------------------|
| **自动化引擎** | 一键生成符合 YYC³ 标准的全栈文档架构　 |
| **规范守卫**　 | 内置标准化验证与合规检查机制　　　　　 |
| **AI 增强**　　| 集成 AI 能力实现智能文档生成与知识管理 |
| **多云适配**　 | 支持 ALI（阿里云）等主流云服务文档模板 |
| **生态链接**　 | 与 YYC³ 全系列智能应用无缝集成　　　　 |

### 品牌标识

```
YYC³ = YanYuCloudCube
     ↳ 言启象限 — 以语言为入口，开启智能应用的无限象限
     ↳ 语枢未来 — 以语言为核心，驱动未来的智能交互范式
     ↳ 云枢归一 — 万象归元于云枢，深栈智启新纪元
```

---

## 核心架构 — 五高五标五化五维

YYC³-CLI 基于团队核心机制架构设计，详见 [YYC³ 团队核心-五维驱动](docs/YYC3-团队通用-标准规范/YYC3-团队核心-五维驱动.md)。

### 体系架构总览

```
┌──────────────────────────────────────────────────────────────────────────┐
│                         YYC³ 智能应用核心机制                              │
├──────────────────────────────────────────────────────────────────────────┤
│                                                                          │
│  ┌──────────────────────────────────────────────────────────────────┐   │
│  │                    五高架构体系 (High Architecture)              │   │
│  │  ┌────────┐ ┌────────┐ ┌────────┐ ┌────────┐ ┌────────┐       │   │
│  │  │ 高可用  │ │ 高性能  │ │ 高安全  │ │ 高扩展  │ │ 高智能  │       │   │
│  │  │ 99.99% │ │ <100ms │ │ 纵深防御│ │ 弹性伸缩│ │ AI增强 │       │   │
│  │  │  SLA   │ │ P99延迟│ │ 架构    │ │ HPA    │ │ 能力   │       │   │
│  │  └────────┘ └────────┘ └────────┘ └────────┘ └────────┘       │   │
│  └──────────────────────────────────────────────────────────────────┘   │
│                                    │                                     │
│  ┌──────────────────────────────────────────────────────────────────┐   │
│  │                    五标规范体系 (Standard System)                │   │
│  │  ┌────────┐ ┌────────┐ ┌────────┐ ┌────────┐ ┌────────┐       │   │
│  │  │ 标准化  │ │ 规范化  │ │ 自动化  │ │ 可视化  │ │ 智能化  │       │   │
│  │  │ 95%+   │ │ 流程   │ │ CI/CD  │ │ Grafana│ │ AI辅助 │       │   │
│  │  │ 覆盖率 │ │ 规范   │ │ Pipeline│ │ 看板   │ │ 开发   │       │   │
│  │  └────────┘ └────────┘ └────────┘ └────────┘ └────────┘       │   │
│  └──────────────────────────────────────────────────────────────────┘   │
│                                    │                                     │
│  ┌──────────────────────────────────────────────────────────────────┐   │
│  │                    五化转型体系 (Transformation)                 │   │
│  │  ┌────────┐ ┌────────┐ ┌────────┐ ┌────────┐ ┌────────┐       │   │
│  │  │ 流程化  │ │ 数字化  │ │ 生态化  │ │ 工具化  │ │ 服务化  │       │   │
│  │  │ 全生命  │ │ 数据   │ │ 多云   │ │ CLI   │ │ 微服务 │       │   │
│  │  │ 周期    │ │ 驱动   │ │ 适配   │ │ 工具   │ │ 架构   │       │   │
│  │  └────────┘ └────────┘ └────────┘ └────────┘ └────────┘       │   │
│  └──────────────────────────────────────────────────────────────────┘   │
│                                    │                                     │
│  ┌──────────────────────────────────────────────────────────────────┐   │
│  │                    五维评估体系 (Evaluation)                     │   │
│  │  ┌────────┐ ┌────────┐ ┌────────┐ ┌────────┐ ┌────────┐       │   │
│  │  │ 时间维  │ │ 空间维  │ │ 属性维  │ │ 事件维  │ │ 关联维  │       │   │
│  │  │ 演进   │ │ 拓扑   │ │ 质量   │ │ 响应   │ │ 依赖   │       │   │
│  │  │ 追踪   │ │ 分布   │ │ 评估   │ │ 处理   │ │ 分析   │       │   │
│  │  └────────┘ └────────┘ └────────┘ └────────┘ └────────┘       │   │
│  └──────────────────────────────────────────────────────────────────┘   │
│                                                                          │
│                                    ▼                                     │
│  ┌──────────────────────────────────────────────────────────────────┐   │
│  │              YYC³ 智能应用全生命周期管理平台                      │   │
│  │          设计 → 开发 → 测试 → 部署 → 运维 → 演进               │   │
│  └──────────────────────────────────────────────────────────────────┘   │
└──────────────────────────────────────────────────────────────────────────┘
```

### 五维驱动评估模型

| 评估维度 | 核心关注 | 关键指标 | 工具支撑 |
| -------- | -------- | -------- | -------- |
| **⏱ 时间维** | 版本演进、迭代周期、趋势预测 | MTBF / MTTR / 发布频率 | Git / Changelog / 时序监控 |
| **🌐 空间维** | 服务拓扑、资源分布、地域部署 | 资源利用率 / 访问延迟 | K8s / Cloud Map / 多区域监控 |
| **⚙️ 属性维** | 质量属性、技术栈、架构健康度 | 性能分 / 安全分 / 覆盖率 | SonarQube / 安全扫描 / 测试报告 |
| **🔔 事件维** | 业务事件、系统事件、异常警报 | 响应时间 / 处理时限 / 升级率 | 告警平台 / 事件追踪 / PagerDuty |
| **🔗 关联维** | 依赖关系、数据血缘、协作网络 | 依赖深度 / 调用频率 / 协同效率 | 调用链 / 数据地图 / 协作图谱 |

---

## 功能特性

### 📄 智能文档生成

一键生成符合 YYC³ 标准的全栈文档架构，覆盖项目全生命周期：

```bash
yyc3 docs generate --project "我的项目" --version v2.0.0
```

| 文档类别 | 生成内容 | 模板数量 |
| -------- | -------- | -------- |
| 需求规划 | 项目章程、可行性分析、需求规格 | 10+ |
| 项目规划 | 项目管理、进度、风险管理 | 8+ |
| 架构设计 | 系统架构、数据架构、安全架构 | 12+ |
| 详细设计 | 模块设计、UI/UX、接口设计 | 10+ |
| API 文档 | RESTful 规范、错误码、SDK 使用 | 15+ |
| ALI 云服务 | ECS / RDS / OSS / SLB / VPC 等 | 19+ 云服务 |

### ✅ 文档验证引擎

内置多层次验证机制，确保文档质量：

- **格式验证** — 检查文档结构是否符合 YYC³ 规范
- **头部验证** — 校验 `@file` / `@version` / `@author` 等元数据完整性
- **内容验证** — 确保内容遵循「五高五标五化」标准
- **链接验证** — 自动检测文档内外部链接有效性

### 🔄 版本与更新管理

- 自动版本号递增与日期同步
- 支持 `--dry-run` 试运行模式预览变更
- 批量更新历史文档至最新规范版本

### ☁️ 多云服务支持

深度集成主流云服务平台文档模板，当前支持 **ALI（阿里云）** 19+ 核心服务：

```
ECS → RDS → OSS → SLB → VPC → RAM → CloudMonitor
LogService → WAF → DDoS → SSL → CDN → ACK → FC → MQ
API Gateway → Redis → MongoDB → PolarDB
```

### ⚡ 性能优化

| 特性 | 说明 | 效果 |
| ---- | ---- | ---- |
| 智能缓存 | 基于文件 Hash 的内容缓存 | 重复生成提速 10x |
| 并行生成 | 多线程架构（可配置 `--max-workers`） | 大规模文档生成加速 5x |
| 增量更新 | 仅处理变更内容 | 更新操作 O(1) 复杂度 |
| 进度反馈 | 实时进度条 + 详细统计 | 可视化的操作反馈 |

---

## 快速开始

### 环境要求

- **Node.js**: >= 16.0.0
- **NPM**: >= 8.0.0
- **操作系统**: macOS / Linux / Windows

### 安装

```bash
# 方式一：通过 NPM 全局安装（推荐）
npm install -g yyc3-cli

# 方式二：从源码安装
git clone https://github.com/YYC-Cube/YYC3-CLI.git
cd YYC3-CLI
npm install
npm link

# 验证安装
yyc3 --version
```

### 快速体验

```bash
# 生成标准文档架构
yyc3 docs generate

# 验证文档规范
yyc3 docs validate

# 更新文档版本
yyc3 docs update --new-version v2.1.0
```

---

## 命令行指南

### 全局选项

| 选项 | 缩写 | 说明 |
| ---- | ---- | ---- |
| `--version` | `-V` | 显示版本号 |
| `--help` | `-h` | 显示帮助信息 |
| `--verbose` | | 启用详细输出模式 |

### 文档生成 (`docs`)

```bash
yyc3 docs generate [options]
```

| 选项 | 缩写 | 默认值 | 说明 |
| ---- | ---- | ------ | ---- |
| `--root` | `-r` | `docs` | 文档根目录 |
| `--version` | `-v` | `v2.0.0` | 文档版本号 |
| `--project-name` | `-p` | 项目名称 | 项目名称 |
| `--enable-ali` | | `false` | 启用阿里云文档 |
| `--ali-region` | | `cn-hangzhou` | 阿里云区域 |
| `--cache` | | `true` | 启用缓存 |
| `--max-workers` | | `4` | 最大工作线程数 |
| `--verbose` | | `false` | 详细输出 |

### 文档验证 (`validate`)

```bash
yyc3 docs validate [options]
```

| 选项 | 说明 |
| ---- | ---- |
| `--check-format` | 检查文档格式 |
| `--check-headers` | 检查头部信息 |
| `--check-content` | 检查内容规范 |
| `--check-links` | 检查链接有效性 |

### 文档更新 (`update`)

```bash
yyc3 docs update [options]
```

| 选项 | 说明 |
| ---- | ---- |
| `--update-version` | 更新版本号 |
| `--update-date` | 更新日期 |
| `--new-version` | 指定新版本号 |
| `--dry-run` | 试运行模式 |

---

## 文档体系

YYC³-CLI 项目内置完整的多维文档体系，覆盖项目全生命周期：

### 文档全景图

```
docs/
├── YYC3-CLI-使用指南/          # 用户文档 - 快速上手与运维部署
│   ├── YYC3-CLI-初始化.md      # 项目初始化指南
│   ├── YYC3-CLI-本地部署.md    # 本地部署指引
│   ├── YYC3-CLI-配置指南.md    # 配置说明
│   └── YYC3-CLI-运维指南.md    # 运维操作手册
│
├── YYC3-CLI-设计架构/          # 架构文档 - 系统设计与实现
│   ├── YYC3-CLI-项目定义.md    # 项目定义与范围
│   ├── YYC3-CLI-设计实现.md    # 详细设计实现
│   └── YYC3-CLI-文件结构.md    # 项目文件结构
│
├── YYC3-CLI-标准规范/          # 规范文档 - 开发标准与执行规范
│   ├── YYC3-CLI-标准规范.md    # 核心标准规范
│   ├── YYC3-CLI-执行规范.md    # 执行细则
│   └── YYC3-CLI-分类体系.md    # 分类体系
│
├── YYC3-CLI-API-文档/          # API 文档 - 接口规格与参考
│   └── YYC3-CLI-API-文档.md    # API 完整文档
│
├── YYC3-CLI-审核分析/          # 审核报告 - 质量检测与评估
│   ├── YYC3-CLI-审核报告.md    # 项目审核报告
│   └── YYC3-CLI-标准报告.md    # 标准检查报告
│
├── YYC3-团队通用-标准规范/      # 团队规范 - 核心机制与文档标准
│   ├── YYC3-团队核心-五维驱动.md  # ⭐ 核心机制文档
│   ├── YYC3-团队规范-开发标准.md  # 开发标准规范
│   ├── YYC3-团队规范-文档闭环.md  # 文档闭环管理
│   ├── YYC3-团队通用-开发文档.md  # 通用开发文档
│   └── YYC3-多端适配-规范文档.md  # 多端适配规范
│
├── YYC3-全栈体系-运维手册/      # 运维文档 - 系统运维与AI模型
│   ├── YYC3-知识体系-运维手册.md # 知识体系运维
│   └── YYC3-NVIDIA-Model.md   # GPU/NVIDIA 模型部署
│
├── YYC3-构建自属-UI知识库/      # UI/UX 知识库
│   ├── YYC3-Next+React-项目.md # Next.js + React 项目指南
│   └── YYC3-智能应用-复用设计.md # 智能应用复用设计
│
├── YYC3-欢迎信息/              # 快速参考 - 环境与配置速查
│   ├── YYC3-CLI.md             # CLI 速查
│   ├── YYC3-DEV.md             # 开发环境速查
│   ├── YYC3-ENV.md             # 环境变量速查
│   └── YYC3-MODEL.md           # AI 模型速查
│
└── README.md                   # 文档索引
```

---

## AI 智能化能力

YYC³-CLI 深度集成 AI 能力，提供智能化的文档处理体验：

### AI 能力矩阵

| 层级 | 能力 | 实现方式 | 应用场景 |
| ---- | ---- | -------- | -------- |
| **感知智能** | NLU / 文档解析 | LLM + 规则引擎 | 智能文档分类、内容提取 |
| **认知智能** | 知识推理 / 规范检查 | 知识图谱 + RAG | 规范自动审查、合规校验 |
| **决策智能** | 推荐 / 优化 | 策略引擎 + ML | 最佳模板推荐、结构优化 |
| **创造智能** | 内容生成 / 模板生成 | LLM + Prompt Engine | 自动文档撰写、模板生成 |

### 智能技术栈

```
┌──────────────────────────────────────────────────────────────┐
│                       YYC³ AI 技术栈                          │
├──────────────────────────────────────────────────────────────┤
│                                                              │
│  LLM 层    │ DeepSeek  │  YYC³ Model  │  Qwen  │  Ollama     │
├────────────┼─────────────────────────────────────────────────┤
│  编排层    │ LangChain  │  LlamaIndex  │  Semantic Kernel    │
├────────────┼─────────────────────────────────────────────────┤
│  向量层    │ pgvector   │  Milvus      │  Pinecone           │
├────────────┼─────────────────────────────────────────────────┤
│  Agent 层  │ AutoGPT    │  CrewAI      │  Custom Agents      │
├────────────┼─────────────────────────────────────────────────┤
│  工具层    │ Function Calling  │  MCP   │  Tool Use          │
│                                                              │
└──────────────────────────────────────────────────────────────┘
```

---

## 技术栈

| 类别 | 技术 | 用途 |
| ---- | ---- | ---- |
| **运行时** | Node.js >= 16 | CLI 运行环境 |
| **CLI 框架** | Commander.js | 命令行参数解析 |
| **UI 增强** | Chalk / Figlet / Boxen / Ora | 终端样式与交互反馈 |
| **用户交互** | Inquirer | 交互式问答 |
| **HTTP** | Axios | 远程 API 调用 |
| **配置管理** | dotenv | 环境变量管理 |
| **日志** | Winston | 日志记录 |
| **测试** | Jest | 单元/集成测试 |
| **代码质量** | ESLint + Prettier | 代码规范与格式化 |
| **版本管理** | Standard-Version | 语义化版本发布 |
| **Git Hooks** | Husky + commitlint + lint-staged | 提交前检查 |

---

## 项目结构

```
YYC3-CLI/
├── bin/                    # CLI 入口
│   └── yyc3-cli.js         # 主入口脚本
│
├── lib/                    # 核心库
│   └── index.js            # 模块导出
│
├── config/                 # 配置文件
│   ├── defaults/           # 默认配置（ESLint/Prettier/TS/Commitlint）
│   ├── environments/       # 环境配置（.env 系列）
│   ├── security/           # 安全配置（MCP/RBAC/ACL）
│   └── services/           # 服务配置（Docker/Compose）
│
├── docs/                   # 📚 完整文档体系
│   ├── YYC3-CLI-使用指南/   # 用户指南
│   ├── YYC3-CLI-设计架构/   # 架构设计
│   ├── YYC3-CLI-标准规范/   # 标准规范
│   ├── YYC3-CLI-API-文档/   # API 文档
│   ├── YYC3-CLI-审核分析/   # 审核报告
│   ├── YYC3-团队通用-标准规范/ # 团队核心规范
│   ├── YYC3-全栈体系-运维手册/ # 运维手册
│   ├── YYC3-构建自属-UI知识库/ # UI知识库
│   └── YYC3-欢迎信息/       # 欢迎与速查
│
├── Public/                 # 静态资源
│   ├── Family-001.png      # 品牌家族图
│   ├── cloud-icons/        # 云端图标集
│   └── yyc3-*/             # YYC³ 品牌资产（iOS/Android/macOS/watchOS/Web）
│
├── claude/                 # AI 开发辅助
│   ├── Claude-Agentic组件选择指南.md
│   ├── Claude-Code实用小技巧.md
│   └── Claude-Skill从创建到优化的终极指南.md
│
├── .github/workflows/      # CI/CD 流水线
├── .husky/                 # Git Hooks
├── .vscode/                # VS Code 配置
│
├── package.json            # 项目配置
├── env.*                   # 环境模板文件
└── README.md               # 📖 本文档
```

---

## 贡献指南

我们欢迎所有形式的贡献！请遵循以下流程：

1. **Fork** 本仓库
2. 创建特性分支：`git checkout -b feature/AmazingFeature`
3. 遵循 **Conventional Commits** 规范提交：`<type>(<scope>): <subject>`
4. 确保通过 lint 和测试：`npm run lint && npm test`
5. 提交 PR 至 `develop` 分支

### Commit 规范

```
feat(scope):    新功能
fix(scope):     修复缺陷
docs(scope):    文档更新
style(scope):   代码格式
refactor(scope): 重构
test(scope):    测试
chore(scope):   构建/工具
```

详细规范请参考 [YYC³ 团队规范-开发标准](docs/YYC3-团队通用-标准规范/YYC3-团队规范-开发标准.md)。

---

## 许可证与团队

### 许可证

本项目采用 **MIT License** 开源，详见 [LICENSE](LICENSE) 文件。

### YYC³ 团队

| 角色 | 联系方式 |
| ---- | -------- |
| **项目主页** | [https://github.com/YYC-Cube/YYC3-CLI](https://github.com/YYC-Cube/YYC3-CLI) |
| **问题反馈** | [Issues](https://github.com/YYC-Cube/YYC3-CLI/issues) |
| **电子邮箱** | [admin@0379.email](mailto:admin@0379.email) |
| **核心机制** | [五维驱动架构](docs/YYC3-团队通用-标准规范/YYC3-团队核心-五维驱动.md) |

---

### 核心引用

> **YYC³（YanYuCloudCube）智能应用链**
>
> **言启千行代码，语枢万物智能**
>
> _Words Inspire Thousands of Lines of Code, Language Pivots the Intelligence of All Things_
>
> **万象归元于云枢 | 深栈智启新纪元**
>
> _All Things Converge in Cloud Pivot; Deep Stacks Ignite a New Era of Intelligence_

---

<div align="center">

**© 2025-2026 YYC³ Team. Built with ❤️ for the AI Era.**

**五高 · 五标 · 五化 · 五维** — 驱动的智能应用开发范式

</div>
