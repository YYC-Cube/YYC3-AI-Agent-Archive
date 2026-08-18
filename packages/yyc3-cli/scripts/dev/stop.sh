#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../utils/common.sh
source "$SCRIPT_DIR/../utils/common.sh"

section "停止本地开发服务"
load_env
check_docker_running || true

compose_file="docker-compose.yml"
service="${1:-}"
if [[ -f "$REPO_ROOT/$compose_file" ]]; then
  if [[ -n "$service" ]]; then
    run docker_compose -f "$REPO_ROOT/$compose_file" stop "$service"
  else
    run docker_compose -f "$REPO_ROOT/$compose_file" down
  fi
  ok "服务已停止"
else
  warn "未找到 $compose_file，跳过"
fi
