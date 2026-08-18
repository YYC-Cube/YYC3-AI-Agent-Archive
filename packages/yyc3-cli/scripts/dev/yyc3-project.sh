#!/bin/bash
set -e

# ===================== 核心配置（统一管理）=====================
# 团队基础配置
TEAM_NAME="yyc3"
DEFAULT_ENV="dev"
# 多机服务器列表（按环境划分）
declare -A SERVERS=(
  ["dev"]="localhost"
  ["test"]="test-server.yyc3.com"
  ["prod"]="prod-server-1.yyc3.com prod-server-2.yyc3.com"
)
# 多环境依赖清单
declare -A DEPS=(
  ["dev"]="node>=18 docker>=20 git>=2.30"
  ["test"]="node>=18 docker>=20 kubectl>=1.24"
  ["prod"]="node>=18 docker>=20 kubectl>=1.24 sshpass>=1.06"
)
# 多环境部署端口
declare -A DEPLOY_PORTS=(
  ["dev"]="3000"
  ["test"]="3000"
  ["prod"]="3000"
)
# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# ===================== 帮助函数（子命令说明）=====================
show_help() {
  echo -e "${BLUE}===== yyc3团队一站式项目管理脚本 =====${NC}"
  echo "使用方式：./yyc3-project.sh <子命令> [参数1] [参数2]..."
  echo -e "\n子命令列表："
  echo "  init        <env>           初始化指定环境的项目配置（默认：dev）"
  echo "  update      <env> [force]   增量更新指定环境配置（force=强制覆盖）"
  echo "  check-env   <env>           检查指定环境的依赖和连通性（默认：dev）"
  echo "  sync-env    <env>           同步指定环境配置到多机（默认：dev）"
  echo "  ai-gen      <env> <agent> <prompt-file>  调用AI生成代码（agent=MCP/Tongyi/Kimi）"
  echo "  ai-review   <env> <code-file>           AI评审指定代码文件"
  echo "  build       <env>           构建指定环境的代码产物（默认：dev）"
  echo "  build-docker <env>          构建指定环境的Docker镜像（默认：dev）"
  echo "  deploy      <env> [ratio]   部署到指定环境（ratio=灰度比例，仅prod生效）"
  echo "  rollback    <env>           回滚指定环境到上一版本（默认：dev）"
  echo "  help                        显示本帮助信息"
  echo -e "\n示例："
  echo "  ./yyc3-project.sh init prod          # 初始化生产环境配置"
  echo "  ./yyc3-project.sh ai-gen dev MCP prompt.txt  # 调用MCP生成代码"
  echo "  ./yyc3-project.sh deploy prod 50     # 灰度50%部署生产环境"
}

# ===================== 核心功能函数（对应子命令）=====================

# 1. 初始化项目配置（init子命令）
init_project() {
  local ENV=${1:-$DEFAULT_ENV}
  echo -e "${GREEN}===== 初始化${TEAM_NAME}团队${ENV}环境配置 =====${NC}"

  # 步骤1：创建目录结构
  mkdir -p .vscode .husky .github/workflows scripts/{env,ai,deploy} logs/${ENV} tmp/${ENV}
  echo -e "✅ 目录结构创建完成"

  # 步骤2：生成环境专属配置
  cat > .env.${ENV} << EOF
# ${TEAM_NAME}团队 ${ENV} 环境配置
TEAM_NAME=${TEAM_NAME}
ENV=${ENV}
# AI智能体配置（多智能体适配）
AI_AGENT_TYPE="MCP"
AI_AGENT_URL=http://localhost:8080/${ENV}
AI_AGENT_API_KEY=${TEAM_NAME}_${ENV}_api_key
# 数据库配置（多机适配）
DB_HOST=$(if [ "${ENV}" = "prod" ]; then echo "prod-db.${TEAM_NAME}.com"; else echo "localhost"; fi)
DB_USER=${TEAM_NAME}_${ENV}
# 多机监控配置
MONITOR_HOST=$(if [ "${ENV}" = "prod" ]; then echo "prod-monitor.${TEAM_NAME}.com"; else echo "localhost:9090"; fi)
EOF
  echo -e "✅ ${ENV}环境配置文件生成：.env.${ENV}"

  # 步骤3：生成AI智能体调用脚本
  cat > scripts/ai/ai-config.sh << EOF
#!/bin/bash
# ${TEAM_NAME}团队 AI智能体调用脚本（多智能体适配）
AI_AGENT=${AI_AGENT_TYPE:-MCP}
case $AI_AGENT in
  MCP)
    echo "调用MCP智能体：${AI_AGENT_URL}"
    curl -X POST ${AI_AGENT_URL}/code-completion -H "X-API-KEY: ${AI_AGENT_API_KEY}" -d @-
    ;;
  Copilot)
    echo "调用Copilot智能体"
    ;;
  Tongyi)
    echo "调用通义千问智能体"
    ;;
  Kimi)
    echo "调用Kimi智能体"
    ;;
