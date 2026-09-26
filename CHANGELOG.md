# Changelog

All notable changes to YYC³ AI Agent Archive will be documented in this file.

## [Unreleased]

### P1 三项整改 + Pages 落地页重构（2026-09-26 续会话）

- **P1-1 agent-runtime 优雅停机**：SIGTERM/SIGINT 由 `process.exit(0)` 改为 `server.close → runtime.flushPending() → store.close() → exit(0)`；10s 超时兜底；每步 try/catch 失败仅告警不阻断。修复"容器被强杀丢在途写入"风险
- **P1-2 限流器真 Token Bucket + TTL（agent-runtime + mcp-runtime server-security.ts）**：固定窗口重置 → 按经过时间连续补充令牌（`refillTokens = elapsed/window * max`），消除窗口边界突发；新增 `setInterval` 定期清理 > `2×windowMs` 未访问的桶，防 Map 内存泄漏；对齐 gateway MemoryStore 既有实现
- **P1-3 输出截断字节化（registry + sandbox executor.ts）**：`string.length`（字符数）→ `Buffer.byteLength()`（字节数）；`slice` → `Buffer.slice`（自动对齐 UTF-8 字符边界）。修复中文等多字节 UTF-8 内容致实际输出超 1MB 的内存 DoS 风险
- **Pages 落地页重构（ai-agent.yyc3.vip）**：基于 YYC³ HTML 设计指导文档与 YYC-CUBE-HUB.html 设计系统重构 `public/index.html`——完整 CSS 变量六色体系 + 明暗主题（FOUC 安全）、权威 logo 引用（favicon/apple-touch-icon）、Hero 品牌顶图 4:1 原比例展示、Hero/Stats/资产矩阵/AI Family 8 位家人(3 层)/五高架构/技术栈/Footer 全区块、数字滚动/入场动画/主题切换/移动端响应

### P2 池二批：治理收尾（2026-09-26）

- **P2 callId crypto 化（skill-registry 1.3.0 + mcp-runtime 1.5.0）**：执行/工具调用 ID 由 `Date.now()`/`Math.random` 改 `crypto.randomBytes(8)`——同毫秒并发不碰撞、非密码学随机面消除
- **P2 cowagent 桥接加固（mcp-runtime）**：`stdin.write` 增 EPIPE 监听（子进程先退出时不再作为进程级异常崩溃 Node）；stdout/stderr 单流 1MB 上限 + 截断标记（与 skill-registry executor 同口径）
- **P2 reload sync 语义（skill-registry 1.3.0 + gateway 1.4.0）**：`SkillRegistry.clear()`（逐个发 `skill:unregistered`）+ `LoaderOptions.sync` / `SkillLoader.reload()`；`POST /skills/reload` 改用 reload——磁盘为唯一事实源，已删除技能与幽灵注册一并清除（此前只增不删、残留可执行）
- **P2 限流 fail-open 告警 + CORS env 化（gateway 1.4.0）**：存储 consume 连续失败首次与每第 5 次告警（恢复清零，不再静默）；`YYC3_CORS_ORIGINS` 逗号分隔白名单（未配置保持 `*` 兼容）
- **P2 观测无界增长封顶（observability 1.2.0）**：`Logger.maxEntries`（默认 1000 环形裁剪，0=不留内存）；`MetricsRegistry({ maxSeries })`（默认 10_000，新分区超限丢弃+一次性告警，既有分区不受影响）
- **P2 plugin-marketplace 接 Store（1.0.1 → 1.1.0）**：`store?` 配置——install/update/activate/deactivate/remove 写穿 + `restore()` 重启恢复 + `flushPending()`；"插件注册表重启即失"闭环
- **P2 CLI 杂项修复（yyc3-cli）**：端口段 3030-3039 放行（对齐团队「3030 起」规范，3000-3029/3100-3199 仍限用）；`config --set` 死分支修复（Commander 双占位符不合法 → `--set <key>=<value>` + 数字/布尔/JSON 自动转型）；删除 0 字节 `lib/i18n.js`；init 模板 package.json 补 `express` 依赖声明
- **P2 `.env.example` 重写 v2.0.0**：删除虚构基础设施（Postgres/DB_*、API_PORT=8000、REDIS_HOST 三件套）；仅保留仓库内真实消费项（YYC3_API_KEYS/TRUSTED_PROXY_HOPS/CORS_ORIGINS、REDIS_URL、STORE_*、AGENT_STORE_FILE、OTEL_*、MCP_HOST），附消费方速查表
- **测试超时修正（yyc3-cli）**：T14/T16 全量评分 jest timeout 90s → 190s（对齐其自身 elapsed<180s 断言——超时窄于断言导致慢速环境先被掐死）
- **P2 mcp-hub 双轨裁决（方案 B 拆分处置）**：`server/`（@yyc3/mcp-server，与 mcp-runtime 功能双轨的死代码：无构建/无测试/不在 workspace）+ 零引用的 `gateway/`、`client/` 归档至 `_archive/mcp-hub-dual-track-code/`（附归档说明）；mcp-hub 保留资产定位——`claude-prompts/`（vendored 上游参考镜像）+ `mcp/`（运维配置 JSON）+ `mcp-servers/`（指南），新增定位声明 README；README 已知缺口表第 6 项 🟡→✅。至此 P2 池全部闭环

