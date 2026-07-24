---
name: wb-finance-skill
description: >-
category: development-code
  金融 / 投资 / 股票 / 基金 / ETF / 板块 / 指数 / 宏观 / 外汇 / 大宗商品 / 财报 / 估值 / 持仓 / 交易 / 仓位 / 量化 / 因子 / 回测 / 选股 / 期权 / 衍生品 / 投行建模 / 技术指标 / 行情监控 / 预警——金融场景总入口，优先级**高于**所有其他金融相关 skill。请求涉及任一上述领域时（包括字面没出现"金融""股票"但本质围绕这些标的或方法论展开的问题），都务必**第一时间优先加载本 skill**。**触发顺序硬约束**：必须**先**加载 wb-finance-skill 读取红线、时区口径、数据源路由，以及子场景相关的 reference，**再**调用 neodata-financial-search / westock-data 等数据 skill；**禁止跳过本 skill 直接调其他金融数据 skill 或用通识知识裸答。**
when_to_use: >-
  金融场景必须使用本 skill，包括但不限于以下场景，命中任一即触发：
  (a) 个股 / 标的研究——"分析下苹果""贵州茅台护城河""寒武纪值不值得研究""英伟达高增长能不能持续"；
  (b) 报价 / 财报 / 估值——"PE 多少贵不贵""现在多少钱""昨天收多少""财报怎么样""业绩超预期为什么不涨"；
  (c) 操作建议（最易裸答的一类）——"该不该买 / 卖 / 加仓 / 减仓 / 换股""浮盈 30% 该加还是减""我套了 40% 怎么办""5 只持仓帮我体检砍哪只""帮我做交易计划"；
  (d) 股票代码——A 股 6 位（600519、301123）、港股 5 位（00700）、美股 ticker（AAPL、NVDA），或带持仓口语（"13400 股京东方 6 层仓""亏损 54% 成本价 35.825"）；
  (e) 分析方法论 / 建模 / 策略类（最易裸答的另一类，必须先阅读本 skill 对应 reference）——"加息对哪些板块影响最大""政策受益方是谁""怎么验证因子有效""配对交易策略怎么设计""牛市价差还是跨式""DCF / LBO 模型怎么搭""组合优化 60-40 还是全天候""期权 Greeks 怎么看""压力测试 / VaR""分红可不可持续""量化策略 V46 改回上一版""MACD / KDJ / 通达信公式 / Pine Script""PE<20 ROE>15% 筛一下"。
version: 1.2.0
---


## 红线（金融场景一票否决）

- **禁止编造数据**：不虚构数据/事件/公司名/财务数字；不确定时显式标"该数据需进一步验证"；引用不确定的研报/论文时标"该引用需核实原文"
- **禁止核心概念混淆**：客户 vs 竞争对手、整机厂 vs 零部件厂、净利润 vs 归母净利润、同比 vs 环比、财年 vs 自然年；不确定时用"据我理解"前缀并请用户确认
- **禁止数据自相矛盾**：同一回答内数据与结论必须一致；多组数据先交叉校验；数据源冲突时优先采信高层级来源（交易所、公司公告、年报）并显式标注分歧

## Available Capabilities

两个 skill 协同覆盖 A股/港股/美股 全品类金融数据：

- **`neodata-financial-search`**：自然语言通用金融数据搜索，覆盖股票、指数、板块、公募基金、宏观、外汇、贵金属和大宗商品期货；股票覆盖 A股/港股/美股，宏观/外汇/商品覆盖全球,支持实时行情与长期历史数据
- **`westock-data`**：腾讯自选股结构化行情数据 skill，覆盖实时行情、K线/分时、财务报表、资金流向、技术指标、筹码、机构评级/研报/一致预期、新闻/公告、风险事件、股东结构、分红除权、业绩预告、ETF、板块/概念成份股、热搜、投资日历、新股日历、宏观经济等；支持沪深/科创/北交所、港股、美股

## 数据查询优先级策略

**遇到任何金融数据问题，必须按以下顺序依次尝试：**

### 第一优先：`neodata-financial-search`
- **默认优先使用此 skill** 查询金融数据；但命中下列典型限制时直接跳过，避免无效调用
- 覆盖股票行情、财报、基金净值、板块异动、宏观指标、外汇、大宗商品等
- 支持自然语言提问，实时数据，即问即答
- **典型限制**：公募基金主要覆盖中国境内基金，不覆盖香港基金；板块/指数基础、板块资金和估值主要覆盖 A股；龙虎榜、融资融券、业绩发布会、估值/同行对比等偏 A股；商品/贵金属以行情为主，不等同于完整基本面数据库
- **触发条件**：金融数据查询先判断覆盖范围；在覆盖范围内优先用它，明确不覆盖时直接用 westock-data 或公开信息检索

