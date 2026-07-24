---
file: YYC3-Skill-核心定位与设计原则.md
description: YYC³ Skill 核心定位、设计原则、标准模板与10个完整示例
author: YanYuCloudCube Team <admin@0379.email>
version: v2.0.0
created: 2026-03-21
updated: 2026-07-23
status: stable
tags: [Skill],[标准模板],[原子能力],[设计原则],[全生命周期]
category: policy
language: zh-CN
audience: developers,architects,skill-developers
complexity: advanced
related_docs: YYC3-AI-Family-九层全栈架构.md, YYC3-Agent.md, YYC3-Skill-安全审计流程.md
---

# YYC3 Skill核心定位与设计原则

## 一、Skill核心定位与设计原则

**核心定义**
Skill是YYC³体系中可被Agent按需调用的原子能力单元，是将具体业务能力、算法模型、外部系统接口封装为标准化、可复用、可编排的功能积木。Agent负责决策「做不做、什么时候做」，Skill负责「怎么做、执行出结果」，二者解耦是AI Family规模化扩展的核心基础。
**设计原则（契合「万象归元于云枢」理念）**

- **单一职责原则**：一个Skill仅完成一件原子任务，职责边界清晰，无重叠、无歧义
- **标准化原则**：所有Skill遵循统一的元数据、入参、出参、异常格式，即插即用
- **可复用原则**：一次开发，可被所有权限内的Agent调用，支持多场景复用
- **可观测原则**：执行全链路留痕，支持日志、耗时、成功率统计与审计
- **安全可控原则**：内置权限校验与参数校验，执行风险可管控，结果可追溯

## 二、Skill标准格式模板（可直接复用）

所有Skill必须采用结构化定义，分为五大模块，以下为工业级标准JSON模板，可直接纳入Skill管理平台：

```
{
  "skill_base_info": {
    "skill_id": "YYC3-SKILL-DATA-001",
    "skill_name": "chart_analysis 图表解读技能",
    "skill_category": "数据分析类",
    "skill_desc": "输入图表数据或图片，输出核心指标、趋势判断与异常点识别",
    "author": "YYC³ 技术中台",
    "version": "v1.2.0",
    "enable_status": true,
    "permission_level": "public",
    "call_timeout": 15,
    "retry_times": 2
  },
  "input_params": {
    "required": [
      {
        "param_name": "chart_data",
        "param_type": "object",
        "param_desc": "图表结构化数据或图片base64",
        "example": "{\"x_axis\":[\"1月\",\"2月\"],\"y_axis\":[120,150]}"
      }
    ],
    "optional": [
      {
        "param_name": "analysis_dimension",
        "param_type": "string",
        "param_desc": "分析维度：趋势/占比/对比/异常",
        "default_value": "trend"
      }
    ]
  },
  "output_params": {
    "success": {
      "code": 0,
      "msg": "success",
      "data": {
        "core_conclusion": "核心结论字符串",
        "key_indicators": "关键指标数组",
        "abnormal_points": "异常点数组"
      }
    },
    "error": {
      "code": -1,
      "msg": "错误描述",
      "error_type": "PARAM_ERROR/TIMEOUT/DEPEND_FAIL/NO_PERMISSION"
    }
  },
  "execution_logic": {
    "trigger_condition": "用户需要解读图表、分析数据趋势时调用",
    "process_flow": [
      "参数合法性校验",
      "调用多模态解析模型识别图表信息",
      "执行趋势/异常分析算法",
      "结果格式化封装返回"
    ],
    "dependence": "依赖多模态解析模型v2.1、指标计算引擎"
  },
  "exception_handle": {
    "param_error": "返回参数错误码与错误字段，引导Agent修正入参",
    "timeout_retry": "自动重试2次，重试失败返回超时错误",
    "dependency_fail": "依赖服务不可用时返回降级结果或错误提示"
  }
}
```

## 三、Skill构建全流程规范

### 1. 需求定义阶段

原子化拆解：将复杂业务能力拆解为最小执行单元，单个Skill执行步骤不超过5步；杜绝「大而全」的万能Skill
场景对齐：用自然语言清晰描述功能与触发场景，确保Agent能通过语义精准匹配调用
边界划定：明确Skill能做什么、不能做什么，避免模糊地带导致调用错误

### 2. 开发封装阶段

命名规范：采用「领域+动作+对象」命名法，例如 text_document_summary、security_content_check，全局唯一
参数规范：必填参数控制在3个以内，可选参数不超过5个；所有参数必须明确类型与校验规则
输出规范：统一返回结构化JSON，禁止返回非结构化自然语言；结果字段语义清晰，无需Agent二次猜解
安全规范：
输入参数做白名单校验，防范注入攻击
涉及数据写入、系统变更的Skill，必须增加二次确认机制
敏感操作全链路留痕，记录调用方、时间、入参出参

### 3. 测试上架阶段

单测覆盖：覆盖正常场景、边界场景、异常场景，通过率100%方可上架
适配测试：验证Agent能否正确识别、调用、解析该Skill，确保语义描述与实际功能一致
目录同步：纳入全局Skill库统一管理，同步更新元数据与调用文档

### 4. 运维迭代阶段

版本管理：采用语义化版本号（主版本.次版本.修订号），不兼容旧版时升级主版本
核心指标：持续监控调用量、成功率、平均耗时、错误率四大指标
下线机制：废弃Skill提前公示并设置过渡期，禁止直接下线导致Agent调用失败

