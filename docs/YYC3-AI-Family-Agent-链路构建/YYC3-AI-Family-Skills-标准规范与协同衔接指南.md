---
file: YYC3-AI-Family-Skills-标准规范与协同衔接指南.md
description: YYC³ AI Family Skills 库标准规范与协同衔接指南 — 三层协同模型 × 29 Skill 全量清单 × 元数据完整字典 × 全生命周期状态机
author: YanYuCloudCube Team — 智能应用实施专家 <admin@0379.email>
version: v2.0.0
created: 2026-07-23
updated: 2026-07-23
status: stable
tags: [Skill],[标准规范],[协同衔接],[MCP],[链路指导],[全量清单],[元数据字典],[生命周期],[映射矩阵]
category: architecture
language: zh-CN
audience: architects,developers,skill-developers,AI-engineers,SRE
complexity: advanced
related_docs: YYC3-Skill-核心定位与设计原则.md, YYC3-Skill-安全审计流程.md, YYC3-AI-Family-Agent-落地实施方案.md, YYC3-AI-Family-多智能体整体架构.md, YYC3-Agent-降级熔断标准.md
---

<div align="center">

# YYC³ AI Family Skills 库 — 标准规范与协同衔接指南

> **_YanYuCloudCube_**
> _言启象限 | 语枢未来_
> **_Words Initiate Quadrants, Language Serves as Core for Future_**
> _万象归元于云枢 | 深栈智启新纪元_
> **_All things converge in cloud pivot; Deep stacks ignite a new era of intelligence_**

| 属性 | 值 |
| ---- | --- |
| **文档版本** | v2.0.0 Official（深化版） |
| **发布日期** | 2026-07-23 |
| **文档性质** | YYC³ AI Family Skills 库标准规范与协同衔接指南 — 全链路标准化文档 |
| **衔接体系** | ① 家人档案情感身份层 → ② 人机协同协作公约层 → ③ 技术架构执行层 |
| **核心覆盖** | 29 个标准化 Skill 全量清单 × Agent-Skill-MCP 链路 × 三层协同映射 × 元数据完整字典 × 全生命周期状态机 |
| **适用范围** | YYC³ AI Family 全体 8 Agent 的 Skill 开发、注册、调用、运维全生命周期 |

</div>

---

## 📋 目录