esac
EOF
  chmod +x scripts/ai/ai-config.sh
  echo -e "✅ AI智能体配置脚本生成：scripts/ai/ai-config.sh"

  # 步骤4：生成基础.gitignore
  cat > .gitignore << EOF
# 多环境敏感文件
.env.*
!/.env.example
# AI缓存
ai-cache/
# 多机部署临时文件
tmp/
logs/
# Docker镜像标签文件
.docker-image-tag.*
EOF
  echo -e "✅ .gitignore生成完成"

  echo -e "${GREEN}===== ${ENV}环境初始化完成 =====${NC}"
}

# 2. 增量更新配置（update子命令）
update_config() {
  local ENV=${1:-$DEFAULT_ENV}
  local FORCE=${2:-false}

  # 增量更新函数
  update_file() {
    local FILE_PATH=$1
    local CONTENT=$(cat)
    if [ -f "$FILE_PATH" ] && [ "$FORCE" != "force" ]; then
      read -p "📄 文件 $FILE_PATH 已存在，是否覆盖？(y/N) " -n 1 -r
      echo
      if ! [[ $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}⏭️  跳过：$FILE_PATH${NC}"
        return
      fi
    fi
    echo "$CONTENT" > $FILE_PATH
    echo -e "${GREEN}✅ 更新完成：$FILE_PATH${NC}"
  }

  echo -e "${GREEN}===== 增量更新${TEAM_NAME}团队${ENV}环境配置 =====${NC}"

  # 更新AI智能体配置
  cat << EOF | update_file scripts/ai/ai-config.sh
#!/bin/bash
# ${TEAM_NAME}团队 AI智能体调用脚本（多智能体适配，已升级支持Kimi）
AI_AGENT=${AI_AGENT_TYPE:-MCP}
case $AI_AGENT in
  MCP)
    echo "调用MCP智能体：${AI_AGENT_URL}"
    curl -X POST ${AI_AGENT_URL}/code-completion -H "X-API-KEY: ${AI_AGENT_API_KEY}" -d @-
    ;;
  Copilot)
    echo "调用Copilot智能体"
    ;;
  Tongyi)
    echo "调用通义千问智能体"
    ;;
  Kimi)
    echo "调用Kimi智能体"
    ;;
esac
EOF

  # 更新环境配置
  cat << EOF | update_file .env.${ENV}
# ${TEAM_NAME}团队 ${ENV} 环境配置（已升级）
TEAM_NAME=${TEAM_NAME}
ENV=${ENV}
AI_AGENT_TYPE="MCP"
AI_AGENT_URL=http://localhost:8080/${ENV}
AI_AGENT_API_KEY=${TEAM_NAME}_${ENV}_api_key
DB_HOST=$(if [ "${ENV}" = "prod" ]; then echo "prod-db.${TEAM_NAME}.com"; else echo "localhost"; fi)
DB_USER=${TEAM_NAME}_${ENV}
# 新增：多机监控配置
MONITOR_HOST=$(if [ "${ENV}" = "prod" ]; then echo "prod-monitor.${TEAM_NAME}.com"; else echo "localhost:9090"; fi)
EOF

  echo -e "${GREEN}===== ${ENV}环境配置增量更新完成 =====${NC}"
}

