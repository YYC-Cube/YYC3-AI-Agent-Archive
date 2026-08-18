#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../utils/common.sh
source "$SCRIPT_DIR/../utils/common.sh"

section "同步环境与依赖"
load_env

if [[ -f "$REPO_ROOT/sync-env.sh" ]]; then
  run bash "$REPO_ROOT/sync-env.sh"
fi

if [[ -f "$REPO_ROOT/check-env.sh" ]]; then
  run bash "$REPO_ROOT/check-env.sh"
fi

ok "同步完成"
