# 支持支持指南（Support）

> 谢谢使用 YYC³ AI Agent Archive！以下是获取帮助的渠道。

## 快速排查

1. **构建/测试失败**：先跑完整门禁定位环节
   ```bash
   pnpm install && pnpm run typecheck && pnpm run test && pnpm run build
   ```
2. **服务启动异常**：检查 `.env`（参考 [.env.example](.env.example)），认证未配置时服务会 fail-closed 返回 503 —— 这是预期安全行为
3. **技能资产校验失败**：`pnpm run skills:validate` 查看具体 frontmatter 错误

## 获取帮助的渠道

| 类型 | 渠道 | 响应说明 |
| ---- | ---- | -------- |
| 🐛 Bug 报告 | [GitHub Issues](../../issues)（使用 bug 模板） | maintainer 轮值处理 |
| 💡 功能建议 | [GitHub Issues](../../issues)（使用 feature 模板） | 讨论后立项 |
| 💬 使用讨论 | [GitHub Discussions](../../discussions) | 社区互助 |
| 🔒 安全漏洞 | 邮件 [admin@0379.email](mailto:admin@0379.email)（**不要公开 Issue**） | 见 [SECURITY.md](SECURITY.md) SLA |
| 🤝 贡献 | [CONTRIBUTING.md](CONTRIBUTING.md) | PR 全年欢迎 |

## 文档入口

- 快速开始：[README](README.md#-快速开始)
- 开发者五件套：[docs/developers/](docs/developers/)（API / 架构 / 贡献 / 部署 / 测试）
- 三服务端口：Skill Gateway `3030` · MCP Runtime `3031` · Agent Runtime `3032`