### S1 收尾后 P2 池首批（2026-09-26）

- **P2 chunked body 实际字节计数（gateway 1.3.0 + mcp-runtime 1.4.0）**：请求体限制原只校验 `Content-Length`，chunked 传输直接绕过；现包装请求体为计数流（累计超 1MB 即取消上游并报错），经 `safeJson` re-throw + onError 映射为 413 `PAYLOAD_TOO_LARGE`（三服务同一契约）
- **P2 CSP/HSTS 安全头补齐（gateway + mcp-runtime + agent-runtime）**：新增 `Content-Security-Policy: default-src 'none'; frame-ancestors 'none'; base-uri 'none'`（纯 JSON API 零前端资源）与 `Strict-Transport-Security: max-age=31536000; includeSubDomains`（明文传输下 UA 按规范忽略本头，无条件发送安全）
- **P2 Store 持久化抽象层（新包 @yyc3/store 1.0.0，23 用例）**：`Store` 接口（get/put/delete/keys/clear/close）+ 三适配器——`MemoryStore`（测试/默认）、`FileStore`（单文件 JSON、tmp+rename 原子写、防抖落盘、懒加载单例 promise 防并发乱序、损坏快照视为空库）、`RedisStore`（lazy ioredis + SCAN 游标遍历 + 失败降级）；`createStoreFromEnv()` 按 `REDIS_URL`/`STORE_FILE`/`STORE_MEMORY` 环境选择
- **P2 agent-runtime 3032 同构收敛（1.1.0 → 1.2.0，42→65 用例）**：复刻第十六章 mcp-runtime 模式——默认绑定 127.0.0.1（`AGENT_HOST` 可覆盖）、fail-closed API Key 认证（`YYC3_API_KEYS`，未配置 /api 503；/health 与 / 公开）、内存 Token Bucket 限流 + XFF 受信跳数、安全头（含 CSP/HSTS）、请求体限制（含 chunked 计数）、App 工厂化（`createAgentServerApp`）便于测试、POST 边界校验（非法 JSON/缺 profileName→400）；新增 `GET /api/v1/agents/:id`
- **P2 agent 会话持久化接线**：`AgentRuntimeConfig.store?: Store`——创建/状态/消息/内存写穿落盘，`restore()` 启动恢复，`flushPending()` 等待在飞写入（优雅停机）；`AGENT_STORE_FILE` 环境变量启用（compose 透传，挂载卷内 JSON 重启可恢复）；"agent 会话重启即失"闭环
- compose agent-runtime 补 `AGENT_HOST=0.0.0.0`/`YYC3_API_KEYS`/`YYC3_TRUSTED_PROXY_HOPS`/`AGENT_STORE_FILE`；release.yml 冒烟升级 9/9（新增"无凭据 /api 必须被拒"断言，认证后请求带 key）