## 四、Skill与AI Family Agent的衔接机制

### 5. 标准调用链路

用户请求 → 言启·千行解析 → 元启·天枢编排 → 专业Agent决策 → 调用对应Skill → 执行返回结果 → 结果汇总 → 交付用户
所有Skill统一接入YYC³ Skill能力池，由元启·天枢统一管理与权限分配
专业Agent根据任务需求，从权限范围内的Skill库中选择并调用
智云·守护对所有Skill调用做实时安全审计，异常调用即时拦截

### 6. Agent调用Skill的标准流程

意图匹配：Agent判断当前任务需要外部能力，从Skill库中语义检索匹配技能
参数填充：从上下文与任务指令中提取参数，补全必填项，校验合法性
发起调用：通过标准接口调用Skill，附带会话ID与身份标识
结果处理：接收结构化结果，转化为自然语言反馈给用户/提交中枢
异常处理：调用失败时，根据错误类型选择重试、降级或上报中枢

### 7. 权限匹配机制

不同Agent拥有不同的Skill调用权限，例如格物·宗师仅可调用代码分析类Skill，创想·灵韵仅可调用内容生成类Skill
高风险Skill仅对指定Agent开放，禁止越权调用
元启·天枢拥有全局Skill调度权限，可根据任务动态分配能力

## 五、分阶段落地实施步骤

### 第一阶段：基础能力池搭建（1个月）

梳理核心高频场景，拆解首批10~20个原子Skill（覆盖语义解析、文档摘要、图表解读、文案生成、安全校验等基础能力）
落地Skill标准模板与开发规范，搭建全局Skill管理目录
完成核心Agent与Skill库的对接，跑通单Agent单Skill调用链路

### 第二阶段：规模化扩展（2个月）

按业务领域批量扩展Skill，覆盖数据分析、预测算法、安全风控、代码优化等专业领域
落地Skill调用监控与运维体系，实现全链路可观测
支持多Skill串行/并行组合调用，支撑复杂任务闭环

### 第三阶段：生态化演进（长期）

建立Skill贡献与审核机制，支持内部业务方自定义Skill
落地Skill智能推荐能力，Agent可自主发现并适配新Skill
形成标准化Skill市场，实现能力的沉淀、复用与价值变现

---

## 第一部分：首批核心Skill完整定义示例（5个核心示例）

首批选型遵循高复用、原子化、强刚需原则，覆盖通用底座、入口交互、数据分析、预测算法、创意生成等核心场景，严格遵循YYC³ Skill标准规范，可直接接入全局Skill能力池，适配全家族Agent调用。

### 1. 内容安全校验 Skill（全家族通用·基础底座）

归属领域：安全通用类 | 对应Agent：智云·守护（主）、全家族Agent（前置调用）
核心价值：所有输入输出的统一安全卡口，全链路复用，是品牌合规与内容安全的底层保障。

```
{
"skill_base_info": {
"skill_id": "YYC3-SKILL-SEC-001",
"skill_name": "content_security_check 内容安全校验",
"skill_category": "安全通用类",
"skill_desc": "对输入文本进行多维度安全检测，识别违规内容并返回风险等级与拦截建议，覆盖涉政、涉黄赌毒、暴力违法、品牌违禁、Prompt注入五大类风险",
"author": "YYC³ 技术中台-安全组",
"version": "v1.0.0",
"enable_status": true,
"permission_level": "public",
"call_timeout": 3,
"retry_times": 1
},
"input_params": {
"required": [
{
"param_name": "check_content",
"param_type": "string",
"param_desc": "待检测的文本内容，最大长度10000字符",
"example": "用户输入的查询内容/Agent生成的输出内容"
},
{
"param_name": "check_level",
"param_type": "string",
"param_desc": "检测严格等级：strict-严格（全量规则）、normal-标准（通用规则）、light-宽松（仅致命风险）",
"example": "normal"
}
],
"optional": [
{
"param_name": "scene_type",
"param_type": "string",
"param_desc": "业务场景：input-用户输入检测、output-输出内容检测、code-代码内容检测",
"default_value": "input"
}
]
},
"output_params": {
"success": {
"code": 0,
"msg": "检测完成",
"data": {
"risk_level": "pass/warn/block",
"risk_type": "风险类型标签，无风险则为null",
"risk_keywords": "命中的敏感关键词数组，无风险则为空数组",
"suggestion": "处置建议：正常放行/人工复核/强制拦截"
}
},
"error": {
"code": -1,
"msg": "错误描述",
"error_type": "PARAM_ERROR/CONTENT_TOO_LONG/SERVICE_UNAVAILABLE"
}
},
"execution_logic": {
"trigger_condition": "所有用户输入进入系统、所有Agent生成最终输出前，必须调用本Skill做安全校验",
"process_flow": [
"参数合法性校验，超长内容自动截断",
"匹配敏感词规则库与语义检测模型",
"综合判定风险等级与类型",
"返回结构化检测结果"
],
"dependence": "依赖YYC³安全规则库v3.2、语义风险检测模型"
},
"exception_handle": {
"param_error": "返回参数错误提示，默认按normal等级执行检测",
"timeout_retry": "自动重试1次，失败则按block等级拦截并告警",
"dependency_fail": "降级为基础敏感词规则检测，同步触发服务告警"
}
}
```

