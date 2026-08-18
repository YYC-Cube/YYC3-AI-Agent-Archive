#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../utils/common.sh
source "$SCRIPT_DIR/../utils/common.sh"

section "开发环境初始化"
load_env
print_device

section "检查依赖"
require_cmd docker
require_cmd git
require_cmd awk
if command -v node >/dev/null 2>&1; then ok "Node.js: $(node -v)"; else warn "未安装 Node.js (可选)"; fi
if command -v npm  >/dev/null 2>&1; then ok "npm: $(npm -v)"; else warn "未安装 npm (可选)"; fi
if command -v jq   >/dev/null 2>&1; then ok "jq: $(jq --version)"; else warn "未安装 jq (可选)"; fi

section "检测 Docker 服务"
check_docker_running || exit 1
ok "Docker 已就绪: $(docker --version | awk '{print $3}')"

section "同步环境变量"
if [[ -f "$REPO_ROOT/sync-env.sh" ]]; then
  run bash "$REPO_ROOT/sync-env.sh"
else
  warn "未找到 sync-env.sh，跳过同步"
fi

section "配置 Git 钩子 (husky)"
if [[ -d "$REPO_ROOT/.husky" && -f "$REPO_ROOT/husky.config.js" ]]; then
  ok "Husky 已存在"
else
  warn "未配置 husky，后续可按需添加"
fi

section "完成"
ok "开发环境初始化完成。可执行: $REPO_ROOT/devctl start"
