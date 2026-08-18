#!/bin/bash

##############################################################################
# @fileoverview YYC³ 统一日志系统
# @description 提供统一的日志记录功能，支持多级别、多输出目标
# @author YYC³ Team
# @version 1.0.0
# @created 2026-02-28
# @modified 2026-02-28
# @copyright Copyright (c) 2026 YYC³
# @license MIT
#
# 遵循YYC³项目的五高五标五化实施规范
##############################################################################

# ==============================================================================
# 1. 日志级别定义
# ==============================================================================

readonly LOG_LEVEL_DEBUG=0
readonly LOG_LEVEL_INFO=1
readonly LOG_LEVEL_NOTICE=2
readonly LOG_LEVEL_WARNING=3
readonly LOG_LEVEL_ERROR=4
readonly LOG_LEVEL_CRITICAL=5

# 当前日志级别（可通过环境变量LOG_LEVEL设置）
CURRENT_LOG_LEVEL=${LOG_LEVEL_INFO}

# ==============================================================================
# 2. 颜色定义（YYC³品牌色系）
# ==============================================================================

readonly COLOR_RESET="\033[0m"
readonly COLOR_BLACK="\033[0;30m"
readonly COLOR_RED="\033[0;31m"
readonly COLOR_GREEN="\033[0;32m"
readonly COLOR_YELLOW="\033[1;33m"
readonly COLOR_BLUE="\033[0;34m"
readonly COLOR_MAGENTA="\033[0;35m"
readonly COLOR_CYAN="\033[0;36m"
readonly COLOR_WHITE="\033[0;37m"

# YYC³品牌颜色
readonly YYC3_COLOR_PRIMARY="\033[0;36m"    # 青色
readonly YYC3_COLOR_SECONDARY="\033[0;34m"  # 蓝色
readonly YYC3_COLOR_ACCENT="\033[1;33m"     # 黄色
readonly YYC3_COLOR_SUCCESS="\033[0;32m"     # 绿色
readonly YYC3_COLOR_ERROR="\033[0;31m"       # 红色
readonly YYC3_COLOR_WARNING="\033[1;33m"     # 黄色

# ==============================================================================
# 3. 日志配置
# ==============================================================================

# 日志目录
LOG_DIR="${LOG_DIR:-$(pwd)/logs}"

# 日志文件名
LOG_FILE="${LOG_FILE:-${LOG_DIR}/yyc3-$(date +"%Y%m%d_%H%M%S").log}"

# 日志格式
LOG_FORMAT="${LOG_FORMAT:-[%Y-%m-%d %H:%M:%S] [%LEVEL] [%SOURCE] %MESSAGE}"

# 是否输出到控制台
LOG_TO_CONSOLE="${LOG_TO_CONSOLE:-true}"

# 是否输出到文件
LOG_TO_FILE="${LOG_TO_FILE:-true}"

# 是否启用彩色输出
LOG_COLOR="${LOG_COLOR:-true}"

# ==============================================================================
# 4. 日志格式化函数
# ==============================================================================

# 格式化日志消息
format_log_message() {
    local level="$1"
    local message="$2"
    local source="${3:-$(basename "${BASH_SOURCE[1]}")}"

    local timestamp="$(date +"%Y-%m-%d %H:%M:%S")"
    local formatted_message="${LOG_FORMAT//%Y/$timestamp}"
    formatted_message="${formatted_message//%LEVEL/$level}"
    formatted_message="${formatted_message//%SOURCE/$source}"
    formatted_message="${formatted_message//%MESSAGE/$message}"

    echo "$formatted_message"
}

# 获取日志级别名称
get_level_name() {
    local level="$1"

    case "$level" in
        $LOG_LEVEL_DEBUG) echo "DEBUG" ;;
        $LOG_LEVEL_INFO) echo "INFO" ;;
        $LOG_LEVEL_NOTICE) echo "NOTICE" ;;
        $LOG_LEVEL_WARNING) echo "WARNING" ;;
        $LOG_LEVEL_ERROR) echo "ERROR" ;;
        $LOG_LEVEL_CRITICAL) echo "CRITICAL" ;;
        *) echo "UNKNOWN" ;;
    esac
}