### 2. 结构化实体抽取 Skill（入口核心·言启·千行专属）

归属领域：语义交互类 | 对应Agent：言启·千行
核心价值：将自然语言转化为结构化指令，是意图路由与任务执行的前置基础。

```
{
"skill_base_info": {
"skill_id": "YYC3-SKILL-NLU-001",
"skill_name": "structured_entity_extraction 结构化实体抽取",
"skill_category": "语义交互类",
"skill_desc": "从用户自然语言中抽取任务意图、核心实体、关键参数，输出标准化任务指令，支持缺失参数识别与补全提示",
"author": "YYC³ 技术中台-NLP组",
"version": "v1.1.0",
"enable_status": true,
"permission_level": "entrance_only",
"call_timeout": 5,
"retry_times": 1
},
"input_params": {
"required": [
{
"param_name": "user_query",
"param_type": "string",
"param_desc": "用户原始自然语言查询",
"example": "帮我分析上个月的销售数据，预测下季度趋势"
}
],
"optional": [
{
"param_name": "context",
"param_type": "string",
"param_desc": "当前会话上下文摘要，用于多轮实体补全",
"default_value": ""
}
]
},
"output_params": {
"success": {
"code": 0,
"msg": "抽取完成",
"data": {
"intent_type": "一级意图分类：data_analysis/trend_prediction/content_create/recommend",
"intent_confidence": "意图置信度，0-1之间的数值",
"entities": "抽取到的实体键值对对象",
"missing_params": "缺失的必填参数数组，无缺失则为空",
"target_agent": "建议路由的目标Agent标识"
}
},
"error": {
"code": -1,
"msg": "错误描述",
"error_type": "PARAM_ERROR/QUERY_TOO_SHORT/SERVICE_UNAVAILABLE"
}
},
"execution_logic": {
"trigger_condition": "用户输入进入言启·千行后，首要调用本Skill完成语义解析",
"process_flow": [
"预处理用户输入，去除无效字符",
"结合上下文做意图识别与分类",
"抽取业务实体与关键参数",
"识别缺失必填项，匹配目标路由Agent",
"返回结构化结果"
],
"dependence": "依赖YYC³领域意图识别模型、实体抽取模型v2.0"
},
"exception_handle": {
"param_error": "返回错误提示，要求重新输入有效查询",
"timeout_retry": "自动重试1次，失败则降级为规则匹配模式",
"dependency_fail": "返回通用意图分类，同步上报元启·天枢"
}
}
```

### 3. 文档智能摘要 Skill（分析核心·多Agent复用）

归属领域：数据分析类 | 对应Agent：语枢·万物（主）、全家族Agent（长文本处理）
核心价值：高频复用的文本处理原子能力，支撑文档分析、报告解读、信息提炼等多场景。

```
{
"skill_base_info": {
"skill_id": "YYC3-SKILL-DATA-001",
"skill_name": "document_intelligent_summary 文档智能摘要",
"skill_category": "数据分析类",
"skill_desc": "对长文档、多文档进行智能摘要提取，支持核心观点提炼、多文档对比、指定维度摘要三种模式",
"author": "YYC³ 技术中台-AI组",
"version": "v1.2.0",
"enable_status": true,
"permission_level": "professional",
"call_timeout": 20,
"retry_times": 1
},
"input_params": {
"required": [
{
"param_name": "document_content",
"param_type": "string",
"param_desc": "待处理的文档文本内容，支持单篇长文本或多篇用分隔符拼接",
"example": "文档正文内容..."
},
{
"param_name": "summary_mode",
"param_type": "string",
"param_desc": "摘要模式：core-核心观点摘要、compare-多文档对比、dimension-指定维度摘要",
"example": "core"
}
],
"optional": [
{
"param_name": "target_dimension",
"param_type": "string",
"param_desc": "指定维度摘要时的提取维度，如风险、收益、结论等",
"default_value": ""
},
{
"param_name": "output_length",
"param_type": "int",
"param_desc": "输出摘要字数，默认300字",
"default_value": 300
}
]
},
"output_params": {
"success": {
"code": 0,
"msg": "摘要生成完成",
"data": {
"summary_content": "摘要正文内容",
"key_points": "核心要点数组",
"source_mapping": "要点对应原文位置标记数组"
}
},
"error": {
"code": -1,
"msg": "错误描述",
"error_type": "PARAM_ERROR/CONTENT_EMPTY/SERVICE_UNAVAILABLE"
}
},
"execution_logic": {
"trigger_condition": "需要处理长文档、提取核心信息、对比多份文档内容时调用",
"process_flow": [
"文档分段与预处理",
"按指定模式执行摘要生成",
"提取核心要点并做原文映射",
"按字数要求精简优化",
"返回结构化结果"
],
"dependence": "依赖YYC³文档理解大模型、文本摘要微调模型"
},
"exception_handle": {
"param_error": "返回参数错误说明，引导修正入参",
"timeout_retry": "自动重试1次，失败则缩短生成长度降级输出",
"dependency_fail": "返回抽取式摘要结果，保障基础可用"
}
}
```

### 4. 时间序列基础预测 Skill（预测核心·预见·先知专属）

归属领域：算法模型类 | 对应Agent：预见·先知
核心价值：封装通用预测算法，屏蔽底层技术细节，Agent只需传入数据即可获得标准化预测结果。

