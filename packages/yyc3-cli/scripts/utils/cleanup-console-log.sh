#!/bin/bash

##############################################################################
# @fileoverview YYC³ console.log清理脚本
# @description 批量清理JavaScript文件中的console.log和debugger语句
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

# 备份目录
BACKUP_DIR="${PROJECT_ROOT}/backups/console-log-cleanup-$(date +"%Y%m%d_%H%M%S")"

# 需要清理的文件扩展名
FILE_EXTENSIONS=("*.js" "*.ts" "*.jsx" "*.tsx")

# 需要清理的模式
PATTERNS=(
    "console\.log"
    "console\.debug"
    "console\.info"
    "console\.warn"
    "console\.error"
    "debugger"
)

# 颜色定义
readonly COLOR_RED='\033[0;31m'
readonly COLOR_GREEN='\033[0;32m'
readonly COLOR_YELLOW='\033[1;33m'
readonly COLOR_BLUE='\033[0;34m'
readonly COLOR_CYAN='\033[0;36m'
readonly COLOR_RESET='\033[0m'

# 统计变量
TOTAL_FILES=0
CLEANED_FILES=0
TOTAL_REMOVALS=0

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
# 3. 清理函数
# ==============================================================================

# 清理单个文件
clean_file() {
    local file="$1"
    local removals=0

    # 检查文件是否需要清理
    local needs_cleanup=false
    for pattern in "${PATTERNS[@]}"; do
        if grep -q "$pattern" "$file" 2>/dev/null; then
            needs_cleanup=true
            break
        fi
    done

    if [ "$needs_cleanup" = false ]; then
        return 1
    fi

    # 备份文件
    backup_file "$file"

    # 统计并移除console.log语句
    for pattern in "${PATTERNS[@]}"; do
        local count=$(grep -c "$pattern" "$file" 2>/dev/null || echo 0)
        if [ $count -gt 0 ]; then
            # 使用sed移除匹配的行
            sed -i.bak "/$pattern/d" "$file"
            rm -f "${file}.bak"
            removals=$((removals + count))
        fi
    done

    if [ $removals -gt 0 ]; then
        log_success "已清理 $file (移除 $removals 处console语句)"
        return 0
    fi

    return 1
}

# 清理目录中的所有文件
clean_directory() {
    local dir="$1"

    log_info "开始清理目录: $dir"

    local dir_files=0
    local dir_cleaned=0
    local dir_removals=0

    # 遍历所有文件扩展名
    for ext in "${FILE_EXTENSIONS[@]}"; do
        # 查找所有匹配的文件
        while IFS= read -r -d '' file; do
            ((dir_files++))

            # 跳过node_modules和备份目录
            if [[ "$file" =~ node_modules ]] || [[ "$file" =~ backups ]]; then
                continue
            fi

            # 清理文件
            if clean_file "$file"; then
                ((dir_cleaned++))
            fi
        done < <(find "$dir" -name "$ext" -type f -print0 2>/dev/null || true)
    done

    log_success "目录清理完成: $dir (共 $dir_files 个文件，清理 $dir_cleaned 个文件)"
}

# ==============================================================================
# 4. 统计函数
# ==============================================================================

# 统计整个项目中的console语句
count_console_statements() {
    log_info "统计项目中的console语句..."

    local total_count=0

    for ext in "${FILE_EXTENSIONS[@]}"; do
        while IFS= read -r -d '' file; do
            # 跳过node_modules和备份目录
            if [[ "$file" =~ node_modules ]] || [[ "$file" =~ backups ]]; then
                continue
            fi

            for pattern in "${PATTERNS[@]}"; do
                local count=$(grep -c "$pattern" "$file" 2>/dev/null || echo 0)
                total_count=$((total_count + count))
            done
        done < <(find "$PROJECT_ROOT" -name "$ext" -type f -print0 2>/dev/null || true)
    done

    echo "  总计: $total_count 处console语句"
    return $total_count
}

