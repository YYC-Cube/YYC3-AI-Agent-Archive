#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../utils/common.sh
source "$SCRIPT_DIR/../utils/common.sh"

section "日志清理"
check_docker_running || { warn "Docker 未运行，跳过容器日志"; exit 0; }

compose_file="$REPO_ROOT/docker-compose.yml"
if [[ -f "$compose_file" ]]; then
  mapfile -t names < <(docker_compose -f "$compose_file" ps --services)
  for s in "${names[@]}"; do
    cid=$(docker_compose -f "$compose_file" ps -q "$s" || true)
    if [[ -n "${cid:-}" ]]; then
      warn "清理日志: $s ($cid)"
      : > "$(docker inspect --format='{{.LogPath}}' "$cid")" || true
    fi
  done
fi
ok "日志清理完成"
