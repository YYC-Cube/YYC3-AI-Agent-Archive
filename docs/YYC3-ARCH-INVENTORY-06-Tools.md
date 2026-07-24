---
file: YYC3-ARCH-INVENTORY-06-Tools.md
description: YYC³ Tools 架构可视化清单 — Rust 内置 / 工具 Hub / Agent 引用
author: YYC³ 智能架构顾问
version: v1.0.0
created: 2026-07-24
status: stable
tags: [架构清单, Tools, 工具链]
---

# YYC³ Tools 架构可视化清单

> **工具即能力 · Rust 原生 · 生态扩展**

---

## 一、Tools 总体架构

```
┌─────────────────────────────────────────────────────────────────────┐
│                    YYC³ Tools 四层能力                              │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │              ⚙️ Rust 内置工具（12 个原生）                   │   │
│  │              语言原生支持 · 零依赖执行                       │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │              🛠️ 工具 Hub tools-hub/                        │   │
│  │              IDE / 自动补全 / 浏览器 / Go / Conductor       │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │              📋 Agent 引用工具（223 个引用）                 │   │
│  │              各 Agent 定义中声明的工具依赖                   │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │              🔧 工具实现（38 个有具体实现）                  │   │
│  │              Rust 内置 12 + 其他实现 26                     │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

---

## 二、Rust 内置工具（12 个原生）

据 `_tools_index.json`，以下 12 个工具为 Rust 语言内置实现：

```
┌─────────────────────────────────────────────────────────────────────┐
│  Rust 内置工具清单                                                  │
├──────┬──────────────────────────────────────┬───────────────────────┤
│  #   │ 工具名                               │ 文件                  │
├──────┼──────────────────────────────────────┼───────────────────────┤
│  1   │ execute_cmd                          │ execute_cmd.rs        │
│  2   │ fs_read                              │ fs_read.rs            │
│  3   │ fs_write                             │ fs_write.rs           │
│  4   │ glob                                 │ glob.rs               │
│  5   │ grep                                 │ grep.rs               │
│  6   │ image_read                           │ image_read.rs         │
│  7   │ introspect                           │ introspect.rs         │
│  8   │ ls                                   │ ls.rs                 │
│  9   │ mcp                                  │ mcp.rs                │
│  10  │ mkdir                                │ mkdir.rs              │
│  11  │ parse                                │ parse.rs              │
│  12  │ rm                                   │ rm.rs                 │
└──────┴──────────────────────────────────────┴───────────────────────┘
```

**工具能力说明**：

| 工具 | 功能 | 实现大小 |
|------|------|----------|
| `execute_cmd` | 执行 shell 命令 | 7.1KB |
| `fs_read` | 文件读取 | 9.1KB |
| `fs_write` | 文件写入 | 15.8KB |
| `glob` | 文件模式匹配 | 内核级 |
| `grep` | 文本搜索 | 1.2KB |
| `image_read` | 图片读取 | 11.2KB |
| `introspect` | 自省查询 | 0.1KB |
| `ls` | 目录列表 | 13.5KB |
| `mcp` | MCP 协议通信 | 0.6KB |
| `mkdir` | 目录创建 | 2.0KB |
| `parse` | 解析引擎 | 内核级 |
| `rm` | 文件删除 | 2.0KB |

---

## 三、工具 Hub 分类（`tools-hub/`）

```
tools-hub/
│
├── autocomplete/              终端自动补全（fig/withfig 生态）
│   ├── cli/                   发布工具 CLI
│   ├── generators/            补全生成器
│   ├── helpers/               辅助函数
│   ├── hooks/                 IDE Hooks
│   ├── integrations/          框架集成（argparse/click/cobra/oclif）
│   ├── merge/                 补全合并工具
│   ├── shared/                共享库
│   └── types/                 类型定义
│
├── chat-agent/                聊天 Agent 工具
│   ├── browser/               浏览器工具
│   │   ├── tools/toolIds.ts   工具 ID 注册
│   │   ├── outputHelpers.ts   输出辅助
│   │   ├── taskHelpers.ts     任务辅助
│   │   └── toolTerminalCreator.ts 终端创建
│   └── common/
│       └── terminalSandbox.ts 终端沙箱
│
├── code-ide/                  IDE 集成工具
│   ├── memery/                用户记忆
│   ├── plugins/               插件市场
│   │   └── marketplaces/      多个市场目录
│   ├── skills/                技能共享
│   │   └── skill-share/       SKILL.md
│   ├── skills-marketplace/    技能市场
│   ├── mcp.json               MCP 配置
│   ├── models.json            模型配置
│   └── settings.json          设置
│
├── conductor/                 编排引擎（外部项目）
│   ├── rules/                 编排规则
│   ├── skills/                编排技能
│   ├── VERSION                版本号
│   └── plugin.json            插件配置
│
├── golang-tools/              Go 工具集（外部项目）
│   ├── benchmark/             基准测试
│   ├── blog/                  Atom feed
│   └── cmd/                   CLI 命令集合
│       ├── benchcmp/          性能比较
│       ├── bisect/            二分查找
│       ├── bundle/            打包
│       ├── callgraph/         调用图
│       ├── compilebench/      编译基准
│       ├── deadcode/          死代码检测
│       ├── digraph/           有向图
│       ├── eg/                示例生成
│       ├── file2fuzz/         Fuzz 生成
│       ├── fiximports/        导入修复
│       ├── godex/             依赖导出
│       ├── goimports/         导入管理
│       ├── gomvpkg/           包迁移
│       ├── gonew/             项目模板
│       └── gotype/            类型检查
│
└── (工具 Hub 总计：6 个子目录)
```

---

## 四、Agent 工具引用分析

据 `_tools_index.json`，工具引用情况如下：

| 工具 | Agent 引用数 | 实现数 |
|------|-------------|--------|
| Read | 大量 | Rust 内置 |
| Write | 大量 | Rust 内置 |
| Edit | 大量 | Rust 内置 |
| Bash/execute_cmd | 大量 | Rust 内置 |
| Grep | 大量 | Rust 内置 |
| Glob | 大量 | Rust 内置 |
| LS | 中量 | Rust 内置 |
| WebSearch | 中量 | Web |
| WebFetch | 中量 | Web |
| mcp__magic-codex__* | 少量 | MCP 桥接 |

### 常用工具组合模式

```
Agent 类型               常用工具组合
─────────────────────────────────────────────────
代码开发 Agent       Read + Write + Edit + Bash + Grep
研究型 Agent         Read + WebSearch + WebFetch + Write
设计类 Agent         Read + Write + Edit + Glob
安全审计 Agent       Read + Grep + Glob + Bash
```

---

## 五、工具与 Skill 的关系

```
┌─────────────────────────────────────────────────────────────────────┐
│                    Tool ↔ Skill ↔ Agent 关系                        │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  Tools（原子操作）              Skills（能力封装）                   │
│  ┌────────────┐                ┌────────────┐                      │
│  │ execute_cmd│                │ 图表解读    │                      │
│  │ fs_read    │  ──── 组合 ──▶ │ 文档摘要    │  ──── 调用 ──▶    │
│  │ fs_write   │                │ 代码审核    │                      │
│  │ grep       │                │ 趋势预测    │                      │
│  │ glob       │                │ 内容创意    │                      │
│  │ ...        │                │ ...        │                      │
│  └────────────┘                └────────────┘                      │
│       ▲                              ▲                              │
│       │                              │                              │
│       │      ┌──────────────┐        │                              │
│       └──────│ Agent 编排层  │────────┘                              │
│              │ (意图匹配)    │                                       │
│              └──────────────┘                                       │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

---

## 六、所属文件清单

| 路径 | 类型 | 状态 |
|------|------|------|
| `_tools_index.json` | 全局工具索引（261 工具） | ✅ 索引文件 |
| — | Rust 内置 12 工具 | ✅ 核心资产 |
| `tools-hub/autocomplete/` | 自动补全生态 | 📦 外部来源（withfig） |
| `tools-hub/chat-agent/` | 聊天 Agent 工具 | ✅ 核心资产 |
| `tools-hub/code-ide/` | IDE 集成工具 | ✅ 核心资产 |
| `tools-hub/conductor/` | 编排引擎 | 📦 外部项目 |
| `tools-hub/golang-tools/` | Go 工具集 | 📦 外部项目（golang.org/x） |
