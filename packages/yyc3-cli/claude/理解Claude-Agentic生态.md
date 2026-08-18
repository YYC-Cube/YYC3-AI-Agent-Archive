---
@file: 理解Claude-Agentic生态.md
@description: YYC³-CLI 理解Claude-Agentic生态.md
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

# 理解 Claude 的 Agentic 生态：把零散能力组织成可持续的工作流

本文讨论了如何理解 Claude 的 Agentic 生态，即把零散能力组织成可持续的工作流，并围绕几个关键“组件”展开介绍它们分别解决的问题、适用场景以及组合使用方法。关键要点包括：

1. Prompts：是与 Claude 对话时用自然语言给出的指令，即时、灵活但不持久。适用于一次性需求、对话迭代优化等场景，不过不会跨对话自动保留，高频要求可沉淀为 Skills 或 Projects。
2. Skills：是“文件夹式”能力包，可放指令说明等，采用渐进式加载机制。适用于组织级工作流、领域型能力、个人偏好等场景，能让 Claude 稳定、重复、高效完成专业任务。
3. Projects：是付费版套餐中的自包含工作空间，有独立聊天记录与知识库，可扩展上下文容量。适用于持久上下文、工作空间组织、团队协作、自定义指令等场景，为特定工作场景提供持续上下文。
4. Subagents：是面向特定任务的 AI 助手，有独立上下文窗口等。适用于任务专精、上下文管理、并行处理、工具隔离与限制等场景，可独立处理离散任务。
5. MCP：是连接层协议，提供标准化连接方式。适用于访问外部数据、调用业务系统、连接开发环境、对接自研系统等场景，解决“让 Claude 连接到哪里、拿到什么数据”的问题。
6. 组件定位区分：Prompts 是即时指令；Skills 教会 Claude “怎么做”；Projects 提供持续上下文；Subagents 独立执行、分工完成任务；MCP 解决数据连接问题。
7. 组合使用建议：若在多个 Projects 间反复用同一套指令，可做成 Skill；若多个代理复用专业方法，也沉淀为 Skill。 

自从推出 Skills 以来，很多人都想搞清楚：Claude 这套 Agentic（智能体化）生态里，各个组件到底是怎么协同工作的。
不管你是在 Claude Code 里搭建复杂工作流，用 API 做企业级解决方案，还是在 Claude.ai 上提升日常效率——只要你能判断“该用哪个组件、什么时候用”，你和 Claude 的协作方式就会从「临时对话」升级为「稳定的工作系统」。
这份指南会围绕几个关键“组件”展开：它们分别解决什么问题、适用于哪些场景，以及如何组合使用，搭出更强大的智能体工作流。

先明确一下定位：它们分别解决什么问题？
为了避免概念混在一起，可以用一句话抓住每个组件的定位：
- Prompts：你在当下对话里给 Claude 的指令（即时、灵活，但不持久）
- Skills：可复用的“操作手册 + 资源包”（让 Claude 稳定地按同一套方法做事）
- Projects：面向某个工作主题的长期工作空间（持续积累知识与对话上下文）
- Subagents：分工明确的“子角色/子助手”（独立上下文 + 权限隔离，用于专门任务）
- MCP：连接层协议（让 Claude 接入外部工具与数据源，解决“数据在哪儿”）
有了这个总框架，下面再看每一项，就更容易理解它们之间的关系与边界。

Prompts：对话中的指令
Prompts（提示词）是你在与 Claude 对话时，用自然语言给出的指令。它的特点是即时、对话式、可随时调整：你在当下补充背景、提出要求，Claude 依据当前输入完成一次响应。
适用场景
- 一次性需求：例如「总结这篇文章」
- 对话中的迭代优化：例如「把语气改得更专业」
- 即时上下文输入：例如「分析这份数据并识别趋势」
- 临时格式/呈现要求：例如「按项目符号列表输出」
示例 Prompt