# 3. 检查环境依赖（check-env子命令）
check_env() {
  local ENV=${1:-$DEFAULT_ENV}
  echo -e "${GREEN}===== 检查${TEAM_NAME}团队${ENV}环境依赖 =====${NC}"

  # 解析依赖清单
  IFS=' ' read -ra DEPS_LIST <<< "${DEPS[$ENV]}"
  for DEP in "${DEPS_LIST[@]}"; do
    NAME=$(echo $DEP | cut -d'>=' -f1)
    MIN_VER=$(echo $DEP | cut -d'>=' -f2)
    
    # 检查是否安装
    if ! command -v $NAME &> /dev/null; then
      echo -e "${RED}❌ $NAME 未安装（${ENV}环境必需）${NC}"
      exit 1
    fi
    
    # 检查版本
    VER=$($NAME --version 2>&1 | head -n1 | grep -oE '[0-9]+\.[0-9]+(\.[0-9]+)?' | head -n1)
    if [ "$(echo -e "$VER\n$MIN_VER" | sort -V | head -n1)" != "$MIN_VER" ]; then
      echo -e "${RED}❌ $NAME 版本过低（当前：$VER，要求：>=${MIN_VER}）${NC}"
      exit 1
    fi
    
    echo -e "${GREEN}✅ $NAME $VER（满足>=${MIN_VER}）${NC}"
  done

  # 检查AI智能体连通性
  if [ -f ".env.${ENV}" ]; then
    AI_AGENT_URL=$(grep AI_AGENT_URL .env.${ENV} | cut -d'=' -f2)
    if curl -s --head $AI_AGENT_URL | head -n1 | grep "200 OK" > /dev/null; then
      echo -e "${GREEN}✅ AI智能体 $AI_AGENT_URL 连通正常${NC}"
    else
      echo -e "${YELLOW}⚠️ AI智能体 $AI_AGENT_URL 无法连通（非阻塞，仅提醒）${NC}"
    fi
  else
    echo -e "${YELLOW}⚠️ 未找到.env.${ENV}，跳过AI智能体检查${NC}"
  fi

  echo -e "${GREEN}===== ${ENV}环境依赖检查通过 =====${NC}"
}

# 4. 同步环境到多机（sync-env子命令）
sync_env() {
  local ENV=${1:-$DEFAULT_ENV}
  local SERVER_LIST=${SERVERS[$ENV]}
  local USER="${TEAM_NAME}-admin"

  echo -e "${GREEN}===== 同步${TEAM_NAME}团队${ENV}环境到多机：${SERVER_LIST} =====${NC}"
  for SERVER in $SERVER_LIST; do
    echo -e "\n📡 同步到服务器：$SERVER"
    # 同步环境配置文件
    if [ -f ".env.${ENV}" ]; then
      scp .env.${ENV} ${USER}@${SERVER}:/opt/${TEAM_NAME}-project/.env.${ENV}
    else
      echo -e "${YELLOW}⚠️ 未找到.env.${ENV}，跳过配置同步${NC}"
    fi
    # 同步AI脚本
    scp -r scripts/ai/ ${USER}@${SERVER}:/opt/${TEAM_NAME}-project/scripts/
    # 远程初始化目录
    ssh ${USER}@${SERVER} "cd /opt/${TEAM_NAME}-project && chmod +x scripts/ai/ai-config.sh && mkdir -p logs/${ENV} tmp/${ENV}"
    echo -e "${GREEN}✅ $SERVER 同步完成${NC}"
  done

  echo -e "\n${GREEN}===== 所有服务器环境同步完成 =====${NC}"
}