```
{
"skill_base_info": {
"skill_id": "YYC3-SKILL-ALGO-001",
"skill_name": "time_series_basic_predict 时间序列基础预测",
"skill_category": "算法模型类",
"skill_desc": "基于历史时间序列数据，自动适配最优算法，输出未来周期预测结果与置信区间，支持趋势、拐点、异常识别",
"author": "YYC³ 技术中台-算法组",
"version": "v1.0.0",
"enable_status": true,
"permission_level": "professional",
"call_timeout": 15,
"retry_times": 1
},
"input_params": {
"required": [
{
"param_name": "history_data",
"param_type": "array",
"param_desc": "历史时间序列数据，格式为[{"date":"YYYY-MM-DD","value":数值}]",
"example": "[{"date":"2024-01-01","value":120}]"
},
{
"param_name": "predict_periods",
"param_type": "int",
"param_desc": "预测未来周期数，最大支持365",
"example": 30
}
],
"optional": [
{
"param_name": "frequency",
"param_type": "string",
"param_desc": "数据频率：day/week/month/year，自动识别则不传",
"default_value": "auto"
},
{
"param_name": "confidence_level",
"param_type": "float",
"param_desc": "置信度水平，默认0.95",
"default_value": 0.95
}
]
},
"output_params": {
"success": {
"code": 0,
"msg": "预测完成",
"data": {
"predict_result": "预测结果数组，格式同历史数据",
"confidence_interval": "置信区间上下界数组",
"model_used": "实际使用的算法模型：Prophet/ARIMA/LSTM",
"trend_judge": "整体趋势判断：上升/下降/平稳",
"abnormal_points": "预测异常拐点数组"
}
},
"error": {
"code": -1,
"msg": "错误描述",
"error_type": "PARAM_ERROR/DATA_INSUFFICIENT/SERVICE_UNAVAILABLE"
}
},
"execution_logic": {
"trigger_condition": "需要对业务指标做未来趋势预测、异常预警时调用",
"process_flow": [
"数据清洗与缺失值填充",
"自动识别数据频率与特征",
"匹配最优预测算法模型",
"执行预测计算与置信区间生成",
"识别趋势与异常拐点",
"返回结构化结果"
],
"dependence": "依赖Prophet、ARIMA、LSTM算法引擎v2.3"
},
"exception_handle": {
"param_error": "返回参数错误与数据格式要求",
"timeout_retry": "自动重试1次，失败则降级为简单线性预测",
"data_insufficient": "返回数据量不足提示，明确最少数据要求"
}
}
```

### 5. 品牌定向文案生成 Skill（创意核心·创想·灵韵专属）

归属领域：内容生成类 | 对应Agent：创想·灵韵
核心价值：内置YYC³品牌规范，保障所有创意输出贴合品牌调性，避免人设与品牌形象偏离。

```
{
"skill_base_info": {
"skill_id": "YYC3-SKILL-CREATE-001",
"skill_name": "brand_copy_generation 品牌定向文案生成",
"skill_category": "内容生成类",
"skill_desc": "基于YYC³品牌规范与调性，生成指定类型的文案内容，自动植入品牌元素，保障品牌表述统一",
"author": "YYC³ 品牌部+技术中台",
"version": "v1.0.0",
"enable_status": true,
"permission_level": "professional",
"call_timeout": 10,
"retry_times": 1
},
"input_params": {
"required": [
{
"param_name": "copy_type",
"param_type": "string",
"param_desc": "文案类型：slogan/宣传文案/产品介绍/活动文案/报告标题",
"example": "宣传文案"
},
{
"param_name": "core_theme",
"param_type": "string",
"param_desc": "文案核心主题与业务诉求",
"example": "推广行业大模型定制服务"
}
],
"optional": [
{
"param_name": "style_tone",
"param_type": "string",
"param_desc": "文案风格：专业严谨/科技前沿/简洁有力/人文厚重",
"default_value": "专业严谨"
},
{
"param_name": "plan_count",
"param_type": "int",
"param_desc": "生成方案数量，默认3个，最多5个",
"default_value": 3
}
]
},
"output_params": {
"success": {
"code": 0,
"msg": "生成完成",
"data": {
"copy_list": "文案方案数组，每项包含方案名称、文案内容、适用场景",
"brand_elements": "植入的品牌元素说明",
"adjustable_dimension": "可调整的方向建议数组"
}
},
"error": {
"code": -1,
"msg": "错误描述",
"error_type": "PARAM_ERROR/THEME_TOO_VAGUE/SERVICE_UNAVAILABLE"
}
},
"execution_logic": {
"trigger_condition": "需要生成品牌相关文案、营销内容、官方宣传材料时调用",
"process_flow": [
"解析核心诉求与风格要求",
"加载YYC³品牌规范与话术库",
"按要求生成多版本文案",
"品牌合规性校验与优化",
"补充适用场景与调整建议",
"返回结构化结果"
],
"dependence": "依赖YYC³品牌知识库、创意生成大模型、品牌合规校验规则"
},
"exception_handle": {
"param_error": "返回参数错误与类型说明",
"timeout_retry": "自动重试1次，失败则减少方案数量降级输出",
"dependency_fail": "返回基础通用文案，标注未经过品牌校验"
}
}
```

