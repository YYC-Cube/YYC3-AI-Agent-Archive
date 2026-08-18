#!/bin/bash

# YYC³ 快速启动脚本
# 作者：YYC³
# 版本：1.0
# 更新日期：2025-07-10
# 一键部署 YYC³ 开发者工具包
# 优化版：增加配置灵活性、强化错误处理、完善日志系统

set -euo pipefail
trap 'log_error "脚本执行失败: 第 $LINENO 行"; cleanup; exit 1' ERR

# 默认配置（可通过命令行参数或交互式修改）
ROOT_DIR="/Volume2/YYC"
NAS_IP="192.168.3.45"
LOG_FILE="/var/log/yyc3_deploy_$(date +%Y%m%d_%H%M%S).log"
TEMP_DIR="/tmp/yyc3_deploy_$(date +%s)"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# 日志函数
log_info() {
    local msg="[$(date '+%Y-%m-%d %H:%M:%S')] [INFO] $1"
    echo -e "${BLUE}${msg}${NC}"
    echo "${msg}" >> "${LOG_FILE}"
}

log_success() {
    local msg="[$(date '+%Y-%m-%d %H:%M:%S')] [SUCCESS] $1"
    echo -e "${GREEN}${msg}${NC}"
    echo "${msg}" >> "${LOG_FILE}"
}

log_warning() {
    local msg="[$(date '+%Y-%m-%d %H:%M:%S')] [WARNING] $1"
    echo -e "${YELLOW}${msg}${NC}"
    echo "${msg}" >> "${LOG_FILE}"
}

log_error() {
    local msg="[$(date '+%Y-%m-%d %H:%M:%S')] [ERROR] $1"
    echo -e "${RED}${msg}${NC}"
    echo "${msg}" >> "${LOG_FILE}"
}

log_step() {
    local msg="[$(date '+%Y-%m-%d %H:%M:%S')] [STEP] $1"
    echo -e "${PURPLE}${msg}${NC}"
    echo "${msg}" >> "${LOG_FILE}"
}

log_highlight() {
    local msg="[$(date '+%Y-%m-%d %H:%M:%S')] [HIGHLIGHT] $1"
    echo -e "${CYAN}${msg}${NC}"
    echo "${msg}" >> "${LOG_FILE}"
}

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

    YYC³ 快速启动 v2.0
    Quick Start Deployment
    ======================
EOF
    echo -e "${NC}"
    echo ""
    echo "🚀 一键部署 YYC³ 开发者工具包"
    echo "📅 部署时间: $(date)"
    echo "🌐 目标服务器: $NAS_IP"
    echo "📁 安装目录: $ROOT_DIR"
    echo "📜 日志文件: $LOG_FILE"
    echo ""
}

# 检查前置条件
check_prerequisites() {
    log_step "检查前置条件..."

    # 检查命令行工具
    local required_tools=("docker" "docker-compose" "curl" "jq" "git" "openssl")
    for tool in "${required_tools[@]}"; do
        if ! command -v "$tool" &> /dev/null; then
            log_error "$tool 未安装，请先安装 $tool"
            exit 1
        fi
    done

    # 检查 Docker 服务
    if ! docker info &> /dev/null; then
        log_error "Docker 服务未运行，请启动 Docker"
        exit 1
    fi

    # 检查磁盘空间
    local free_space=$(df -BG "$ROOT_DIR" | awk 'NR==2 {print $4}' | tr -d 'G')
    if [ "$free_space" -lt 10 ]; then
        log_warning "安装目录可用空间不足 10GB ($free_space GB)，可能影响部署"
    fi

    # 检查端口占用
    local required_ports=(3001 4873 8080 8888 9090 3000 9093)
    for port in "${required_ports[@]}"; do
        if lsof -Pi :$port -sTCP:LISTEN -t >/dev/null ; then
            log_error "端口 $port 已被占用，请释放后重试"
            exit 1
        fi
    done

    log_success "前置条件检查通过"
}

