#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../utils/common.sh
source "$SCRIPT_DIR/../utils/common.sh"

section "AI 自动推进 (监视模式)"
load_env
mode=${1:-review} # review|gen
interval=${INTERVAL:-2}

if ! command -v git >/dev/null 2>&1; then
  err "需要 git"
  exit 1
fi

run_once() {
  local files
  # 获取改动文件列表（未提交和已暂存）
  mapfile -t files < <(git status --porcelain | awk '{print $2}' | sed 's/^\"//; s/\"$//' | sort -u)
  if [[ ${#files[@]} -eq 0 ]]; then
    log "无变更，跳过"
    return 0
  fi
  echo "变更文件: ${files[*]}"
  case "$mode" in
    review)
      if [[ -f "$REPO_ROOT/ai-code-review.sh" ]]; then
        bash "$REPO_ROOT/ai-code-review.sh" "${files[@]}" || true
      else
        warn "未找到 ai-code-review.sh"
      fi
      ;;
    gen)
      if [[ -f "$REPO_ROOT/ai-code-gen.sh" ]]; then
        bash "$REPO_ROOT/ai-code-gen.sh" "${files[@]}" || true
      else
        warn "未找到 ai-code-gen.sh"
      fi
      ;;
    *) err "未知模式: $mode"; return 1 ;;
  esac
}

if command -v fswatch >/dev/null 2>&1; then
  ok "使用 fswatch 进行实时监视 (模式: $mode)"
  fswatch -or "$REPO_ROOT" | while read -r _; do
    run_once
    sleep "$interval"
  done
else
  warn "未安装 fswatch，使用轮询模式 (每${interval}s)"
  while true; do
    run_once
    sleep "$interval"
  done
fi
