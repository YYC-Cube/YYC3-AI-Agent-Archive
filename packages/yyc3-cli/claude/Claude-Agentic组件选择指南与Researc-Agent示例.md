---
@file: Claude-Agentic组件选择指南与Researc-Agent示例.md
@description: YYC³-CLI Claude-Agentic组件选择指南与Researc-Agent示例.md
@author: YanYuCloudCube Team
@version: v1.0.0
@created: 2026-02-17
@updated: 2026-02-17
@status: published
@tags: [文档],[YYC³-CLI]
---

> ***YanYuCloudCube***
> 言启象限 | 语枢未来
> ***Words Initiate Quadrants, Language Serves as Core for the Future***
> 万象归元于云枢 | 深栈智启新纪元
> ***All things converge in the cloud pivot; Deep stacks ignite a new era of intelligence***

---

#

本文讨论了 Claude Agentic 组件选择指南，并以 Research Agent 为例展示组件组合使用的工作流，同时解答了组件使用中的常见问题。关键要点包括：

1. 组件选择原则：先判断任务需解决的问题类型，如指令、可复用流程等，再对应选用 Prompts、Skills 等组件，必要时进行组合，可减少重复解释，让工作流更稳定、可扩展。
2. 各组件核心信息：Skills 是可复用流程，跨对话复用；Prompts 是对话指令，仅当前对话有效；Projects 承载项目背景资料，项目内持续有效；Subagents 负责任务拆分分工，可跨会话复用；MCP 连接外部工具数据源，持续可用。
3. 研究智能体工作流：创建并配置「Competitive Intelligence」Project，上传资料并添加指令；通过 MCP 连接 Google Drive、GitHub 等数据源；创建 competitive-analysis 等专用 Skills；配置 market - researcher、technical - analyst 等 Subagents；启用研究智能体，系统按链路协同工作输出竞品分析报告。
4. Skills 省上下文机制：采用渐进式加载机制，先扫描元信息，命中后加载完整说明，资源按需加载，高效使用上下文。
5. 组件使用对比：Prompts 用于一次性指令，Skills 用于可复用流程，Projects 用于项目长期背景；Subagents 负责分工执行，可使用 Skills；根据不同需求可单独或组合使用各组件。
6. Subagents 使用 Skills：在 Claude Code 和 Agent SDK 中，subagents 可像主代理一样访问并使用 Skills，实现分工执行与专业方法复用。

上一篇我们先把 Claude 的 Agentic 生态“搭了个骨架” —— Prompts、Skills、Projects、Subagents、MCP 各自负责什么、彼此怎么协同。这一篇不再停留在概念解释上，而是把它们放进真实任务里跑一遍：你会看到什么时候该用哪个组件、怎么用更省步骤，以及如何组合起来，把一次性对话变成可复用的工作流。
先判断需求，再选择组件
单个组件解决的是某一类问题。当你把它们按职责串联起来，就能形成一条更完整、更稳定的工作链路：Prompts 用于下达当下指令，Skills 固化可复用的方法，Projects 承载长期背景与资料，Subagents 承担分工执行与权限隔离，MCP 负责接入外部工具与数据源。通过这种组合，你不仅能完成一次任务，更能把能力沉淀为可持续复用的智能体工作流。
选择组件的关键在于先判断任务需要解决哪一类问题：是 指令、可复用流程、长期背景、分工执行，还是外部连接。明确需求后，对应选用 Prompts、Skills、Projects、Subagents 或 MCP，并在需要时进行组合 —— 这样既能减少重复解释，也能让工作流更稳定、更可扩展。
组件名称
Skills
Prompts
Projects
Subagents
MCP
核心作用
可复用的流程/方法（程序化知识）
对话中的指令
项目背景与资料（背景知识）
任务拆分与分工执行
工具与数据源连接能力
生效范围
可跨多次对话复用
仅当前对话当下有效
在该 Project 内持续有效
可跨会话复用（按配置）
持续连接、长期可用
典型内容
说明文档 + 脚本/代码 + 资源文件
自然语言指令
文档资料 + 上下文 + 项目级指令
子代理的完整配置与逻辑
工具接口定义与连接配置
触发方式
按需动态加载
每一轮对话即时生效
项目内默认持续可用
调用时加载/运行
连接建立后持续可用
是否支持代码
✅ 可以
❌ 不建议/通常不包含
❌ 通常不包含
✅ 可以
✅ 可以
适用场景
固化专业方法与标准流程
快速提出需求、即时调整
集中管理长期背景与资料
专项任务执行（如审查/测试/安全）
访问外部数据与工具（如 Drive/Slack/DB）

