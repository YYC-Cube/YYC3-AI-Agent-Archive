#!/bin/bash
set -e

ENV=${1:-dev}
CODE_FILE=${2:-src/index.ts}

if [ -f ".env.${ENV}" ]; then
  source ".env.${ENV}"
fi

if [ ! -f "$CODE_FILE" ]; then
  echo "❌ 文件 ${CODE_FILE} 不存在"
  exit 1
fi

CODE_CONTENT=$(cat "$CODE_FILE")

REVIEW_PROMPT="作为yyc3团队的代码评审专家，请评审以下代码：
1. 是否符合团队ESLint/Prettier规范
2. 是否存在权限漏洞（如硬编码密钥、未校验RBAC权限）
3. 是否符合Docker容器权限规范
4. 输出结构化评审报告（仅JSON格式）

代码内容：
${CODE_CONTENT}"

echo "===== 调用AI智能体评审代码: ${CODE_FILE} ====="
RESPONSE=$(curl -s -X POST "${AI_AGENT_URL}/code-review" \
  -H "X-API-KEY: ${AI_AGENT_API_KEY}" \
  -H "Content-Type: application/json" \
  -d "{\"prompt\":\"${REVIEW_PROMPT}\", \"team\":\"${TEAM_NAME}\"}")

mkdir -p "logs/${ENV}"
REPORT_FILE="logs/${ENV}/code-review-$(basename "$CODE_FILE")-$(date +%Y%m%d%H%M%S).json"
echo "$RESPONSE" | jq . > "$REPORT_FILE" 2>/dev/null || echo "$RESPONSE" > "$REPORT_FILE"

echo ""
echo "===== 评审关键问题 ====="
ERRORS=$(echo "$RESPONSE" | jq -r '.errors | length' 2>/dev/null || echo "0")
if [ "$ERRORS" -gt 0 ]; then
  echo "❌ 发现 ${ERRORS} 个严重问题："
  echo "$RESPONSE" | jq -r '.errors[] | "- \(.message)（行：\(.line)）"' 2>/dev/null
else
  echo "✅ 代码评审通过，无严重问题"
fi

echo ""
echo "===== 完整评审报告已保存到: ${REPORT_FILE} ====="