# 获取日志级别颜色
get_level_color() {
    local level="$1"

    case "$level" in
        $LOG_LEVEL_DEBUG) echo "$COLOR_CYAN" ;;
        $LOG_LEVEL_INFO) echo "$YYC3_COLOR_PRIMARY" ;;
        $LOG_LEVEL_NOTICE) echo "$YYC3_COLOR_SUCCESS" ;;
        $LOG_LEVEL_WARNING) echo "$YYC3_COLOR_WARNING" ;;
        $LOG_LEVEL_ERROR) echo "$YYC3_COLOR_ERROR" ;;
        $LOG_LEVEL_CRITICAL) echo "$COLOR_BOLD_RED" ;;
        *) echo "$COLOR_RESET" ;;
    esac
}

# ==============================================================================
# 5. 日志输出函数
# ==============================================================================

# 输出日志到控制台和文件
output_log() {
    local level="$1"
    local message="$2"
    local source="${3:-$(basename "${BASH_SOURCE[1]}")}"

    local level_name=$(get_level_name "$level")
    local formatted_message=$(format_log_message "$level_name" "$message" "$source")

    # 输出到控制台
    if [ "$LOG_TO_CONSOLE" = "true" ]; then
        if [ "$LOG_COLOR" = "true" ]; then
            local level_color=$(get_level_color "$level")
            echo -e "${level_color}${formatted_message}${COLOR_RESET}"
        else
            echo "$formatted_message"
        fi
    fi

    # 输出到文件
    if [ "$LOG_TO_FILE" = "true" ]; then
        # 确保日志目录存在
        mkdir -p "$LOG_DIR"
        # 写入日志文件（不带颜色）
        echo "$formatted_message" >> "$LOG_FILE"
    fi
}

# ==============================================================================
# 6. 日志级别函数
# ==============================================================================

# 调试日志
log_debug() {
    if [ "$CURRENT_LOG_LEVEL" -le "$LOG_LEVEL_DEBUG" ]; then
        output_log "$LOG_LEVEL_DEBUG" "$@"
    fi
}

# 信息日志
log_info() {
    if [ "$CURRENT_LOG_LEVEL" -le "$LOG_LEVEL_INFO" ]; then
        output_log "$LOG_LEVEL_INFO" "$@"
    fi
}

# 通知日志
log_notice() {
    if [ "$CURRENT_LOG_LEVEL" -le "$LOG_LEVEL_NOTICE" ]; then
        output_log "$LOG_LEVEL_NOTICE" "$@"
    fi
}

# 警告日志
log_warning() {
    if [ "$CURRENT_LOG_LEVEL" -le "$LOG_LEVEL_WARNING" ]; then
        output_log "$LOG_LEVEL_WARNING" "$@"
    fi
}

# 错误日志
log_error() {
    if [ "$CURRENT_LOG_LEVEL" -le "$LOG_LEVEL_ERROR" ]; then
        output_log "$LOG_LEVEL_ERROR" "$@" >&2
    fi
}

# 严重错误日志
log_critical() {
    if [ "$CURRENT_LOG_LEVEL" -le "$LOG_LEVEL_CRITICAL" ]; then
        output_log "$LOG_LEVEL_CRITICAL" "$@" >&2
    fi
}

# ==============================================================================
# 7. 日志管理函数
# ==============================================================================

# 设置日志级别
set_log_level() {
    local level="$1"

    case "$level" in
        "debug"|"DEBUG") CURRENT_LOG_LEVEL=$LOG_LEVEL_DEBUG ;;
        "info"|"INFO") CURRENT_LOG_LEVEL=$LOG_LEVEL_INFO ;;
        "notice"|"NOTICE") CURRENT_LOG_LEVEL=$LOG_LEVEL_NOTICE ;;
        "warning"|"WARNING") CURRENT_LOG_LEVEL=$LOG_LEVEL_WARNING ;;
        "error"|"ERROR") CURRENT_LOG_LEVEL=$LOG_LEVEL_ERROR ;;
        "critical"|"CRITICAL") CURRENT_LOG_LEVEL=$LOG_LEVEL_CRITICAL ;;
        *)
            log_error "无效的日志级别: $level"
            return 1
            ;;
    esac

    log_info "日志级别已设置为: $(get_level_name $CURRENT_LOG_LEVEL)"
    return 0
}

