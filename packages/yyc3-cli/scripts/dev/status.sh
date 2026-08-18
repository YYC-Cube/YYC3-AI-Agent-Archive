#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../utils/common.sh
source "$SCRIPT_DIR/../utils/common.sh"

section "服务状态"
load_env
print_device

compose_file="docker-compose.yml"
service="${1:-}"
if [[ -f "$REPO_ROOT/$compose_file" ]]; then
  if docker info >/dev/null 2>&1; then
    if [[ -n "$service" ]]; then
      run docker_compose -f "$REPO_ROOT/$compose_file" ps "$service"
    else
      run docker_compose -f "$REPO_ROOT/$compose_file" ps
    fi
  else
    warn "Docker 未运行，无法查询容器状态"
  fi
else
  warn "未找到 $compose_file"
fi

if ollama_running; then ok "Ollama: 运行中"; else warn "Ollama: 未运行 (可选)"; fi
