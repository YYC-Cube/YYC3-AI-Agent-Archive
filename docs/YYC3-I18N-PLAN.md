---
file: YYC3-I18N-PLAN.md
description: YYC³ 零依赖 10 语言 i18n 项目方案 — 自研国际化引擎
author: YYC³ 智能架构顾问
version: v1.0.0
created: 2026-07-24
status: planning
tags: [i18n, 国际化, 零依赖, 10语言]
---

# YYC³ 零依赖 10 语言 i18n 项目方案

> **言启千行代码，语枢万物智能**
> **自研无依赖国际化引擎 · 覆盖 Agent 系统提示词 + Skills 标准化**

---

## 一、覆盖语言（10 种）

| # | 语言 | 区域码 | 方向 | 覆盖优先级 |
|---|------|--------|:----:|:----------:|
| 1 | 简体中文 | `zh-CN` | LTR | P0 — 主语言 |
| 2 | 英语 | `en` | LTR | P0 — 主语言 |
| 3 | 日语 | `ja` | LTR | P1 |
| 4 | 韩语 | `ko` | LTR | P1 |
| 5 | 法语 | `fr` | LTR | P1 |
| 6 | 德语 | `de` | LTR | P1 |
| 7 | 西班牙语 | `es` | LTR | P2 |
| 8 | 俄语 | `ru` | LTR | P2 |
| 9 | 阿拉伯语 | `ar` | RTL | P2 |
| 10 | 葡萄牙语 | `pt` | LTR | P2 |

---

## 二、技术架构（零外部依赖）

```
┌─────────────────────────────────────────────────────────────────────┐
│               YYC³ i18n 引擎（零外部依赖）                          │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │  i18n Engine 核心                                              │   │
│  │  ┌─────────────────────────────────────────────────────────┐ │   │
│  │  │  loadLocale(lang)   →  从 JSON 文件加载翻译表            │ │   │
│  │  │  t(key, params?)    →  获取翻译 + 参数插值              │ │   │
│  │  │  tpl(text, params)  →  模板字符串替换                    │ │   │
│  │  │  has(key)           →  检查翻译是否存在                  │ │   │
│  │  │  locale()           →  当前区域                          │ │   │
│  │  └─────────────────────────────────────────────────────────┘ │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │  翻译存储格式: JSON 平面键值对                                │   │
│  │                                                               │   │
│  │  locales/                                                     │   │
│  │  ├── zh-CN.json    # 源语言（权威源）                         │   │
│  │  ├── en.json       # 英文                                     │   │
│  │  ├── ja.json       # 日文                                     │   │
│  │  ├── ko.json       # 韩文                                     │   │
│  │  ├── fr.json       # 法文                                     │   │
│  │  ├── de.json       # 德文                                     │   │
│  │  ├── es.json       # 西班牙文                                 │   │
│  │  ├── ru.json       # 俄文                                     │   │
│  │  ├── ar.json       # 阿拉伯文                                 │   │
│  │  └── pt.json       # 葡萄牙文                                 │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │  翻译键命名规范                                                │   │
│  │                                                               │   │
│  │  agent.tianshu.name           = "元启·天枢"                   │   │
│  │  agent.tianshu.role           = "总指挥 · 决策中枢"           │   │
│  │  agent.tianshu.desc           = "全局任务编排、资源调度..."    │   │
│  │  skill.rag.blueprint.name     = "RAG Blueprint"               │   │
│  │  skill.rag.blueprint.desc     = "NVIDIA RAG 蓝图..."          │   │
│  │  common.yes                   = "是"                          │   │
│  │  common.no                    = "否"                          │   │
│  │  error.file_not_found         = "文件 {path} 未找到"          │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

## 三、i18n Engine 核心实现（~120 行）

```javascript
// packages/yyci/src/engine/i18n-engine.js
// 零外部依赖 — 仅使用 Node.js 内置模块

import { readFileSync, existsSync } from 'fs'
import { join, dirname } from 'path'
import { fileURLToPath } from 'url'

const __dirname = dirname(fileURLToPath(import.meta.url))
const LOCALES_DIR = join(__dirname, '../../locales')

export class I18nEngine {
  #cache = new Map()
  #fallback = 'zh-CN'
  #current = 'zh-CN'

  constructor(options = {}) {
    this.#current = options.locale || 'zh-CN'
    this.#fallback = options.fallback || 'zh-CN'
  }

