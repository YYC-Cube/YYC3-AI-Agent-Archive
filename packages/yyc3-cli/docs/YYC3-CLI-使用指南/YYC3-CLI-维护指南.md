---
@file: NAVIGATION-GUIDE.md
@description: YYC³-CLI NAVIGATION-GUIDE.md
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

# YYC³ 目录跳转与使用维护指南

## 🧭 快速导航

### 核心目录快速跳转

```bash
# 跳转到项目根目录
cd /Users/yanyu/yyc3-management

# 跳转到CLI工具目录
cd YYC3_CLI

# 跳转到macOS脚本目录
cd Mac

# 跳转到脚本集合目录
cd scripts

# 跳转到配置目录
cd .github
```

### 快捷命令设置

在您的Shell配置文件中添加以下别名：

```bash
# ~/.zshrc 或 ~/.bashrc

alias yyc3='cd /Users/yanyu/yyc3-management'
alias yyc3-cli='cd /Users/yanyu/yyc3-management/YYC3_CLI'
alias yyc3-mac='cd /Users/yanyu/yyc3-management/Mac'
alias yyc3-scripts='cd /Users/yanyu/yyc3-management/scripts'
alias yyc3-config='cd /Users/yanyu/yyc3-management/.github'

# 重新加载配置
source ~/.zshrc
```

## 🚀 常用操作指南

### 1. 系统状态检查

```bash
# 在项目根目录执行
./yyc3-smart-ops.sh status

# 检查错误
./yyc3-error-fixer.sh scan

# 检查AI服务状态
./yyc3-ai.sh status
```

### 2. 开发环境启动

```bash
# 启动AI服务
./yyc3-ai.sh start

# 启动开发环境
./yyc3-management.sh dev

# 启动监控
./yyc3-smart-ops.sh monitor
```

### 3. 项目构建部署

```bash
# 构建项目
./build.sh

# 构建Docker镜像
./build-docker.sh

# 部署到本地
./deploy.sh

# 使用Docker Compose启动
docker-compose up -d
```

## 📁 目录功能详解

### 核心运维目录 (`YYC3_CLI/`)

**主要功能**: CLI工具核心实现和运维脚本

**关键文件**:
- `packages/yyc3-cli/bin/yyc3-cli.js` - CLI主入口
- `yyc3-ai.sh` - AI服务管理
- `yyc3-management.sh` - 项目管理
- `yyc3-config-validator.sh` - 配置验证

**使用示例**:
```bash
cd YYC3_CLI
./yyc3-ai.sh status
./yyc3-management.sh dev
```

### macOS专用目录 (`Mac/`)

**主要功能**: macOS系统级管理和优化脚本

**关键文件**:
- `yyc3-env.sh` - 环境配置
- `yyc3-frp.sh` - 内网穿透
- `yyc3-http.sh` - HTTP服务
- `yyc3-install.sh` - 系统安装

**使用示例**:
```bash
cd Mac
./yyc3-env.sh setup
./yyc3-frp.sh start
```

### 脚本集合目录 (`scripts/`)

**主要功能**: 按功能分类的脚本集合

**子目录说明**:
- `ai/` - AI相关自动化脚本
- `cleanup/` - 系统清理脚本
- `dev/` - 开发环境脚本
- `utils/` - 工具函数脚本

**使用示例**:
```bash
cd scripts/ai
./auto.sh

cd scripts/cleanup
./deep-clean.sh
```

### 配置管理目录 (`.github/`, `.vscode/`, `.husky/`)

**主要功能**: 开发工具和流程配置

**关键配置**:
- `.github/workflows/` - CI/CD流水线
- `.vscode/` - VS Code开发环境
- `.husky/` - Git钩子配置

## 🔧 维护操作指南

### 日常维护流程

#### 1. 系统健康检查
```bash
# 检查系统状态
yyc3
./yyc3-smart-ops.sh status

# 检查错误
yyc3
./yyc3-error-fixer.sh scan

# 检查资源使用
yyc3
./yyc3-smart-ops.sh analyze
```

#### 2. 日志管理
```bash
# 查看系统日志
yyc3
./scripts/cleanup/logs.sh view

# 清理旧日志
yyc3
./scripts/cleanup/logs.sh clean
```

#### 3. 缓存清理
```bash
# 清理系统缓存
yyc3
./scripts/cleanup/caches.sh

# 深度清理
yyc3
./scripts/cleanup/deep-clean.sh
```

### 故障排查指南

#### 1. 服务无法启动
```bash
# 检查服务状态
yyc3
./yyc3-smart-ops.sh status

# 检查错误日志
yyc3
./scripts/cleanup/logs.sh error

# 重启服务
yyc3
./yyc3-management.sh restart
```

#### 2. 性能问题
```bash
# 性能分析
yyc3
./yyc3-smart-ops.sh analyze

# 运行基准测试
yyc3
./performance-benchmark.sh

# 检查资源使用
yyc3
top  # 查看系统资源
```

#### 3. 配置问题
```bash
# 验证配置
yyc3
./yyc3-config-validator.sh

# 更新配置
yyc3
./update-config.sh

# 同步环境
yyc3
./sync-env.sh
```

## 📋 定期维护计划

### 每日维护
- [ ] 系统状态检查 (`./yyc3-smart-ops.sh status`)
- [ ] 错误扫描 (`./yyc3-error-fixer.sh scan`)
- [ ] 日志检查 (`./scripts/cleanup/logs.sh view`)

### 每周维护
- [ ] 深度清理 (`./scripts/cleanup/deep-clean.sh`)
- [ ] 性能分析 (`./yyc3-smart-ops.sh analyze`)
- [ ] 备份检查 (`./yyc3-management.sh backup`)

### 每月维护
- [ ] 安全扫描 (`./yyc3-error-fixer.sh security`)
- [ ] 依赖更新 (`npm update`)
- [ ] 文档更新 (检查文档完整性)

## 🛠️ 工具使用技巧

### Shell快捷键
```bash
# 快速回到项目根目录
yyc3

# 查看最近修改的文件
ls -lat | head -10

# 查找特定文件
find . -name "*.sh" -type f

# 批量修改权限
find . -name "*.sh" -exec chmod +x {} \;
```

### Git操作技巧
```bash
# 查看提交历史
git log --oneline -10

# 查看文件变更
git status

# 撤销本地修改
git checkout -- <file>

# 清理未跟踪文件
git clean -fd
```

### 调试技巧
```bash
# 调试Shell脚本
bash -x ./script.sh

# 检查语法
bash -n ./script.sh

# 查看环境变量
env | grep YYC3

# 跟踪系统调用
strace -f ./script.sh
```

## 📞 紧急联系方式

### 技术支持
- **项目负责人**: YYC³团队
- **紧急响应**: 1小时内
- **常规支持**: 24小时内

### 问题上报
1. 使用GitHub Issues提交问题
2. 提供详细的错误信息
3. 包含复现步骤和日志

### 文档更新
- 发现文档问题请及时更新
- 保持文档与实际代码同步
- 定期审查文档准确性

---

**文档版本**: 1.0.0  
**最后更新**: 2025-01-30  
**维护团队**: YYC³开发团队