## [2.7.0] - 2026-09-26

### 版本主题：Security-Hardened + Registry Ecosystem（安全纵深 + 资产生态）

v2.6.0（关联维度图谱）之后的收口版本：以 S0/S1 安全与质量整改为主线，叠加语义配对与 registry 生态元数据增强。全量 1135 测试中英双跑全绿，doctor 六检 PASS。

### Registry 生态 + 语义配对（v2.7.0 特性）

- **语义配对兜底减半孤立节点**（149 → 74 → 1.1%）：family-pairing fallback 与二次迭代，关联维度图谱孤立率持续下降
- **Registry 生态元数据**：技能资产新增 `repository`/`website` + related backfeed 声明
- **Registry 浏览器页面**：新增可视化浏览入口

### S0/S1 安全与质量整改（2026-09-25 ~ 2026-09-26）

详见 `docs/YYC3-AI-Agent-Archive-trae-20260925/00-项目现状审核报告.md`（第十一～十四章）。

- **S0-1 执行隔离链修复**：skill-registry ↔ skill-sandbox 依赖链接线；entry 路径穿越收敛、子进程环境变量白名单、命令黑名单接入执行路径、超时钳制、输出 1MB 上限；compose 容器加固（no-new-privileges/cap_drop ALL/read_only/资源限额/回环绑定）；新增 40 个对抗测试
- **S0-2 能力宣称对齐**：README 新增实现状态矩阵（四级成熟度，逐包/逐能力附代码证据），数字与安全表述全面纠偏
- **S1 i18n locale 漂移修复**：Node ≥21 不再采信 undici navigator 的宿主 LANG；`formatRelativeTimestamp` 修正 timezone/locale 参数错位；CI 显式钉 LANG；中文裸环境门禁转绿
- **S1 Gateway 边界（P1-1/P2-2）**：限流改受信代理跳数解析（`YYC3_TRUSTED_PROXY_HOPS`，默认 0 直连不信 XFF），伪造 XFF 不再能绕限流；execute/mcp-call/列表查询接 Zod 4，非法 JSON/null body→400，timeout 钳制 [1s, max]；gateway 1.2.0
- **S1 MCP Runtime 收敛（P1-2，@yyc3/mcp-runtime 1.3.0）**：独立服务默认绑 127.0.0.1（MCP_HOST 可覆盖）；新增契约对齐 gateway 的安全层——`/api` 全部 fail-closed API Key 认证（无 key 503）、内存限流+XFF 跳数、安全头、1MB body、非法 JSON 400；app 工厂化便于测试；compose 透传认证/跳数配置
- 修复 i18n secret-equal 计时断言高负载 flake（hrtime 纳秒计时，生产代码未动）
- **S1 资产加载校验（P1-3，@yyc3/skill-registry 1.2.0）**：`SkillLoader.load()` 注册前默认接 `validateUnifiedSkill`，非法 domain/非 SemVer version/自引用 fallback 等非法资产拒绝注册、进 `quarantine` 并发 `skill:quarantined` 事件，与 doctor 共用同一校验函数（单一事实源）；`validate:false` 保留宽容模式
- **S1 OpenAPI 漂移修正（gateway）**：`openapi.yaml` 1.0.0 → 1.2.0 与实现一致——删除"不强制认证"错误表述，补 `securitySchemes.apiKey`、401/403/429/413 响应与错误码枚举；补文档化 `/api/v1/registry{,/servers,/servers/{slug}}` 三端点；Skill 模式补 required/枚举对齐 Zod 边界
- **S1 可观测性修正（P1-6，@yyc3/observability 1.1.0）**：histogram 改累计桶（le=X 含所有 ≤X 观测值）、导出补 `_sum`/`_count`、labels 参与分区并在 Prometheus 输出渲染为 `name{k="v"}`；新增 `.with()` 绑定子实例；tracer ID 改用 `crypto.randomBytes`（traceId 32hex/spanId 16hex 对齐 W3C/OTLP）、父 span 缺失时保留 parentId 并支持上游 traceId 继承；新增 OTLP HTTP exporter（`OTEL_EXPORTER_OTLP_ENDPOINT` 控制，未配置自动禁用）
- **BREAKING（@yyc3/i18n-core 2.4.3 → 3.0.0）**：
  - `registerTranslation()` 由整表替换改为**深合并**——修复 MCP `add_translation_key` 增量注册单键抹掉整语言包的产品缺陷；新增 `replaceTranslation()` 保留旧整表替换语义
  - 新增 `i18n.ready: Promise<void>` 初始语言包就绪承诺（浏览器自动检测场景消除构造期翻译竞态）；懒加载到达时与飞行中注册的键合并而非互相覆盖

