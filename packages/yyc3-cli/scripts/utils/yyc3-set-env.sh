#!/bin/bash

# YYC³ 环境变量设置脚本
# 设置所有必需的环境变量

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
log_highlight() { echo -e "${CYAN}[重点]${NC} $1"; }

echo -e "${CYAN}"
cat << 'EOF'
    ██╗   ██╗██╗   ██╗ ██████╗██████╗     ███████╗███╗   ██╗██╗   ██╗
    ╚██╗ ██╔╝╚██╗ ██╔╝██╔════╝╚════██╗    ██╔════╝████╗  ██║██║   ██║
     ╚████╔╝  ╚████╔╝ ██║      █████╔╝    █████╗  ██╔██╗ ██║██║   ██║
      ╚██╔╝    ╚██╔╝  ██║      ╚═══██╗    ██╔══╝  ██║╚██╗██║╚██╗ ██╔╝
       ██║      ██║   ╚██████╗██████╔╝    ███████╗██║ ╚████║ ╚████╔╝ 
       ╚═╝      ╚═╝    ╚═════╝╚═════╝     ╚══════╝╚═╝  ╚═══╝  ╚═══╝  
                                                                      
    YYC³ 环境变量设置
    Environment Variables Setup
    ===========================
EOF
echo -e "${NC}"

log_info "设置 YYC³ 开发者工具包环境变量..."

# 核心配置
export YYC3_REGISTRY="http://192.168.0.9:4873"
export NEXT_PUBLIC_BASE_URL="http://192.168.0.9:3001"
export PORT="3001"

# 生成 JWT 密钥
if command -v openssl &> /dev/null; then
    export JWT_SECRET=$(openssl rand -base64 32)
else
    export JWT_SECRET="yyc3-default-jwt-secret-$(date +%s)"
    log_warning "OpenSSL 未安装，使用默认 JWT 密钥"
fi

# 监控配置
export MONITORING_ENDPOINT="http://192.168.0.9:9090"
export MONITORING_API_KEY="yyc3-monitoring-key-$(date +%s)"
export ALERT_WEBHOOK="http://192.168.0.9:9093"

# 应用配置
export APP_VERSION="1.0.0"
export SERVICE_NAME="yyc3-devkit"
export SERVICE_HOST="192.168.0.9"

# 功能开关
export FEATURE_SECURITY="true"
export FEATURE_MONITORING="true"
export FEATURE_AUDIT="true"

# 安全配置
export SECURITY_AUDIT_ENABLED="true"
export SECURITY_INTEGRITY_CHECK_ENABLED="true"
export SECURITY_PERMISSIONS_CHECK_ENABLED="true"
export STRICT_SECURITY_MODE="true"

# 监控配置
export MONITORING_ENABLED="true"
export MONITORING_SAMPLE_RATE="1.0"
export MONITORING_ENDPOINTS="http://192.168.0.9:9090,http://192.168.0.9:3000"

# 访问控制
export BLOCKED_IPS=""
export ALLOWED_ENVIRONMENTS="development,staging,production"
export ALLOWED_REGIONS="CN,US,EU"

# 合规配置
export COMPLIANCE_GDPR="true"
export COMPLIANCE_CCPA="true"

# 微信通知 (需要用户自行配置)
export WECHAT_WEBHOOK_URL="https://qyapi.weixin.qq.com/cgi-bin/webhook/send?key=YOUR_KEY"

# 创建环境变量文件
ENV_FILE="/volume2/YC/.env"
cat > "$ENV_FILE" << EOF
# YYC³ 开发者工具包环境变量
# 生成时间: $(date)

# 核心配置
YYC3_REGISTRY=$YYC3_REGISTRY
NEXT_PUBLIC_BASE_URL=$NEXT_PUBLIC_BASE_URL
PORT=$PORT
JWT_SECRET=$JWT_SECRET

# 监控配置
MONITORING_ENDPOINT=$MONITORING_ENDPOINT
MONITORING_API_KEY=$MONITORING_API_KEY
ALERT_WEBHOOK=$ALERT_WEBHOOK
MONITORING_ENABLED=$MONITORING_ENABLED
MONITORING_SAMPLE_RATE=$MONITORING_SAMPLE_RATE
MONITORING_ENDPOINTS=$MONITORING_ENDPOINTS

# 应用配置
APP_VERSION=$APP_VERSION
SERVICE_NAME=$SERVICE_NAME
SERVICE_HOST=$SERVICE_HOST

# 功能开关
FEATURE_SECURITY=$FEATURE_SECURITY
FEATURE_MONITORING=$FEATURE_MONITORING
FEATURE_AUDIT=$FEATURE_AUDIT

# 安全配置
SECURITY_AUDIT_ENABLED=$SECURITY_AUDIT_ENABLED
SECURITY_INTEGRITY_CHECK_ENABLED=$SECURITY_INTEGRITY_CHECK_ENABLED
SECURITY_PERMISSIONS_CHECK_ENABLED=$SECURITY_PERMISSIONS_CHECK_ENABLED
STRICT_SECURITY_MODE=$STRICT_SECURITY_MODE

# 访问控制
BLOCKED_IPS=$BLOCKED_IPS
ALLOWED_ENVIRONMENTS=$ALLOWED_ENVIRONMENTS
ALLOWED_REGIONS=$ALLOWED_REGIONS

# 合规配置
COMPLIANCE_GDPR=$COMPLIANCE_GDPR
COMPLIANCE_CCPA=$COMPLIANCE_CCPA

# 微信通知 (请修改为实际的 Webhook URL)
WECHAT_WEBHOOK_URL=$WECHAT_WEBHOOK_URL
EOF

log_success "环境变量设置完成！"
echo ""
log_highlight "📋 已设置的环境变量:"
echo "  🔧 YYC3_REGISTRY: $YYC3_REGISTRY"
echo "  🌐 NEXT_PUBLIC_BASE_URL: $NEXT_PUBLIC_BASE_URL"
echo "  🚪 PORT: $PORT"
echo "  🔑 JWT_SECRET: ${JWT_SECRET:0:20}..."
echo "  📊 MONITORING_ENDPOINT: $MONITORING_ENDPOINT"
echo "  🚨 ALERT_WEBHOOK: $ALERT_WEBHOOK"
echo ""
log_highlight "📄 环境变量文件: $ENV_FILE"
echo ""
log_info "要在当前会话中使用这些变量，请运行:"
echo "  source $ENV_FILE"
echo ""
log_warning "⚠️  请记得修改 WECHAT_WEBHOOK_URL 为实际的微信 Webhook 地址"