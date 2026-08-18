#!/bin/bash

set -euo pipefail

# 性能基准配置
readonly BENCHMARK_ITERATIONS=10
readonly PERFORMANCE_THRESHOLD=500  # ms
readonly RESULTS_FILE="/tmp/yyc3-benchmark-$(date +%Y%m%d-%H%M%S).json"

# 颜色输出
readonly COLOR_GREEN='\033[0;32m'
readonly COLOR_RED='\033[0;31m'
readonly COLOR_YELLOW='\033[1;33m'
readonly COLOR_BLUE='\033[0;34m'
readonly COLOR_RESET='\033[0m'

# 性能测试函数
function run_benchmark() {
    local test_name="$1"
    local command="$2"
    local iterations="${3:-$BENCHMARK_ITERATIONS}"
    
    echo -e "${COLOR_BLUE}运行性能测试: $test_name${COLOR_RESET}"
    echo "命令: $command"
    echo "迭代次数: $iterations"
    
    local total_time=0
    local min_time=999999
    local max_time=0
    local results=()
    
    for ((i=1; i<=iterations; i++)); do
        echo -n "  第 $i 次: "
        
        local start_time
        start_time=$(date +%s%N)
        
        # 执行命令，忽略输出
        eval "$command" > /dev/null 2>&1
        
        local end_time
        end_time=$(date +%s%N)
        
        local duration_ms
        duration_ms=$(( (end_time - start_time) / 1000000 ))
        
        results+=("$duration_ms")
        total_time=$((total_time + duration_ms))
        
        if (( duration_ms < min_time )); then
            min_time=$duration_ms
        fi
        
        if (( duration_ms > max_time )); then
            max_time=$duration_ms
        fi
        
        # 颜色编码输出
        if (( duration_ms <= PERFORMANCE_THRESHOLD )); then
            echo -e "${COLOR_GREEN}${duration_ms}ms ✓${COLOR_RESET}"
        elif (( duration_ms <= PERFORMANCE_THRESHOLD * 2 )); then
            echo -e "${COLOR_YELLOW}${duration_ms}ms ~${COLOR_RESET}"
        else
            echo -e "${COLOR_RED}${duration_ms}ms ✗${COLOR_RESET}"
        fi
    done
    
    local avg_time=$((total_time / iterations))
    
    # 计算标准差
    local variance=0
    for result in "${results[@]}"; do
        local diff=$((result - avg_time))
        variance=$((variance + diff * diff))
    done
    variance=$((variance / iterations))
    local stddev=$(echo "sqrt($variance)" | bc)
    
    # 输出统计信息
    echo -e "\n${COLOR_BLUE}统计结果:${COLOR_RESET}"
    echo "  平均时间: ${avg_time}ms"
    echo "  最短时间: ${min_time}ms"
    echo "  最长时间: ${max_time}ms"
    echo "  标准差: ${stddev}ms"
    
    if (( avg_time <= PERFORMANCE_THRESHOLD )); then
        echo -e "  性能状态: ${COLOR_GREEN}符合要求 ✓${COLOR_RESET}"
    else
        echo -e "  性能状态: ${COLOR_RED}不符合要求 ✗${COLOR_RESET}"
    fi
    
    # 保存结果
    save_result "$test_name" "$avg_time" "$min_time" "$max_time" "$stddev"
}

# 保存测试结果
function save_result() {
    local test_name="$1"
    local avg_time="$2"
    local min_time="$3"
    local max_time="$4"
    local stddev="$5"
    
    local result_json="{
      \"test_name\": \"$test_name\",
      \"timestamp\": \"$(date -u +'%Y-%m-%dT%H:%M:%SZ')\",
      \"iterations\": $BENCHMARK_ITERATIONS,
      \"threshold_ms\": $PERFORMANCE_THRESHOLD,
      \"results\": {
        \"avg_ms\": $avg_time,
        \"min_ms\": $min_time,
        \"max_ms\": $max_time,
        \"stddev_ms\": $stddev,
        \"meets_threshold\": $(( avg_time <= PERFORMANCE_THRESHOLD ? 1 : 0 ))
      }
    }"
    
    if [[ ! -f "$RESULTS_FILE" ]]; then
        echo "[" > "$RESULTS_FILE"
    else
        # 移除最后的闭合括号，准备添加新结果
        sed -i '$ d' "$RESULTS_FILE"
        echo "," >> "$RESULTS_FILE"
    fi
    
    echo "$result_json" >> "$RESULTS_FILE"
    echo "]" >> "$RESULTS_FILE"
}

