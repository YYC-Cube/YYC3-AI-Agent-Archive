# AI-Family 统一架构（整合后 v3 — 2026-09-02，Phase 5 生产就绪）

| Hub | 内容 | 数量 |
|-----|------|:---:|
| agents-hub/ai-family/ | AI Family 8位家人（docs/下重复已删除，符号链接保留） | 8 |
| agents-hub/cowagent/ | CowAgent Python 框架（外部，→ _external/） | ~50+ |
| skills-hub/community/ | 社区技能 | ~283 |
| skills-hub/marketplace/ | 市场化技能 | ~121 |
| skills-hub/ai-ml/nvidia-skills/ | NVIDIA 官方技能 | **202** |
| skills-hub/b2b/ | B2B SDR 技能（b2b-skills 重复已删除） | 8 |
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
| mcp-hub/claude-prompts/ | MCP 提示词服务（整合后） | 1 |
| docs/ | AI Family 完整文档体系 + 架构文档 | ~70 |
| system prompt | docs/ 单一权威源（agents-hub 副本已删除） | 1 |

## 新增核心包 (Phase 3-5)

| 包 | 阶段 | 功能 | 测试 |
|----|------|------|:---:|
| `@yyc3/skill-gateway` | Phase 3 | Skill Gateway API (REST/Hono) | 16 |
| `@yyc3/conductor` | Phase 3 | 协同编排引擎 | 14 |
| `@yyc3/plugin-marketplace` | Phase 3 | Plugin Marketplace 运行时 | 29 |
| `@yyc3/skill-sandbox` | Phase 3 | 沙箱执行环境 (Node/Python/Shell) | 28 |
| `@yyc3/agent-runtime` | Phase 4 | Agent 智能体运行时 | 42 |
| `@yyc3/orchestrator` | Phase 4 | 智能编排调度器 | 24 |
| `@yyc3/observability` | Phase 4 | 可观测性监控 | 42 |
| `@yyc3/agent-registry` | Phase 4 | Agent 注册中心 | — |

## Phase 5: 生产就绪

| 能力 | 内容 | 状态 |
|------|------|:---:|
| 🐳 **Docker** | 多阶段构建 + docker-compose 三服务编排 | ✅ |
| 🔄 **CI/CD** | GitHub Actions 矩阵构建 (Node 20/22) + Release | ✅ |
| 📖 **API 文档** | OpenAPI 3.1 规范 (Skill Gateway) | ✅ |
| 🔐 **安全加固** | 速率限制 / 安全头 / 沙箱隔离 / 密钥管理 | ✅ |
| ⚡ **性能优化** | Tree Shaking / Bundle 分析 / 构建缓存 | ✅ |
| 🛠️ **技能/插件** | AYNC 模板生成器 / 标准化 ID | ✅ |

## 质量基线 (2026-09-02)

| 指标 | 值 |
|------|:--:|
| TypeScript 包 | 13 |
| 测试文件 | 46 |
| 测试用例 | 929 |
| Build 通过率 | 11/11 |
| Typecheck 通过率 | 9/9 |
| ESLint 诊断 | 0 |
