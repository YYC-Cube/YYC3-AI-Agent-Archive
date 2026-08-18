#!/bin/bash

# YYC³ AI 模型优化脚本
# 配置 AI 模型负载均衡和智能路由
# 作者：YYC³
# 版本：1.0
# 更新日期：2025-07-10

set -e

ROOT_DIR="/Volume2/YYC"
AI_DIR="/Volume2/YYC/ai-models"
OLLAMA_DIR="/Volume2/YYC/ollama"
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
    ██╗   ██╗██╗   ██╗ ██████╗██████╗     ███╗   ███╗ ██████╗ ██████╗  ███████╗██╗
    ╚██╗ ██╔╝╚██╗ ██╔╝██╔════╝╚════██╗    ████╗ ████║██╔═══██╗██╔═══██╗██╔════╝██║
     ╚████╔╝  ╚████╔╝ ██║      █████╔╝    ██╔████╔██║██║   ██║██║   ██║█████╗  ██║
      ╚██╔╝    ╚██╔╝  ██║      ╚═══██╗    ██║╚██╔╝██║██║   ██║██║   ██║██╔══╝  ██║
       ██║      ██║   ╚██████╗██████╔╝    ██║ ╚═╝ ██║╚██████╔╝██████╔╝ ███████╗███████╗
       ╚═╝      ╚═╝    ╚═════╝╚═════╝     ╚═╝     ╚═╝ ╚═════╝ ╚═════╝  ╚══════╝╚══════╝
                                                     
    YYC³ AI 模型优化
    AI Model Optimizer
    ==================
EOF
    echo -e "${NC}"
    echo ""
    echo "🤖 配置 AI 模型负载均衡和智能路由"
    echo "📅 优化时间: $(date)"
    echo "🌐 目标服务器: $NAS_IP"
    echo "📁 模型目录: $AI_DIR"
    echo ""
}

# 创建 AI 模型目录结构
create_ai_structure() {
    log_step "创建 AI 模型目录结构..."
    
    mkdir -p "$AI_DIR"/{models,cache,logs,config}
    mkdir -p "$AI_DIR/models"/{ollama,openai,custom}
    mkdir -p "$AI_DIR/cache"/{embeddings,responses,sessions}
    mkdir -p "$OLLAMA_DIR"/{models,config}
    
    log_success "目录结构创建完成"
}

# 创建 AI 模型负载均衡器
create_load_balancer() {
    log_step "创建 AI 模型负载均衡器..."
    
    cat > "$AI_DIR/docker-compose.yml" << 'EOF'
version: '3.8'

services:
  # Ollama 服务集群
  ollama-1:
    image: ollama/ollama:latest
    container_name: yc-ollama-1
    restart: unless-stopped
    ports:
      - "11434:11434"
    Volumes:
      - /Volume2/YC/ollama/models:/root/.ollama
    environment:
      - OLLAMA_HOST=0.0.0.0
      - OLLAMA_ORIGINS=*
    networks:
      - yyc3-network
    deploy:
      resources:
        limits:
          memory: 8G
        reservations:
          memory: 4G

  ollama-2:
    image: ollama/ollama:latest
    container_name: yc-ollama-2
    restart: unless-stopped
    ports:
      - "11435:11434"
    Volumes:
      - /Volume2/YC/ollama/models:/root/.ollama
    environment:
      - OLLAMA_HOST=0.0.0.0
      - OLLAMA_ORIGINS=*
    networks:
      - yyc3-network
    deploy:
      resources:
        limits:
          memory: 8G
        reservations:
          memory: 4G

  # AI 路由器
  ai-router:
    image: nginx:alpine
    container_name: yc-ai-router
    restart: unless-stopped
    ports:
      - "8888:80"
    Volumes:
      - /Volume2/YC/ai-models/config/nginx.conf:/etc/nginx/nginx.conf
      - /Volume2/YC/ai-models/logs:/var/log/nginx
    networks:
      - yyc3-network
    depends_on:
      - ollama-1
      - ollama-2

  # AI 监控
  ai-monitor:
    image: prom/prometheus:latest
    container_name: yc-ai-monitor
    restart: unless-stopped
    ports:
      - "9091:9090"
    Volumes:
      - /Volume2/YC/ai-models/config/prometheus.yml:/etc/prometheus/prometheus.yml
      - /Volume2/YC/ai-models/config/rules:/etc/prometheus/rules
    networks:
      - yyc3-network
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
      - '--storage.tsdb.path=/prometheus'
      - '--web.console.libraries=/etc/prometheus/console_libraries'
      - '--web.console.templates=/etc/prometheus/consoles'
      - '--web.enable-lifecycle'

  # Redis 缓存
  ai-cache:
    image: redis:7-alpine
    container_name: yc-ai-cache
    restart: unless-stopped
    ports:
      - "6380:6379"
    Volumes:
      - /Volume2/YC/ai-models/cache:/data
    networks:
      - yyc3-network
    command: redis-server --appendonly yes --maxmemory 2gb --maxmemory-policy allkeys-lru

networks:
  yyc3-network:
    external: true
EOF

    log_success "负载均衡器配置创建完成"
}

