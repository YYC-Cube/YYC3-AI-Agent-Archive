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
