#!/bin/bash
set -e
ENV=${1:-dev}
# 多环境部署目标
declare -A DEPLOY_TARGETS=(
  ["dev"]="localhost:3200"
  ["test"]="test-server.yyc3.com:3200"
  ["prod"]="prod-server-1.yyc3.com:3200 prod-server-2.yyc3.com:3200"
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
IMAGE_TAG=$(cat .docker-image-tag.${ENV})

# 解析部署目标
TARGETS=${DEPLOY_TARGETS[$ENV]}
# 灰度发布处理（仅prod）
if [ "$ENV" = "prod" ] && [ "$CANARY_RATIO" -lt 100 ]; then
  # 随机选择部分服务器
  TARGETS=$(echo $TARGETS | tr ' ' '\n' | shuf -n $(($(echo $TARGETS | wc -w) * CANARY_RATIO / 100)) | tr '\n' ' ')
  echo -e "${YELLOW}⚠️  生产环境灰度发布（比例：$CANARY_RATIO%），部署目标：$TARGETS${NC}"
fi

# 批量部署
for TARGET in "${TARGETS[@]}"; do
  HOST=$(echo $TARGET | cut -d':' -f1)
  PORT=$(echo $TARGET | cut -d':' -f2)
  echo -e "\n📡 部署到：$HOST:$PORT"
  
  # 停止旧容器
  ssh yyc3-admin@$HOST "docker stop yyc3-app-${ENV} || true && docker rm yyc3-app-${ENV} || true"
  # 启动新容器（多环境权限配置）
  ssh yyc3-admin@$HOST "docker run -d --name yyc3-app-${ENV} \
    -p $PORT:3000 \
    --env-file /opt/yyc3-project/.env.${ENV} \
    --user 1000:1000 \
    --restart unless-stopped \
    $IMAGE_TAG"
  
  # 健康检查
  sleep 5
  if curl -s http://$HOST:$PORT/health | grep "ok" > /dev/null; then
    echo -e "${GREEN}✅ $HOST:$PORT 部署成功，健康检查通过${NC}"
  else
    echo -e "${RED}❌ $HOST:$PORT 健康检查失败${NC}"
    # 回滚（仅prod）
    if [ "$ENV" = "prod" ]; then
      echo "🔄 执行回滚..."
      ssh yyc3-admin@$HOST "docker stop yyc3-app-${ENV} && docker rm yyc3-app-${ENV} && docker run -d --name yyc3-app-${ENV} -p $PORT:3000 --env-file /opt/yyc3-project/.env.${ENV} registry.yyc3.com/yyc3-app:prod-latest"
    fi
  fi
done

echo -e "\n===== ${ENV}环境部署完成 ====="
