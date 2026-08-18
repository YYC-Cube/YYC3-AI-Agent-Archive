#!/bin/bash
set -e # 遇到错误立即退出

# ===================== 核心配置（增量更新专属）=====================
# 团队专属配置
TEAM_NAME="yyc3"
ADMIN_USER="@YYC-Cube"
DEVOPS_USER="@YYC-Cube"
CORE_LEAD_USER="@YYC-Cube"

# 增量更新模式：--force 强制覆盖所有文件；无参数则交互式确认
FORCE_UPDATE=false
if [ "$1" = "--force" ]; then
  FORCE_UPDATE=true
  echo "⚠️  已启用强制覆盖模式，所有配置文件将被更新！"
fi

# 颜色输出（提升交互体验）
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 增量更新核心函数：检查文件是否存在，按需覆盖
write_file_if_needed() {
  local FILE_PATH=$1
  local CONTENT=$(cat) # 读取标准输入作为文件内容

  # 检查文件是否存在
  if [ -f "$FILE_PATH" ]; then
    if [ "$FORCE_UPDATE" = true ]; then
      echo -e "${YELLOW}🔄 强制覆盖文件：$FILE_PATH${NC}"
      echo "$CONTENT" > "$FILE_PATH"
    else
      # 交互式确认
      read -p "📄 文件 $FILE_PATH 已存在，是否覆盖？(y/N) " -n 1 -r
      echo
      if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${GREEN}✅ 覆盖文件：$FILE_PATH${NC}"
        echo "$CONTENT" > "$FILE_PATH"
      else
        echo -e "${YELLOW}⏭️  跳过文件：$FILE_PATH${NC}"
      fi
    fi
  else
    # 文件不存在，直接创建
    echo -e "${GREEN}📝 创建新文件：$FILE_PATH${NC}"
    echo "$CONTENT" > "$FILE_PATH"
  fi
}

# ===================== 执行流程 =====================
# 步骤1：创建所有必要目录（已存在则跳过，不影响）
echo -e "\n${GREEN}===== 1. 确保目录结构完整 ====="
mkdir -p .vscode .husky .github/workflows .git-hooks
echo -e "✅ 目录检查完成${NC}"

# ------------------------------ VSCode全量配置（增量更新）------------------------------
echo -e "\n${GREEN}===== 2. 增量更新VSCode配置 ====${NC}"

# .vscode/extensions.json
cat << EOF | write_file_if_needed .vscode/extensions.json
{
  "recommendations": [
    "esbenp.prettier-vscode",
    "dbaeumer.vscode-eslint",
    "ms-azuretools.vscode-docker",
    "github.vscode-github-actions",
    "gitlab.gitlab-workflow",
    "ms-vscode.vscode-typescript-next",
    "humao.rest-client",
    "ms-vscode.launch-editor"
  ]
}
EOF

# .vscode/settings.json
cat << EOF | write_file_if_needed .vscode/settings.json
{
  // 团队yyc3 编辑器全局设置
  "editor.formatOnSave": true,
  "editor.defaultFormatter": "esbenp.prettier-vscode",
  "editor.codeActionsOnSave": {
    "source.fixAll.eslint": true
  },
  "typescript.format.enable": true,
  "files.eol": "\\n",
  "files.trimTrailingWhitespace": true,
  "files.insertFinalNewline": true,
  // Docker相关
  "docker.enableEnhancedImages": true,
  // Git相关
  "git.enableCommitSigning": false,
  "git.confirmSync": false
}
EOF

# .vscode/launch.json
cat << EOF | write_file_if_needed .vscode/launch.json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "${TEAM_NAME}-应用调试",
      "type": "node",
      "request": "launch",
      "program": "\${workspaceFolder}/src/index.js",
      "cwd": "\${workspaceFolder}",
      "envFile": "\${workspaceFolder}/.env",
      "restart": true,
      "console": "integratedTerminal",
      "internalConsoleOptions": "neverOpen"
    },
    {
      "name": "${TEAM_NAME}-Docker调试",
      "type": "docker",
      "request": "launch",
      "platform": "node",
      "dockerFile": "${workspaceFolder}/Dockerfile",
      "envFile": "\${workspaceFolder}/.env.docker",
      "portMapping": [3000, 8080],
      "sourceMapPathOverrides": {
        "/app/*": "\${workspaceFolder}/*"
      }
    }
  ]
}
EOF

