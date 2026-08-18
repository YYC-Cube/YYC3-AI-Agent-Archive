#!/bin/bash

# YYC³ 快速启动脚本
# 一键部署 YYC³ 开发者工具包

set -e

ROOT_DIR="/Volume2/www"
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
log_step() { echo -e "${PURPLE}[步骤]${NC} $1"; }
log_highlight() { echo -e "${CYAN}[重点]${NC} $1"; }

# 显示欢迎信息
show_welcome() {
    clear
    echo -e "${CYAN}"
    cat << 'EOF'
    ██╗   ██╗██╗   ██╗ ██████╗██████╗     ██████╗ ██╗   ██╗██╗ ██████╗██╗  ██╗
    ╚██╗ ██╔╝╚██╗ ██╔╝██╔════╝╚════██╗   ██╔═══██╗██║   ██║██║██╔════╝██║ ██╔╝
     ╚████╔╝  ╚████╔╝ ██║      █████╔╝   ██║   ██║██║   ██║██║██║     █████╔╝
      ╚██╔╝    ╚██╔╝  ██║      ╚═══██╗   ██║▄▄ ██║██║   ██║██║██║     ██╔═██╗
       ██║      ██║   ╚██████╗██████╔╝   ╚██████╔╝╚██████╔╝██║╚██████╗██║  ██╗
       ╚═╝      ╚═╝    ╚═════╝╚═════╝     ╚══▀▀═╝  ╚═════╝ ╚═╝ ╚═════╝╚═╝  ╚═╝

    YYC³ 快速启动
    Quick Start Deployment
    ======================
EOF
    echo -e "${NC}"
    echo ""
    echo "🚀 一键部署 YYC³ 开发者工具包"
    echo "📅 部署时间: $(date)"
    echo "🌐 目标服务器: $NAS_IP"
    echo "📁 安装目录: $ROOT_DIR"
    echo ""
}

# 检查前置条件
check_prerequisites() {
    log_step "检查前置条件..."

    # 检查 Docker
    if ! command -v docker &> /dev/null; then
        log_error "Docker 未安装，请先安装 Docker"
        exit 1
    fi

    # 检查 Docker Compose
    if ! command -v docker-compose &> /dev/null; then
        log_error "Docker Compose 未安装，请先安装 Docker Compose"
        exit 1
    fi

    # 检查 Docker 服务
    if ! docker info &> /dev/null; then
        log_error "Docker 服务未运行，请启动 Docker"
        exit 1
    fi

    # 检查权限
    if [[ $EUID -ne 0 ]]; then
        log_warning "建议使用 root 权限运行此脚本"
    fi

    log_success "前置条件检查通过"
}

# 创建目录结构
create_directories() {
    log_step "创建目录结构..."

    mkdir -p "$ROOT_DIR"/{scripts,configs,docs,services,gitlab,ai-models,monitoring,backups}
    mkdir -p "$ROOT_DIR/services/frp-beginner"

    log_success "目录结构创建完成"
}

# 设置环境变量
setup_environment() {
    log_step "设置环境变量..."

    if [ -f "$ROOT_DIR/scripts/set-env.sh" ]; then
        source "$ROOT_DIR/scripts/set-env.sh"
        log_success "环境变量设置完成"
    else
        log_warning "环境变量脚本不存在，跳过设置"
    fi
}

# 执行部署脚本
execute_deployment_scripts() {
    log_step "执行部署脚本..."

    local scripts=(
        "advanced-setup.sh:高级配置"
        "security-hardening.sh:安全加固"
        "gitlab-integration.sh:GitLab 集成"
        "ai-model-optimizer.sh:AI 模型优化"
        "monitoring-alerts.sh:监控告警"
    )

    for script_info in "${scripts[@]}"; do
        local script=$(echo "$script_info" | cut -d':' -f1)
        local desc=$(echo "$script_info" | cut -d':' -f2)
        local script_path="$ROOT_DIR/scripts/$script"

        if [ -f "$script_path" ] && [ -x "$script_path" ]; then
            log_info "执行 $desc ($script)..."

            # 在后台执行脚本，显示进度
            if "$script_path" > "/tmp/yyc3-$script.log" 2>&1; then
                log_success "$desc 部署完成"
            else
                log_error "$desc 部署失败，查看日志: /tmp/yyc3-$script.log"
            fi
        else
            log_warning "脚本不存在或不可执行: $script"
        fi

        # 等待一段时间，避免资源冲突
        sleep 5
    done
}

