---
@file: DEPLOYMENT-GUIDE.md
@description: YYC³-CLI DEPLOYMENT-GUIDE.md
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

# YYC³ CLI 部署指南

## 🎯 部署概述

YYC³ CLI支持多种部署方式，从本地开发到生产环境，确保符合 **「五高五标五化」** 原则。

## 📋 部署检查清单

### 1. 环境准备

- [ ] Node.js >= 16.0.0 已安装
- [ ] npm >= 8.0.0 或 yarn >= 1.22.0 已安装
- [ ] Git 已安装并配置
- [ ] SSH密钥已配置（用于远程部署）
- [ ] 目标服务器访问权限已验证

### 2. 项目检查

- [ ] 代码通过所有测试
- [ ] 无已知安全漏洞
- [ ] 依赖项已锁定版本
- [ ] 环境变量已正确配置
- [ ] 配置文件符合标准

### 3. 部署前验证

- [ ] 端口合规性检查通过（3200-3500）
- [ ] 磁盘空间充足（> 1GB）
- [ ] 内存充足（> 2GB）
- [ ] 网络连接稳定
- [ ] 备份机制就绪

## 🚀 部署流程

### 步骤1：环境配置

#### 开发环境

```bash
# 设置开发环境变量
export NODE_ENV=development
export LOG_LEVEL=debug
export PORT=3200

# 验证环境
yyc3 config --list
```

#### 生产环境

```bash
# 设置生产环境变量
export NODE_ENV=production
export LOG_LEVEL=info
export PORT=3400
export DATABASE_URL=postgresql://user:pass@prod-db:5432/app

# 启用安全增强
export SECURE_COOKIES=true
export CSP_ENABLED=true
```

### 步骤2：构建项目

```bash
# 构建生产版本（优化和压缩）
yyc3 build --mode production --analyze

# 验证构建输出
ls -la dist/
file dist/*

# 运行构建后测试
npm run test:build
```

### 步骤3：部署执行

#### 3.1 本地部署（开发）

```bash
# 部署到本地开发环境
yyc3 deploy dev --config ./config/dev.yaml

# 验证部署
curl http://localhost:3200/health
```

#### 3.2 预发布环境

```bash
# 部署到预发布环境
yyc3 deploy staging --force

# 运行冒烟测试
npm run test:smoke -- --env=staging
```

#### 3.3 生产环境

```bash
# 部署到生产环境（需要确认）
yyc3 deploy prod

# 或使用强制部署（谨慎使用）
yyc3 deploy prod --force
```

### 步骤4：部署后验证

```bash
# 检查服务健康
./yyc3-management.sh health

# 查看实时日志
./yyc3-management.sh logs all

# 性能监控
curl http://localhost:3400/metrics

# 功能验证
npm run test:e2e -- --env=production
```

## 🌍 多环境部署

### 环境配置示例

```yaml:config%2Fenvironments.yaml
# 开发环境
dev:
  name: "开发环境"
  port: 3200
  host: "localhost"
  protocol: "http"
  database:
    host: "localhost"
    port: 5432
    name: "app_dev"
  features:
    debug: true
    cache: false

# 预发布环境  
staging:
  name: "预发布环境"
  port: 3300
  host: "staging.yyc3.com"
  protocol: "https"
  database:
    host: "staging-db.yyc3.com"
    port: 5432
    name: "app_staging"
  features:
    debug: false
    cache: true

# 生产环境
prod:
  name: "生产环境"
  port: 3400
  host: "app.yyc3.com"
  protocol: "https"
  database:
    host: "prod-db.yyc3.com"
    port: 5432
    name: "app_prod"
  features:
    debug: false
    cache: true
    monitoring: true
```

### 环境切换

```bash
# 查看当前环境
echo $NODE_ENV

# 切换到开发环境
export NODE_ENV=development
yyc3 deploy dev

# 切换到生产环境
export NODE_ENV=production  
yyc3 deploy prod
```

## 🐳 Docker 部署

### Dockerfile