# CLI性能测试
function benchmark_cli() {
    echo -e "\n${COLOR_BLUE}=== CLI工具性能基准测试 ===${COLOR_RESET}"
    
    # 测试CLI版本命令
    run_benchmark \
        "CLI版本命令" \
        "node packages/yyc3-cli/bin/yyc3-cli.js --version"
    
    # 测试CLI帮助命令
    run_benchmark \
        "CLI帮助命令" \
        "node packages/yyc3-cli/bin/yyc3-cli.js --help"
    
    # 测试项目初始化（dry-run模式）
    run_benchmark \
        "项目初始化(dry-run)" \
        "node packages/yyc3-cli/bin/yyc3-cli.js init test-benchmark --dry-run"
}

# 系统脚本性能测试
function benchmark_scripts() {
    echo -e "\n${COLOR_BLUE}=== 系统脚本性能基准测试 ===${COLOR_RESET}"
    
    # 测试管理脚本状态检查
    run_benchmark \
        "管理脚本状态检查" \
        "./yyc3-management.sh status"
    
    # 测试智能运维检查
    run_benchmark \
        "智能运维状态检查" \
        "./yyc3-smart-ops.sh status"
}

# 生成性能报告
function generate_report() {
    echo -e "\n${COLOR_BLUE}=== 生成性能基准报告 ===${COLOR_RESET}"
    
    if [[ -f "$RESULTS_FILE" ]]; then
        local report_file="/tmp/yyc3-performance-report-$(date +%Y%m%d-%H%M%S).md"
        
        cat > "$report_file" << EOF
# YYC³ 性能基准测试报告

**测试时间:** $(date)
**性能阈值:** ${PERFORMANCE_THRESHOLD}ms
**测试环境:** $(uname -a)

## 执行摘要

$(generate_summary)

## 详细测试结果

\`\`\`json
$(cat "$RESULTS_FILE" | python3 -m json.tool 2>/dev/null || cat "$RESULTS_FILE")
\`\`\`

## 性能分析

$(generate_analysis)

## 建议改进

$(generate_recommendations)

---

*报告生成时间: $(date)*
*遵循YYC³五高原则 - 高性能要求*
EOF
        
        echo -e "${COLOR_GREEN}性能报告已生成:${COLOR_RESET} $report_file"
        open "$report_file" 2>/dev/null || echo "请手动打开文件查看报告"
    else
        echo -e "${COLOR_YELLOW}警告: 未找到测试结果文件${COLOR_RESET}"
    fi
}

# 生成摘要
function generate_summary() {
    local total_tests=0
    local passed_tests=0
    
    if [[ -f "$RESULTS_FILE" ]]; then
        total_tests=$(grep -c '"test_name"' "$RESULTS_FILE" || echo "0")
        passed_tests=$(grep -c '"meets_threshold": 1' "$RESULTS_FILE" || echo "0")
    fi
    
    echo "- **总测试数:** $total_tests"
    echo "- **通过测试数:** $passed_tests"
    echo "- **通过率:** $(( total_tests > 0 ? passed_tests * 100 / total_tests : 0 ))%"
    
    if [[ $total_tests -gt 0 ]] && [[ $passed_tests -eq $total_tests ]]; then
        echo "- **总体状态:** ✅ 所有测试符合性能要求"
    else
        echo "- **总体状态:** ⚠️  部分测试未达到性能要求"
    fi
}

# 生成分析
function generate_analysis() {
    cat << EOF
1. **响应时间分析**: 所有命令的平均响应时间应小于${PERFORMANCE_THRESHOLD}ms
2. **稳定性分析**: 标准差反映响应时间的稳定性，值越小越稳定
3. **资源使用**: 测试期间监控CPU和内存使用情况
4. **并发性能**: 测试系统在高并发下的表现
EOF
}

# 生成建议
function generate_recommendations() {
    cat << EOF
1. **优化启动时间**: 对于启动时间较长的命令，考虑预加载机制
2. **缓存优化**: 对频繁调用的操作添加缓存机制
3. **异步处理**: 将耗时操作转为异步执行，提高响应速度
4. **资源限制**: 合理设置资源限制，防止单点过载
5. **监控告警**: 设置性能监控告警，及时发现性能退化
EOF
}

# 主函数
function main() {
    echo -e "${COLOR_BLUE}🚀 启动YYC³性能基准测试${COLOR_RESET}"
    echo "性能阈值: ${PERFORMANCE_THRESHOLD}ms"
    echo "测试时间: $(date)"
    echo ""
    
    # 切换到项目根目录
    cd "/Users/yanyu/yyc3-management" || {
        echo -e "${COLOR_RED}错误: 无法切换到项目目录${COLOR_RESET}"
        exit 1
    }
    
    # 运行所有性能测试
    benchmark_cli
    benchmark_scripts
    
    # 生成报告
    generate_report
    
    echo -e "\n${COLOR_GREEN}✅ 性能基准测试完成${COLOR_RESET}"
}

# 运行主函数
main "$@"