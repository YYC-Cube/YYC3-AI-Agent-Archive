---
@file: 如何使用CLAUDE将Claude-Code的工作效率发挥到极致.md
@description: YYC³-CLI 如何使用CLAUDE将Claude-Code的工作效率发挥到极致.md
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

# 如何用 CLAUDE.md 将 Claude Code 的工作效率发挥到极致

GLM Coding Plan 用户在使用 Claude Code 时，总会遇到一个难题：
如何在不反复赘述的前提下，让工具充分理解你的项目架构、编码规范和工作流程？
随着代码库规模的不断增长，这个问题会变得愈发突出。模块之间的依赖关系、特定领域的编码模式还有团队内部的约定，这些东西本来就不好直观展示。结果就是每次跟工具对话，都得先花时间重复解释一遍 —— 比如当初的架构怎么定的、测试有哪些要求、代码风格偏好是什么，特别浪费时间。
而 CLAUDE.md 刚好能解决这个痛点，它就像给 Claude Code 专门准备的 “项目说明书”。它是一份配置文件，能帮助 Claude Code 记住项目的核心信息，形成持久的上下文记忆。每次你跟 Claude Code 对话，都会自动加载这些背景信息，确保它对你的项目了如指掌。
接下来我就具体说说，CLAUDE.md 该怎么结构化地编写，分享一些实战中的最佳方案，还有怎么用它充分发挥GLM-4.6 模型与 Claude Code 工具的效能。
什么是  CLAUDE.md 文件？
以下是你可能会在代码仓库中用到的 CLAUDE.md 示例：
CLAUDE.md 是一份写给 Claude Code 的“项目备忘录”。它是一份放在代码仓库里的特殊配置文件，用来告诉 Claude Code 你的项目是怎么组织的、有哪些约定、使用什么规范、遵循怎样的开发流程。这样一来，你就不用在每次对话里反复解释架构、风格和团队习惯。
它的存放位置非常灵活：
• 对于一般项目，放在仓库根目录，整个团队都能共享；
• 如果是 monorepo，可以把它放在父级目录；
• 你也可以把它放在自己的主目录，让它在所有项目里都能生效。
一句话总结：把 Claude Code 需要长期记住的项目信息写进 CLAUDE.md，就能让你的协作从第一句开始就“对齐上下文”。
下面是你可能在仓库中用到的 CLAUDE.md 示例：
# Project Context

When working with this Code base, prioritize readability over cleverness. Ask clarifying questions before making architectural changes.

## About This Project

FastAPI REST API for user authentication and profiles. Uses SQLAlchemy for database operations and Pydantic for validation.

## Key Directories

- `app/models/` - database models
- `app/api/` - route handlers
- `app/core/` - configuration and utilities

## Standards

- Type hints required on all functions
- pytest for testing (fixtures in `tests/conftest.py`)
- PEP 8 with 100 character lines

## Common Commands
```bash
uvicorn app.main:app --reload  # dev server
pytest tests/ -v               # run tests
```

## Notes

All routes use `/api/v1` prefix. JWT tokens expire after 24 hours.一个配置得当的 CLAUDE.md 文件，能显著提升 Claude Code 在你项目中的工作表现。它会为 Claude Code 补齐架构背景、明确你的工作流程，并说明项目里常用的工具和约定。重点不是写“Claude Code 可能需要什么”，而是把你在实际协作中总是需要重复解释的内容整理进去。
你可以在文件里记录诸如：常用的 bash 命令、关键工具类、编码风格规范、测试方式、仓库结构约定、开发环境的搭建步骤、以及项目里那些容易踩坑的注意事项。格式没有硬性要求，只要简洁、易读，让团队成员和 Claude Code 一眼就能抓住重点即可。
最终，这份 CLAUDE.md 会成为 Claude Code 的基础上下文之一，在每一次对话前自动加载——你不再需要从头讲一遍项目背景，它也能始终保持“对齐状态”，更快进入正题。

