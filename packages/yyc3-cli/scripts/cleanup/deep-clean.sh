#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../utils/common.sh
source "$SCRIPT_DIR/../utils/common.sh"

section "深度清理"
load_env

if confirm "将执行 Docker 清理与缓存/日志清理，继续?"; then
  bash "$SCRIPT_DIR/docker.sh" YES=1 || true
  bash "$SCRIPT_DIR/logs.sh" || true
  bash "$SCRIPT_DIR/caches.sh" || true
  ok "深度清理完成"
else
  warn "已取消"
fi
