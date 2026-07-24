---
file: YYC3-ARCH-INVENTORY-03-Skills.md
description: YYC³ Skills 架构可视化清单 — 全量分类、社区/市场化/NVIDIA 三大池
author: YYC³ 智能架构顾问
version: v1.0.0
created: 2026-07-24
status: stable
tags: [架构清单, Skills, 分类]
---

# YYC³ Skills 架构可视化清单

> **单一职责 · 标准化复用 · Agent 按需调用**

---

## 一、Skills 总体架构

```
┌─────────────────────────────────────────────────────────────────────┐
│                    YYC³ Skills 三层能力池                           │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │           🏘️ 社区技能池 skills-hub/community/               │   │
│  │           ~283 个 Skill（最大池 · 社区贡献）                 │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │           🏪 市场化技能池 skills-hub/marketplace/            │   │
│  │           ~121 个 Skill（含 Anthropic 官方 Skills）          │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │           🤖 AI/ML 技能池 skills-hub/ai-ml/                 │   │
│  │           NVIDIA Skills（官方签名 · 安全供应链）              │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │           💼 B2B 技能池 skills-hub/b2b/                     │   │
│  │           b2b-sdr-template + b2b-skills（待合并去重）       │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

---

## 二、社区技能分类（`skills-hub/community/`）

### 2.1 按领域分类

```
┌─────────────────────────────────────────────────────────────────────┐
│  社区技能 ~283 个 — 按领域分类                                      │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  📊 数据分析类                                    ~30+              │
│  ├── a-stock-data       A 股数据获取                                │
│  ├── us-stock-analysis  美股分析                                    │
│  ├── stock-analysis     通用股票分析                                │
│  ├── neodata-financial-search 金融搜索                              │
│  ├── lingxi-financialsearch    灵犀金融搜索                         │
│  ├── earnings-tracker  财报追踪                                    │
│  ├── macro-monitor     宏观监控                                    │
│  └── ...                                                           │
│                                                                     │
│  🛠️ 开发工具类                                     ~40+             │
│  ├── fullstack-dev     全栈开发助手                                │
│  ├── frontend-dev      前端开发助手                                │
│  ├── flutter-dev       Flutter 开发                                │
│  ├── react-native-dev  React Native 开发                           │
│  ├── cangjie-skill     仓颉语言                                    │
│  ├── task-implement    任务实现                                    │
│  ├── task-alignment    任务对齐                                    │
│  ├── tdd               TDD 开发                                    │
│  └── ...                                                           │
│                                                                     │
│  📝 内容创作类                                     ~25+             │
│  ├── novel-writing     小说写作                                    │
│  ├── novel-writer      小说作家                                    │
│  ├── khazix-writer     卡兹克写作                                  │
│  ├── fbs-bookwriter    写书助手                                    │
│  ├── content-factory   内容工厂                                    │
│  ├── content-ops       内容运营                                    │
│  ├── seo-ops           SEO 优化                                    │
│  └── ...                                                           │
│                                                                     │
│  🤖 AI 与模型类                                     ~20+            │
│  ├── openai-image-gen  OpenAI 图片生成                             │
│  ├── openai-whisper    OpenAI 语音识别                             │
│  ├── model-usage       模型用量                                    │
│  ├── deep-research     深度研究                                    │
│  ├── autoresearch      自动研究                                    │
│  └── ...                                                           │
│                                                                     │
│  ☁️ 云服务与 API 类                                 ~35+            │
│  ├── cloudbase         腾讯云开发                                  │
│  ├── cloudflare        Cloudflare                                  │
│  ├── tencentcloud-*    腾讯云系列（COS/CLS/OCR 等）                │
│  ├── edgeone           边缘安全                                    │
│  ├── netlify-deploy    Netlify 部署                                │
│  ├── web-deploy        Web 部署                                    │
│  └── ...                                                           │
│                                                                     │
│  💬 通讯与协同类                                     ~20+           │
│  ├── dingtalk-unified  钉钉统一                                    │
│  ├── lark-unified      飞书统一                                    │
│  ├── wecom-unified     企微统一                                    │
│  ├── imap-smtp-email   电子邮件                                    │
│  ├── gmail             Gmail                                       │
│  ├── email-skill       邮件技能                                    │
│  └── ...                                                           │
│                                                                     │
│  🧩 效率工具类                                     ~30+            │
│  ├── plan-tracker      计划追踪                                    │
│  ├── goal-tracker      目标追踪                                    │
│  ├── habit-tracker     习惯追踪                                    │
│  ├── study-planner     学习规划                                    │
│  ├── calendar          日历                                        │
│  ├── caldav-calendar   CalDAV 日历                                │
│  ├── pdfkit-py         PDF 生成                                    │
│  ├── md-to-pdf-cjk     MD 转 PDF                                  │
│  └── ...                                                           │
│                                                                     │
│  🎨 设计与创意类                                     ~15+           │
│  ├── guizang-ppt-skill 歸藏 PPT 技能                               │
│  ├── excalidraw-diagram Excalidraw 图表                            │
│  ├── deck-generator    Deck 生成器                                 │
│  ├── gsap-animation    GSAP 动画                                  │
│  └── ...                                                           │
│                                                                     │
│  🛒 电商与生活服务类                                 ~20+           │
│  ├── 12306-train       12306 火车票                                │
│  ├── ctrip-wendao      携程问道                                    │
│  ├── meituan-*         美团系列                                    │
│  ├── didi-ride         滴滴出行                                    │
│  ├── airbnb            Airbnb                                      │
│  ├── flight-tracker    航班追踪                                    │
│  └── ...                                                           │
│                                                                     │
│  🔬 学术与教育类                                     ~15+           │
│  ├── academic-tutor    学业导师                                    │
│  ├── academic-translation 学术翻译                                │
│  ├── arxiv-reader      Arxiv 阅读                                 │
│  ├── arxiv-watcher     Arxiv 监控                                 │
│  ├── open-lesson       公开课                                      │
│  └── ...                                                           │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