使用/init命令快速上手
从零创建 CLAUDE.md 可能会让人望而却步，尤其是在面对一个不熟悉的代码库时。
而 /init 命令能自动完成这一过程 —— 它会分析你的项目，生成一份初始配置。
在任意 Claude Code  会话中运行以下命令：
cd your-project
claude
/initClaude Code 能自动扫描你的整个代码库，读取包管理文件、已有的项目文档、各类配置文件以及代码目录结构，然后根据你的项目情况自动生成一份初版 CLAUDE.md。生成内容通常包含构建/运行命令、测试说明、关键目录以及能从代码中推断出的编码规范。
不过要注意，通过/init 命令生成的文件绝对不能直接拿来当最终版本用。自动生成的文件能抓住项目的骨架，但往往缺少了团队工作流的血肉 —— 那些约定俗成的细节。所以一定要仔细核对生成的内容，再结合团队的实际工作习惯做调整优化。
即使你的项目里已经有现成的 CLAUDE.md 了，也能使用 /init 命令。这种情况下，Claude Code 会对比现有文件和代码库的最新变化，给出针对性的优化建议。
/init 之后，下一步做什么？
• 检查准确性：确保所有推断出的信息都是正确的。
• 补充“潜规则”：加入 Claude Code 无法推断的工作流，比如分支命名规范、部署流程、代码审查的具体要求等。
• 精简内容：删掉那些不适合当前项目的通用指导内容。
• 纳入版本控制：把最终版文件提交到版本控制系统里，方便团队成员共享使用。
其实 /init 命令的核心作用就是快速搭好基础框架，CLAUDE.md 的真正价值在于后续的持续迭代完善。在日常使用 Claude Code  时，用 # 键记录下那些重复性的操作指南，慢慢把这份文件打磨成能精准匹配团队运作模式的专属配置。

如何构建一份真正高效的 CLAUDE.md?
接下来的内容，会手把手教你如何打磨这份文件，让它成为你的得力助手。我们将聚焦于几个核心场景：如何帮助它理解复杂架构、跟踪多步骤任务、集成自定义工具，以及通过统一流程减少重复沟通。
为 Claude Code 提供“项目地图”
在日常开发中，最耗时的往往不是写代码，而是反复解释项目架构、模块依赖、关键库、编码风格等背景信息。要让 Claude Code 长期、稳定地理解你的代码库，就需要把这些基础上下文写进 CLAUDE.md，让它无需每次都从零开始。
最基础也最重要的内容，是项目的总体概览和目录结构。
你可以在 CLAUDE.md 中加入简洁的项目说明和一份结构清晰的目录树，帮助 Claude Code 快速建立认知模型，知道关键模块分别放在哪里。例如：
main.py
├── logs
│   ├── application.log
├── modules
│   ├── cli.py
│   ├── logging_utils.py
│   ├── media_handler.py
│   ├── player.py在项目地图中，你可以进一步加入主要依赖、架构模式以及任何“非标准”的组织方式。如果项目采用了 DDD、微服务拆分，或使用了某些特定框架，也可以在这里说明。这样 Claude Code 能更准确地判断代码属于哪一层、修改应该落在哪里，不会误入无关模块。
把 Claude Code 接入你的运行环境
Claude Code 会继承你的开发环境，但它并不知道“哪些工具该用、怎么用”。这个时候就需要你在 CLAUDE.md 中明确告诉它。
如果团队里有部署脚本、测试脚本、代码生成器、数据处理脚本等常用工具，都可以写在 CLAUDE.md 中。建议包含以下信息：
• 工具名称与用途
• 基础使用方法（命令格式、关键参数）
• 典型调用场景
• 是否支持 --help 获取帮助文档
只要你把这些说明补充完整，Claude Code 就可以在任务中正确调用这些工具。对于较复杂的内部工具，建议再补充团队最常用的几条“高频用法”。
Claude Code 还内置了 MCP（Model Context Protocol）客户端，可以连接外部 MCP 服务器，从而使用更多扩展能力。
你可以通过以下方式配置 MCP：
• 项目设置
• 全局设置
• 仓库中的 .mcp.json 文件
如果某个 MCP 工具没有正常显示，可以用 --mcp-debug 排查异常。
举个例子，若你的团队已配置 Slack MCP 服务器，而你希望 Claude Code 在对话中能直接调用 Slack 工具，可在 CLAUDE.md 中添加如下内容：
### Slack MCP
- Posts to #dev-notifications channel only
- Use for deployment notifications and build failures
- Do not use for individual PR updates (those go through GitHub webhooks)
- Rate limited to 10 messages per hour定义标准工作流
要是让 Claude Code 没个明确规划就直接改代码，大概率会白忙活一场。它给的方案可能漏了需求点，或者用错了架构思路，更糟的还会搞崩现有功能，最后只能返工。
关键是得让 Claude Code 动手前先 “想清楚”。所以一定要在 CLAUDE.md 里针对不同类型的任务定好标准工作流，让它照着执行。一套完善的默认工作流，核心是动手修改前先把四个问题捋明白：
1. 这个问题是不是得先调研一下，摸清当前的代码现状才能动手？
2. 动手写代码前，要不要先搭个详细的实现方案？
3. 现在手里的信息够不够？还缺哪些关键内容没明确？
4. 做完之后怎么验证？怎么确保方案是有效的？
工作流可以根据任务类型灵活定制：
• 功能开发：可遵循“调研-规划-编码-提交”的流程。
• 算法开发：更适合采用“测试驱动开发”（TDD）模式。
• UI 迭代：则可遵循“视觉原型迭代”的流程。
同时，也请在文档中明确测试要求、提交信息规范以及各类审批流程。当 Claude Code 预先掌握了这些工作流，它就能主动地与团队的实际节奏保持一致，而不是凭感觉行事。
以下是一个工作流指令的示例：
1) Before modifying Code  in the following locations: X, Y, Z
        - Consider how it might affect A, B, C
        - Construct an implementation plan
        - Develop a test plan that will validate the following functions...使用Claude Code 的进阶技巧