# 设置日志目录
set_log_dir() {
    local dir="$1"

    if [ ! -d "$dir" ]; then
        mkdir -p "$dir" || {
            log_error "无法创建日志目录: $dir"
            return 1
        }
    fi

    LOG_DIR="$dir"
    log_info "日志目录已设置为: $dir"
    return 0
}

# 清理旧日志文件
cleanup_old_logs() {
    local days="${1:-30}"

    log_info "清理 $days 天前的旧日志文件..."

    if [ -d "$LOG_DIR" ]; then
        find "$LOG_DIR" -name "yyc3-*.log" -type f -mtime +$days -delete
        log_notice "旧日志文件清理完成"
    else
        log_warning "日志目录不存在: $LOG_DIR"
    fi
}

# 显示日志统计
show_log_stats() {
    log_info "日志统计信息..."

    if [ -d "$LOG_DIR" ]; then
        local total_files=$(find "$LOG_DIR" -name "yyc3-*.log" -type f | wc -l)
        local total_size=$(du -sh "$LOG_DIR" | cut -f1)

        echo "  日志文件数量: $total_files"
        echo "  日志目录大小: $total_size"
        echo "  日志目录路径: $LOG_DIR"
    else
        log_warning "日志目录不存在: $LOG_DIR"
    fi
}

# ==============================================================================
# 8. 便捷函数
# ==============================================================================

# 成功消息（带图标）
log_success() {
    log_notice "✓ $@"
}

# 失败消息（带图标）
log_failure() {
    log_error "✗ $@"
}

# 进度消息（带图标）
log_progress() {
    log_info "⟳ $@"
}

# 完成消息（带图标）
log_complete() {
    log_notice "✔ $@"
}

# 警告消息（带图标）
log_alert() {
    log_warning "⚠ $@"
}

# ==============================================================================
# 9. 初始化函数
# ==============================================================================

# 初始化日志系统
init_logger() {
    # 创建日志目录
    mkdir -p "$LOG_DIR"

    # 设置日志级别
    if [ -n "$LOG_LEVEL" ]; then
        set_log_level "$LOG_LEVEL"
    fi

    log_info "YYC³ 日志系统已初始化"
    log_debug "日志目录: $LOG_DIR"
    log_debug "日志级别: $(get_level_name $CURRENT_LOG_LEVEL)"
}

# ==============================================================================
# 10. 主执行函数
# ==============================================================================

# 如果直接执行此脚本，则显示帮助信息
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    echo "YYC³ 统一日志系统"
    echo ""
    echo "用法: source scripts/utils/yyc3-logger.sh"
    echo ""
    echo "可用函数:"
    echo "  log_debug(message)      - 调试日志"
    echo "  log_info(message)       - 信息日志"
    echo "  log_notice(message)     - 通知日志"
    echo "  log_warning(message)    - 警告日志"
    echo "  log_error(message)      - 错误日志"
    echo "  log_critical(message)   - 严重错误日志"
    echo "  log_success(message)    - 成功消息"
    echo "  log_failure(message)    - 失败消息"
    echo "  log_progress(message)   - 进度消息"
    echo "  log_complete(message)   - 完成消息"
    echo "  log_alert(message)      - 警告消息"
    echo ""
    echo "配置函数:"
    echo "  set_log_level(level)    - 设置日志级别"
    echo "  set_log_dir(dir)       - 设置日志目录"
    echo "  cleanup_old_logs(days)  - 清理旧日志"
    echo "  show_log_stats()       - 显示日志统计"
    echo ""
    echo "环境变量:"
    echo "  LOG_LEVEL              - 日志级别 (debug|info|notice|warning|error|critical)"
    echo "  LOG_DIR               - 日志目录"
    echo "  LOG_FILE              - 日志文件名"
    echo "  LOG_TO_CONSOLE        - 是否输出到控制台 (true|false)"
    echo "  LOG_TO_FILE           - 是否输出到文件 (true|false)"
    echo "  LOG_COLOR             - 是否启用彩色输出 (true|false)"
fi