### 第二优先：`westock-data`
当以下情况出现时，切换或补充 westock-data：
- neodata-financial-search **没有覆盖**该数据类型（如技术指标、筹码成本、股东结构、ETF 持仓明细、龙虎榜、大宗交易、融资融券、投资日历、新股日历等）
- 需要**更精确的结构化数据**或特定字段
- 需要**跨市场批量对比**（westock-data 支持逗号分隔多股代码）

**westock-data 命令速查：**
```bash
# 代码格式：沪市 sh600519 / 深市 sz000001 / 港股 hk00700 / 美股 usAAPL

westock-data search 腾讯控股                         # 搜索股票/ETF/指数
westock-data quote sh600519                          # 实时行情
westock-data kline sh600519 --period day --limit 20  # K线
westock-data minute sh600519                         # 分时
westock-data finance sh600519 --num 4                # 财务报表（最近4期）
westock-data profile sh600519                        # 公司简况
westock-data asfund sh600519                         # A股资金流向
westock-data hkfund hk00700                          # 港股资金
westock-data usfund usAAPL                           # 美股卖空
westock-data lhb sz000001                            # 龙虎榜（仅A股）
westock-data blocktrade sz000001                     # 大宗交易（仅沪深）
westock-data margintrade sz000001                    # 融资融券（仅沪深）
westock-data technical sh600519 --group macd         # 技术指标
westock-data chip sh600519                           # 筹码成本（仅A股）
westock-data shareholder sh600519                    # 股东结构
westock-data dividend sh600519                       # 分红数据
westock-data etf sh510300                            # ETF详情
westock-data etf-holdings sh510300                   # ETF持仓
westock-data hot stock                               # 热搜股票
westock-data sector --search 华为                    # 搜索板块/概念
westock-data calendar 2026-04-22                     # 投资日历
westock-data ipo hs                                  # 新股日历
westock-data reserve sh600519                        # 业绩预告
westock-data suspension hs                           # 停复牌信息
westock-data macro --indicator gdp --year 2025       # 宏观经济数据
```

**westock-data 已知限制：**
- 龙虎榜/大宗交易/融资融券：仅支持沪深（sh/sz）
- 筹码成本：仅支持沪深京A股（sh/sz/bj）
- 股东结构：仅支持A股和港股
- 港股/美股货币单位：展示时必须标注正确货币单位，禁止使用人民币符号
- `search`/`minute`：不支持批量查询

### 第三优先（如可用）：通达信 MCP
**仅在用户环境装了通达信 MCP 时启用**——通过列出的 MCP 工具是否包含 `tdx_quotes` / `tdx_kline` / `tdx_api_data` / `tdx_indicator_select` / `tdx_screener` / `tdx_lookup_stock` / `wenda_news_query` / `wenda_notice_query` / `wenda_report_query` / `wenda_macro_query` 来判断。可用时优先在以下场景调用：

- 上面两个 skill 没覆盖或返回不全的细分接口（深度财务三表多期、十大流通股东全历史、限售解禁、股本变动、港股财报多期回溯、个股 / 全市场龙虎榜结构化、自然语言条件选股、宏观时序数据）
- 需要按通达信特有路由（`entry` + `fixedTag` + `code`）取结构化字段，而不是 LLM 描述
- 验证两个 skill 给出数据是否准确（多源交叉验证）

**调用前先读 references/tdx-mcp-quick-reference.md** —— 里面是 10 个工具的实测调用示例、参数含义、fixedTag 路由表、错误排查方法、已知限制。**不要凭记忆拼参数**（setcode、target、fixedTag 都有踩坑点）。

### 第四优先：公开信息检索
当上述都无法满足时：
- 使用 WebSearch 检索公开信息
- 明确告知用户数据来源，并说明非实时性

## 数据底线