# .vscode/typescript.code-snippets
cat << EOF | write_file_if_needed .vscode/typescript.code-snippets
{
  "YYC3-接口权限校验": {
    "prefix": "yyc3-perm-check",
    "body": [
      "import { checkPermission } from '@/utils/rbac';",
      "",
      "/**",
      " * \$1",
      " * @param userId 用户ID",
      " */",
      "export const \$2 = async (userId: string) => {",
      "  const hasPermission = await checkPermission(userId, '\$3');",
      "  if (!hasPermission) {",
      "    throw new Error('权限不足：${TEAM_NAME}团队权限管控');",
      "  }",
      "  // \$0",
      "};",
      ""
    ],
    "description": "YYC3团队专属 - 接口权限校验模板"
  },
  "YYC3-MCP协同注释": {
    "prefix": "yyc3-mcp-note",
    "body": [
      "/**",
      " * \$1",
      " * MCP协同说明：",
      " * - 权限范围：\$2",
      " * - 适用角色：\$3",
      " * - 团队：${TEAM_NAME}",
      " */"
    ],
    "description": "YYC3团队专属 - MCP协同注释模板"
  }
}
EOF

# .vscode/tasks.json
cat << EOF | write_file_if_needed .vscode/tasks.json
{
  "version": "2.0.0",
  "tasks": [
    {
      "label": "${TEAM_NAME}-启动Docker服务",
      "type": "shell",
      "command": "docker-compose up -d",
      "group": "build",
      "problemMatcher": [],
      "detail": "启动YYC3团队应用+MCP服务"
    },
    {
      "label": "${TEAM_NAME}-代码检查",
      "type": "shell",
      "command": "npm run lint",
      "group": "test",
      "problemMatcher": ["\$eslint-stylish"],
      "detail": "执行ESLint+Prettier检查"
    },
    {
      "label": "${TEAM_NAME}-权限配置校验",
      "type": "shell",
      "command": "node -c rbac.config.js && node -c mcp-roles.json",
      "group": "test",
      "problemMatcher": [],
      "detail": "校验权限配置文件语法"
    }
  ]
}
EOF

# ------------------------------ Git相关全量配置（增量更新）------------------------------
echo -e "\n${GREEN}===== 3. 增量更新Git配置 ====${NC}"

# .gitignore
cat << EOF | write_file_if_needed .gitignore
# 敏感配置（权限/MCP/密钥）- 团队${TEAM_NAME}
.env
.access-keys
.env.permissions.local

# 依赖/构建产物
node_modules/
dist/
build/
coverage/

# 环境/容器相关
.docker/
*.docker-cache
mcp-cache/

