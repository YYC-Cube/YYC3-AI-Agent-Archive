# YYC³ 部署文档

> 核心平台部署与运维指南。

## 一、部署方式

| 方式 | 场景 | 复杂度 |
| ---- | ---- | ------ |
| Docker Compose | 单机生产/开发 | 低 |
| 原生 Node | 开发调试 | 低 |
| Kubernetes | 分布式生产 | 高 |

## 二、Docker Compose 部署（推荐）

### 2.1 前置要求

- Docker ≥ 24
- Docker Compose ≥ 2.20
- 至少 2 CPU / 4GB 内存

### 2.2 快速启动

```bash
# 1. 配置环境变量
cp .env.example .env
# 编辑 .env，设置 YYC3_API_KEYS 等

# 2. 构建并启动
docker-compose up -d --build

# 3. 验证健康
curl http://127.0.0.1:3030/health
curl http://127.0.0.1:3031/health
curl http://127.0.0.1:3032/health
```

### 2.3 服务拓扑

```
docker-compose.yml
├── skill-gateway   → 3030
├── mcp-runtime     → 3031
└── agent-runtime   → 3032
```

### 2.4 安全配置

Docker Compose 已内置以下安全加固：

| 项 | 值 | 说明 |
| -- | -- | ---- |
| `no-new-privileges` | true | 禁止提权 |
| `cap_drop` | ALL | 丢弃所有 Linux capabilities |
| `read_only` | true | 根文件系统只读 |
| tmpfs `/tmp` | noexec | /tmp 不可执行 |
| 内存限制 | 512MB | 单服务内存上限 |
| pids_limit | 256 | 进程数上限 |

### 2.5 环境变量

```bash
# 认证（必填，逗号分隔多密钥）
YYC3_API_KEYS=sk-your-key-1,sk-your-key-2

# 网络
YYC3_TRUSTED_PROXY_HOPS=1        # 反向代理跳数
YYC3_CORS_ORIGINS=https://your-domain.com

# 持久化
YYC3_STORE_TYPE=file              # memory | file | redis
YYC3_STORE_FILE_PATH=/data/store  # FileStore 路径

# Redis（仅 store_type=redis）
REDIS_URL=redis://redis:6379

# 可观测性
OTEL_EXPORTER_OTLP_ENDPOINT=http://otel-collector:4318
```

### 2.6 持久化卷

```yaml
volumes:
  - store-data:/data/store        # FileStore 数据
  - skills-hub:/app/skills-hub    # Skill 资产（只读挂载）
```

## 三、原生 Node 部署

### 3.1 构建

```bash
pnpm install
pnpm run build
```

### 3.2 启动各服务

```bash
# Skill Gateway
YYC3_API_KEYS=sk-xxx node packages/skill-gateway/dist/server.js

# MCP Runtime
YYC3_API_KEYS=sk-xxx node packages/mcp-runtime/dist/server.js

# Agent Runtime
YYC3_API_KEYS=sk-xxx node packages/agent-runtime/dist/server.js
```

### 3.3 进程管理

推荐使用 `pm2` 或 systemd：

```bash
npm i -g pm2
pm2 start packages/skill-gateway/dist/server.js --name skill-gateway
pm2 startup
pm2 save
```

## 四、Kubernetes 部署

### 4.1 资源清单

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: skill-gateway
spec:
  replicas: 2
  template:
    spec:
      containers:
      - name: skill-gateway
        image: yyc3/skill-gateway:latest
        ports: [{ containerPort: 3030 }]
        env:
        - name: YYC3_API_KEYS
          valueFrom: { secretKeyRef: { name: yyc3-secrets, key: api-keys } }
        resources:
          limits: { memory: "512Mi", cpu: "500m" }
        securityContext:
          readOnlyRootFilesystem: true
          runAsNonRoot: true
          allowPrivilegeEscalation: false
```

### 4.2 Ingress

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  annotations:
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
spec:
  rules:
  - host: api.yyc3.example.com
    http:
      paths:
      - path: /skills
        backend: { service: { name: skill-gateway, port: 3030 } }
      - path: /mcp
        backend: { service: { name: mcp-runtime, port: 3031 } }
      - path: /agents
        backend: { service: { name: agent-runtime, port: 3032 } }
```

## 五、健康检查

| 端点 | 服务 | 成功响应 |
| ---- | ---- | -------- |
| `GET /health` | 3030/3031/3032 | `200 {"status":"ok"}` |

Docker/K8s 探针配置：

```yaml
livenessProbe:
  httpGet: { path: /health, port: 3030 }
  initialDelaySeconds: 5
  periodSeconds: 10
readinessProbe:
  httpGet: { path: /health, port: 3030 }
  periodSeconds: 5
```

## 六、监控与日志

### 6.1 指标

Prometheus 格式暴露（可配置）：

```
/metrics
```

关键指标：
- `http_requests_total{service,method,path,status}`
- `skill_execution_duration_seconds{skill}`
- `skill_execution_errors_total{skill,error_type}`

### 6.2 日志

结构化 JSON 日志输出到 stdout，集中采集（ELK/Loki）：

```json
{ "timestamp": "...", "level": "info", "message": "...", "service": "skill-gateway" }
```

### 6.3 链路追踪

配置 `OTEL_EXPORTER_OTLP_ENDPOINT` 后自动上报 W3C Trace Context。

## 七、备份与恢复

### 7.1 FileStore 备份

```bash
tar czf store-backup-$(date +%Y%m%d).tar.gz /data/store
```

### 7.2 恢复

```bash
tar xzf store-backup-YYYYMMDD.tar.gz -C /data/store
docker-compose restart
```

## 八、升级流程

1. **预发布**：在 staging 环境部署新版本
2. **门禁**：CI 全绿 + doctor 六检通过
3. **灰度**：逐步替换实例，观察健康检查
4. **回滚**：异常时 `docker-compose down && docker-compose up -d <旧镜像>`

---

**YanYuCloudCube** · 言启千行代码，语枢万物智能
