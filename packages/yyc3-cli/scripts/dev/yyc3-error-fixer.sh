#!/bin/bash
#
# @fileoverview YYC³ 错误修复与问题跟踪脚本
# @description 自动检测、修复常见错误，跟踪问题解决进度
# @author YYC³
# @version 1.0.0
# @created 2026-01-30
# @modified 2026-01-30
# @copyright Copyright (c) 2026 YYC³
# @license MIT

set -euo pipefail

# 配置
readonly ERROR_LOG_DIR="/var/log/yyc3-errors"
readonly FIX_REPORT_DIR="/tmp/yyc3-fix-reports"
readonly SUPPORTED_ERRORS=(
    "permission_denied"
    "file_not_found" 
    "syntax_error"
    "dependency_missing"
    "port_conflict"
    "memory_limit"
)

# 颜色定义
readonly COLOR_RED='\033[0;31m'
readonly COLOR_GREEN='\033[0;32m'
readonly COLOR_YELLOW='\033[1;33m'
readonly COLOR_BLUE='\033[0;34m'
readonly COLOR_RESET='\033[0m'

# 显示用法
function show_usage() {
    echo -e "${COLOR_BLUE}用法:${COLOR_RESET}"
    echo "  $0 scan          - 扫描系统错误"
    echo "  $0 fix           - 自动修复检测到的错误"
    echo "  $0 report        - 生成错误报告"
    echo "  $0 monitor       - 持续监控错误"
    echo ""
}

# 扫描错误
function scan_for_errors() {
    echo -e "${COLOR_BLUE}🔍 开始系统错误扫描...${COLOR_RESET}"
    
    local error_count=0
    local errors_found=()
    
    # 检查权限问题
    if [[ ! -x "$0" ]]; then
        errors_found+=("permission_denied:脚本本身缺少执行权限")
        ((error_count++))
    fi
    
    # 检查常见目录
    local critical_dirs=(
        "/Users/yanyu/yyc3-management"
        "/Users/yanyu/yyc3-management/YYC3_CLI"
        "/Users/yanyu/yyc3-management/YYC3_CLI/packages/yyc3-cli"
    )
    
    for dir in "${critical_dirs[@]}"; do
        if [[ ! -d "$dir" ]]; then
            errors_found+=("file_not_found:目录不存在: $dir")
            ((error_count++))
        fi
    done
    
    # 检查CLI可执行文件
    local cli_path="/Users/yanyu/yyc3-management/YYC3_CLI/packages/yyc3-cli/bin/yyc3-cli.js"
    if [[ ! -f "$cli_path" ]]; then
        errors_found+=("file_not_found:CLI主文件不存在: $cli_path")
        ((error_count++))
    fi
    
    # 检查Node.js依赖
    local package_path="/Users/yanyu/yyc3-management/YYC3_CLI/packages/yyc3-cli/package.json"
    if [[ -f "$package_path" ]]; then
        if [[ ! -d "/Users/yanyu/yyc3-management/YYC3_CLI/packages/yyc3-cli/node_modules" ]]; then
            errors_found+=("dependency_missing:Node.js依赖未安装")
            ((error_count++))
        fi
    fi
    
    # 输出结果
    if [[ $error_count -eq 0 ]]; then
        echo -e "${COLOR_GREEN}✅ 未发现系统错误${COLOR_RESET}"
        return 0
    else
        echo -e "${COLOR_YELLOW}⚠️  发现 $error_count 个错误:${COLOR_RESET}"
        for error in "${errors_found[@]}"; do
            echo -e "  ${COLOR_RED}$error${COLOR_RESET}"
        done
        
        # 保存到日志文件
        local timestamp=$(date +"%Y%m%d_%H%M%S")
        mkdir -p "$ERROR_LOG_DIR"
        printf "%s\n" "${errors_found[@]}" > "$ERROR_LOG_DIR/errors_$timestamp.log"
        
        return $error_count
    fi
}

