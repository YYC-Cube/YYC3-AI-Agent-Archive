#!/bin/bash

##############################################################################
# @fileoverview YYC³ 统一环境变量加载器
# @description 提供统一的环境变量加载和配置管理功能
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
# 1. 环境变量文件路径配置
# ==============================================================================

# 获取脚本所在目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"

# 环境变量文件路径（按优先级排序）
ENV_FILES=(
    "${PROJECT_ROOT}/.env.local"           # 本地覆盖配置（最高优先级）
    "${PROJECT_ROOT}/.env.production"      # 生产环境配置
    "${PROJECT_ROOT}/.env.staging"        # 预发布环境配置
    "${PROJECT_ROOT}/.env.development"     # 开发环境配置
    "${PROJECT_ROOT}/.env"               # 默认配置
    "${PROJECT_ROOT}/env.yyc3.full"       # YYC³全量配置
)

# ==============================================================================
# 2. 环境变量加载函数
# ==============================================================================

# 加载环境变量文件
load_env_file() {
    local env_file="$1"

    if [ -f "$env_file" ]; then
        echo "[INFO] 加载环境变量文件: $env_file"
        # 只加载非注释行和非空行
        while IFS='=' read -r key value; do
            # 跳过注释和空行
            [[ "$key" =~ ^[[:space:]]*# ]] && continue
            [[ -z "$key" ]] && continue

            # 移除前后空格
            key=$(echo "$key" | xargs)
            value=$(echo "$value" | xargs)

            # 导出环境变量
            export "$key=$value"
        done < "$env_file"
        return 0
    else
        echo "[WARN] 环境变量文件不存在: $env_file"
        return 1
    fi
}

# 按优先级加载环境变量
load_all_env() {
    echo "[INFO] 开始加载环境变量..."

    local loaded_count=0
    for env_file in "${ENV_FILES[@]}"; do
        if load_env_file "$env_file"; then
            ((loaded_count++))
        fi
    done

    echo "[INFO] 环境变量加载完成，共加载 $loaded_count 个配置文件"
}

# ==============================================================================
# 3. 环境变量获取函数
# ==============================================================================

# 获取环境变量（带默认值）
get_env_var() {
    local var_name="$1"
    local default_value="${2:-}"

    if [ -n "${!var_name}" ]; then
        echo "${!var_name}"
    else
        echo "$default_value"
    fi
}

# 获取必需的环境变量（如果不存在则报错）
get_required_env_var() {
    local var_name="$1"
    local error_message="${2:-环境变量 $var_name 未设置}"

    if [ -z "${!var_name}" ]; then
        echo "[ERROR] $error_message" >&2
        exit 1
    fi

    echo "${!var_name}"
}

# ==============================================================================
# 4. 常用配置获取函数
# ==============================================================================

# 获取NAS配置
get_nas_config() {
    echo "NAS_HOST=$(get_env_var NAS_HOST '192.168.3.45')"
    echo "NAS_PORT=$(get_env_var NAS_SSH_PORT '9557')"
    echo "NAS_USER=$(get_env_var NAS_SSH_USER 'YYC')"
    echo "NAS_HTTP_PORT=$(get_env_var NAS_HTTP_PORT '8989')"
    echo "NAS_HTTPS_PORT=$(get_env_var NAS_HTTPS_PORT '9898')"
}

# 获取网络配置
get_network_config() {
    echo "NEW_IP=$(get_env_var NAS_HOST '192.168.3.45')"
    echo "NEW_DOMAIN=$(get_env_var NEW_DOMAIN 'china.0379.pro')"
    echo "NEW_EMAIL_SERVER=$(get_env_var NEW_EMAIL_SERVER '0379.email')"
}

# 获取项目路径配置
get_project_paths() {
    echo "PROJECT_ROOT=$(get_env_var PROJECT_ROOT '$PROJECT_ROOT')"
    echo "ROOT_DIR=$(get_env_var ROOT_DIR '$PROJECT_ROOT')"
    echo "SCRIPT_DIR=$(get_env_var SCRIPT_DIR '$SCRIPT_DIR')"
}

# ==============================================================================
# 5. 环境验证函数
# ==============================================================================

# 验证必需的环境变量
validate_env_vars() {
    local required_vars=("$@")

    echo "[INFO] 验证环境变量..."

    local missing_vars=()
    for var_name in "${required_vars[@]}"; do
        if [ -z "${!var_name}" ]; then
            missing_vars+=("$var_name")
        fi
    done

    if [ ${#missing_vars[@]} -gt 0 ]; then
        echo "[ERROR] 缺少必需的环境变量: ${missing_vars[*]}" >&2
        return 1
    fi

    echo "[INFO] 环境变量验证通过"
    return 0
}

# 验证IP地址格式
validate_ip() {
    local ip="$1"

    if [[ "$ip" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]; then
        return 0
    else
        echo "[ERROR] 无效的IP地址: $ip" >&2
        return 1
    fi
}

# ==============================================================================
# 6. 环境信息显示函数
# ==============================================================================

# 显示当前环境信息
show_env_info() {
    echo ""
    echo "============================================"
    echo "  YYC³ 环境配置信息"
    echo "============================================"
    echo "  项目根目录: $PROJECT_ROOT"
    echo "  脚本目录: $SCRIPT_DIR"
    echo "  环境类型: ${NODE_ENV:-development}"
    echo "  NAS主机: ${NAS_HOST:-未设置}"
    echo "  NAS端口: ${NAS_SSH_PORT:-未设置}"
    echo "============================================"
    echo ""
}

# ==============================================================================
# 7. 主执行函数
# ==============================================================================

# 初始化环境
init_env() {
    # 加载所有环境变量
    load_all_env

    # 设置默认值
    export PROJECT_ROOT="${PROJECT_ROOT:-$(pwd)}"
    export SCRIPT_DIR="${SCRIPT_DIR:-$(pwd)}"
    export NODE_ENV="${NODE_ENV:-development}"

    # 显示环境信息
    show_env_info
}

# 如果直接执行此脚本，则初始化环境
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    init_env
fi
