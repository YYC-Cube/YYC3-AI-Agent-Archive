# YYC³ 贡献指南

> 面向核心平台开发者的协作规范。资产（Skill/Agent/Plugin/MCP/Tool）贡献见各 hub 的 README。

## 一、环境要求

| 工具 | 版本 | 说明 |
| ---- | ---- | ---- |
| Node.js | ≥ 20 | 推荐 22 LTS |
| pnpm | ≥ 9 | `npm i -g pnpm@9` |
| TypeScript | 5.9.3 | 根 `devDependencies` 钉版 |
| tsup | 8.4.0 | **精确钉版**，禁止 8.5.x（.cts bug，egoist/tsup#1375） |

```bash
pnpm install
pnpm run build
```

## 二、Monorepo 结构

```
packages/
├── skill-registry/     # Skill 注册中心（扫描/解析/校验/执行/熔断）
├── skill-gateway/      # Skill Gateway API（REST/Hono/安全中间件）
├── skill-sandbox/      # Skill 沙箱执行环境（Node/Python/Shell）
├── mcp-runtime/        # 统一 MCP 运行时
├── agent-runtime/      # Agent 智能体运行时
├── agent-registry/     # Agent 注册中心
├── orchestrator/       # 智能编排调度器
├── conductor/          # 协同编排引擎
├── plugin-marketplace/ # Plugin Marketplace 运行时
├── observability/      # 可观测性监控
├── store/              # 持久化抽象层（Memory/File/Redis）
├── yyc3-cli/           # yyc3 CLI
├── yyc3-i18n/          # i18n 框架
└── @yyc3/icons/        # Lucide 图标子集（只读）
```

**依赖方向**（不得反向）：
```
skill-gateway → skill-registry → skill-sandbox
mcp-runtime → skill-registry
conductor → orchestrator → agent-runtime
```

## 三、开发工作流

### 3.1 分支策略

- `main`：生产分支，受保护，需 PR + CI 绿
- `chore/<scope>-<desc>`：依赖升级、工具链调整
- `feat/<scope>-<desc>`：新功能
- `fix/<scope>-<desc>`：Bug 修复
- 不使用 `dependabot/*` 分支直接合并（lockfile 未审计）

### 3.2 提交规范

遵循 Conventional Commits：

```
<type>(<scope>): <subject>

[optional body]

[optional footer(s)]
```

| type | 说明 |
| ---- | ---- |
| feat | 新功能 |
| fix | Bug 修复 |
| chore | 依赖升级、构建配置 |
| docs | 文档 |
| refactor | 重构 |
| test | 测试 |
| security | 安全修复 |

### 3.3 提交前检查清单

```bash
pnpm run lint          # ESLint
pnpm run typecheck     # tsc --noEmit
pnpm run test          # vitest（中英双跑：LANG=en_US.UTF-8 pnpm test）
pnpm run build         # tsup 构建
pnpm run doctor        # 六检质量门禁
```

**门禁标准**：0 error，warning 需说明理由。

## 四、代码规范

### 4.1 命名

- 目录/文件：英文 kebab-case
- 文档/注释：中文为主
- 包名：`@yyc3/*`

### 4.2 依赖治理

- **tsup**：所有子包 `devDependencies` 精确声明 `"tsup": "8.4.0"`（禁止 caret）
- **typescript**：根 `devDependencies` 精确 `"typescript": "5.9.3"`
- **新依赖**：先在对应子包 `package.json` 声明，根不随意加
- **pnpm.overrides**：pnpm 9.0.0 不读取 `package.json` 的 `pnpm.overrides`，钉版靠精确版本声明

### 4.3 安全红线

| 类别 | 要求 |
| ---- | ---- |
| 命令黑名单 | SkillSandbox.execute 必须校验 28 条黑名单（rm/sudo/chmod/killall 等） |
| 路径隔离 | 入口路径限制在 skill 源根，禁止路径穿越 |
| 环境变量 | 子进程仅白名单 9 个变量，排除主机 API Key |
| 超时 | 30s–300s，0/负/NaN 重置默认 |
| 输出 | stdout/stderr 各 1MB 上限 |
| 端口 | 未认证服务绑定 127.0.0.1 |
| 认证 | 除 `/health` 和 `/` 外全部 Bearer/X-API-Key |
| 请求体 | 1MB 上限 + Zod 校验 |
| 限流 | token bucket 100 req/min |

## 五、PR 流程

1. Fork / 分支 → 开发 → 本地全量门禁
2. 提交 PR，标题遵循 Conventional Commits
3. CI 自动运行 lint/typecheck/test/build + skills 审计
4. 至少 1 名 maintainer review
5. Squash merge 至 main

## 六、问题反馈

- Bug：GitHub Issues，附复现步骤 + 期望/实际行为
- 安全问题：**不要公开 Issue**，邮件 `admin@0379.email`
- 讨论：GitHub Discussions

---

**YanYuCloudCube** · 言启千行代码，语枢万物智能
