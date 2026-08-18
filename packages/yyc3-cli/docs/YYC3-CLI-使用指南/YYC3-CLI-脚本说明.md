---
@file: 脚本说明.md
@description: YYC³-CLI 脚本说明.md
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

你需要我为yyc3团队编写适配“一人多机/多环境/多智能体”、结合AI智能编程协同的**企业级项目从0到可用核心脚本清单**，包含每个分类的1-2个可直接复用的脚本模板，所有脚本均贴合团队场景、适配多环境/多机/AI协同，且便捷实用。

以下是按“从0到可用”生命周期划分的核心脚本清单，每个脚本都包含完整代码、使用说明和适配要点：

---

## 一、项目初始化脚本（基础骨架搭建）

### 1. 全量配置初始化脚本（init-project.sh）

**核心用途**：一键搭建yyc3团队项目基础骨架，适配多环境模板、AI智能体配置，支持增量更新。

```bash
#!/bin/bash
set -e
# 适配多环境：通过参数指定环境（dev/test/prod）
ENV=${1:-dev}
TEAM_NAME="yyc3"
ADMIN_USER="@YYC-Cube"
# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

# 步骤1：创建目录结构（多环境兼容）
echo -e "${GREEN}===== 1. 创建${ENV}环境目录结构 ====${NC}"
mkdir -p .vscode .husky .github/workflows scripts/{env,ai,deploy} logs/${ENV} tmp/${ENV}

# 步骤2：生成环境专属配置模板（多环境隔离）
echo -e "${GREEN}===== 2. 生成${ENV}环境配置 ====${NC}"
cat > .env.${ENV} << EOF
# YYC3团队 ${ENV} 环境配置
TEAM_NAME=${TEAM_NAME}
ENV=${ENV}
# AI智能体配置（多智能体适配）
AI_AGENT_TYPE="MCP" # 可切换为Copilot/Tongyi
AI_AGENT_URL=http://localhost:8080/${ENV}
AI_AGENT_API_KEY=yyc3_${ENV}_api_key
# 数据库配置（多机适配）
DB_HOST=$(if [ "${ENV}" = "prod" ]; then echo "prod-db.yyc3.com"; else echo "localhost"; fi)
DB_USER=yyc3_${ENV}
EOF

# 步骤3：生成AI智能体协同配置（多智能体兼容）
cat > scripts/ai/ai-config.sh << EOF
#!/bin/bash
# YYC3团队 AI智能体调用脚本（多智能体适配）
AI_AGENT=\${AI_AGENT_TYPE:-MCP}
case \$AI_AGENT in
  MCP)
    echo "调用MCP智能体：\${AI_AGENT_URL}"
    curl -X POST \${AI_AGENT_URL}/code-completion -H "X-API-KEY: \${AI_AGENT_API_KEY}" -d @-
    ;;
  Copilot)
    echo "调用Copilot智能体"
    # Copilot接口调用逻辑
    ;;
  Tongyi)
    echo "调用通义千问智能体"
    # 通义千问接口调用逻辑
    ;;
esac
EOF
chmod +x scripts/ai/ai-config.sh

# 步骤4：生成基础.gitignore（多环境敏感文件隔离）
cat > .gitignore << EOF
# 多环境敏感文件
.env.*
!/.env.example
# AI缓存
ai-cache/
# 多机部署临时文件
tmp/
logs/
EOF

echo -e "${GREEN}===== YYC3团队${ENV}环境初始化完成 =====${NC}"
```

**使用说明**：

- 开发环境：`./init-project.sh dev`
- 生产环境：`./init-project.sh prod`
- 适配要点：支持多环境参数、多智能体切换、多机数据库地址自动适配。

### 2. 增量配置更新脚本（update-config.sh）

**核心用途**：迭代升级时仅更新变更的配置，不覆盖自定义内容（适配一人维护多版本）。

