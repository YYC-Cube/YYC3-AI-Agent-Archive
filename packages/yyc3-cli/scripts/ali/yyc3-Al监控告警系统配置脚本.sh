#!/bin/bash

# YYC³ 监控告警系统配置脚本
# 配置 Prometheus + Grafana + AlertManager

set -e

ROOT_DIR="/Volume2/YYC"
MONITORING_DIR="/Volume2/YYC/monitoring"
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
    ██╗   ██╗██╗   ██╗ ██████╗██████╗     ███╗   ███╗ ██████╗ ███╗   ██╗
    ╚██╗ ██╔╝╚██╗ ██╔╝██╔════╝╚════██╗    ████╗ ████║██╔═══██╗████╗  ██║
     ╚████╔╝  ╚████╔╝ ██║      █████╔╝    ██╔████╔██║██║   ██║██╔██╗ ██║
      ╚██╔╝    ╚██╔╝  ██║      ╚═══██╗    ██║╚██╔╝██║██║   ██║██║╚██╗██║
       ██║      ██║   ╚██████╗██████╔╝    ██║ ╚═╝ ██║╚██████╔╝██║ ╚████║
       ╚═╝      ╚═╝    ╚═════╝╚═════╝     ╚═╝     ╚═╝ ╚═════╝ ╚═╝  ╚═══╝
                                                                         
    YYC³ 监控告警系统
    Monitoring & Alerts
    ===================
EOF
    echo -e "${NC}"
    echo ""
    echo "📊 配置 Prometheus + Grafana + AlertManager"
    echo "📅 配置时间: $(date)"
    echo "🌐 目标服务器: $NAS_IP"
    echo "📁 监控目录: $MONITORING_DIR"
    echo ""
}

# 创建监控目录结构
create_monitoring_structure() {
    log_step "创建监控目录结构..."
    
    mkdir -p "$MONITORING_DIR"/{prometheus,grafana,alertmanager,node-exporter}
    mkdir -p "$MONITORING_DIR/prometheus"/{data,config,rules}
    mkdir -p "$MONITORING_DIR/grafana"/{data,dashboards,provisioning}
    mkdir -p "$MONITORING_DIR/grafana/provisioning"/{dashboards,datasources,notifiers}
    mkdir -p "$MONITORING_DIR/alertmanager"/{data,config}
    
    # 设置权限
    chown -R 472:472 "$MONITORING_DIR/grafana"
    chown -R 65534:65534 "$MONITORING_DIR/prometheus"
    chown -R 65534:65534 "$MONITORING_DIR/alertmanager"
    
    log_success "目录结构创建完成"
}