Please conduct a comprehensive security review of this code. I'm looking for:
1. Common vulnerabilities including:
Injection flaws (SQL, command, XSS, etc.)
Authentication and authorization issues
Sensitive data exposure
Security misconfigurations
Broken access control
Cryptographic failures
Input validation problems
Error handling and logging issues
2. For each issue you find, please provide:
Severity level (Critical/High/Medium/Low)
Location in the code (line numbers or function names)
Explanation of why it's a security risk and how it could be exploited
Specific fix recommendation with code examples where possible
Best practice guidance to prevent similar issues
3. Code context: [Describe what the code does, the language/framework, and the environment it runs in - e.g., "This is a Node.js REST API that handles user authentication and processes payment data"]
4. Additional considerations:
Are there any OWASP Top 10 vulnerabilities present?
Does the code follow security best practices for [specific framework/language]?
Are there any dependencies with known vulnerabilities?
Please prioritize findings by severity and potential impact.

小提示：
Prompts 是你与 Claude 交互的主要方式，但它们不会跨对话自动保留。如果某类工作流程需要反复使用，或涉及较强的专业 / 组织知识，建议把这些内容沉淀为 Skills 或 Projects，以获得更稳定一致的执行效果。
比如把「按 OWASP 标准做代码安全审查」或「按‘执行摘要-关键发现-建议’的结构输出分析」这类高频要求整理为 Skill，这样你无需每次重复说明流程，同时也能保证输出的一致性与可复用性。

Skills：把高频方法论变成可复用能力
Skills 可以理解为“文件夹式”的能力包：里面可以放指令说明、脚本、资源文件。Claude 在处理任务时会按需发现并动态加载，从而在特定领域更稳定、更专业。
你可以把 Skills 理解成给 Claude 配置的一套“专项工作手册”：从处理 Excel 表格，到遵循公司的品牌规范，都可以通过 Skills 固化下来。
如何加载 Skills？
当 Claude 处理任务时，它会先去扫描当前可用的 Skills，找出可能相关的那几个。Skills 采用渐进式加载（progressive disclosure）机制：
- 先加载元信息（metadata）：大概 ~100 tokens，只给 Claude 足够的信息，用来判断“这个 Skill 有没有用”
- 需要时再加载完整说明：不超过 5k tokens
- 脚本/文件等资源：只有在真的用到时才会加载
简单说就是：先快速定位，再按需深入，最后才动用资源 —— 既省上下文，也更稳。
适用场景
当你希望 Claude 稳定、重复、高效地完成某类“专业任务”时，优先选择 Skills。典型场景包括：
- 组织级工作流（标准化流程）：用于固化企业内部的统一规范与流程，例如品牌使用规范、合规/审批流程、常用文档与模板体系。
- 领域型能力（专业任务能力）：用于沉淀特定领域的操作方法与最佳实践，例如 Excel 公式与建模、PDF 解析与处理、数据清洗与分析。
- 个人偏好（个性化工作方式）：用于固化个人在工作中的偏好与习惯，例如笔记结构与记录规则、代码风格与工程约定、调研方法与信息整理流程。

举一个例子：
你可以做一个“品牌规范”的 Skill，把你们公司的色板、字体规范、版式规范都放进去。这样 Claude 在生成 PPT 或文档 时，就会自动套用这些标准，也就是说你不用每次都从头解释一遍。

Projects：建立长期工作空间
在所有付费版 Claude 套餐中，Projects（项目）是一种自包含的工作空间：每个项目有独立的聊天记录与知识库，并提供 200K context window。你可以在其中上传资料、补充背景，并设置项目级自定义指令，对该项目内的所有对话生效。
Projects 是怎么工作的？
你上传到项目知识库的内容，会在该项目内的所有对话中持续可用。Claude 会自动利用这些上下文，为你生成更充分、更相关的回答。
当项目知识接近上下文限制时，Claude 会无缝启用 RAG（Retrieval Augmented Generation，检索增强生成）模式，将可用容量扩展至最高 10 倍。
适用场景
当你需要以下能力时，优先选择 Projects：
- 持久上下文：需要让同一批背景知识持续影响每次对话
- 工作空间组织：为不同项目/计划隔离不同的上下文，互不干扰
- 团队协作：共享知识库与对话历史（适用于 Team / Enterprise 套餐）
- 自定义指令：为项目设置专属的语气、视角或工作方式

举一个例子：
在创建一个「Q4 Product Launch」项目时，你可以把把市场调研、竞品分析、产品规格等材料统一放进去。此后你在该项目里开启的每一次对话，都能直接调用这些内容，无需反复上传或重复解释背景。

小提示：
Projects 的核心作用是：为某个特定工作场景提供持续的上下文（比如公司代码库、研究课题、长期客户项目）。而 Skills 的核心作用是：教会 Claude “怎么做”某件事。
举例来说，Project 可以存放产品发布相关的所有背景材料；Skill 则可以沉淀你们团队的写作规范或代码评审流程。如果你发现自己在多个 Projects 之间反复复制同一套指令，你可以把这些通用规则抽出来做成一个 Skill。

Subagents ：把任务拆分给“独立执行单元”
Subagents（子代理）是一类面向特定任务的 AI 助手，它拥有独立的上下文窗口、可定制的系统提示词，以及被明确限定的工具权限。它们可在 Claude Code 与 Claude Agent SDK 中使用，用于独立处理离散任务并回传结果给主代理。
Subagents 是怎么工作的？
你可以为每个 subagent 定义：
- 它负责什么？
- 如何处理问题？
- 能访问哪些工具？
Claude 可以根据 subagent 的描述自动把任务委派给合适的 subagent；你也可以在对话中直接指定调用某个 subagent。
适用场景
Subagents 特别适合以下需求：
- 任务专精：如代码审查、测试用例生成、安全审计
- 上下文管理：把主对话保持在主线，把专业且细碎的工作下放给子代理处理
- 并行处理：多个 subagent 可同时处理不同维度的工作
- 工具隔离与限制：将特定 subagent 限定为更安全的操作范围（例如只读权限）

举一个例子：
创建一个 code-reviewer subagent，仅允许使用 Read / Grep / Glob 等读取与检索工具，不开放 Write / Edit。这样当你修改代码后，Claude 可以自动将质量与安全审查交给该 subagent 完成，同时避免出现“意外改动代码”的风险。

小提示：
如果你希望多个代理或多段对话都复用同一套专业方法（例如安全审查流程、数据分析方法），建议将这些知识沉淀为 Skill，而不是写死在某个 subagent 里。
一句话区分：

- 用 Skills：把“怎么做”教给所有代理都能用
- 用 Subagents：需要独立执行、权限隔离、上下文隔离，并且能按角色分工完成任务

MCP：让 Claude 接入外部工具与数据源

MCP 在 AI 应用与既有工具、数据源之间，提供了一层通用的连接接口。
通过 MCP，AI 应用可以用更统一的方式接入你现有的工具链与数据来源。

Model Context Protocol（MCP） 是一个开放标准，用于把 AI 助手连接到外部系统 —— 内容库、企业业务工具、数据库、开发环境等。
MCP 是怎么工作的？
MCP 提供了一套标准化的连接方式，让 Claude 能以统一协议接入你的工具与数据源。相比为每个数据源单独开发一套集成，你只需要对接 同一个协议 即可。
- MCP Server（服务器端）：对外暴露数据与能力（比如读取文档、查询数据库、调用某个工具能力）
- MCP Client（客户端）：由 Claude 等 AI 应用扮演，负责连接这些服务器并发起调用
适用场景
当你需要 Claude 做到以下能力时，适合选择 MCP：
- 访问外部数据：如 Google Drive、Slack、GitHub、各类数据库
- 调用业务系统：如 CRM、项目管理平台等
- 连接开发环境：本地文件、IDE、版本控制系统等
- 对接自研系统：企业内部的专有工具与数据源

举一个例子：
通过 MCP 将 Claude 连接到公司 Google Drive。此后 Claude 就能直接搜索文档、读取文件、引用内部知识，无需你手动上传；而且这种连接可以持续生效并自动更新。

小提示：
可以这样理解：MCP 解决的是“让 Claude 连接到哪里、拿到什么数据”。如果你需要 Claude 先能访问数据库或 Excel 文件本身，那就是 MCP 的范畴。