## [2.6.0] - 2026-09-24

### 版本主题：Association-Dimension Graph（关联维度图谱）

从「Quality-Gated」演进为「Graph-Aware」：831 技能资产新增关联维度（Association Dimension）分析——双层边模型 + PageRank 枢纽识别 + 连通分量/孤立率度量 + 显式声明建议引擎。

### 关联维度图谱引擎（核心）

- **双层边模型**：explicit（frontmatter `related_skills`/`depends_on`，权重 2）+ implicit（正文提及，权重 1）；`skills-graph.js` 单一引擎四输出（summary/hubs/clusters/nodes）
- **简化 PageRank**：20 轮迭代、damping 0.85，识别核心枢纽技能（hub 排名）
- **并查集连通分量**：孤立节点率、最大连通分量、边密度（密度过高的重写信号）
- **领域簇聚合**：按 domain 分簇（簇技能数总和 = 总节点，测试断言自洽）
- **首份图报告**：`docs/skill-score/graph-report.{json,md}` — 831 节点 / 937+ 边 / 孤立率 ~18% / top hub

### related_skills 建议引擎 + 批量补全

- **`yyc3 skills graph-suggest`**（dry-run / `--apply` / `--top-n` / `--min-confidence`）：从 implicit 边推导显式声明候选
- **置信度算法**：双向提及 +3（最强信号）/ 同领域 +1 / 每条单向提及 +1；阈值 4、Top 5
- **批量落地**：117 个 SKILL.md frontmatter 追加 `related_skills` 声明——262 候选全部置信度 5（双向+同领域最高档）
- **图谱提升**：explicit 边 0 → 78（去重后）；孤立节点 149 保持（写入关联均指向非孤立节点）；validate 零回归
- 候选清单归档：`docs/skill-score/related-skills-suggestions.json`

### Doctor 六检 + 发布闭环增强

- **第六检 graph**（信息性，永不阻断）：孤立率 > 25% WARN——积累期看板信号
- **Job Summary 可视化**：doctor 检测 `GITHUB_STEP_SUMMARY` 环境变量自动追加 Markdown 报告（CI Actions 页直接可见六检表格 + 评分 + 图指标）
- **advisory 模式**（`doctor --advisory`）：新检查灰度期失败仅报告不阻断（exit 0），CI 渐进接入
- **baseline-advance 自动闭环**（release.yml）：tag 触发 → gen-baseline 新基线 → doctor GATES.baseline 同步 → 测试断言更新 → 自动开 PR（人工确认合入）—— 本版本首次实跑演示
- **example 检修复**：容忍 `ERR_PNPM_IGNORED_BUILDS`（esbuild postinstall 被忽略属 P2-3 预期决策，esbuild 二进制由平台 optional dep 提供；门禁以实际 vite build 结果为准）

### P2/P3 治理收尾

