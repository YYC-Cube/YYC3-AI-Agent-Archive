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

# 检查AI智能体连通性（多智能体适配）
AI_AGENT_URL=$(grep AI_AGENT_URL .env.${ENV} | cut -d'=' -f2)
if curl -s --head $AI_AGENT_URL | head -n1 | grep "200 OK" > /dev/null; then
  echo -e "${GREEN}✅ AI智能体 $AI_AGENT_URL 连通正常${NC}"
else
  echo -e "${YELLOW}⚠️ AI智能体 $AI_AGENT_URL 无法连通（非阻塞，仅提醒）${NC}"
fi

echo -e "\n===== ${ENV}环境依赖检查通过 ====="