# 修复检测到的错误
function fix_detected_errors() {
    echo -e "${COLOR_BLUE}🔧 开始修复系统错误...${COLOR_RESET}"
    
    local fixes_applied=0
    
    # 1. 修复脚本权限
    echo -e "${COLOR_BLUE}1. 检查脚本执行权限...${COLOR_RESET}"
    local scripts=(
        "yyc3-error-fixer.sh"
        "yyc3-smart-ops.sh"
        "yyc3-management.sh"
        "yyc3-ai.sh"
    )
    
    for script in "${scripts[@]}"; do
        if [[ -f "$script" && ! -x "$script" ]]; then
            chmod +x "$script"
            echo -e "  ${COLOR_GREEN}✅ 已添加执行权限: $script${COLOR_RESET}"
            ((fixes_applied++))
        fi
    done
    
    # 2. 修复目录路径（处理空格问题）
    echo -e "${COLOR_BLUE}2. 检查目录路径...${COLOR_RESET}"
    
    # 如果存在带空格的目录，创建不带空格的符号链接
    if [[ -d "YYC3 CLI" && ! -L "YYC3_CLI" ]]; then
        ln -s "YYC3 CLI" "YYC3_CLI"
        echo -e "  ${COLOR_GREEN}✅ 已创建符号链接: YYC3_CLI -> YYC3 CLI${COLOR_RESET}"
        ((fixes_applied++))
    fi
    
    # 3. 检查CLI项目目录结构
    echo -e "${COLOR_BLUE}3. 检查CLI项目结构...${COLOR_RESET}"
    
    local cli_dir="YYC3_CLI/packages/yyc3-cli"
    if [[ ! -d "$cli_dir" ]]; then
        echo -e "  ${COLOR_YELLOW}⚠️  CLI目录不存在: $cli_dir${COLOR_RESET}"
        echo -e "  ${COLOR_BLUE}  尝试创建目录结构...${COLOR_RESET}"
        
        mkdir -p "$cli_dir/bin"
        mkdir -p "$cli_dir/lib"
        mkdir -p "$cli_dir/__tests__"
        
        echo -e "  ${COLOR_GREEN}✅ 已创建CLI目录结构${COLOR_RESET}"
        ((fixes_applied++))
        
        # 创建基本package.json如果不存在
        local package_file="$cli_dir/package.json"
        if [[ ! -f "$package_file" ]]; then
            cat > "$package_file" << EOF
{
  "name": "yyc3-cli",
  "version": "1.0.0",
  "description": "YYC³ CLI工具",
  "main": "bin/yyc3-cli.js",
  "scripts": {
    "test": "jest --coverage --passWithNoTests",
    "start": "node bin/yyc3-cli.js"
  },
  "dependencies": {
    "commander": "^11.0.0"
  },
  "devDependencies": {
    "jest": "^29.0.0"
  }
}
EOF
            echo -e "  ${COLOR_GREEN}✅ 已创建package.json${COLOR_RESET}"
        fi
    fi
    
    # 4. 安装Node.js依赖
    echo -e "${COLOR_BLUE}4. 检查Node.js依赖...${COLOR_RESET}"
    
    if [[ -d "$cli_dir" && -f "$cli_dir/package.json" ]]; then
        echo -e "  ${COLOR_BLUE}  进入目录: $cli_dir${COLOR_RESET}"
        cd "$cli_dir"
        
        if [[ ! -d "node_modules" ]]; then
            echo -e "  ${COLOR_BLUE}  安装依赖...${COLOR_RESET}"
            npm install
            echo -e "  ${COLOR_GREEN}✅ 依赖安装完成${COLOR_RESET}"
            ((fixes_applied++))
        else
            echo -e "  ${COLOR_GREEN}✅ 依赖已安装${COLOR_RESET}"
        fi
        
        cd - > /dev/null
    fi
    
    # 生成修复报告
    local timestamp=$(date +"%Y%m%d_%H%M%S")
    mkdir -p "$FIX_REPORT_DIR"
    echo "修复完成于: $(date)" > "$FIX_REPORT_DIR/fix_$timestamp.txt"
    echo "应用修复数量: $fixes_applied" >> "$FIX_REPORT_DIR/fix_$timestamp.txt"
    
    if [[ $fixes_applied -eq 0 ]]; then
        echo -e "${COLOR_GREEN}✅ 无需修复，系统正常${COLOR_RESET}"
    else
        echo -e "${COLOR_GREEN}✅ 完成！应用了 $fixes_applied 个修复${COLOR_RESET}"
    fi
    
    return $fixes_applied
}

# 生成错误报告
function generate_error_report() {
    echo -e "${COLOR_BLUE}📊 生成错误报告...${COLOR_RESET}"
    
    local report_file="/tmp/yyc3-error-report-$(date +%Y%m%d).md"
    
    cat > "$report_file" << EOF
# YYC³ 系统错误报告
**生成时间**: $(date)
**系统**: $(uname -a)

## 系统概览
- 用户: $(whoami)
- 主机名: $(hostname)
- 当前目录: $(pwd)

## 错误扫描结果
EOF

    # 运行扫描并获取结果
    local scan_output=$(scan_for_errors 2>&1)
    echo "$scan_output" >> "$report_file"
    
    echo -e "\n## 修复历史" >> "$report_file"
    if [[ -d "$FIX_REPORT_DIR" ]]; then
        for fix_file in "$FIX_REPORT_DIR"/*.txt; do
            if [[ -f "$fix_file" ]]; then
                echo -e "\n### $(basename "$fix_file")" >> "$report_file"
                cat "$fix_file" >> "$report_file"
            fi
        done
    fi
    
    echo -e "\n## 建议操作" >> "$report_file"
    echo "1. 定期运行 \`$0 scan\` 监控系统健康" >> "$report_file"
    echo "2. 发现错误时运行 \`$0 fix\` 自动修复" >> "$report_file"
    echo "3. 查看 \`$ERROR_LOG_DIR\` 目录获取详细错误日志" >> "$report_file"
    
    echo -e "${COLOR_GREEN}✅ 报告已生成: $report_file${COLOR_RESET}"
    echo -e "${COLOR_BLUE}📄 报告内容预览:${COLOR_RESET}"
    head -20 "$report_file"
}

# 持续监控错误
function monitor_errors_continuous() {
    echo -e "${COLOR_BLUE}👁️  开始持续错误监控...${COLOR_RESET}"
    echo -e "${COLOR_YELLOW}按 Ctrl+C 停止监控${COLOR_RESET}"
    
    local iteration=1
    
    while true; do
        echo -e "\n${COLOR_BLUE}=== 监控周期 #$iteration ($(date)) ===${COLOR_RESET}"
        
        scan_for_errors
        
        # 等待5秒
        sleep 5
        ((iteration++))
    done
}

# 主函数
function main() {
    local command="${1:-scan}"
    
    case "$command" in
        scan)
            scan_for_errors
            ;;
        fix)
            fix_detected_errors
            ;;
        report)
            generate_error_report
            ;;
        monitor)
            monitor_errors_continuous
            ;;
        *)
            echo -e "${COLOR_RED}未知命令: $command${COLOR_RESET}"
            show_usage
            exit 1
            ;;
    esac
}

# 脚本入口
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi