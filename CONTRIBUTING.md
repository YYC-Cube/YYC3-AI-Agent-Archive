# 贡献指南（Contributing）

> 感谢关注 YYC³ AI Agent Archive！完整贡献规范见
> [`docs/developers/CONTRIBUTING.md`](docs/developers/CONTRIBUTING.md)，
> 本文件是快速入口。

## 快速开始

```bash
# 环境要求：Node >= 20 · pnpm >= 9
pnpm install
pnpm run build
pnpm run test        # 1,190+ 用例，需全绿
```

## 提交前必检（五检门禁）

```bash
pnpm run lint        # ESLint
pnpm run typecheck   # tsc --noEmit
pnpm run test        # vitest + jest（中英双跑）
pnpm run build       # tsup 全包构建
pnpm run doctor      # 六检质量门禁（validate/dedup/score/registry/graph/example）
```

全部通过后再提交 PR，标题遵循 [Conventional Commits](docs/developers/CONTRIBUTING.md#32-提交规范)
（`feat|fix|chore|docs|refactor|test|security(scope): subject`）。

## 关键约定（速览）

| 约定 | 要求 |
| ---- | ---- |
| 依赖方向 | `skill-gateway → skill-registry → skill-sandbox`、`mcp-runtime → skill-registry`、`conductor → orchestrator → agent-runtime`，不得反向 |
| 工具链钉版 | `tsup` 精确 `8.4.0`（8.5.x 有 .cts bug）、`typescript` 精确 `5.9.3` |
| 新功能 | 必须携带 `tests/*.test.ts` |
| 安全红线 | 命令黑名单 / 路径隔离 / env 白名单 / 超时钳制 / 认证 fail-closed，详见[贡献指南 §4.3](docs/developers/CONTRIBUTING.md#43-安全红线) |
| 资产目录 | 目标命名 `AYNC-<类型>-<类别>-<名称>`（skills-hub 只增不删） |
| 全仓操作 | 必须显式排除 `_external/` 与 `_archive/`（529MB 外部参考，勿动） |

## 行为准则

参与本项目即表示同意 [行为准则](CODE_OF_CONDUCT.md)。

## 报告问题

- Bug → [GitHub Issues](../../issues)（附复现步骤）
- **安全漏洞 → 不要公开 Issue**，邮件 `admin@0379.email`，见 [SECURITY.md](SECURITY.md)
- 讨论 → [GitHub Discussions](../../discussions)

## PR 流程

1. Fork / 分支（`feat|fix|chore/<scope>-<desc>`）→ 开发 → 本地五检
2. 提交 PR（使用 [PR 模板](.github/PULL_REQUEST_TEMPLATE.md)）
3. CI 全绿 + 至少 1 名 maintainer review
4. Squash merge 至 `main`

---

**YanYuCloudCube** · 言启千行代码，语枢万物智能
