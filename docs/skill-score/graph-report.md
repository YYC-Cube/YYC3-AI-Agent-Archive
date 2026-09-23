# 技能关联维度图分析报告

> 生成时间: 2026-09-23T19:38:38.168Z · 数据基础：831 技能全量正文扫描

## 一、图谱总览

| 指标 | 值 | 说明 |
|------|----|------|
| 节点（技能） | 785 | 全量 SKILL.md |
| 边（引用关系） | 2595 | explicit 676 + implicit 1919 |
| 孤立节点 | 60 | 无任何入/出边的技能 |
| 连通分量 | 64 | 最大分量 719 节点 |
| 边密度 | 0.004216 | 实际边 / 理论完全图边 |

## 二、核心枢纽 TOP15（hubRank）

| # | 技能 | hubRank | 路径 |
|---|------|---------|------|
| 1 | `research` | 0.03581 | skills-hub/community/deep-research/research |
| 2 | `schema` | 0.02168 | skills-hub/marketing/marketing-skills/skills/schema |
| 3 | `pricing` | 0.02124 | skills-hub/marketing/marketing-skills/skills/pricing |
| 4 | `image` | 0.02113 | skills-hub/marketing/marketing-skills/skills/image |
| 5 | `product-marketing` | 0.02003 | skills-hub/marketing/marketing-skills/skills/product-marketing |
| 6 | `setup-matt-pocock-skills` | 0.01833 | skills-hub/dev-workflow/engineering-skills/skills/engineering/setup-matt-pocock-skills |
| 7 | `review` | 0.01613 | skills-hub/dev-workflow/engineering-skills/skills/in-progress/review |
| 8 | `competitors` | 0.01578 | skills-hub/marketing/marketing-skills/skills/competitors |
| 9 | `seo-audit` | 0.01293 | skills-hub/marketing/marketing-skills/skills/seo-audit |
| 10 | `launch` | 0.01292 | skills-hub/marketing/marketing-skills/skills/launch |
| 11 | `social` | 0.01289 | skills-hub/marketing/marketing-skills/skills/social |
| 12 | `notes` | 0.01282 | skills-hub/community/ima-skills/notes |
| 13 | `emails` | 0.01242 | skills-hub/marketing/marketing-skills/skills/emails |
| 14 | `video` | 0.01226 | skills-hub/marketing/marketing-skills/skills/video |
| 15 | `copywriting` | 0.0113 | skills-hub/marketing/marketing-skills/skills/copywriting |

## 三、领域簇（按簇内边密度排序 TOP15）

| 领域目录 | 技能数 | 簇内边 |
|----------|--------|--------|
| skills-hub/community | 336 | 567 |
| skills-hub/marketing | 43 | 352 |
| skills-hub/ai-ml | 201 | 269 |
| skills-hub/marketplace | 147 | 168 |
| skills-hub/dev-workflow | 30 | 21 |
| skills-hub/b2b | 9 | 13 |
| skills-hub/glm | 16 | 11 |
| skills-hub/social-search | 1 | 0 |
| skills-hub/yyc3 | 2 | 0 |

## 四、治理建议

- 孤立技能 60 个：补充 related_skills 或在正文中引用相邻技能可提升可发现性
- 显式声明边占比极低（26.1%）：frontmatter related_skills 是当前空白，建议新技能规范要求声明
- 本报告为「关联维度」数据基础，v2.6.0 评分集成候选（暂不计分，先积累数据）

