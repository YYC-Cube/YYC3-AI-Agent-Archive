# mcp-hub — MCP 资产区（定位声明）

> **2026-09-26 双轨裁决（方案 B 拆分处置）后，本目录仅保留资产，不含运行时代码。**
> MCP 运行时唯一实现在 [`packages/mcp-runtime`](../packages/mcp-runtime/)（进 CI/Docker）。

## 目录内容

| 目录 | 定位 | 维护策略 |
| ---- | ---- | -------- |
| `claude-prompts/` | vendored 上游项目（claude-prompts-mcp v1.3.0）— 提示词引擎参考镜像 | 只读镜像，不参与构建；被 CLI deduper 按 reference-asset 排除 |
| `mcp/` | MCP 客户端运维配置快照（brave-search / docker / postgres / github 等 JSON） | 随部署环境按需更新 |
| `mcp-servers/` | API Key 指南 / MCP 配置指南 / 快速上手 | 文档资产，按需更新 |

## 已归档（勿在此寻找）

`server/`、`gateway/`、`client/` 双轨代码已移至 [`_archive/mcp-hub-dual-track-code/`](../_archive/mcp-hub-dual-track-code/)。
