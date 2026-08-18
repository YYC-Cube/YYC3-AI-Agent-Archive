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
