---
file: README.md
description: Claude Prompts MCP — 合并后的单一权威源
version: v1.0.0
created: 2026-07-24
status: merged
---

# Claude Prompts MCP — YYC3 整合版

> 原始来源：`claude-prompts-mcp/` 仓库 — 已合并至此目录

**合并说明**：原始项目中 `claude-prompts-mcp/` 子目录仅为根级配置文件（.husky/.actrc/.editorconfig），与主项目无关，已清除。所有 MCP Server 源码、提示词、门禁、方法论统一在此目录管理。

## 目录结构

```
mcp-hub/claude-prompts/
├── YYC3-Claw/          # YYC3 专属扩展
├── assets/             # 静态资源
├── docs/               # 文档（架构/门禁/提示词创作指南）
├── plans/              # 实施计划
├── server/             # MCP Server 源码
│   ├── gates/          # 7 个质量门禁
│   ├── graphs/         # DOT/JSON/SVG 架构图
│   ├── methodologies/  # 4 种方法论(5W1H/CAGEERF/SCAMPER/REACT)
│   ├── prompts/        # ~50+ 提示词（analysis/development/documentation 等 9 类）
│   └── src/            # TypeScript 源码
├── CHANGELOG.md
├── CLAUDE.md           # 操作手册
└── package.json
```