## 第二部分：Agent调用Skill的提示词嵌入方案

### 一、嵌入核心原则

优先级秩序不变：身份规则 > 安全红线 > 任务目标 > Skill调用逻辑，Skill调用始终服务于任务，不干扰Agent核心身份
无侵入式架构：在原有Agent提示词框架中新增独立模块，不拆解原有身份、规则、任务三层结构
权限最小化：每个Agent仅开放本职相关的Skill列表，禁止全量开放，避免能力越界与调用混乱
结构化可解析：调用指令采用固定标签格式，便于系统层识别、拦截与执行，降低幻觉调用概率

### 二、标准嵌入架构与通用模板

嵌入位置
统一插入到Agent系统提示词的 「职责层」之后、「规则层」之前，新增独立章节 「能力调用层·Skill调用规范」，与原有结构完全解耦。
通用可复用模板（可直接复制到任意Agent提示词中）

### 三、能力调用层·Skill调用规范

#### 1. 可用能力范围

你仅可调用以下授权范围内的Skill工具完成任务，超出列表的能力需求必须上报元启·天枢申请调度，禁止私自执行非授权能力。
【你的专属Skill列表】
• 【Skill名称1】：Skill功能描述，适用场景说明
• 【Skill名称2】：Skill功能描述，适用场景说明
• 【Skill名称3】：Skill功能描述，适用场景说明

#### 2. 调用触发判断

满足以下任一条件时，必须调用对应Skill，禁止仅凭自身能力直接输出结果：
• 任务需要调用外部数据、算法、系统接口才能完成
• 任务结果要求结构化、标准化输出，纯生成无法保障准确率
• 任务涉及安全校验、品牌合规等必须标准化管控的环节
• 自身知识与能力边界无法覆盖任务需求

#### 3. 标准调用流程

1. **需求匹配**：判断当前任务是否需要工具支持，匹配最适配的Skill
2. **参数提取**：从上下文与用户需求中提取所有必填参数，缺失则向用户一次性确认
3. **发起调用**：使用固定格式输出调用指令，等待系统返回结果
4. **结果校验**：校验Skill返回结果的完整性与合理性，异常则按规则重试或上报
5. **整合输出**：将结构化结果转化为符合你角色风格的自然语言，交付给用户/中枢

#### 9. 调用指令格式

必须严格使用以下格式输出调用指令，禁止自由格式表述，否则系统无法识别执行：

```
<skill_call>
{
"skill_name": "调用的Skill名称",
"params": {
"参数名1": "参数值1",
"参数名2": "参数值2"
}
}
</skill_call>
```

#### 4. 结果处理与异常规则

• 调用成功：基于返回的data字段整合输出，不得篡改核心结果数据，可做表述优化
• 参数错误：根据错误提示修正参数后重试，最多重试2次，仍失败则上报元启·天枢
• 服务超时：自动重试1次，失败则告知用户当前服务暂不可用，给出替代方案
• 禁止行为：禁止编造Skill返回结果，禁止模拟Skill执行，禁止绕过Skill直接输出结论

#### 5. 安全与审计规则

• 所有Skill调用自动经过智云·守护安全校验，违规调用会被直接拦截
• 所有调用全链路留痕，包含调用方、入参、出参、耗时，支持审计追溯
• 高风险操作类Skill调用，必须先获得用户二次确认，禁止自动执行

### 三、分角色Agent嵌入适配方案

#### 3. 入口Agent（言启·千行）适配方案

嵌入侧重点：聚焦语义解析类Skill，强化参数抽取与路由匹配能力，调用链路短平快
核心调整：Skill调用结果直接用于路由决策，无需转化为自然语言；增加「多Skill串行调用」规则（先安全校验→再实体抽取→最后路由分发）
补充规则片段：
所有用户输入必须先调用「内容安全校验」Skill，检测通过后方可执行后续解析；检测不通过直接执行标准拦截话术，终止流程。

#### 4. 专业执行Agent（语枢·万物/预见·先知/创想·灵韵等）适配方案

嵌入侧重点：聚焦领域专属Skill，明确「核心任务必须依赖Skill完成」的强约束，避免纯生成幻觉
核心调整：增加「结果溯源」规则，输出结论必须标注数据/结果来源于对应Skill；复杂任务支持多Skill串行组合调用
补充规则片段（以语枢·万物为例）：
所有文档分析类任务，必须调用「文档智能摘要」Skill提取核心信息，再基于结果做深度解读；禁止直接凭空分析未传入的文档内容。

#### 5. 全局中枢Agent（元启·天枢）适配方案

嵌入侧重点：聚焦调度类、运维类Skill，拥有全量Skill目录的调度权限，不直接执行业务Skill
核心调整：增加「Skill编排」能力，可拆解任务为多Skill执行链路，分配给对应专业Agent执行；支持全局Skill状态监控与故障调度
补充规则片段：
你不直接调用业务类Skill，仅负责根据任务需求，调度对应专业Agent执行其授权范围内的Skill；当专业Agent能力不足时，你可临时分配额外Skill权限并备案。

### 四、落地最佳实践

