---
file: YYC3-AGENTS-HUB-双插件市场评估.md
description: claude-code-agents 与 community-agents 两套插件市场的重叠分析与处置建议
author: YanYuCloudCube Team <admin@0379.email>
version: v1.0.0
created: 2026-08-18
updated: 2026-08-18
status: stable
tags: [agents-hub, plugins, dedup, evaluation]
category: architecture-audit
language: zh-CN
---

# 双插件市场重叠评估（P3-4）

> 数据基准：2026-08-18 工作区实测

## 一、实测结论

| 维度 | claude-code-agents | community-agents |
|------|-------------------|------------------|
| 插件数 | **91** | 78 |
| 同名插件 | — | **78（100% 与前者重名，为其严格子集）** |
| 独有插件 | 13 | **0** |
| 内容一致性 | 含 .codex-plugin 等更多 harness 产物 | 同名插件内容已**分化**（agent 定义、plugin.json 存在差异） |
| 上游来源 | wshobson/agents（多 harness 单源生成架构） | 同源的**分叉快照**（README 同样指向 wshobson） |

## 二、定性

两套市场是**同一上游（wshobson/agents）的两个不同时间点/分支的快照**：

- claude-code-agills 更新（多 13 个插件、多 harness 产物、内容迭代）
- community-agents 完全被前者名称覆盖，但内容并非字节重复，属"旧版分叉"

## 三、处置建议

### ✅ 执行记录（2026-08-18 第六轮）

**决策：合并收敛已执行**。community-agents 已 `git mv` 至 `_archive/agents-hub-community-agents`
（附 ARCHIVE-NOTE.md 说明与恢复命令），`agents-hub/roles/` 保留单一市场 claude-code-agents。

**最终数据依据**（覆盖第一节表格的量化验证）：

| 指标 | 数值 |
|------|-----:|
| 共享插件（78 个）内 B 独有文件 | **0** |
| B 独有插件 | **0** |
| A 独有插件 / 独有文件 | 13 / 187 |
| 内容分化文件（归档保留可查） | 343 |

即：community-agents 对资产集合的净贡献为零，其分化内容已完整保留于归档与 git 历史。

| 选项 | 评估 | 建议 |
|------|------|:----:|
| 直接删除 community-agents | 内容已分化，删除会丢失分叉版本的差异化内容（若有独立维护价值） | ⚠️ 暂缓 |
| 保留双市场 | 存储冗余（78 目录）、概念混淆（README 均自称完整市场） | 现状 |
| **合并收敛**：以 claude-code-agents 为唯一市场，community-agents 迁移至 `_archive/` 并在 README 注明分叉来源 | 消除冗余与混淆，可随时从归档恢复 | ✅ **已执行**（2026-08-18） |

**执行前置条件**：确认 community-agents 无独立上游同步链路（当前仓库未见其专属 sync 脚本）；
归档后 `agents-hub/roles/` 仅保留单一市场，检索与治理成本减半。

## 四、关联

- 技能层面的同名冲突治理已由 skill-registry 版本胜出机制承接（见技术栈分析报告 7.8）
- 本评估对应路线图 P3-4，执行合并前需维护者确认
