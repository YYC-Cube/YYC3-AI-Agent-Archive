#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../utils/common.sh
source "$SCRIPT_DIR/../utils/common.sh"

section "缓存清理 (安全)"
TARGETS=(
  "$REPO_ROOT/node_modules"
  "$REPO_ROOT/.cache"
  "$HOME/.cache/npm"
  "$HOME/.cache/yarn"
  "$HOME/Library/Caches/Ollama"
)

for t in "${TARGETS[@]}"; do
  if [[ -e "$t" ]]; then
    warn "删除: $t"
    rm -rf "$t"
  fi
done
ok "缓存清理完成"
