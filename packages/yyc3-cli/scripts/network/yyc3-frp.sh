#!/bin/bash

# YYC³ 开发环境内网穿透配置脚本（增强版）
# 作者：YYC³
# 版本：2.0
# 更新日期：2025-07-12

# 基础配置（可通过交互修改）
ROOT_DIR="/Volume1/www/frpc"
NAS_IP="192.168.3.45"
LOG_FILE="$ROOT_DIR/logs/penetration.log"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# 初始化日志系统
init_logging() {
    mkdir -p "$(dirname "$LOG_FILE")"
    exec &> >(tee -a "$LOG_FILE")  # 同时输出到控制台和日志文件
    log_info "脚本启动时间：$(date +'%Y-%m-%d %H:%M:%S')"
}

# 日志函数
log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }
log_step() { echo -e "${PURPLE}[STEP]${NC} $1"; }
log_highlight() { echo -e "${CYAN}[HIGHLIGHT]${NC} $1"; }

# 错误处理
set -euo pipefail
trap 'log_error "脚本在第 $LINENO 行执行失败"; exit 1' ERR

# 输入验证函数
validate_ip() {
    local ip=$1
    if [[ ! $ip =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        log_error "无效的IP地址: $ip"
        return 1
    fi
}

validate_port() {
    local port=$1
    if ! [[ $port =~ ^[0-9]+$ ]] || [ $port -lt 1 ] || [ $port -gt 65535 ]; then
        log_error "无效的端口: $port"
        return 1
    fi
}

# 依赖检查
check_dependencies() {
    log_step "检查系统依赖..."
    local dependencies=("docker" "docker-compose" "curl" "sed" "grep")
    for dep in "${dependencies[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            log_error "未找到 $dep，请先安装"
            if [ "$dep" = "docker" ]; then
                log_highlight "安装命令: curl -fsSL https://get.docker.com | sh"
            fi
            exit 1
        fi
    done
    log_success "依赖检查通过"
}

# 基础参数配置交互
configure_basic_params() {
    log_step "基础参数配置"
    
    # 根目录配置
    read -p "请输入根目录 (默认: $ROOT_DIR): " input_dir
    ROOT_DIR=${input_dir:-"$ROOT_DIR"}
    
    # NAS IP配置
    while true; do
        read -p "请输入NAS IP地址 (默认: $NAS_IP): " input_ip
        NAS_IP=${input_ip:-"$NAS_IP"}
        if validate_ip "$NAS_IP"; then
            break
        fi
    done
    
    # 日志文件路径
    LOG_FILE="$ROOT_DIR/logs/penetration.log"
}

# 配置备份
backup_config() {
    local config_file=$1
    if [ -f "$config_file" ]; then
        cp "$config_file" "${config_file}.$(date +%Y%m%d%H%M).bak"
        log_info "已备份旧配置至 ${config_file}.$(date +%Y%m%d%H%M).bak"
    fi
}

# 方案对比显示
show_comparison() {
    echo ""
    log_highlight "内网穿透方案对比"
    echo "=================="
    echo ""
    echo "| 方案      | 免费额度    | 稳定性 | 速度   | 安全性 | 配置难度 |"
    echo "|-----------|-------------|--------|--------|--------|----------|"
    echo "| frp       | 无限制      | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐   | ⭐⭐⭐     |"
    echo "| ngrok     | 1个隧道     | ⭐⭐⭐⭐   | ⭐⭐⭐⭐   | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐   |"
    echo "| nps       | 无限制      | ⭐⭐⭐⭐   | ⭐⭐⭐⭐   | ⭐⭐⭐     | ⭐⭐⭐     |"
    echo "| ZeroTier  | 25设备      | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐   |"
    echo "| Tailscale | 20设备      | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐   |"
    echo "| 自建方案  | 无限制      | ⭐⭐⭐     | ⭐⭐⭐⭐   | ⭐⭐⭐⭐⭐ | ⭐⭐       |"
    echo ""
    echo "💡 推荐选择："
    echo "• 个人开发: Tailscale 或 ZeroTier"
    echo "• 团队协作: frp 或 ngrok"
    echo "• 企业使用: 自建方案"
    echo ""
    read -p "按回车键返回..."
}

# 配置frp
setup_frp() {
    log_step "配置 frp 内网穿透..."
    local frp_dir="$ROOT_DIR/services/frp"
    mkdir -p "$frp_dir"
    
    # 备份旧配置
    backup_config "$frp_dir/frpc.toml"
    backup_config "$frp_dir/frps.toml"
    
    # 创建客户端配置
    cat > "$frp_dir/frpc.toml" << EOF
[common]
server_addr = YOUR_SERVER_IP
server_port = 7000
token = YOUR_TOKEN

[yc-web]
type = http
local_ip = $NAS_IP
local_port = 80
custom_domains = nas.0379.email

[yc-gitlab]
type = http
local_ip = $NAS_IP
local_port = 8080
custom_domains = gitlab.yourdomain.com
EOF

    # 创建服务端配置
    cat > "$frp_dir/frps.ini" << EOF
[common]
bind_port = 7000
token = YOUR_TOKEN
dashboard_port = 7500
dashboard_user = admin
dashboard_pwd = admin123

vhost_http_port = 80
vhost_https_port = 443

log_file = ./frps.log
log_level = info
log_max_days = 3
EOF

    # 创建Docker Compose
    cat > "$frp_dir/docker-compose.yml" << EOF
version: '3.8'
services:
  frpc:
    image: snowdreamtech/frpc:latest
    Volumes:
      - ./frpc.ini:/etc/frp/frpc.ini
    restart: unless-stopped
EOF

    # 创建配置脚本
    cat > "$frp_dir/configure.sh" << 'EOF'
#!/bin/bash
set -euo pipefail
source /etc/profile

echo "🔧 配置 frp 内网穿透"
echo "==================="

read -p "请输入 frp 服务器地址: " SERVER_ADDR
read -p "请输入认证令牌: " TOKEN
read -p "请输入您的域名 (如: yourdomain.com): " DOMAIN

sed -i "s/YOUR_SERVER_IP/$SERVER_ADDR/g" frpc.ini
sed -i "s/YOUR_TOKEN/$TOKEN/g" frpc.ini
sed -i "s/yourdomain.com/$DOMAIN/g" frpc.ini

echo "✅ frp 配置完成！"
echo "🚀 启动命令: docker-compose up -d frpc"
EOF

    chmod +x "$frp_dir/configure.sh"
    log_success "frp 配置完成，目录: $frp_dir"
}

# 配置ngrok
setup_ngrok() {
    log_step "配置 ngrok 内网穿透..."
    local ngrok_dir="$ROOT_DIR/services/ngrok"
    mkdir -p "$ngrok_dir"
    
    backup_config "$ngrok_dir/ngrok.yml"
    
    cat > "$ngrok_dir/ngrok.yml" << EOF
version: "2"
authtoken: YOUR_NGROK_TOKEN

tunnels:
  yc-web:
    proto: http
    addr: $NAS_IP:80
    subdomain: yc-dev
EOF

    cat > "$ngrok_dir/docker-compose.yml" << EOF
version: '3.8'
services:
  ngrok:
    image: ngrok/ngrok:latest
    Volumes:
      - ./ngrok.yml:/etc/ngrok.yml
    ports:
      - "4040:4040"
    restart: unless-stopped
EOF

    cat > "$ngrok_dir/configure.sh" << 'EOF'
#!/bin/bash
set -euo pipefail

echo "🔗 配置 ngrok 内网穿透"
echo "====================="

echo "1. 访问 https://ngrok.com 注册账户"
echo "2. 获取您的 authtoken"
read -p "请输入 authtoken: " TOKEN

sed -i "s/YOUR_NGROK_TOKEN/$TOKEN/g" ngrok.yml

echo "✅ 配置完成！"
echo "🚀 启动命令: docker-compose up -d"
EOF

    chmod +x "$ngrok_dir/configure.sh"
    log_success "ngrok 配置完成，目录: $ngrok_dir"
}

# 配置nps（新增）
setup_nps() {
    log_step "配置 nps 内网穿透..."
    local nps_dir="$ROOT_DIR/services/nps"
    mkdir -p "$nps_dir"
    
    backup_config "$nps_dir/nps.conf"
    
    cat > "$nps_dir/nps.conf" << EOF
# NPS 服务端配置
bridge_type=tcp
bridge_port=8024
web_host=0.0.0.0
web_port=8080
web_username=admin
web_password=admin
EOF

    cat > "$nps_dir/docker-compose.yml" << EOF
version: '3.8'
services:
  nps:
    image: npsorg/nps:latest
    Volumes:
      - ./nps.conf:/etc/nps/conf/nps.conf
    ports:
      - "8024:8024"
      - "8080:8080"
    restart: unless-stopped
EOF

    cat > "$nps_dir/configure.sh" << 'EOF'
#!/bin/bash
set -euo pipefail

echo "🔧 配置 nps 内网穿透"
echo "==================="

read -p "请输入服务器公网IP: " SERVER_IP

sed -i "s/bridge_port=8024/bridge_port=8024/g" nps.conf
sed -i "s/web_host=0.0.0.0/web_host=0.0.0.0/g" nps.conf

echo "✅ 配置完成！"
echo "🚀 启动命令: docker-compose up -d"
EOF

    chmod +x "$nps_dir/configure.sh"
    log_success "nps 配置完成，目录: $nps_dir"
}

# 配置ZeroTier
setup_zerotier() {
    log_step "配置 ZeroTier 组网..."
    local zt_dir="$ROOT_DIR/services/zerotier"
    mkdir -p "$zt_dir"
    
    backup_config "$zt_dir/docker-compose.yml"
    
    cat > "$zt_dir/docker-compose.yml" << EOF
version: '3.8'
services:
  zerotier:
    image: zyclonedx/zerotier:latest
    devices:
      - /dev/net/tun
    network_mode: host
    Volumes:
      - /var/lib/zerotier-one:/var/lib/zerotier-one
    cap_add:
      - NET_ADMIN
    restart: unless-stopped
EOF

    cat > "$zt_dir/configure.sh" << 'EOF'
#!/bin/bash
set -euo pipefail

echo "🌟 配置 ZeroTier 组网"
echo "==================="

echo "1. 访问 https://my.zerotier.com 创建网络"
read -p "请输入网络ID: " NETWORK_ID

docker-compose up -d
sleep 5
docker exec yc-zerotier zerotier-cli join $NETWORK_ID

echo "✅ 配置完成！"
echo "🔧 请在ZeroTier管理界面授权节点"
EOF

    chmod +x "$zt_dir/configure.sh"
    log_success "ZeroTier 配置完成，目录: $zt_dir"
}

# 配置Tailscale
setup_tailscale() {
    log_step "配置 Tailscale VPN..."
    local ts_dir="$ROOT_DIR/services/tailscale"
    mkdir -p "$ts_dir"
    
    backup_config "$ts_dir/docker-compose.yml"
    
    cat > "$ts_dir/docker-compose.yml" << EOF
version: '3.8'
services:
  tailscale:
    image: tailscale/tailscale:latest
    hostname: yc-nas
    environment:
      - TS_AUTHKEY=${TS_AUTHKEY}
    Volumes:
      - /var/lib/tailscale:/var/lib/tailscale
      - /dev/net/tun:/dev/net/tun
    cap_add:
      - NET_ADMIN
    network_mode: host
    restart: unless-stopped
EOF

    cat > "$ts_dir/configure.sh" << 'EOF'
#!/bin/bash
set -euo pipefail

echo "🔧 配置 Tailscale VPN"
echo "==================="

echo "1. 访问 https://tailscale.com 生成Auth Key"
read -p "请输入Auth Key: " AUTH_KEY

echo "TS_AUTHKEY=$AUTH_KEY" > .env
docker-compose up -d

echo "✅ 配置完成！"
echo "🌐 其他设备登录同一账户即可访问"
EOF

    chmod +x "$ts_dir/configure.sh"
    log_success "Tailscale 配置完成，目录: $ts_dir"
}

# 配置自建方案
setup_custom() {
    log_step "配置自建内网穿透方案..."
    local custom_dir="$ROOT_DIR/services/custom-tunnel"
    mkdir -p "$custom_dir"
    
    backup_config "$custom_dir/ssh-tunnel.sh"
    
    cat > "$custom_dir/ssh-tunnel.sh" << 'EOF'
#!/bin/bash
set -euo pipefail

SERVER_IP="YOUR_SERVER_IP"
SERVER_USER="YOUR_USERNAME"
SSH_KEY="$HOME/.ssh/id_rsa"

ssh -N -R 8080:192.168.3.45:80 \
    -R 8081:192.168.3.45:8080 \
    -i $SSH_KEY \
    $SERVER_USER@$SERVER_IP
EOF

    chmod +x "$custom_dir/ssh-tunnel.sh"
    log_success "自建方案配置完成，目录: $custom_dir"
}

# 创建统一管理脚本
create_tunnel_manager() {
    log_step "创建内网穿透管理器..."
    local manager_file="$ROOT_DIR/development/scripts/tunnel-manager.sh"
    mkdir -p "$(dirname "$manager_file")"
    
    backup_config "$manager_file"
    
    cat > "$manager_file" << 'EOF'
#!/bin/bash
# 内网穿透管理器
# 自动生成，请勿手动修改

ROOT_DIR="/Volume1/YYC"

show_menu() {
    echo "🌐 YYC³ 内网穿透管理器"
    echo "==================="
    echo "1. 启动 frp 客户端"
    echo "2. 启动 ngrok"
    echo "3. 启动 nps"
    echo "4. 启动 ZeroTier"
    echo "5. 启动 Tailscale"
    echo "6. 启动自建隧道"
    echo "7. 查看状态"
    echo "8. 停止所有"
    echo "0. 退出"
}

start_service() {
    local service=$1
    cd "$ROOT_DIR/services/$service" && docker-compose up -d
    echo "✅ $service 已启动"
}

show_status() {
    echo "📊 服务状态："
    docker ps | grep -E "yc-(frpc|ngrok|nps|zerotier|tailscale)"
}

stop_all() {
    docker stop yc-frpc yc-ngrok yc-nps yc-zerotier yc-tailscale
    echo "⏹️ 所有服务已停止"
}

while true; do
    show_menu
    read -p "选择操作: " choice
    
    case $choice in
        1) start_service "frp" ;;
        2) start_service "ngrok" ;;
        3) start_service "nps" ;;
        4) start_service "zerotier" ;;
        5) start_service "tailscale" ;;
        6) cd "$ROOT_DIR/services/custom-tunnel" && ./ssh-tunnel.sh & ;;
        7) show_status ;;
        8) stop_all ;;
        0) exit 0 ;;
    esac
done
EOF

    chmod +x "$manager_file"
    log_success "管理脚本创建完成: $manager_file"
}

# 主函数
main() {
    init_logging
    check_dependencies
    configure_basic_params
    
    while true; do
        clear
        show_penetration_options
        read -p "请选择方案 (0-7): " choice
        
        case $choice in
            1) setup_frp ;;
            2) setup_ngrok ;;
            3) setup_nps ;;
            4) setup_zerotier ;;
            5) setup_tailscale ;;
            6) setup_custom ;;
            7) show_comparison; continue ;;
            0) log_info "配置已取消"; exit 0 ;;
            *) log_error "无效选择，请重新输入"; continue ;;
        esac
        
        break
    done
    
    create_tunnel_manager
    setup_autostart
    
    log_success "所有配置完成！"
    log_highlight "管理脚本路径: $ROOT_DIR/development/scripts/tunnel-manager.sh"
    log_highlight "日志文件路径: $LOG_FILE"
    
    read -p "是否立即启动管理器？(y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        "$ROOT_DIR/development/scripts/tunnel-manager.sh"
    fi
}

# 执行主函数
main "$@"