```bash
#!/bin/bash
set -e
ENV=${1:-dev}
FORCE=${2:-false}
TEAM_NAME="yyc3"

# 增量更新函数（避免覆盖）
update_file() {
  FILE_PATH=\$1
  CONTENT=\$(cat)
  if [ -f "\$FILE_PATH" ] && [ "\$FORCE" != "force" ]; then
    read -p "文件 \$FILE_PATH 已存在，是否覆盖？(y/N) " -n 1 -r
    echo
    if ! [[ \$REPLY =~ ^[Yy]$ ]]; then
      echo "跳过：\$FILE_PATH"
      return
    fi
  fi
  echo "\$CONTENT" > \$FILE_PATH
  echo "更新完成：\$FILE_PATH"
}

# 更新AI智能体配置（仅更新新增的智能体类型）
cat << EOF | update_file scripts/ai/ai-config.sh
#!/bin/bash
# YYC3团队 AI智能体调用脚本（多智能体适配，已升级支持Kimi）
AI_AGENT=\${AI_AGENT_TYPE:-MCP}
case \$AI_AGENT in
  MCP)
    echo "调用MCP智能体：\${AI_AGENT_URL}"
    curl -X POST \${AI_AGENT_URL}/code-completion -H "X-API-KEY: \${AI_AGENT_API_KEY}" -d @-
    ;;
  Copilot)
    echo "调用Copilot智能体"
    ;;
  Tongyi)
    echo "调用通义千问智能体"
    ;;
  Kimi)
    echo "调用Kimi智能体"
    # Kimi接口调用逻辑
    ;;
esac
EOF

# 更新环境配置（新增监控地址）
cat << EOF | update_file .env.${ENV}
# YYC3团队 ${ENV} 环境配置（已升级）
TEAM_NAME=${TEAM_NAME}
ENV=${ENV}
AI_AGENT_TYPE="MCP"
AI_AGENT_URL=http://localhost:8080/${ENV}
AI_AGENT_API_KEY=yyc3_${ENV}_api_key
DB_HOST=$(if [ "${ENV}" = "prod" ]; then echo "prod-db.yyc3.com"; else echo "localhost"; fi)
DB_USER=yyc3_${ENV}
# 新增：多机监控配置
MONITOR_HOST=$(if [ "${ENV}" = "prod" ]; then echo "prod-monitor.yyc3.com"; else echo "localhost:9090"; fi)
EOF

echo "===== YYC3团队${ENV}环境配置增量更新完成 ====="
```

**使用说明**：

- 交互式更新：`./update-config.sh dev`
- 强制覆盖：`./update-config.sh prod force`
- 适配要点：增量更新、多环境兼容、保留自定义配置。

---

## 二、环境配置与隔离脚本（多机/多环境一致性）

### 1. 多机环境同步脚本（sync-env.sh）

**核心用途**：将本地环境配置同步到远程服务器（一人维护多机），避免逐机手动配置。

```bash
#!/bin/bash
set -e
# 多机配置：支持批量服务器列表
SERVERS=("dev-server.yyc3.com" "test-server.yyc3.com")
ENV=${1:-dev}
TEAM_NAME="yyc3"
USER="yyc3-admin"

echo "===== 同步${ENV}环境配置到多机：${SERVERS[*]} ====="
for SERVER in "\${SERVERS[@]}"; do
  echo -e "\n📡 同步到服务器：\$SERVER"
  # 1. 同步环境配置文件
  scp .env.${ENV} \${USER}@\${SERVER}:/opt/yyc3-project/.env.${ENV}
  # 2. 同步AI智能体配置脚本
  scp scripts/ai/ai-config.sh \${USER}@\${SERVER}:/opt/yyc3-project/scripts/ai/
  # 3. 远程执行环境初始化
  ssh \${USER}@\${SERVER} "cd /opt/yyc3-project && chmod +x scripts/ai/ai-config.sh && mkdir -p logs/${ENV} tmp/${ENV}"
  echo -e "✅ \$SERVER 同步完成"
done

echo -e "\n===== 所有服务器环境同步完成 ====="
```

**使用说明**：

- 同步开发环境到多机：`./sync-env.sh dev`
- 适配要点：批量多机同步、SSH免密登录适配、环境隔离。

### 2. 环境依赖检查脚本（check-env.sh）

**核心用途**：检查本地/远程服务器的环境依赖（如Node/Docker/AI智能体），适配多环境。