# 交互式配置
interactive_config() {
    log_step "交互式配置..."

    read -p "请输入安装目录 (默认: $ROOT_DIR): " input_root
    if [ -n "$input_root" ]; then
        ROOT_DIR="$input_root"
    fi

    read -p "请输入服务器 IP 地址 (默认: $NAS_IP): " input_ip
    if [ -n "$input_ip" ]; then
        NAS_IP="$input_ip"
    fi

    # 验证 IP 格式
    if ! [[ "$NAS_IP" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        log_error "无效的 IP 地址格式: $NAS_IP"
        exit 1
    fi

    # 创建临时目录
    mkdir -p "$TEMP_DIR"

    # 更新配置文件
    cat > "$ROOT_DIR/configs/yyc3.env" << EOF
# YYC³ 环境配置
ROOT_DIR=$ROOT_DIR
NAS_IP=$NAS_IP
EOF

    log_success "配置完成"
}

# 创建目录结构
create_directories() {
    log_step "创建目录结构..."

    # 主目录
    mkdir -p "$ROOT_DIR"/{scripts,configs,docs,services,gitlab,ai-models,monitoring,backups,logs}

    # 服务目录
    mkdir -p "$ROOT_DIR/services"/{frp,gitlab,ai-router,npm-registry,prometheus,grafana,alertmanager}

    # 设置权限
    chmod 755 "$ROOT_DIR"
    chmod -R 755 "$ROOT_DIR/scripts"

    log_success "目录结构创建完成"
}

# 部署服务
deploy_services() {
    log_step "开始部署服务..."

    # 服务列表及部署函数映射
    local services=(
        "frp:deploy_frp"
        "gitlab:deploy_gitlab"
        "ai-router:deploy_ai_router"
        "npm-registry:deploy_npm_registry"
        "monitoring:deploy_monitoring"
    )

    # 依次部署服务
    for service_info in "${services[@]}"; do
        local service=$(echo "$service_info" | cut -d':' -f1)
        local func=$(echo "$service_info" | cut -d':' -f2)

        log_step "部署 $service 服务..."
        if $func; then
            log_success "$service 服务部署成功"
        else
            log_error "$service 服务部署失败"
            return 1
        fi
    done

    log_success "所有服务部署完成"
}

# 部署 frp 服务
deploy_frp() {
    local frp_dir="$ROOT_DIR/services/frp"
    mkdir -p "$frp_dir"

    # 创建 frp 配置
    cat > "$frp_dir/frpc.ini" << EOF
[common]
server_addr = $NAS_IP
server_port = 7000
token = yyc3frptoken

[yyc3-web]
type = http
local_ip = 127.0.0.1
local_port = 3001
custom_domains = yyc3.$NAS_IP.nip.io

[yyc3-gitlab]
type = http
local_ip = 127.0.0.1
local_port = 8080
custom_domains = gitlab.$NAS_IP.nip.io
EOF

    # 创建 Docker Compose 文件
    cat > "$frp_dir/docker-compose.yml" << EOF
version: '3.8'

services:
  frpc:
    image: snowdreamtech/frpc:0.47.0
    container_name: yyc3-frpc
    Volumes:
      - ./frpc.ini:/etc/frp/frpc.ini
    restart: always
    networks:
      - yyc3-network

networks:
  yyc3-network:
    external: true
EOF

    # 创建网络
    if ! docker network inspect yyc3-network &>/dev/null; then
        docker network create yyc3-network
    fi

    # 启动服务
    cd "$frp_dir" && docker-compose up -d

    return 0
}

# 部署 GitLab 服务
deploy_gitlab() {
    local gitlab_dir="$ROOT_DIR/services/gitlab"
    mkdir -p "$gitlab_dir"/{config,logs,data}

    # 创建 Docker Compose 文件
    cat > "$gitlab_dir/docker-compose.yml" << EOF
version: '3.8'

services:
  gitlab:
    image: gitlab/gitlab-ce:latest
    container_name: yyc3-gitlab
    restart: always
    hostname: 'gitlab.$NAS_IP.nip.io'
    environment:
      GITLAB_OMNIBUS_CONFIG: |
        external_url 'http://gitlab.$NAS_IP.nip.io:8080'
        gitlab_rails['gitlab_shell_ssh_port'] = 2222
        unicorn['port'] = 8080
        nginx['listen_port'] = 80
    ports:
      - '8080:80'
      - '2222:22'
    Volumes:
      - '$gitlab_dir/config:/etc/gitlab'
      - '$gitlab_dir/logs:/var/log/gitlab'
      - '$gitlab_dir/data:/var/opt/gitlab'
    networks:
      - yyc3-network

networks:
  yyc3-network:
    external: true
EOF

    # 启动服务
    cd "$gitlab_dir" && docker-compose up -d

    return 0
}

# 部署 AI Router 服务
deploy_ai_router() {
    local ai_dir="$ROOT_DIR/services/ai-router"
    mkdir -p "$ai_dir"

    # 创建 Docker Compose 文件
    cat > "$ai_dir/docker-compose.yml" << EOF
version: '3.8'

services:
  ai-router:
    image: doubaoai/ai-router:latest
    container_name: yyc3-ai-router
    restart: always
    ports:
      - '8888:80'
    environment:
      - API_KEY=your_openai_api_key
    networks:
      - yyc3-network

networks:
  yyc3-network:
    external: true
EOF

    # 启动服务
    cd "$ai_dir" && docker-compose up -d

    return 0
}

# 部署 NPM 注册服务
deploy_npm_registry() {
    local npm_dir="$ROOT_DIR/services/npm-registry"
    mkdir -p "$npm_dir/data"

    # 创建 Docker Compose 文件
    cat > "$npm_dir/docker-compose.yml" << EOF
version: '3.8'

services:
  verdaccio:
    image: verdaccio/verdaccio:5
    container_name: yyc3-npm-registry
    restart: always
    ports:
      - '4873:4873'
    Volumes:
      - '$npm_dir/data:/verdaccio/storage'
      - '$npm_dir/conf:/verdaccio/conf'
    networks:
      - yyc3-network

networks:
  yyc3-network:
    external: true
EOF

    # 启动服务
    cd "$npm_dir" && docker-compose up -d

    return 0
}

# 部署监控系统
deploy_monitoring() {
    local monitor_dir="$ROOT_DIR/services/monitoring"
    mkdir -p "$monitor_dir"/{prometheus,grafana,alertmanager}

    # 创建 Prometheus 配置
    cat > "$monitor_dir/prometheus/prometheus.yml" << EOF
global:
  scrape_interval: 15s
  evaluation_interval: 15s

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']

  - job_name: 'node'
    static_configs:
      - targets: ['$NAS_IP:9100']
EOF

    # 创建 Grafana 配置
    mkdir -p "$monitor_dir/grafana/dashboards"
    cat > "$monitor_dir/grafana/datasources/datasource.yml" << EOF
apiVersion: 1

datasources:
  - name: Prometheus
    type: prometheus
    url: http://prometheus:9090
    access: proxy
    isDefault: true
EOF

    # 创建 AlertManager 配置
    cat > "$monitor_dir/alertmanager/config.yml" << EOF
global:
  smtp_smarthost: 'smtp.example.com:587'
  smtp_from: 'alertmanager@example.com'
  smtp_auth_username: 'alertmanager'
  smtp_auth_password: 'password'

route:
  receiver: 'email'

receivers:
  - name: 'email'
    email_configs:
      - to: 'admin@example.com'
EOF

    # 创建 Docker Compose 文件
    cat > "$monitor_dir/docker-compose.yml" << EOF
version: '3.8'

services:
  prometheus:
    image: prom/prometheus:latest
    container_name: yyc3-prometheus
    restart: always
    Volumes:
      - '$monitor_dir/prometheus/prometheus.yml:/etc/prometheus/prometheus.yml'
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
    ports:
      - '9090:9090'
    networks:
      - yyc3-network

  grafana:
    image: grafana/grafana:latest
    container_name: yyc3-grafana
    restart: always
    Volumes:
      - '$monitor_dir/grafana/datasources:/etc/grafana/datasources'
      - '$monitor_dir/grafana/dashboards:/var/lib/grafana/dashboards'
    ports:
      - '3000:3000'
    networks:
      - yyc3-network

  alertmanager:
    image: prom/alertmanager:latest
    container_name: yyc3-alertmanager
    restart: always
    Volumes:
      - '$monitor_dir/alertmanager/config.yml:/etc/alertmanager/config.yml'
    command:
      - '--config.file=/etc/alertmanager/config.yml'
    ports:
      - '9093:9093'
    networks:
      - yyc3-network

networks:
  yyc3-network:
    external: true
EOF

    # 启动服务
    cd "$monitor_dir" && docker-compose up -d

    return 0
}

# 验证部署结果
verify_deployment() {
    log_step "验证部署结果..."

    local services=(
        "3001:YYC3 管理面板"
        "4873:NPM 私有仓库"
        "8080:GitLab"
        "8888:AI 路由器"
        "9090:Prometheus"
        "3000:Grafana"
        "9093:AlertManager"
    )

    local success_count=0
    local total_count=${#services[@]}

    log_info "开始验证服务状态，可能需要几分钟时间..."

    # 等待所有服务启动（最多5分钟）
    log_info "等待服务启动（最多5分钟）..."
    sleep 300

    for service_info in "${services[@]}"; do
        local port=$(echo "$service_info" | cut -d':' -f1)
        local name=$(echo "$service_info" | cut -d':' -f2)

        log_info "验证 $name - 端口 $port ..."

        # 尝试多次，提高验证准确性
        local attempts=5
        local success=false

        for ((i=1; i<=$attempts; i++)); do
            if curl -s --connect-timeout 10 "http://$NAS_IP:$port" > /dev/null; then
                log_success "$name 验证通过"
                success=true
                ((success_count++))
                break
            else
                log_warning "尝试 $i/$attempts: $name 未响应，重试中..."
                sleep 10
            fi
        done

        if [ "$success" = false ]; then
            log_error "$name 验证失败，服务可能未正常启动"
        fi
    done

    echo ""
    log_highlight "部署验证结果: $success_count/$total_count 服务正常运行"

    if [ "$success_count" -lt "$total_count" ]; then
        log_warning "部分服务未通过验证，请检查日志: $LOG_FILE"
        return 1
    else
        log_success "所有服务验证通过！"
        return 0
    fi
}

# 安全加固
security_hardening() {
    log_step "执行安全加固..."

    # 创建防火墙规则
    log_info "配置防火墙..."
    if command -v ufw &> /dev/null; then
        ufw allow 22/tcp
        ufw allow 80/tcp
        ufw allow 443/tcp
        ufw allow 3001/tcp
        ufw allow 8080/tcp
        ufw --force enable
        log_success "防火墙配置完成"
    else
        log_warning "未找到 ufw，跳过防火墙配置"
    fi

    # 设置 Docker 自动更新
    log_info "配置 Docker 自动更新..."
    mkdir -p /etc/apt/apt.conf.d
    cat > /etc/apt/apt.conf.d/20auto-upgrades << EOF
APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Unattended-Upgrade "1";
EOF
    log_success "Docker 自动更新配置完成"

    # 配置服务账户权限
    log_info "配置服务账户权限..."
    chmod -R 700 "$ROOT_DIR"
    log_success "权限配置完成"

    log_success "安全加固完成"
}

# 创建管理脚本
create_management_script() {
    log_step "创建管理脚本..."

    cat > "$ROOT_DIR/manage.sh" << EOF
#!/bin/bash

# YYC³ 管理脚本
# 自动生成，请勿手动修改

ROOT_DIR="$ROOT_DIR"
NAS_IP="$NAS_IP"
LOG_FILE="$LOG_FILE"

show_menu() {
    echo "🌐 YYC³ 开发者工具包管理"
    echo "========================="
    echo "1. 启动所有服务"
    echo "2. 停止所有服务"
    echo "3. 重启所有服务"
    echo "4. 查看服务状态"
    echo "5. 查看服务日志"
    echo "6. 更新所有服务"
    echo "7. 创建系统备份"
    echo "8. 安全检查"
    echo "0. 退出"
    echo "========================="
}

start_services() {
    echo "启动所有服务..."
    find "$ROOT_DIR/services" -name "docker-compose.yml" -exec dirname {} \; | while read dir; do
        echo "启动 $dir 中的服务..."
        cd "$dir" && docker-compose up -d
    done
    echo "✅ 所有服务已启动"
}

stop_services() {
    echo "停止所有服务..."
    find "$ROOT_DIR/services" -name "docker-compose.yml" -exec dirname {} \; | while read dir; do
        echo "停止 $dir 中的服务..."
        cd "$dir" && docker-compose down
    done
    echo "✅ 所有服务已停止"
}

restart_services() {
    stop_services
    start_services
}

show_status() {
    echo "服务状态:"
    docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

    echo -e "\n服务访问地址:"
    echo "  • YYC³ 管理面板: http://$NAS_IP:3001"
    echo "  • GitLab: http://$NAS_IP:8080"
    echo "  • AI 路由器: http://$NAS_IP:8888"
    echo "  • NPM 仓库: http://$NAS_IP:4873"
    echo "  • 监控系统: http://$NAS_IP:3000"
}

show_logs() {
    echo "可用服务:"
    docker ps --format "{{.Names}}"

    read -p "请输入要查看日志的服务名称: " service

    if [ -n "$service" ]; then
        docker logs -f "$service"
    else
        echo "请输入有效的服务名称"
    fi
}

update_services() {
    echo "更新所有服务..."
    find "$ROOT_DIR/services" -name "docker-compose.yml" -exec dirname {} \; | while read dir; do
        echo "更新 $dir 中的服务..."
        cd "$dir" && docker-compose pull && docker-compose up -d
    done
    echo "✅ 所有服务已更新"
}

create_backup() {
    local backup_dir="$ROOT_DIR/backups/backup_$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$backup_dir"

    echo "正在创建备份..."
    tar -czf "$backup_dir/configs.tar.gz" "$ROOT_DIR/configs"
    tar -czf "$backup_dir/services.tar.gz" "$ROOT_DIR/services"

    # 备份数据库
    echo "备份数据库..."
    # TODO: 添加数据库备份逻辑

    echo "✅ 备份完成: $backup_dir"
}

security_check() {
    echo "执行安全检查..."

    # 检查容器运行状态
    local running_containers=$(docker ps -q | wc -l)
    local total_containers=$(docker ps -aq | wc -l)

    echo "• 运行中容器: $running_containers/$total_containers"

    # 检查开放端口
    echo "• 开放端口:"
    ss -tulpn | grep LISTEN

    # 检查磁盘空间
    echo "• 磁盘空间:"
    df -h "$ROOT_DIR"

    echo "✅ 安全检查完成"
}

while true; do
    show_menu
    read -p "请选择操作 (0-8): " choice

    case $choice in
        1) start_services ;;
        2) stop_services ;;
        3) restart_services ;;
        4) show_status ;;
        5) show_logs ;;
        6) update_services ;;
        7) create_backup ;;
        8) security_check ;;
        0) exit 0 ;;
        *) echo "无效选择，请重新输入" ;;
    esac

    echo ""
    read -p "按回车键继续..."
