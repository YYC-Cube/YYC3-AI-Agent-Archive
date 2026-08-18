---
@file: YYC³-CLI-紧急修复执行指南.md
@description: YYC³-CLI 紧急修复执行指南
@author: YanYuCloudCube Team
@version: v1.0.0
@created: 2026-02-28
@updated: 2026-02-28
@status: published
@tags: [执行指南],[YYC³-CLI]
---

> ***YanYuCloudCube***
> 言启象限 | 语枢未来
> ***Words Initiate Quadrants, Language Serves as Core for the Future***
> 万象归元于云枢 | 深栈智启新纪元
> ***All things converge in cloud pivot; Deep stacks ignite a new era of intelligence***

---

# YYC³-CLI 紧急修复执行指南

## 概述

本指南提供了执行YYC³-CLI项目紧急修复的详细步骤，包括：
1. 移除硬编码配置
2. 清理console.log语句
3. 验证修复结果

## 修复内容

### 1. 已创建的工具脚本

#### 1.1 统一环境变量加载器
**文件**: `scripts/utils/yyc3-env-loader.sh`

**功能**:
- 按优先级加载环境变量文件
- 提供环境变量获取函数
- 支持配置验证

**使用方法**:
```bash
# 在脚本开头引用
source "${SCRIPT_DIR}/../utils/yyc3-env-loader.sh"

# 加载所有环境变量
load_all_env

# 获取环境变量
NAS_HOST=$(get_env_var NAS_HOST '192.168.3.45')
```

#### 1.2 统一日志系统
**文件**: `scripts/utils/yyc3-logger.sh`

**功能**:
- 多级别日志记录（DEBUG/INFO/NOTICE/WARNING/ERROR/CRITICAL）
- 控制台和文件双输出
- YYC³品牌色系

**使用方法**:
```bash
# 在脚本开头引用
source "${SCRIPT_DIR}/../utils/yyc3-logger.sh"

# 使用日志函数
log_debug "调试信息"
log_info "普通信息"
log_notice "通知信息"
log_warning "警告信息"
log_error "错误信息"
log_critical "严重错误"

# 便捷函数
log_success "操作成功"
log_failure "操作失败"
log_progress "进行中"
log_complete "操作完成"
log_alert "重要警告"
```

#### 1.3 硬编码配置修复脚本
**文件**: `scripts/utils/fix-hardcode-config.sh`

**功能**:
- 批量移除硬编码IP地址（192.168.3.45）
- 批量移除硬编码路径（/Volume2/）
- 自动备份原文件
- 生成修复报告

**使用方法**:
```bash
# 赋予执行权限
chmod +x scripts/utils/fix-hardcode-config.sh

# 执行修复
./scripts/utils/fix-hardcode-config.sh
```

#### 1.4 console.log清理脚本
**文件**: `scripts/utils/cleanup-console-log.sh`

**功能**:
- 批量清理JavaScript/TypeScript文件中的console语句
- 移除debugger语句
- 自动备份原文件
- 生成清理报告

**使用方法**:
```bash
# 赋予执行权限
chmod +x scripts/utils/cleanup-console-log.sh

# 执行清理
./scripts/utils/cleanup-console-log.sh
```

## 执行步骤

### 步骤1: 准备环境

```bash
# 进入项目根目录
cd /Volumes/Development/YYC3-CLI

# 确认当前目录
pwd
# 应该输出: /Volumes/Development/YYC3-CLI

# 检查package.json是否存在
ls -la package.json
```

### 步骤2: 赋予执行权限

```bash
# 赋予所有工具脚本执行权限
chmod +x scripts/utils/yyc3-env-loader.sh
chmod +x scripts/utils/yyc3-logger.sh
chmod +x scripts/utils/fix-hardcode-config.sh
chmod +x scripts/utils/cleanup-console-log.sh

# 验证权限
ls -la scripts/utils/
```

### 步骤3: 修复硬编码配置

```bash
# 执行硬编码修复脚本
./scripts/utils/fix-hardcode-config.sh

# 查看修复报告
cat backups/hardcode-fix-*.txt
```

**预期输出**:
```
    ██╗   ██╗ █████╗ ██╗  ██╗██╗   ██╗
    ██║   ██║██╔══██╗██║ ██╔╝██║   ██║
    ██║   ██║███████║█████╔╝ ██║   ██║
    ██║   ██║██╔══██║██╔═██╗ ██║   ██║
    ╚██████╔╝██║  ██║██║  ██╗╚██████╔╝
     ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝

    YYC³ 硬编码配置修复工具
    Hardcode Configuration Fixer
    =======================

[信息] 备份目录已创建: /Volumes/Development/YYC3-CLI/backups/hardcode-fix-20260228_123456
[信息] 开始修复脚本文件...
[成功] 已修复 scripts/utils/yyc3-quick-start.sh (替换 5 处硬编码IP)
[成功] 已修复 scripts/network/yyc3-http.sh (替换 8 处硬编码IP)
...
[成功] 🎉 硬编码配置修复完成！
```

### 步骤4: 清理console.log语句