# 5. AI代码生成（ai-gen子命令）
ai_code_gen() {
  local ENV=${1:-$DEFAULT_ENV}
  local AI_AGENT=${2:-"MCP"}
  local PROMPT_FILE=${3:-"prompt.txt"}

  echo -e "${GREEN}===== 调用${AI_AGENT}智能体生成${ENV}环境代码 =====${NC}"

  # 校验prompt文件
  if [ ! -f "$PROMPT_FILE" ]; then
    echo -e "${RED}❌ 未找到prompt文件：$PROMPT_FILE${NC}"
    echo "请创建该文件并写入代码生成指令（如：生成${TEAM_NAME}团队用户权限接口）"
    exit 1
  fi

  # 加载环境配置
  if [ -f ".env.${ENV}" ]; then
    source .env.${ENV}
  else
    echo -e "${RED}❌ 未找到.env.${ENV}，请先执行init子命令${NC}"
    exit 1
  fi

  # 读取生成指令
  PROMPT=$(cat $PROMPT_FILE)

  # 多智能体调用逻辑
  case $AI_AGENT in
    MCP)
      RESPONSE=$(curl -s -X POST $AI_AGENT_URL/code-completion \
        -H "X-API-KEY: $AI_AGENT_API_KEY" \
        -H "Content-Type: application/json" \
        -d "{\"prompt\":\"$PROMPT\", \"team\":\"$TEAM_NAME\", \"env\":\"$ENV\"}")
      ;;
    Tongyi)
      RESPONSE=$(curl -s -X POST https://dashscope.aliyuncs.com/api/v1/services/aigc/text-generation/generation \
        -H "Authorization: Bearer $AI_AGENT_API_KEY" \
        -H "Content-Type: application/json" \
        -d "{\"model\":\"qwen-turbo\", \"input\":{\"messages\":[{\"role\":\"user\",\"content\":\"$PROMPT\"}]}}")
      ;;
    Kimi)
      echo -e "${YELLOW}⚠️ Kimi智能体调用逻辑待补充${NC}"
      exit 1
      ;;
    *)
      echo -e "${RED}❌ 不支持的AI智能体：$AI_AGENT（仅支持MCP/Tongyi/Kimi）${NC}"
      exit 1
      ;;
  esac

  # 提取代码并写入文件
  CODE=$(echo $RESPONSE | jq -r '.data.code // .output.text // "// 未提取到有效代码"')
  OUTPUT_FILE="src/ai-gen-$(date +%Y%m%d%H%M%S).ts"
  echo "$CODE" > $OUTPUT_FILE
  echo -e "✅ 代码已生成到：$OUTPUT_FILE"

  # 语法校验+格式化
  if command -v npx &> /dev/null; then
    echo -e "🔍 校验生成代码语法..."
    if npx tsc --noEmit $OUTPUT_FILE; then
      echo -e "${GREEN}✅ 代码语法校验通过${NC}"
    else
      echo -e "${RED}❌ 代码语法校验失败，请手动调整${NC}"
    fi
    # 格式化代码
    npx prettier --write $OUTPUT_FILE
    echo -e "${GREEN}✅ 代码已按${TEAM_NAME}规范格式化${NC}"
  else
    echo -e "${YELLOW}⚠️ 未安装npx，跳过语法校验和格式化${NC}"
  fi

  echo -e "${GREEN}===== AI代码生成完成 =====${NC}"
}

# 6. AI代码评审（ai-review子命令）
ai_code_review() {
  local ENV=${1:-$DEFAULT_ENV}
  local CODE_FILE=${2:-"src/index.ts"}

  echo -e "${GREEN}===== AI评审${ENV}环境代码：$CODE_FILE =====${NC}"

  # 校验代码文件
  if [ ! -f "$CODE_FILE" ]; then
    echo -e "${RED}❌ 未找到代码文件：$CODE_FILE${NC}"
    exit 1
  fi

  # 加载环境配置
  if [ -f ".env.${ENV}" ]; then
    source .env.${ENV}
  else
    echo -e "${RED}❌ 未找到.env.${ENV}，请先执行init子命令${NC}"
    exit 1
  fi

  # 读取代码内容
  CODE_CONTENT=$(cat $CODE_FILE)
  # 构建评审指令
  REVIEW_PROMPT="作为${TEAM_NAME}团队的代码评审专家，请评审以下代码：
1. 是否符合团队ESLint/Prettier规范
2. 是否存在权限漏洞（如硬编码密钥、未校验RBAC权限）
3. 是否符合Docker容器权限规范
4. 输出结构化评审报告（仅JSON格式）

代码内容：
$CODE_CONTENT"

  # 调用AI评审
  RESPONSE=$(curl -s -X POST $AI_AGENT_URL/code-review \
    -H "X-API-KEY: $AI_AGENT_API_KEY" \
    -H "Content-Type: application/json" \
    -d "{\"prompt\":\"$REVIEW_PROMPT\", \"team\":\"$TEAM_NAME\"}")

  # 保存评审报告
  REPORT_FILE="logs/${ENV}/code-review-$(basename $CODE_FILE)-$(date +%Y%m%d%H%M%S).json"
  mkdir -p logs/${ENV}
  echo $RESPONSE | jq . > $REPORT_FILE

  # 输出关键问题
  ERRORS=$(echo $RESPONSE | jq -r '.errors | length // 0')
  if [ "$ERRORS" -gt 0 ]; then
    echo -e "${RED}❌ 发现$ERRORS个严重问题：${NC}"
    echo $RESPONSE | jq -r '.errors[] | "- \(.message)（行：\(.line)）"'
  else
    echo -e "${GREEN}✅ 代码评审通过，无严重问题${NC}"
  fi

  echo -e "✅ 完整评审报告已保存到：$REPORT_FILE"
}

