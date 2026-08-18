# skills-hub/ — 技能资产中心

> 八大分类池，8,600+ SKILL.md 资产。技能 = Agent 按需调用的原子能力单元。

## 分类池一览

| 目录 | 规模 | 内容特征 | 来源 |
|------|:----:|---------|------|
| `community/` | ~283 技能 / 4,600+ 文件 | 中文为主，覆盖数据分析、开发工具、内容创作、云服务 API | 社区贡献 |
| `marketplace/` | ~121 技能 | 英文为主，商业生产力（含 Anthropic 官方 Skills） | 官方市场 |
| `ai-ml/` | 212 技能 | NVIDIA 官方 Agent Skills（`nvidia-skills/skills/<name>/SKILL.md`，标准 frontmatter 格式）+ 量化技能 | NVIDIA 官方 |
| `b2b/` | 8 技能 | B2B SDR 销售流程（OpenClaw 平台） | 自建 |
| `dev-workflow/` | ~12 技能 | 开发工作流（自改进、Git 规范） | 社区 |
| `glm/` | — | 智谱 GLM 模型专用技能 | 自建 |
| `marketing/` | — | 营销、SEO、内容运营 | 社区 |
| `social-search/` | — | 社交媒体与搜索引擎 | 社区 |
| `ui-ux/` | — | 设计系统、Figma、组件 | 社区 |
| `yyc3/` | 2 技能包 | 平台专属（统一架构规划 + 五高架构体系） | 自建 |

## SKILL.md 标准格式

```yaml
---
name: my-skill              # 必填，kebab-case
description: >              # 建议填写（≥10 字符）
  多行描述文本，使用折叠语法。
category: development-code  # AYNC 类别（development-code / ai-ml / business-productivity ...）
version: 1.0.0              # SemVer 2.0.0
allowed-tools: [read_file, execute_command]
---

# 技能正文（When to Use / How to Use / Example / Tips）
```

## 校验与治理工具

```bash
pnpm run skills:validate            # frontmatter 完整性校验
pnpm run skills:stats               # 规模统计
pnpm yyc3 skills naming lint -v     # 命名合规检查（kebab-case + AYNC 编码率）
pnpm yyc3 skills naming migrate     # AYNC 迁移计划（dry-run，--apply 执行）
pnpm run skills:dedup               # 重复检测
```

> 解析与校验核心：`packages/skill-registry`（frontmatter.ts / validator.ts）。
> 新增技能请通过 `pnpm run skills:validate` 自检。