  /** 加载语言文件 */
  loadLocale(lang) {
    if (this.#cache.has(lang)) return this.#cache.get(lang)
    const path = join(LOCALES_DIR, `${lang}.json`)
    if (!existsSync(path)) {
      if (lang !== this.#fallback) return this.loadLocale(this.#fallback)
      return {}
    }
    const data = JSON.parse(readFileSync(path, 'utf-8'))
    this.#cache.set(lang, data)
    return data
  }

  /** 获取翻译 */
  t(key, params = {}) {
    const locale = this.loadLocale(this.#current)
    const fallback = this.loadLocale(this.#fallback)
    let value = this.#resolve(locale, key)
    if (value === undefined) value = this.#resolve(fallback, key)
    if (value === undefined) return key
    return this.#interpolate(value, params)
  }

  /** 模板插值 */
  #interpolate(text, params) {
    return text.replace(/\{(\w+)\}/g, (_, k) => params[k] ?? `{${k}}`)
  }

  /** 深度解析键路径 */
  #resolve(obj, key) {
    return key.split('.').reduce((o, k) => o?.[k], obj)
  }

  /** 检查键是否存在 */
  has(key) {
    const locale = this.loadLocale(this.#current)
    return this.#resolve(locale, key) !== undefined
  }

  /** 当前区域 */
  get locale() { return this.#current }
  set locale(lang) { this.#current = lang }
}
```

## 四、翻译覆盖范围（4 级）

### 4.1 第 1 级：Agent 系统提示词（~200 键）

```
agent.tianshu.name
agent.tianshu.role
agent.tianshu.phone
agent.qianhang.name
agent.qianhang.role
... (8 agents × ~25 键)
```

### 4.2 第 2 级：Skills 标准化（~300 键）

```
skill_category.data_analysis
skill_category.development
skill_category.content_creation
skill_category.cloud_service
skill_category.communication
skill_category.productivity
skill_category.design
skill_category.ecommerce
skill_category.education
skill_category.ai_ml
```

### 4.3 第 3 级：CLI 工具链（~150 键）

```
cli.build.progress     = "正在构建 {type} 索引..."
cli.validate.passing   = "通过: {count}"
cli.validate.failing   = "失败: {count}"
cli.doctor.status      = "健康状态: {status}"
cli.error.not_found    = "文件 {path} 未找到"
```

### 4.4 第 4 级：文档与品牌（~100 键）

```
brand.slogan.primary   = "万象归元于云枢"
brand.slogan.secondary = "深栈智启新纪元"
brand.name.full        = "YYC³ 言语云立方"
brand.name.short       = "YYC³"
```

## 五、同步工作流

```
┌──────────┐    ┌──────────┐    ┌──────────┐    ┌──────────┐
│ 源语言    │───▶│ AI 翻译  │───▶│ 人工审核  │───▶│ 发布     │
│ zh-CN    │    │ 生成 9   │    │ Gate 检查 │    │ locales/ │
│ 权威文件  │    │ 语言文件  │    │ 完整性    │    │          │
└──────────┘    └──────────┘    └──────────┘    └──────────┘
      │                                              │
      └─────────────── CLI 命令 ──────────────────────┘
                      yyci i18n sync
                      yyci i18n lint
```

## 六、完整性检查

```bash
# 检查所有语言文件是否完整覆盖 zh-CN 的所有键
yyci i18n lint

# 输出示例:
# ✓ zh-CN: 750 键 (权威源)
# ✓ en:    748 键 (缺失 2 键: agent.x.desc, error.permission)
# ⚠ ja:   680 键 (缺失 70 键)
# ⚠ ar:   450 键 (缺失 300 键, 需优先补充)
# ✗ es:    (文件不存在)
```

## 七、RTL 支持（阿拉伯语）

阿拉伯语需要额外处理：

```
┌─────────────────────────────────────────────────────────────┐
│  RTL 特殊处理                                                 │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  文字方向: dir="rtl" 属性                                    │
│  数字处理: 使用阿拉伯数字 (123) 而非印地语数字 (١٢٣)      │
│  标点符号: 保持英文标点在数字和代码中不变                    │
│  对齐: CLI 输出左对齐 (terminal 原生)                        │
│  图标: 镜像对称图标 (如箭头, 通过 CSS transform: scaleX(-1))│
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

## 八、集成至 CLI

```javascript
// 在 yyci CLI 中调用 i18n 引擎
import { I18nEngine } from './engine/i18n-engine.js'

const i18n = new I18nEngine({ locale: process.env.LANG?.startsWith('zh') ? 'zh-CN' : 'en' })

// 使用
console.log(i18n.t('cli.build.progress', { type: 'skills' }))
// → "正在构建 skills 索引..." (zh-CN)
// → "Building skills index..." (en)
```

## 九、Roadmap

| 阶段 | 内容 | 时间 |
|------|------|------|
| Phase 1 | 确定键命名规范 + 生成 zh-CN 权威源 | 第 1 周 |
| Phase 2 | AI 翻译 en/ja/ko + 人工审核 | 第 2 周 |
| Phase 3 | AI 翻译 fr/de/es/ru + 人工审核 | 第 3 周 |
| Phase 4 | AI 翻译 ar/pt + 人工审核 + RTL 适配 | 第 4 周 |
| Phase 5 | CLI i18n 子命令集成 + CI 自动检查 | 第 5 周 |
| Phase 6 | Skill frontmatter 多语言字段扩展 | 第 6 周 |