# 创建监控服务 Docker Compose
create_monitoring_compose() {
    log_step "创建监控服务配置..."
    
    cat > "$MONITORING_DIR/docker-compose.yml" << 'EOF'
version: '3.8'

services:
  # Prometheus 监控服务
  prometheus:
    image: prom/prometheus:latest
    container_name: yc-prometheus
    restart: unless-stopped
    ports:
      - "9090:9090"
    Volumes:
      - /Volume2/YYC/monitoring/prometheus/config:/etc/prometheus
      - /Volume2/YYC/monitoring/prometheus/data:/prometheus
      - /Volume2/YYC/monitoring/prometheus/rules:/etc/prometheus/rules
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
      - '--storage.tsdb.path=/prometheus'
      - '--web.console.libraries=/etc/prometheus/console_libraries'
      - '--web.console.templates=/etc/prometheus/consoles'
      - '--web.enable-lifecycle'
      - '--web.enable-admin-api'
      - '--storage.tsdb.retention.time=30d'
    networks:
      - yyc3-network
    user: "65534:65534"

  # Grafana 可视化面板
  grafana:
    image: grafana/grafana:latest
    container_name: yc-grafana
    restart: unless-stopped
    ports:
      - "3000:3000"
    Volumes:
      - /Volume2/YYC/monitoring/grafana/data:/var/lib/grafana
      - /Volume2/YYC/monitoring/grafana/provisioning:/etc/grafana/provisioning
      - /Volume2/YYC/monitoring/grafana/dashboards:/var/lib/grafana/dashboards
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=yyc3admin
      - GF_USERS_ALLOW_SIGN_UP=false
      - GF_SERVER_DOMAIN=192.168.3.45
      - GF_SMTP_ENABLED=true
      - GF_SMTP_HOST=0379.email:587
      - GF_SMTP_USER=admin@0379.email
      - GF_SMTP_PASSWORD=your-email-password
      - GF_SMTP_FROM_ADDRESS=admin@0379.email
      - GF_INSTALL_PLUGINS=grafana-clock-panel,grafana-simple-json-datasource
    networks:
      - yyc3-network
    depends_on:
      - prometheus

  # AlertManager 告警管理
  alertmanager:
    image: prom/alertmanager:latest
    container_name: yc-alertmanager
    restart: unless-stopped
    ports:
      - "9093:9093"
    Volumes:
      - /Volume2/YYC/monitoring/alertmanager/config:/etc/alertmanager
      - /Volume2/YYC/monitoring/alertmanager/data:/alertmanager
    command:
      - '--config.file=/etc/alertmanager/alertmanager.yml'
      - '--storage.path=/alertmanager'
      - '--web.external-url=http://192.168.3.45:9093'
    networks:
      - yyc3-network
    user: "65534:65534"

  # Node Exporter 系统监控
  node-exporter:
    image: prom/node-exporter:latest
    container_name: yc-node-exporter
    restart: unless-stopped
    ports:
      - "9100:9100"
    Volumes:
      - /proc:/host/proc:ro
      - /sys:/host/sys:ro
      - /:/rootfs:ro
    command:
      - '--path.procfs=/host/proc'
      - '--path.rootfs=/rootfs'
      - '--path.sysfs=/host/sys'
      - '--collector.filesystem.mount-points-exclude=^/(sys|proc|dev|host|etc)($$|/)'
    networks:
      - yyc3-network

  # cAdvisor 容器监控
  cadvisor:
    image: gcr.io/cadvisor/cadvisor:latest
    container_name: yc-cadvisor
    restart: unless-stopped
    ports:
      - "8080:8080"
    Volumes:
      - /:/rootfs:ro
      - /var/run:/var/run:ro
      - /sys:/sys:ro
      - /var/lib/docker/:/var/lib/docker:ro
      - /dev/disk/:/dev/disk:ro
    privileged: true
    devices:
      - /dev/kmsg
    networks:
      - yyc3-network

networks:
  yyc3-network:
    external: true
EOF

    log_success "监控服务配置创建完成"
}

# 创建 Prometheus 配置
create_prometheus_config() {
    log_step "创建 Prometheus 配置..."
    
    cat > "$MONITORING_DIR/prometheus/config/prometheus.yml" << 'EOF'
global:
  scrape_interval: 15s
  evaluation_interval: 15s
  external_labels:
    cluster: 'yyc3-cluster'
    replica: 'prometheus-1'

rule_files:
  - "rules/*.yml"

alerting:
  alertmanagers:
    - static_configs:
        - targets:
          - alertmanager:9093

scrape_configs:
  # Prometheus 自身监控
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']

  # 系统监控
  - job_name: 'node-exporter'
    static_configs:
      - targets: ['node-exporter:9100']
    scrape_interval: 10s

  # 容器监控
  - job_name: 'cadvisor'
    static_configs:
      - targets: ['cadvisor:8080']
    scrape_interval: 10s

  # Docker 守护进程监控
  - job_name: 'docker'
    static_configs:
      - targets: ['192.168.3.45:9323']
    scrape_interval: 30s

  # YYC³ 应用监控
  - job_name: 'yyc3-apps'
    static_configs:
      - targets: 
        - '192.168.3.45:3001'  # 管理面板
        - '192.168.3.45:4873'  # NPM 仓库
        - '192.168.3.45:8080'  # GitLab
    metrics_path: /metrics
    scrape_interval: 30s

  # AI 服务监控
  - job_name: 'ai-services'
    static_configs:
      - targets:
        - '192.168.3.45:11434'  # Ollama 1
        - '192.168.3.45:11435'  # Ollama 2
        - '192.168.3.45:8888'   # AI Router
    scrape_interval: 30s

  # 数据库监控
  - job_name: 'databases'
    static_configs:
      - targets:
        - '192.168.3.45:6379'   # Redis
        - '192.168.3.45:5432'   # PostgreSQL
    scrape_interval: 30s

  # 网络设备监控
  - job_name: 'network'
    static_configs:
      - targets:
        - '192.168.0.1:161'    # 路由器 SNMP
    scrape_interval: 60s

  # 黑盒监控 - HTTP 端点
  - job_name: 'blackbox-http'
    metrics_path: /probe
    params:
      module: [http_2xx]
    static_configs:
      - targets:
        - http://192.168.3.45:3001    # 管理面板
        - http://192.168.3.45:4873    # NPM 仓库
        - http://192.168.3.45:8080    # GitLab
        - http://192.168.3.45:8888    # AI Router
    relabel_configs:
      - source_labels: [__address__]
        target_label: __param_target
      - source_labels: [__param_target]
        target_label: instance
      - target_label: __address__
        replacement: blackbox-exporter:9115

  # 自定义业务指标
  - job_name: 'yyc3-business'
    static_configs:
      - targets: ['192.168.3.45:9999']
    metrics_path: /business-metrics
    scrape_interval: 60s
EOF

    log_success "Prometheus 配置创建完成"
}