# 验证部署结果
verify_deployment() {
    log_step "验证部署结果..."

    local services=(
        "3001:YYC³ 管理面板"
        "4873:NPM 私有仓库"
        "8080:GitLab"
        "9090:Prometheus"
        "3000:Grafana"
    )

    local success_count=0
    local total_count=${#services[@]}

    for service_info in "${services[@]}"; do
        local port=$(echo "$service_info" | cut -d':' -f1)
        local name=$(echo "$service_info" | cut -d':' -f2)

        if curl -s --connect-timeout 5 "http://$NAS_IP:$port" > /dev/null; then
            log_success "$name 运行正常 (:$port)"
            ((success_count++))
        else
            log_warning "$name 可能未启动 (:$port)"
        fi
    done

    echo ""
    log_highlight "部署结果: $success_count/$total_count 服务正常运行"
}

# 显示访问信息
show_access_info() {
    log_step "生成访问信息..."

    echo ""
    log_highlight "🌐 YYC³ 开发者工具包访问地址:"
    echo ""
    echo "  📊 管理面板:     http://$NAS_IP:3001"
    echo "  📦 NPM 仓库:     http://$NAS_IP:4873"
    echo "  🔧 GitLab:       http://$NAS_IP:8080"
    echo "  🤖 AI 路由器:    http://$NAS_IP:8888"
    echo "  📈 Grafana:      http://$NAS_IP:3000 (admin/yyc3admin)"
    echo "  📊 Prometheus:   http://$NAS_IP:9090"
    echo "  🚨 AlertManager: http://$NAS_IP:9093"
    echo ""
    log_highlight "🔑 默认登录信息:"
    echo "  • Grafana: admin / yyc3admin"
    echo "  • GitLab: root / (查看容器日志获取初始密码)"
    echo ""
    log_highlight "📋 管理命令:"
    echo "  • 查看服务状态: docker ps"
    echo "  • 查看日志: docker-compose logs -f"
    echo "  • 重启服务: docker-compose restart"
    echo ""
    log_highlight "📚 文档位置:"
    echo "  • 部署文档: $ROOT_DIR/docs/"
    echo "  • 配置文件: $ROOT_DIR/configs/"
    echo "  • 日志文件: /tmp/yyc3-*.log"
    echo ""
}

# 创建快速管理脚本
create_management_script() {
    log_step "创建管理脚本..."

    cat > "$ROOT_DIR/manage.sh" << 'EOF'
#!/bin/bash

# YYC³ 管理脚本

ROOT_DIR="/Volume2/www"
NAS_IP="192.168.3.45"

case "${1:-help}" in
    "start")
        echo "启动所有服务..."
        find "$ROOT_DIR" -name "docker-compose.yml" -exec dirname {} \; | while read dir; do
            echo "启动 $dir 中的服务..."
            cd "$dir" && docker-compose up -d
        done
        ;;
    "stop")
        echo "停止所有服务..."
        find "$ROOT_DIR" -name "docker-compose.yml" -exec dirname {} \; | while read dir; do
            echo "停止 $dir 中的服务..."
            cd "$dir" && docker-compose down
        done
        ;;
    "status")
        echo "服务状态:"
        docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
        ;;
    "logs")
        if [ -n "$2" ]; then
            docker logs -f "$2"
        else
            echo "请指定容器名称"
        fi
        ;;
    "update")
        echo "更新所有服务..."
        find "$ROOT_DIR" -name "docker-compose.yml" -exec dirname {} \; | while read dir; do
            cd "$dir" && docker-compose pull && docker-compose up -d
        done
        ;;
    "backup")
        echo "备份配置和数据..."
        backup_dir="$ROOT_DIR/backups/backup-$(date +%Y%m%d-%H%M%S)"
        mkdir -p "$backup_dir"
        cp -r "$ROOT_DIR/configs" "$backup_dir/"
        echo "备份完成: $backup_dir"
        ;;
    *)
        echo "YYC³ 管理工具"
        echo ""
        echo "用法: $0 [命令]"
        echo ""
        echo "命令:"
        echo "  start    启动所有服务"
        echo "  stop     停止所有服务"
        echo "  status   查看服务状态"
        echo "  logs     查看容器日志"
        echo "  update   更新所有服务"
        echo "  backup   备份配置"
        echo ""
        ;;
esac
EOF

    chmod +x "$ROOT_DIR/manage.sh"
    log_success "管理脚本创建完成: $ROOT_DIR/manage.sh"
}

# 主执行函数
main() {
    show_welcome

    # 询问用户确认
    echo -n "是否开始部署 YYC³ 开发者工具包？(y/N): "
    read -r confirm

    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        log_info "部署已取消"
        exit 0
    fi

    # 执行部署步骤
    check_prerequisites
    create_directories
    setup_environment
    execute_deployment_scripts
    verify_deployment
    create_management_script
    show_access_info

    echo ""
    log_success "🎉 YYC³ 开发者工具包部署完成！"
    echo ""
    log_highlight "🚀 下一步操作:"
    echo "  1. 访问管理面板配置系统"
    echo "  2. 在 GitLab 中创建第一个项目"
    echo "  3. 配置 AI 模型和监控告警"
    echo "  4. 使用 $ROOT_DIR/manage.sh 管理服务"
    echo ""
    log_info "如有问题，请查看日志文件: /tmp/yyc3-*.log"
}

# 执行主函数
main "$@"