---
示例工作流：研究智能体（Research Agent）
下面我们用多个组件组合，搭建一个完整的研究智能体。本示例将演示如何搭建并启用一个用于竞品分析（competitive analysis）的智能体工作流。
第一步：创建并配置 Project
新建一个「Competitive Intelligence（竞品情报）」Project，并上传以下资料作为项目知识库：

- 行业报告与市场分析
- 竞品产品文档（说明书/白皮书/更新日志等）
- 来自 CRM 的客户反馈与一线需求记录
- 以往研究结论与摘要材料
然后在项目内添加 项目级指令（Project instructions），例如：
请从我们的产品战略视角分析竞争对手，重点识别差异化机会与正在浮现的市场趋势。输出结论时需给出明确证据，并提供可执行的建议与行动项。
第二步：通过 MCP 连接数据源
为项目启用相应的 MCP Servers，让 Claude 能直接访问外部数据与工具：
- Google Drive：访问团队共享的研究文档与资料库
- GitHub：查看竞品的开源仓库（代码、README、Issue、Release 等）
- Web Search：获取实时的市场信息与最新动态
第三步：创建专用 Skills
创建一个名为 competitive-analysis 的 Skill，用来固化竞品分析的统一方法与输出规范。例如，My Company GDrive Navigation Skill 是一种优化的搜索与检索策略，可以高效定位公司内部文档、研究材料等。

# My Company GDrive Navigation Skill

## Overview

Optimized search and retrieval strategy for Meridian Tech's Google Drive structure. Use this skill to efficiently locate internal documents, research, and strategic materials.

## Drive Organization

**Top-level structure:**

- `/Strategy & Planning/` - OKRs, quarterly plans, board decks
- `/Product/` - PRDs, roadmaps, technical specs
- `/Research/` - Market research, competitive intel, user studies
- `/Sales & Marketing/` - Case studies, pitch decks, campaign materials
- `/Customer Success/` - Implementation guides, success metrics
- `/Company Ops/` - Policies, org charts, team directories

**Naming conventions:**

- Format: `YYYY-MM-DD_DocumentName_vX`
- Final versions marked with `_FINAL`
- Drafts include `_DRAFT` or `_WIP`

## Search Best Practices

1. **Start broad, then filter** - Use folder context + keywords
2. **Target document owners** - Sales materials from Sales/, not root
3. **Check recency** - Prioritize documents from last 6 months for current strategy
4. **Look for "source of truth"** - Files with `_FINAL`, `_APPROVED`, or in `/Archives/Official/`

## Research Agent Workflow

1. Identify topic category (product, market, customer)
2. Search relevant folder with targeted keywords
3. Retrieve 3-5 most recent/relevant documents
4. Cross-reference with `/Strategy & Planning/` for context
5. Cite sources with file names and dates
第四步：配置 Subagents（仅适用于 Claude Code / Agent SDK）
创建用于分工执行的专项 subagents，例如：

- market-researcher subagent（市场研究子代理）：负责信息检索与资料汇总（行业动态、市场规模、趋势信号等）。
name: market-researcher
description: Research market trends, industry reports, and competitive landscape data. Use proactively for competitive analysis.
tools: Read, Grep, Web-search

---
You are a market research analyst specializing in competitive intelligence.

When researching:

1. Identify authoritative sources (Gartner, Forrester, industry reports)
2. Gather quantitative data (market share, growth rates, funding)
3. Analyze qualitative insights (analyst opinions, customer reviews)
4. Synthesize trends and patterns

Present findings with citations and confidence levels.

- technical-analyst subagent（技术分析子代理）：负责技术维度的竞品分析，重点拆解竞品的技术架构、实现路径与工程决策（技术栈与架构模式、可扩展性与性能方案、技术优势与限制），输出可直接支撑产品与技术决策的结论与建议。
name: technical-analyst
description: Analyze technical architecture, implementation approaches, and engineering decisions. Use for technical competitive analysis.
tools: Read, Bash, Grep

---
You are a technical architect analyzing competitor technology choices.

When analyzing:

1. Review public repositories and technical documentation
2. Assess architecture patterns and technology stack
3. Evaluate scalability and performance approaches
4. Identify technical strengths and limitations

Focus on actionable technical insights that inform our product decisions.
第五步：启用研究智能体（Research Agent）
现在，当你向 Claude 提出这样的需求：
 「分析我们前三大竞争对手在最新 AI 功能上的定位策略，并找出我们可以利用的空档与机会」
系统会按以下链路协同工作：

