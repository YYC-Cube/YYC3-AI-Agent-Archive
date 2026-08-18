#!/usr/bin/env bash
set -euo pipefail

# Project root (repo root)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Load colors
# shellcheck source=colors.sh
source "$REPO_ROOT/scripts/utils/colors.sh"

# Logging helpers
log()   { echo -e "${DIM}[$(date +%H:%M:%S)]${RESET} $*"; }
ok()    { echo -e "${GREEN}✔${RESET} $*"; }
warn()  { echo -e "${YELLOW}⚠${RESET} $*"; }
err()   { echo -e "${RED}✖${RESET} $*" 1>&2; }
section(){ echo -e "${BOLD}${CYAN}==>${RESET} ${BOLD}$*${RESET}"; }

# Run command with echo
run() {
  echo -e "${DIM}$ ${RESET}$*"
  "$@"
}

# Env loader: .env, .env.local, .env.docker, .env.permissions if exist
load_env() {
  local files=("$REPO_ROOT/.env" "$REPO_ROOT/.env.local" "$REPO_ROOT/.env.docker" "$REPO_ROOT/.env.permissions")
  for f in "${files[@]}"; do
    if [[ -f "$f" ]]; then
      set -a
      # shellcheck disable=SC1090
      source "$f"
      set +a
    fi
  done
}

# Get env with default
get_env() {
  local key=$1
  local def=${2-}
  if [[ -n "${!key-}" ]]; then
    echo "${!key}"
  else
    echo "$def"
  fi
}

is_macos() { [[ "$(uname -s)" == "Darwin" ]]; }
is_arm64() { [[ "$(uname -m)" == "arm64" ]]; }

# Require command present
require_cmd() {
  local c=$1
  if ! command -v "$c" >/dev/null 2>&1; then
    err "未找到命令: $c，请先安装。"
    return 127
  fi
}

# docker compose wrapper (supports old docker-compose)
docker_compose() {
  if command -v docker >/dev/null 2>&1 && docker compose version >/dev/null 2>&1; then
    docker compose "$@"
  elif command -v docker-compose >/dev/null 2>&1; then
    docker-compose "$@"
  else
    err "未检测到 docker compose 或 docker-compose"
    return 127
  fi
}

# Check docker daemon
check_docker_running() {
  if ! docker info >/dev/null 2>&1; then
    err "Docker 未运行。请启动 Docker Desktop 后重试。"
    return 1
  fi
}

# Ollama status
ollama_running() {
  if command -v ollama >/dev/null 2>&1; then
    if ollama ps >/dev/null 2>&1; then return 0; else return 1; fi
  fi
  return 1
}

# Print local device summary
print_device() {
  local host chip cores ram storage
  host=$(get_env LOCAL_MBP_HOST_NAME "$(hostname)")
  chip=$(get_env LOCAL_MBP_CHIP "$(sysctl -n machdep.cpu.brand_string 2>/dev/null || echo unknown)")
  cores=$(get_env LOCAL_MBP_CORES "$(sysctl -n hw.ncpu 2>/dev/null || echo ?)")
  ram=$(get_env LOCAL_MBP_RAM "$(/usr/sbin/sysctl -n hw.memsize 2>/dev/null | awk '{printf "%.0fGB", $1/1024/1024/1024}')")
  storage=$(get_env LOCAL_MBP_STORAGE "unknown")
  echo -e "${BOLD}设备:${RESET} $host  ${BOLD}芯片:${RESET} $chip  ${BOLD}核心:${RESET} $cores  ${BOLD}内存:${RESET} $ram  ${BOLD}存储:${RESET} $storage"
}

# Confirm helper
confirm() {
  local msg=${1:-"继续执行?"}
  read -r -p "${msg} [y/N] " ans
  case "$ans" in
    y|Y|yes|YES) return 0 ;;
    *) return 1 ;;
  esac
}
