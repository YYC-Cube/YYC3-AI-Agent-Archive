#!/bin/bash
set -e
ENV=${1:-dev}
FORCE=${2:-false}
TEAM_NAME="yyc3"

# 增量更新函数（避免覆盖）
update_file() {
  FILE_PATH=$1
  CONTENT=$(cat)
  if [ -f "$FILE_PATH" ] && [ "$FORCE" != "force" ]; then
    read -p "文件 $FILE_PATH 已存在，是否覆盖？(y/N) " -n 1 -r
    echo
    if ! [[ $REPLY =~ ^[Yy]$ ]]; then
      echo "跳过：$FILE_PATH"
      return
    fi
  fi
  echo "$CONTENT" > $FILE_PATH
  echo "更新完成：$FILE_PATH"
}

# 更新AI智能体配置（仅更新新增的智能体类型）
cat << EOF | update_file scripts/ai/ai-config.sh
#!/bin/bash
# YYC3团队 AI智能体调用脚本（多智能体适配，已升级支持Kimi）
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
