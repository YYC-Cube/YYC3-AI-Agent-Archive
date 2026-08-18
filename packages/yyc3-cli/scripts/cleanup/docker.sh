#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../utils/common.sh
source "$SCRIPT_DIR/../utils/common.sh"

YES=${YES:-0}

section "Docker 资源清理"
check_docker_running || { warn "Docker 未运行，跳过"; exit 0; }

cleanup() {
  run docker system prune -f
  run docker volume prune -f || true
  run docker builder prune -f || true
}

if [[ "$YES" == "1" ]]; then
  cleanup
else
  if confirm "是否清理未使用的容器/镜像/缓存?"; then
    cleanup
  else
    warn "已取消"
  fi
fi
ok "Docker 清理完成"
