# YYC3 管理仓库 — AI 代理协作指令

> 让 AI 代理在本仓库中即刻可用、稳健高效地推进工作。

## 大图景与架构
- 本仓库围绕脚本驱动的平台运维与开发协作，核心入口为 [devctl](../devctl) 与一组分目录脚本。
- 服务编排主要通过 [docker-compose.yml](../docker-compose.yml) 及分组清理/启动脚本完成；AI 协作与自动化在 [scripts/ai/](../scripts/ai) 下。
- 管理与导航的关键文档：
  - 总览与命令参考：[README.md](../README.md)，目录导航与常用操作：[NAVIGATION-GUIDE.md](../NAVIGATION-GUIDE.md)
- 典型数据/控制流：开发者调用 `devctl` → 触发 `scripts/*` → 调整/启动容器编排与 AI 任务 → 通过 VS Code 任务或脚本查看状态与日志。

## 开发者工作流（必须掌握）
- 本地服务：`devctl start|stop|restart|status`（分别映射到 [scripts/dev/*.sh](../scripts/dev)）。
- AI 协作：
  - 代码生成：[scripts/ai/gen.sh](../scripts/ai/gen.sh)
  - 代码审查：[scripts/ai/review.sh](../scripts/ai/review.sh)
  - 结对提示：[scripts/ai/pair.sh](../scripts/ai/pair.sh)
  - 自动推进（监视）：[scripts/ai/auto.sh](../scripts/ai/auto.sh)
  - 文档/计划生成：[scripts/ai/doc.sh](../scripts/ai/doc.sh), [scripts/ai/plan.sh](../scripts/ai/plan.sh)
- VS Code 任务（更快捷）：
  - 启动容器：在任务面板运行“yyc3-启动本地服务”或“yyc3-启动Docker服务”。
  - 状态/清理：运行“yyc3-查看状态”“yyc3-清理-快速/深度”。
  - AI：运行“yyc3-智能生成”“yyc3-智能审查”“yyc3-AI自动推进(监视)”。

## 项目特有约定
- Shell 脚本默认启用严格模式与统一日志：见 [devctl](../devctl) 顶部 `set -euo pipefail`；颜色日志工具位于 [scripts/utils/colors.sh](../scripts/utils/colors.sh)。
- 端口与安全：端口合规则参考 [README.md](../README.md)（一般在 3200-3500）；权限/角色与访问控制见 [rbac.config.js](../rbac.config.js)、[mcp-roles.json](../mcp-roles.json)、[mcp-access-rules.json](../mcp-access-rules.json)。
- 容器与监控：核心编排在 [docker-compose.yml](../docker-compose.yml)；监控/告警资源位于 [grafana/dashboard.json](../grafana/dashboard.json) 与相关清理脚本。
- 提交规范与质量：使用 Husky/ESLint/Prettier（见 [husky.config.js](../husky.config.js)、[lint-staged.config.js](../lint-staged.config.js)、[tsconfig.json](../tsconfig.json)）；建议遵循 Conventional Commits。

## 跨组件通信与集成点
- AI/MCP：AI 入口脚本位于 [scripts/ai](../scripts/ai)；MCP 权限与审计在 [mcp-roles.json](../mcp-roles.json)、[mcp-audit-log.yml](../mcp-audit-log.yml)、[mcp.config.js](../mcp.config.js)。
- 运维总控：高级运维/错误修复/智能操作脚本在根目录：
  - 快速状态与修复：[yyc3-smart-ops.sh](../yyc3-smart-ops.sh)、[yyc3-error-fixer.sh](../yyc3-error-fixer.sh)
  - 构建/部署：[build.sh](../build.sh)、[build-docker.sh](../build-docker.sh)、[deploy.sh](../deploy.sh)
- macOS 环境脚本（非容器）：[Mac/yyc3-env.sh](../Mac/yyc3-env.sh) 等，用于主机级环境配置与企业部署脚本联动。

## 代码变更模式（示例与建议）
- 为 `devctl` 增加子命令：
  1. 在 [scripts/dev](../scripts/dev) 新增对应脚本（如 `new-feature.sh`），保持 `bash` 严格模式与统一日志输出。
  2. 在 [devctl](../devctl) 的 `case` 语句中添加分支，将子命令路由到脚本。
  3. 为 VS Code 任务添加对应入口（如需），或直接调用脚本。
- 修改容器编排：仅在 [docker-compose.yml](../docker-compose.yml) 或分组 compose 文件中调整；更新后用任务“yyc3-查看状态”验证。
- 触发 AI 审查/生成：优先通过任务“yyc3-智能审查/智能生成”，或直接运行相应脚本。

## 安全与保障
- 不要直接修改访问控制/角色文件（[mcp-roles.json](../mcp-roles.json)、[mcp-access-rules.json](../mcp-access-rules.json)、[rbac.config.js](../rbac.config.js)）除非需求明确；修改后运行任务“yyc3-权限配置校验”。
- 变更脚本后建议运行“yyc3-代码检查”（`npm run lint`）与“yyc3-查看状态”；与容器相关的变更请用“yyc3-清理-快速/深度”后再“启动本地服务”。
- 在 Mac 主机环境级脚本（[Mac/yyc3-env.sh](../Mac/yyc3-env.sh)）中，谨慎变更 NAS/目录参数；该脚本面向企业部署场景。

---
以上为可发现且已实施的模式与工作流。若您新增组件或流程，请遵循现有脚本风格与任务入口设计，并更新本文件中的引用链接与示例。
