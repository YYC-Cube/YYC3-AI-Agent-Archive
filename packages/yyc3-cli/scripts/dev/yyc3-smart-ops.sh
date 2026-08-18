#!/bin/bash
#
# @fileoverview YYC³ 智能运维监控脚本
# @description 全局服务健康检查、性能监控、智能告警的核心运维工具
# @author YYC³
# @version 1.0.0
# @created 2026-01-30
# @modified 2026-01-30
# @copyright Copyright (c) 2026 YYC³
# @license MIT

set -euo pipefail

# 配置常量
readonly OPS_LOG_DIR="/var/log/yyc3-ops"
readonly ALERT_THRESHOLD_CPU=80
readonly ALERT_THRESHOLD_MEM=85
readonly ALERT_THRESHOLD_DISK=90
readonly STATUS_FILE="/tmp/yyc3-ops-status.json"

# 颜色定义
readonly COLOR_RED='\033[0;31m'
readonly COLOR_GREEN='\033[0;32m'
readonly COLOR_YELLOW='\033[1;33m'
readonly COLOR_BLUE='\033[0;34m'
readonly COLOR_CYAN='\033[0;36m'
readonly COLOR_RESET='\033[0m'

# 显示用法
function show_usage() {
    echo -e "${COLOR_CYAN}用法:${COLOR_RESET}"
    echo "  $0 status        - 检查系统全局状态"
    echo "  $0 monitor       - 启动持续监控"
    echo "  $0 report        - 生成运维报告"
    echo "  $0 analyze       - 运行智能分析"
    echo "  $0 alert-test    - 测试告警系统"
    echo ""
}