```bash
#!/bin/bash
set -e
ENV=${1:-dev}
# 多环境依赖清单
declare -A DEPS=(
  ["dev"]="node>=18 docker>=20 git>=2.30"
  ["test"]="node>=18 docker>=20 kubectl>=1.24"
  ["prod"]="node>=18 docker>=20 kubectl>=1.24 sshpass>=1.06"
)

echo "===== 检查${ENV}环境依赖 ====="
# 解析依赖清单
IFS=' ' read -ra DEPS_LIST <<< "\${DEPS[$ENV]}"
for DEP in "\${DEPS_LIST[@]}"; do
  NAME=\$(echo \$DEP | cut -d'>=' -f1)
  MIN_VER=\$(echo \$DEP | cut -d'>=' -f2)
  
  # 检查是否安装
  if ! command -v \$NAME &> /dev/null; then
    echo -e "${RED}❌ \$NAME 未安装（${ENV}环境必需）${NC}"
    exit 1
  fi
  
  # 检查版本
  VER=\$(\$NAME --version 2>&1 | head -n1 | grep -oE '[0-9]+\.[0-9]+(\.[0-9]+)?' | head -n1)
  if [ "\$(echo -e "\$VER\n\$MIN_VER" | sort -V | head -n1)" != "\$MIN_VER" ]; then
    echo -e "${RED}❌ \$NAME 版本过低（当前：\$VER，要求：>=${MIN_VER}）${NC}"
    exit 1
  fi
  
  echo -e "${GREEN}✅ \$NAME \$VER（满足>=${MIN_VER}）${NC}"
done

# 检查AI智能体连通性（多智能体适配）
AI_AGENT_URL=\$(grep AI_AGENT_URL .env.${ENV} | cut -d'=' -f2)
if curl -s --head \$AI_AGENT_URL | head -n1 | grep "200 OK" > /dev/null; then
  echo -e "${GREEN}✅ AI智能体 \$AI_AGENT_URL 连通正常${NC}"
else
  echo -e "${YELLOW}⚠️ AI智能体 \$AI_AGENT_URL 无法连通（非阻塞，仅提醒）${NC}"
fi

echo -e "\n===== ${ENV}环境依赖检查通过 ====="
```

**使用说明**：

- 检查开发环境依赖：`./check-env.sh dev`
- 适配要点：多环境依赖差异化检查、AI智能体连通性校验、非阻塞提醒。

---

## 三、AI智能编程协同脚本（多智能体调用/结果校验）

### 1. AI代码生成脚本（ai-code-gen.sh）

**核心用途**：调用多智能体生成业务代码，自动校验语法，适配yyc3团队规范。

```bash
#!/bin/bash
set -e
ENV=${1:-dev}
AI_AGENT=\${2:-MCP}
# 加载环境配置
source .env.${ENV}

# 读取代码生成指令（支持从文件/命令行传入）
PROMPT_FILE=\${3:-prompt.txt}
if [ ! -f "\$PROMPT_FILE" ]; then
  echo "请创建prompt.txt，写入代码生成指令（如：生成yyc3团队用户权限接口）"
  exit 1
fi
PROMPT=\$(cat \$PROMPT_FILE)

echo "===== 调用\$AI_AGENT智能体生成代码 ====="
# 多智能体调用逻辑
case \$AI_AGENT in
  MCP)
    RESPONSE=\$(curl -s -X POST \$AI_AGENT_URL/code-completion \
      -H "X-API-KEY: \$AI_AGENT_API_KEY" \
      -H "Content-Type: application/json" \
      -d "{\"prompt\":\"\$PROMPT\", \"team\":\"\$TEAM_NAME\", \"env\":\"\$ENV\"}")
    ;;
  Tongyi)
    # 通义千问调用逻辑
    RESPONSE=\$(curl -s -X POST https://dashscope.aliyuncs.com/api/v1/services/aigc/text-generation/generation \
      -H "Authorization: Bearer \$AI_AGENT_API_KEY" \
      -H "Content-Type: application/json" \
      -d "{\"model\":\"qwen-turbo\", \"input\":{\"messages\":[{\"role\":\"user\",\"content\":\"\$PROMPT\"}]}}")
    ;;
esac

# 提取代码内容（适配AI返回格式）
CODE=\$(echo \$RESPONSE | jq -r '.data.code // .output.text')
# 写入文件
OUTPUT_FILE="src/ai-gen-$(date +%Y%m%d%H%M%S).ts"
echo "\$CODE" > \$OUTPUT_FILE
echo "===== 代码已生成到：\$OUTPUT_FILE ====="

# 自动校验语法（yyc3团队规范）
echo "===== 校验生成代码语法 ====="
if npx tsc --noEmit \$OUTPUT_FILE; then
  echo -e "${GREEN}✅ 代码语法校验通过${NC}"
else
  echo -e "${RED}❌ 代码语法校验失败，请手动调整${NC}"
  # 保留生成文件，便于手动修复
fi

# 格式化代码（适配团队规范）
npx prettier --write \$OUTPUT_FILE
echo -e "${GREEN}✅ 代码已按yyc3规范格式化${NC}"
```

**使用说明**：

