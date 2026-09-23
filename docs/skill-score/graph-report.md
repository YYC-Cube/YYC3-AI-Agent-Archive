# 技能关联维度图分析报告

> 生成时间: 2026-09-23T19:16:36.246Z · 数据基础：831 技能全量正文扫描

## 一、图谱总览

| 指标 | 值 | 说明 |
|------|----|------|
| 节点（技能） | 785 | 全量 SKILL.md |
| 边（引用关系） | 2410 | explicit 307 + implicit 2103 |
| 孤立节点 | 74 | 无任何入/出边的技能 |
| 连通分量 | 78 | 最大分量 703 节点 |
| 边密度 | 0.003916 | 实际边 / 理论完全图边 |

## 二、核心枢纽 TOP15（hubRank）

| # | 技能 | hubRank | 路径 |
|---|------|---------|------|
| 1 | `research` | 0.03685 | skills-hub/community/deep-research/research |
| 2 | `image` | 0.02105 | skills-hub/marketing/marketing-skills/skills/image |
| 3 | `product-marketing` | 0.02095 | skills-hub/marketing/marketing-skills/skills/product-marketing |
| 4 | `schema` | 0.01908 | skills-hub/marketing/marketing-skills/skills/schema |
| 5 | `pricing` | 0.01893 | skills-hub/marketing/marketing-skills/skills/pricing |
| 6 | `research-add-items` | 0.01624 | skills-hub/community/deep-research/research-add-items |
| 7 | `setup-matt-pocock-skills` | 0.01605 | skills-hub/dev-workflow/engineering-skills/skills/engineering/setup-matt-pocock-skills |
| 8 | `review` | 0.01605 | skills-hub/dev-workflow/engineering-skills/skills/in-progress/review |
| 9 | `competitors` | 0.01402 | skills-hub/marketing/marketing-skills/skills/competitors |
| 10 | `notes` | 0.01289 | skills-hub/community/ima-skills/notes |
| 11 | `launch` | 0.01252 | skills-hub/marketing/marketing-skills/skills/launch |
| 12 | `social` | 0.01165 | skills-hub/marketing/marketing-skills/skills/social |
| 13 | `emails` | 0.01129 | skills-hub/marketing/marketing-skills/skills/emails |
| 14 | `ab-testing` | 0.01058 | skills-hub/marketing/marketing-skills/skills/ab-testing |
| 15 | `analytics` | 0.01025 | skills-hub/marketing/marketing-skills/skills/analytics |

## 三、领域簇（按簇内边密度排序 TOP15）

| 领域目录 | 技能数 | 簇内边 |
|----------|--------|--------|
| skills-hub/community | 336 | 498 |
| skills-hub/marketing | 43 | 352 |
| skills-hub/ai-ml | 201 | 240 |
| skills-hub/marketplace | 147 | 103 |
| skills-hub/dev-workflow | 30 | 21 |
| skills-hub/b2b | 9 | 13 |
| skills-hub/glm | 16 | 11 |
| skills-hub/social-search | 1 | 0 |
| skills-hub/yyc3 | 2 | 0 |

## 四、治理建议

- 孤立技能 74 个：补充 related_skills 或在正文中引用相邻技能可提升可发现性
- 显式声明边占比极低（12.7%）：frontmatter related_skills 是当前空白，建议新技能规范要求声明
- 本报告为「关联维度」数据基础，v2.6.0 评分集成候选（暂不计分，先积累数据）

