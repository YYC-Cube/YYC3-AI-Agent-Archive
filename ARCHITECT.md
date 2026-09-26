# AI-Family 统一架构（整合后 v3 — 2026-09-02，数据核对 2026-09-26）

> ⚠️ **成熟度说明**：资产平台面（注册/评分/图谱/doctor 门禁/供应链/容器化）已生产可用；
> 智能运行时面（LLM 分解、Agent 工具执行、插件落盘安装）为接口完备的内存原型。
> 逐包/逐能力状态以 [README「实现状态矩阵」](README.md#-实现状态矩阵) 为准，
> 代码路径级证据见 [深审报告](docs/YYC3-AI-Agent-Archive-trae-20260925/00-项目现状审核报告.md)（评分 75.6/C+）。

| Hub | 内容 | 数量 |
| ----- | ------ | :---: |
| agents-hub/ai-family/ | AI Family 8位家人（docs/下重复已删除，符号链接保留） | 8 |
| agents-hub/cowagent/ | CowAgent Python 框架（外部，→ _external/） | ~50+ |
| skills-hub/community/ | 社区技能 | **358** |
| skills-hub/marketplace/ | 市场化技能 | **160** |
| skills-hub/ai-ml/nvidia-skills/ | NVIDIA 官方技能 | **212** |
| skills-hub/b2b/ | B2B SDR 技能（b2b-skills 重复已删除） | 9 |
| skills-hub 其他领域 | dev-workflow/marketing/glm/ui-ux/social-search/yyc3 | 92 |
| plugins-hub/official/ | 官方插件（18组重复 .mcp.json 已删除） | ~80+ |
| plugins-hub/official/claude-code-hooks/ | Claude Code Hooks | ~55 |
| plugins-hub/official/claude-code-mcps/ | Claude Code MCP 配置 | ~54 |
| plugins-hub/official/buildwithclaude-*/ | buildwithclaude 插件 8 组 | 8 groups |
| plugins-hub/official/claude-mem/ | 记忆系统（claude-mem-main） | 1 |
| tools-hub/workflow-builder/ | AI 工作流构建器（ai-agent） | 1 |
| tools-hub/browser-agent/ | 浏览器自动化 Rust CLI | 1 |
| packages/@yyc3/icons/ | Lucide 图标库子集 | ~1000+ icons |
| packages/ | TypeScript 核心包（新增 6 个包） | **13** |
| locales/ | i18n 翻译文件（zh-CN + en） | 2 files |
| mcp-hub/claude-prompts/ | MCP 提示词服务（vendored 上游镜像；双轨代码已归档 _archive/mcp-hub-dual-track-code） | 1 |
| docs/ | AI Family 完整文档体系 + 架构文档 + 会话审核存档 | 85+ |
| system prompt | docs/ 单一权威源（agents-hub 副本已删除） | 1 |

## 新增核心包 (Phase 3-5)

> 测试数为 2026-09-26 实测（全量 1197，中/英 locale 双跑）；成熟度图例：✅生产可用 🟡部分可用/纵深防御 🔴内存原型 📊数据资产。

| 包 | 阶段 | 功能 | 测试 | 成熟度 |
| ---- | ------ | ------ | :---: | :---: |
| `@yyc3/skill-gateway` | Phase 3 | Skill Gateway API (REST/Hono，13 端点；XFF 跳数 + Zod 边界 + chunked 计数 + CSP/HSTS + reload sync + fail-open 告警) | 63 | ✅ |
| `@yyc3/conductor` | Phase 3 | 协同编排引擎（DAG/重试/超时真实，执行体靠注入） | 14 | 🟡 |
| `@yyc3/plugin-marketplace` | Phase 3 | Plugin Marketplace 运行时（可选 Store 持久化；无落盘安装） | 32 | 🟡 |
| `@yyc3/skill-sandbox` | Phase 3 | 沙箱净化层（Node/Python/Shell；S0-1 已接线，非 OS 强边界） | 76 | 🟡 |
| `@yyc3/agent-runtime` | Phase 4 | Agent 智能体运行时（3032 同构收敛：fail-closed 认证/限流/安全头 + 可选 Store 持久化；对话注入/工具只发事件） | 65 | 🟡 |
| `@yyc3/orchestrator` | Phase 4 | 智能编排调度器（中文规则真实，LLM 分解未实现） | 39 | 🔴 |
| `@yyc3/observability` | Phase 4 | 可观测性监控（histogram 累计桶+_sum/_count+labels 分区+maxSeries；logger maxEntries；tracer OTLP） | 65 | 🟡 |
| `@yyc3/store` | Phase 5 | 持久化抽象层（Store 接口 + Memory/File 原子写/Redis lazy 三适配器） | 23 | ✅ |
| `@yyc3/agent-registry` | Phase 4 | Agent 角色注册表（数据资产，非 TS 包） | — | 📊 |
| `@yyc3/skill-registry` | Phase 5 | Skill 注册中心（loader 接 validator + reload sync 语义；callId crypto 化） | 83 | ✅ |

## Phase 5: 生产就绪（资产平台面）

> 下表状态为 2026-09-26 代码核对结果；智能运行时面的"生产就绪"宣称已收敛至 README 状态矩阵。

| 能力 | 内容 | 状态 |
| ------ | ------ | :---: |
| 🐳 **Docker** | 多阶段构建 + compose 三服务；S0-1 加固（非 root/cap_drop ALL/read_only/no-new-privileges/限额/回环绑定） | ✅ |
| 🔄 **CI/CD** | GitHub Actions 矩阵构建 (Node 22/24) + Release + 三镜像冒烟 | ✅ |
| 📖 **API 文档** | OpenAPI 3.1 规范存在，但与实现有漂移（认证描述相反/缺端点与 401/429/413） | 🟡 |
| 🔐 **安全加固** | fail-closed 认证/限流/安全头/执行链控制点/容器隔离已落地；XFF 伪造、CSP/HSTS 缺失为已知缺口 | 🟡 |
| ⚡ **性能优化** | Tree Shaking / Bundle 分析 / Turbo 构建缓存 | ✅ |
| 🛠️ **技能/插件** | AYNC 模板生成器 / 标准化 ID / doctor 六检门禁 | ✅ |

## 质量基线 (2026-09-26)

| 指标 | 值 |
| ------ | :--: |
| TypeScript 包 | 14 |
| 测试文件 | 58（51 TS + 7 CLI/JS） |
| 测试用例 | **1197 全绿**（中/英 locale 双跑，2026-09-26 P2 二批收口后逐包实测） |
| doctor 门禁 | 六检 PASS（validate/dedup/score/registry/graph/example） |
| 技能资产 | 831（0 errors / 0 warnings，26 类别） |
| Build 通过率 | 11/11 |
| Typecheck 通过率 | 14/14 |
| ESLint | 0 error |
| i18n 框架 | @yyc3/i18n-core **3.0.0**（631 用例；深合并注册 + `ready` 承诺） |

> 历史基线（2026-09-02：46 文件 / 929 用例 / 9 包 typecheck）保留于 git 历史。
