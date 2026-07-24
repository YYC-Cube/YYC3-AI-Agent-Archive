---
file: README.md
description: AI 工作流构建器 — 从 ai-agent 项目集成（Next.js + React Flow）
version: v1.0.0
created: 2026-07-24
status: integrated
source: ai-agent/
---

# AI 工作流构建器 — Workflow Builder

> **第八层·用户交互层** — 可视化 AI 工作流编排

从 `ai-agent/` 项目完整集成。提供拖拽式 AI 工作流构建能力。

## 核心能力

- **12 种 AI 节点**：文本模型、嵌入模型、工具调用、提示词、图片生成、音频、JS 执行、HTTP 请求、条件分支、结构化输出、开始/结束节点
- **React Flow 画布**：拖拽编排、缩放平移、节点连接
- **代码导出**：将可视化工作流导出为可执行代码
- **shadcn/ui 组件库**：36+ Radix UI 组件

## 启动

```bash
cd tools-hub/workflow-builder
pnpm install
pnpm dev  # 默认端口 3411
```
