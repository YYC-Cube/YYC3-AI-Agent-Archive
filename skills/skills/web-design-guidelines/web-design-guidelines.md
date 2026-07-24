# web-design-guidelines

npx skills add <https://github.com/vercel-labs/agent-skills> --skill web-design-guidelines

## Summary

Audit UI code against Vercel's Web Interface Guidelines for design and accessibility compliance.
对照 Vercel 网页界面指南审核 UI 代码，确保其设计与可访问性符合规范。

Fetches the latest guidelines from a remote source before each review, ensuring rules stay current
每次审核前从远程来源获取最新指南，确保规则保持最新
Accepts file paths or patterns as arguments; prompts for files if none provided
接受文件路径或模式作为参数；若未提供则提示输入文件
Outputs findings in a terse file:line format for quick scanning and remediation
以简洁的file:line格式输出检测结果，便于快速扫描和修复
Covers design, accessibility, and UX best practices as defined in the guidelines repository
涵盖指南库中定义的设计、可访问性和用户体验最佳实践