# 创建告警规则
create_alert_rules() {
    log_step "创建告警规则..."
    
    # 系统告警规则
    cat > "$MONITORING_DIR/prometheus/rules/system_alerts.yml" << 'EOF'
groups:
  - name: system_alerts
    rules:
      # CPU 使用率告警
      - alert: HighCPUUsage
        expr: 100 - (avg by(instance) (irate(node_cpu_seconds_total{mode="idle"}[5m])) * 100) > 80
        for: 5m
        labels:
          severity: warning
          service: system
        annotations:
          summary: "服务器 CPU 使用率过高"
          description: "服务器 {{ $labels.instance }} CPU 使用率超过 80%，当前值: {{ $value }}%"

      # 内存使用率告警
      - alert: HighMemoryUsage
        expr: (1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)) * 100 > 85
        for: 5m
        labels:
          severity: warning
          service: system
        annotations:
          summary: "服务器内存使用率过高"
          description: "服务器 {{ $labels.instance }} 内存使用率超过 85%，当前值: {{ $value }}%"

      # 磁盘使用率告警
      - alert: HighDiskUsage
        expr: (1 - (node_filesystem_avail_bytes{fstype!="tmpfs"} / node_filesystem_size_bytes{fstype!="tmpfs"})) * 100 > 90
        for: 5m
        labels:
          severity: critical
          service: system
        annotations:
          summary: "磁盘空间不足"
          description: "服务器 {{ $labels.instance }} 磁盘 {{ $labels.mountpoint }} 使用率超过 90%，当前值: {{ $value }}%"

      # 磁盘 I/O 告警
      - alert: HighDiskIO
        expr: irate(node_disk_io_time_seconds_total[5m]) * 100 > 80
        for: 10m
        labels:
          severity: warning
          service: system
        annotations:
          summary: "磁盘 I/O 使用率过高"
          description: "服务器 {{ $labels.instance }} 磁盘 I/O 使用率超过 80%"

      # 网络流量告警
      - alert: HighNetworkTraffic
        expr: irate(node_network_receive_bytes_total[5m]) * 8 / 1024 / 1024 > 100
        for: 5m
        labels:
          severity: warning
          service: network
        annotations:
          summary: "网络流量过高"
          description: "服务器 {{ $labels.instance }} 网络接收流量超过 100Mbps"

      # 系统负载告警
      - alert: HighSystemLoad
        expr: node_load15 / count(node_cpu_seconds_total{mode="idle"}) by (instance) > 2
        for: 10m
        labels:
          severity: warning
          service: system
        annotations:
          summary: "系统负载过高"
          description: "服务器 {{ $labels.instance }} 15分钟平均负载超过 CPU 核心数的 2 倍"
EOF

    # 应用服务告警规则
    cat > "$MONITORING_DIR/prometheus/rules/service_alerts.yml" << 'EOF'
