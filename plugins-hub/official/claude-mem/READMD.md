---
file: README.md
description: Claude 记忆系统 — 从 claude-mem-main 集成
version: v1.0.0
created: 2026-07-24
status: integrated
source: claude-mem-main (v9.0.12)
---

# Claude 记忆系统 — Memory Plugin

> **第四层·共享能力底座层** — 跨会话上下文持久化

从 `claude-mem-main`（AGPL-3.0）集成。AI 记忆压缩系统，持久化跨会话上下文。

## 包含模块

| 模块 | 路径 | 说明 |
|------|------|------|
| 核心配置 | `.claude/commands/` | CLI 命令增强 |
| 插件包 | `plugin/commands/` | make-plan/do 命令 |
| 文档 | `docs/` | 架构/配置/使用指南 |
| Cursor 适配 | `cursor-hooks/` | Cursor IDE hooks |

## 使用

```bash
cd plugins-hub/official/claude-mem
npx claude-mem --help
```