# 创建 Nginx 路由配置
create_nginx_config() {
    log_step "创建 Nginx 路由配置..."
    
    cat > "$AI_DIR/config/nginx.conf" << 'EOF'
events {
    worker_connections 1024;
}

http {
    upstream ollama_backend {
        least_conn;
        server ollama-1:11434 weight=1 max_fails=3 fail_timeout=30s;
        server ollama-2:11434 weight=1 max_fails=3 fail_timeout=30s;
    }
    
    upstream openai_backend {
        server api.openai.com:443;
    }
    
    # 日志格式
    log_format ai_access '$remote_addr - $remote_user [$time_local] '
                        '"$request" $status $body_bytes_sent '
                        '"$http_referer" "$http_user_agent" '
                        'rt=$request_time uct="$upstream_connect_time" '
                        'uht="$upstream_header_time" urt="$upstream_response_time"';
    
    access_log /var/log/nginx/ai_access.log ai_access;
    error_log /var/log/nginx/ai_error.log;
    
    # 限流配置
    limit_req_zone $binary_remote_addr zone=ai_limit:10m rate=10r/s;
    
    server {
        listen 80;
        server_name ai-router.yyc3.local;
        
        # 健康检查
        location /health {
            access_log off;
            return 200 "healthy\n";
            add_header Content-Type text/plain;
        }
        
        # Ollama 本地模型路由
        location /api/ollama/ {
            limit_req zone=ai_limit burst=20 nodelay;
            
            proxy_pass http://ollama_backend/;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            
            # 超时设置
            proxy_connect_timeout 30s;
            proxy_send_timeout 300s;
            proxy_read_timeout 300s;
            
            # 缓存设置
            proxy_cache_bypass $http_pragma;
            proxy_cache_revalidate on;
            proxy_cache_min_uses 1;
            proxy_cache_use_stale error timeout updating http_500 http_502 http_503 http_504;
        }
        
        # OpenAI API 代理
        location /api/openai/ {
            limit_req zone=ai_limit burst=10 nodelay;
            
            proxy_pass https://api.openai.com/;
            proxy_ssl_server_name on;
            proxy_set_header Host api.openai.com;
            proxy_set_header Authorization $http_authorization;
            
            # 超时设置
            proxy_connect_timeout 30s;
            proxy_send_timeout 60s;
            proxy_read_timeout 60s;
        }
        
        # 智能路由 - 根据模型类型自动选择后端
        location /api/chat {
            limit_req zone=ai_limit burst=15 nodelay;
            
            # 使用 Lua 脚本进行智能路由
            access_by_lua_block {
                local cjson = require "cjson"
                local http = require "resty.http"
                
                -- 读取请求体
                ngx.req.read_body()
                local body = ngx.req.get_body_data()
                
                if body then
                    local ok, data = pcall(cjson.decode, body)
                    if ok and data.model then
                        -- 本地模型路由到 Ollama
                        if string.match(data.model, "llama") or 
                           string.match(data.model, "qwen") or
                           string.match(data.model, "mistral") then
                            ngx.var.backend = "ollama_backend"
                        else
                            -- 其他模型路由到 OpenAI
                            ngx.var.backend = "openai_backend"
                        end
                    end
                end
            }
            
            proxy_pass http://$backend/v1/chat/completions;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        }
        
        # 模型管理接口
        location /api/models {
            proxy_pass http://ollama_backend/api/tags;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
        }
        
        # 统计信息
        location /stats {
            stub_status on;
            access_log off;
            allow 192.168.0.0/24;
            deny all;
        }
    }
}
EOF

    log_success "Nginx 配置创建完成"
}

# 创建 Prometheus 监控配置
create_prometheus_config() {
    log_step "创建 Prometheus 监控配置..."
    
    cat > "$AI_DIR/config/prometheus.yml" << 'EOF'
global:
  scrape_interval: 15s
  evaluation_interval: 15s

rule_files:
  - "rules/*.yml"

scrape_configs:
  - job_name: 'ai-router'
    static_configs:
      - targets: ['ai-router:80']
    metrics_path: /stats
    scrape_interval: 10s

  - job_name: 'ollama-1'
    static_configs:
      - targets: ['ollama-1:11434']
    metrics_path: /metrics
    scrape_interval: 30s

  - job_name: 'ollama-2'
    static_configs:
      - targets: ['ollama-2:11434']
    metrics_path: /metrics
    scrape_interval: 30s

  - job_name: 'redis'
    static_configs:
      - targets: ['ai-cache:6379']
    scrape_interval: 30s

alerting:
  alertmanagers:
    - static_configs:
        - targets:
          - alertmanager:9093
EOF

    # 创建告警规则
    mkdir -p "$AI_DIR/config/rules"
    
    cat > "$AI_DIR/config/rules/ai_alerts.yml" << 'EOF'
groups:
  - name: ai_model_alerts
    rules:
      - alert: OllamaServiceDown
        expr: up{job="ollama-1"} == 0 or up{job="ollama-2"} == 0
        for: 1m
        labels:
          severity: critical
        annotations:
          summary: "Ollama 服务不可用"
          description: "Ollama 服务 {{ $labels.instance }} 已停止响应超过 1 分钟"

      - alert: HighAIRequestLatency
        expr: nginx_http_request_duration_seconds{quantile="0.95"} > 10
        for: 2m
        labels:
          severity: warning
        annotations:
          summary: "AI 请求延迟过高"
          description: "95% 的 AI 请求延迟超过 10 秒"

      - alert: AIRequestRateHigh
        expr: rate(nginx_http_requests_total[5m]) > 100
        for: 1m
        labels:
          severity: warning
        annotations:
          summary: "AI 请求频率过高"
          description: "AI 请求频率超过每秒 100 次"

      - alert: RedisMemoryUsageHigh
        expr: redis_memory_used_bytes / redis_memory_max_bytes > 0.9
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "Redis 内存使用率过高"
          description: "Redis 内存使用率超过 90%"
EOF

    log_success "Prometheus 配置创建完成"
}

# 创建 AI 模型管理脚本
create_model_manager() {
    log_step "创建 AI 模型管理脚本..."
    
    cat > "$AI_DIR/manage-models.sh" << 'EOF'
#!/bin/bash

# YYC³ AI 模型管理脚本

set -e

OLLAMA_HOST="http://192.168.3.45:11434"
AI_ROUTER="http://192.168.3.45:8888"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[信息]${NC} $1"; }
log_success() { echo -e "${GREEN}[成功]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[警告]${NC} $1"; }
log_error() { echo -e "${RED}[错误]${NC} $1"; }

# 显示帮助信息
show_help() {
    echo "YYC³ AI 模型管理工具"
    echo ""
    echo "用法: $0 [命令] [参数]"
    echo ""
    echo "命令:"
    echo "  list                    列出所有可用模型"
    echo "  pull <model>           下载模型"
    echo "  remove <model>         删除模型"
    echo "  status                 查看服务状态"
    echo "  test <model>           测试模型"
    echo "  benchmark <model>      性能测试"
    echo "  install-recommended    安装推荐模型"
    echo ""
    echo "示例:"
    echo "  $0 list"
    echo "  $0 pull llama3.2:3b"
    echo "  $0 test qwen2.5:7b"
    echo ""
}

# 列出模型
list_models() {
    log_info "获取模型列表..."
    
    echo "本地模型:"
    curl -s "$OLLAMA_HOST/api/tags" | jq -r '.models[] | "\(.name) - \(.size/1024/1024/1024 | floor)GB"' 2>/dev/null || {
        log_error "无法连接到 Ollama 服务"
        return 1
    }
    
    echo ""
    echo "推荐模型:"
    echo "  llama3.2:3b     - 轻量级对话模型 (2GB)"
    echo "  qwen2.5:7b      - 中文优化模型 (4GB)"
    echo "  mistral:7b      - 高性能模型 (4GB)"
    echo "  codellama:7b    - 代码生成模型 (4GB)"
}

# 下载模型
pull_model() {
    local model="$1"
    if [ -z "$model" ]; then
        log_error "请指定模型名称"
        return 1
    fi
    
    log_info "下载模型: $model"
    curl -X POST "$OLLAMA_HOST/api/pull" \
        -H "Content-Type: application/json" \
        -d "{\"name\":\"$model\"}" \
        --no-buffer | while IFS= read -r line; do
        echo "$line" | jq -r '.status // empty' 2>/dev/null || echo "$line"
    done
    
    log_success "模型下载完成: $model"
}

# 删除模型
remove_model() {
    local model="$1"
    if [ -z "$model" ]; then
        log_error "请指定模型名称"
        return 1
    fi
    
    log_warning "删除模型: $model"
    curl -X DELETE "$OLLAMA_HOST/api/delete" \
        -H "Content-Type: application/json" \
        -d "{\"name\":\"$model\"}"
    
    log_success "模型删除完成: $model"
}

# 查看服务状态
check_status() {
    log_info "检查服务状态..."
    
    echo "Ollama 服务:"
    for port in 11434 11435; do
        if curl -s "http://192.168.3.45:$port" > /dev/null; then
            echo "  ✅ Ollama ($port) - 运行中"
        else
            echo "  ❌ Ollama ($port) - 停止"
        fi
    done
    
    echo ""
    echo "AI 路由器:"
    if curl -s "$AI_ROUTER/health" > /dev/null; then
        echo "  ✅ AI Router - 运行中"
    else
        echo "  ❌ AI Router - 停止"
    fi
    
    echo ""
    echo "Redis 缓存:"
    if redis-cli -h 192.168.3.45 -p 6380 ping > /dev/null 2>&1; then
        echo "  ✅ Redis - 运行中"
    else
        echo "  ❌ Redis - 停止"
    fi
}

# 测试模型
test_model() {
    local model="$1"
    if [ -z "$model" ]; then
        log_error "请指定模型名称"
        return 1
    fi
    
    log_info "测试模型: $model"
    
    local test_prompt="你好，请简单介绍一下你自己。"
    local start_time=$(date +%s.%N)
    
    local response=$(curl -s "$OLLAMA_HOST/api/generate" \
        -H "Content-Type: application/json" \
        -d "{\"model\":\"$model\",\"prompt\":\"$test_prompt\",\"stream\":false}")
    
    local end_time=$(date +%s.%N)
    local duration=$(echo "$end_time - $start_time" | bc)
    
    echo "响应时间: ${duration}s"
    echo "模型响应:"
    echo "$response" | jq -r '.response' 2>/dev/null || echo "$response"
}

# 性能测试
benchmark_model() {
    local model="$1"
    if [ -z "$model" ]; then
        log_error "请指定模型名称"
        return 1
    fi
    
    log_info "性能测试: $model"
    
    local prompts=(
        "写一个 Hello World 程序"
        "解释什么是人工智能"
        "计算 1+1 等于多少"
        "介绍一下 YYC³ 开发者工具包"
        "用 JavaScript 写一个排序函数"
    )
    
    local total_time=0
    local count=0
    
    for prompt in "${prompts[@]}"; do
        log_info "测试提示: $prompt"
        
        local start_time=$(date +%s.%N)
        curl -s "$OLLAMA_HOST/api/generate" \
            -H "Content-Type: application/json" \
            -d "{\"model\":\"$model\",\"prompt\":\"$prompt\",\"stream\":false}" > /dev/null
        local end_time=$(date +%s.%N)
        
        local duration=$(echo "$end_time - $start_time" | bc)
        total_time=$(echo "$total_time + $duration" | bc)
        count=$((count + 1))
        
        echo "  响应时间: ${duration}s"
    done
    
    local avg_time=$(echo "scale=2; $total_time / $count" | bc)
    log_success "平均响应时间: ${avg_time}s"
}

# 安装推荐模型
install_recommended() {
    log_info "安装推荐模型..."
    
    local models=(
        "llama3.2:3b"
        "qwen2.5:7b"
    )
    
    for model in "${models[@]}"; do
        log_info "安装模型: $model"
        pull_model "$model"
    done
    
    log_success "推荐模型安装完成"
}

# 主函数
main() {
    case "${1:-help}" in
        "list")
            list_models
            ;;
        "pull")
            pull_model "$2"
            ;;
        "remove")
            remove_model "$2"
            ;;
        "status")
            check_status
            ;;
        "test")
            test_model "$2"
            ;;
        "benchmark")
            benchmark_model "$2"
            ;;
        "install-recommended")
            install_recommended
            ;;
        "help"|*)
            show_help
            ;;
    esac
}