groups:
  - name: service_alerts
    rules:
      # 服务不可用告警
      - alert: ServiceDown
        expr: up == 0
        for: 1m
        labels:
          severity: critical
          service: "{{ $labels.job }}"
        annotations:
          summary: "服务不可用"
          description: "服务 {{ $labels.job }} 在实例 {{ $labels.instance }} 上不可用"

      # HTTP 响应时间告警
      - alert: HighHTTPResponseTime
        expr: probe_http_duration_seconds > 5
        for: 2m
        labels:
          severity: warning
          service: http
        annotations:
          summary: "HTTP 响应时间过长"
          description: "HTTP 端点 {{ $labels.instance }} 响应时间超过 5 秒"

      # HTTP 状态码告警
      - alert: HTTPStatusError
        expr: probe_http_status_code >= 400
        for: 1m
        labels:
          severity: critical
          service: http
        annotations:
          summary: "HTTP 状态码异常"
          description: "HTTP 端点 {{ $labels.instance }} 返回状态码 {{ $value }}"

      # 容器重启告警
      - alert: ContainerRestarted
        expr: increase(container_start_time_seconds[1h]) > 0
        for: 0m
        labels:
          severity: warning
          service: docker
        annotations:
          summary: "容器重启"
          description: "容器 {{ $labels.name }} 在过去 1 小时内重启了 {{ $value }} 次"

      # 容器内存使用率告警
      - alert: ContainerHighMemoryUsage
        expr: (container_memory_usage_bytes / container_spec_memory_limit_bytes) * 100 > 90
        for: 5m
        labels:
          severity: warning
          service: docker
        annotations:
          summary: "容器内存使用率过高"
          description: "容器 {{ $labels.name }} 内存使用率超过 90%，当前值: {{ $value }}%"

      # 容器 CPU 使用率告警
      - alert: ContainerHighCPUUsage
        expr: (rate(container_cpu_usage_seconds_total[5m]) * 100) > 80
        for: 5m
        labels:
          severity: warning
          service: docker
        annotations:
          summary: "容器 CPU 使用率过高"
          description: "容器 {{ $labels.name }} CPU 使用率超过 80%，当前值: {{ $value }}%"
EOF

    # YYC³ 业务告警规则
    cat > "$MONITORING_DIR/prometheus/rules/yyc3_alerts.yml" << 'EOF'
groups:
  - name: yyc3_alerts
    rules:
      # NPM 仓库告警
      - alert: NPMRegistryDown
        expr: up{job="yyc3-apps", instance="192.168.3.45:4873"} == 0
        for: 1m
        labels:
          severity: critical
          service: npm-registry
        annotations:
          summary: "NPM 私有仓库不可用"
          description: "YYC³ NPM 私有仓库服务不可用，影响包管理功能"

      # GitLab 服务告警
      - alert: GitLabDown
        expr: up{job="yyc3-apps", instance="192.168.3.45:8080"} == 0
        for: 2m
        labels:
          severity: critical
          service: gitlab
        annotations:
          summary: "GitLab 服务不可用"
          description: "YYC³ GitLab 服务不可用，影响代码管理和 CI/CD 功能"

      # AI 服务告警
      - alert: AIServiceDown
        expr: up{job="ai-services"} == 0
        for: 1m
        labels:
          severity: warning
          service: ai
        annotations:
          summary: "AI 服务不可用"
          description: "AI 服务 {{ $labels.instance }} 不可用，影响智能功能"

      # 管理面板告警
      - alert: DashboardDown
        expr: up{job="yyc3-apps", instance="192.168.3.45:3001"} == 0
        for: 1m
        labels:
          severity: warning
          service: dashboard
        annotations:
          summary: "管理面板不可用"
          description: "YYC³ 管理面板不可用，影响系统管理功能"

      # 包下载量异常告警
      - alert: UnusualPackageDownloads
        expr: rate(npm_package_downloads_total[1h]) > 1000
        for: 5m
        labels:
          severity: warning
          service: npm-registry
        annotations:
          summary: "包下载量异常"
          description: "NPM 包下载量异常增长，每小时超过 1000 次"

      # 用户登录异常告警
      - alert: UnusualLoginActivity
        expr: rate(user_login_attempts_total[5m]) > 10
        for: 2m
        labels:
          severity: warning
          service: auth
        annotations:
          summary: "用户登录异常"
          description: "用户登录尝试频率异常，5分钟内超过 10 次"
