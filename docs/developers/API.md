# YYC³ API 文档

> 核心平台对外 HTTP API 参考。所有端点除 `/health` 和 `/` 外均需认证。

## 一、认证

### 1.1 方式

| 方式 | Header | 示例 |
| ---- | ------ | ---- |
| Bearer Token | `Authorization: Bearer <key>` | `Authorization: Bearer sk-xxx` |
| API Key | `X-API-Key: <key>` | `X-API-Key: sk-xxx` |

密钥通过环境变量 `YYC3_API_KEYS` 配置（逗号分隔）。使用 `timingSafeEqual` 常量时间比较。

### 1.2 未认证响应

```json
{ "error": { "code": "UNAUTHORIZED", "message": "..." } }
```

| 场景 | HTTP 状态 |
| ---- | --------- |
| 未配置密钥 | 503 SERVICE_UNAVAILABLE |
| 缺失凭证 | 401 UNAUTHORIZED |
| 无效凭证 | 403 FORBIDDEN |

## 二、通用约定

- **Base URL**：`http://<host>:<port>`
- **请求体上限**：1MB（超限返回 413）
- **限流**：100 req/min（token bucket，超限返回 429）
- **安全头**：CSP `default-src 'none'`、HSTS `max-age=31536000; includeSubDomains`
- **错误格式**：

```json
{
  "error": {
    "code": "ERROR_CODE",
    "message": "人类可读描述",
    "details": {}
  }
}
```

## 三、Skill Gateway（3030）

### 3.1 健康检查

```
GET /health
```

响应 `200 OK`：
```json
{ "status": "ok", "service": "skill-gateway", "version": "1.4.0" }
```

### 3.2 列出 Skills

```
GET /skills
```

**Query**：
| 参数 | 类型 | 说明 |
| ---- | ---- | ---- |
| `category` | string | 按类别过滤 |
| `limit` | number | 分页大小，默认 50 |
| `offset` | number | 偏移量 |

响应 `200 OK`：
```json
{
  "items": [{ "name": "...", "category": "...", "version": "..." }],
  "total": 831,
  "limit": 50,
  "offset": 0
}
```

### 3.3 获取 Skill 详情

```
GET /skills/:name
```

### 3.4 执行 Skill

```
POST /skills/:name/execute
Content-Type: application/json

{ "input": { ... }, "timeout": 60 }
```

响应 `200 OK`：
```json
{ "stdout": "...", "stderr": "...", "exitCode": 0, "durationMs": 1234 }
```

### 3.5 重新加载 Skills

```
POST /skills/reload
```

同步语义：先 `registry.clear()`（逐个发 `skill:unregistered`），再按磁盘重建。

## 四、MCP Runtime（3031）

### 4.1 健康检查

```
GET /health
```

### 4.2 MCP 端点

```
POST /mcp
```

遵循 [MCP 协议](https://spec.modelcontextprotocol.io/)，支持 tools/list、tools/call、resources/list 等方法。

### 4.3 Skill 桥接

MCP runtime 将注册的 Skill 暴露为 MCP Tool，命名规则：`skill.<name>`。

## 五、Agent Runtime（3032）

### 5.1 健康检查

```
GET /health
```

### 5.2 Agent 对话

```
POST /agents/:id/chat
Content-Type: application/json

{ "message": "...", "sessionId": "..." }
```

### 5.3 Agent 列表

```
GET /agents
```

## 六、限流与错误码

| HTTP | code | 说明 |
| ---- | ---- | ---- |
| 400 | BAD_REQUEST | 请求体无效（JSON 解析失败/Zod 校验失败） |
| 401 | UNAUTHORIZED | 缺失认证凭证 |
| 403 | FORBIDDEN | 认证失败 |
| 404 | NOT_FOUND | 资源不存在 |
| 413 | PAYLOAD_TOO_LARGE | 请求体超 1MB |
| 429 | RATE_LIMITED | 触发限流 |
| 503 | SERVICE_UNAVAILABLE | 服务不可用（如未配置密钥） |

## 七、环境变量

| 变量 | 服务 | 默认 | 说明 |
| ---- | ---- | ---- | ---- |
| `YYC3_API_KEYS` | 全部 | — | API 密钥（逗号分隔） |
| `YYC3_TRUSTED_PROXY_HOPS` | 全部 | 0 | XFF 可信跳数 |
| `YYC3_CORS_ORIGINS` | 全部 | `*` | CORS 源 |
| `PORT` / `MCP_HOST` | 各服务 | 3030/3031/3032 | 端口/绑定地址 |
| `YYC3_STORE_TYPE` | agent/plugin | `memory` | store 类型：memory/file/redis |

---

**YanYuCloudCube** · 言启千行代码，语枢万物智能
