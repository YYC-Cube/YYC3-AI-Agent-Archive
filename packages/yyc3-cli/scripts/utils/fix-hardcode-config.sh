#!/bin/bash

##############################################################################
# @fileoverview YYC³ 硬编码配置修复脚本
# @description 批量移除硬编码的IP地址和路径，替换为环境变量
# @author YYC³ Team
# @version 1.0.0
# @created 2026-02-28
# @modified 2026-02-28
# @copyright Copyright (c) 2026 YYC³
# @license MIT
#
# 遵循YYC³项目的五高五标五化实施规范
##############################################################################

set -e

# ==============================================================================
# 1. 配置
# ==============================================================================

# 项目根目录
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

# 需要修复的硬编码值
HARDCODED_IP="192.168.3.45"
HARDCODED_PATH="/Volume2/"

# 替换为的环境变量
IP_VAR="\${NAS_HOST}"
PATH_VAR="\${PROJECT_ROOT}"

# 备份目录
BACKUP_DIR="${PROJECT_ROOT}/backups/hardcode-fix-$(date +"%Y%m%d_%H%M%S")"

# 颜色定义
readonly COLOR_RED='\033[0;31m'
readonly COLOR_GREEN='\033[0;32m'
readonly COLOR_YELLOW='\033[1;33m'
readonly COLOR_BLUE='\033[0;34m'
readonly COLOR_CYAN='\033[0;36m'
readonly COLOR_RESET='\033[0m'

# ==============================================================================
# 2. 工具函数
# ==============================================================================

log_info() { echo -e "${COLOR_BLUE}[信息]${COLOR_RESET} $1"; }
log_success() { echo -e "${COLOR_GREEN}[成功]${COLOR_RESET} $1"; }
log_warning() { echo -e "${COLOR_YELLOW}[警告]${COLOR_RESET} $1"; }
log_error() { echo -e "${COLOR_RED}[错误]${COLOR_RESET} $1"; }

# 创建备份目录
create_backup() {
    mkdir -p "$BACKUP_DIR"
    log_info "备份目录已创建: $BACKUP_DIR"
}

# 备份文件
backup_file() {
    local file="$1"
    local backup_path="${BACKUP_DIR}/$(basename "$file")"

    if [ -f "$file" ]; then
        cp "$file" "$backup_path"
        log_info "已备份: $file -> $backup_path"
    fi
}

# ==============================================================================
# 3. 修复函数
# ==============================================================================

# 修复IP地址硬编码
fix_hardcoded_ip() {
    local file="$1"
    local count=0

    # 检查文件是否包含硬编码IP
    if grep -q "$HARDCODED_IP" "$file" 2>/dev/null; then
        # 备份文件
        backup_file "$file"

        # 统计替换次数
        count=$(grep -o "$HARDCODED_IP" "$file" | wc -l)

        # 执行替换
        sed -i.bak "s|$HARDCODED_IP|\$NAS_HOST|g" "$file"
        rm -f "${file}.bak"

        log_success "已修复 $file (替换 $count 处硬编码IP)"
        return 0
    fi

    return 1
}

# 修复路径硬编码
fix_hardcoded_path() {
    local file="$1"
    local count=0

    # 检查文件是否包含硬编码路径
    if grep -q "$HARDCODED_PATH" "$file" 2>/dev/null; then
        # 备份文件
        backup_file "$file"

        # 统计替换次数
        count=$(grep -o "$HARDCODED_PATH" "$file" | wc -l)

        # 执行替换
        sed -i.bak "s|$HARDCODED_PATH|\$PROJECT_ROOT|g" "$file"
        rm -f "${file}.bak"

        log_success "已修复 $file (替换 $count 处硬编码路径)"
        return 0
    fi

    return 1
}

# 修复文件中的所有硬编码
fix_file() {
    local file="$1"

    log_info "检查文件: $file"

    local fixed=false

    # 修复IP地址
    if fix_hardcoded_ip "$file"; then
        fixed=true
    fi

    # 修复路径
    if fix_hardcoded_path "$file"; then
        fixed=true
    fi

    if [ "$fixed" = false ]; then
        log_info "文件无需修复: $file"
    fi
}

