#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../utils/common.sh
source "$SCRIPT_DIR/../utils/common.sh"

section "AI 文档生成"
load_env
out=${OUT:-}

if [[ $# -eq 0 ]]; then
  warn "用法: devctl ai:doc <path...> [ENV OUT=path.md]"
fi

if [[ -f "$REPO_ROOT/ai-code-gen.sh" ]]; then
  if [[ -n "$out" ]]; then
    bash "$REPO_ROOT/ai-code-gen.sh" --doc "$@" > "$out" || true
    ok "已生成: $out"
  else
    bash "$REPO_ROOT/ai-code-gen.sh" --doc "$@" || true
  fi
else
  warn "未找到 ai-code-gen.sh，输出模板占位"
  for p in "$@"; do
    echo -e "# 文档: $p\n\n- 目标: TODO\n- 背景: TODO\n- 接口: TODO\n- 注意: TODO\n"
  done
fi
