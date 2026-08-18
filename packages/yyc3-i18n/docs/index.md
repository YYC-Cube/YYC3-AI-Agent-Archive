---
layout: home

hero:
  name: '@yyc3/i18n-core'
  text: AI-Native i18n Framework
  tagline: 零依赖 · AI翻译 · MCP协议 · ICU编译器 · 10语言 · OWASP L4安全
  image:
    src: /Family-001.png
    alt: YYC³ Family
  actions:
    - theme: brand
      text: 快速开始
      link: /guide/getting-started
    - theme: alt
      text: GitHub
      link: https://github.com/YYC-Cube/YYC3-i18n-Core

features:
  - icon: 🤖
    title: AI 翻译原生集成
    details: OpenAI + Ollama 双引擎，一键批量翻译，质量评分，上下文感知。73% 开发者已在用 LLM 翻译。
    link: /guide/ai-translation
  - icon: 🔌
    title: MCP 协议 Server
    details: 行业首个 i18n MCP Server，7 个工具让 Claude/Cursor 等 AI Agent 直接操作翻译资源。
    link: /guide/mcp-integration
  - icon: 📦
    title: 零运行时依赖
    details: 完全零依赖，包体积 20.5KB gzipped，无供应链风险。Tree-shaking 友好。
  - icon: 🌐
    title: ICU MessageFormat
    details: 完整 ICU 编译器，支持复数/选择/序数/偏移/数字/日期/时间格式，10 语言全覆盖。
  - icon: 🔒
    title: OWASP L4 安全矩阵
    details: ReDoS 防护、密钥等值比较、速率限制、指数退避。企业级安全合规。
  - icon: 🎨
    title: RTL 原生支持
    details: 阿拉伯语/希伯来语/波斯语 RTL 布局自动处理，CSS 属性翻转，方向检测。
  - icon: ⚡
    title: LRU 缓存系统
    details: O(1) 缓存命中 <0.1ms，可配置 TTL 过期，缓存统计与预热。
  - icon: 🧩
    title: 插件生命周期
    details: beforeTranslate / afterTranslate / onMissingKey / onLocaleChange / onError 完整钩子链。
---
