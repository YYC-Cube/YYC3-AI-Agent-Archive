---
file: 上游断供演习-Runbook.md
description: YYC³ AI Agent Archive — 上游断供演习标准作业程序（GitHub 断供 / npm 断供 / 上游资产失效）
author: AI Tutor <YYC3-AI-Agent>
version: v1.0.0
created: 2026-09-22
updated: 2026-09-22
status: active
tags: [runbook],[drill],[supply-chain],[business-continuity]
category: operations
---

# 🚨 上游断供演习 Runbook（Supply-Chain Outage Drill）

> **目标**：验证本项目在上游（GitHub / npm / 上游参考资产）完全断供的情况下，
> 核心 API、CLI、注册表分发 **继续可用 ≥90 天**，且恢复流程 <1 人时。
> 依据：《05-可复用技术与项目蓝图》第 5 节「GitHub 断供出口策略」。

## 一、断供风险模型

| 断供源 | 影响面 | 缓解资产 | RTO 目标 |
|--------|--------|----------|----------|
| GitHub 不可用 | CI/CD、Pages 分发、Dependabot、issue | 镜像内置技能快照、GHCR 镜像、MCP registry 静态产物、git 本地全量 | 切换 <30min |
| npm registry 不可用 | 新环境依赖安装 | pnpm store 本地缓存、lockfile + `--frozen-lockfile`、GHCR 已构建镜像 | 已构建环境 0 影响；新环境用镜像 |
| 上游参考资产（agents-hub 等镜像源）失效 | 参考资产不再更新 | 资产已 git-native 入库，断供 = 冻结而非丢失 | 0（无影响） |

## 二、演习场景与步骤

### 演习 A：GitHub API 断供（每季度）

```bash
# 1. 模拟：断网/hosts 屏蔽 github.com（或直接离线执行以下命令）
# 2. 验证核心链路（全部应通过）：

# 2.1 本地构建 + 测试（不触网）
pnpm install --frozen-lockfile --offline
pnpm turbo build && pnpm turbo test

# 2.2 CLI 全功能（技能索引/评分/导出/去重）
node packages/yyc3-cli/bin/yyc3-cli.js skills index
node packages/yyc3-cli/bin/yyc3-cli.js skills score --out /tmp/drill-score
node packages/yyc3-cli/bin/yyc3-cli.js skills export-mcp --out /tmp/drill-registry
node packages/yyc3-cli/bin/yyc3-cli.js skills dedup

# 2.3 三容器本地栈（镜像已拉取/本地构建）
docker compose up -d
# 冒烟 8 项（参照 release.yml Smoke test）

# 2.4 静态注册表仍可分发（Pages 断供时降级为 GHCR 镜像内嵌 registry.json）
```

**通过标准**：2.1–2.3 全绿；registry.json 与最近一次 CI 产物哈希一致。
**记录**：演习日期、耗时、失败项、修复 commit。

### 演习 B：npm registry 断供（每半年）

```bash
# 1. 清空 node_modules 模拟新环境
# 2. 使用本地 pnpm store 离线安装
pnpm install --frozen-lockfile --offline
# 3. 若 store 缺失 → 用 GHCR 镜像直接跑（绕过构建）
docker run --rm -p 3030:3030 ghcr.io/yyc-cube/skill-gateway:latest
```

**通过标准**：离线安装成功 或 镜像直接启动冒烟 8/8。
**兜底**：`pnpm store add` 定期预热脚本（附录 A）。

### 演习 C：Pages 分发断供（每半年）

```bash
# 1. 验证备用分发通道
curl -fsS https://ai-agent.yyc3.vip/registry/registry.json | jq '.servers | length'   # 主通道
docker run --rm ghcr.io/yyc-cube/skill-gateway:latest cat /app/skills >/dev/null      # 镜像内快照
# 2. git clone 本地全量 → 独立 serve registry/
git clone --depth 1 <mirror> && npx serve public/registry
```

**通过标准**：至少 2 条通道可获取完整 registry.json（831 servers）。

## 三、恢复流程（断供真实发生时）

1. **判定**：确认断供范围（仅 API / 全站 / npm）与预计时长
2. **切换**：
   - CI 断 → 本地 `pnpm turbo build+test` 作为门禁，手动 `git push` 到镜像仓库
   - Pages 断 → GHCR 镜像内嵌快照 + 任一静态服务器 serve `public/registry/`
   - npm 断 → `--offline` 安装（store 预热）或镜像分发
3. **通告**：在镜像仓库 README 顶部公告降级状态
4. **恢复**：上游恢复后 `git fetch && pnpm install`，跑 CI 全量回归
5. **复盘**：更新本 runbook（新发现的单点 → 新的缓解措施）

## 四、排期与责任

| 演习 | 频率 | 下次排期 | 责任 | 记录位置 |
|------|------|----------|------|----------|
| A: GitHub 断供 | 每季度 | 2026-12 | 值班维护者 | 本文件「演习记录」节 |
| B: npm 断供 | 每半年 | 2027-03 | 值班维护者 | 同上 |
| C: Pages 断供 | 每半年 | 2027-03 | 值班维护者 | 同上 |

## 五、演习记录（追加式）

| 日期 | 场景 | 结果 | 耗时 | 发现与修复 |
|------|------|------|------|-----------|
| 2026-09-22 | 首次基线（本地全链路） | ✅ 831 skills score + export + dedup + 三容器冒烟 | ~6min | 建立基线；镜像快照 4.4MB 确认 |

## 附录 A：pnpm store 预热（月度 cron 建议）

```bash
# 月度执行：确保离线安装可用
pnpm install --frozen-lockfile --prod=false --lockfile-only && pnpm install --frozen-lockfile
```

## 附录 B：关联文档

- 《05-可复用技术与项目蓝图-全链路生产闭环.md》— 断供出口策略总纲
- 《06-蓝图落地实施计划.md》— Phase I / M5
- `.github/workflows/release.yml` — 冒烟 8 项清单（演习直接复用）