# IDE/编辑器
.idea/
.vscode/!.vscode/* # 保留vscode配置，排除缓存
*.swp
*.swo

# 日志/临时文件
logs/
tmp/
*.log

# Git相关
.git-credentials
EOF

# .gitattributes
cat << EOF | write_file_if_needed .gitattributes
# 团队${TEAM_NAME} Git跨平台格式统一
* text=auto eol=lf

# 二进制文件不转换
*.png binary
*.jpg binary
*.gif binary

# 配置文件强制LF
*.js text eol=lf
*.ts text eol=lf
*.json text eol=lf
*.yml text eol=lf
*.sh text eol=lf
Dockerfile text eol=lf

# 文档文件保留CRLF（Windows兼容）
*.md text eol=crlf
*.txt text eol=crlf
EOF

# .gitconfig
cat << EOF | write_file_if_needed .gitconfig
[user]
  name = ${TEAM_NAME}-Team
  email = ${TEAM_NAME}@example.com
[core]
  autocrlf = input
  safecrlf = true
[branch]
  protect = main
[push]
  default = simple
[hooks]
  path = .git-hooks
# 禁止强制推送到主分支
[alias]
  nopush = push --no-force
EOF

# branch-protection.yml
cat << EOF | write_file_if_needed branch-protection.yml
# 团队${TEAM_NAME} Git分支保护规则（GitHub/GitLab通用）
branch: main
protection:
  enabled: true
  enforce_admins: true
  required_pull_request_reviews:
    required_approving_review_count: 1
    dismiss_stale_reviews: true
    require_code_owner_reviews: true
  required_status_checks:
    strict: true
    contexts:
      - "lint-check"
      - "type-check"
      - "docker-build"
  restrictions:
    users:
      - ${ADMIN_USER}
      - ${DEVOPS_USER}
    teams:
      - ${TEAM_NAME}-admin
EOF

# husky.config.js
cat << EOF | write_file_if_needed husky.config.js
module.exports = {
  hooks: {
    'pre-commit': 'lint-staged',
    'commit-msg': 'commitlint -E HUSKY_GIT_PARAMS',
    'pre-push': 'npm run test && npm run build'
  }
};
EOF

# lint-staged.config.js
cat << EOF | write_file_if_needed lint-staged.config.js
module.exports = {
  // 团队${TEAM_NAME} 仅校验提交的文件
  '*.{js,ts,jsx,tsx}': [
    'eslint --fix',
    'prettier --write'
  ],
  '*.{json,yml,yaml,md}': [
    'prettier --write'
  ],
  '*.{js,ts}': [
    'node -c' // 语法校验
  ],
  'rbac.config.js|mcp-roles.json': [
    'node -c' // 权限配置文件专属校验
  ]
};
EOF

# .husky/pre-commit（需添加执行权限）
cat << EOF | write_file_if_needed .husky/pre-commit
#!/usr/bin/env sh
. "\$(dirname -- "\$0")/_/husky.sh"

# 团队${TEAM_NAME} 提交前校验
npx lint-staged
npx tsc --noEmit --project tsconfig.json
node -c rbac.config.js
node -c mcp-roles.json
EOF
# 确保钩子文件有执行权限（无论是否覆盖）
if [ -f ".husky/pre-commit" ]; then
  chmod +x .husky/pre-commit
  echo -e "${GREEN}✅ 已为.husky/pre-commit添加执行权限${NC}"
fi

# .husky/commit-msg
cat << EOF | write_file_if_needed .husky/commit-msg
#!/usr/bin/env sh
. "\$(dirname -- "\$0")/_/husky.sh"

# 团队${TEAM_NAME} 提交信息校验
npx --no -- commitlint --edit "\$1"
EOF
if [ -f ".husky/commit-msg" ]; then
  chmod +x .husky/commit-msg
  echo -e "${GREEN}✅ 已为.husky/commit-msg添加执行权限${NC}"
fi

# .git-hooks/pre-push
cat << EOF | write_file_if_needed .git-hooks/pre-push
#!/bin/bash
# 团队${TEAM_NAME} 推送前校验Docker构建
echo "===== 校验Docker镜像构建 ====="
docker build -t ${TEAM_NAME}-app:temp . > /dev/null 2>&1
if [ \$? -ne 0 ]; then
  echo "❌ Docker构建失败，禁止推送！"
  exit 1
fi
# 删除临时镜像
docker rmi ${TEAM_NAME}-app:temp > /dev/null 2>&1
echo "✅ Docker构建校验通过"
exit 0
EOF
if [ -f ".git-hooks/pre-push" ]; then
  chmod +x .git-hooks/pre-push
  echo -e "${GREEN}✅ 已为.git-hooks/pre-push添加执行权限${NC}"
fi

# commitlint.config.js
cat << EOF | write_file_if_needed commitlint.config.js
module.exports = {
  extends: ['@commitlint/config-conventional'],
  rules: {
    'type-enum': [
      2,
      'always',
      ['feat', 'fix', 'docs', 'style', 'refactor', 'test', 'chore', 'perm', 'mcp']
    ],
    'subject-max-length': [2, 'always', 50],
    'type-case': [2, 'always', 'lower-case']
  }
};
EOF

# CODEOWNERS
cat << EOF | write_file_if_needed CODEOWNERS
# 团队${TEAM_NAME} 代码所有权规则
# 核心权限配置文件仅管理员可修改
/rbac.config.js ${ADMIN_USER}
/mcp-roles.json ${ADMIN_USER}
/access-control.json ${ADMIN_USER}

# Docker配置由运维审核
/Dockerfile ${DEVOPS_USER}
/docker-compose*.yml ${DEVOPS_USER}

# 业务代码由核心负责人审核
/src/core/ ${CORE_LEAD_USER}
/src/payment/ ${CORE_LEAD_USER}

# 根目录配置文件需管理员审核
/*.config.js ${ADMIN_USER}
/*.yml ${ADMIN_USER}
EOF

# ------------------------------ 代码规范全量配置（增量更新）------------------------------
echo -e "\n${GREEN}===== 4. 增量更新代码规范配置 ====${NC}"

# .editorconfig
cat << EOF | write_file_if_needed .editorconfig
# 团队${TEAM_NAME} 跨编辑器格式规范
root = true

[*]
charset = utf-8
end_of_line = lf
indent_size = 2
indent_style = space
insert_final_newline = true
trim_trailing_whitespace = true

[*.md]
trim_trailing_whitespace = false

[*.{yml,yaml}]
indent_size = 2

[Dockerfile*]
indent_size = 4
indent_style = space
EOF

# .prettierrc
cat << EOF | write_file_if_needed .prettierrc
{
  "semi": true,
  "singleQuote": true,
  "tabWidth": 2,
  "trailingComma": "es5",
  "printWidth": 100,
  "endOfLine": "lf",
  "arrowParens": "avoid",
  "ignorePath": ".gitignore"
}
EOF

# .eslintignore
cat << EOF | write_file_if_needed .eslintignore
# 团队${TEAM_NAME} ESLint忽略规则
node_modules/
dist/
build/
coverage/
*.config.js
*.min.js
Dockerfile*
*.yml
*.md
EOF

# .eslintrc.js
cat << EOF | write_file_if_needed .eslintrc.js
module.exports = {
  env: {
    browser: true,
    es2021: true,
    node: true,
    jest: true
  },
  extends: [
    'eslint:recommended',
    'plugin:@typescript-eslint/recommended',
    'prettier'
  ],
  parser: '@typescript-eslint/parser',
  parserOptions: {
    ecmaVersion: 'latest',
    sourceType: 'module'
  },
  plugins: ['@typescript-eslint', 'prettier'],
  rules: {
    'prettier/prettier': 'error',
    'no-console': process.env.NODE_ENV === 'production' ? 'warn' : 'off',
    'no-debugger': process.env.NODE_ENV === 'production' ? 'warn' : 'off',
    '@typescript-eslint/no-unused-vars': ['error', { argsIgnorePattern: '^_' }],
    'no-unused-vars': 'off'
  },
  globals: {
    // 团队${TEAM_NAME} 全局变量
    YYCTEAM: 'readonly'
  }
};
EOF

# tsconfig.json
cat << EOF | write_file_if_needed tsconfig.json
{
  "compilerOptions": {
    "target": "ES2020",
    "module": "CommonJS",
    "outDir": "./dist",
    "rootDir": "./src",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "resolveJsonModule": true,
    "declaration": true,
    "sourceMap": true
  },
  "include": [
    "src/**/*",
    "rbac.config.js",
    "mcp.config.js"
  ],
  "exclude": [
    "node_modules",
    "dist",
    "test/**/*.spec.ts"
  ]
}
EOF

