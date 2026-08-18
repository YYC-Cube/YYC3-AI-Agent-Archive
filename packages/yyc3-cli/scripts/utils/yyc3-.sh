#!/bin/bash

# YYC³ 最终部署检查脚本
# 执行部署前的全面系统检查

set -e

ROOT_DIR="/Volume2/YYC"
NAS_IP="192.168.3.45"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[信息]${NC} $1"; }
log_success() { echo -e "${GREEN}[成功]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[警告]${NC} $1"; }
log_error() { echo -e "${RED}[错误]${NC} $1"; }
log_step() { echo -e "${PURPLE}[检查]${NC} $1"; }
log_highlight() { echo -e "${CYAN}[重点]${NC} $1"; }

# 检查结果统计
CHECKS_PASSED=0
CHECKS_FAILED=0
CHECKS_WARNING=0

# 记录检查结果
check_result() {
    local status=$1
    local message=$2
    
    case $status in
        "pass")
            log_success "$message"
            ((CHECKS_PASSED++))
            ;;
        "fail")
            log_error "$message"
            ((CHECKS_FAILED++))
            ;;
        "warn")
            log_warning "$message"
            ((CHECKS_WARNING++))
            ;;
    esac
}

# 显示欢迎信息
show_welcome() {
    clear
    echo -e "${CYAN}"
    cat << 'EOF'
    ██╗   ██╗██╗   ██╗ ██████╗██████╗     ███████╗██╗███╗   ██╗ █████╗ ██╗     
    ╚██╗ ██╔╝╚██╗ ██╔╝██╔════╝╚════██╗    ██╔════╝██║████╗  ██║██╔══██╗██║     
     ╚████╔╝  ╚████╔╝ ██║      █████╔╝    █████╗  ██║██╔██╗ ██║███████║██║     
      ╚██╔╝    ╚██╔╝  ██║      ╚═══██╗    ██╔══╝  ██║██║╚██╗██║██╔══██║██║     
       ██║      ██║   ╚██████╗██████╔╝    ██║     ██║██║ ╚████║██║  ██║███████╗
       ╚═╝      ╚═╝    ╚═════╝╚═════╝     ╚═╝     ╚═╝╚═╝  ╚═══╝╚═╝  ╚═╝╚══════╝
                                                                                
    YYC³ 最终部署检查
    Final Deployment Check
    ======================
EOF
    echo -e "${NC}"
    echo ""
    echo "🔍 正在进行部署前系统环境检查..."
    echo "📅 检查时间: $(date)"
    echo "🌐 目标服务器: $NAS_IP"
    echo "📁 根目录: $ROOT_DIR"
    echo ""
}

# 检查系统要求
check_system_requirements() {
    log_step "检查系统要求..."
    
    # 检查操作系统
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        check_result "pass" "操作系统: Linux"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        check_result "pass" "操作系统: macOS"
    else
        check_result "warn" "操作系统: $OSTYPE (未完全测试)"
    fi
    
    # 检查 CPU 核心数
    CPU_CORES=$(nproc 2>/dev/null || sysctl -n hw.ncpu 2>/dev/null || echo "unknown")
    if [[ "$CPU_CORES" != "unknown" ]] && [[ $CPU_CORES -ge 8 ]]; then
        check_result "pass" "CPU 核心数: $CPU_CORES (推荐 8+)"
    elif [[ "$CPU_CORES" != "unknown" ]] && [[ $CPU_CORES -ge 4 ]]; then
        check_result "warn" "CPU 核心数: $CPU_CORES (推荐 8+，当前可用但性能可能受限)"
    else
        check_result "fail" "CPU 核心数: $CPU_CORES (至少需要 4 核心)"
    fi
    
    # 检查内存
    if command -v free &> /dev/null; then
        MEMORY_GB=$(free -g | awk '/^Mem:/{print $2}')
        if [[ $MEMORY_GB -ge 16 ]]; then
            check_result "pass" "系统内存: ${MEMORY_GB}GB (推荐 16GB+)"
        elif [[ $MEMORY_GB -ge 8 ]]; then
            check_result "warn" "系统内存: ${MEMORY_GB}GB (推荐 16GB+，当前可用但建议升级)"
        else
            check_result "fail" "系统内存: ${MEMORY_GB}GB (至少需要 8GB)"
        fi
    elif command -v vm_stat &> /dev/null; then
        # macOS 内存检查
        MEMORY_BYTES=$(sysctl -n hw.memsize)
        MEMORY_GB=$((MEMORY_BYTES / 1024 / 1024 / 1024))
        if [[ $MEMORY_GB -ge 16 ]]; then
            check_result "pass" "系统内存: ${MEMORY_GB}GB (推荐 16GB+)"
        else
            check_result "warn" "系统内存: ${MEMORY_GB}GB (推荐 16GB+)"
        fi
    else
        check_result "warn" "无法检测系统内存"
    fi
    
    # 检查磁盘空间
    DISK_SPACE=$(df -BG /Volume2 2>/dev/null | awk 'NR==2{print $4}' | sed 's/G//' || df -BG / | awk 'NR==2{print $4}' | sed 's/G//')
    if [[ $DISK_SPACE -ge 500 ]]; then
        check_result "pass" "可用磁盘空间: ${DISK_SPACE}GB (推荐 500GB+)"
    elif [[ $DISK_SPACE -ge 200 ]]; then
        check_result "warn" "可用磁盘空间: ${DISK_SPACE}GB (推荐 500GB+，当前可用但空间紧张)"
    else
        check_result "fail" "可用磁盘空间: ${DISK_SPACE}GB (至少需要 200GB)"
    fi
}