# 7. 构建代码（build子命令）
build_project() {
  local ENV=${1:-$DEFAULT_ENV}
  # 构建参数（多环境差异化）
  declare -A BUILD_ARGS=(
    ["dev"]="--source-map --watch"
    ["test"]="--source-map"
    ["prod"]="--minify --no-source-map"
  )

  echo -e "${GREEN}===== 构建${TEAM_NAME}团队${ENV}环境代码 =====${NC}"
  # 前置检查
  ./$0 check-env $ENV

  # 清理旧产物
  rm -rf dist/${ENV}
  mkdir -p dist/${ENV}

  # 差异化构建
  if command -v npx &> /dev/null; then
    npx tsc ${BUILD_ARGS[$ENV]} --outDir dist/${ENV}
  else
    echo -e "${RED}❌ 未安装npx，无法执行构建${NC}"
    exit 1
  fi

  # 复制配置文件
  if [ -f ".env.${ENV}" ]; then
    cp .env.${ENV} dist/${ENV}/.env
  fi
  cp -r scripts/ai/ dist/${ENV}/scripts/

  # 校验产物
  if [ -f "dist/${ENV}/index.js" ]; then
    echo -e "${GREEN}✅ ${ENV}环境构建完成，产物路径：dist/${ENV}${NC}"
  else
    echo -e "${RED}❌ ${ENV}环境构建失败${NC}"
    exit 1
  fi
}

# 8. 构建Docker镜像（build-docker子命令）
build_docker() {
  local ENV=${1:-$DEFAULT_ENV}
  local IMAGE_TAG="${TEAM_NAME}-app:${ENV}-$(date +%Y%m%d%H%M%S)"
  local DOCKERFILE="Dockerfile.${ENV}"

  echo -e "${GREEN}===== 构建${TEAM_NAME}团队${ENV}环境Docker镜像 =====${NC}"

  # 兜底使用默认Dockerfile
  if [ ! -f "$DOCKERFILE" ]; then
    DOCKERFILE="Dockerfile"
    echo -e "${YELLOW}⚠️ 未找到${DOCKERFILE}，使用默认Dockerfile${NC}"
  fi

  # 构建镜像
  docker build -t $IMAGE_TAG -f $DOCKERFILE \
    --build-arg ENV=$ENV \
    --build-arg TEAM_NAME=$TEAM_NAME \
    .

  # 校验镜像
  if docker images | grep "$IMAGE_TAG" > /dev/null; then
    echo -e "${GREEN}✅ 镜像构建成功：$IMAGE_TAG${NC}"
    # 推送生产环境镜像
    if [ "$ENV" = "prod" ]; then
      echo -e "📤 推送生产环境镜像到仓库..."
      docker tag $IMAGE_TAG registry.${TEAM_NAME}.com/${TEAM_NAME}-app:${ENV}
      docker push registry.${TEAM_NAME}.com/${TEAM_NAME}-app:${ENV}
      echo -e "${GREEN}✅ 镜像推送完成${NC}"
    fi
    # 保存镜像标签
    echo $IMAGE_TAG > .docker-image-tag.${ENV}
    # 备份上一版本标签（用于回滚）
    if [ -f ".docker-image-tag.${ENV}" ]; then
      cp .docker-image-tag.${ENV} .docker-image-tag.${ENV}.prev
    fi
    echo -e "✅ 镜像标签已保存到：.docker-image-tag.${ENV}"
  else
    echo -e "${RED}❌ 镜像构建失败${NC}"
    exit 1
  fi
}