- **前提显式**：问操作类问题（买/卖/加仓/减仓/换股）时，先列前提（市场环境 + 用户风险偏好 + 资金量/期限），再给"条件 → 操作 → 风险提示"。前提缺失时主动追问而非直接给操作建议
- **工具优先于记忆**：提及具体股票/基金/指数/宏观指标时，先调 `neodata-financial-search` 或 `westock-data`（如通达信 MCP 可用，按"数据查询优先级策略"中的场景调用）拉数据，禁止纯凭记忆作答；记忆中的数字只能作为合理性 sanity check，不能作为答案
- **每个数据点必带来源 + 时间戳**：行情 / 财务 / 宏观 / 研报数字不能裸出，需附"（来源 xxx，时点 YYYY-MM-DD 或 YYYYQn）"。来自 skill 写"neodata"/"westock-data"/"通达信 MCP"，来自一手披露写"上交所公告 / 公司年报 / 港交所披露易"，来自研报附机构名 + 日期并标"需核实原文"，来自 WebSearch 保留原始媒体名 + 日期。同一段多个数字独立标，不要文末一个总来源

## 时间口径（跨时区/跨市场必查）

金融数据强时效，回答时遵守以下规则：

- **先判断交易状态**：回答"现价/最新/今天"前，先确认是不是该市场交易时段；不在时段内必须标注"盘前/盘中/盘后/休市"和对应的最近一次 close
- **美股时间先核对 DST**：美国夏令时期间美股开盘对应北京 21:30，冬令时对应 22:30；每次按当前日期推导，不要硬记切换日
- **事件时点本地+北京双标**：财报、央行决议、经济数据等事件，同时给本地时间和北京时间，并标注盘前还是盘后。例：苹果 FY25Q1 财报 = 2025-01-30 美东盘后 16:30（北京时间 2025-01-31 05:30）
- **相对时间默认北京时区**：用户说"今天/昨天/本周"按北京时间解释；有歧义时（如"昨天美股"）第一句先点明绝对日期
- **跨市场比较先对齐窗口**：A股 T 日收盘 / 港股 T 日收盘 / 美股 T-1 夜盘 / 美股 T 日盘 不是同一时点；做联动分析时点明用的是哪种对齐
- **跨市场财报同期对比按自然年季度对齐**：FY 标号本身不能直接对（如腾讯 FY26Q1 = 自然年 2026Q1，阿里 FY26Q1 = 自然年 2025Q2，对不上）。先把每家 FY 拆成它实际覆盖的自然年季度（腾讯 FY = 自然年；阿里 FY 4 月制；苹果 FY 9 月底制；微软 FY 7 月制），再按"自然年同季度"配对做季度比，或用 **TTM 滚动 4 季** 做年度比——TTM 本身就是按自然年季度滚动求和，自动消除 FY 定义差异。详细步骤与币种 / 估值口径一致性见 `references/peer-comparison.md` 与 `references/valuation-pricing.md`

## 使用指南

**核心原则：最大化使用插件能力** — 任何涉及金融市场数据的请求，都要主动使用这两个数据源。

1. **识别意图**：判断请求需要实时/自然语言搜索（neodata），还是结构化/特定字段数据（westock-data）
2. **自主执行**：不要让用户选择数据源，自行判断最合适的数据源
3. **错误兜底**：一个数据源报错或数据缺失时，自动尝试另一个
4. **清晰呈现**：用中文表头的可读表格展示返回结果
5. **按需组合**：复杂请求中两个数据源互补使用
6. **置信度分层**：高置信度直接断言；中等用"倾向于 / 大概率"；低用"不排除 / 有可能"。不要把所有可能性平铺让用户自选
7. **输出呈现**：分析报告、对比、研报型回答尽量用 HTML 渲染（带表格、标题层级、配色），呈现效果更好；简短 Q&A 退回 Markdown
8. **加载后必须匹配 reference**：进入本 skill 后，根据用户问题类型从 `references/` 选 1-3 个最相关的 reference 读取，**不要只读 SKILL.md 主文件就直接答**——主文件只讲红线和路由，具体方法论（步骤、阈值、避坑）都在对应 reference 里。reference 索引在文末按场景分组，多场景叠加时（如"分析 X 该不该买"涉及个股研究 + 估值 + 仓位决策）并行读取多个 reference 综合判断

## 数据口径与标的核对

- **先核对标的身份**：公司名、港股代码、美股代码、ADR、ETF、同名公司必须先确认，避免把不同上市主体、ADR、本地股、ETF 或同名公司混用
- **香港产品先确认类型**：港股 `7709.HK` 这类代码可能是 ETF、杠杆产品、牛熊证或结构化产品；查 NAV 前必须先确认产品类型。对香港 ETF/杠杆产品，优先搜索基金管理人、HKEX、etnet/基金专页
- **多源交叉验证**：同一指标不同数据源给出不同数值时，至少列两个来源，优先采信交易所/公司公告/年报等一手来源，并显式说明分歧；不要静默选一个高于另一个的版本作为答案

