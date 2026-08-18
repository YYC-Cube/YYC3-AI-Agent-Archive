---
@file: PROJECT-TREE.md
@description: YYC³-CLI PROJECT-TREE.md
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

# YYC³ 项目文件树结构

## 📁 完整项目目录结构

```
/Users/yanyu/yyc3-management/
├── 📁 .git-hooks/                   # Git钩子脚本
│   └── pre-push                     # 推送前检查脚本
├── 📁 .github/                      # GitHub配置
│   └── 📁 workflows/                # CI/CD工作流
│       ├── ci-cd-pipeline.yml       # 主CI/CD流水线
│       └── permissions.yml          # 权限配置
├── 📁 .husky/                       # Husky配置
│   ├── commit-msg                   # 提交消息检查
│   └── pre-commit                   # 提交前检查
├── 📁 .trae/                        # Trae IDE配置
│   └── 📁 rules/                    # 项目规则
│       └── project_rules.md         # 项目开发规则
├── 📁 .vscode/                      # VS Code配置
│   ├── extensions.json              # 推荐扩展
│   ├── launch.json                  # 调试配置
│   ├── settings.json                # 编辑器设置
│   ├── tasks.json                   # 任务配置
│   └── typescript.code-snippets     # TypeScript代码片段
├── 📁 Mac/                          # macOS专用脚本
│   ├── Mac-ssh.md                   # SSH配置文档
│   ├── yyc3-.sh                     # 基础脚本
│   ├── yyc3-cli.sh                  # CLI工具脚本
│   ├── yyc3-env.sh                  # 环境配置脚本
│   ├── yyc3-frp.sh                  # FRP内网穿透
│   ├── yyc3-http.sh                 # HTTP服务管理
│   ├── yyc3-install.sh              # 安装脚本
│   ├── yyc3-kb.sh                   # 知识库脚本
│   ├── yyc3-knowledge-base.sh       # 知识库管理
│   ├── yyc3-mail.sh                 # 邮件服务
│   ├── yyc3-model-mana.sh           # 模型管理
│   ├── yyc3-model.sh                # AI模型脚本
│   ├── yyc3-stall.sh                # 服务安装
│   ├── yyc3-star.sh                 # 星标功能
│   └── yyc3.sh                      # 主脚本
├── 📁 YYC3_CLI/                     # CLI工具项目
│   ├── 📁 k8s/                      # Kubernetes配置
│   │   ├── deployment.yaml          # 部署配置
│   │   └── ingress.yaml             # 入口配置
│   ├── 📁 packages/                 # CLI包管理
│   │   └── 📁 yyc3-cli/             # 主CLI包
│   │       ├── 📁 __tests__/        # 测试文件
│   │       │   ├── cli.test.js      # CLI测试
│   │       │   ├── integration.test.js # 集成测试
│   │       │   └── performance.test.js # 性能测试
│   │       ├── 📁 bin/              # 可执行文件
│   │       │   └── yyc3-cli.js      # CLI入口点
│   │       ├── 📁 lib/              # 库文件
│   │       │   └── index.js         # 核心实现
│   │       ├── 📁 templates/        # 模板文件
│   │       ├── package-lock.json    # 依赖锁定
│   │       └── package.json         # 包配置
│   ├── 📄 智能聊天界面.html            # 智能聊天界面
│   ├── 📄 万象归元于云枢.html          # 项目主页
│   ├── INSTALL_SCRIPT_REVIEW.md     # 安装脚本审查
│   ├── YYC3-C.md                    # CLI文档
│   ├── install-yyc3-cli.sh          # CLI安装脚本
│   ├── yyc3-AlertManager.sh         # 告警管理
│   ├── yyc3-DevOps.sh               # DevOps脚本
│   ├── yyc3-ai-admin.sh             # AI管理脚本
│   ├── yyc3-ai.sh                   # AI服务脚本
│   ├── yyc3-cli.md                  # CLI使用文档
│   ├── yyc3-config-validator.sh     # 配置验证
│   ├── yyc3-devkit-setup.sh         # 开发工具设置
│   ├── yyc3-final-deployment-check.sh # 最终部署检查
│   ├── yyc3-first-steps-guide.md    # 入门指南
│   ├── yyc3-frpc.sh                 # FRPC客户端
│   ├── yyc3-kb-.md                  # 知识库文档
│   ├── yyc3-kb.md                   # 知识库主文档
│   ├── yyc3-knowledge-base.sh       # 知识库脚本
│   ├── yyc3-local-deployment-guide.md # 本地部署指南
│   ├── yyc3-management.sh           # 管理脚本
│   ├── yyc3-nas.sh                  # NAS脚本
│   ├── yyc3-quick-start.sh          # 快速开始
│   ├── yyc3-set-env.sh              # 环境设置
│   ├── 万象归元于云枢.html          # 项目主页
│   └── 智能聊天界面.html            # AI聊天界面
├── 📁 grafana/                      # Grafana配置
│   └── dashboard.json               # 监控面板配置
├── 📁 packages/                     # 全局包管理
│   └── 📁 yyc3-cli/                 # CLI包（全局）
│       ├── 📁 bin/                  # 可执行文件
│       │   └── yyc3-cli.js          # CLI入口
│       ├── 📁 lib/                  # 库文件
│       │   └── index.js             # 核心实现
│       └── package.json             # 包配置
├── 📁 scripts/                      # 脚本集合
│   ├── 📁 ai/                       # AI相关脚本
│   │   ├── auto.sh                  # 自动化脚本
│   │   ├── doc.sh                   # 文档生成
│   │   ├── gen.sh                   # 代码生成
│   │   ├── pair.sh                  # 结对编程
│   │   ├── plan.sh                  # 计划脚本
│   │   └── review.sh                # 代码审查
│   ├── 📁 cleanup/                  # 清理脚本
│   │   ├── caches.sh                # 缓存清理
│   │   ├── deep-clean.sh            # 深度清理
│   │   ├── docker.sh                # Docker清理
│   │   └── logs.sh                  # 日志清理
│   ├── 📁 dev/                      # 开发脚本
│   │   ├── setup.sh                 # 环境设置
│   │   ├── start.sh                 # 启动脚本
│   │   ├── status.sh                # 状态检查
│   │   ├── stop.sh                  # 停止脚本
│   │   ├── sync-custom.sh           # 自定义同步
│   │   └── sync.sh                  # 同步脚本
│   └── 📁 utils/                    # 工具脚本
│       ├── colors.sh                # 颜色定义
│       ├── common.sh                # 通用函数
│       └── install-completion.sh    # 自动补全安装
├── 📄 .docker-permissions           # Docker权限配置
├── 📄 .dockerignore                 # Docker忽略文件
├── 📄 .editorconfig                 # 编辑器配置
├── 📄 .env.docker                   # Docker环境变量
├── 📄 .env.example                  # 环境变量示例
├── 📄 .env.local                    # 本地环境变量
├── 📄 .env.permissions              # 权限环境变量
├── 📄 .eslintignore                 # ESLint忽略文件
├── 📄 .eslintrc.js                  # ESLint配置
├── 📄 .gitattributes                # Git属性
├── 📄 .gitconfig                    # Git配置
├── 📄 .gitignore                    # Git忽略文件
├── 📄 .gitleaks.toml                # 安全扫描配置
├── 📄 .mcpignore                    # MCP忽略文件
├── 📄 .prettierrc                   # Prettier配置
├── 📄 API-DOCUMENTATION.md          # API文档
├── 📄 CODEOWNERS                    # 代码所有者
├── 📄 DEPLOYMENT-GUIDE.md           # 部署指南
├── 📄 DEVOPS-GUIDE.md               # DevOps指南
├── 📄 Dockerfile                    # Docker构建文件
├── 📄 Dockerfile.perms              # 权限Dockerfile
├── 📄 ISSUE-TRACKING.md             # 问题跟踪
├── 📄 Makefile                      # Make构建配置
├── 📄 NAVIGATION-GUIDE.md           # 导航指南
├── 📄 README.md                     # 项目说明
├── 📄 YYC³团队审核分析清单.md       # 审核清单
├── 📄 access-control.json           # 访问控制
├── 📄 ai-code-gen.sh                # AI代码生成
├── 📄 ai-code-review.sh             # AI代码审查
├── 📄 branch-protection.yml         # 分支保护
├── 📄 build-docker.sh               # Docker构建
├── 📄 build.sh                      # 构建脚本
├── 📄 check-env.sh                  # 环境检查
├── 📄 commitlint.config.js          # 提交消息检查
├── 📄 deploy.sh                     # 部署脚本
├── 📄 devctl                        # 开发控制工具
├── 📄 docker-compose.permissions.yml # 权限Docker Compose
├── 📄 docker-compose.yml            # Docker Compose配置
├── 📄 find-problem-extension.sh     # 问题检测
├── 📄 husky.config.js               # Husky配置
├── 📄 init-project.sh               # 项目初始化
├── 📄 init-yyc3-project-incremental.md # 增量初始化文档
├── 📄 init-yyc3-project-incremental.sh # 增量初始化脚本
├── 📄 init-yyc3-project.md          # 初始化文档
├── 📄 init-yyc3-project.sh          # 初始化脚本
├── 📄 lint-staged.config.js         # 提交前检查配置
├── 📄 mcp-access-rules.json         # MCP访问规则
├── 📄 mcp-audit-log.yml             # MCP审计日志
├── 📄 mcp-roles.json                # MCP角色配置
├── 📄 mcp.config.js                 # MCP配置
├── 📄 performance-benchmark.sh      # 性能基准测试
├── 📄 rbac.config.js                # RBAC配置
├── 📄 rollback.sh                   # 回滚脚本
├── 📄 sync-env.sh                   # 环境同步
├── 📄 tsconfig.json                 # TypeScript配置
├── 📄 update-config.sh              # 配置更新
├── 📄 yyc                           # 快捷命令
├── 📄 yyc3-error-fixer.sh           # 错误修复脚本
├── 📄 yyc3-management.sh            # 管理脚本
├── 📄 yyc3-project.md               # 项目文档
├── 📄 yyc3-project.sh               # 项目脚本
├── 📄 yyc3-smart-ops.sh             # 智能运维脚本
├── 📄 yyc3_project.md               # 项目文档（重复）
├── 📄 yycc                          # 快捷命令
├── 📄 脚本说明.md                   # 脚本说明文档
└── 📄 配置指南.md                   # 配置指南文档
```