---

## 三、市场化技能（`skills-hub/marketplace/`）

### 3.1 Anthropic 官方 Skills

```
anthropics-skills/
├── algorithmic-art      算法艺术生成
├── brand-guidelines     品牌指南
├── canvas-design        Canvas 设计
├── claude-api           Claude API 多语言 SDK 指南
│   ├── csharp/          C# SDK
│   ├── curl/            Curl 示例
│   ├── go/              Go SDK
│   ├── java/            Java SDK
│   ├── php/             PHP SDK
│   ├── python/          Python SDK
│   └── ruby/            Ruby SDK
├── doc-coauthoring      文档协作
├── docx                 Word 文档处理
├── frontend-design      前端设计
├── internal-comms       内部沟通
├── mcp-builder          MCP 服务构建器
├── pdf                  PDF 处理
├── pptx                 PPT 处理
└── skill-creator        Skill 创建器（含评估系统）
```

### 3.2 其他市场化 Skills（代表性）

| Skill | 功能 |
|-------|------|
| activecampaign-automation | ActiveCampaign 自动化 |
| airtable-automation | Airtable 自动化 |
| amplitude-automation | Amplitude 自动化 |
| agent-analytics | Agent 分析 |

---

## 四、NVIDIA 技能池（`skills-hub/ai-ml/nvidia-skills/`）

| 分类 | 技能数 | 说明 |
|------|--------|------|
| AI-Q 部署 | 2 | aiq-deploy, aiq-research |
| CUDA-Q | 1 | cudaq-guide |
| cuOpt 优化 | 6 | cuopt-* 系列 |
| cuPyNumeric | 2 | cupynumeric-hdf5, cupynumeric-install |
| DALI | 1 | dali-dynamic-mode |
| DeepStream | 1 | deepstream-dev |
| 医学影像 | 3 | dicom-* 系列 |
| Dynamo | 3 | dynamo-* 系列 |
| Earth2 | 2 | earth2studio-* 系列 |
| RAG | 3 | rag-blueprint, rag-eval, rag-perf |
| NeMoClaw | 3 | nemoclaw-* 系列 |
| 其他 | ~40+ | 更多 NVIDIA 官方签名技能 |

> 总计：**~60+** NVIDIA 官方技能（OMS 签名验证）

---

## 五、B2B 技能池（`skills-hub/b2b/`）

### ⚠️ 存在重复 — 2 套相同子技能

| Skill | b2b-sdr-template/skills/ | b2b-skills/skills/ | 状态 |
|-------|--------------------------|---------------------|------|
| chroma-memory | ✅ | ✅ | 🔴 重复 |
| delivery-queue | ✅ | ✅ | 🔴 重复 |
| graphify | ✅ | ✅ | 🔴 重复 |
| lead-discovery | ✅ | ✅ | 🔴 重复 |
| quotation-generator | ✅ | ✅ | 🔴 重复 |
| sdr-humanizer | ✅ | ✅ | 🔴 重复 |
| supermemory | ✅ | ✅ | 🔴 重复 |
| telegram-toolkit | ✅ | ✅ | 🔴 重复 |

> ⚠️ **建议**：保留 `b2b-sdr-template/skills/` 为权威来源，删除 `b2b-skills/skills/` 副本。

---

## 六、Skill 标准格式模板

所有 Skill 统一采用以下结构化定义：

```json
{
  "skill_base_info": {
    "skill_id": "YYC3-SKILL-{CATEGORY}-{NUM}",
    "skill_name": "skill_name",
    "skill_category": "分类标识",
    "skill_desc": "技能描述",
    "author": "YYC³ 技术中台",
    "version": "v1.0.0",
    "enable_status": true,
    "permission_level": "public",
    "call_timeout": 15,
    "retry_times": 2
  },
  "input_params": { "required": [], "optional": [] },
  "output_params": { "success": {}, "error": {} },
  "execution_logic": { "trigger_condition": "", "process_flow": [], "dependence": "" },
  "exception_handle": {}
}
```

---

## 七、所属文件清单

| 池 | 路径 | Skill 数 | 状态 |
|----|------|----------|------|
| 社区技能 | `skills-hub/community/` | ~283 | ✅ 活跃 |
| 市场化技能 | `skills-hub/marketplace/` | ~121 | ✅ 活跃 |
| NVIDIA 技能 | `skills-hub/ai-ml/nvidia-skills/` | ~60 | ✅ 外部来源 |
| B2B 技能 | `skills-hub/b2b/` | ~16(8x2) | ⚠️ 去重处理中 |
| 核心设计原则 | `docs/YYC3-AI-Family-Agent-链路构建/YYC3-AI-Family-Skill-核心设计原则.md` | — | ✅ 核心文档 |
| 安全审计流程 | `docs/YYC3-AI-Family-Agent-链路构建/YYC3-AI-Family-Skill-安全审计流程.md` | — | ✅ 核心文档 |