1. 创建`prompt.txt`：`echo "生成yyc3团队用户权限接口" > prompt.txt`
2. 调用MCP生成代码：`./ai-code-gen.sh dev MCP`
3. 适配要点：多智能体切换、团队规范自动格式化、语法校验。

### 2. AI代码评审脚本（ai-code-review.sh）

**核心用途**：调用AI智能体评审代码，输出合规性报告，适配yyc3团队权限规范。

```bash
#!/bin/bash
set -e
ENV=${1:-dev}
CODE_FILE=\${2:-src/index.ts}
source .env.${ENV}

if [ ! -f "\$CODE_FILE" ]; then
  echo -e "${RED}❌ 文件 \$CODE_FILE 不存在${NC}"
  exit 1
fi

# 读取代码内容
CODE_CONTENT=\$(cat \$CODE_FILE)
# 构建评审指令（贴合yyc3团队规范）
REVIEW_PROMPT="作为yyc3团队的代码评审专家，请评审以下代码：
1. 是否符合团队ESLint/Prettier规范
2. 是否存在权限漏洞（如硬编码密钥、未校验RBAC权限）
3. 是否符合Docker容器权限规范
4. 输出结构化评审报告（仅JSON格式）

代码内容：
\$CODE_CONTENT"

echo "===== 调用AI智能体评审代码：\$CODE_FILE ====="
RESPONSE=\$(curl -s -X POST \$AI_AGENT_URL/code-review \
  -H "X-API-KEY: \$AI_AGENT_API_KEY" \
  -H "Content-Type: application/json" \
  -d "{\"prompt\":\"\$REVIEW_PROMPT\", \"team\":\"\$TEAM_NAME\"}")

# 解析评审报告
REPORT_FILE="logs/${ENV}/code-review-$(basename \$CODE_FILE)-$(date +%Y%m%d%H%M%S).json"
echo \$RESPONSE | jq . > \$REPORT_FILE

# 输出关键问题
echo -e "\n===== 评审关键问题 ====="
ERRORS=\$(echo \$RESPONSE | jq -r '.errors | length')
if [ "\$ERRORS" -gt 0 ]; then
  echo -e "${RED}❌ 发现\$ERRORS个严重问题：${NC}"
  echo \$RESPONSE | jq -r '.errors[] | "- \(.message)（行：\(.line)）"'
else
  echo -e "${GREEN}✅ 代码评审通过，无严重问题${NC}"
fi

echo -e "\n===== 完整评审报告已保存到：\$REPORT_FILE ====="
```

**使用说明**：

- 评审指定代码文件：`./ai-code-review.sh dev src/user/permission.ts`
- 适配要点：贴合团队规范的评审指令、结构化报告、多环境日志隔离。

---

## 四、构建与打包脚本（多环境差异化构建）

### 1. 多环境构建脚本（build.sh）

**核心用途**：适配dev/test/prod环境的差异化构建（如dev带调试、prod精简）。

```bash
#!/bin/bash
set -e
ENV=${1:-dev}
TEAM_NAME="yyc3"
# 构建参数（多环境差异化）
declare -A BUILD_ARGS=(
  ["dev"]="--source-map --watch"
  ["test"]="--source-map"
  ["prod"]="--minify --no-source-map"
)

echo "===== 开始${ENV}环境构建（yyc3团队） ====="
# 前置检查
./scripts/env/check-env.sh \$ENV

# 清理旧产物
rm -rf dist/${ENV}
mkdir -p dist/${ENV}

# 差异化构建
npx tsc \${BUILD_ARGS[$ENV]} --outDir dist/${ENV}

# 复制环境配置（仅复制对应环境）
cp .env.${ENV} dist/${ENV}/.env
# 复制AI智能体配置
cp scripts/ai/ai-config.sh dist/${ENV}/scripts/ai/

# 构建完成校验
if [ -f "dist/${ENV}/index.js" ]; then
  echo -e "${GREEN}✅ ${ENV}环境构建完成，产物路径：dist/${ENV}${NC}"
else
  echo -e "${RED}❌ ${ENV}环境构建失败${NC}"
  exit 1
fi
```

**使用说明**：

- 构建生产环境：`./build.sh prod`
- 适配要点：多环境构建参数差异化、产物隔离、前置依赖检查。

### 2. Docker多环境打包脚本（build-docker.sh）

**核心用途**：为不同环境构建Docker镜像，适配多机部署。

