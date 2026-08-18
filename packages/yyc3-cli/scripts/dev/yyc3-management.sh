#!/bin/bash

# =============================================================================
# @file yyc3-management.sh
# @description YYC³ 系统管理脚本
# @module scripts/management
# @author YYC³
# @version 2.0.0
# @created 2026-01-30
# @updated 2026-01-30
# @copyright Copyright (c) 2026 YYC³
# @license MIT
# =============================================================================

set -euo pipefail
IFS=$'\n\t'

# 颜色定义
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly MAGENTA='\033[0;35m'
readonly CYAN='\033[0;36m'
readonly WHITE='\033[1;37m'
readonly NC='\033[0m' # No Color

# 日志级别
readonly LOG_ERROR=0
readonly LOG_WARN=1
readonly LOG_INFO=2
readonly LOG_DEBUG=3
LOG_LEVEL=${LOG_LEVEL:-2}

# 目录常量
readonly YYC3_HOME="${YYC3_HOME:-$HOME/.yyc3}"
readonly YYC3_CONFIG="${YYC3_CONFIG:-$YYC3_HOME/config.yaml}"
readonly YYC3_LOGS="${YYC3_LOGS:-/var/log/yyc3}"
readonly YYC3_DATA="${YYC3_DATA:-/var/lib/yyc3}"

# -----------------------------------------------------------------------------
# 日志函数
# -----------------------------------------------------------------------------

log() {
  local level="$1"
  local message="$2"
  local timestamp
  timestamp=$(date '+%Y-%m-%d %H:%M:%S')

  case "$level" in
    "$LOG_ERROR")
      if [[ "$LOG_LEVEL" -ge "$LOG_ERROR" ]]; then
        echo -e "${RED}🔴 [ERROR]${NC} [$timestamp] $message" >&2
      fi
      ;;
    "$LOG_WARN")
      if [[ "$LOG_LEVEL" -ge "$LOG_WARN" ]]; then
        echo -e "${YELLOW}🟡 [WARN]${NC} [$timestamp] $message" >&2
      fi
      ;;
    "$LOG_INFO")
      if [[ "$LOG_LEVEL" -ge "$LOG_INFO" ]]; then
        echo -e "${GREEN}🟢 [INFO]${NC} [$timestamp] $message"
      fi
      ;;
    "$LOG_DEBUG")
      if [[ "$LOG_LEVEL" -ge "$LOG_DEBUG" ]]; then
        echo -e "${BLUE}🔵 [DEBUG]${NC} [$timestamp] $message"
      fi
      ;;
  esac
}

log_error() { log "$LOG_ERROR" "$1"; }
log_warn() { log "$LOG_WARN" "$1"; }
log_info() { log "$LOG_INFO" "$1"; }
log_debug() { log "$LOG_DEBUG" "$1"; }

# -----------------------------------------------------------------------------
# 工具函数
# -----------------------------------------------------------------------------

print_banner() {
  echo -e "${MAGENTA}"
  echo "╔════════════════════════════════════════════════════════════╗"
  echo "║                    YYC³ 管理系统                          ║"
  echo "║      言启象限 | 语枢未来 | 万象归元于云枢                ║"
  echo "╚════════════════════════════════════════════════════════════╝"
  echo -e "${NC}"
  echo -e "${CYAN}版本: 2.0.0 | 作者: YYC³团队 | 时间: $(date)${NC}"
  echo ""
}

validate_port() {
  local port="$1"

  if ! [[ "$port" =~ ^[0-9]+$ ]]; then
    log_error "端口必须是数字: $port"
    return 1
  fi

  if (( port < 1024 || port > 65535 )); then
    log_error "端口必须在1024-65535范围内: $port"
    return 1
  fi

  # YYC³ 端口合规性检查
  if (( port >= 3000 && port <= 3199 )); then
    log_error "端口 $port 在限用范围(3000-3199)内，请使用3200-3500范围"
    return 1
  fi

  # 检查端口是否被占用
  if command -v lsof > /dev/null 2>&1; then
    if lsof -i:"$port" > /dev/null 2>&1; then
      log_warn "端口 $port 已被占用"
      return 2
    fi
  fi

  return 0
}

check_system_requirements() {
  log_info "检查系统要求..."

  # 检查bash版本
  local bash_version
  bash_version=$(bash --version | head -n1 | awk '{print $4}' | cut -d'(' -f1)
  log_info "Bash版本: $bash_version"

  if [[ $(echo "$bash_version" | cut -d'.' -f1) -lt 4 ]]; then
    log_warn "建议使用Bash 4.0或更高版本"
  fi

  # 检查磁盘空间
  local disk_info
  disk_info=$(df -h / | tail -1)
  local available_space
  available_space=$(echo "$disk_info" | awk '{print $4}')
  local use_percent
  use_percent=$(echo "$disk_info" | awk '{print $5}' | sed 's/%//')

  log_info "可用磁盘空间: $available_space"

  if (( use_percent > 90 )); then
    log_error "磁盘使用率超过90%！请清理磁盘空间"
    return 1
  elif (( use_percent > 80 )); then
    log_warn "磁盘使用率超过80%，建议清理"
  fi

  # 检查内存
  if command -v free > /dev/null 2>&1; then
    local mem_info
    mem_info=$(free -h | grep Mem)
    local total_mem
    total_mem=$(echo "$mem_info" | awk '{print $2}')
    local used_mem
    used_mem=$(echo "$mem_info" | awk '{print $3}')
    log_info "内存: $used_mem / $total_mem"
  fi

  # 检查CPU核心数
  local cpu_cores
  cpu_cores=$(nproc 2>/dev/null || sysctl -n hw.ncpu 2>/dev/null || echo "unknown")
  log_info "CPU核心数: $cpu_cores"

  log_success "系统要求检查完成"
  return 0
}

main "$@"