# 检查必需软件
check_required_software() {
    log_step "检查必需软件..."
    
    # 检查 Docker
    if command -v docker &> /dev/null; then
        DOCKER_VERSION=$(docker --version | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)
        DOCKER_MAJOR=$(echo $DOCKER_VERSION | cut -d. -f1)
        DOCKER_MINOR=$(echo $DOCKER_VERSION | cut -d. -f2)
        
        if [[ $DOCKER_MAJOR -gt 20 ]] || [[ $DOCKER_MAJOR -eq 20 && $DOCKER_MINOR -ge 10 ]]; then
            check_result "pass" "Docker: $DOCKER_VERSION (需要 20.10+)"
        else
            check_result "fail" "Docker: $DOCKER_VERSION (需要 20.10+)"
        fi
        
        # 检查 Docker 服务状态
        if systemctl is-active --quiet docker 2>/dev/null || pgrep -f docker &> /dev/null; then
            check_result "pass" "Docker 服务: 运行中"
        else
            check_result "fail" "Docker 服务: 未运行"
        fi
    else
        check_result "fail" "Docker: 未安装"
    fi
    
    # 检查 Docker Compose
    if command -v docker-compose &> /dev/null; then
        COMPOSE_VERSION=$(docker-compose --version | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)
        COMPOSE_MAJOR=$(echo $COMPOSE_VERSION | cut -d. -f1)
        
        if [[ $COMPOSE_MAJOR -ge 2 ]]; then
            check_result "pass" "Docker Compose: $COMPOSE_VERSION (需要 2.0+)"
        else
            check_result "warn" "Docker Compose: $COMPOSE_VERSION (推荐 2.0+)"
        fi
    elif docker compose version &> /dev/null; then
        COMPOSE_VERSION=$(docker compose version | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)
        check_result "pass" "Docker Compose: $COMPOSE_VERSION (内置版本)"
    else
        check_result "fail" "Docker Compose: 未安装"
    fi
    
    # 检查其他必需工具
    local tools=("curl" "jq" "git" "openssl")
    for tool in "${tools[@]}"; do
        if command -v $tool &> /dev/null; then
            local version=$($tool --version 2>/dev/null | head -1 || echo "已安装")
            check_result "pass" "$tool: $version"
        else
            check_result "fail" "$tool: 未安装"
        fi
    done
    
    # 检查可选工具
    local optional_tools=("htop" "netstat" "bc")
    for tool in "${optional_tools[@]}"; do
        if command -v $tool &> /dev/null; then
            check_result "pass" "$tool: 已安装 (可选)"
        else
            check_result "warn" "$tool: 未安装 (可选，建议安装)"
        fi
    done
}

