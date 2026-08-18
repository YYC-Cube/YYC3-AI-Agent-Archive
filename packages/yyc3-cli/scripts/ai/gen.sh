#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../utils/common.sh
source "$SCRIPT_DIR/../utils/common.sh"

section "AI 代码生成"
load_env
if [[ -f "$REPO_ROOT/ai-code-gen.sh" ]]; then
  run bash "$REPO_ROOT/ai-code-gen.sh" "$@"
else
  err "未找到 ai-code-gen.sh"
  exit 1
fi