main "$@"
EOF

    chmod +x "$AI_DIR/manage-models.sh"
    
    log_success "模型管理脚本创建完成"
}

# 启动 AI 服务
start_ai_services() {
    log_step "启动 AI 服务..."
    
    cd "$AI_DIR"
    
    # 启动服务
    docker-compose up -d
    
    # 等待服务启动
    log_info "等待 AI 服务启动..."
    sleep 30
    
    # 检查服务状态
    if curl -s "http://$NAS_IP:8888/health" > /dev/null; then
        log_success "AI 路由器启动成功"
    else
        log_warning "AI 路由器可能未完全启动"
    fi
    
    if curl -s "http://$NAS_IP:11434" > /dev/null; then
        log_success "Ollama 服务启动成功"
    else
        log_warning "Ollama 服务可能未完全启动"
    fi
}

# 主执行函数
main() {
    show_welcome
    
    # 检查权限
    if [[ $EUID -ne 0 ]]; then
        log_warning "建议使用 root 权限运行此脚本"
    fi
    
    # 执行优化步骤
    create_ai_structure
    create_load_balancer
    create_nginx_config
    create_prometheus_config
    create_model_manager
    start_ai_services
    
    # 显示完成信息
    echo ""
    log_success "🎉 YYC³ AI 模型优化完成！"
    echo ""
    log_highlight "📋 服务摘要:"
    echo "  🤖 AI 路由器: http://$NAS_IP:8888"
    echo "  🦙 Ollama 1: http://$NAS_IP:11434"
    echo "  🦙 Ollama 2: http://$NAS_IP:11435"
    echo "  📊 监控面板: http://$NAS_IP:9091"
    echo "  🗄️ Redis 缓存: $NAS_IP:6380"
    echo ""
    log_highlight "🚀 后续步骤:"
    echo "  1. 运行 '$AI_DIR/manage-models.sh install-recommended' 安装推荐模型"
    echo "  2. 运行 '$AI_DIR/manage-models.sh status' 检查服务状态"
    echo "  3. 运行 '$AI_DIR/manage-models.sh test llama3.2:3b' 测试模型"
    echo ""
    log_highlight "🔧 管理命令:"
    echo "  • 模型管理: $AI_DIR/manage-models.sh"
    echo "  • 服务状态: docker-compose -f $AI_DIR/docker-compose.yml ps"
    echo "  • 查看日志: docker-compose -f $AI_DIR/docker-compose.yml logs -f"
    echo ""
}

# 执行主函数
main "$@"