# 9. 部署项目（deploy子命令）
deploy_project() {
  local ENV=${1:-$DEFAULT_ENV}
  local CANARY_RATIO=${2:-100}
  local SERVER_LIST=${SERVERS[$ENV]}
  local PORT=${DEPLOY_PORTS[$ENV]}
  local USER="${TEAM_NAME}-admin"

  echo -e "${GREEN}===== 部署${TEAM_NAME}团队${ENV}环境（灰度比例：$CANARY_RATIO%）=====${NC}"

  # 校验镜像标签
  if [ ! -f ".docker-image-tag.${ENV}" ]; then
    echo -e "${RED}❌ 未找到镜像标签文件，请先执行build-docker子命令${NC}"
    exit 1
  fi
  local IMAGE_TAG=$(cat .docker-image-tag.${ENV})

  # 灰度发布处理（仅生产环境）
  if [ "$ENV" = "prod" ] && [ "$CANARY_RATIO" -lt 100 ]; then
    SERVER_LIST=$(echo $SERVER_LIST | tr ' ' '\n' | shuf -n $(($(echo $SERVER_LIST | wc -w) * CANARY_RATIO / 100)) | tr '\n' ' ')
    echo -e "${YELLOW}⚠️  生产环境灰度发布，部署目标：$SERVER_LIST${NC}"
  fi

  # 批量部署
  for SERVER in $SERVER_LIST; do
    echo -e "\n📡 部署到：$SERVER:$PORT"
    # 停止旧容器
    ssh ${USER}@${SERVER} "docker stop ${TEAM_NAME}-app-${ENV} || true && docker rm ${TEAM_NAME}-app-${ENV} || true"
    # 启动新容器
    ssh ${USER}@${SERVER} "docker run -d --name ${TEAM_NAME}-app-${ENV} \
      -p $PORT:3000 \
      --env-file /opt/${TEAM_NAME}-project/.env.${ENV} \
      --user 1000:1000 \
      --restart unless-stopped \
      $IMAGE_TAG"
    # 健康检查
    sleep 5
    if curl -s http://$SERVER:$PORT/health | grep "ok" > /dev/null; then
      echo -e "${GREEN}✅ $SERVER:$PORT 部署成功，健康检查通过${NC}"
    else
      echo -e "${RED}❌ $SERVER:$PORT 健康检查失败${NC}"
      # 生产环境自动回滚
      if [ "$ENV" = "prod" ]; then
        echo -e "🔄 执行回滚..."
        ./$0 rollback $ENV
      fi
    fi
  done

  echo -e "\n${GREEN}===== ${ENV}环境部署完成 =====${NC}"
}

# 10. 回滚项目（rollback子命令）
rollback_project() {
  local ENV=${1:-$DEFAULT_ENV}
  local SERVER_LIST=${SERVERS[$ENV]}
  local PORT=${DEPLOY_PORTS[$ENV]}
  local USER="${TEAM_NAME}-admin"

  echo -e "${GREEN}===== 回滚${TEAM_NAME}团队${ENV}环境 =====${NC}"

  # 读取上一版本镜像标签
  if [ -f ".docker-image-tag.${ENV}.prev" ]; then
    local PREV_IMAGE_TAG=$(cat .docker-image-tag.${ENV}.prev)
  else
    PREV_IMAGE_TAG="registry.${TEAM_NAME}.com/${TEAM_NAME}-app:${ENV}-latest"
    echo -e "${YELLOW}⚠️  无历史镜像标签，使用默认镜像：$PREV_IMAGE_TAG${NC}"
  fi

  # 批量回滚
  for SERVER in $SERVER_LIST; do
    echo -e "\n🔄 回滚到：$SERVER:$PORT"
    # 停止当前容器
    ssh ${USER}@${SERVER} "docker stop ${TEAM_NAME}-app-${ENV} || true && docker rm ${TEAM_NAME}-app-${ENV} || true"
    # 启动上一版本
    ssh ${USER}@${SERVER} "docker run -d --name ${TEAM_NAME}-app-${ENV} \
      -p $PORT:3000 \
      --env-file /opt/${TEAM_NAME}-project/.env.${ENV} \
      --user 1000:1000 \
      --restart unless-stopped \
      $PREV_IMAGE_TAG"
    # 健康检查
    sleep 5
    if curl -s http://$SERVER:$PORT/health | grep "ok" > /dev/null; then
      echo -e "${GREEN}✅ $SERVER:$PORT 回滚成功${NC}"
    else
      echo -e "${RED}❌ $SERVER:$PORT 回滚失败，请手动处理${NC}"
    fi
  done

  echo -e "\n${GREEN}===== ${ENV}环境回滚完成 =====${NC}"
}

# ===================== 主逻辑（子命令解析）=====================
main() {
  if [ $# -eq 0 ]; then
    show_help
    exit 0
  fi

  # 解析子命令
  case "$1" in
    init)
      init_project "$2"
      ;;
    update)
      update_config "$2" "$3"
      ;;
    check-env)
      check_env "$2"
      ;;
    sync-env)
      sync_env "$2"
      ;;
    ai-gen)
      ai_code_gen "$2" "$3" "$4"
      ;;
    ai-review)
      ai_code_review "$2" "$3"
      ;;
    build)
      build_project "$2"
      ;;
    build-docker)
      build_docker "$2"
      ;;
    deploy)
      deploy_project "$2" "$3"
      ;;
    rollback)
      rollback_project "$2"
      ;;
    help)
      show_help
      ;;
    *)
      echo -e "${RED}❌ 未知子命令：$1${NC}"
      show_help
      exit 1
      ;;
  esac
}

# 执行主逻辑
main "$@"