done
EOF

    chmod +x "$ROOT_DIR/manage.sh"
    log_success "管理脚本创建完成: $ROOT_DIR/manage.sh"
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
    echo "  • 管理脚本: $ROOT_DIR/manage.sh"
    echo "  • 查看服务状态: docker ps"
    echo "  • 查看日志: docker logs -f <容器名>"
    echo "  • 重启服务: docker-compose restart"
    echo ""
    log_highlight "📚 文档位置:"
    echo "  • 部署文档: $ROOT_DIR/docs/"
    echo "  • 配置文件: $ROOT_DIR/configs/"
    echo "  • 日志文件: $LOG_FILE"
    echo ""
}

# 清理临时文件
cleanup() {
    log_step "清理临时文件..."
    if [ -d "$TEMP_DIR" ]; then
        trash "$TEMP_DIR"
    fi
    log_success "清理完成"
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

    # 创建日志文件
    mkdir -p "$(dirname "$LOG_FILE")"
    touch "$LOG_FILE"

    # 执行部署步骤
    check_prerequisites
    interactive_config
    create_directories
    deploy_services
    verify_deployment
    security_hardening
    create_management_script
    show_access_info
    cleanup

    echo ""
    log_success "🎉 YYC³ 开发者工具包部署完成！"
    echo ""
    log_highlight "🚀 下一步操作:"
    echo "  1. 访问管理面板配置系统"
    echo "  2. 在 GitLab 中创建第一个项目"
    echo "  3. 配置 AI 模型和监控告警"
    echo "  4. 使用 $ROOT_DIR/manage.sh 管理服务"
    echo ""
    log_info "如有问题，请查看日志文件: $LOG_FILE"
}

# 执行主函数
main "$@"
