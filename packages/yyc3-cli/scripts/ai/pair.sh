#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../utils/common.sh
source "$SCRIPT_DIR/../utils/common.sh"

section "智能结对编程助手"
load_env
print_device

# Check Ollama
if ollama_running; then
  ok "Ollama 运行中，可用于本地大模型辅助"
else
  warn "Ollama 未运行。如需启用: https://ollama.com/download"
fi

# Show helpful tips and entry points
cat <<EOF
${BOLD}可用入口:${RESET}
- 使用 VS Code Copilot Chat 与本仓库工作流
- 运行: $REPO_ROOT/devctl ai:review         进行批量审查
- 运行: $REPO_ROOT/devctl ai:gen            进行代码生成
- MCP 配置: $REPO_ROOT/mcp.config.js
- 访问规则: $REPO_ROOT/mcp-access-rules.json
EOF
