---
@file: YYC3-CLI-开发者工具包本地部署指南.md
@description: YYC³-CLI YYC3-CLI-开发者工具包本地部署指南.md
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

# YYC³ 开发者工具包本地部署指南

## 📋 部署前准备

### 系统要求

- **操作系统**: Linux (推荐 Ubuntu 20.04+) 或 macOS
- **CPU**: 8 核心以上 (推荐)
- **内存**: 16GB 以上 (推荐)
- **存储**: 500GB 以上可用空间 (SSD 推荐)
- **网络**: 稳定的互联网连接

### 必需软件

1. **Docker** (版本 20.10+)
   \`\`\`bash

   # Ubuntu/Debian

   curl -fsSL <https://get.docker.com> -o get-docker.sh
   sudo sh get-docker.sh

   # macOS

   brew install docker
   \`\`\`

2. **Docker Compose** (版本 2.0+)
   \`\`\`bash

   # Linux

   sudo curl -L "<https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname> -s)-$(uname -m)" -o /usr/local/bin/docker-compose
   sudo chmod +x /usr/local/bin/docker-compose

   # macOS

   brew install docker-compose
   \`\`\`

3. **必需工具**
   \`\`\`bash

   # Ubuntu/Debian

   sudo apt-get update
   sudo apt-get install -y curl jq git openssl bc netstat-nat

   # macOS

   brew install curl jq git openssl bc
   \`\`\`

## 🚀 快速部署 (推荐)

### 方法一：一键部署

\`\`\`bash

# 1. 下载部署脚本

curl -fsSL <https://raw.githubusercontent.com/your-repo/yyc3-devkit/main/scripts/quick-start.sh> -o quick-start.sh

# 2. 设置执行权限

chmod +x quick-start.sh

# 3. 执行部署

sudo ./quick-start.sh
\`\`\`

### 方法二：分步部署

\`\`\`bash

# 1. 创建工作目录

sudo mkdir -p /volume2/YC
cd /volume2/YC

# 2. 下载所有脚本

git clone <https://github.com/your-repo/yyc3-devkit.git> .

# 3. 设置执行权限

chmod +x scripts/*.sh

# 4. 执行部署前检查

sudo ./scripts/final-deployment-check.sh

# 5. 设置环境变量

source ./scripts/set-env.sh

# 6. 开始部署

sudo ./scripts/advanced-setup.sh
sudo ./scripts/gitlab-integration.sh
sudo ./scripts/ai-model-optimizer.sh
sudo ./scripts/monitoring-alerts.sh
\`\`\`

## 📝 详细部署步骤

### 步骤 1: 环境准备

\`\`\`bash

# 检查 Docker 安装

docker --version
docker-compose --version

# 启动 Docker 服务

sudo systemctl start docker
sudo systemctl enable docker

# 将当前用户添加到 docker 组 (可选)

sudo usermod -aG docker $USER

# 注意：需要重新登录才能生效

\`\`\`

### 步骤 2: 下载和配置

\`\`\`bash

# 创建工作目录

sudo mkdir -p /volume2/YC
cd /volume2/YC

# 设置目录权限

sudo chown -R $USER:$USER /volume2/YC

# 下载项目文件 (如果有 Git 仓库)

git clone <https://your-git-repo.com/yyc3-devkit.git> .

# 或者手动创建目录结构

mkdir -p {scripts,configs,docs,services,gitlab,ai-models,monitoring,backups}
\`\`\`

### 步骤 3: 配置环境变量

\`\`\`bash

# 复制环境变量模板

cp .env.example .env

# 编辑环境变量

nano .env

# 必需配置项

YYC3_REGISTRY=<http://192.168.0.9:4873>
NEXT_PUBLIC_BASE_URL=<http://192.168.0.9:3001>
PORT=3001
JWT_SECRET=your-secure-jwt-secret
WECHAT_WEBHOOK_URL=your-wechat-webhook-url

# 加载环境变量

source .env
\`\`\`

### 步骤 4: 执行部署脚本

\`\`\`bash

# 1. 基础设置

sudo ./scripts/advanced-setup.sh

# 2. 安全加固

sudo ./scripts/security-hardening.sh

# 3. GitLab 集成

sudo ./scripts/gitlab-integration.sh

# 4. AI 模型优化

sudo ./scripts/ai-model-optimizer.sh

# 5. 监控告警

sudo ./scripts/monitoring-alerts.sh

# 6. 健康检查

sudo ./scripts/health-check.sh
\`\`\`

### 步骤 5: 验证部署

\`\`\`bash

# 检查服务状态

docker ps

# 检查网络连接

curl <http://192.168.0.9:3001>  # 管理面板
curl <http://192.168.0.9:4873>  # NPM 仓库
curl <http://192.168.0.9:8080>  # GitLab
curl <http://192.168.0.9:9090>  # Prometheus
\`\`\`

## 🔧 配置说明

### 网络配置

如果您的服务器 IP 不是 `192.168.0.9`，需要修改以下文件中的 IP 地址：

\`\`\`bash

# 查找并替换 IP 地址

find . -type f -name "*.sh" -o -name "*.yml" -o -name "*.conf" | xargs sed -i 's/192.168.0.9/YOUR_SERVER_IP/g'
\`\`\`

### 端口配置

默认端口分配：

| 端口 | 服务 | 说明 |
|------|------|------|
| 3001 | YYC³ 管理面板 | 主要管理界面 |
| 4873 | NPM 私有仓库 | Verdaccio |
| 8080 | GitLab | 代码管理 |
| 8888 | AI 路由器 | AI 服务负载均衡 |
| 9090 | Prometheus | 监控数据收集 |
| 3000 | Grafana | 监控可视化 |
| 9093 | AlertManager | 告警管理 |
| 11434/11435 | Ollama | AI 模型服务 |

如需修改端口，请编辑相应的 `docker-compose.yml` 文件。

### 存储配置

默认数据存储位置：

\`\`\`
/volume2/YC/
├── gitlab-data/          # GitLab 数据
├── ai-models/           # AI 模型数据
├── monitoring/          # 监控数据
├── backups/            # 备份数据
└── configs/            # 配置文件
\`\`\`

## 🚨 常见问题和解决方案

### 问题 1: Docker 权限错误

\`\`\`bash

# 错误: permission denied while trying to connect to the Docker daemon socket

sudo usermod -aG docker $USER
newgrp docker

# 或者重新登录

\`\`\`

### 问题 2: 端口被占用

\`\`\`bash

# 检查端口占用

sudo netstat -tulpn | grep :3001

# 停止占用端口的服务

sudo kill -9 PID

# 或者修改配置文件中的端口

\`\`\`

### 问题 3: 磁盘空间不足

\`\`\`bash

# 检查磁盘使用情况

df -h

# 清理 Docker 未使用的资源

docker system prune -a

# 清理日志文件

sudo find /var/log -type f -name "*.log" -mtime +7 -delete
\`\`\`

### 问题 4: 内存不足

\`\`\`bash

# 检查内存使用

free -h

# 限制容器内存使用 (编辑 docker-compose.yml)

services:
  service-name:
    deploy:
      resources:
        limits:
          memory: 2G
\`\`\`

### 问题 5: 服务启动失败

\`\`\`bash

# 查看容器日志

docker logs container-name

# 查看详细错误信息

docker-compose logs service-name

# 重启服务

docker-compose restart service-name
\`\`\`

## 🔒 安全注意事项

### 1. 防火墙配置

\`\`\`bash

# Ubuntu/Debian

sudo ufw allow 22/tcp      # SSH
sudo ufw allow 3001/tcp    # 管理面板
sudo ufw allow 8080/tcp    # GitLab
sudo ufw enable

# CentOS/RHEL

sudo firewall-cmd --permanent --add-port=3001/tcp
sudo firewall-cmd --permanent --add-port=8080/tcp
sudo firewall-cmd --reload
\`\`\`

### 2. SSL 证书配置

\`\`\`bash

# 安装 Certbot

sudo apt-get install certbot

# 申请证书

sudo certbot certonly --standalone -d your-domain.com

# 配置 Nginx SSL (如果使用)

sudo nano /etc/nginx/sites-available/yyc3
\`\`\`

### 3. 定期备份

\`\`\`bash

# 创建备份脚本

cat > /volume2/YC/backup.sh << 'EOF'
# !/bin/bash
BACKUP_DIR="/volume2/YC/backups/$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BACKUP_DIR"
cp -r /volume2/YC/configs "$BACKUP_DIR/"
cp -r /volume2/YC/gitlab-data "$BACKUP_DIR/"
tar -czf "$BACKUP_DIR.tar.gz" "$BACKUP_DIR"
rm -rf "$BACKUP_DIR"
EOF

chmod +x /volume2/YC/backup.sh

# 设置定时备份

crontab -e

# 添加: 0 2 ** * /volume2/YC/backup.sh

\`\`\`

## 📊 监控和维护

### 日常检查命令

\`\`\`bash

# 查看服务状态

./manage.sh status

# 查看资源使用情况

docker stats

# 查看日志

./manage.sh logs container-name

# 更新服务

./manage.sh update
\`\`\`

### 性能优化

\`\`\`bash

# 清理未使用的 Docker 资源

docker system prune -a

# 优化 Docker 配置

sudo nano /etc/docker/daemon.json
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  }
}

# 重启 Docker

sudo systemctl restart docker
\`\`\`

## 🎯 部署后验证清单

- [ ] 所有服务容器正常运行
- [ ] 管理面板可以访问 (<http://your-ip:3001>)
- [ ] GitLab 可以访问 (<http://your-ip:8080>)
- [ ] NPM 仓库可以访问 (<http://your-ip:4873>)
- [ ] Grafana 监控面板可以访问 (<http://your-ip:3000>)
- [ ] AI 服务响应正常
- [ ] 告警系统配置正确
- [ ] 备份脚本可以正常执行
- [ ] 防火墙规则配置正确
- [ ] SSL 证书配置正确 (如果使用)

## 📞 获取帮助

如果在部署过程中遇到问题：

1. 查看日志文件: `/tmp/yyc3-*.log`
2. 检查 Docker 容器状态: `docker ps -a`
3. 查看系统资源: `htop` 或 `docker stats`
4. 参考故障排除文档: `docs/troubleshooting.md`

---

**部署完成后，请及时修改默认密码和配置安全策略！**

---

> 「***YanYuCloudCube***」
> 「***<admin@0379.email>***」
> 「***Words Initiate Quadrants, Language Serves as Core for the Future***」
> 「***All things converge in the cloud pivot; Deep stacks ignite a new era of intelligence***」