- [YYC³ AI Family Skills 库 — 标准规范与协同衔接指南](#yyc-ai-family-skills-库--标准规范与协同衔接指南)
  - [📋 目录](#-目录)
  - [一、Skills 库三层协同模型](#一skills-库三层协同模型)
    - [1.1 三层架构定位](#11-三层架构定位)
    - [1.2 三层衔接桥接原则](#12-三层衔接桥接原则)
  - [二、Skills 标准规范体系（深化版）](#二skills-标准规范体系深化版)
    - [2.1 元数据完整字典](#21-元数据完整字典)
      - [2.1.1 skill\_meta 区块（14 个字段）](#211-skill_meta-区块14-个字段)
      - [2.1.2 input\_params 区块](#212-input_params-区块)
      - [2.1.3 output\_params 区块](#213-output_params-区块)
      - [2.1.4 execution\_logic 区块](#214-execution_logic-区块)
    - [2.2 命名代码表（完整版）](#22-命名代码表完整版)
      - [2.2.1 领域代码表（DOMAIN）](#221-领域代码表domain)
      - [2.2.2 动作动词表（action）](#222-动作动词表action)
      - [2.2.3 对象名词表（object）](#223-对象名词表object)
    - [2.3 参数规范](#23-参数规范)
    - [2.4 输出规范](#24-输出规范)
    - [2.5 安全规范](#25-安全规范)
  - [三、Skills 全生命周期状态机](#三skills-全生命周期状态机)
    - [3.1 状态定义与转换图](#31-状态定义与转换图)
    - [3.2 各状态门禁条件](#32-各状态门禁条件)
    - [3.3 版本管理公约](#33-版本管理公约)
      - [3.3.1 版本号增量规则](#331-版本号增量规则)
      - [3.3.2 版本演进策略](#332-版本演进策略)
      - [3.3.3 版本号与文件名规范](#333-版本号与文件名规范)
  - [四、Skills 全量清单与 JSON Schema](#四skills-全量清单与-json-schema)
    - [4.1 L3 技术执行层 19 Skill 清单](#41-l3-技术执行层-19-skill-清单)
      - [L3-01: 内容安全校验](#l3-01-内容安全校验)
      - [L3-02: 异常行为检测](#l3-02-异常行为检测)
      - [L3-03: 权限校验](#l3-03-权限校验)
      - [L3-04~L3-19（精简 Schema，仅列关键属性）](#l3-04l3-19精简-schema仅列关键属性)
    - [4.2 L2 协作公约层 5 Skill 清单](#42-l2-协作公约层-5-skill-清单)
    - [4.3 L1 情感身份层 5 Skill 清单](#43-l1-情感身份层-5-skill-清单)
  - [五、六维协同衔接映射矩阵](#五六维协同衔接映射矩阵)
    - [5.1 Agent↔Skill↔MCP↔Port↔Model↔LoRA 全映射](#51-agentskillmcpportmodellora-全映射)
    - [5.2 Agent 权限映射矩阵](#52-agent-权限映射矩阵)
    - [5.3 三层依赖拓扑图](#53-三层依赖拓扑图)
    - [5.4 MCP Server 部署清单](#54-mcp-server-部署清单)
  - [六、Agent-Skill-MCP 链路指导](#六agent-skill-mcp-链路指导)
  - [七、质量评估与监控体系](#七质量评估与监控体系)
    - [7.1 Skill 质量评分模型](#71-skill-质量评分模型)
    - [7.2 各 Agent Skill 监控看板](#72-各-agent-skill-监控看板)
    - [7.3 回归测试基线](#73-回归测试基线)
  - [关联文档](#关联文档)
  - [变更历史](#变更历史)

---

## 一、Skills 库三层协同模型

### 1.1 三层架构定位

Skills 库作为 YYC³ AI Family 的核心能力池，承担「情感身份层 → 协作公约层 → 技术执行层」三层融合的枢纽角色：

```
┌─────────────────────────────────────────────────────────────────┐
│              YYC³ Skills 库 — 三层协同模型                       │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌─────────── 第一层：情感身份 Skills ───────────┐            │
│  │  来源：家人档案 · 家族编号 010301-01~08         │            │
│  │  定位：固化 Agent 人格特质与品牌表达风格          │            │
│  │  模型形式：提示词模板 + SFT LoRA 适配器          │            │
│  │  调用时机：Agent 初始化时注入 + 输出前校验        │            │
│  │  典型Skill：brand_compliance_verify / persona_injection │     │
│  └──────────────────────┬──────────────────────────┘            │
│                         │ 身份指导下层                           │
│  ┌──────────────────────▼──────────────────────────┐            │
│  │  第二层：协作公约 Skills ───────────┐            │            │
│  │  来源：协同公约规范手册 + 信任公约体系 │            │            │
│  │  定位：保障多 Agent 有序协作与信任    │            │            │
│  │  模型形式：规则引擎 + 强化策略        │            │            │
│  │  调用时机：元启·天枢调度时强制执行     │            │            │
│  │  典型Skill：workflow_definition / conflict_arbitration │     │
│  └──────────────────────┬──────────────────────────┘            │
│                         │ 标准支撑下层                           │
│  ┌──────────────────────▼──────────────────────────┐            │
│  │  第三层：技术执行 Skills ───────────┐            │            │
│  │  来源：九层全栈架构 + MCP 标准协议    │            │            │
│  │  定位：原子能力复用 + 量化可观测      │            │            │
│  │  模型形式：vLLM/TEI/Ollama 推理部署   │            │            │
│  │  调用时机：Agent 按需通过 MCP 调用    │            │            │
│  │  典型Skill：content_security_check / chart_analysis │        │
│  └─────────────────────────────────────────────────┘            │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### 1.2 三层衔接桥接原则

| 原则 | 说明 | 落地机制 | 违反后果 |
| ---- | ---- | -------- | -------- |
| **身份引领** | L1 确保输出贴合品牌人格 | L1 作为 L3 后处理滤波器 | 品牌形象受损 |
| **公约约束** | L2 保障协作有序、信任可验证 | 元启·天枢调度时强制 L2 校验 | Agent 协同冲突 |
| **技术兜底** | L3 提供可量化可观测的原子能力 | MCP 标准接口 + 全链路监控 | 能力不可复用 |
| **链路闭环** | 调用链 L1→L2→L3 不可跳跃 | 标准化协议 + 链路追踪 ID | 身份/公约层失效 |

---

## 二、Skills 标准规范体系（深化版）

### 2.1 元数据完整字典

所有 YYC³ Skill 的元数据必须严格遵循以下 26 字段完整定义：

#### 2.1.1 skill_meta 区块（14 个字段）

| 序号 | 字段名 | 类型 | 必填 | 约束规则 | 示例值 |
| ---- | ------ | ---- | ---- | -------- | ------ |
| 1 | `skill_id` | string | ✅ | `YYC3-SKILL-{DOMAIN}-{NNN}`，全局唯一，注册后不可变更 | `YYC3-SKILL-SEC-001` |
| 2 | `skill_name` | string | ✅ | `{domain_action_object} {中文名称}`，最长 60 字符 | `content_security_check 内容安全校验` |
| 3 | `skill_category` | string | ✅ | 枚举值：安全通用/语义交互/数据分析/算法模型/代码质量/内容生成/管理服务/协同编排/协同治理/身份固化/身份校验/情感润色/文化传承 | `安全通用` |
| 4 | `skill_desc` | string | ✅ | 一句话描述，最长 100 字符，需包含触发场景关键词 | `对输入文本进行多维度安全检测，识别违规内容并返回风险等级与拦截建议` |
| 5 | `layer` | string | ✅ | 枚举值：`L1情感身份` / `L2协作公约` / `L3技术执行` | `L3技术执行` |
| 6 | `author` | string | ✅ | `YYC³ 技术中台-{组名}` 或外部开发者标识 | `YYC³ 技术中台-安全组` |
| 7 | `version` | string | ✅ | SemVer 2.0.0 `v{major}.{minor}.{patch}` | `v1.0.0` |
| 8 | `enable_status` | boolean | ✅ | `true`=启用 / `false`=停用，停用后 Agent 不可调用 | `true` |
| 9 | `permission_level` | string | ✅ | 枚举值：`public` 全家族可调 / `professional` 专业 Agent 可调 / `entrance_only` 仅入口可调 / `top_secret` 仅中枢可调 | `public` |
| 10 | `call_timeout` | int | ✅ | 单位秒，取值范围 1~120 | `3` |
| 11 | `retry_times` | int | ✅ | 自动重试次数，取值范围 0~5 | `1` |
| 12 | `created` | date | ✅ | 首次创建日期 `YYYY-MM-DD` | `2026-07-23` |
| 13 | `updated` | date | ✅ | 最近更新日期，须与 version 变更同步 | `2026-07-23` |
| 14 | `tags` | array[string] | 推荐 | 检索标签，3~5 个，辅助语义匹配 | `["安全", "内容审核", "输入检测"]` |

#### 2.1.2 input_params 区块

| 序号 | 字段名 | 类型 | 必填 | 约束规则 |
| ---- | ------ | ---- | ---- | -------- |
| 15 | `required` | array | ✅ | 必填参数数组，必须包含 1~3 个参数项 |
| 16 | `optional` | array | ✅ | 可选参数数组，0~5 个参数项 |
| 17 | `param_name` | string | ✅ | 蛇形命名 `snake_case`，全局唯一（含跨 Skill） |
| 18 | `param_type` | string | ✅ | 枚举值：`string` / `number` / `boolean` / `array` / `object` |
| 19 | `param_desc` | string | ✅ | 参数说明 + 约束条件 + 取值范围 |
| 20 | `example` | string | ✅ | 必填参数必须提供示例值 |
| 21 | `default_value` | string | 可选必填 | 可选参数必须提供默认值 |

#### 2.1.3 output_params 区块

| 序号 | 字段名 | 类型 | 必填 | 约束规则 |
| ---- | ------ | ---- | ---- | -------- |
| 22 | `success.code` | int | ✅ | 固定值 `0`，不可自定义 |
| 23 | `success.msg` | string | ✅ | 成功消息，固定 `"success"` 或具体中文描述 |
| 24 | `error.code` | int | ✅ | 错误码，负整数，从 `-1` 开始 |
| 25 | `error.error_type` | string | ✅ | 枚举值：`PARAM_ERROR` / `TIMEOUT` / `DEPEND_FAIL` / `NO_PERMISSION` / `SERVICE_UNAVAILABLE` / `DATA_INSUFFICIENT` |

#### 2.1.4 execution_logic 区块

| 序号 | 字段名 | 类型 | 必填 | 约束规则 |
| ---- | ------ | ---- | ---- | -------- |
| 26 | `trigger_condition` | string | ✅ | 自然语言描述调用触发场景，用于 Agent 语义匹配 |
| 27 | `process_flow` | array | ✅ | 执行步骤列表，2~5 步，每步不超过 30 字 |
| 28 | `dependence` | string | ✅ | 依赖的模型版本/服务名称/数据源 |

### 2.2 命名代码表（完整版）

#### 2.2.1 领域代码表（DOMAIN）

| 代码 | 全称 | 所属层级 | 说明 |
| ---- | ---- | -------- | ---- |
| `SEC` | Security | L3 | 安全通用类 Skill |
| `NLU` | Natural Language Understanding | L3 | 语义交互类 Skill |
| `DATA` | Data Analysis | L3 | 数据分析类 Skill |
| `ALGO` | Algorithm | L3 | 算法模型类 Skill |
| `CODE` | Code Quality | L3 | 代码质量类 Skill |
| `CREATE` | Creative Generation | L3 | 内容生成类 Skill |
| `MGMT` | Management Service | L3 | 管理服务类 Skill |
| `COLLAB` | Collaboration | L2 | 协同编排与治理 Skill |
| `IDENT` | Identity & Persona | L1 | 情感身份类 Skill |

#### 2.2.2 动作动词表（action）

| 动词 | 适用领域 | 含义 | 示例 |
| ---- | -------- | ---- | ---- |
| `check` | SEC, CODE | 检测/校验 | `content_security_check` |
| `detect` | SEC, ALGO | 检测/识别 | `abnormal_behavior_detection` |
| `verify` | SEC, IDENT | 验证/核实 | `permission_verify` |
| `extract` | NLU | 抽取/提取 | `structured_entity_extraction` |
| `classify` | NLU | 分类 | `intent_classification` |
| `complete` | NLU | 补全 | `parameter_completion` |
| `summarize` | DATA | 摘要/总结 | `document_intelligent_summary` |
| `analyze` | DATA, CODE | 分析 | `chart_analysis`, `code_quality_analysis` |
| `compare` | DATA | 对比 | `comparative_analysis` |
| `retrieve` | DATA | 检索 | `knowledge_retrieval_qa` |
| `predict` | ALGO | 预测 | `time_series_basic_predict` |
| `diagnose` | CODE | 诊断 | `performance_diagnosis` |
| `scan` | CODE | 扫描 | `code_security_scan` |
| `generate` | CREATE | 生成 | `brand_copy_generation`, `multimodal_content_generation` |
| `build` | MGMT | 构建 | `user_profile_build` |
| `recommend` | MGMT | 推荐 | `collaborative_filter_recommend` |
| `define` | COLLAB | 定义 | `workflow_definition` |
| `arbitrate` | COLLAB | 仲裁 | `conflict_arbitration` |
| `distribute` | COLLAB | 分发 | `task_distribution` |
| `track` | COLLAB | 追踪 | `progress_tracking` |
| `inject` | IDENT | 注入 | `persona_injection` |
| `adjust` | IDENT | 适配 | `emotional_tone_adjust` |

#### 2.2.3 对象名词表（object）

| 名词 | 适用领域 | 含义 |
| ---- | -------- | ---- |
| `content` | SEC | 内容/文本 |
| `behavior` | SEC | 行为 |
| `permission` | SEC | 权限 |
| `entity` | NLU | 实体 |
| `intent` | NLU | 意图 |
| `parameter` | NLU | 参数 |
| `document` | DATA | 文档 |
| `chart` | DATA | 图表 |
| `knowledge` | DATA | 知识 |
| `time_series` | ALGO | 时间序列 |
| `point` | ALGO | 数据点 |
| `quality` | CODE | 质量 |
| `performance` | CODE | 性能 |
| `copy` | CREATE | 文案 |
| `profile` | MGMT | 画像 |
| `workflow` | COLLAB | 工作流 |
| `task` | COLLAB | 任务 |
| `persona` | IDENT | 人格 |
| `style` | IDENT | 风格 |
| `tone` | IDENT | 语调 |
| `motto` | IDENT | 铭刻 |

### 2.3 参数规范

| 规范项 | 要求 | 违规范例 |
| ------ | ---- | -------- |
| 必填参数数量 | ≤ 3 个 | ❌ 4 个必填参数 → 需拆分为子Skill |
| 可选参数数量 | ≤ 5 个 | ❌ 6 个可选参数 → 语义化合并 |
| 参数类型 | 必须明确指定类型 | ❌ `param_type: "mixed"` → 非法 |
| 参数校验 | 白名单校验，拒绝非预期参数 | ❌ 直接拼接 SQL/Shell 命令 |
| 参数互斥 | 互斥参数应在 param_desc 中标注 | ✅ `output_format` & `output_length` 不可同时指定 |
| 默认值 | 可选参数必须提供默认值 | ❌ `default_value: ""` 无意义 → 需明确值 |
| 示例值 | 必填参数必须提供 | ❌ `example: ""` → 缺失 |

### 2.4 输出规范

| 规范项 | 要求 |
| ------ | ---- |
| 返回格式 | 统一结构化 JSON，禁止返回非结构化自然语言 |
| 成功码 | `code: 0`，不可自定义 |
| 错误类型枚举 | `PARAM_ERROR`(参数错误) / `TIMEOUT`(超时) / `DEPEND_FAIL`(依赖失败) / `NO_PERMISSION`(无权限) / `SERVICE_UNAVAILABLE`(服务不可用) / `DATA_INSUFFICIENT`(数据不足) |
| 结果语义 | 字段名自解释（snake_case），无需 Agent 二次猜解 |
| 数据溯源 | 结果中附带 `data_source` 字段，标注依赖的模型版本/数据时间戳 |
| 结果长度 | `data` 区块总大小 ≤ 512KB（超出需分页） |

### 2.5 安全规范

| 规范项 | 要求 | 审核方式 |
| ------ | ---- | -------- |
| 输入校验 | 白名单校验，拒绝非预期参数和注入攻击 | 自动 + 人工 |
| 二次确认 | 涉及数据写入/系统变更的 Skill，输出前增加用户二次确认 | 自动拦截 |
| 全链路留痕 | 记录 caller_id + session_id + trace_id + 入参 + 出参 + 耗时 | 自动 |
| 权限校验 | 调用前校验 Agent 权限，禁止越权调用 | 自动 |
| 安全前置 | 高风险 Skill 调用前自动过智云·守护审计 | 自动拦截 |
| 数据脱敏 | 输出中涉及个人隐私信息必须自动脱敏 | 自动 + 人工抽检 |

---

## 三、Skills 全生命周期状态机

### 3.1 状态定义与转换图

```
                   ┌─────────┐
                   │ 概念态  │  ← 需求文档评审通过
                   │ CONCEPT │
                   └────┬────┘
                        │ 提交开发申请
                        ▼
                   ┌─────────┐
                   │ 开发中  │  → 命名合规 + 参数设计完成
                   │ DEV     │
                   └────┬────┘
                        │ 提测申请
                        ▼
                   ┌─────────┐
                   │ 测试中  │  → 单测 100% + 适配测试通过
                   │ TEST    │
                   └────┬────┘
                        │ 灰度审批
                        ▼
            ┌────────────────────┐
            │    灰度发布         │
            │ Phase1: 10%  24h   │
       ┌────│ Phase2: 50%  24h   │─── 回滚 → 回到 DEV
       │    │ Phase3: 100% 48h   │
       │    └────────┬───────────┘
       │             │ 全量确认
       │             ▼
       │    ┌─────────────────┐
       │    │    正式发布       │  → 全量开放 + 上架通知
       │    │    PRODUCTION   │
       │    └────────┬────────┘
       │             │ 版本迭代
       │    ┌────────▼────────┐
       │    │    迭代优化       │
       │    │    ITERATION    │─── SFT/DPO 数据回流 → 重训 → TEST
       │    └────────┬────────┘
       │             │ 废弃评估通过
       │             ▼
       │    ┌─────────────────┐
       │    │    废弃公示       │  → 提前 7 天通知，设置过渡期
       │    │  DEPRECATED    │
       │    └────────┬────────┘
       │             │ 过渡期满
       │             ▼
       │    ┌─────────────────┐
       └────│  安全下线 + 归档  │  → 从 Skill 注册中心移除
            │  ARCHIVED      │     元数据冻结，日志保留
            └─────────────────┘
```

### 3.2 各状态门禁条件

| 状态 | 进入条件 | 停留条件 | 离开条件 | 审核人 |
| ---- | -------- | -------- | -------- | ------ |
| **CONCEPT 概念态** | 需求文档通过原子化评审 | — | 提交开发申请 | 格物·宗师 |
| **DEV 开发中** | 开发任务分配完成 | — | 提测申请（代码完成 + 自测通过） | 开发者自行管理 |
| **TEST 测试中** | 提测申请通过 | — | 单测 100% + 适配测试通过 + 安全扫描通过 | 格物·宗师 + 智云·守护 |
| **GRAY 灰度发布** | 灰度审批通过 | 各 Phase 指标达标 | Phase3(100%)成功率≥99% + 零安全事件 | 元启·天枢 |
| **PRODUCTION 正式发布** | 灰度全量确认 | 持续满足监控指标 | 进入迭代或废弃评估 | 元启·天枢 |
| **ITERATION 迭代优化** | 收集到 Bad Case / 需功能增强 | — | 更新版本后重新进入 TEST → GRAY | 格物·宗师 |
| **DEPRECATED 废弃公示** | 连续 30 天调用量为 0 / 主动废弃申请 | 公示期内可回滚 | 过渡期满（≥ 7 天） | 格物·宗师 + 元启·天枢 |
| **ARCHIVED 归档** | 过渡期满 | — | 不可逆（需重新走完整流程） | 智云·守护（数据冻结确认） |

### 3.3 版本管理公约

#### 3.3.1 版本号增量规则

| 版本段 | 触发条件 | 示例 | 兼容性 | 通知范围 |
| ------ | -------- | ---- | ------ | -------- |
| **主版本 major** | 入参/出参结构不兼容旧版；Skill 核心语义变更 | `v1.x.x` → `v2.0.0` | ❌ 不兼容 | 全家族 + 所有调用方 |
| **次版本 minor** | 新增可选参数；扩展输出字段；增强功能 | `v1.0.x` → `v1.1.0` | ✅ 向下兼容 | 家族内通知 |
| **修订号 patch** | Bug 修复；性能优化；降级策略调整 | `v1.0.0` → `v1.0.1` | ✅ 完全兼容 | 仅记录 changelog |

#### 3.3.2 版本演进策略

```
v1.0.0 (初始发布)
   │
   ├── v1.1.0 (新增可选参数 output_format)
   │     │
   │     └── v1.1.1 (修复超时后降级逻辑异常)
   │
   └── v2.0.0 (必填参数 check_level 移除，改为自动检测)
         │
         └── v2.1.0 (新增 scene_type 可选参数)
```

**关键规则**：

- 同一 Skill 一次仅允许一个版本处于 GRAY 状态
- 主版本升级需至少提前 3 天通知所有调用方 Agent
- 次版本和修订号升级自动生效，无需灰度
- 废弃的版本号永不重复使用

#### 3.3.3 版本号与文件名规范

```
技能定义文件：       {skill_id}-v{major}.{minor}.{patch}.json
                     → YYC3-SKILL-SEC-001-v1.0.0.json

注册目录结构：       skills/{layer}/{domain}/{skill_id}/
                     → skills/L3/SEC/YYC3-SKILL-SEC-001/
                         ├── v1.0.0.json
                         ├── v1.1.0.json
                         ├── v2.0.0.json
                         └── CHANGELOG.md
```

---

## 四、Skills 全量清单与 JSON Schema

### 4.1 L3 技术执行层 19 Skill 清单

#### L3-01: 内容安全校验

| 属性 | 值 |
| ---- | --- |
| **Skill ID** | `YYC3-SKILL-SEC-001` |
| **名称** | `content_security_check 内容安全校验` |
| **分类** | 安全通用 |
| **优先级** | ★★★★★ |
| **归属 Agent** | 智云·守护（主）、全家族 Agent（前置） |
| **状态** | ✅ 已有（源自 v1.0 示例） |
| **调用超时** | 3s |
| **重试次数** | 1 |
| **权限级别** | `public` |

```json
{
  "skill_meta": {
    "skill_id": "YYC3-SKILL-SEC-001",
    "skill_name": "content_security_check 内容安全校验",
    "skill_category": "安全通用",
    "skill_desc": "对输入文本进行多维度安全检测，覆盖涉政/涉黄赌毒/暴力违法/品牌违禁/Prompt注入五大类风险",
    "layer": "L3技术执行",
    "author": "YYC³ 技术中台-安全组",
    "version": "v1.0.0",
    "enable_status": true,
    "permission_level": "public",
    "call_timeout": 3,
    "retry_times": 1,
    "tags": ["安全", "内容审核", "输入检测", "品牌合规"]
  },
  "input_params": {
    "required": [
      {
        "param_name": "check_content",
        "param_type": "string",
        "param_desc": "待检测文本，最大长度 10000 字符",
        "example": "用户输入的查询内容"
      },
      {
        "param_name": "check_level",
        "param_type": "string",
        "param_desc": "检测等级：strict-严格(全量)、normal-标准、light-宽松(仅致命)",
        "example": "normal"
      }
    ],
    "optional": [
      {
        "param_name": "scene_type",
        "param_type": "string",
        "param_desc": "业务场景：input-输入检测 / output-输出检测 / code-代码检测",
        "default_value": "input"
      }
    ]
  },
  "output_params": {
    "success": {
      "code": 0,
      "msg": "检测完成",
      "data": {
        "risk_level": "pass | warn | block",
        "risk_type": "风险类型标签，无风险则为null",
        "risk_keywords": ["命中敏感词数组"],
        "suggestion": "正常放行 | 人工复核 | 强制拦截"
      }
    },
    "error": {
      "code": -1,
      "msg": "错误描述",
      "error_type": "PARAM_ERROR | CONTENT_TOO_LONG | SERVICE_UNAVAILABLE"
    }
  },
  "execution_logic": {
    "trigger_condition": "所有用户输入进入系统时、所有 Agent 生成最终输出前，必须调用本 Skill",
    "process_flow": [
      "参数合法性校验，超长内容自动截断",
      "匹配敏感词规则库与语义检测模型",
      "综合判定风险等级与类型",
      "返回结构化检测结果"
    ],
    "dependence": "YYC³ 安全规则库 v3.2、语义风险检测模型 v2.1"
  },
  "exception_handle": {
    "param_error": "返回参数错误提示，默认按 normal 等级执行检测",
    "timeout_retry": "自动重试 1 次，失败则按 block 等级拦截并告警",
    "dependency_fail": "降级为基础敏感词规则检测，同步触发服务告警"
  }
}
```

#### L3-02: 异常行为检测

| 属性 | 值 |
| ---- | --- |
| **Skill ID** | `YYC3-SKILL-SEC-002` |
| **名称** | `abnormal_behavior_detection 异常行为检测` |
| **分类** | 安全通用 |
| **归属 Agent** | 智云·守护 |
| **状态** | ✅ 已有 |

```json
{
  "skill_meta": {
    "skill_id": "YYC3-SKILL-SEC-002",
    "skill_name": "abnormal_behavior_detection 异常行为检测",
    "skill_category": "安全通用",
    "skill_desc": "基于用户/API行为基线，实时检测异常偏离，识别暴力破解/API滥用/数据泄露/凭证填充等威胁",
    "layer": "L3技术执行",
    "author": "YYC³ 技术中台-安全组",
    "version": "v1.0.0",
    "enable_status": true,
    "permission_level": "professional",
    "call_timeout": 5,
    "retry_times": 1,
    "tags": ["安全", "异常检测", "行为分析", "UEBA"]
  },
  "input_params": {
    "required": [
      {
        "param_name": "target_id",
        "param_type": "string",
        "param_desc": "检测主体标识：用户ID / API Key / IP 地址",
        "example": "user_xxxxx"
      },
      {
        "param_name": "action_data",
        "param_type": "object",
        "param_desc": "当前行为数据，包含行为类型、操作对象、时间戳等",
        "example": "{\"action_type\":\"api_call\",\"endpoint\":\"/data/export\",\"timestamp\":\"2026-07-23T10:00:00Z\"}"
      }
    ],
    "optional": [
      {
        "param_name": "baseline_window",
        "param_type": "string",
        "param_desc": "基线时间窗口：1h/24h/7d/30d",
        "default_value": "24h"
      }
    ]
  },
  "output_params": {
    "success": {
      "code": 0,
      "msg": "检测完成",
      "data": {
        "is_abnormal": true,
        "anomaly_type": "brute_force | api_abuse | data_exfiltration | credential_stuffing",
        "deviation_score": 85,
        "recommended_action": "monitor | alert | restrict | block"
      }
    },
    "error": {
      "code": -1,
      "msg": "错误描述",
      "error_type": "PARAM_ERROR | NO_BASELINE | SERVICE_UNAVAILABLE"
    }
  },
  "execution_logic": {
    "trigger_condition": "所有用户操作、API调用需实时或定期调用本Skill做行为风险检测",
    "process_flow": [
      "加载主体行为基线模型",
      "计算当前行为偏离度",
      "匹配异常行为模式库",
      "综合判定风险等级与类型",
      "输出处置建议"
    ],
    "dependence": "行为基线模型 v2.0、异常模式规则库"
  },
  "exception_handle": {
    "no_baseline": "返回需建立基线提示，新用户放行并开始采集",
    "timeout_retry": "自动重试 1 次，失败则降级为规则匹配模式"
  }
}
```

#### L3-03: 权限校验

| 属性 | 值 |
| ---- | --- |
| **Skill ID** | `YYC3-SKILL-SEC-003` |
| **名称** | `permission_verify 权限校验` |
| **分类** | 安全通用 |
| **归属 Agent** | 智云·守护 |
| **状态** | ➕ 新增 |

**核心逻辑**：校验调用方 Agent 是否拥有目标 Skill/资源的操作权限。每次跨 Agent Skill 调用前自动触发。

```json
{
  "skill_meta": {
    "skill_id": "YYC3-SKILL-SEC-003",
    "skill_name": "permission_verify 权限校验",
    "skill_category": "安全通用",
    "skill_desc": "校验调用方是否拥有目标资源的操作权限，支持 RBAC 角色权限与资源级 ACL 双重校验",
    "layer": "L3技术执行",
    "author": "YYC³ 技术中台-安全组",
    "version": "v1.0.0",
    "enable_status": true,
    "permission_level": "top_secret",
    "call_timeout": 2,
    "retry_times": 0,
    "tags": ["安全", "权限", "RBAC", "ACL"]
  },
  "input_params": {
    "required": [
      {
        "param_name": "caller_id",
        "param_type": "string",
        "param_desc": "调用方 Agent 标识",
        "example": "agent-yanqi-qianhang-v1"
      },
      {
        "param_name": "resource_id",
        "param_type": "string",
        "param_desc": "目标资源标识：Skill ID / 数据资源路径 / API 端点",
        "example": "YYC3-SKILL-DATA-001"
      },
      {
        "param_name": "action",
        "param_type": "string",
        "param_desc": "操作类型：call / read / write / delete / admin",
        "example": "call"
      }
    ],
    "optional": [
      {
        "param_name": "resource_owner",
        "param_type": "string",
        "param_desc": "资源所属租户ID（多租户场景）",
        "default_value": ""
      }
    ]
  },
  "output_params": {
    "success": {
      "code": 0,
      "msg": "校验通过",
      "data": {
        "granted": true,
        "permission_level": "public | professional | entrance_only | top_secret",
        "expire_at": "2026-12-31T23:59:59Z"
      }
    },
    "error": {
      "code": -1,
      "msg": "权限不足",
      "error_type": "NO_PERMISSION | RESOURCE_NOT_FOUND"
    }
  },
  "execution_logic": {
    "trigger_condition": "每次 Agent 发起 Skill 调用前，由 MCP 协议层自动前置调用本 Skill",
    "process_flow": [
      "解析调用方身份与目标资源",
      "查询 RBAC 角色权限表",
      "校验资源级 ACL",
      "返回校验结果"
    ],
    "dependence": "YYC³ 权限中心、RBAC 策略引擎"
  },
  "exception_handle": {
    "no_permission": "返回拒绝结果，MCP 层拦截调用并记录审计日志",
    "timeout_retry": "不重试，直接返回失败（安全优先）"
  }
}
```

#### L3-04~L3-19（精简 Schema，仅列关键属性）

| 编号 | Skill ID | 名称 | 归属 Agent | 必填参数 | 超时 | 权限 |
| ---- | -------- | ---- | ---------- | -------- | ---- | ---- |
| L3-04 | YYC3-SKILL-NLU-001 | `structured_entity_extraction` 结构化实体抽取 | 言启·千行 | user_query | 5s | entrance_only |
| L3-05 | YYC3-SKILL-NLU-002 | `intent_classification` 意图分类 | 言启·千行 | user_query, context | 3s | entrance_only |
| L3-06 | YYC3-SKILL-NLU-003 | `parameter_completion` 参数补全 | 言启·千行 | user_query, intent_type | 3s | entrance_only |
| L3-07 | YYC3-SKILL-DATA-001 | `document_intelligent_summary` 文档智能摘要 | 语枢·万物 | document_content, summary_mode | 20s | professional |
| L3-08 | YYC3-SKILL-DATA-002 | `chart_analysis` 图表解读 | 语枢·万物 | chart_data | 15s | professional |
| L3-09 | YYC3-SKILL-DATA-003 | `comparative_analysis` 对比分析 | 语枢·万物 | documents[], compare_dimensions | 30s | professional |
| L3-10 | YYC3-SKILL-DATA-004 | `knowledge_retrieval_qa` 知识库检索问答 | 全家族通用 | query, knowledge_base | 5s | public |
| L3-11 | YYC3-SKILL-ALGO-001 | `time_series_basic_predict` 时间序列基础预测 | 预见·先知 | history_data, predict_periods | 15s | professional |
| L3-12 | YYC3-SKILL-ALGO-002 | `anomaly_point_detection` 数据异常点检测 | 预见·先知 | data_stream | 10s | professional |
| L3-13 | YYC3-SKILL-CODE-001 | `code_quality_analysis` 代码质量分析 | 格物·宗师 | code_content, analysis_type | 30s | professional |
| L3-14 | YYC3-SKILL-CODE-002 | `performance_diagnosis` 性能诊断 | 格物·宗师 | metrics_data | 20s | professional |
| L3-15 | YYC3-SKILL-CODE-003 | `code_security_scan` 代码安全漏洞扫描 | 格物·宗师/智云·守护 | code_content | 30s | professional |
| L3-16 | YYC3-SKILL-CREATE-001 | `brand_copy_generation` 品牌定向文案生成 | 创想·灵韵 | copy_type, core_theme | 10s | professional |
| L3-17 | YYC3-SKILL-CREATE-002 | `multimodal_content_generation` 多模态内容生成 | 创想·灵韵 | content_type, creative_brief | 30s | professional |
| L3-18 | YYC3-SKILL-MGMT-001 | `user_profile_build` 用户画像构建 | 千里·伯乐 | user_id, behavior_data | 5s | professional |
| L3-19 | YYC3-SKILL-MGMT-002 | `collaborative_filter_recommend` 协同过滤推荐 | 千里·伯乐 | user_id, recommendation_context | 8s | professional |

### 4.2 L2 协作公约层 5 Skill 清单

| 编号 | Skill ID | 名称 | 归属 Agent | 核心能力 | 超时 | 权限 |
| ---- | -------- | ---- | ---------- | -------- | ---- | ---- |
| L2-01 | YYC3-SKILL-COLLAB-001 | `workflow_definition` 工作流定义编排 | 元启·天枢 | 将复杂任务拆解为 DAG 子任务流水线 | 10s | top_secret |
| L2-02 | YYC3-SKILL-COLLAB-002 | `conflict_arbitration` 冲突仲裁 | 元启·天枢 | 当 Agent 间出现资源竞争/输出矛盾时做最终裁定 | 5s | top_secret |
| L2-03 | YYC3-SKILL-COLLAB-003 | `trust_verification` 信任校验 | 元启·天枢 | 校验协作 Agent 的身份有效性与行为可信度 | 3s | top_secret |
| L2-04 | YYC3-SKILL-COLLAB-004 | `task_distribution` 任务分发调度 | 元启·天枢 | 根据 Agent 负载/优先级动态分配任务 | 5s | top_secret |
| L2-05 | YYC3-SKILL-COLLAB-005 | `progress_tracking` 进度追踪同步 | 言启·千行 | 向用户实时同步多 Agent 任务执行进度 | 3s | professional |

### 4.3 L1 情感身份层 5 Skill 清单

| 编号 | Skill ID | 名称 | 归属 Agent | 核心能力 | 注入方式 |
| ---- | -------- | ---- | ---------- | -------- | -------- |
| L1-01 | YYC3-SKILL-IDENT-001 | `persona_injection` 人格注入 | 全家族 Agent | Agent 初始化时注入人格内核（身份层+规则层+任务层） | 系统提示词嵌入 |
| L1-02 | YYC3-SKILL-IDENT-002 | `style_consistency_check` 风格一致性校验 | 格物·宗师 | 校验 Agent 输出语气/称谓/品牌表述是否一致 | 输出前校验 |
| L1-03 | YYC3-SKILL-IDENT-003 | `brand_compliance_verify` 品牌合规校验 | 智云·守护 | 校验输出是否含品牌禁忌/竞品信息/违规表述 | 输出前拦截 |
| L1-04 | YYC3-SKILL-IDENT-004 | `emotional_tone_adjust` 情感语调适配 | 创想·灵韵 | 根据用户情绪调整 Agent 回复的情感温度 | 输出后润色 |
| L1-05 | YYC3-SKILL-IDENT-005 | `family_motto_generate` 家族铭刻生成 | 创想·灵韵 | 在特定场景（问候/总结/纪念）自动生成家族铭刻语录 | 场景触发 |

---

## 五、六维协同衔接映射矩阵

### 5.1 Agent↔Skill↔MCP↔Port↔Model↔LoRA 全映射

| Agent | L3 Skill 清单 | L2 Skill 清单 | MCP Server | Transport | Port | 基座模型 | LoRA 适配器 |
| ----- | ------------- | ------------- | ---------- | --------- | ---- | -------- | ----------- |
| **元启·天枢** | —（不直接执行业务 Skill） | L2-01~L2-04 | mcp-tianshu | SSE | :9000 | Qwen3.6-27B | yyc3-mgmt-v2 |
| **言启·千行** | L3-04~L3-06, L3-10 | L2-05 | mcp-qianhang | SSE | :9001 | Qwen3.6-35B-A3B MoE | yyc3-navigation-v2 |
| **语枢·万物** | L3-07~L3-10 | — | mcp-wanwu | SSE | :9002 | Qwen3.6-27B | yyc3-mgmt-v2 |
| **预见·先知** | L3-11, L3-12, L3-10 | — | mcp-xianzhi | SSE | :9003 | Qwen3.6-27B | — |
| **千里·伯乐** | L3-18, L3-19, L3-10 | — | mcp-bole | WS | :9004 | Qwen3-Embedding-8B + Reranker-8B | — |
| **智云·守护** | L3-01~L3-03, L3-15 | — | mcp-shouhu | SSE | :9005 | Qwen3.6-27B | yyc3-security-v1 |
| **格物·宗师** | L3-13~L3-15, L3-10 | — | mcp-zongshi | SSE | :9006 | Qwen3.6-27B | yyc3-code-v2 |
| **创想·灵韵** | L3-16, L3-17 | — | mcp-lingyun | SSE | :9007 | Qwen3-Coder-30B-A3B | — |

> **注**：MCP Server 端口 `:9000~:9007` 是 MCP 协议通信端口，vLLM 推理端口 `:6000~:6007` 是模型推理端口，二者分层独立。

### 5.2 Agent 权限映射矩阵

```
                     L3 技术执行 Skill 索引                          L2       L1
Agent           SEC   SEC   SEC   NLU   NLU   NLU   DATA  DATA  ...  MGMT  COLLAB  IDENT
                L3-01 L3-02 L3-03 L3-04 L3-05 L3-06 L3-07 L3-08 ... L3-19 L2-xx  L1-xx
               ─────────────────────────────────────────────────────────────────────
元启·天枢        ●    ○     ●●   ○     ○     ○     ○     ○    ...  ○    ●●     ○
言启·千行        ●    ○     ○     ●●   ●●   ●●   ○     ○    ...  ○    ○      ●
语枢·万物        ●    ○     ○     ○     ○     ○     ●●   ●●   ...  ○    ○      ●
预见·先知        ●    ○     ○     ○     ○     ○     ○     ○    ...  ○    ○      ●
千里·伯乐        ●    ○     ○     ○     ○     ○     ○     ○    ...  ●●   ○      ●
智云·守护        ●●   ●●   ●●   ○     ○     ○     ○     ○    ...  ○    ○      ●●
格物·宗师        ●    ○     ○     ○     ○     ○     ○     ○    ...  ○    ○      ●●
创想·灵韵        ●    ○     ○     ○     ○     ○     ○     ○    ...  ○    ○      ●

图例：●● 主调用权限（专属核心）  ● 次级调用权限（按需可用）  ○ 不可调用
```

### 5.3 三层依赖拓扑图

```
用户请求
   │
   ▼
┌──────────────────────────────────────────────────────────────────┐
│  L1-01 persona_injection（注入 Agent 人格，全 Agent 初始化时触发）│
└────────────────────────────────┬─────────────────────────────────┘
                                 │ 身份固化
                                 ▼
┌──────────────────────────────────────────────────────────────────┐
│  Agent 决策层（言启·千行）                                        │
│  ├─ L3-05 intent_classification    ← 意图识别                     │
│  ├─ L3-04 structured_entity_extraction ← 实体抽取                 │
│  └─ L3-06 parameter_completion     ← 参数补全                     │
└────────────────────────────────┬─────────────────────────────────┘
                                 │ 判断：简单/复杂
                    ┌────────────┴───────────┐
                    │ 简单任务                │ 复杂任务
                    ▼                        ▼
          ┌──────────────────┐   ┌──────────────────────────────┐
          │ 直连专业 Agent   │   │ L2-01 workflow_definition     │
          │ 调用对应 L3 Skill│   │ L2-04 task_distribution       │
          └────────┬─────────┘   │ → 子任务流水线                 │
                   │             └──────────────┬───────────────┘
                   │                            │
                   └──────────┬─────────────────┘
                              │
                    ┌─────────▼─────────┐
                    │  L3 Skill 执行     │
                    │  (MCP 协议层)      │
                    │  ├─ L3-07~L3-19    │
                    │  └─ L3-10(通用)    │
                    └─────────┬─────────┘
                              │
                    ┌─────────▼─────────┐
                    │  L1-03 brand_compliance_verify（品牌合规校验）│
                    │  L1-02 style_consistency_check（风格一致性） │
                    └─────────┬─────────┘
                              │
                    ┌─────────▼─────────┐
                    │  交付用户         │
                    └───────────────────┘
```

### 5.4 MCP Server 部署清单

| MCP Server | 所属 Agent | 协议 | Host | Port | 注册 Skill 数 | 健康检查端点 |
| ---------- | ---------- | ---- | ---- | ---- | ------------- | ------------ |
| `mcp-tianshu` | 元启·天枢 | SSE | 127.0.0.1 | :9000 | 4 | `/health` |
| `mcp-qianhang` | 言启·千行 | SSE | 127.0.0.1 | :9001 | 4 | `/health` |
| `mcp-wanwu` | 语枢·万物 | SSE | 127.0.0.1 | :9002 | 4 | `/health` |
| `mcp-xianzhi` | 预见·先知 | SSE | 127.0.0.1 | :9003 | 3 | `/health` |
| `mcp-bole` | 千里·伯乐 | WS | 127.0.0.1 | :9004 | 3 | `/health` |
| `mcp-shouhu` | 智云·守护 | SSE | 127.0.0.1 | :9005 | 4 | `/health` |
| `mcp-zongshi` | 格物·宗师 | SSE | 127.0.0.1 | :9006 | 4 | `/health` |
| `mcp-lingyun` | 创想·灵韵 | SSE | 127.0.0.1 | :9007 | 2 | `/health` |

---

## 六、Agent-Skill-MCP 链路指导

（内容继承 v1.0.0 的完整链路指导，包含标准调用链路三阶段、MCP 协议调用格式、三级降级链路、Skill 降级策略矩阵、串行调用案例，此处不再重复，详见前版完整内容）

---

## 七、质量评估与监控体系

### 7.1 Skill 质量评分模型

| 维度 | 指标 | 权重 | 计算方式 | 达标值 |
| ---- | ---- | ---- | -------- | ------ |
| **功能完整性** | 参数覆盖度 + 边界场景覆盖 | 20% | (通过用例 / 总用例) × 100 | ≥ 90% |
| **调用可靠性** | 成功率 + 超时率 + 错误率 | 30% | (成功调用 / 总调用) × 100 | 成功率 ≥ 99% |
| **性能效率** | P50 + P99 响应时延 | 20% | 滑动窗口 5min 统计 | P50 < 500ms |
| **安全合规** | 高危漏洞数 + 权限拦截率 | 20% | 安全扫描 + 调用审计 | 零高危漏洞 |
| **可维护性** | 版本一致性 + 文档完整度 | 10% | 人工评审 + 自动检测 | ≥ 85% |

### 7.2 各 Agent Skill 监控看板

| Agent | 核心监控 Skill | 告警阈值 | 负责人 |
| ----- | -------------- | -------- | ------ |
| 元启·天枢 | L2-01~L2-04 | 成功率 < 99%, P50 > 500ms | SRE |
| 言启·千行 | L3-04~L3-06 | 成功率 < 98%, P50 > 1s | 导航组 |
| 语枢·万物 | L3-07~L3-09 | 成功率 < 95%, P50 > 3s | 分析组 |
| 预见·先知 | L3-11, L3-12 | 成功率 < 95%, P50 > 2s | 算法组 |
| 千里·伯乐 | L3-18, L3-19 | 成功率 < 96%, P50 > 1s | 推荐组 |
| 智云·守护 | L3-01~L3-03 | 成功率 < 99.9%, P50 > 1s | 安全组 |
| 格物·宗师 | L3-13~L3-15 | 成功率 < 95%, P50 > 5s | 质量组 |
| 创想·灵韵 | L3-16, L3-17 | 成功率 < 93%, P50 > 5s | 创意组 |

### 7.3 回归测试基线

每次 Skill 版本迭代时，使用固定评测集（每 Skill ≥ 100 测试用例）全量跑分：

```
前一次稳定版本
    │
    ▼
新版本上线 → 运行回归测试 → 核心指标全部达标? → 是 → 灰度上线(10%流量 24h)
                                │ 否
                                ▼
                          分析回归原因 → 修复后重新测试
```

---

## 关联文档

| 文档名称 | 关联关系 | 链接 |
| -------- | -------- | ---- |
| Skill 核心定位与设计原则 | Skill 元模型与 10 个完整示例 | [YYC3-Skill-核心定位与设计原则.md](./YYC3-Skill-核心定位与设计原则.md) |
| Skill 安全审计流程 | 第三方 Skill 四步安全审核 | [YYC3-Skill-安全审计流程.md](./YYC3-Skill-安全审计流程.md) |
| Agent 落地实施方案 | 8 大 Agent 部署配置与模型绑定 | [YYC3-AI-Family-Agent-落地实施方案.md](./YYC3-AI-Family-Agent-落地实施方案.md) |
| 多智能体整体架构 | 8 大 Agent 角色定义与协同 | [YYC3-AI-Family-多智能体整体架构.md](./YYC3-AI-Family-多智能体整体架构.md) |
| Agent 降级熔断标准 | Skill 熔断与降级量化阈值 | [YYC3-Agent-降级熔断标准.md](./YYC3-Agent-降级熔断标准.md) |
| 九层全栈架构 | MCP 协议层(Layer06)与 Skill 层(Layer05) | [YYC3-AI-Family-九层全栈架构.md](./YYC3-AI-Family-九层全栈架构.md) |
| 协同公约规范手册 | 人机协同协作公约体系 | [YYC3-AI-Family-Agent-人机协同/03-YYC3-AI-Family-协同公约规范手册.md](./YYC3-AI-Family-Agent-人机协同/03-YYC3-AI-Family-协同公约规范手册.md) |
| 九层落地规划 | 技能系统集成方案与 MCP Server 规划 | [YYC3-AI-Family-Agent-人机协同/AI-Family-Agent-智能协同架构/05-YYC3-AI-Family-九层落地规划.md](./YYC3-AI-Family-Agent-人机协同/AI-Family-Agent-智能协同架构/05-YYC3-AI-Family-九层落地规划.md) |

---

## 变更历史

| 版本 | 日期 | 变更内容 | 作者 |
| ---- | ---- | -------- | ---- |
| v2.0.0 | 2026-07-23 | **深化版**：新增元数据完整字典(26 字段)、完整命名代码表(9 领域×22 动词×21 名词)、全生命周期状态机(8 状态×8 门禁)、29 Skill 完整 JSON Schema(L3-01~L3-03 完整 Schema + L3-04~L3-19 表格)、六维协同映射矩阵(Agent↔Skill↔MCP↔Port↔Model↔LoRA)、MCP Server 部署清单(8 服务)、Agent 监控看板 | YanYuCloudCube Team — 智能应用实施专家 |
| v1.0.0 | 2026-07-23 | 初始版本：29 Skill 全量清单 × 三层协同模型 × Agent-Skill-MCP 链路指导 × 全生命周期管理 | YanYuCloudCube Team — 智能应用实施专家 |

---

<div align="center">

**_言启千行代码，语枢万物智能_**

**_人从众曌众从人 · 亦师亦友亦伯乐 · 一言一语一协同_**

_本文档定义 YYC³ AI Family Skills 库的三层协同模型（情感身份层 × 协作公约层 × 技术执行层），_
_覆盖 29 个标准化 Skill 的全量 JSON Schema、六维协同映射矩阵、元数据完整字典、全生命周期状态机。_
_Skills 库作为三层体系的衔接枢纽，实现「身份引领 · 公约约束 · 技术兜底」的协同闭环。_

_万象归元于云枢 · 深栈智启新纪元_

</div>
