#!/bin/bash
set -e
ENV=${1:-dev}
TEAM_NAME="yyc3"
# 多环境回滚目标
declare -A ROLLBACK_TARGETS=(
  ["dev"]="localhost:3200"
  ["test"]="test-server.yyc3.com:3200"
  ["prod"]="prod-server-1.yyc3.com:3200 prod-server-2.yyc3.com:3200"
)

echo "===== 开始${ENV}环境回滚（yyc3团队） ====="
# 读取上一版本镜像标签（需提前记录）
if [ ! -f ".docker-image-tag.${ENV}.prev" ]; then
  echo -e "${YELLOW}⚠️  无历史镜像标签，使用默认镜像：registry.yyc3.com/yyc3-app:${ENV}-latest${NC}"
  PREV_IMAGE_TAG="registry.yyc3.com/yyc3-app:${ENV}-latest"
else
  PREV_IMAGE_TAG=$(cat .docker-image-tag.${ENV}.prev)
fi

# 批量回滚
for TARGET in "${ROLLBACK_TARGETS[$ENV]}"; do
  HOST=$(echo $TARGET | cut -d':' -f1)
  PORT=$(echo $TARGET | cut -d':' -f2)
  echo -e "\n🔄 回滚到：$HOST:$PORT"

  # 停止当前容器
  ssh yyc3-admin@$HOST "docker stop yyc3-app-${ENV} || true && docker rm yyc3-app-${ENV} || true"
  # 启动上一版本
  ssh yyc3-admin@$HOST "docker run -d --name yyc3-app-${ENV} \
    -p $PORT:3000 \
    --env-file /opt/yyc3-project/.env.${ENV} \
    --user 1000:1000 \
    --restart unless-stopped \
    $PREV_IMAGE_TAG"

  # 健康检查
  sleep 5
  if curl -s http://$HOST:$PORT/health | grep "ok" > /dev/null; then
    echo -e "${GREEN}✅ $HOST:$PORT 回滚成功${NC}"
  else
    echo -e "${RED}❌ $HOST:$PORT 回滚失败，请手动处理${NC}"
  fi
done

echo -e "\n===== ${ENV}环境回滚完成 ====="