EOF

    log_success "告警规则创建完成"
}

# 创建 AlertManager 配置
create_alertmanager_config() {
    log_step "创建 AlertManager 配置..."
    
    cat > "$MONITORING_DIR/alertmanager/config/alertmanager.yml" << 'EOF'
global:
  smtp_smarthost: 'smtp.qq.com:587'
  smtp_from: 'admin@0379.email'
  smtp_auth_username: 'admin@0379.email'
  smtp_auth_password: 'your-email-password'
  wechat_api_url: 'https://qyapi.weixin.qq.com/cgi-bin/'

# 告警路由配置
route:
  group_by: ['alertname', 'cluster', 'service']
  group_wait: 10s
  group_interval: 10s
  repeat_interval: 1h
  receiver: 'default'
  routes:
    # 严重告警立即通知
    - match:
        severity: critical
      receiver: 'critical-alerts'
      group_wait: 0s
      repeat_interval: 5m
    
    # 系统告警
    - match:
        service: system
      receiver: 'system-alerts'
    
    # YYC³ 业务告警
    - match_re:
        service: (npm-registry|gitlab|dashboard)
      receiver: 'yyc3-alerts'
    
    # AI 服务告警
    - match:
        service: ai
      receiver: 'ai-alerts'

# 告警接收器配置
receivers:
  # 默认接收器
  - name: 'default'
    email_configs:
      - to: 'admin@china.0379.pro'
        subject: 'YYC³ 告警通知'
        body: |
          告警详情:
          - 告警名称: {{ .GroupLabels.alertname }}
          - 告警级别: {{ .GroupLabels.severity }}
          - 告警时间: {{ .CommonAnnotations.summary }}
          - 详细描述: {{ .CommonAnnotations.description }}

  # 严重告警接收器
  - name: 'critical-alerts'
    email_configs:
      - to: 'admin@china.0379.pro'
        subject: '🚨 YYC³ 严重告警'
        body: |
          ⚠️ 严重告警通知
          
          告警名称: {{ .GroupLabels.alertname }}
          告警级别: {{ .GroupLabels.severity }}
          服务名称: {{ .GroupLabels.service }}
          告警时间: {{ .CommonAnnotations.summary }}
          详细描述: {{ .CommonAnnotations.description }}
          
          请立即处理！
    
    webhook_configs:
      - url: '${WECHAT_WEBHOOK_URL}'
        send_resolved: true
        http_config:
          proxy_url: ''
        title: 'YYC³ 严重告警'
        text: |
          🚨 严重告警
          服务: {{ .GroupLabels.service }}
          描述: {{ .CommonAnnotations.description }}
          时间: {{ .CommonAnnotations.summary }}

  # 系统告警接收器
  - name: 'system-alerts'
    email_configs:
      - to: 'ops@china.0379.pro'
        subject: '📊 YYC³ 系统告警'
        body: |
          系统监控告警
          
          告警名称: {{ .GroupLabels.alertname }}
          服务器: {{ .GroupLabels.instance }}
          告警描述: {{ .CommonAnnotations.description }}

  # YYC³ 业务告警接收器
  - name: 'yyc3-alerts'
    email_configs:
      - to: 'dev@china.0379.pro'
        subject: '🔧 YYC³ 业务告警'
        body: |
          YYC³ 业务服务告警
          
          服务名称: {{ .GroupLabels.service }}
          告警描述: {{ .CommonAnnotations.description }}
          影响范围: {{ .CommonAnnotations.summary }}
    
    webhook_configs:
      - url: '${WECHAT_WEBHOOK_URL}'
        send_resolved: true
        title: 'YYC³ 业务告警'
        text: |
          🔧 业务告警
          服务: {{ .GroupLabels.service }}
          描述: {{ .CommonAnnotations.description }}

  # AI 服务告警接收器
  - name: 'ai-alerts'
    email_configs:
      - to: 'ai-team@china.0379.pro'
        subject: '🤖 YYC³ AI 服务告警'
        body: |
          AI 服务监控告警
          
          服务实例: {{ .GroupLabels.instance }}
          告警描述: {{ .CommonAnnotations.description }}

# 告警抑制规则
inhibit_rules:
  # 当服务器宕机时，抑制该服务器上的其他告警
  - source_match:
      alertname: 'ServiceDown'
    target_match:
      instance: '{{ .Labels.instance }}'
    equal: ['instance']
  
  # 当磁盘空间严重不足时，抑制磁盘使用率告警
  - source_match:
      severity: 'critical'
      alertname: 'HighDiskUsage'
    target_match:
      severity: 'warning'
      alertname: 'HighDiskUsage'
    equal: ['instance', 'mountpoint']

# 告警模板
templates:
  - '/etc/alertmanager/templates/*.tmpl'
EOF

    log_success "AlertManager 配置创建完成"
}

