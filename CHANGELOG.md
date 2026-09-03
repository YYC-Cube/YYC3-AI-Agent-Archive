# Changelog

All notable changes to YYC³ AI Agent Archive will be documented in this file.

## [2.2.1] - 2026-09-03

### 全链路 CI/CD 闭环（CI + Release + Security 三绿灯）

#### 工程修复
- **TypeScript 7.0.2 → 5.9.3 全量回滚**：TS7 为原生编译器，不提供 compiler API（`ts.sys`/`createProgram`），导致 rollup-plugin-dts 6.1.1 崩溃（skill-registry DTS 构建失败）。根因：Dependabot #59 批量升级。新增 `pnpm.overrides["typescript"]` 防止版本漂移
- **IDE 类型解析修复（skill-sandbox / skill-registry）**：包级 tsconfig 原排除 tests/，IDE 回退到无 `@types/node` 的推断项目（`process` 找不到、`SkillSandbox.on` EventEmitter 类型不解析）。现 `tsconfig.json` 覆盖 src+tests（IDE 与 typecheck 共用），`tsconfig.build.json`（composite:false, rootDir:src）供 tsup/dts 构建收窄，typecheck 脚本简化为 `tsc --noEmit`
- **解散 packages/yyc3-i18n 嵌套 workspace**：删除嵌套 `pnpm-workspace.yaml`/`pnpm-lock.yaml`，根安装覆盖其依赖；tsconfig 显式 `types: ["node"]`
- **分支改名同步**：默认分支 master → main，ci.yml/security.yml 触发分支同步更新；release.yml `target_commitish` 显式指向 `${{ github.sha }}`

#### Bug 修复
- **skill-sandbox**：stdin EPIPE 未处理错误（CI Linux 下 `sh -c` 提前退出导致）；`isCommandBlocked` 尾部斜杠/绝对路径误放行（`/bin/rm -rf /` 解析为空串）
- **skill-gateway**：errorHandler 中间件被 Hono 默认 onError 旁路（返回 text/plain 而非 JSON），改用 `app.onError`；`POST /execute` 执行失败仍返回 `ok:true`，现正确映射 500 + EXECUTION_ERROR
- **orchestrator**：stuck-task 检测基于 `remaining`（已过滤 failed）导致依赖失败链路永不触发，改扫描全量任务

#### 质量门禁（分支覆盖率达标）
- skill-registry：73.52% → 75.32%（补 executor 真实脚本/降级深度/half-open 恢复测试）
- orchestrator：67.21% → 88.52%（补重试/autoRetry=false/load-balance/依赖失败测试）
- skill-gateway：56.25% → 72.97%（补 execute 成功/失败、搜索过滤、生命周期测试）
- skill-sandbox：59.03% → 83.52%（补 native 校验/maxOutput 截断/AbortSignal 测试）
- observability：62.79% → 80.23%（补 logger 控制台分流/Prometheus 桶导出/tracer 边界测试）
- 修复 yyc3-i18n coverage 的 vitest CLI 参数解析（`Unknown option: 'coverage'`）

#### CI/CD
- Publish 步骤优雅降级：未配置 NPM_TOKEN 时跳过发布并输出配置指引，保持 Release 绿色
- v2.2.0 GitHub Release 成功发布；npm publish + GitHub Release 双 job 全绿

## [2.2.0] - 2026-09-02

### Phase 5: 生产就绪与生态扩展

#### Docker 容器化
- 多阶段构建 `Dockerfile`，基于 `node:20-alpine`
- `docker-compose.yml` 编排三服务：Skill Gateway (3030)、MCP Runtime (3031)、Agent Runtime (3032)
- `.dockerignore` 优化构建上下文

#### CI/CD Pipeline
- 增强 `.github/workflows/ci.yml`：矩阵构建 Node 20/22，全量包测试覆盖率
- 新增 `.github/workflows/release.yml`：npm 发布 + GitHub Release
- 新增 `.github/workflows/security.yml`：依赖审计 + 密钥扫描

#### API 文档化
- `packages/skill-gateway/openapi.yaml`：OpenAPI 3.1 规范，覆盖所有 API 端点
- 修复 YAML 语法错误（内联 Flow Mapping → Block Style）

#### 安全加固
- `packages/skill-gateway/src/middleware/security.ts`：Token Bucket 速率限制 (100 req/min/IP)
- 安全响应头：X-Content-Type-Options、X-Frame-Options、CSP、HSTS
- 请求体大小限制：1MB
- `SECURITY.md`：安全策略文档

#### 性能优化
- 所有 `tsup.config.ts` 添加 `treeshake: true`
- Turbo 构建缓存，Build 时间 3.3s

#### 技能/插件扩展
- `scripts/create-skill.js`：AYNC 技能/插件模板生成器，标准化 AYNC ID 生成

#### 工程修复
- 修复 tsup 8.5.x `.cts` 类型文件 bug：降级至 8.4.0 + `pnpm.overrides` 全覆盖
- 安装 `@swc/core` devDependency 解决 peer dependency 缺失
- 修复 TypeScript Project References 配置（composite/emitDeclarationOnly）
- 修复 tsconfig `baseUrl` 弃用警告 → 显式 `paths`
- ESLint 配置：`tsup.config.ts` 加入 ignores 避免 project references 解析错误
- 修复 openapi.yaml YAML 语法错误

## [2.1.0] - 2026-07-24

### Phase 4: 生态智能

#### Agent 智能体运行时 (`@yyc3/agent-runtime`)
- 智能体生命周期管理（创建/激活/休眠/销毁）
- 对话上下文管理（多轮对话、记忆窗口）
- 工具调用框架（注册/发现/执行）
- 多智能体通信协议
- 42 项测试

#### 智能编排调度器 (`@yyc3/orchestrator`)
- 基于规则的 LLM 任务分解
- 多策略调度：能力匹配/轮询/负载均衡
- 工作流执行引擎（DAG 依赖解析）
- 重试与降级机制
- 24 项测试

#### 可观测性监控 (`@yyc3/observability`)
- 结构化日志（JSON/Console/File）
- 多类型指标收集（Counter/Gauge/Histogram）
- 分布式链路追踪（Span/Trace）
- 健康检查框架
- 42 项测试

#### Agent 注册中心 (`@yyc3/agent-registry`)
- 智能体发现与能力匹配

### Phase 3: 平台能力构建

#### Skill Gateway API (`@yyc3/skill-gateway`)
- 基于 Hono 的 REST API
- 技能 CRUD 端点
- 安全中间件
- 16 项测试

#### 协同编排引擎 (`@yyc3/conductor`)
- 多智能体协同编排
- 任务编排与工作流执行
- 14 项测试

#### Plugin Marketplace 运行时 (`@yyc3/plugin-marketplace`)
- 插件注册/激活/停用/依赖管理
- 29 项测试

#### Skill 沙箱执行环境 (`@yyc3/skill-sandbox`)
- 多运行时安全隔离 (Node/Python/Shell/Native)
- 资源配额限制
- 28 项测试

## [2.0.0] - 2026-05-03

### 工程基座加固

- Monorepo 架构：7 核心 TypeScript 包
- 技能系统：标准化注册/发现/调度/降级熔断
- MCP 运行时：统一调度工具来源
- i18n 框架：零依赖引擎，10 种语言支持
- CLI 工具：技能构建/验证/去重/统计
- AYNC 统一分类编码体系
- 五高架构：高可用/高性能/高安全/高扩展/高智能