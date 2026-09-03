# 🏷️ Git Tagging 分层架构规范

> 远程标签管理标准 — 版本发布 / 生命周期 / 包级三维标签体系
> **最后更新**: 2026-09-02 | **适用**: YYC³ AI Agent Archive Monorepo

## 一、标签分层架构

```
┌─────────────────────────────────────────────────────────────┐
│                  Tag 三维分层架构                             │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  L1: 版本层 (Release)          → 触发 release.yml 发布流水线 │
│      v{major}.{minor}.{patch}                                │
│      示例: v2.2.0                                            │
│                                                              │
│  L2: 生命周期层 (Phase)        → 标记路线图里程碑，只读锚点   │
│      phase/{n}-{slug}                                        │
│      示例: phase/5-production-ready                          │
│                                                              │
│  L3: 包级层 (Package)          → 单包独立发布锚点             │
│      {pkg}@{version}                                         │
│      示例: @yyc3/skill-registry@2.0.0                        │
│                                                              │
│  命名总规则: 全小写、kebab-case、禁止空格与特殊字符            │
└─────────────────────────────────────────────────────────────┘
```

## 二、各层规范

### L1 版本层 — `v*`

| 属性 | 值 |
|------|-----|
| 格式 | `v{major}.{minor}.{patch}`（严格 SemVer，带 `v` 前缀） |
| 触发 | [release.yml](.github/workflows/release.yml)（npm 发布 + GitHub Release + CHANGELOG 注入） |
| 类型 | **annotated tag**（必须，携带发布说明） |
| 创建时机 | 对应版本 CI 全绿 且 CHANGELOG.md 已更新 |
| 预发布 | `v3.0.0-beta.1`（进入 prerelease 通道，不覆盖 stable） |

### L2 生命周期层 — `phase/*`

| 属性 | 值 |
|------|-----|
| 格式 | `phase/{n}-{slug}`，如 `phase/3-platform-capability` |
| 用途 | 路线图里程碑快照，用于回溯某阶段完整代码状态 |
| 类型 | annotated tag，message 注明阶段交付摘要 |
| 约束 | 每阶段**仅打一次**，不随 patch 更新 |

阶段对照表：

| Tag | 阶段 | 状态 |
|-----|------|:---:|
| `phase/1-foundation-hardening` | 工程基座加固 | ✅ 已交付 |
| `phase/2-asset-governance` | 资产治理 | ✅ 已交付 |
| `phase/3-platform-capability` | 平台能力构建 | ✅ 已交付 |
| `phase/4-ecosystem-intelligence` | 生态智能 | ✅ 已交付 |
| `phase/5-production-ready` | 生产就绪与生态扩展 | ✅ 当前 |

### L3 包级层 — `{pkg}@{version}`

| 属性 | 值 |
|------|-----|
| 格式 | `@yyc3/{pkg}@{semver}` 或独立包 `{pkg}@{semver}` |
| 用途 | Monorepo 中单包独立发版锚点（配合 changesets fixed/linked 策略） |
| 类型 | lightweight tag |
| 约束 | 仅在单包独立发布时使用；全量发版统一走 L1 |

## 三、远程操作流程

### 3.1 标准发版（L1）

```bash
# 0. 前置校验：CI 全绿 + CHANGELOG 已更新 + package.json 版本一致
gh run list --branch master --limit 1   # 确认 conclusion=success
grep '"version"' package.json           # 确认版本号
grep -n "^## \[" CHANGELOG.md | head -1 # 确认 changelog 条目

# 1. 创建 annotated tag
git tag -a v2.2.0 -m "release: v2.2.0 — Phase 5 生产就绪

- 13 core packages / 929 tests / build 11/11
- Docker + CI/CD + OpenAPI + Security hardening
See CHANGELOG.md for details."

# 2. 推送单个 tag（避免 git push --tags 误推全部）
git push origin v2.2.0

# 3. 验证 release 工作流被触发并成功
gh run list --workflow release.yml --limit 1
gh release view v2.2.0   # 确认 GitHub Release 已生成
```

### 3.2 里程碑锚定（L2）

```bash
git tag -a phase/5-production-ready -m "Phase 5 完成: Docker/CI-CD/API文档/安全加固/性能优化"
git push origin phase/5-production-ready
```

### 3.3 单包发版（L3）

```bash
git tag "@yyc3/skill-registry@2.0.1"
git push origin "@yyc3/skill-registry@2.0.1"
```

### 3.4 标签纠错

```bash
# 本地删除
git tag -d <tag>
# 远程删除（需谨慎，已触发 release 的 v* tag 删除后应同步删 GitHub Release）
git push origin --delete <tag>
```

## 四、标签一致性保障

1. **版本三处对齐**：`package.json` ↔ `CHANGELOG.md` ↔ `v*` tag 必须一致，CI 发版前自动校验。
2. **禁止移动**：已推送远程的 tag 不可 rebase 重打；错误时按 3.4 删除重建并记录于 CHANGELOG。
3. **保护规则**：建议在 GitHub 仓库设置中为 `v*` pattern 启用 tag protection（仅维护者可创建）。
4. **文档同步**：每次新增 L1/L2 tag 后，更新本规范的阶段对照表。

## 五、当前标签清单

> 由 CI/维护者手动维护，与 `git tag -l` 保持同步。

| Tag | 类型 | Commit | 说明 |
|-----|------|--------|------|
| `v2.2.0` | L1 annotated | 待打 | v2.2.0 生产就绪发布 |
| `phase/5-production-ready` | L2 annotated | 待打 | Phase 5 里程碑 |

---
**维护**: YanYuCloudCube Team <admin@0379.email>
**© 2025-2026 YanYuCloudCube™. All Rights Reserved.**