除了配置 CLAUDE.md，还有三个技巧能大幅提升你的 Claude Code  体验。
5. 保持上下文“干净”
长时间连续使用 Claude Code ，会让上下文里不断堆积无关信息：旧任务的文件内容、失效的命令输出、已经过时的讨论……这些噪声会占据 Claude Code 的上下文窗口，让它难以专注在当前任务上。
在切换任务时，可以使用 /clear 命令重置上下文。它会清除历史记录，但保留 CLAUDE.md 配置，相当于开启一个全新的工作会话。
例如：你刚完成一轮身份验证相关的调试，接下来要开发全新的 API 端点。此时，与身份验证相关的上下文已经不再有用，可以执行一次 /clear命令，避免旧内容干扰 Claude Code 的思考。
1. 使用 Sub-agent 隔离不同工作阶段
复杂任务往往需要多个分析视角。比如：
• 你刚调试完一段身份验证逻辑
• 接下来要对同一段代码进行安全审查
如果继续在同一个对话中，让 Claude Code 的“调试上下文”直接影响安全检查，会导致它过度关注已经解决的问题，反而忽略真正的风险点。
这时可以让 Claude Code 启动一个 Sub-agent 来处理新阶段的分析。Sub-agent 拥有独立上下文，相当于为该步骤开了一个全新、干净的工作空间。
这种方式在多步骤流程里尤其有用：开发阶段需要项目背景和功能需求，而安全审查阶段则需要“无前提”的视角。上下文隔离，让两种分析都能更精准。
2. 为高频任务创建自定义命令
重复输入相似提示本身就是一种浪费：
“请检查这段代码的安全隐患”
“帮我分析这里的性能瓶颈”
“为这一函数写单元测试”
每次都要想一遍最佳 phrasing，没有必要。
你可以把常用提示写进 .claude/commands/ 目录下的 markdown 文件，作为 自定义斜杠命令 来调用。
示例：
创建 .claude/commands/performance-optimization.md，内容写入你的标准性能优化指令。
之后在任何对话中输入：
/performance-optimization myfile.pyClaude Code 就会自动加载你的提示，并支持使用 $ARGUMENTS 或 $1、$2 这样的参数占位符，让你能灵活传入文件名、配置或说明。
自定义命令等于把你的经验沉淀成“可调用的工具”，大幅减少重复工作。
performance-optimization.md文件的内容可能如下：
# Performance Optimization

Analyze the provided Code  for performance bottlenecks and optimization opportunities. Conduct a thorough review covering:

## Areas to Analyze

### Database & Data Access
- N+1 query problems and missing eager loading
- Lack of database indexes on frequently queried columns
- Inefficient joins or subqueries
- Missing pagination on large result sets
- Absence of query result caching
- Connection pooling issues