# 创建 Grafana 数据源配置
create_grafana_datasources() {
    log_step "创建 Grafana 数据源配置..."
    
    cat > "$MONITORING_DIR/grafana/provisioning/datasources/prometheus.yml" << 'EOF'
apiVersion: 1

datasources:
  - name: Prometheus
    type: prometheus
    access: proxy
    url: http://prometheus:9090
    isDefault: true
    editable: true
    jsonData:
      timeInterval: "15s"
      queryTimeout: "60s"
      httpMethod: "POST"
    secureJsonData: {}

  - name: AlertManager
    type: alertmanager
    access: proxy
    url: http://alertmanager:9093
    editable: true
    jsonData:
      implementation: "prometheus"
EOF

    log_success "Grafana 数据源配置创建完成"
}

# 创建 Grafana 仪表板配置
create_grafana_dashboards() {
    log_step "创建 Grafana 仪表板配置..."
    
    cat > "$MONITORING_DIR/grafana/provisioning/dashboards/dashboards.yml" << 'EOF'
apiVersion: 1

providers:
  - name: 'YYC³ Dashboards'
    orgId: 1
    folder: 'YYC³'
    type: file
    disableDeletion: false
    updateIntervalSeconds: 10
    allowUiUpdates: true
    options:
      path: /var/lib/grafana/dashboards
EOF

    # 创建系统监控仪表板
    cat > "$MONITORING_DIR/grafana/dashboards/system-overview.json" << 'EOF'
{
  "dashboard": {
    "id": null,
    "title": "YYC³ 系统概览",
    "tags": ["yyc3", "system"],
    "timezone": "Asia/Shanghai",
    "panels": [
      {
        "id": 1,
        "title": "CPU 使用率",
        "type": "stat",
        "targets": [
          {
            "expr": "100 - (avg by(instance) (irate(node_cpu_seconds_total{mode=\"idle\"}[5m])) * 100)",
            "legendFormat": "{{ instance }}"
          }
        ],
        "fieldConfig": {
          "defaults": {
            "unit": "percent",
            "thresholds": {
              "steps": [
                {"color": "green", "value": null},
                {"color": "yellow", "value": 70},
                {"color": "red", "value": 90}
              ]
            }
          }
        },
        "gridPos": {"h": 8, "w": 6, "x": 0, "y": 0}
      },
      {
        "id": 2,
        "title": "内存使用率",
        "type": "stat",
        "targets": [
          {
            "expr": "(1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)) * 100",
            "legendFormat": "{{ instance }}"
          }
        ],
        "fieldConfig": {
          "defaults": {
            "unit": "percent",
            "thresholds": {
              "steps": [
                {"color": "green", "value": null},
                {"color": "yellow", "value": 80},
                {"color": "red", "value": 95}
              ]
            }
          }
        },
        "gridPos": {"h": 8, "w": 6, "x": 6, "y": 0}
      },
      {
        "id": 3,
        "title": "磁盘使用率",
        "type": "stat",
        "targets": [
          {
            "expr": "(1 - (node_filesystem_avail_bytes{fstype!=\"tmpfs\"} / node_filesystem_size_bytes{fstype!=\"tmpfs\"})) * 100",
            "legendFormat": "{{ mountpoint }}"
          }
        ],
        "fieldConfig": {
          "defaults": {
            "unit": "percent",
            "thresholds": {
              "steps": [
                {"color": "green", "value": null},
                {"color": "yellow", "value": 80},
                {"color": "red", "value": 95}
              ]
            }
          }
        },
        "gridPos": {"h": 8, "w": 6, "x": 12, "y": 0}
      },
      {
        "id": 4,
        "title": "网络流量",
        "type": "timeseries",
        "targets": [
          {
            "expr": "irate(node_network_receive_bytes_total[5m]) * 8",
            "legendFormat": "接收 - {{ device }}"
          },
          {
            "expr": "irate(node_network_transmit_bytes_total[5m]) * 8",
            "legendFormat": "发送 - {{ device }}"
          }
        ],
        "fieldConfig": {
          "defaults": {
            "unit": "bps"
          }
        },
        "gridPos": {"h": 8, "w": 6, "x": 18, "y": 0}
      }
    ],
    "time": {
      "from": "now-1h",
      "to": "now"
    },
    "refresh": "30s"
  }
}
EOF

    log_success "Grafana 仪表板配置创建完成"
}