少样本增强提升准确率：对于调用逻辑复杂的Skill，在规范末尾补充1~2个完整的「需求→调用→结果→输出」示例，可将调用准确率提升30%以上。
分层控制避免幻觉：系统层做二次校验，校验Skill名称、参数格式是否合法，非法调用直接拦截并返回错误，不依赖模型单一判断。
动态加载适配场景：不同业务场景动态注入对应Skill列表，无需全量写入提示词，既节省上下文窗口，又避免能力越界。
版本同步机制：Skill版本迭代时，同步更新对应Agent提示词中的功能描述，保障模型认知与实际能力一致。

---

## 第三部分：扩展 Skill 完整定义示例（新增5个）

以下5个Skill补全覆盖代码分析、推荐算法、安全检测、性能诊断、多模态生成五大领域，与前文5个共同构成10个完整示例。

### 6. 代码质量分析 Skill（格物·宗师专属）

归属领域：代码质量类 | 对应Agent：格物·宗师
核心价值：将代码静态分析与质量评估封装为标准能力，支撑自动化代码审查。

```json
{
  "skill_base_info": {
    "skill_id": "YYC3-SKILL-CODE-001",
    "skill_name": "code_quality_analysis 代码质量分析",
    "skill_category": "代码质量类",
    "skill_desc": "对代码进行静态分析，识别质量问题、安全漏洞、性能瓶颈，输出分级问题清单与优化建议",
    "author": "YYC³ 技术中台-代码质量组",
    "version": "v1.0.0",
    "enable_status": true,
    "permission_level": "professional",
    "call_timeout": 30,
    "retry_times": 1
  },
  "input_params": {
    "required": [
      {
        "param_name": "code_content",
        "param_type": "string",
        "param_desc": "待分析的代码内容",
        "example": "function hello() { console.log('hello') }"
      },
      {
        "param_name": "language",
        "param_type": "string",
        "param_desc": "编程语言：typescript/javascript/python/go/java",
        "example": "typescript"
      }
    ],
    "optional": [
      {
        "param_name": "analysis_depth",
        "param_type": "string",
        "param_desc": "分析深度：quick-快速扫描、standard-标准分析、deep-深度分析",
        "default_value": "standard"
      },
      {
        "param_name": "check_rules",
        "param_type": "array",
        "param_desc": "自定义检查规则列表，如security/performance/maintainability",
        "default_value": ["security","performance","maintainability"]
      }
    ]
  },
  "output_params": {
    "success": {
      "code": 0,
      "msg": "分析完成",
      "data": {
        "overall_score": "代码质量总评分0-100",
        "issues": "问题数组，每项包含级别(critical/warning/info)、类型、位置、描述、修复建议",
        "metrics": "代码复杂度、重复率、测试覆盖率预估等量化指标",
        "suggestions": "优化建议数组，按优先级排序"
      }
    },
    "error": {
      "code": -1,
      "msg": "错误描述",
      "error_type": "PARAM_ERROR/LANGUAGE_UNSUPPORTED/CODE_TOO_LARGE/SERVICE_UNAVAILABLE"
    }
  },
  "execution_logic": {
    "trigger_condition": "需要对代码做质量评估、安全审查、性能诊断时调用",
    "process_flow": [
      "代码预处理与语法校验",
      "按规则集执行静态分析",
      "安全漏洞扫描",
      "性能瓶颈识别",
      "生成分级问题清单与优化建议"
    ],
    "dependence": "依赖ESLint/CodeQL静态分析引擎v3.0、安全漏洞规则库"
  },
  "exception_handle": {
    "param_error": "返回参数错误说明与支持的语言列表",
    "timeout_retry": "自动重试1次，失败则降级为快速扫描模式",
    "dependency_fail": "返回基础语法检查结果，标注深度分析不可用"
  }
}
```

### 7. 用户画像构建 Skill（千里·伯乐专属）

归属领域：推荐算法类 | 对应Agent：千里·伯乐
核心价值：将用户行为数据转化为结构化画像，是个性化推荐的基础。

```json
{
  "skill_base_info": {
    "skill_id": "YYC3-SKILL-REC-001",
    "skill_name": "user_profile_build 用户画像构建",
    "skill_category": "推荐算法类",
    "skill_desc": "基于用户行为数据、偏好信息、历史交互记录，构建多维度用户画像，输出标签体系与特征权重",
    "author": "YYC³ 技术中台-推荐组",
    "version": "v1.0.0",
    "enable_status": true,
    "permission_level": "professional",
    "call_timeout": 10,
    "retry_times": 1
  },
  "input_params": {
    "required": [
      {
        "param_name": "user_id",
        "param_type": "string",
        "param_desc": "用户唯一标识",
        "example": "USER-2026-001"
      },
      {
        "param_name": "behavior_data",
        "param_type": "array",
        "param_desc": "用户行为数据数组，每项包含行为类型、时间戳、对象、权重",
        "example": "[{\"type\":\"view\",\"target\":\"doc-001\",\"timestamp\":\"2026-07-01\",\"weight\":1}]"
      }
    ],
    "optional": [
      {
        "param_name": "profile_dimensions",
        "param_type": "array",
        "param_desc": "画像维度：interest/preference/behavior/demographic",
        "default_value": ["interest","preference","behavior"]
      }
    ]
  },
  "output_params": {
    "success": {
      "code": 0,
      "msg": "画像构建完成",
      "data": {
        "profile_tags": "标签数组，每项包含标签名、权重(0-1)、来源",
        "interest_vector": "兴趣向量表示，用于相似度计算",
        "preference_scores": "偏好维度评分对象",
        "update_time": "画像最后更新时间"
      }
    },
    "error": {
      "code": -1,
      "msg": "错误描述",
      "error_type": "PARAM_ERROR/USER_NOT_FOUND/INSUFFICIENT_DATA/SERVICE_UNAVAILABLE"
    }
  },
  "execution_logic": {
    "trigger_condition": "需要构建用户画像、更新用户标签、支撑个性化推荐时调用",
    "process_flow": [
      "行为数据清洗与归一化",
      "基于行为序列提取兴趣标签",
      "计算各维度特征权重",
      "生成结构化画像与向量表示",
      "返回结果并更新画像缓存"
    ],
    "dependence": "依赖用户行为分析模型v2.0、标签体系库"
  },
  "exception_handle": {
    "param_error": "返回参数错误说明",
    "insufficient_data": "返回基础画像，标注数据量不足",
    "timeout_retry": "自动重试1次，失败则返回缓存画像"
  }
}
```