# 批量修复目录中的所有文件
fix_directory() {
    local dir="$1"
    local file_pattern="${2:-*.sh}"

    log_info "开始修复目录: $dir"

    local total_files=0
    local fixed_files=0

    # 查找所有匹配的文件
    while IFS= read -r -d '' file; do
        ((total_files++))

        if fix_file "$file"; then
            ((fixed_files++))
        fi
    done < <(find "$dir" -name "$file_pattern" -type f -print0)

    log_success "目录修复完成: $dir (共 $total_files 个文件，修复 $fixed_files 个)"
}

# ==============================================================================
# 4. 主执行流程
# ==============================================================================

main() {
    echo ""
    echo -e "${COLOR_CYAN}"
    cat << 'EOF'
    ██╗   ██╗ █████╗ ██╗  ██╗██╗   ██╗
    ██║   ██║██╔══██╗██║ ██╔╝██║   ██║
    ██║   ██║███████║█████╔╝ ██║   ██║
    ██║   ██║██╔══██║██╔═██╗ ██║   ██║
    ╚██████╔╝██║  ██║██║  ██╗╚██████╔╝
     ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝

    YYC³ 硬编码配置修复工具
    Hardcode Configuration Fixer
    =======================
EOF
    echo -e "${COLOR_RESET}"
    echo ""

    # 创建备份目录
    create_backup

    # 修复脚本文件
    log_info "开始修复脚本文件..."
    fix_directory "${PROJECT_ROOT}/scripts" "*.sh"

    # 修复环境文件
    log_info "开始修复环境文件..."
    fix_directory "${PROJECT_ROOT}" "env.*"

    # 修复配置文件
    log_info "开始修复配置文件..."
    fix_directory "${PROJECT_ROOT}/config" "*.*"

    # 修复文档文件
    log_info "开始修复文档文件..."
    fix_directory "${PROJECT_ROOT}/docs" "*.md"

    # 生成修复报告
    generate_fix_report

    echo ""
    log_success "🎉 硬编码配置修复完成！"
    echo ""
    log_info "📋 修复摘要:"
    echo "  • 备份目录: $BACKUP_DIR"
    echo "  • 硬编码IP: $HARDCODED_IP -> \$NAS_HOST"
    echo "  • 硬编码路径: $HARDCODED_PATH -> \$PROJECT_ROOT"
    echo ""
    log_info "🚀 下一步操作:"
    echo "  1. 检查修复后的文件"
    echo "  2. 运行测试验证功能"
    echo "  3. 如有问题，从备份目录恢复"
    echo ""
}

# 生成修复报告
generate_fix_report() {
    local report_file="${PROJECT_ROOT}/hardcode-fix-report-$(date +"%Y%m%d_%H%M%S").txt"

    cat > "$report_file" << EOF
YYC³ 硬编码配置修复报告
==========================
修复时间: $(date)
项目根目录: $PROJECT_ROOT
备份目录: $BACKUP_DIR

修复内容:
--------
硬编码IP地址: $HARDCODED_IP
替换为环境变量: \$NAS_HOST

硬编码路径: $HARDCODED_PATH
替换为环境变量: \$PROJECT_ROOT

修复的文件类型:
--------
- Shell脚本 (*.sh)
- 环境配置文件 (env.*)
- 配置文件 (*.*)
- 文档文件 (*.md)

建议操作:
--------
1. 检查所有修复后的文件
2. 确保环境变量正确设置
3. 运行相关脚本测试功能
4. 如发现问题，从备份目录恢复原始文件

环境变量配置:
--------
请在 .env 或 env.yyc3.full 文件中设置以下环境变量:

NAS_HOST=192.168.3.45
PROJECT_ROOT=/Volumes/Development/YYC3-CLI

EOF

    log_success "修复报告已生成: $report_file"
}

# ==============================================================================
# 5. 执行主函数
# ==============================================================================

# 检查是否在项目根目录
if [ ! -f "${PROJECT_ROOT}/package.json" ]; then
    log_error "请在YYC³项目根目录中运行此脚本"
    exit 1
fi

# 询问用户确认
echo -n "是否开始修复硬编码配置？(y/N): "
read -r confirm

if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
    log_info "修复已取消"
    exit 0
fi

# 执行主函数
main "$@"
