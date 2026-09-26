# mcp-hub 双轨代码归档

> **归档日期**: 2026-09-26 ｜ **裁决依据**: 深审报告 §7.3-5 / 第二十一章（方案 B 拆分处置）

## 归档原因

`server/`（@yyc3/mcp-server，~1378 行）与 `packages/mcp-runtime` 是同一职责的**双轨实现**。
mcp-runtime 为唯一活轨（40 测试、进 CI/Docker、S0→P2 持续加固）；本目录代码从未构建
（无 dist）、无测试、不在 pnpm-workspace，且 2026-09-02 后零改动——死代码双轨，裁决归档。

`gateway/`、`client/` 为零引用 TS/JS 片段，一并归档。

## 恢复方式

如需复活：`git mv` 回 `mcp-hub/` 并接入 pnpm-workspace + CI；但应先评估与
`@yyc3/mcp-runtime` 的职责合并，避免再次双轨。

## 保留在 mcp-hub/ 的资产（未归档）

- `claude-prompts/` — vendored 上游项目（claude-prompts-mcp v1.3.0），提示词引擎参考镜像
- `mcp/` — MCP 客户端运维配置快照（brave-search/docker/postgres 等 JSON）
- `mcp-servers/` — API Key / 配置 / 快速上手指南
