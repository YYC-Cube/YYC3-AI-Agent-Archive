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