```bash
#!/bin/bash
set -e
ENV=${1:-dev}
TEAM_NAME="yyc3"
# 镜像标签（多环境/多机适配）
IMAGE_TAG="yyc3-app:${ENV}-$(date +%Y%m%d%H%M%S)"
# 多环境Dockerfile（dev/test用基础版，prod用精简版）
DOCKERFILE="Dockerfile.${ENV}"
if [ ! -f "\$DOCKERFILE" ]; then
  DOCKERFILE="Dockerfile" # 兜底使用默认Dockerfile
fi

echo "===== 构建${ENV}环境Docker镜像：\$IMAGE_TAG ====="
# 构建镜像（多环境构建参数）
docker build -t \$IMAGE_TAG -f \$DOCKERFILE \
  --build-arg ENV=\$ENV \
  --build-arg TEAM_NAME=\$TEAM_NAME \
  .

# 镜像校验
if docker images | grep "\$IMAGE_TAG" > /dev/null; then
  echo -e "${GREEN}✅ 镜像构建成功${NC}"
  # 推送镜像（仅prod环境）
  if [ "\$ENV" = "prod" ]; then
    echo "===== 推送生产环境镜像到仓库 ====="
    docker tag \$IMAGE_TAG registry.yyc3.com/yyc3-app:${ENV}
    docker push registry.yyc3.com/yyc3-app:${ENV}
    echo -e "${GREEN}✅ 镜像推送完成${NC}"
  fi
else
  echo -e "${RED}❌ 镜像构建失败${NC}"
  exit 1
fi

# 写入镜像标签到文件（便于部署脚本读取）
echo \$IMAGE_TAG > .docker-image-tag.${ENV}
echo "===== 镜像标签已保存到：.docker-image-tag.${ENV} ====="
```

**使用说明**：

- 构建测试环境镜像：`./build-docker.sh test`
- 适配要点：多环境Dockerfile、镜像标签规范、生产环境自动推送。

---

## 五、部署与发布脚本（多机/多环境一键部署）

### 1. 多环境部署脚本（deploy.sh）

**核心用途**：一键部署到指定环境，支持多机批量部署、灰度发布。

```bash
#!/bin/bash
set -e
ENV=${1:-dev}
# 多环境部署目标
declare -A DEPLOY_TARGETS=(
  ["dev"]="localhost:3000"
  ["test"]="test-server.yyc3.com:3000"
  ["prod"]="prod-server-1.yyc3.com:3000 prod-server-2.yyc3.com:3000"
)
TEAM_NAME="yyc3"
# 灰度发布比例（仅prod生效）
CANARY_RATIO=${2:-100} # 100=全量，50=灰度50%

echo "===== 开始${ENV}环境部署（yyc3团队） ====="
# 读取镜像标签
if [ ! -f ".docker-image-tag.${ENV}" ]; then
  echo -e "${RED}❌ 请先执行build-docker.sh构建镜像${NC}"
  exit 1
fi
IMAGE_TAG=\$(cat .docker-image-tag.${ENV})

# 解析部署目标
TARGETS=\${DEPLOY_TARGETS[$ENV]}
# 灰度发布处理（仅prod）
if [ "\$ENV" = "prod" ] && [ "\$CANARY_RATIO" -lt 100 ]; then
  # 随机选择部分服务器
  TARGETS=\$(echo \$TARGETS | tr ' ' '\n' | shuf -n \$((\$(echo \$TARGETS | wc -w) * CANARY_RATIO / 100)) | tr '\n' ' ')
  echo -e "${YELLOW}⚠️  生产环境灰度发布（比例：\$CANARY_RATIO%），部署目标：\$TARGETS${NC}"
fi

# 批量部署
for TARGET in "\${TARGETS[@]}"; do
  HOST=\$(echo \$TARGET | cut -d':' -f1)
  PORT=\$(echo \$TARGET | cut -d':' -f2)
  echo -e "\n📡 部署到：\$HOST:\$PORT"
  
  # 停止旧容器
  ssh yyc3-admin@\$HOST "docker stop yyc3-app-${ENV} || true && docker rm yyc3-app-${ENV} || true"
  # 启动新容器（多环境权限配置）
  ssh yyc3-admin@\$HOST "docker run -d --name yyc3-app-${ENV} \
    -p \$PORT:3000 \
    --env-file /opt/yyc3-project/.env.${ENV} \
    --user 1000:1000 \
    --restart unless-stopped \
    \$IMAGE_TAG"
  
  # 健康检查
  sleep 5
  if curl -s http://\$HOST:\$PORT/health | grep "ok" > /dev/null; then
    echo -e "${GREEN}✅ \$HOST:\$PORT 部署成功，健康检查通过${NC}"
  else
    echo -e "${RED}❌ \$HOST:\$PORT 健康检查失败${NC}"
    # 回滚（仅prod）
    if [ "\$ENV" = "prod" ]; then
      echo "🔄 执行回滚..."
      ssh yyc3-admin@\$HOST "docker stop yyc3-app-${ENV} && docker rm yyc3-app-${ENV} && docker run -d --name yyc3-app-${ENV} -p \$PORT:3000 --env-file /opt/yyc3-project/.env.${ENV} registry.yyc3.com/yyc3-app:prod-latest"
    fi
  fi
done

echo -e "\n===== ${ENV}环境部署完成 ====="
```