# 启动监控服务
start_monitoring_services() {
    log_step "启动监控服务..."
    
    cd "$MONITORING_DIR"
    
    # 启动服务
    docker-compose up -d
    
    # 等待服务启动
    log_info "等待监控服务启动..."
    sleep 30
    
    # 检查服务状态
    services=("prometheus:9090" "grafana:3000" "alertmanager:9093")
    
    for service in "${services[@]}"; do
        name=$(echo $service | cut -d: -f1)
        port=$(echo $service | cut -d: -f2)
        
        if curl -s "http://$NAS_IP:$port" > /dev/null; then
            log_success "$name 服务启动成功"
        else
            log_warning "$name 服务可能未完全启动"
        fi
    done
}

# 创建监控管理脚本
create_monitoring_manager() {
    log_step "创建监控管理脚本..."
    
    cat > "$MONITORING_DIR/manage-monitoring.sh" << 'EOF'
#!/bin/bash

# YYC³ 监控管理脚本

set -e

MONITORING_DIR="/Volume2/YYC/monitoring"
NAS_IP="1192.168.3.45
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
    echo "YYC³ 监控管理工具"
    echo ""
    echo "用法: $0 [命令]"
    echo ""
    echo "命令:"
    echo "  status          查看服务状态"
    echo "  start           启动所有服务"
    echo "  stop            停止所有服务"
    echo "  restart         重启所有服务"
    echo "  logs [service]  查看服务日志"
    echo "  reload          重载配置"
    echo "  backup          备份配置"
    echo "  test-alerts     测试告警"
    echo ""
    echo "示例:"
    echo "  $0 status"
    echo "  $0 logs prometheus"
    echo "  $0 test-alerts"
    echo ""
}

# 查看服务状态
check_status() {
    log_info "检查监控服务状态..."
    
    cd "$MONITORING_DIR"
    docker-compose ps
    
    echo ""
    echo "服务访问地址:"
    echo "  📊 Prometheus: http://$NAS_IP:9090"
    echo "  📈 Grafana: http://$NAS_IP:3000 (admin/yyc3admin)"
    echo "  🚨 AlertManager: http://$NAS_IP:9093"
    echo "  📋 Node Exporter: http://$NAS_IP:9100"
    echo "  🐳 cAdvisor: http://$NAS_IP:8080"
}

# 启动服务
start_services() {
    log_info "启动监控服务..."
    cd "$MONITORING_DIR"
    docker-compose up -d
    log_success "监控服务启动完成"
}

# 停止服务
stop_services() {
    log_info "停止监控服务..."
    cd "$MONITORING_DIR"
    docker-compose down
    log_success "监控服务停止完成"
}

# 重启服务
restart_services() {
    log_info "重启监控服务..."
    cd "$MONITORING_DIR"
    docker-compose restart
    log_success "监控服务重启完成"
}

# 查看日志
view_logs() {
    local service="$1"
    cd "$MONITORING_DIR"
    
    if [ -z "$service" ]; then
        docker-compose logs -f
    else
        docker-compose logs -f "$service"
    fi
}

# 重载配置
reload_config() {
    log_info "重载监控配置..."
    
    # 重载 Prometheus 配置
    curl -X POST "http://$NAS_IP:9090/-/reload" || log_warning "Prometheus 配置重载失败"
    
    # 重载 AlertManager 配置
    curl -X POST "http://$NAS_IP:9093/-/reload" || log_warning "AlertManager 配置重载失败"
    
    log_success "配置重载完成"
}

