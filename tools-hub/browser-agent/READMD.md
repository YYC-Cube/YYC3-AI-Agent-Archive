---
file: README.md
description: agent-browser Rust CLI 源码 — 从 agent-browser 项目集成
version: v0.21.4
created: 2026-07-24
status: integrated
source: agent-browser/
---

# Browser Agent — Rust CLI 源码

> 无头浏览器自动化 CLI，供 AI Agent 调用

从 `agent-browser` 项目集成 Rust CLI 源码。Skills 层已位于 `skills/agent-browser/`。

## 目录结构

```
tools-hub/browser-agent/
├── Cargo.toml        # Rust 项目配置
├── Cargo.lock
├── src/              # Rust 源码
│   ├── main.rs       # 入口
│   ├── native/       # CDP + WebDriver 协议实现
│   │   ├── cdp/      # Chrome DevTools Protocol
│   │   └── webdriver/ # Safari/iOS WebDriver
│   ├── browser.rs    # 浏览器核心
│   └── ...
├── bin/              # 编译后二进制入口
├── scripts/          # 构建/版本脚本
└── package.json      # npm 包配置
```

## 构建

```bash
cd tools-hub/browser-agent
cargo build --release
```
