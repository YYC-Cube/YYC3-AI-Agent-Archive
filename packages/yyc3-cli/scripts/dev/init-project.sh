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
