#!/bin/bash
set -e

ENV=${1:-dev}
AI_AGENT=${2:-MCP}

if [ -f ".env.${ENV}" ]; then
  source ".env.${ENV}"
fi

PROMPT_FILE=${3:-prompt.txt}
if [ ! -f "$PROMPT_FILE" ]; then
  echo "请创建 prompt.txt，写入代码生成指令（如：生成yyc3团队用户权限接口）"
  exit 1
fi
PROMPT=$(cat "$PROMPT_FILE")

echo "===== 调用 ${AI_AGENT} 智能体生成代码 ====="

case "$AI_AGENT" in
  MCP)
    RESPONSE=$(curl -s -X POST "${AI_AGENT_URL}/code-completion" \
      -H "X-API-KEY: ${AI_AGENT_API_KEY}" \
      -H "Content-Type: application/json" \
      -d "{\"prompt\":\"${PROMPT}\", \"team\":\"${TEAM_NAME}\", \"env\":\"${ENV}\"}")
    ;;
  Tongyi)
    RESPONSE=$(curl -s -X POST https://dashscope.aliyuncs.com/api/v1/services/aigc/text-generation/generation \
      -H "Authorization: Bearer ${AI_AGENT_API_KEY}" \
      -H "Content-Type: application/json" \
      -d "{\"model\":\"qwen-turbo\", \"input\":{\"messages\":[{\"role\":\"user\",\"content\":\"${PROMPT}\"}]}}")
    ;;
  *)
    echo "不支持的 AI 智能体: ${AI_AGENT}"
    exit 1
    ;;
esac

CODE=$(echo "$RESPONSE" | jq -r '.data.code // .output.text' 2>/dev/null || echo "$RESPONSE")

OUTPUT_FILE="src/ai-gen-$(date +%Y%m%d%H%M%S).ts"
mkdir -p src
echo "$CODE" > "$OUTPUT_FILE"
echo "===== 代码已生成到: ${OUTPUT_FILE} ====="

echo "===== 校验生成代码语法 ====="
if command -v npx &>/dev/null; then
  if npx tsc --noEmit "$OUTPUT_FILE" 2>/dev/null; then
    echo "✅ 代码语法校验通过"
  else
    echo "❌ 代码语法校验失败，请手动调整"
  fi
fi

if command -v npx &>/dev/null; then
  npx prettier --write "$OUTPUT_FILE" 2>/dev/null && echo "✅ 代码已按 yyc3 规范格式化"
fi