```dockerfile:Dockerfile
# 使用官方Node.js镜像
FROM node:18-alpine AS builder

# 设置工作目录
WORKDIR /app

# 复制依赖文件
COPY package*.json ./
COPY yarn.lock ./

# 安装依赖（生产环境）
RUN npm ci --only=production

# 复制应用代码
COPY . .

# 构建应用
RUN npm run build

# 生产环境镜像
FROM node:18-alpine

# 安装必要的系统包
RUN apk add --no-cache curl bash

# 创建非root用户
RUN addgroup -g 1001 -S nodejs && \
    adduser -S yyc3 -u 1001

# 设置工作目录
WORKDIR /app

# 从构建阶段复制文件
COPY --from=builder --chown=yyc3:nodejs /app .

# 切换到非root用户
USER yyc3

# 健康检查
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:${PORT:-3200}/health || exit 1

# 暴露端口
EXPOSE ${PORT:-3200}

# 启动命令
CMD ["node", "dist/index.js"]
```

### Docker Compose配置

```yaml:docker-compose.yml
version: '3.8'

services:
  app:
    build: .
    ports:
      - "${PORT:-3200}:${PORT:-3200}"
    environment:
      - NODE_ENV=${NODE_ENV:-production}
      - PORT=${PORT:-3200}
      - DATABASE_URL=${DATABASE_URL}
    volumes:
      - ./logs:/app/logs
    depends_on:
      - redis
      - postgres
    networks:
      - yyc3-network
    restart: unless-stopped

  postgres:
    image: postgres:15-alpine
    environment:
      POSTGRES_DB: ${DB_NAME}
      POSTGRES_USER: ${DB_USER}
      POSTGRES_PASSWORD: ${DB_PASSWORD}
    volumes:
      - postgres_data:/var/lib/postgresql/data
    networks:
      - yyc3-network
    restart: unless-stopped

  redis:
    image: redis:7-alpine
    command: redis-server --appendonly yes
    volumes:
      - redis_data:/data
    networks:
      - yyc3-network
    restart: unless-stopped

  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf
      - ./ssl:/etc/nginx/ssl
    depends_on:
      - app
    networks:
      - yyc3-network
    restart: unless-stopped

volumes:
  postgres_data:
  redis_data:

networks:
  yyc3-network:
    driver: bridge
```

### Docker部署命令

```bash
# 构建Docker镜像
docker build -t yyc3-app:latest .

# 运行容器
docker run -d \
  --name yyc3-app \
  -p 3200:3200 \
  -e NODE_ENV=production \
  -v $(pwd)/logs:/app/logs \
  yyc3-app:latest

# 使用Docker Compose
docker-compose up -d

# 查看容器日志
docker logs -f yyc3-app
```

## ☸️ Kubernetes 部署

### Deployment配置

```yaml:k8s%2Fdeployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: yyc3-app
  namespace: yyc3
  labels:
    app: yyc3
    component: api
spec:
  replicas: 3
  selector:
    matchLabels:
      app: yyc3
      component: api
  template:
    metadata:
      labels:
        app: yyc3
        component: api
    spec:
      containers:
      - name: app
        image: yyc3-app:latest
        imagePullPolicy: IfNotPresent
        ports:
        - containerPort: 3200
          name: http
        env:
        - name: NODE_ENV
          value: "production"
        - name: PORT
          value: "3200"
        resources:
          requests:
            memory: "256Mi"
            cpu: "250m"
          limits:
            memory: "512Mi"
            cpu: "500m"
        livenessProbe:
          httpGet:
            path: /health
            port: 3200
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /health
            port: 3200
          initialDelaySeconds: 5
          periodSeconds: 5
---
apiVersion: v1
kind: Service
metadata:
  name: yyc3-service
  namespace: yyc3
spec:
  selector:
    app: yyc3
    component: api
  ports:
  - port: 80
    targetPort: 3200
    protocol: TCP
  type: ClusterIP
```

### Ingress配置

```yaml:k8s%2Fingress.yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: yyc3-ingress
  namespace: yyc3
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
    cert-manager.io/cluster-issuer: "letsencrypt-prod"
spec:
  tls:
  - hosts:
    - app.yyc3.com
    secretName: yyc3-tls
  rules:
  - host: app.yyc3.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: yyc3-service
            port:
              number: 80
```

### Kubernetes部署命令

```bash
# 创建命名空间
kubectl create namespace yyc3

# 应用配置
kubectl apply