### 8. 异常行为检测 Skill（智云·守护专属）

归属领域：安全检测类 | 对应Agent：智云·守护
核心价值：基于行为基线实时识别异常操作，是安全防护体系的核心检测能力。

```json
{
  "skill_base_info": {
    "skill_id": "YYC3-SKILL-SEC-002",
    "skill_name": "abnormal_behavior_detection 异常行为检测",
    "skill_category": "安全检测类",
    "skill_desc": "基于用户/API行为基线，实时检测异常登录、API滥用、批量操作、数据泄露等行为风险",
    "author": "YYC³ 技术中台-安全组",
    "version": "v1.0.0",
    "enable_status": true,
    "permission_level": "professional",
    "call_timeout": 5,
    "retry_times": 1
  },
  "input_params": {
    "required": [
      {
        "param_name": "subject_id",
        "param_type": "string",
        "param_desc": "检测主体标识（用户ID/API Key/IP地址）",
        "example": "USER-2026-001"
      },
      {
        "param_name": "behavior_event",
        "param_type": "object",
        "param_desc": "当前行为事件，包含行为类型、时间、目标、频率等",
        "example": "{\"type\":\"api_call\",\"target\":\"/data/export\",\"frequency\":50,\"time_window\":\"1min\"}"
      }
    ],
    "optional": [
      {
        "param_name": "detection_mode",
        "param_type": "string",
        "param_desc": "检测模式：realtime-实时检测、batch-批量分析",
        "default_value": "realtime"
      }
    ]
  },
  "output_params": {
    "success": {
      "code": 0,
      "msg": "检测完成",
      "data": {
        "risk_level": "normal/suspicious/malicious",
        "anomaly_type": "异常类型：brute_force/api_abuse/data_exfiltration/credential_stuffing",
        "deviation_score": "偏离基线分数0-100",
        "recommended_action": "建议处置：monitor/alert/restrict/block"
      }
    },
    "error": {
      "code": -1,
      "msg": "错误描述",
      "error_type": "PARAM_ERROR/NO_BASELINE/SERVICE_UNAVAILABLE"
    }
  },
  "execution_logic": {
    "trigger_condition": "所有用户操作、API调用需实时或定期调用本Skill做行为风险检测",
    "process_flow": [
      "加载主体行为基线模型",
      "计算当前行为偏离度",
      "匹配异常行为模式库",
      "综合判定风险等级与类型",
      "输出处置建议"
    ],
    "dependence": "依赖行为基线模型v2.0、异常模式规则库"
  },
  "exception_handle": {
    "no_baseline": "返回需建立基线提示，新用户放行并开始采集",
    "timeout_retry": "自动重试1次，失败则降级为规则匹配模式"
  }
}
```

### 9. 性能诊断 Skill（格物·宗师专属）

归属领域：性能优化类 | 对应Agent：格物·宗师
核心价值：自动化识别系统性能瓶颈，输出可执行的优化方案。

```json
{
  "skill_base_info": {
    "skill_id": "YYC3-SKILL-PERF-001",
    "skill_name": "performance_diagnosis 性能诊断",
    "skill_category": "性能优化类",
    "skill_desc": "分析系统性能指标、慢查询、资源占用数据，识别瓶颈根因，输出分级优化建议",
    "author": "YYC³ 技术中台-性能组",
    "version": "v1.0.0",
    "enable_status": true,
    "permission_level": "professional",
    "call_timeout": 20,
    "retry_times": 1
  },
  "input_params": {
    "required": [
      {
        "param_name": "metrics_data",
        "param_type": "object",
        "param_desc": "性能指标数据，包含CPU/内存/IO/网络/响应时间等",
        "example": "{\"cpu_usage\":85,\"memory_usage\":72,\"avg_response_time\":1200}"
      },
      {
        "param_name": "target_system",
        "param_type": "string",
        "param_desc": "目标系统或服务标识",
        "example": "yyc3-api-gateway"
      }
    ],
    "optional": [
      {
        "param_name": "time_range",
        "param_type": "string",
        "param_desc": "分析时间范围，默认最近1小时",
        "default_value": "1h"
      },
      {
        "param_name": "diagnosis_depth",
        "param_type": "string",
        "param_desc": "诊断深度：surface-表层分析、root_cause-根因分析",
        "default_value": "root_cause"
      }
    ]
  },
  "output_params": {
    "success": {
      "code": 0,
      "msg": "诊断完成",
      "data": {
        "bottlenecks": "瓶颈数组，每项包含类型/位置/严重度/影响范围",
        "root_causes": "根因分析数组",
        "optimization_plan": "优化方案数组，按投入产出比排序",
        "expected_improvement": "预期优化效果预估"
      }
    },
    "error": {
      "code": -1,
      "msg": "错误描述",
      "error_type": "PARAM_ERROR/INSUFFICIENT_METRICS/SERVICE_UNAVAILABLE"
    }
  },
  "execution_logic": {
    "trigger_condition": "系统性能下降、响应变慢、资源占用异常时调用",
    "process_flow": [
      "指标数据预处理与异常标记",
      "瓶颈识别与分类",
      "根因链路追踪分析",
      "生成优化方案与效果预估",
      "输出结构化诊断报告"
    ],
    "dependence": "依赖性能分析引擎v2.1、历史性能基线库"
  },
  "exception_handle": {
    "insufficient_metrics": "返回已有数据分析结果，标注数据不足",
    "timeout_retry": "自动重试1次，失败则降级为表层分析"
  }
}
```