```bash
# 执行console.log清理脚本
./scripts/utils/cleanup-console-log.sh

# 查看清理报告
cat backups/console-log-cleanup-*.txt
```

**预期输出**:
```
    ██╗   ██╗ █████╗ ██╗  ██╗██╗   ██╗
    ██║   ██║██╔══██╗██║ ██╔╝██║   ██║
    ██║   ██║███████║█████╔╝ ██║   ██║
    ██║   ██║██╔══██║██╔═██╗ ██║   ██║
    ╚██████╔╝██║  ██║██║  ██╗╚██████╔╝
     ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝

    YYC³ console.log清理工具
    Console.log Cleanup Tool
    =======================

📊 当前console语句统计:
  总计: 156 处console语句

[信息] 开始清理脚本目录...
[成功] 已清理 lib/index.js (移除 12 处console语句)
[成功] 已清理 packages/yyc3-cli/lib/index.js (移除 8 处console语句)
...
[成功] 🎉 console.log清理完成！
```

### 步骤5: 验证修复结果

```bash
# 检查是否还有硬编码IP
grep -r "192.168.3.45" scripts/ lib/ packages/ --include="*.sh" --include="*.js" 2>/dev/null || echo "✅ 无硬编码IP"

# 检查是否还有硬编码路径
grep -r "/Volume2/" scripts/ lib/ packages/ --include="*.sh" --include="*.js" 2>/dev/null || echo "✅ 无硬编码路径"

# 检查是否还有console.log
grep -r "console\.log" scripts/ lib/ packages/ --include="*.js" --include="*.ts" 2>/dev/null || echo "✅ 无console.log"

# 检查是否还有debugger
grep -r "debugger" scripts/ lib/ packages/ --include="*.js" --include="*.ts" 2>/dev/null || echo "✅ 无debugger"
```

### 步骤6: 测试功能

```bash
# 测试环境变量加载器
source scripts/utils/yyc3-env-loader.sh
echo "NAS_HOST: $NAS_HOST"
echo "PROJECT_ROOT: $PROJECT_ROOT"

# 测试日志系统
source scripts/utils/yyc3-logger.sh
log_info "测试信息日志"
log_success "测试成功日志"
log_warning "测试警告日志"
log_error "测试错误日志"

# 测试CLI工具
node bin/yyc3-cli.js --version
node bin/yyc3-cli.js --help
```

## 环境变量配置

### 创建.env.local文件

在项目根目录创建`.env.local`文件：

```bash
# ================================================================================
# YYC³ 本地环境变量配置
# ================================================================================
#
# > YanYuCloudCube
# > 言启象限 | 语枢未来
#
# 创建日期: 2026-02-28
# 作者: YYC³ Team
#
# 注意事项:
# 1. 此文件包含本地开发环境的特定配置
# 2. 请勿将此文件提交到版本控制系统
# 3. 生产环境请使用独立的 .env.production 文件
#
# ================================================================================

# ================================================================================
# 基础设施配置
# ================================================================================

# NAS配置
NAS_HOST=192.168.3.45
NAS_SSH_PORT=9557
NAS_SSH_USER=YYC
NAS_HTTP_PORT=8989
NAS_HTTPS_PORT=9898

# 网络配置
NEW_DOMAIN=china.0379.pro
NEW_EMAIL_SERVER=0379.email

# 项目路径配置
PROJECT_ROOT=/Volumes/Development/YYC3-CLI
ROOT_DIR=/Volumes/Development/YYC3-CLI

# ================================================================================
# 应用配置
# ================================================================================

# Node环境
NODE_ENV=development
NODE_VERSION=18

# 端口配置
DEFAULT_PORT=3200
HTTP_PORT=3200
HTTPS_PORT=3201

# ================================================================================
# 日志配置
# ================================================================================

# 日志级别 (debug|info|notice|warning|error|critical)
LOG_LEVEL=info

# 日志目录
LOG_DIR=./logs

# 日志输出配置
LOG_TO_CONSOLE=true
LOG_TO_FILE=true
LOG_COLOR=true
```

### 更新.gitignore

确保`.gitignore`包含以下内容：

```gitignore
# 环境变量
.env
.env.local
.env.*.local

# 备份目录
backups/

# 日志文件
logs/
*.log

# 临时文件
tmp/
temp/
```

## 脚本迁移指南

### 迁移现有脚本使用新工具

#### 示例1: 迁移欢迎信息脚本

**旧代码**:
```bash
#!/bin/bash

# 颜色定义
readonly COLOR_RED='\033[0;31m'
readonly COLOR_GREEN='\033[0;32m'
readonly COLOR_YELLOW='\033[1;33m'
readonly COLOR_BLUE='\033[0;34m'
readonly COLOR_CYAN='\033[0;36m'
readonly COLOR_RESET='\033[0m'

# 欢迎信息
show_welcome() {
    clear
    echo -e "${COLOR_CYAN}"
    cat << 'EOF'
    ██╗   ██╗ █████╗ ██╗  ██╗██╗   ██╗
    ...
EOF
    echo -e "${COLOR_RESET}"
    echo "欢迎使用 YYC³ 工具"
    echo "===================="
}

show_welcome
```