# ------------------------------ Docker全量配置（增量更新）------------------------------
echo -e "\n${GREEN}===== 5. 增量更新Docker配置 ====${NC}"

# .dockerignore
cat << EOF | write_file_if_needed .dockerignore
# 团队${TEAM_NAME} Docker构建忽略规则
.git/
.gitignore
node_modules/
dist/
coverage/
logs/
tmp/
.env
.access-keys
.env.permissions.local
*.log
.git-hooks/
.husky/
.vscode/
EOF

# Dockerfile
cat << EOF | write_file_if_needed Dockerfile
# 团队${TEAM_NAME} 应用镜像构建规则
FROM node:18-alpine AS base
WORKDIR /app
USER node

# 依赖安装阶段
FROM base AS deps
COPY --chown=node:node package.json package-lock.json ./
RUN npm ci --only=production

# 构建阶段
FROM base AS builder
COPY --chown=node:node package.json package-lock.json ./
RUN npm ci
COPY --chown=node:node . .
RUN npm run build

# 运行阶段（最小镜像）
FROM base AS runner
COPY --chown=node:node --from=deps /app/node_modules ./node_modules
COPY --chown=node:node --from=builder /app/dist ./dist
COPY --chown=node:node --from=builder /app/package.json ./
COPY --chown=node:node .env.docker ./