### 10. 多模态内容生成 Skill（创想·灵韵专属）

归属领域：内容生成类 | 对应Agent：创想·灵韵
核心价值：统一封装文本、图像、音频多模态生成能力，支撑多元化创意产出。

```json
{
  "skill_base_info": {
    "skill_id": "YYC3-SKILL-CREATE-002",
    "skill_name": "multimodal_content_generation 多模态内容生成",
    "skill_category": "内容生成类",
    "skill_desc": "根据创意需求，生成文本、图像、音频等多模态内容，支持风格定向与品牌元素植入",
    "author": "YYC³ 品牌部+技术中台",
    "version": "v1.0.0",
    "enable_status": true,
    "permission_level": "professional",
    "call_timeout": 30,
    "retry_times": 1
  },
  "input_params": {
    "required": [
      {
        "param_name": "content_type",
        "param_type": "string",
        "param_desc": "内容类型：text-文案、image-图像、audio-音频、mixed-混合",
        "example": "image"
      },
      {
        "param_name": "creative_brief",
        "param_type": "string",
        "param_desc": "创意需求描述，包含主题、风格、目标受众等",
        "example": "为YYC³智能平台生成科技感首页Banner，深海蓝主色调"
      }
    ],
    "optional": [
      {
        "param_name": "style_reference",
        "param_type": "string",
        "param_desc": "风格参考：描述或参考图片URL",
        "default_value": ""
      },
      {
        "param_name": "brand_elements",
        "param_type": "boolean",
        "param_desc": "是否自动植入YYC³品牌元素",
        "default_value": true
      },
      {
        "param_name": "output_count",
        "param_type": "int",
        "param_desc": "生成方案数量，默认2个",
        "default_value": 2
      }
    ]
  },
  "output_params": {
    "success": {
      "code": 0,
      "msg": "生成完成",
      "data": {
        "content_list": "内容数组，每项包含类型、内容(文本/URL)、风格说明、适用场景",
        "brand_compliance": "品牌合规校验结果",
        "adjustable_params": "可调整的参数建议"
      }
    },
    "error": {
      "code": -1,
      "msg": "错误描述",
      "error_type": "PARAM_ERROR/BRIEF_TOO_VAGUE/GENERATION_FAILED/SERVICE_UNAVAILABLE"
    }
  },
  "execution_logic": {
    "trigger_condition": "需要生成图像、音频、多模态创意内容时调用",
    "process_flow": [
      "解析创意需求与风格要求",
      "加载品牌规范与素材库",
      "路由至对应模态生成模型",
      "执行生成与品牌合规校验",
      "输出多方案结果"
    ],
    "dependence": "依赖多模态生成模型集群、品牌素材库v2.0"
  },
  "exception_handle": {
    "brief_too_vague": "返回需补充信息提示，列出必要描述维度",
    "generation_failed": "自动重试1次，失败则返回基础通用模板",
    "timeout_retry": "减少输出数量后重试1次"
  }
}
```

---

## 关联文档

| 文档名称 | 关联关系 | 链接 |
| -------- | -------- | ---- |
| 九层全栈架构 | Skill 运行于 Layer05 | [YYC3-AI-Family-九层全栈架构.md](./YYC3-AI-Family-九层全栈架构.md) |
| Agent 设计规范 | Agent 调用 Skill 的标准规范 | [YYC3-Agent.md](./YYC3-Agent.md) |
| 多智能体整体架构 | 各 Agent 专属 Skill 映射 | [YYC3-AI-Family-多智能体整体架构.md](./YYC3-AI-Family-多智能体整体架构.md) |
| Skill 安全审计流程 | 第三方 Skill 上架审核 | [YYC3-Skill-安全审计流程.md](./YYC3-Skill-安全审计流程.md) |

---

## 变更历史

| 版本 | 日期 | 变更内容 | 作者 |
| ---- | ---- | -------- | ---- |
| v2.0.0 | 2026-07-23 | 补充 YAML 标头、新增5个 Skill 示例（代码分析/用户画像/异常检测/性能诊断/多模态生成）、交叉引用、变更历史 | YanYuCloudCube Team |
| v1.0.0 | 2026-03-21 | 初始版本：5个核心 Skill 示例 | YanYuCloudCube Team |

---