**新代码**:
```bash
#!/bin/bash

# 引入统一工具
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../utils/yyc3-env-loader.sh"
source "${SCRIPT_DIR}/../utils/yyc3-logger.sh"

# 初始化环境
load_all_env

# 初始化日志
init_logger

# 显示欢迎信息
log_info "欢迎使用 YYC³ 工具"
log_info "===================="
```

#### 示例2: 迁移日志记录

**旧代码**:
```bash
# 信息日志
log_info() {
    echo -e "${COLOR_CYAN}[信息]${COLOR_RESET} $1"
}

# 错误日志
log_error() {
    echo -e "${COLOR_RED}[错误]${COLOR_RESET} $1" >&2
}

# 使用
log_info "开始处理..."
log_error "处理失败"
```

**新代码**:
```bash
# 引入统一日志系统
source "${SCRIPT_DIR}/../utils/yyc3-logger.sh"

# 使用统一日志函数
log_info "开始处理..."
log_error "处理失败"

# 或使用便捷函数
log_success "处理成功"
log_warning "处理警告"
```

## 验证清单

### 修复前检查清单

- [ ] 确认项目根目录正确
- [ ] 确认package.json存在
- [ ] 备份重要文件
- [ ] 了解修复范围和影响

### 修复后验证清单

- [ ] 硬编码IP已全部移除
- [ ] 硬编码路径已全部移除
- [ ] console.log已全部清理
- [ ] debugger已全部清理
- [ ] 环境变量正确加载
- [ ] 日志系统正常工作
- [ ] CLI工具功能正常
- [ ] 备份文件已保存
- [ ] 修复报告已生成

### 功能测试清单

- [ ] 环境变量加载器测试通过
- [ ] 日志系统测试通过
- [ ] CLI工具版本检查通过
- [ ] CLI工具帮助文档正常
- [ ] 项目初始化功能正常
- [ ] 配置管理功能正常

## 回滚方案

### 如果修复出现问题

#### 1. 恢复硬编码配置修复

```bash
# 查找备份目录
ls -la backups/hardcode-fix-*

# 恢复特定文件
cp backups/hardcode-fix-20260228_123456/scripts/utils/yyc3-quick-start.sh scripts/utils/yyc3-quick-start.sh

# 或恢复整个备份
cp -r backups/hardcode-fix-20260228_123456/* .
```

#### 2. 恢复console.log清理

```bash
# 查找备份目录
ls -la backups/console-log-cleanup-*

# 恢复特定文件
cp backups/console-log-cleanup-20260228_123456/lib/index.js lib/index.js

# 或恢复整个备份
cp -r backups/console-log-cleanup-20260228_123456/* .
```

#### 3. 完全回滚

```bash
# 删除所有修改
git checkout -- .

# 或使用git恢复特定文件
git restore scripts/utils/yyc3-quick-start.sh
```

## 常见问题

### Q1: 修复脚本执行失败

**问题**: 脚本没有执行权限

**解决方案**:
```bash
# 赋予执行权限
chmod +x scripts/utils/fix-hardcode-config.sh
chmod +x scripts/utils/cleanup-console-log.sh
```

### Q2: 环境变量未加载

**问题**: 环境变量为空或未设置

**解决方案**:
```bash
# 检查.env.local文件是否存在
ls -la .env.local

# 手动加载环境变量
source scripts/utils/yyc3-env-loader.sh

# 验证环境变量
echo $NAS_HOST
echo $PROJECT_ROOT
```

### Q3: 日志系统不工作

**问题**: 日志未输出或输出格式错误

**解决方案**:
```bash
# 检查日志目录权限
ls -la logs/

# 手动创建日志目录
mkdir -p logs

# 设置日志级别
export LOG_LEVEL=debug
```

### Q4: 修复后功能异常

**问题**: 修复后脚本或工具无法正常工作

**解决方案**:
```bash
# 查看修复报告
cat backups/hardcode-fix-*.txt
cat backups/console-log-cleanup-*.txt

# 检查备份文件
ls -la backups/

# 恢复备份
cp backups/hardcode-fix-*/filename.sh path/to/file.sh
```

## 下一步行动

### 短期（1周内）

1. ✅ 完成硬编码配置修复
2. ✅ 完成console.log清理
3. ⏳ 统一所有脚本使用新工具
4. ⏳ 更新文档和示例

### 中期（2周内）

1. ⏳ 实现统一欢迎信息系统
2. ⏳ 完善配置管理系统
3. ⏳ 建立代码质量检查流程

### 长期（1个月内）

1. ⏳ 建立自动化测试流程
2. ⏳ 实现持续集成优化
3. ⏳ 完善监控和告警系统

---

<div align="center">

> 「***YanYuCloudCube***」
> 「***<admin@0379.email>***」
> 「***Words Initiate Quadrants, Language Serves as Core for the Future***」
> 「***All things converge in the cloud pivot; Deep stacks ignite a new era of intelligence***」

</div>
