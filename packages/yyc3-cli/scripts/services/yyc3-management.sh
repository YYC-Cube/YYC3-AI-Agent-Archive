#!/bin/bash

# YYC³ 配置验证脚本
# 验证所有配置文件中的IP、域名和邮箱设置

set -e

ROOT_DIR="/volume2/YC"
NEW_IP="192.168.3.9"
NEW_DOMAIN="china.0379.pro"
NEW_EMAIL_SERVER="0379.email"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[信息]${NC} $1"; }
log_success() { echo -e "${GREEN}[成功]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[警告]${NC} $1"; }
log_error() { echo -e "${RED}[错误]${NC} $1"; }
log_highlight() { echo -e "${CYAN}[重点]${NC} $1"; }

# 显示欢迎信息
show_welcome() {
    clear
    echo -e "${CYAN}"
    cat << 'EOF'
    ██╗   ██╗██╗   ██╗ ██████╗██████╗     ██████╗ ██████╗ ███╗   ██╗███████╗██╗ ██████╗ 
    ╚██╗ ██╔╝╚██╗ ██╔╝██╔════╝╚════██╗   ██╔════╝██╔═══██╗████╗  ██║██╔════╝██║██╔════╝ 
     ╚████╔╝  ╚████╔╝ ██║      █████╔╝   ██║     ██║   ██║██╔██╗ ██║█████╗  ██║██║  ███╗
      ╚██╔╝    ╚██╔╝  ██║      ╚═══██╗   ██║     ██║   ██║██║╚██╗██║██╔══╝  ██║██║   ██║
       ██║      ██║   ╚██████╗██████╔╝   ╚██████╗╚██████╔╝██║ ╚████║██║     ██║╚██████╔╝
       ╚═╝      ╚═╝    ╚═════╝╚═════╝     ╚═════╝ ╚═════╝ ╚═╝  ╚═══╝╚═╝     ╚═╝ ╚═════╝ 
                                                                                         
    YYC³ 配置验证器
    Configuration Validator
    =======================
EOF
    echo -e "${NC}"
    echo ""
    echo "🔍 验证配置文件中的IP、域名和邮箱设置"
    echo "📅 验证时间: $(date)"
    echo "🌐 目标IP: $NEW_IP"
    echo "🌍 目标域名: $NEW_DOMAIN"
    echo "📧 邮箱服务器: $NEW_EMAIL_SERVER"
    echo ""
}

# 验证IP地址配置
validate_ip_config() {
    log_info "验证IP地址配置..."
    
    local files_to_check=(
        "scripts/advanced-setup.sh"
        "scripts/health-check.sh"
        "scripts/complete-deployment.sh"
        "scripts/monitoring-alerts.sh"
        "scripts/set-env.sh"
        "scripts/quick-start.sh"
        "services/frp-beginner/frpc.ini"
    )
    
    local ip_count=0
    local correct_count=0
    
    for file in "${files_to_check[@]}"; do
        if [ -f "$ROOT_DIR/$file" ]; then
            local old_ip_count=$(grep -c "192.168.0.9" "$ROOT_DIR/$file" 2>/dev/null || echo 0)
            local new_ip_count=$(grep -c "$NEW_IP" "$ROOT_DIR/$file" 2>/dev/null || echo 0)
            
            ip_count=$((ip_count + old_ip_count + new_ip_count))
            correct_count=$((correct_count + new_ip_count))
            
            if [ "$old_ip_count" -gt 0 ]; then
                log_warning "$file 中仍有 $old_ip_count 个旧IP地址需要更新"
            elif [ "$new_ip_count" -gt 0 ]; then
                log_success "$file 中有 $new_ip_count 个正确的IP地址"
            fi
        else
            log_error "文件不存在: $file"
        fi
    done
    
    echo ""
    log_highlight "IP地址验证结果: $correct_count/$ip_count 正确"
}

# 验证域名配置
validate_domain_config() {
    log_info "验证域名配置..."
    
    local domain_files=(
        "services/frp-beginner/frpc.ini"
        "scripts/monitoring-alerts.sh"
    )
    
    local domain_found=false
    
    for file in "${domain_files[@]}"; do
        if [ -f "$ROOT_DIR/$file" ]; then
            if grep -q "$NEW_DOMAIN" "$ROOT_DIR/$file"; then
                log_success "$file 中包含正确的域名配置"
                domain_found=true
            else
                log_warning "$file 中未找到域名配置"
            fi
        fi
    done
    
    if [ "$domain_found" = true ]; then
        log_success "域名配置验证通过"
    else
        log_error "域名配置验证失败"
    fi
}

# 验证邮箱服务器配置
validate_email_config() {
    log_info "验证邮箱服务器配置..."
    
    local email_files=(
        "scripts/advanced-setup.sh"
        "scripts/monitoring-alerts.sh"
    )
    
    local email_found=false
    
    for file in "${email_files[@]}"; do
        if [ -f "$ROOT_DIR/$file" ]; then
            if grep -q "$NEW_EMAIL_SERVER" "$ROOT_DIR/$file"; then
                log_success "$file 中包含正确的邮箱服务器配置"
                email_found=true
            else
                log_warning "$file 中未找到邮箱服务器配置"
            fi
        fi
    done
    
    if [ "$email_found" = true ]; then
        log_success "邮箱服务器配置验证通过"
    else
        log_error "邮箱服务器配置验证失败"
    fi
}