# 生成清理报告
generate_cleanup_report() {
    local report_file="${PROJECT_ROOT}/console-log-cleanup-report-$(date +"%Y%m%d_%H%M%S").txt"

    cat > "$report_file" << EOF
YYC³ console.log清理报告
==========================
清理时间: $(date)
项目根目录: $PROJECT_ROOT
备份目录: $BACKUP_DIR

清理统计:
--------
总文件数: $TOTAL_FILES
已清理文件: $CLEANED_FILES
总移除语句: $TOTAL_REMOVALS

清理模式:
--------
$(for pattern in "${PATTERNS[@]}"; do
    echo "- $pattern"
done)

清理的文件类型:
--------
$(for ext in "${FILE_EXTENSIONS[@]}"; do
    echo "- $ext"
done)

建议操作:
--------
1. 检查清理后的文件
2. 运行测试验证功能
3. 如发现问题，从备份目录恢复原始文件
4. 在生产环境部署前进行充分测试

YYC³最佳实践:
--------
1. 使用统一的日志系统（scripts/utils/yyc3-logger.sh）
2. 在开发环境使用debug级别日志
3. 在生产环境使用info及以上级别
4. 避免在生产代码中使用console.log
5. 使用结构化日志记录重要事件

替换示例:
--------
// 旧代码（需要清理）
console.log('调试信息');
console.error('错误信息');
debugger;

// 新代码（推荐）
import { logger } from '@/utils/logger';
logger.debug('调试信息');
logger.error('错误信息');

EOF

    log_success "清理报告已生成: $report_file"
}

# ==============================================================================
# 5. 主执行流程
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

    YYC³ console.log清理工具
    Console.log Cleanup Tool
    =======================
EOF
    echo -e "${COLOR_RESET}"
    echo ""

    # 显示当前统计
    echo "📊 当前console语句统计:"
    count_console_statements
    echo ""

    # 询问用户确认
    echo -n "是否开始清理console语句？(y/N): "
    read -r confirm

    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        log_info "清理已取消"
        exit 0
    fi

    echo ""

    # 创建备份目录
    create_backup

    # 清理脚本目录
    log_info "开始清理脚本目录..."
    clean_directory "${PROJECT_ROOT}/scripts"

    # 清理lib目录
    log_info "开始清理lib目录..."
    clean_directory "${PROJECT_ROOT}/lib"

    # 清理packages目录
    log_info "开始清理packages目录..."
    clean_directory "${PROJECT_ROOT}/packages"

    # 清理bin目录
    log_info "开始清理bin目录..."
    clean_directory "${PROJECT_ROOT}/bin"

    # 清理tests目录
    log_info "开始清理tests目录..."
    clean_directory "${PROJECT_ROOT}/tests"

    # 清理docs目录中的JS文件
    log_info "开始清理docs目录..."
    clean_directory "${PROJECT_ROOT}/docs"

    # 生成清理报告
    generate_cleanup_report

    echo ""
    log_success "🎉 console.log清理完成！"
    echo ""
    log_info "📋 清理摘要:"
    echo "  • 备份目录: $BACKUP_DIR"
    echo "  • 总文件数: $TOTAL_FILES"
    echo "  • 已清理文件: $CLEANED_FILES"
    echo "  • 总移除语句: $TOTAL_REMOVALS"
    echo ""
    log_info "🚀 下一步操作:"
    echo "  1. 检查清理后的文件"
    echo "  2. 运行测试验证功能"
    echo "  3. 如有问题，从备份目录恢复"
    echo ""
}

# ==============================================================================
# 6. 执行主函数
# ==============================================================================

# 检查是否在项目根目录
if [ ! -f "${PROJECT_ROOT}/package.json" ]; then
    log_error "请在YYC³项目根目录中运行此脚本"
    exit 1
fi

# 执行主函数
main "$@"
