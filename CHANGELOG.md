# Changelog

All notable changes to YYC³ AI Agent Archive will be documented in this file.

## [2.4.0] - 2026-09-22

### 版本主题：Supply-Chain Hardened（供应链加固 + MCP 生态卡位 + 智能评分）

蓝图五阶段（E–I）全部落地，项目评分预期 90.0 (A−) → 96 (A+)。

### 供应链三防线（Phase E/F）

- **Dependabot vendor 告警清零**：`scripts/dismiss-vendor-alerts.mjs`（Link-header 手动翻页 + `--apply --yes` 双保险 + 限流重试），565 条参考资产告警 dismissed，核心 12 项保留跟踪
- **Actions SHA 锁定**：`scripts/pin-actions-sha.mjs` 表驱动替换，4 workflow 30 处 uses 全部 pin 到 commit SHA + `# vX` 注释（防 tag 劫持/投毒）
- **dependency-review PR 门禁**：ci.yml 新增 job，`fail-on-severity: high` 阻断高危依赖引入（供应链第三层）

### MCP Registry 生态（Phase G）

- **CLI `skills export-mcp`**：831 技能 → 官方 server.json 格式（namespace `io.github.yyc-cube/<slug>`，schema pin 2025-12-11）；46 组 slug 碰撞逐级拼父目录消歧，全局唯一
- **Gateway 聚合 API**：`GET /api/v1/registry[/servers[/:slug]]`（mtime 缓存，REGISTRY_NOT_EXPORTED 404 引导）
- **静态分发**：`public/registry/` 832 文件随 Pages 上线（`https://ai-agent.yyc3.vip/registry/registry.json`）
- **CI schema 门禁**：`scripts/validate-mcp-registry.mjs`（ajv draft-07 校验官方 schema，零新增依赖）

### 智能评分体系（Phase H）

- **CLI `skills score`**：五维加权（元数据 25%/文档 20%/资产健康 25%/活跃度 15%/安全 15%），0–100 + A–E
- 首份报告归档 `docs/skill-score/`：831 技能均分 80，A:110/B:503/C:217/D:1/E:0，低分 TOP20 治理清单

### 治理收尾（Phase I）

- **I1 口径统一**：release 冒烟 `/api/v1/health/version` 与路由表核对一致（文档收口，无代码改动）
- **I2 skills 卷生产化**：镜像内置 community SKILL.md 快照（~4.4MB，开箱 total>0）；server.ts 空载 WARN；`docker-compose.skills.yml` override 支持外部卷注入
- **I3 dedup 四分类**：默认忽略构建产物/依赖目录；重复组分类 license-template/reference-asset/build-artifact/genuine（实测 14/163/1/3529），genuine 聚焦真实裁决
- **I4 断供演习 runbook**：`docs/runbooks/上游断供演习-Runbook.md`（GitHub/npm/Pages 三场景 + 季度/半年排期 + 记录节）

### 质量

- 新增测试：CLI scorer 22 用例（jest）+ gateway registry 5 用例（vitest 36/36）
- 全门禁绿：tsc 0 errors / eslint 0 errors / coverage ≥75% 分支门禁不降

## [2.3.0] - 2026-09-17

### 版本发布（v2.3.0）

- 全部 @yyc3 包版本 bump：skill-gateway 1.1.0 / mcp-runtime 1.2.0 / agent-runtime 1.1.0 / skill-registry 1.1.1 / skill-sandbox、plugin-marketplace、conductor、orchestrator、observability 1.0.1 / i18n-core 2.4.3（防 registry latest 回退）

### CI/CD（发布流水线）

- Release workflow 新增 docker job：buildx 构建三镜像（gha 缓存 scope 隔离）→ compose 冒烟 8 项断言 → 通过后推送 GHCR（tag + latest）
- docker-compose.yml 镜像名参数化：`${IMAGE_PREFIX:-yyc3}/...:${TAG:-local}`，CI 复用刚构建镜像免二次构建
- mcp-runtime 分支覆盖率 72.09% → 86.04%（补无执行器路由 ×3、tool:failed 事件 4 个测试），全门禁提至 75%
- turbo test 缓存禁用（cache: false），杜绝缓存假绿
- server.ts HTTP 引导层排除出单测覆盖率统计（由容器冒烟验证）

### Docker 实机冒烟闭环（P0-2 完成 · 生产就绪全链路闭环）

#### 新增

- **三服务独立入口**：`skill-gateway/src/server.ts`（组装 registry/loader/executor + gateway.start）、`mcp-runtime/src/server.ts`（Hono 暴露 `/health` + `/api/v1/tools` + `/api/v1/tools/call`）、`agent-runtime/src/server.ts`（`/health` + `/api/v1/profiles` + `/api/v1/agents` 创建 AI Family 实例）；tsup entry 同步加入 server.ts
- **mcp-runtime / agent-runtime 补齐 hono + @hono/node-server 依赖**（此前为纯库包，无 HTTP 服务能力）

#### 修复

- **Dockerfile healthcheck**：`localhost` 在 busybox wget 中解析为 `::1`（IPv6）而服务绑定 IPv4，Connection refused 导致容器永远 unhealthy → 改用 `127.0.0.1`；路由修正为实际存在的 `/api/v1/health`
- **pnpm workspace 运行时依赖缺失**：镜像仅拷贝根 node_modules，包级依赖（symlink 到 .pnpm）丢失，`ERR_MODULE_NOT_FOUND: hono` → 三运行阶段补拷贝 `packages/*/node_modules`
- **构建上下文缺失**：.dockerignore 排除了 `tsconfig*.json`（frozen-lockfile 校验需要）→ 保留；deps 阶段补 `COPY turbo.json`（`pnpm turbo build` 前置条件）
- **compose healthcheck** 补 `start_period: 10s` 防启动期误判；移除过时的 `version` 字段

#### 验证记录

- 容器编排：`skill-gateway`(3030) / `mcp-runtime`(3031) / `agent-runtime`(3032) 三容器全部 **healthy**
- API 冒烟 8/8 通过：gateway health/version/skills、mcp health、agent health/profiles/创建实例（QianHang-1）、安全头（x-frame-options/x-content-type-options/referrer-policy）
- 回归：typecheck 13/13、build 11/11、test 22/22 全绿

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
