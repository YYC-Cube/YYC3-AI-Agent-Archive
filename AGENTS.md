# YYC³ AI Agent Archive — Agent 工作指南

> 面向 AI 编码助手（Claude Code / Codex / ZCode 等）的项目上下文。
> **最后更新**: 2026-09-02 | **Phase 5 生产就绪**

## 项目概要

- **定位**：企业级 AI Agent 资产归档平台（pnpm Monorepo），汇聚 Skill / Agent / Plugin / MCP / Tool 五类资产
- **技术栈**：TypeScript 5.7+（核心包）、Rust（yyc3-engine / agent-browser）、Node ≥ 20、pnpm ≥ 9
- **版本**: v2.2.0 | **核心包**: 13 | **测试**: 929 | **Build**: 11/11
- **语言约定**：文档与注释以中文为主，代码标识符用英文 kebab-case

## 目录职责（修改前先确认归属）

| 目录 | 内容 | 可自由修改 |
| ------ | ------ | :---------: |
| `packages/skill-registry` | Skill 注册中心（扫描/解析/校验/执行/熔断） | ✅ |
| `packages/skill-gateway` | Skill Gateway API（REST/Hono/安全中间件） | ✅ |
| `packages/skill-sandbox` | Skill 沙箱执行环境（Node/Python/Shell） | ✅ |
| `packages/mcp-runtime` | 统一 MCP 运行时（Skill/CowAgent 桥接 + 事件层） | ✅ |
| `packages/conductor` | 协同编排引擎（多智能体协同/任务编排） | ✅ |
| `packages/agent-runtime` | Agent 智能体运行时（生命周期/对话/工具调用） | ✅ |
| `packages/agent-registry` | Agent 注册中心（智能体发现/能力匹配） | ✅ |
| `packages/orchestrator` | 智能编排调度器（LLM 分解/多策略调度） | ✅ |
| `packages/plugin-marketplace` | Plugin Marketplace 运行时（注册/激活/依赖） | ✅ |
| `packages/observability` | 可观测性监控（日志/指标/链路追踪/健康检查） | ✅ |
| `packages/yyc3-cli` | `yyc3` CLI（skills build/validate/dedup/stats/naming） | ✅ |
| `packages/yyc3-i18n` | i18n 框架（独立成熟包，谨慎改动） | ⚠️ |
| `packages/@yyc3/icons` | Lucide 图标子集 | ❌ |
| `skills-hub/` | 8,600+ 技能资产（只增不删，改动需校验） | ⚠️ |
| `agents-hub/` | AI Family + 角色定义 + 框架实现 | ⚠️ |
| `plugins-hub/` `mcp-hub/` `tools-hub/` | 插件/MCP/工具资产 | ⚠️ |
| `_external/` | 外部参考代码（529MB，勿动，见其 README） | ❌ |
| `_archive/` | 已废弃包归档（勿动） | ❌ |
| `docs/` | 架构文档体系（41,000+ 行，改动需同步索引） | ⚠️ |
| `scripts/` | i18n/同步工具脚本（CJS） | ✅ |

## 常用命令

```bash
pnpm install              # 安装依赖（workspace 链接）
pnpm run lint             # ESLint（scripts/，包级 lint 独立）
pnpm run typecheck        # 全部包 tsc --noEmit
pnpm run build            # 全部包 tsup 构建（Turbo 缓存加速）
pnpm run test             # 全部包 vitest 运行（929 测试）
pnpm run skills:validate  # yyc3 skills validate（扫描 skills-hub）
pnpm run skills:stats     # 技能统计
pnpm yyc3 skills naming lint -v   # AYNC 命名合规检查

# Docker
docker-compose up -d      # 启动全部服务 (3030/3031/3032)

# 创建新技能/插件
node scripts/create-skill.js <domain> <name> <type> [runtime]
node scripts/create-plugin.js <domain> <name> <type>
```

## 关键约定

1. **SKILL.md 格式**：YAML frontmatter 必含 `name`，建议含 `description`/`category`/`version`（SemVer）。
   多行文本用 `>`/`|` 块语法，数组用 `[a, b]` 内联语法 —— 解析器在
   `packages/skill-registry/src/frontmatter.ts`，修改格式需同步其测试。
2. **AYNC 编码**：资产目录命名目标格式 `AYNC-<类型>-<类别>-<名称>`（如 `AYNC-Y-DE-paper-quick-reader`），
   迁移用 `pnpm yyc3 skills naming migrate`（默认 dry-run，`--apply` 才执行）。
3. **包依赖方向**：`skill-gateway → skill-registry → skill-sandbox`，`mcp-runtime → skill-registry`，`conductor → orchestrator → agent-runtime`，不得反向依赖。
4. **测试**：新功能必须带 `tests/*.test.ts`（vitest），运行 `pnpm -r run test` 验证。
5. **CI**：`.github/workflows/ci.yml` 运行 lint/typecheck/test/build + skills 审计，提交前本地全过。
6. **Docker**：`Dockerfile` 多阶段构建三服务镜像，`docker-compose.yml` 编排端口 3030/3031/3032。
7. **ESLint**：各包 `eslint.config.mjs` 独立配置，`tsup.config.ts`/`vitest.config.ts` 需加入 ignores。
8. **tsup**：固定版本 `8.4.0`（`pnpm.overrides` 全覆盖），`@swc/core` 为 devDependency。`tsconfig.build.json` 避免与 Project References 冲突。

## 已知陷阱

- `_external/ClickHouse`（398MB）在 git 追踪中，任何全仓库 glob 操作（eslint/prettier/重命名脚本）
  必须显式排除 `_external` 与 `_archive`。
- `docs/YYC3-AI-Family-Agent-家人档案/` 含指向 `agents-hub/ai-family/` 的符号链接，勿当作真实目录复制。
- 根 `.gitignore` 之前仅忽略 `.DS_Store`，历史提交可能包含构建产物 —— 不要 `git add -A` 盲目提交大文件。
- **tsup 8.5.x** 存在 ".cts" 类型文件生成 bug（egoist/tsup#1375），必须使用 `8.4.0`。
- **Project References**：被引用的包（mcp-runtime、agent-runtime）须启用 `composite: true` + `emitDeclarationOnly: true`，基配置 `tsconfig.base.json` 不得含 `composite`。