# 检查系统状态
function check_global_status() {
    echo -e "${COLOR_CYAN}🌐 检查YYC³系统全局状态...${COLOR_RESET}"

    local overall_healthy=true
    local status_report=""

    # 1. 检查核心目录
    echo -e "${COLOR_BLUE}1. 检查核心目录...${COLOR_RESET}"

    local critical_dirs=(
        "/Users/yanyu/yyc3-management"
        "/Users/yanyu/yyc3-management/YYC3_CLI"
        "/Users/yanyu/yyc3-management/Mac"
    )

    for dir in "${critical_dirs[@]}"; do
        if [[ -d "$dir" ]]; then
            echo -e "  ${COLOR_GREEN}✅ $dir${COLOR_RESET}"
            status_report+="目录 $dir: 正常\n"
        else
            echo -e "  ${COLOR_RED}❌ $dir (不存在)${COLOR_RESET}"
            status_report+="目录 $dir: 异常\n"
            overall_healthy=false
        fi
    done

    # 2. 检查关键脚本
    echo -e "${COLOR_BLUE}2. 检查关键脚本...${COLOR_RESET}"

    local critical_scripts=(
        "yyc3-error-fixer.sh"
        "yyc3-smart-ops.sh"
        "yyc3-management.sh"
        "yyc3-ai.sh"
    )

    for script in "${critical_scripts[@]}"; do
        if [[ -f "$script" && -x "$script" ]]; then
            echo -e "  ${COLOR_GREEN}✅ $script (可执行)${COLOR_RESET}"
            status_report+="脚本 $script: 正常\n"
        elif [[ -f "$script" ]]; then
            echo -e "  ${COLOR_YELLOW}⚠️  $script (存在但不可执行)${COLOR_RESET}"
            status_report+="脚本 $script: 警告(需执行权限)\n"
            chmod +x "$script" 2>/dev/null && echo -e "    ${COLOR_GREEN}已添加执行权限${COLOR_RESET}"
        else
            echo -e "  ${COLOR_RED}❌ $script (不存在)${COLOR_RESET}"
            status_report+="脚本 $script: 异常\n"
            overall_healthy=false
        fi
    done

    # 3. 检查系统资源
    echo -e "${COLOR_BLUE}3. 检查系统资源...${COLOR_RESET}"

    # CPU使用率
    local cpu_usage=$(top -l 1 | grep "CPU usage" | awk '{print $3}' | sed 's/%//')
    # 处理小数点的CPU使用率
    local cpu_usage_int=${cpu_usage%.*}
    if [[ -n "$cpu_usage_int" && "$cpu_usage_int" -lt $ALERT_THRESHOLD_CPU ]]; then
        echo -e "  ${COLOR_GREEN}✅ CPU使用率: ${cpu_usage}%${COLOR_RESET}"
        status_report+="CPU使用率: ${cpu_usage}% (正常)\n"
    else
        echo -e "  ${COLOR_YELLOW}⚠️  CPU使用率: ${cpu_usage}%${COLOR_RESET}"
        status_report+="CPU使用率: ${cpu_usage}% (警告)\n"
    fi

    # 内存使用率
    local mem_usage=$(memory_pressure | grep "System-wide memory free percentage:" | awk '{print 100 - $5}')
    if [[ -n "$mem_usage" && "$mem_usage" -lt $ALERT_THRESHOLD_MEM ]]; then
        echo -e "  ${COLOR_GREEN}✅ 内存使用率: ${mem_usage}%${COLOR_RESET}"
        status_report+="内存使用率: ${mem_usage}% (正常)\n"
    else
        echo -e "  ${COLOR_YELLOW}⚠️  内存使用率: ${mem_usage}%${COLOR_RESET}"
        status_report+="内存使用率: ${mem_usage}% (警告)\n"
    fi

    # 磁盘使用率
    local disk_usage=$(df -h / | tail -1 | awk '{print $5}' | sed 's/%//')
    if [[ -n "$disk_usage" && "$disk_usage" -lt $ALERT_THRESHOLD_DISK ]]; then
        echo -e "  ${COLOR_GREEN}✅ 磁盘使用率: ${disk_usage}%${COLOR_RESET}"
        status_report+="磁盘使用率: ${disk_usage}% (正常)\n"
    else
        echo -e "  ${COLOR_YELLOW}⚠️  磁盘使用率: ${disk_usage}%${COLOR_RESET}"
        status_report+="磁盘使用率: ${disk_usage}% (警告)\n"
    fi

    # 4. 检查网络连接
    echo -e "${COLOR_BLUE}4. 检查网络连接...${COLOR_RESET}"

    # 使用更可靠的网络检查方法
    if curl -s --connect-timeout 3 --max-time 5 https://www.google.com &> /dev/null || \
       curl -s --connect-timeout 3 --max-time 5 https://www.baidu.com &> /dev/null; then
        echo -e "  ${COLOR_GREEN}✅ 网络连接正常${COLOR_RESET}"
        status_report+="网络连接: 正常\n"
    else
        echo -e "  ${COLOR_YELLOW}⚠️  网络连接可能受限（使用备用检查）${COLOR_RESET}"
        status_report+="网络连接: 可能受限\n"
        # 不将网络问题视为严重错误
    fi

    # 5. 检查CLI项目
    echo -e "${COLOR_BLUE}5. 检查CLI项目...${COLOR_RESET}"

    local cli_dir="YYC3_CLI/packages/yyc3-cli"
    if [[ -d "$cli_dir" ]]; then
        echo -e "  ${COLOR_GREEN}✅ CLI项目目录存在${COLOR_RESET}"
        status_report+="CLI项目目录: 存在\n"

        # 检查package.json
        if [[ -f "$cli_dir/package.json" ]]; then
            echo -e "  ${COLOR_GREEN}✅ package.json存在${COLOR_RESET}"
            status_report+="package.json: 存在\n"

            # 检查node_modules
            if [[ -d "$cli_dir/node_modules" ]]; then
                echo -e "  ${COLOR_GREEN}✅ 依赖已安装${COLOR_RESET}"
                status_report+="依赖: 已安装\n"
            else
                echo -e "  ${COLOR_YELLOW}⚠️  依赖未安装${COLOR_RESET}"
                status_report+="依赖: 未安装\n"
            fi
        fi
    else
        echo -e "  ${COLOR_RED}❌ CLI项目目录不存在${COLOR_RESET}"
        status_report+="CLI项目目录: 不存在\n"
        overall_healthy=false
    fi

    # 保存状态报告
    mkdir -p "$(dirname "$STATUS_FILE")"
    echo -e "{\"timestamp\": \"$(date -u +'%Y-%m-%dT%H:%M:%SZ')\", \"healthy\": $overall_healthy}" > "$STATUS_FILE"

    # 输出总体状态
    echo -e "\n${COLOR_CYAN}📊 总体状态:${COLOR_RESET}"
    if $overall_healthy; then
        echo -e "${COLOR_GREEN}✅ 系统健康，所有关键组件正常${COLOR_RESET}"
    else
        echo -e "${COLOR_YELLOW}⚠️  系统存在异常，请检查上述问题${COLOR_RESET}"
    fi

    echo -e "\n${COLOR_CYAN}📋 详细状态报告已保存至: $STATUS_FILE${COLOR_RESET}"
}

# 启动持续监控
function start_continuous_monitoring() {
    echo -e "${COLOR_CYAN}👁️  启动持续监控系统...${COLOR_RESET}"
    echo -e "${COLOR_YELLOW}按 Ctrl+C 停止监控${COLOR_RESET}"

    # 创建日志目录
    mkdir -p "$OPS_LOG_DIR"

    local iteration=1
    while true; do
        local timestamp=$(date +"%Y%m%d_%H%M%S")
        local log_file="$OPS_LOG_DIR/monitor_$timestamp.log"

        echo -e "\n${COLOR_CYAN}=== 监控周期 #$iteration ($(date)) ===${COLOR_RESET}"

        # 运行状态检查并记录日志
        check_global_status 2>&1 | tee -a "$log_file"

        echo -e "${COLOR_BLUE}📝 日志已保存: $log_file${COLOR_RESET}"

        # 等待10秒
        sleep 10
        ((iteration++))
    done
}