### Algorithm Efficiency
- Time complexity issues (O(n²) or worse when better exists)
- Nested loops that could be optimized
- Redundant calculations or repeated work
- Inefficient data structure choices
- Missing memoization or dynamic programming opportunities

### Memory Management
- Memory leaks or retained references
- Loading entire datasets when streaming is possible
- Excessive object instantiation in loops
- Large data structures kept in memory unnecessarily
- Missing garbage collection opportunities

### Async & Concurrency
- Blocking I/O operations that should be async
- Sequential operations that could run in parallel
- Missing Promise.all() or concurrent execution patterns
- Synchronous file operations
- Unoptimized worker thread usage

### Network & I/O
- Excessive API calls (missing request batching)
- No response caching strategy
- Large payloads without compression
- Missing CDN usage for static assets
- Lack of connection reuse

### Frontend Performance
- Render-blocking JavaScript or CSS
- Missing Code  splitting or lazy loading
- Unoptimized images or assets
- Excessive DOM manipulations or reflows
- Missing virtualization for long lists
- No debouncing/throttling on expensive operations

### Caching
- Missing HTTP caching headers
- No application-level caching layer
- Absence of memoization for pure functions
- Static assets without cache busting

## Output Format

For each issue identified:
1. **Issue**: Describe the performance problem
2. **Location**: Specify file/function/line numbers
3. **Impact**: Rate severity (Critical/High/Medium/Low) and explain expected performance degradation
4. **Current Complexity**: Include time/space complexity where applicable
5. **Recommendation**: Provide specific optimization strategy
6. **Code  Example**: Show optimized version when possible
7. **Expected Improvement**: Quantify performance gains if measurable

If Code  is well-optimized:
- Confirm optimization status
- List performance best practices properly implemented
- Note any minor improvements possible

**Code  to review:**
```
$ARGUMENTS
```你无需手动创建自定义命令文件，直接让Claude帮你生成即可。例如：
Create a custom slash command called /performance-optimization that analyzes Code  for database query issues, algorithm efficiency, memory management, and caching opportunities.当你创建自定义命令时，Claude Code 会把对应的 Markdown 文件写入 .claude/commands/performance-optimization.md（或你指定的路径），并能立即识别与调用该命令。
从简入手，逐步完善
很多人一开始就想把 CLAUDE.md 做得面面俱到，结果既冗长又难维护。由于 CLAUDE.md 会在每次对话前被载入上下文，保持简洁并按需拆分更有效。实用做法：
• 先只写最关键的内容：项目结构、构建/运行命令、常用脚本示例。
• 把辅助信息拆成独立的 Markdown 文件（例如：testing.md、deploy.md、.claude/commands/*），并在 CLAUDE.md 中引用它们。
• 随着使用过程中的痛点逐步补充内容——让文件随着团队实践自然成长，而不是一次性塞满所有想法。
CLAUDE.md 会成为 Claude Code 的系统上下文，且通常会提交到仓库与团队共享。切勿把任何敏感凭证写进文件，包括但不限于 API Key、数据库连接字符串、私有证书或详细的安全漏洞信息。把它当成可能公开的文档来写。

让 CLAUDE.md 真正解决问题
CLAUDE.md 文件的核心价值，就是将 Claude Code  从一个通用助手，转变为你代码库的“定制版”工具。
从简单开始，逐步演进。 先用基本的项目结构和构建信息打基础，然后根据实际工作流中遇到的痛点，不断丰富它的内容。它应该能做到：
• 把你经常重复输入的命令、检查点和上下文“固化”下来；
• 捕捉那些需要十分钟口述才能讲清的架构与约定；
• 明确工作流，让 Claude Code 在动手前按团队流程思考，减少返工。
很多人会把CLAUDE.md当成“配置完就不管”的文件，但它的真正价值恰恰在于“持续进化”。软件项目从来不是静止的：业务迭代会新增模块，团队磨合会沉淀更高效的协作模式，新工具（比如引入ESLint新规则、改用Docker部署）也会融入工作流——这些变化都需要同步更新到CLAUDE.md中。
一句话总结：好的CLAUDE.md，不是“写出来”的，而是“用出来”的。它不需要完美的格式，只需要解决真问题；不需要追随理论，只需要贴合你的团队——最终和你的代码库一起，成为项目成长的一部分。