# 权限限制
RUN chmod 600 .env.docker
EXPOSE 3000
CMD ["node", "dist/index.js"]
EOF

# Dockerfile.perms
cat << EOF | write_file_if_needed Dockerfile.perms
# 团队${TEAM_NAME} 容器权限拆分配置
# 该文件需在主Dockerfile中通过COPY引入
# 非root用户配置
RUN addgroup -S ${TEAM_NAME}-group && adduser -S ${TEAM_NAME}-user -G ${TEAM_NAME}-group
USER ${TEAM_NAME}-user

# 目录权限配置
RUN mkdir -p /app/logs /app/tmp && chown -R ${TEAM_NAME}-user:${TEAM_NAME}-group /app
RUN chmod 700 /app/logs /app/tmp
RUN chmod 644 /app/dist/**/*.js
RUN chmod 600 /app/*.config.js

# 禁止sudo/root操作
RUN touch /etc/sudoers.d/${TEAM_NAME} && echo "${TEAM_NAME}-user ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/${TEAM_NAME}
RUN chmod 0440 /etc/sudoers.d/${TEAM_NAME}
EOF

# docker-compose.yml
cat << EOF | write_file_if_needed docker-compose.yml
version: '3.8'
services:
  # 应用服务（非root运行）- 团队${TEAM_NAME}
  app:
    build:
      context: .
      dockerfile: Dockerfile
    user: "1000:1000" # 非root用户运行（权限管控）
    ports:
      - "3000:3000"
    env_file:
      - .env.docker
      - .env.permissions
    volumes:
      - ./src:/app/src:ro # 业务目录仅读（权限限制）
    depends_on:
      - mcp-service
    networks:
      - ${TEAM_NAME}-network
    restart: unless-stopped

  # MCP智能协同服务 - 团队${TEAM_NAME}
  mcp-service:
    image: mcp-smart-code:latest
    ports:
      - "8080:8080"
    env_file:
      - .env.docker
    volumes:
      - ./mcp.config.js:/app/mcp.config.js:ro
    networks:
      - ${TEAM_NAME}-network

networks:
  ${TEAM_NAME}-network:
    driver: bridge
EOF

# docker-compose.permissions.yml
cat << EOF | write_file_if_needed docker-compose.permissions.yml
version: '3.8'
services:
  # 团队${TEAM_NAME} 容器权限专属配置
  app:
    user: "${TEAM_NAME}-user:${TEAM_NAME}-group"
    cap_drop:
      - ALL # 移除所有特权
    security_opt:
      - no-new-privileges:true
    read_only: true # 只读文件系统
    tmpfs:
      - /app/tmp:size=100M,uid=1000,gid=1000 # 临时可写目录
    volumes:
      - ./logs:/app/logs:rw
      - ./src:/app/src:ro
    environment:
      - NODE_ENV=production
      - RBAC_ENFORCE=true

  mcp-service:
    user: "1000:1000"
    cap_drop:
      - ALL
    security_opt:
      - no-new-privileges:true
    read_only: true
    tmpfs:
      - /app/tmp:size=50M,uid=1000,gid=1000
EOF

# .docker-permissions
cat << EOF | write_file_if_needed .docker-permissions
# 团队${TEAM_NAME} Docker资源访问白名单
# 允许访问的宿主机目录
ALLOWED_HOST_DIRS=/var/log/${TEAM_NAME},/app/src
# 允许执行的系统命令
ALLOWED_COMMANDS=node,npm,git,cat,ls,grep
# 允许连接的网络地址
ALLOWED_NETWORKS=127.0.0.1,172.17.0.0/16
# 禁止挂载的目录
DENY_MOUNT_DIRS=/root,/etc,/var/run
EOF

# ------------------------------ MCP&权限全量配置（增量更新）------------------------------
echo -e "\n${GREEN}===== 6. 增量更新MCP&权限配置 ====${NC}"

# .env.example
cat << EOF | write_file_if_needed .env.example
# 团队${TEAM_NAME} 环境变量示例（仅含键，无敏感值）
# MCP配置
MCP_SERVER_URL=http://localhost:8080
MCP_API_KEY=your_mcp_api_key_here
MCP_ROLE=developer

# 应用权限配置
RBAC_ENFORCE=true
ADMIN_WHITELIST=${ADMIN_USER}

# 数据库配置
DB_HOST=localhost
DB_USER=${TEAM_NAME}_dev
DB_PASSWORD=your_db_password_here
EOF

# .env.docker
cat << EOF | write_file_if_needed .env.docker
# 团队${TEAM_NAME} Docker专属环境变量
NODE_ENV=development
PORT=3000
MCP_SERVER_URL=http://mcp-service:8080
MCP_API_KEY=docker_mcp_api_key_${TEAM_NAME}
RBAC_ENFORCE=false
DB_HOST=db
DB_USER=${TEAM_NAME}_docker
DB_PASSWORD=docker_db_password_${TEAM_NAME}
EOF

# .env.permissions
cat << EOF | write_file_if_needed .env.permissions
# 团队${TEAM_NAME} 权限相关环境变量
# RBAC配置
RBAC_ENFORCE=true
RBAC_CACHE_TTL=3600
ADMIN_ROLE_ID=1
DEVELOPER_ROLE_ID=2
TESTER_ROLE_ID=3

# MCP权限配置
MCP_PERM_CHECK=true
MCP_DENY_SENSITIVE_FILES=true
MCP_AUDIT_LOG=true

# 安全配置
JWT_SECRET=your_jwt_secret_${TEAM_NAME}
JWT_EXPIRES_IN=8h
EOF

# .access-keys（空文件，仅创建/提示）
if [ ! -f ".access-keys" ]; then
  echo -e "${GREEN}📝 创建敏感密钥文件：.access-keys${NC}"
  echo "# 团队${TEAM_NAME} 第三方服务密钥（需加入.gitignore）" > .access-keys
else
  echo -e "${YELLOW}⏭️  跳过敏感文件：.access-keys（避免覆盖密钥）${NC}"
fi

# .mcpignore
cat << EOF | write_file_if_needed .mcpignore
# 团队${TEAM_NAME} MCP分析忽略规则
node_modules/
dist/
build/
logs/
tmp/
.env*
.access-keys
*.log
Dockerfile*
*.dockerignore
EOF

# mcp.config.js
cat << EOF | write_file_if_needed mcp.config.js
// 团队${TEAM_NAME} MCP核心配置
module.exports = {
  // 服务连接
  server: {
    url: process.env.MCP_SERVER_URL || 'http://localhost:8080',
    apiKey: process.env.MCP_API_KEY || '',
    timeout: 10000
  },
  // 权限管控
  permissions: {
    role: process.env.MCP_ROLE || 'developer',
    allowPaths: ['/src/**', '/test/**'],
    denyPaths: ['.env', '.access-keys', 'rbac.config.js'],
    audit: true // 开启操作审计
  },
  // 智能协同策略
  strategy: {
    codeCompletion: true,
    codeReview: true,
    testGenerate: true,
    permissionCheck: true // 基于RBAC的权限补全
  },
  // 缓存配置
  cache: {
    enable: true,
    dir: './mcp-cache',
    ttl: 3600
  }
};
EOF

# mcp-roles.json
cat << EOF | write_file_if_needed mcp-roles.json
{
  "team": "${TEAM_NAME}",
  "roles": {
    "developer": {
      "name": "${TEAM_NAME}-普通开发者",
      "permissions": [
        "mcp:code-completion",
        "mcp:lint-check",
        "mcp:test-generate"
      ],
      "accessPaths": ["/src/**", "/test/**"],
      "denyPaths": [".env", ".access-keys", "rbac.config.js"]
    },
    "admin": {
      "name": "${TEAM_NAME}-管理员",
      "permissions": [
        "mcp:config-modify",
        "mcp:audit-view",
        "mcp:role-manage"
      ],
      "accessPaths": ["**"],
      "denyPaths": []
    },
    "tester": {
      "name": "${TEAM_NAME}-测试人员",
      "permissions": ["mcp:test-generate", "mcp:lint-check"],
      "accessPaths": ["/test/**", "/src/**"],
      "denyPaths": ["rbac.config.js", "mcp-roles.json"]
    }
  }
}
EOF

# mcp-access-rules.json
cat << EOF | write_file_if_needed mcp-access-rules.json
{
  "team": "${TEAM_NAME}",
  "rules": [
    {
      "id": "rule-001",
      "name": "禁止访问敏感配置文件",
      "pattern": "\\.(env|access-keys|permissions)\\.*",
      "action": "deny",
      "roles": ["all"]
    },
    {
      "id": "rule-002",
      "name": "仅管理员可修改MCP配置",
      "pattern": "mcp\\.(config|roles|access-rules)\\.js(on)?",
      "action": "allow",
      "roles": ["admin"]
    },
    {
      "id": "rule-003",
      "name": "仅管理员可修改RBAC配置",
      "pattern": "rbac\\.config\\.js|access-control\\.json",
      "action": "allow",
      "roles": ["admin"]
    },
    {
      "id": "rule-004",
      "name": "所有角色可访问业务代码",
      "pattern": "src/.*\\.(js|ts|jsx|tsx)",
      "action": "allow",
      "roles": ["developer", "tester", "admin"]
    }
  ]
}
EOF

# mcp-audit-log.yml
cat << EOF | write_file_if_needed mcp-audit-log.yml
# 团队${TEAM_NAME} MCP操作审计规则
log:
  enable: true
  level: info
  format: json
  path: ./logs/mcp-audit.log
  retention: 30d # 日志保留30天
  rotation: daily # 按天分割

# 审计内容
audit:
  include:
    - user: true # 记录操作用户
    - action: true # 记录操作类型（补全/修改/审核）
    - resource: true # 记录访问的资源
    - timestamp: true # 记录时间
    - ip: true # 记录IP
  exclude:
    - paths:
        - /test/** # 排除测试目录审计
        - /tmp/**

# 告警规则
alert:
  enable: true
  thresholds:
    - action: "deny" # 权限拒绝操作
      count: 5 # 5分钟内5次
      timeWindow: 5m
      notify: ${ADMIN_USER}
EOF

# rbac.config.js
cat << EOF | write_file_if_needed rbac.config.js
// 团队${TEAM_NAME} RBAC权限核心配置
module.exports = {
  team: "${TEAM_NAME}",
  roles: ["guest", "developer", "tester", "admin"],
  permissions: [
    { name: "api:user:read", resource: "/api/user" },
    { name: "api:user:write", resource: "/api/user" },
    { name: "config:permissions:modify", resource: "/config/permissions" },
    { name: "mcp:audit:view", resource: "/mcp/audit-logs" }
  ],
  rolePermissions: {
    guest: ["api:user:read"],
    developer: ["api:user:read", "api:user:write"],
    tester: ["api:user:read"],
    admin: ["**"]
  },
  envRules: {
    development: { enforce: false },
    production: { enforce: true }
  }
};
EOF

# access-control.json
cat << EOF | write_file_if_needed access-control.json
{
  "team": "${TEAM_NAME}",
  "policies": [
    {
      "policyId": "policy-001",
      "name": "应用接口权限策略",
      "resources": ["/api/**"],
      "actions": ["GET", "POST", "PUT", "DELETE"],
      "roles": {
        "admin": ["*"],
        "developer": ["GET", "POST"],
        "tester": ["GET"],
        "guest": ["GET:/api/public/**"]
      }
    },
    {
      "policyId": "policy-002",
      "name": "MCP协同权限策略",
      "resources": ["/mcp/**"],
      "actions": ["READ", "WRITE", "CONFIG"],
      "roles": {
        "admin": ["*"],
        "developer": ["READ", "WRITE"],
        "tester": ["READ"],
        "guest": []
      }
    },
    {
      "policyId": "policy-003",
      "name": "配置文件修改策略",
      "resources": ["/*.config.js", "/*.json"],
      "actions": ["WRITE"],
      "roles": {
        "admin": ["*"],
        "developer": [],
        "tester": [],
        "guest": []
      }
    }
  ]
}
EOF

# ------------------------------ CI/CD配置（增量更新）------------------------------
echo -e "\n${GREEN}===== 7. 增量更新CI/CD权限配置 ====${NC}"

# .github/workflows/permissions.yml
cat << EOF | write_file_if_needed .github/workflows/permissions.yml
name: ${TEAM_NAME}-Permissions-Check
on:
  pull_request:
    branches: [main, develop]
  push:
    branches: [main, develop]

permissions:
  contents: read # 仅读取代码
  pull-requests: write # 可评论PR
  actions: read # 仅读取Action配置
  checks: write # 可写入检查结果
  deployments: none # 禁止部署

jobs:
  permission-check:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Install dependencies
        run: npm install
      - name: Lint permission configs
        run: node -c rbac.config.js && node -c mcp-roles.json
      - name: Check CODEOWNERS
        run: grep -q "${ADMIN_USER}" CODEOWNERS || (echo "CODEOWNERS配置错误" && exit 1)
      - name: Docker build check
        run: docker build -t ${TEAM_NAME}-ci:temp .
EOF

# ------------------------------ 项目说明（增量更新）------------------------------
echo -e "\n${GREEN}===== 8. 增量更新README.md ====${NC}"

cat << EOF | write_file_if_needed README.md
# ${TEAM_NAME} 项目配置说明
## 项目简介
本项目为${TEAM_NAME}团队定制的应用开发模板，集成Git、Docker、MCP智能协同、RBAC权限管控等能力，提升团队协同效率。

## 快速开始
### 1. 初始化配置
\`\`\`bash
# 执行初始化脚本（首次/增量）
chmod +x init-yyc3-project-incremental.sh

# 交互式增量更新（推荐）
./init-yyc3-project-incremental.sh

# 强制覆盖所有配置（谨慎使用）
./init-yyc3-project-incremental.sh --force

# 安装依赖
npm install
npm install husky lint-staged @commitlint/cli @commitlint/config-conventional --save-dev

# 启用husky
npx husky install
\`\`\`

### 2. 启动服务
\`\`\`bash
# 本地启动
npm run dev

# Docker启动
docker-compose up -d
\`\`\`

## 权限管控说明
- 管理员账号：${ADMIN_USER}
- 运维账号：${DEVOPS_USER}
- 核心负责人：${CORE_LEAD_USER}
- 敏感配置文件（.env、.access-keys）禁止提交到Git

## MCP智能协同
- MCP服务地址：http://localhost:8080
- 角色权限：参考mcp-roles.json
- 审计日志：参考mcp-audit-log.yml

## 代码规范
- 格式化：Prettier（.prettierrc）
- 代码检查：ESLint（.eslintrc.js）
- 提交规范：commitlint（commitlint.config.js）

## 增量更新说明
- 执行脚本时默认交互式确认覆盖，避免误操作
- 如需强制覆盖所有文件，执行：\`./init-yyc3-project-incremental.sh --force\`
- 敏感文件（.access-keys、.env）不会被自动覆盖
EOF

# 敏感文件保护（.env 仅创建空文件，不覆盖）
if [ ! -f ".env" ]; then
  echo -e "${GREEN}📝 创建本地环境变量文件：.env${NC}"
  echo "# 团队${TEAM_NAME} 本地敏感环境变量（请勿提交）" > .env
else
  echo -e "${YELLOW}⏭️  跳过敏感文件：.env（避免覆盖密钥）${NC}"
fi

# ===================== 完成提示 =====================
echo -e "\n${GREEN}===== ✅ ${TEAM_NAME}团队配置文件增量更新完成！=====${NC}"
echo -e "${YELLOW}💡 关键提醒：${NC}"
echo "1. 敏感文件（.env、.access-keys）未被自动覆盖，需手动维护"
echo "2. 若执行了覆盖操作，建议检查自定义配置是否丢失"
echo "3. 后续更新配置只需重新执行本脚本即可"