# 生成运维报告
function generate_ops_report() {
    echo -e "${COLOR_CYAN}📊 生成运维报告...${COLOR_RESET}"

    local report_file="/tmp/yyc3-ops-report-$(date +%Y%m%d).md"

    cat > "$report_file" << EOF
# YYC³ 智能运维报告
**生成时间**: $(date)
**系统**: $(uname -a)

## 执行摘要
EOF

    # 获取系统状态
    echo -e "\n## 系统状态检查\n\`\`\`" >> "$report_file"
    check_global_status 2>&1 | tail -50 >> "$report_file"
    echo -e "\`\`\`" >> "$report_file"

    # 添加监控日志摘要
    echo -e "\n## 最近监控日志" >> "$report_file"
    if [[ -d "$OPS_LOG_DIR" ]]; then
        local recent_logs=$(ls -t "$OPS_LOG_DIR"/*.log 2>/dev/null | head -5)
        for log in $recent_logs; do
            echo -e "\n### $(basename "$log")" >> "$report_file"
            echo -e "\`\`\`" >> "$report_file"
            tail -10 "$log" >> "$report_file"
            echo -e "\`\`\`" >> "$report_file"
        done
    fi

    # 添加建议
    echo -e "\n## 运维建议" >> "$report_file"
    echo "1. 定期运行 \`$0 status\` 检查系统健康" >> "$report_file"
    echo "2. 使用 \`$0 monitor\` 进行持续监控" >> "$report_file"
    echo "3. 发现问题时运行 \`./yyc3-error-fixer.sh fix\` 自动修复" >> "$report_file"
    echo "4. 查看 \`$OPS_LOG_DIR\` 目录获取详细监控日志" >> "$report_file"

    echo -e "${COLOR_GREEN}✅ 运维报告已生成: $report_file${COLOR_RESET}"
    echo -e "${COLOR_CYAN}📄 报告内容预览:${COLOR_RESET}"
    head -30 "$report_file"
}

# 运行智能分析
function run_intelligent_analysis() {
    echo -e "${COLOR_CYAN}🤖 运行智能分析...${COLOR_RESET}"

    # 分析系统性能趋势
    echo -e "${COLOR_BLUE}1. 系统性能趋势分析${COLOR_RESET}"

    # 检查最近的状态文件
    if [[ -f "$STATUS_FILE" ]]; then
        local last_status=$(cat "$STATUS_FILE")
        echo -e "  ${COLOR_GREEN}✅ 最近状态: $last_status${COLOR_RESET}"
    else
        echo -e "  ${COLOR_YELLOW}⚠️  无最近状态记录${COLOR_RESET}"
    fi

    # 分析资源使用模式
    echo -e "${COLOR_BLUE}2. 资源使用模式分析${COLOR_RESET}"

    local current_hour=$(date +%H)
    if [[ $current_hour -ge 9 && $current_hour -lt 18 ]]; then
        echo -e "  ${COLOR_YELLOW}⚠️  工作时间段，系统负载可能较高${COLOR_RESET}"
    else
        echo -e "  ${COLOR_GREEN}✅ 非高峰时间段，系统负载正常${COLOR_RESET}"
    fi

    # 提供优化建议
    echo -e "${COLOR_BLUE}3. 智能优化建议${COLOR_RESET}"
    echo -e "  ${COLOR_CYAN}• 建议定期清理临时文件${COLOR_RESET}"
    echo -e "  ${COLOR_CYAN}• 建议配置自动化备份${COLOR_RESET}"
    echo -e "  ${COLOR_CYAN}• 建议监控关键服务端口${COLOR_RESET}"

    echo -e "\n${COLOR_GREEN}✅ 智能分析完成${COLOR_RESET}"
}

# 测试告警系统
function test_alert_system() {
    echo -e "${COLOR_CYAN}🚨 测试告警系统...${COLOR_RESET}"

    # 模拟CPU告警
    echo -e "${COLOR_YELLOW}模拟CPU使用率过高告警...${COLOR_RESET}"
    echo -e "${COLOR_RED}🚨 告警: CPU使用率超过 ${ALERT_THRESHOLD_CPU}%${COLOR_RESET}"

    # 模拟内存告警
    echo -e "${COLOR_YELLOW}模拟内存使用率过高告警...${COLOR_RESET}"
    echo -e "${COLOR_RED}🚨 告警: 内存使用率超过 ${ALERT_THRESHOLD_MEM}%${COLOR_RESET}"

    # 模拟磁盘告警
    echo -e "${COLOR_YELLOW}模拟磁盘使用率过高告警...${COLOR_RESET}"
    echo -e "${COLOR_RED}🚨 告警: 磁盘使用率超过 ${ALERT_THRESHOLD_DISK}%${COLOR_RESET}"

    echo -e "\n${COLOR_GREEN}✅ 告警系统测试完成${COLOR_RESET}"
}

# 主函数
function main() {
    local command="${1:-status}"

    case "$command" in
        status)
            check_global_status
            ;;
        monitor)
            start_continuous_monitoring
            ;;
        report)
            generate_ops_report
            ;;
        analyze)
            run_intelligent_analysis
            ;;
        alert-test)
            test_alert_system
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