**使用说明**：

- 全量部署测试环境：`./deploy.sh test`
- 灰度50%部署生产环境：`./deploy.sh prod 50`
- 适配要点：多机批量部署、灰度发布、自动健康检查+回滚。

### 2. 部署回滚脚本（rollback.sh）

**核心用途**：部署失败时一键回滚到上一版本，适配多环境/多机。

```bash
#!/bin/bash
set -e
ENV=${1:-dev}
TEAM_NAME="yyc3"
# 多环境回滚目标
declare -A ROLLBACK_TARGETS=(
  ["dev"]="localhost:3000"
  ["test"]="test-server.yyc3.com:3000"
  ["prod"]="prod-server-1.yyc3.com:3000 prod-server-2.yyc3.com:3000"
)

echo "===== 开始${ENV}环境回滚（yyc3团队） ====="
# 读取上一版本镜像标签（需提前记录）
if [ ! -f ".docker-image-tag.${ENV}.prev" ]; then
  echo -e "${YELLOW}⚠️  无历史镜像标签，使用默认镜像：registry.yyc3.com/yyc3-app:${ENV}-latest${NC}"
  PREV_IMAGE_TAG="registry.yyc3.com/yyc3-app:${ENV}-latest"
else
  PREV_IMAGE_TAG=\$(cat .docker-image-tag.${ENV}.prev)
fi

# 批量回滚
for TARGET in "\${ROLLBACK_TARGETS[$ENV]}"; do
  HOST=\$(echo \$TARGET | cut -d':' -f1)
  PORT=\$(echo \$TARGET | cut -d':' -f2)
  echo -e "\n🔄 回滚到：\$HOST:\$PORT"
  
  # 停止当前容器
  ssh yyc3-admin@\$HOST "docker stop yyc3-app-${ENV} || true && docker rm yyc3-app-${ENV} || true"
  # 启动上一版本
  ssh yyc3-admin@\$HOST "docker run -d --name yyc3-app-${ENV} \
    -p \$PORT:3000 \
    --env-file /opt/yyc3-project/.env.${ENV} \
    --user 1000:1000 \
    --restart unless-stopped \
    \$PREV_IMAGE_TAG"
  
  # 健康检查
  sleep 5
  if curl -s http://\$HOST:\$PORT/health | grep "ok" > /dev/null; then
    echo -e "${GREEN}✅ \$HOST:\$PORT 回滚成功${NC}"
  else
    echo -e "${RED}❌ \$HOST:\$PORT 回滚失败，请手动处理${NC}"
  fi
done

echo -e "\n===== ${ENV}环境回滚完成 ====="
```

**使用说明**：

- 回滚生产环境：`./rollback.sh prod`
- 适配要点：多机批量回滚、历史版本兜底、健康检查。

---

## 六、核心适配要点总结

1. **多环境适配**：所有脚本通过`ENV`参数区分dev/test/prod，配置文件按环境隔离（`.env.dev`/`.env.prod`）；
2. **多机适配**：支持批量服务器列表、SSH远程执行、多机同步/部署/回滚；
3. **多智能体适配**：封装统一AI调用接口，切换智能体仅需修改配置，自动校验AI生成内容；
4. **AI协同适配**：AI脚本贴合yyc3团队规范，自动校验/格式化/评审代码，降低人工成本；
5. **便捷性适配**：所有脚本支持参数化调用、自动检查依赖、清晰的颜色提示、日志留存。

---

## 下一步迭代建议

需要我为你将这些脚本整合为yyc3团队的**一站式项目管理脚本（yyc3-project.sh）**，通过子命令（init/build/deploy/ai-gen等）统一调用所有功能吗？