# 验证端口配置
validate_port_config() {
    log_info "验证端口配置..."
    
    local expected_ports=(
        "3001:YYC³ 管理面板"
        "4873:NPM 私有仓库"
        "8080:GitLab"
        "8888:AI 路由器"
        "9090:Prometheus"
        "3000:Grafana"
        "9093:AlertManager"
        "11434:Ollama 主服务"
        "11435:Ollama 备用服务"
    )
    
    echo ""
    log_highlight "预期端口配置:"
    for port_info in "${expected_ports[@]}"; do
        local port=$(echo "$port_info" | cut -d':' -f1)
        local service=$(echo "$port_info" | cut -d':' -f2)
        echo "  • $service: $port"
    done
}

# 验证环境变量
validate_environment_variables() {
    log_info "验证环境变量配置..."
    
    local env_file="$ROOT_DIR/.env"
    
    if [ -f "$env_file" ]; then
        local required_vars=(
            "YYC3_REGISTRY"
            "NEXT_PUBLIC_BASE_URL"
            "MONITORING_ENDPOINT"
            "SERVICE_HOST"
        )
        
        for var in "${required_vars[@]}"; do
            if grep -q "^$var=" "$env_file"; then
                local value=$(grep "^$var=" "$env_file" | cut -d'=' -f2)
                if [[ "$value" == *"$NEW_IP"* ]]; then
                    log_success "$var 配置正确: $value"
                else
                    log_warning "$var 可能需要更新: $value"
                fi
            else
                log_error "缺少环境变量: $var"
            fi
        done
    else
        log_error "环境变量文件不存在: $env_file"
    fi
}

# 生成配置报告
generate_config_report() {
    log_info "生成配置验证报告..."
    
    local report_file="$ROOT_DIR/config-validation-report-$(date +%Y%m%d-%H%M%S).txt"
    
    cat > "$report_file" << EOF
YYC³ 配置验证报告
==================
验证时间: $(date)
目标IP: $NEW_IP
目标域名: $NEW_DOMAIN
邮箱服务器: $NEW_EMAIL_SERVER

配置文件检查结果:
$(find "$ROOT_DIR" -name "*.sh" -o -name "*.yml" -o -name "*.ini" -o -name "*.conf" | while read file; do
    if grep -q "192.168.0.9" "$file" 2>/dev/null; then
        echo "⚠️  $file - 包含旧IP地址"
    elif grep -q "$NEW_IP" "$file" 2>/dev/null; then
        echo "✅ $file - IP地址已更新"
    fi
done)

域名配置检查:
$(if grep -r "$NEW_DOMAIN" "$ROOT_DIR" >/dev/null 2>&1; then
    echo "✅ 域名配置已更新"
else
    echo "⚠️  域名配置需要检查"
fi)

邮箱服务器配置检查:
$(if grep -r "$NEW_EMAIL_SERVER" "$ROOT_DIR" >/dev/null 2>&1; then
    echo "✅ 邮箱服务器配置已更新"
else
    echo "⚠️  邮箱服务器配置需要检查"
fi)

建议操作:
1. 检查所有标记为⚠️的文件
2. 手动验证关键服务的配置
3. 测试网络连接和服务可用性
4. 更新DNS解析记录
5. 配置邮箱服务器认证信息

EOF

    log_success "配置验证报告已生成: $report_file"
}

# 提供修复建议
provide_fix_suggestions() {
    log_info "提供配置修复建议..."
    
    echo ""
    log_highlight "🔧 配置修复建议:"
    echo ""
    echo "1. 批量替换IP地址:"
    echo "   find $ROOT_DIR -type f $$ -name '*.sh' -o -name '*.yml' -o -name '*.ini' $$ -exec sed -i 's/192.168.0.9/$NEW_IP/g' {} +"
    echo ""
    echo "2. 更新域名配置:"
    echo "   # 编辑 FRP 配置文件"
    echo "   nano $ROOT_DIR/services/frp-beginner/frpc.ini"
    echo ""
    echo "3. 配置邮箱服务器:"
    echo "   # 更新监控告警配置"
    echo "   nano $ROOT_DIR/scripts/monitoring-alerts.sh"
    echo ""
    echo "4. 验证环境变量:"
    echo "   source $ROOT_DIR/scripts/set-env.sh"
    echo ""
    echo "5. 测试网络连接:"
    echo "   curl http://$NEW_IP:3001"
    echo "   curl http://$NEW_IP:4873"
    echo ""
    echo "6. 重启相关服务:"
    echo "   docker-compose restart"
    echo ""
}

# 主执行函数
main() {
    show_welcome
    
    validate_ip_config
    validate_domain_config
    validate_email_config
    validate_port_config
    validate_environment_variables
    generate_config_report
    provide_fix_suggestions
    
    echo ""
    log_success "🎉 配置验证完成！"
    echo ""
    log_highlight "📋 验证摘要:"
    echo "  🌐 IP地址: $NEW_IP"
    echo "  🌍 域名: $NEW_DOMAIN"
    echo "  📧 邮箱服务器: $NEW_EMAIL_SERVER"
    echo ""
    log_highlight "🚀 下一步操作:"
    echo "  1. 根据报告修复配置问题"
    echo "  2. 更新DNS解析记录"
    echo "  3. 配置邮箱服务器认证"
    echo "  4. 重启所有服务"
    echo "  5. 验证服务可用性"
    echo ""
}

# 执行主函数
main "$@"