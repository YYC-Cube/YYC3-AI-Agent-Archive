# YYC³ 架构文档

> 企业级 AI Agent 资产归档平台架构总览。

## 一、系统定位

汇聚 **Skill / Agent / Plugin / MCP / Tool** 五类资产的企业级归档与运行平台，提供注册、发现、执行、编排、观测的全链路能力。

## 二、分层架构

```
┌─────────────────────────────────────────────────────────────┐
│                    接入层 (Gateway)                          │
│   skill-gateway:3030 │ mcp-runtime:3031 │ agent-runtime:3032 │
├─────────────────────────────────────────────────────────────┤
│                    编排层 (Orchestration)                    │
│   orchestrator（LLM 分解/多策略调度）                         │
│   conductor（多智能体协同/任务编排）                          │
├─────────────────────────────────────────────────────────────┤
│                    运行时层 (Runtime)                        │
│   agent-runtime │ agent-registry │ plugin-marketplace        │
├─────────────────────────────────────────────────────────────┤
│                    核心层 (Core)                             │
│   skill-registry │ skill-sandbox │ mcp-runtime              │
├─────────────────────────────────────────────────────────────┤
│                    基础设施层 (Infrastructure)               │
│   store │ observability │ yyc3-i18n │ yyc3-cli │ @yyc3/icons│
└─────────────────────────────────────────────────────────────┘
```

## 三、核心包职责

| 包 | 版本 | 职责 |
| --- | --- | --- |
| `@yyc3/skill-registry` | 1.3.0 | Skill 扫描/解析/校验/执行/熔断 |
| `@yyc3/skill-gateway` | 1.4.0 | Skill REST API（Hono + 安全中间件） |
| `@yyc3/skill-sandbox` | — | Skill 沙箱执行（Node/Python/Shell） |
| `@yyc3/mcp-runtime` | 1.5.0 | 统一 MCP 运行时（Skill/CowAgent 桥接 + 事件层） |
| `@yyc3/agent-runtime` | 1.2.0 | Agent 生命周期/对话/工具调用 |
| `@yyc3/agent-registry` | — | Agent 发现/能力匹配 |
| `@yyc3/orchestrator` | 1.0.1 | LLM 任务分解/多策略调度 |
| `@yyc3/conductor` | — | 多智能体协同编排 |
| `@yyc3/plugin-marketplace` | 1.1.0 | Plugin 注册/激活/依赖管理 |
| `@yyc3/observability` | 1.2.0 | 日志/指标/链路追踪/健康检查 |
| `@yyc3/store` | 1.0.0 | 持久化抽象（Memory/File/Redis） |
| `yyc3-cli` | 2.0.0 | CLI（skills build/validate/dedup/stats/naming） |
| `@yyc3/i18n-core` | 3.0.0 | i18n 框架 |
| `@yyc3/icons` | — | Lucide 图标子集（只读） |

## 四、依赖方向（硬约束）

```
skill-gateway ──▶ skill-registry ──▶ skill-sandbox
       │                │
       ▼                ▼
  (REST API)      (Skill 执行)
                        │
                        ▼
mcp-runtime ──▶ skill-registry
conductor ──▶ orchestrator ──▶ agent-runtime
```

**禁止反向依赖**。新增包需先在此图中标注位置。

## 五、关键技术模式

### 5.1 写穿持久化（agent-runtime / plugin-marketplace）

```typescript
pendingWrites: Set<Promise>      // 并发写追踪
flushPending(): Promise<void>    // 等待全部写入完成
// 失败仅告警，不阻塞主流程
```

### 5.2 FileStore 单例防并发乱序

```typescript
writePromise: Promise<void>      // 链式 await，保证写入顺序
// tmp + rename 原子写 + 防抖 + 损坏快照视为空库
```

### 5.3 Skill 执行安全链

```
命令黑名单(28条) → 路径隔离 → 环境变量白名单(9个) → 超时钳制(30-300s) → 输出截断(1MB)
```

### 5.4 限流 fail-open

```
storeFailures: number            // 连续失败计数
首次 + 每 5 次告警 → 恢复清零
```

### 5.5 观测封顶

```typescript
Logger.maxEntries = 1000         // 日志条目上限
MetricsRegistry({ maxSeries: 10_000 })  // 指标序列上限
```

## 六、服务端口

| 服务 | 端口 | 协议 | 认证 |
| ---- | ---- | ---- | ---- |
| skill-gateway | 3030 | HTTP/REST | Bearer / X-API-Key |
| mcp-runtime | 3031 | HTTP/MCP | Bearer / X-API-Key |
| agent-runtime | 3032 | HTTP | Bearer / X-API-Key |

**未认证端点仅 `/health` 和 `/`**。开发环境默认绑定 `127.0.0.1`。

## 七、数据持久化

| 适配器 | 用途 | 特点 |
| ------ | ---- | ---- |
| MemoryStore | 测试/临时 | 进程内，重启丢失 |
| FileStore | 单机生产 | 原子写+防抖+懒加载单例 |
| RedisStore | 分布式 | lazy ioredis + SCAN + 降级 |

通过 `createStoreFromEnv()` 按环境变量选择。

---

**YanYuCloudCube** · 言启千行代码，语枢万物智能