## 🔍 关键目录说明

### 核心运维目录

- **`YYC3_CLI/`** - CLI工具核心实现，包含完整的命令行功能
- **`Mac/`** - macOS专用脚本，提供系统级管理功能
- **`scripts/`** - 各类功能脚本集合，按功能模块分类

### 配置管理目录

- **`.github/`** - CI/CD和GitHub相关配置
- **`.vscode/`** - VS Code开发环境配置
- **`.husky/`** - Git钩子配置

### 文档目录

- **根目录文档** - 项目核心文档和指南
- **`YYC3_CLI/`** - CLI工具详细文档
- **`grafana/`** - 监控配置文档

## 🎯 核心文件功能说明

### 智能运维脚本

- **`yyc3-smart-ops.sh`** - 全局智能运维监控
- **`yyc3-error-fixer.sh`** - 自动化错误检测修复
- **`yyc3-ai.sh`** - AI服务管理

### 构建部署文件

- **`docker-compose.yml`** - 容器化部署配置
- **`build.sh`** - 项目构建脚本
- **`deploy.sh`** - 部署管理脚本

### 配置管理文件

- **`tsconfig.json`** - TypeScript编译配置
- **`.eslintrc.js`** - 代码规范检查
- **`commitlint.config.js`** - 提交消息规范

## 📊 项目规模统计

- **总文件数**: 156个文件
- **目录数**: 27个主要目录
- **脚本文件**: 约80个Shell脚本
- **配置文件**: 约40个配置文件
- **文档文件**: 约25个文档文件

## 🔄 文件维护建议

### 需要清理的文件

1. **重复文件**:
   - `yyc3_project.md` (与`yyc3-project.md`重复)

2. **命名不规范文件**:
   - `yyc3-.sh` (建议重命名为`yyc3-base.sh`)

### 建议优化的结构

1. **统一脚本命名规范**
2. **合并相似功能脚本**
3. **完善文档结构**

---

**文档版本**: 1.1.0
**生成时间**: 2025-02-01
**维护团队**: YYC³开发团队
