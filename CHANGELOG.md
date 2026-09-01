# Changelog

All notable changes to YYC³ AI Agent Archive will be documented in this file.

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