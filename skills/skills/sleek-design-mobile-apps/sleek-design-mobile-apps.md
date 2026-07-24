# sleek-design-mobile-apps

npx skills add <https://github.com/sleekdotdesign/agent-skills> --skill sleek-design-mobile-apps

## Summary

AI-powered mobile app design tool with REST API for creating projects, describing designs in plain language, and rendering screens.
一款由人工智能驱动的移动应用设计工具，配备REST API，可用于创建项目、用通俗语言描述设计以及渲染界面。

Supports high-level requests ("design a fitness app") and specific edits ("add a pricing section to this screen"); send natural language descriptions via chat messages and let the AI decide what to create or modify
支持高层次需求（“设计一款健身应用”）和具体修改（“为该界面添加定价板块”）；通过聊天消息发送自然语言描述，由人工智能决定创建或修改的内容
Requires Pro+ plan and API key with scoped permissions (projects:read/write, chats:read/write, screenshots, components:read)
需要 Pro+ 计划以及具有特定范围权限的 API 密钥（projects:read/write、chats:read/write、screenshots、components:read）
Async and sync modes available; async returns immediately with a run ID for polling, sync blocks up to 300 seconds
支持异步和同步模式；异步模式会立即返回一个用于轮询的运行 ID，同步模式会阻塞最长 300 秒
Always screenshot newly created or updated screens after each chat run and deliver them to the user; combine all project screens into one screenshot when screens are created for the first time
每次对话运行后，务必对新创建或更新的界面进行截图并交付给用户；首次创建界面时，需将所有项目界面合并为一张截图。
One active run per project at a time; retry failed requests safely using idempotency keys
每个项目一次只能有一个活跃运行；使用幂等键安全重试失败的请求