- **D 级技能清零（D:1 → 0）**：`security-context: audit` 声明式豁免——安全审计类技能（skills-security-check）正文以检测目标身份引用攻击模式属合法语境；body 豁免但 scripts/ 始终扫描，安全下限 80
- **vendor 告警周度清理**：`vendor-alerts-cleanup.yml` 每周一自动 dismiss 参考资产 Dependabot 告警（核心依赖保留跟踪）
- **esbuild postinstall 白名单**：评估后关闭（维持不批准构建脚本的供应链立场）

### 统计

- 版本跨度：`v2.5.0..v2.6.0` 共 11 commits（feat 3 / fix 1 / test 1 / docs 4 / chore 2）
- CLI 测试：62/62 全绿（+图谱 4 用例）；doctor 六检本地 + CI 双绿
- 资产变更：117 个 SKILL.md（related_skills 声明）+ 4 个 CLI 模块

## [2.5.0] - 2026-09-23

### 版本主题：Doctor Integrated Quality Gate（质量门禁一体化）

从「Supply-Chain Hardened」演进为「Quality-Gated」：全资产质量由 doctor 四检门禁看守，版本发布携带评分基线。

### 漏洞清零（V1）

- **12 项 Dependabot 告警清零**（4 high / 7 moderate / 1 low，open 12 → 0）：example lockfile 从零重解析，nanoid 3.3.19 / postcss 8.5.28 / browserslist 4.29.0 / @babel/core 7.29.7 / baseline-browser-mapping 2.11.25 / esbuild 0.25.12 / vite 6.4.3
- **三层 pre-existing 缺陷一并修复**（v2.2.0 起潜伏，因 example 从未入 CI 而漏网）：
  - `file:..` off-by-one → `file:../..`（原指向无 package.json 的 examples/ 目录）
  - example 代码对齐 i18n 单例新 API（initI18n/addTranslations → registerTranslation/setLocale）
  - vite.config 内嵌 node:crypto / node:timers/promises 浏览器 stub（i18n-core 桶导出含 Node-only 工具）

### Doctor 四检聚合门禁（V2）

- **`yyc3 doctor` 新命令**：validate（errors>0 fail）/ dedup（genuine >3600 WARN、>4000 fail）/ score（均分<78 或较基线降>2 分或 E 级新增或 D 级增长 fail）/ registry（schema 校验），退出码语义可直接作 CI 门禁
- **CI 独立 doctor job**（fetch-depth: 0 全量历史 — 浅克隆会使活跃度维度失真产生 D 级误报，实测验证）
- **root script `pnpm doctor`** 从串联两命令升级为单命令聚合
- 11 用例测试（含负向 4：均分下降/E 级新增/D 级增长/边界 -2 分），CLI 包 57/57

### 评分基线固化（V3）

- **`docs/skill-score/baseline-v2.5.0.json`**：版本固化基线（均分 80，A:110/B:503/C:217/D:1/E:0 + worst TOP10）
- doctor score 门禁改为固定基线优先、最近报告回落 — 报告更新不再引起门禁漂移
- `scripts/gen-baseline-v2.5.0.cjs`：基线再生成工具（版本演进复用）

### CI 构建矩阵扩展

- **example（vite-react-zh-cn）纳入 quality job**（node 22/24 双矩阵）：防 off-by-one/API 漂移回潮，实测 803ms/917ms

### 安全与文档治理（发布前全局审核）

- 🔴 P0：`.env.docker` / `.env.permissions` 补入 .gitignore（含密钥类变量，原存在误提交泄漏风险）
- README：doctor 口径更新（四检聚合）、i18n-core 版本 2.4.0→2.4.3 修正、CLI 描述补 Doctor
- docs/README.md 索引：补 runbooks/、skill-score/（含 baseline）、20260917 会话目录
- CLAUDE.md（AGENTS.md symlink 单一信源）：常用命令补 `pnpm run doctor`
- 审核报告归档：`docs/YYC3-AI-Agent-Archive-tutor-20260917/08-v2.5.0-全局审核与建议报告.md`（P1-P3 演进建议）

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
