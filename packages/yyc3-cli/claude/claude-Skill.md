---
@file: claude-Skill.md
@description: YYC³-CLI claude-Skill.md
@author: YanYuCloudCube Team
@version: v1.0.0
@created: 2026-02-17
@updated: 2026-02-17
@status: published
@tags: [文档],[YYC³-CLI]
---

> ***YanYuCloudCube***
> 言启象限 | 语枢未来
> ***Words Initiate Quadrants, Language Serves as Core for the Future***
> 万象归元于云枢 | 深栈智启新纪元
> ***All things converge in the cloud pivot; Deep stacks ignite a new era of intelligence***

---

# Claude Code Skills

如何使用呢？
以youtube-transcript为例子
https://ss.bytenote.net/skill/youtube-transcript
直接点击复制skill文本就可以，如果有脚本的可以在相关链接里面查找到Files文件下载。
可以直接通过skills来过程下载youtube视频并翻译
不用之前请保证Claude Code 1.0 或更高版本以及对 Claude Code 的基本了解。
Skill 有三种存储位置:
1. 个人 Skills
存储在 ~/.claude/skills/ 目录,适用于个人工作流程、实验性 Skills 和个人生产力工具
2. 项目 Skills
存储在项目内的 .claude/skills/ 目录,与团队共享,适用于团队工作流程、项目特定专业知识和共享工具
3. 插件 Skills
来自 Claude Code 插件,插件安装时自动可用
一、编写 SKILL.md 文件
基本结构:
---
name: your-skill-name
description: 简要描述该 Skill 的功能以及何时使用
---# Skill 名称## 说明
为 Claude 提供清晰的分步指导

## 示例
展示使用该 Skill 的具体示例
name 字段必须仅使用小写字母、数字和连字符,最多 64 个字符;description 字段是关键,最多 1024 个字符,需要包含 Skill 的功能和使用时机

---
二、添加辅助文件
可以添加以下内容:
- 脚本文件(Python、JavaScript 等)
- 模板文件
- 参考文档
- 示例数据

---
三、测试 Skill
创建 Skill 后,通过提出与描述相匹配的问题来测试它
检查文件路径:
# 个人 Skillsls ~/.claude/skills/skill-name/SKILL.md

# 项目 Skills  ls .claude/skills/skill-name/SKILL.md
启用调试模式查看错误:
DEBUG=claude:skills claude code

---
四、安装和使用 Skills
通过插件安装:
# 从市场安装
/plugin marketplace add anthropics/skills

# 从本地目录安装
/plugin add /path/to/skill-directory
启用代码执行和文件创建功能后,Claude 会在相关时自动使用这些工具,无需显式调用

---
五、与团队共享
推荐方式:
- 将 Skills 添加到插件的 skills/ 目录
- 将插件添加到市场
- 团队成员安装插件
或通过 Git 直接共享:
# 添加到项目mkdir -p .claude/skills/my-skill
# 创建 SKILL.md 文件# 提交到 Git
git add .claude/skills/my-skill
git commit -m "Add team skill"

---
Claude Code Skills 是一种模块化功能,通过包含指令、脚本和资源的组织化文件夹来扩展 Claude 的能力。每个 Skill 由一个 SKILL.md 文件和可选的辅助文件组成。
核心特点:
- Skills 是模型自动调用的,Claude 会根据你的请求和 Skill 的描述自主决定何时使用它们
- 采用渐进式披露原则,Claude 在启动时只预加载每个已安装 Skill 的名称和描述,仅在需要时才加载完整内容
- 支持跨平台使用,可在 Claude.ai、API 和 Claude Code 中使用
- 可以包含可执行代码,适用于传统编程比生成 token 更可靠的任务
Anthropic 提供了多个预构建的文档处理 Skills,包括 docx(Word 文档)、pdf(PDF 处理)、pptx(PowerPoint 演示文稿)和 xlsx(Excel 电子表格)
更多详细信息和示例可以访问：https://ss.bytenote.net/

如何使用呢？

以youtube-transcript为例子

https://ss.bytenote.net/skill/youtube-transcript

直接点击复制skill文本就可以，如果有脚本的可以在相关链接里面查找到Files文件下载。

可以直接通过skills来过程下载youtube视频并翻译

不用之前请保证Claude Code 1.0 或更高版本以及对 Claude Code 的基本了解。

Skill 有三种存储位置:

个人 Skills

存储在 ~/.claude/skills/ 目录,适用于个人工作流程、实验性 Skills 和个人生产力工具

项目 Skills

存储在项目内的 .claude/skills/ 目录,与团队共享,适用于团队工作流程、项目特定专业知识和共享工具

插件 Skills

来自 Claude Code 插件,插件安装时自动可用

编写 SKILL.md 文件
基本结构:

---
name: your-skill-name
description: 简要描述该 Skill 的功能以及何时使用
---

# Skill 名称

## 说明
为 Claude 提供清晰的分步指导

## 示例
展示使用该 Skill 的具体示例
name 字段必须仅使用小写字母、数字和连字符,最多 64 个字符;description 字段是关键,最多 1024 个字符,需要包含 Skill 的功能和使用时机

添加辅助文件
可以添加以下内容:

脚本文件(Python、JavaScript 等)
模板文件
参考文档
示例数据

测试 Skill
创建 Skill 后,通过提出与描述相匹配的问题来测试它

检查文件路径:

# 个人 Skills
ls ~/.claude/skills/skill-name/SKILL.md

# 项目 Skills  
ls .claude/skills/skill-name/SKILL.md
启用调试模式查看错误:

DEBUG=claude:skills claude code
6. 安装和使用 Skills
通过插件安装:

# 从市场安装
/plugin marketplace add anthropics/skills

# 从本地目录安装
/plugin add /path/to/skill-directory
启用代码执行和文件创建功能后,Claude 会在相关时自动使用这些工具,无需显式调用

与团队共享
推荐方式:

将 Skills 添加到插件的 skills/ 目录
将插件添加到市场
团队成员安装插件
或通过 Git 直接共享:

# 添加到项目
mkdir -p .claude/skills/my-skill
# 创建 SKILL.md 文件

# 提交到 Git
git add .claude/skills/my-skill
git commit -m "Add team skill"
Claude Code Skills 是一种模块化功能,通过包含指令、脚本和资源的组织化文件夹来扩展 Claude 的能力。每个 Skill 由一个 SKILL.md 文件和可选的辅助文件组成。

核心特点:

Skills 是模型自动调用的,Claude 会根据你的请求和 Skill 的描述自主决定何时使用它们
采用渐进式披露原则,Claude 在启动时只预加载每个已安装 Skill 的名称和描述,仅在需要时才加载完整内容
支持跨平台使用,可在 Claude.ai、API 和 Claude Code 中使用
可以包含可执行代码,适用于传统编程比生成 token 更可靠的任务

Anthropic 提供了多个预构建的文档处理 Skills,包括 docx(Word 文档)、pdf(PDF 处理)、pptx(PowerPoint 演示文稿)和 xlsx(Excel 电子表格)

更多详细信息和示例可以访问：

https://ss.bytenote.net/

使用Claude Code Skills实现小红书全自动图文视频发布Agent

Claude Skills 可能比 MCP更重要！