- Project 上下文生效：Claude 读取你在项目中上传的研究资料，并遵循项目级指令开展分析
- MCP 连接启动：Claude 自动检索 Google Drive 中最新的竞品简报，并从 GitHub 拉取相关信息
- Skills 介入：competitive-analysis Skill 提供统一的分析框架与输出规范
- Subagents 分工执行（Claude Code 场景）：market-researcher 汇总行业与市场信息，technical-analyst 评估竞品技术实现与架构取向
- Prompts 细化方向：你在对话中补充即时要求，例如「重点关注医疗行业的企业级客户」
最终输出：一份完整的竞品分析报告——能够同时覆盖多来源数据、遵循既定分析框架、调用专项分工能力，并在整个研究项目中保持一致的上下文与判断口径。

---
常见问题
Skills 到底是怎么“省上下文”的？
Skills 采用渐进式加载（progressive disclosure）机制，目的是在保持能力可扩展的同时，让 Claude 的上下文使用更高效。
当 Claude 处理任务时，会按以下顺序使用 Skills：

1. 先扫描元信息（metadata）：读取 Skill 的描述与摘要，用于快速判断哪些 Skill 可能相关
2. 命中后加载完整说明：一旦匹配到相关 Skill，Claude 才会进一步加载该 Skill 的详细指令
3. 资源按需加载：如果 Skill 内包含可执行代码或参考文件，也只会在确实需要时才加载
这种架构的好处是：你可以同时维护大量 Skills，而不会轻易挤占 Claude 的上下文窗口。Claude 会在每次任务中只取用必要信息，并在必要时再深入，做到“用多少、取多少”。
Skills vs Subagents
优先用 Skills 的情况：
当你希望某种能力可以被“任何一次 Claude 对话”直接复用时，用 Skills。它更像一套可复用的训练资料/操作规范，让 Claude 在不同对话中都能按同一套方法把事情做对、做稳。
优先用 Subagents 的情况：
当你需要一个“独立执行的专用角色”，能够围绕特定目标自行完成一段工作流时，用 Subagents。它更像一个分工明确的专岗：有自己的上下文范围和工具权限，负责把某类任务从头到尾独立跑完。
组合使用：
当你既需要 Subagents 的独立执行与权限隔离，又希望它具备可复用的专业方法时，把 Skills 作为“方法库”供 Subagents 调用。
例如，一个 code-review 子代理可以加载语言相关的最佳实践 Skill，在保持独立审查能力的同时，确保评审标准统一、可复用。
Skills vs Prompts
优先用 Prompts 的情况：
 当你需要的是一次性指令、即时补充上下文，或希望在对话中反复调整方向与表达时，用 Prompts。它更偏“现场指挥”——跟着当前对话走，灵活但不保留。
优先用 Skills 的情况：
 当你有一套会反复用到的流程、规范或专业方法时，用 Skills。它更偏“常驻能力”——Claude 能识别何时该用，并且可以跨对话持续复用，保证执行一致性。
组合使用：
 Prompts 和 Skills 是天然互补的：先用 Skills 提供稳定的底层方法与标准，再用 Prompts 针对每次任务补充具体背景与细化要求，让输出既“有章法”，又“贴合当下”。
Skills vs Projects
优先用 Projects 的情况：
 当你需要围绕某个具体主题/项目，长期共享同一套背景资料与上下文，并且希望这些内容在该项目的每次对话中都能自动生效时，用 Projects。Projects 更像一个“项目工作空间”：资料集中、上下文持续，适合承载固定参考材料。
优先用 Skills 的情况：
当你需要的是可复用的流程方法、规范体系，甚至可执行脚本，并且希望它们只在相关任务出现时才按需加载时，用 Skills。Skills 更像“能力模块”：按需启用，不会长期占用上下文窗口。
组合使用：
 当你既需要项目级的长期背景，又需要专项能力时，把 Projects 和 Skills 一起用。
 例如：建立一个「Product Development」Project，存放产品规格与用户调研资料；同时配套 Skills，用于生成技术文档、分析用户反馈数据等。这样项目内对话既有稳定的背景知识，也能按需调用更专业的处理方法。
关键区别：

- Projects 解决的是「你需要知道什么」（知识与背景）
- Skills 解决的是「你需要怎么做」（方法与能力）
Projects 提供的是你在其中工作的知识底座；Skills 提供的是可以在任何对话、任何项目中复用的执行能力。
Subagents 能使用 Skills 吗？
可以。在 Claude Code 和 Agent SDK 中，subagents 可以像主代理一样访问并使用 Skills。这样就能 subagents 负责分工执行与权限隔离，Skills 提供可复用的专业方法。
例如：
- python-developer subagent（Python 开发子代理） 可以调用 pandas-analysis Skill，按你们团队的约定完成数据处理与转换；
- documentation-writer subagent（文档编写子代理） 可以调用 technical-writing Skill，把 API 文档统一输出为一致的结构与格式。