# 备份配置
backup_config() {
    log_info "备份监控配置..."
    
    local backup_dir="/Volume2/YYC/backups/monitoring-$(date +%Y%m%d-%H%M%S)"
    mkdir -p "$backup_dir"
    
    # 备份配置文件
    cp -r "$MONITORING_DIR/prometheus/config" "$backup_dir/prometheus-config"
    cp -r "$MONITORING_DIR/alertmanager/config" "$backup_dir/alertmanager-config"
    cp -r "$MONITORING_DIR/grafana/provisioning" "$backup_dir/grafana-provisioning"
    
    # 备份 Grafana 数据
    docker exec yc-grafana grafana-cli admin export-dashboard > "$backup_dir/grafana-dashboards.json"
    
    log_success "配置备份完成: $backup_dir"
}

# 测试告警
test_alerts() {
    log_info "测试告警系统..."
    
    # 发送测试告警
    curl -X POST "http://$NAS_IP:9093/api/v1/alerts" \
        -H "Content-Type: application/json" \
        -d '[
            {
                "labels": {
                    "alertname": "TestAlert",
                    "severity": "warning",
                    "service": "test"
                },
                "annotations": {
                    "summary": "这是一个测试告警",
                    "description": "用于测试 YYC³ 监控告警系统是否正常工作"
                },
                "startsAt": "'$(date -u +%Y-%m-%dT%H:%M:%S.%3NZ)'",
                "endsAt": "'$(date -u -d '+5 minutes' +%Y-%m-%dT%H:%M:%S.%3NZ)'"
            }
        ]'
    
    log_success "测试告警已发送"
}

# 主函数
main() {
    case "${1:-help}" in
        "status")
            check_status
            ;;
        "start")
            start_services
            ;;
        "stop")
            stop_services
            ;;
        "restart")
            restart_services
            ;;
        "logs")
            view_logs "$2"
            ;;
        "reload")
            reload_config
            ;;
        "backup")
            backup_config
            ;;
        "test-alerts")
            test_alerts
            ;;
        "help"|*)
            show_help
            ;;
    esac
}

main "$@"
EOF

    chmod +x "$MONITORING_DIR/manage-monitoring.sh"
    
    log_success "监控管理脚本创建完成"
}

# 主执行函数
main() {
    show_welcome
    
    # 检查权限
    if [[ $EUID -ne 0 ]]; then
        log_warning "建议使用 root 权限运行此脚本"
    fi
    
    # 执行配置步骤
    create_monitoring_structure
    create_monitoring_compose
    create_prometheus_config
    create_alert_rules
    create_alertmanager_config
    create_grafana_datasources
    create_grafana_dashboards
    start_monitoring_services
    create_monitoring_manager
    
    # 显示完成信息
    echo ""
    log_success "🎉 YYC³ 监控告警系统配置完成！"
    echo ""
    log_highlight "📋 服务摘要:"
    echo "  📊 Prometheus: http://$NAS_IP:9090"
    echo "  📈 Grafana: http://$NAS_IP:3000 (admin/yyc3admin)"
    echo "  🚨 AlertManager: http://$NAS_IP:9093"
    echo "  📋 Node Exporter: http://$NAS_IP:9100"
    echo "  🐳 cAdvisor: http://$NAS_IP:8080"
    echo ""
    log_highlight "🚀 后续步骤:"
    echo "  1. 访问 Grafana 配置仪表板和告警"
    echo "  2. 配置邮件和微信通知"
    echo "  3. 运行 '$MONITORING_DIR/manage-monitoring.sh test-alerts' 测试告警"
    echo "  4. 根据需要调整告警阈值"
    echo ""
    log_highlight "🔧 管理命令:"
    echo "  • 监控管理: $MONITORING_DIR/manage-monitoring.sh"
    echo "  • 查看状态: $MONITORING_DIR/manage-monitoring.sh status"
    echo "  • 查看日志: $MONITORING_DIR/manage-monitoring.sh logs"
    echo ""
}

# 执行主函数
main "$@"