# 检查网络和端口
check_network_ports() {
    log_step "检查网络和端口..."
    
    # 检查网络连接
    if ping -c 1 8.8.8.8 &> /dev/null; then
        check_result "pass" "网络连接: 正常"
    else
        check_result "fail" "网络连接: 无法访问外网"
    fi
    
    # 检查关键端口
    local ports=(3001 4873 8080 9090 3000 9093 11434 11435 8888 6380)
    local port_conflicts=()
    
    for port in "${ports[@]}"; do
        if command -v netstat &> /dev/null; then
            if netstat -tuln | grep ":$port " &> /dev/null; then
                port_conflicts+=($port)
            fi
        elif command -v ss &> /dev/null; then
            if ss -tuln | grep ":$port " &> /dev/null; then
                port_conflicts+=($port)
            fi
        elif command -v lsof &> /dev/null; then
            if lsof -i :$port &> /dev/null; then
                port_conflicts+=($port)
            fi
        fi
    done
    
    if [[ ${#port_conflicts[@]} -eq 0 ]]; then
        check_result "pass" "端口检查: 所有必需端口可用"
    else
        check_result "warn" "端口冲突: ${port_conflicts[*]} (需要手动处理)"
    fi
}

# 检查权限
check_permissions() {
    log_step "检查权限..."
    
    # 检查是否为 root 用户
    if [[ $EUID -eq 0 ]]; then
        check_result "pass" "用户权限: root 用户"
    else
        check_result "warn" "用户权限: 非 root 用户 (某些操作可能需要 sudo)"
    fi
    
    # 检查 Docker 权限
    if docker ps &> /dev/null; then
        check_result "pass" "Docker 权限: 可以执行 Docker 命令"
    else
        check_result "fail" "Docker 权限: 无法执行 Docker 命令 (需要 sudo 或加入 docker 组)"
    fi
    
    # 检查目录权限
    TARGET_DIR="/Volume2/YC"
    if [[ -d "$TARGET_DIR" ]]; then
        if [[ -w "$TARGET_DIR" ]]; then
            check_result "pass" "目录权限: $TARGET_DIR 可写"
        else
            check_result "fail" "目录权限: $TARGET_DIR 不可写"
        fi
    else
        if mkdir -p "$TARGET_DIR" 2>/dev/null; then
            check_result "pass" "目录权限: 可以创建 $TARGET_DIR"
        else
            check_result "fail" "目录权限: 无法创建 $TARGET_DIR"
        fi
    fi
}

# 检查现有 Ollama 模型
check_ollama_models() {
    log_step "检查现有 Ollama 模型..."
    
    if command -v ollama &> /dev/null; then
        local models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}' | grep -v "^$")
        if [[ -n "$models" ]]; then
            check_result "pass" "Ollama 模型: 已安装 $(echo "$models" | wc -l) 个模型"
            echo "  已安装的模型:"
            while IFS= read -r model; do
                echo "    • $model"
            done <<< "$models"
        else
            check_result "warn" "Ollama 模型: 未安装任何模型"
        fi
    else
        check_result "warn" "Ollama: 未安装 (将在部署过程中安装)"
    fi
}

# 检查系统资源使用情况
check_system_resources() {
    log_step "检查系统资源使用情况..."
    
    # 检查 CPU 使用率
    if command -v top &> /dev/null; then
        CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | sed 's/%us,//' 2>/dev/null || echo "unknown")
        if [[ "$CPU_USAGE" != "unknown" ]]; then
            CPU_NUM=${CPU_USAGE%.*}
            if [[ $CPU_NUM -lt 80 ]]; then
                check_result "pass" "CPU 使用率: ${CPU_USAGE}% (正常)"
            else
                check_result "warn" "CPU 使用率: ${CPU_USAGE}% (较高)"
            fi
        fi
    fi
    
    # 检查内存使用率
    if command -v free &> /dev/null; then
        MEMORY_USAGE=$(free | grep Mem | awk '{printf("%.1f"), $3/$2 * 100.0}')
        MEMORY_NUM=${MEMORY_USAGE%.*}
        if [[ $MEMORY_NUM -lt 80 ]]; then
            check_result "pass" "内存使用率: ${MEMORY_USAGE}% (正常)"
        else
            check_result "warn" "内存使用率: ${MEMORY_USAGE}% (较高)"
        fi
    fi
    
    # 检查磁盘使用率
    DISK_USAGE=$(df / | tail -1 | awk '{print $5}' | sed 's/%//')
    if [[ $DISK_USAGE -lt 80 ]]; then
        check_result "pass" "磁盘使用率: ${DISK_USAGE}% (正常)"
    else
        check_result "warn" "磁盘使用率: ${DISK_USAGE}% (较高)"
    fi
}

# 生成安装建议
generate_recommendations() {
    echo ""
    log_highlight "📋 安装建议和注意事项:"
    echo ""
    
    if [[ $CHECKS_FAILED -gt 0 ]]; then
        echo "❌ 发现 $CHECKS_FAILED 个严重问题，建议解决后再进行部署:"
        echo ""
        
        # Docker 相关建议
        if ! command -v docker &> /dev/null; then
            echo "  🐳 安装 Docker:"
            echo "     curl -fsSL https://get.docker.com -o get-docker.sh"
            echo "     sudo sh get-docker.sh"
            echo ""
        fi
        
        # Docker Compose 建议
        if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
            echo "  🔧 安装 Docker Compose:"
            echo "     sudo curl -L \"https://github.com/docker/compose/releases/latest/download/docker-compose-\$(uname -s)-\$(uname -m)\" -o /usr/local/bin/docker-compose"
            echo "     sudo chmod +x /usr/local/bin/docker-compose"
            echo ""
        fi
        
        # 权限建议
        if ! docker ps &> /dev/null; then
            echo "  👤 配置 Docker 权限:"
            echo "     sudo usermod -aG docker \$USER"
            echo "     newgrp docker  # 或重新登录"
            echo ""
        fi
    fi
    
    if [[ $CHECKS_WARNING -gt 0 ]]; then
        echo "⚠️  发现 $CHECKS_WARNING 个警告，建议优化:"
        echo ""
        echo "  💾 如果内存不足 16GB，建议:"
        echo "     - 关闭不必要的应用程序"
        echo "     - 考虑增加虚拟内存"
        echo "     - 限制容器内存使用"
        echo ""
        echo "  🔧 安装推荐工具:"
        echo "     sudo apt-get install htop net-tools bc  # Ubuntu/Debian"
        echo "     brew install htop netstat bc            # macOS"
        echo ""
    fi
    
    if [[ $CHECKS_FAILED -eq 0 ]]; then
        echo "✅ 系统检查通过！可以开始部署。"
        echo ""
        echo "🚀 推荐的部署步骤:"
        echo "  1. source ./scripts/set-env.sh          # 设置环境变量"
        echo "  2. sudo ./scripts/quick-start.sh        # 快速部署"
        echo "  3. sudo ./scripts/health-check.sh       # 部署后检查"
        echo ""
    fi
}

# 生成检查报告
generate_report() {
    local report_file="/tmp/yyc3-deployment-check-$(date +%Y%m%d-%H%M%S).log"
    
    {
        echo "YYC³ 部署检查报告"
        echo "=================="
        echo "检查时间: $(date)"
        echo "系统信息: $(uname -a)"
        echo ""
        echo "检查结果统计:"
        echo "  ✅ 通过: $CHECKS_PASSED"
        echo "  ⚠️  警告: $CHECKS_WARNING"
        echo "  ❌ 失败: $CHECKS_FAILED"
        echo ""
        echo "详细信息请查看控制台输出"
    } > "$report_file"
    
    log_info "检查报告已保存到: $report_file"
}

# 主执行函数
main() {
    show_welcome
    
    # 执行各项检查
    check_system_requirements
    echo ""
    check_required_software
    echo ""
    check_network_ports
    echo ""
    check_permissions
    echo ""
    check_ollama_models
    echo ""
    check_system_resources
    
    # 显示检查结果
    echo ""
    echo "=================================="
    log_highlight "📊 检查结果统计:"
    echo "  ✅ 通过: $CHECKS_PASSED"
    echo "  ⚠️  警告: $CHECKS_WARNING"
    echo "  ❌ 失败: $CHECKS_FAILED"
    echo "=================================="
    
    # 生成建议和报告
    generate_recommendations
    generate_report
    
    # 返回适当的退出码
    if [[ $CHECKS_FAILED -gt 0 ]]; then
        exit 1
    elif [[ $CHECKS_WARNING -gt 0 ]]; then
        exit 2
    else
        exit 0
    fi
}

# 执行主函数
main "$@"