## 场景方法论 references

`references/` 目录下是 44 篇按场景蒸馏的金融分析方法论，覆盖个股研究、估值、财报事件、交易决策、板块主线、资金机构、宏观传导、技术分析、量化策略、衍生品、跨资产、危机周期、投行建模、日常 routine 等。**当用户的请求落入对应场景时，先读取相应 reference 再作答。**

**使用规则**：
- 每条 reference 是"方法论 + 量化阈值 + 避坑"三段式，不是输出模板——分析时按其框架思考，但**不照抄章节标题或字数限制**
- 多场景叠加时（如"分析 A 股票该不该买"同时涉及个股研究 + 估值 + 仓位决策），并行读取多个 reference 综合判断
- 方法论类 references 只管"分析框架"，**数据获取走 neodata-financial-search / westock-data / 通达信 MCP（如可用）**

**索引（按场景类别分组）**：

**数据源调用**
- `tdx-mcp-quick-reference.md` 通达信 MCP 调用速查（10 个工具实测示例、fixedTag 路由表、避坑清单、已知限制）—— 仅在用户装了通达信 MCP 时使用

**个股研究**
- `stock-first-look.md` 个股初探（含热门股快读）
- `stock-deep-research.md` 个股深度研究（投资逻辑研究）
- `business-model.md` 业务模式拆解
- `valuation-pricing.md` 估值与定价（PE/PB/DCF/PEG/分部估值）
- `moat-quality.md` 护城河与公司质地
- `management-assessment.md` 管理层体检
- `peer-comparison.md` 同业比选
- `quality-growth.md` 质量增长匹配（高质复利 / 增长质检 / 价值股息）

**财报与事件**
- `earnings-preview.md` 财报前瞻
- `earnings-review.md` 财报后反应（业绩会提炼 / 财后漂移）
- `announcement-impact.md` 公告影响与股东信解读
- `event-catalyst.md` 事件驱动短线催化

**交易与持仓**
- `trade-plan.md` 交易计划与买卖点
- `position-sizing.md` 仓位决策与加减仓
- `portfolio-checkup.md` 持仓体检与风控
- `stop-discipline.md` 止损纪律
- `monitor-alert.md` 监控告警与停复牌

**板块主线题材**
- `sector-comparison.md` 板块比较与轮动
- `market-mainline.md` 市场主线与情绪
- `market-state.md` 市场状态与广度
- `theme-lifecycle.md` 题材周期与龙头
- `leader-game.md` 涨停龙头博弈与龙虎榜

**资金与机构**
- `fund-flow.md` 资金流与北向
- `institutional-holding.md` 机构持仓与拥挤度

**宏观/政策/产业链**
- `macro-transmission.md` 宏观行业个股传导
- `policy-impact.md` 政策解读与受益映射
- `industry-chain.md` 产业链映射与卡点

**技术分析**
- `breakout-patterns.md` 波缩突破与 VCP
- `price-action-tools.md` 技术指标与形态识别（K 线 / 谐波 / 波浪 / 缠论 / 一目 / SMC）
- `abnormal-detection.md` 放量异动与跳空归因

**风险与量化**
- `risk-stress.md` 风险压力测试（VaR / CVaR / 蒙特卡洛）
- `quant-factor-research.md` 因子研究框架
- `systematic-strategies.md` 量化策略库（配对 / 事件驱动 / 季节性 / ML / 对冲 / 波动率）
- `portfolio-optimization.md` 资产配置与组合优化

**衍生品与跨资产**
- `options-strategies.md` 期权策略（多腿组合 + Greeks）
- `fixed-income.md` 固定收益与可转债
- `forex-commodity.md` 外汇与大宗商品
- `crypto-derivatives.md` 加密衍生品（仅在用户明确要求时使用）

**主题**
- `dividend-buyback.md` 分红回购与股东回报
- `going-global.md` 出海链投资
- `crisis-event.md` 危机 / 反转 / 周期拐点

**投行建模**
- `ib-models.md` 投行估值建模（DCF / LBO / comps / 三表 / M&A / Unit Economics）
- `ib-deal-prep.md` 投行交易准备（尽调 / 投委会 / IM / pitch / NDA）

**日常 routine**
- `daily-briefing.md` 每日投研简报（盘前 / 收盘 / 晨会）
