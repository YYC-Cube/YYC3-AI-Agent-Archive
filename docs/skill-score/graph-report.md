# 技能关联维度图分析报告

> 生成时间: 2026-09-23T11:30:18.725Z · 数据基础：831 技能全量正文扫描

## 一、图谱总览

| 指标 | 值 | 说明 |
|------|----|------|
| 节点（技能） | 785 | 全量 SKILL.md |
| 边（引用关系） | 2191 | explicit 0 + implicit 2191 |
| 孤立节点 | 149 | 无任何入/出边的技能 |
| 连通分量 | 153 | 最大分量 628 节点 |
| 边密度 | 0.00356 | 实际边 / 理论完全图边 |

## 二、核心枢纽 TOP15（hubRank）

| # | 技能 | hubRank | 路径 |
|---|------|---------|------|
| 1 | `research` | 0.03818 | skills-hub/community/deep-research/research |
| 2 | `product-marketing` | 0.01958 | skills-hub/marketing/marketing-skills/skills/product-marketing |
| 3 | `image` | 0.01833 | skills-hub/marketing/marketing-skills/skills/image |
| 4 | `schema` | 0.01613 | skills-hub/marketing/marketing-skills/skills/schema |
| 5 | `pricing` | 0.01604 | skills-hub/marketing/marketing-skills/skills/pricing |
| 6 | `review` | 0.01564 | skills-hub/dev-workflow/engineering-skills/skills/in-progress/review |
| 7 | `setup-matt-pocock-skills` | 0.01545 | skills-hub/dev-workflow/engineering-skills/skills/engineering/setup-matt-pocock-skills |
| 8 | `competitors` | 0.01182 | skills-hub/marketing/marketing-skills/skills/competitors |
| 9 | `research-add-fields` | 0.01133 | skills-hub/community/deep-research/research-add-fields |
| 10 | `research-add-items` | 0.01133 | skills-hub/community/deep-research/research-add-items |
| 11 | `research-deep` | 0.01133 | skills-hub/community/deep-research/research-deep |
| 12 | `notes` | 0.01132 | skills-hub/community/ima-skills/notes |
| 13 | `social` | 0.0112 | skills-hub/marketing/marketing-skills/skills/social |
| 14 | `emails` | 0.01001 | skills-hub/marketing/marketing-skills/skills/emails |
| 15 | `launch` | 0.00996 | skills-hub/marketing/marketing-skills/skills/launch |

## 三、领域簇（按簇内边密度排序 TOP15）

| 领域目录 | 技能数 | 簇内边 |
|----------|--------|--------|
| skills-hub/community | 336 | 424 |
| skills-hub/marketing | 43 | 352 |
| skills-hub/ai-ml | 201 | 203 |
| skills-hub/dev-workflow | 30 | 21 |
| skills-hub/b2b | 9 | 13 |
| skills-hub/glm | 16 | 11 |
| skills-hub/marketplace | 147 | 7 |
| skills-hub/social-search | 1 | 0 |
| skills-hub/yyc3 | 2 | 0 |

## 四、治理建议

- 孤立技能 149 个：补充 related_skills 或在正文中引用相邻技能可提升可发现性
- 显式声明边占比极低（0.0%）：frontmatter related_skills 是当前空白，建议新技能规范要求声明
- 本报告为「关联维度」数据基础，v2.6.0 评分集成候选（暂不计分，先积累数据）

