#!/bin/bash

# YYC³ 邮箱服务器设置脚本
# 完整的邮件服务器部署和配置

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# 日志函数
log_info() { echo -e "${BLUE}[信息]${NC} $1"; }
log_success() { echo -e "${GREEN}[成功]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[警告]${NC} $1"; }
log_error() { echo -e "${RED}[错误]${NC} $1"; }
log_step() { echo -e "${PURPLE}[步骤]${NC} $1"; }

# 全局变量
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
EMAIL_DIR="$ROOT_DIR/services/email"
LOG_FILE="$ROOT_DIR/logs/email-setup-$(date +%Y%m%d-%H%M%S).log"

# 创建必要目录
mkdir -p "$EMAIL_DIR"/{config,data,logs}
mkdir -p "$ROOT_DIR/logs"

# 显示欢迎信息
show_welcome() {
    clear
    echo -e "${CYAN}"
    cat << 'EOF'
    ██╗   ██╗██╗   ██╗ ██████╗██████╗     ███████╗███╗   ███╗ █████╗ ██╗██╗     
    ╚██╗ ██╔╝╚██╗ ██╔╝██╔════╝╚════██╗    ██╔════╝████╗ ████║██╔══██╗██║██║     
     ╚████╔╝  ╚████╔╝ ██║      █████╔╝    █████╗  ██╔████╔██║███████║██║██║     
      ╚██╔╝    ╚██╔╝  ██║      ╚═══██╗    ██╔══╝  ██║╚██╔╝██║██╔══██║██║██║     
       ██║      ██║   ╚██████╗██████╔╝    ███████╗██║ ╚═╝ ██║██║  ██║██║███████╗
       ╚═╝      ╚═╝    ╚═════╝╚═════╝     ╚══════╝╚═╝     ╚═╝╚═╝  ╚═╝╚═╝╚══════╝
                                                                                  
    邮箱服务器设置
    Email Server Setup
    ==================
EOF
    echo -e "${NC}"
    echo ""
    echo "🚀 欢迎使用 YYC³ 邮箱服务器设置工具！"
    echo "📅 设置时间: $(date)"
    echo "📁 项目目录: $ROOT_DIR"
    echo "📝 日志文件: $LOG_FILE"
    echo ""
}

# 检查环境变量
check_environment() {
    log_step "检查环境变量配置..."
    
    # 加载环境变量
    if [[ -f "$ROOT_DIR/.env" ]]; then
        source "$ROOT_DIR/.env"
    else
        log_error "未找到 .env 文件，请先运行环境变量生成脚本"
        exit 1
    fi
    
    # 检查必需的环境变量
    local required_vars=(
        "DOMAIN"
        "SERVER_IP"
        "SMTP_HOST"
        "SMTP_PORT"
        "SMTP_USER"
        "SMTP_PASSWORD"
        "ADMIN_EMAIL"
    )
    
    local missing_vars=()
    for var in "${required_vars[@]}"; do
        if [[ -z "${!var}" ]]; then
            missing_vars+=("$var")
        fi
    done
    
    if [[ ${#missing_vars[@]} -gt 0 ]]; then
        log_error "缺少以下环境变量:"
        for var in "${missing_vars[@]}"; do
            echo "  - $var"
        done
        
        log_info "正在交互式配置缺少的环境变量..."
        configure_missing_vars "${missing_vars[@]}"
    fi
    
    log_success "环境变量检查完成"
}

# 配置缺少的环境变量
configure_missing_vars() {
    local vars=("$@")
    
    for var in "${vars[@]}"; do
        case $var in
            "DOMAIN")
                read -p "请输入域名 (例: china@0379.pro): " domain_input
                echo "DOMAIN=${domain_input:-china@0379.pro}" >> "$ROOT_DIR/.env"
                ;;
            "SERVER_IP")
                read -p "请输入服务器IP (例: 192.168.3.9): " ip_input
                echo "SERVER_IP=${ip_input:-192.168.3.9}" >> "$ROOT_DIR/.env"
                ;;
            "SMTP_HOST")
                read -p "请输入SMTP服务器 (例: smtp.qq.com): " smtp_host
                echo "SMTP_HOST=${smtp_host:-smtp.qq.com}" >> "$ROOT_DIR/.env"
                ;;
            "SMTP_PORT")
                read -p "请输入SMTP端口 (例: 587): " smtp_port
                echo "SMTP_PORT=${smtp_port:-587}" >> "$ROOT_DIR/.env"
                ;;
            "SMTP_USER")
                read -p "请输入SMTP用户名: " smtp_user
                echo "SMTP_USER=$smtp_user" >> "$ROOT_DIR/.env"
                ;;
            "SMTP_PASSWORD")
                read -s -p "请输入SMTP密码: " smtp_pass
                echo ""
                echo "SMTP_PASSWORD=$smtp_pass" >> "$ROOT_DIR/.env"
                ;;
            "ADMIN_EMAIL")
                read -p "请输入管理员邮箱: " admin_email
                echo "ADMIN_EMAIL=$admin_email" >> "$ROOT_DIR/.env"
                ;;
        esac
    done
    
    # 重新加载环境变量
    source "$ROOT_DIR/.env"
}

# 创建邮箱服务器配置
create_email_config() {
    log_step "创建邮箱服务器配置..."
    
    # 创建 Postfix 主配置文件
    cat > "$EMAIL_DIR/config/main.cf" << EOF
# YYC³ Postfix 主配置文件
# 基础配置
myhostname = mail.${DOMAIN}
mydomain = ${DOMAIN}
myorigin = \$mydomain
inet_interfaces = all
inet_protocols = ipv4
mydestination = \$myhostname, localhost.\$mydomain, localhost, \$mydomain

# 网络配置
mynetworks = 127.0.0.0/8, ${SERVER_IP}/32, 192.168.0.0/16, 10.0.0.0/8

# 邮箱存储
home_mailbox = Maildir/
mailbox_command = 

# SMTP 认证
smtpd_sasl_auth_enable = yes
smtpd_sasl_type = dovecot
smtpd_sasl_path = private/auth
smtpd_sasl_security_options = noanonymous
smtpd_sasl_local_domain = \$myhostname
broken_sasl_auth_clients = yes

# TLS 配置
smtpd_use_tls = yes
smtpd_tls_cert_file = /etc/ssl/certs/mail.${DOMAIN}.crt
smtpd_tls_key_file = /etc/ssl/private/mail.${DOMAIN}.key
smtpd_tls_security_level = may
smtpd_tls_auth_only = yes
smtpd_tls_loglevel = 1
smtpd_tls_received_header = yes
smtpd_tls_session_cache_timeout = 3600s
tls_random_source = dev:/dev/urandom

# 客户端 TLS
smtp_use_tls = yes
smtp_tls_security_level = may
smtp_tls_note_starttls_offer = yes

# 限制配置
smtpd_recipient_restrictions = 
    permit_mynetworks,
    permit_sasl_authenticated,
    reject_unauth_destination,
    reject_rbl_client zen.spamhaus.org,
    reject_rbl_client bl.spamcop.net,
    permit

smtpd_sender_restrictions = 
    permit_mynetworks,
    permit_sasl_authenticated,
    reject_unknown_sender_domain,
    permit

# 邮件大小限制
message_size_limit = 52428800
mailbox_size_limit = 1073741824

# 队列配置
maximal_queue_lifetime = 7d
bounce_queue_lifetime = 7d
maximal_backoff_time = 4000s
minimal_backoff_time = 300s
queue_run_delay = 300s

# 虚拟域配置
virtual_alias_domains = 
virtual_alias_maps = hash:/etc/postfix/virtual
virtual_mailbox_domains = ${DOMAIN}
virtual_mailbox_maps = hash:/etc/postfix/vmailbox
virtual_mailbox_base = /var/mail/vhosts
virtual_uid_maps = static:5000
virtual_gid_maps = static:5000

# 日志配置
syslog_facility = mail
syslog_name = postfix
EOF

    # 创建 Dovecot 配置
    cat > "$EMAIL_DIR/config/dovecot.conf" << EOF
# YYC³ Dovecot 配置文件

# 协议配置
protocols = imap pop3 lmtp

# 监听配置
listen = *, ::

# 基础配置
base_dir = /var/run/dovecot/
instance_name = dovecot

# 登录配置
login_greeting = YYC³ Mail Server Ready

# 邮箱位置
mail_location = maildir:/var/mail/vhosts/%d/%n
mail_privileged_group = mail

# 用户数据库
userdb {
  driver = passwd-file
  args = username_format=%u /etc/dovecot/users
}

# 密码数据库
passdb {
  driver = passwd-file
  args = username_format=%u /etc/dovecot/users
}

# SSL 配置
ssl = required
ssl_cert = </etc/ssl/certs/mail.${DOMAIN}.crt
ssl_key = </etc/ssl/private/mail.${DOMAIN}.key
ssl_protocols = !SSLv2 !SSLv3

# 服务配置
service imap-login {
  inet_listener imap {
    port = 143
  }
  inet_listener imaps {
    port = 993
    ssl = yes
  }
}

service pop3-login {
  inet_listener pop3 {
    port = 110
  }
  inet_listener pop3s {
    port = 995
    ssl = yes
  }
}

service lmtp {
  unix_listener /var/spool/postfix/private/dovecot-lmtp {
    group = postfix
    mode = 0600
    user = postfix
  }
}

service auth {
  unix_listener /var/spool/postfix/private/auth {
    group = postfix
    mode = 0666
    user = postfix
  }
  unix_listener auth-userdb {
    group = mail
    mode = 0600
    user = vmail
  }
}

service auth-worker {
  user = vmail
}

# 邮箱配置
namespace inbox {
  inbox = yes
  location = 
  mailbox Drafts {
    special_use = \Drafts
  }
  mailbox Junk {
    special_use = \Junk
  }
  mailbox Sent {
    special_use = \Sent
  }
  mailbox "Sent Messages" {
    special_use = \Sent
  }
  mailbox Trash {
    special_use = \Trash
  }
  prefix = 
}

# 插件配置
mail_plugins = \$mail_plugins quota

plugin {
  quota = maildir:User quota
  quota_rule = *:storage=1GB
  quota_rule2 = Trash:storage=+100M
}

protocol imap {
  mail_plugins = \$mail_plugins imap_quota
}

protocol lmtp {
  mail_plugins = \$mail_plugins quota
}
EOF

    # 创建虚拟用户文件
    cat > "$EMAIL_DIR/config/users" << EOF
# YYC³ 邮箱用户配置
# 格式: username:password:uid:gid:gecos:home:shell
admin@${DOMAIN}:{PLAIN}admin123:5000:5000:Admin User:/var/mail/vhosts/${DOMAIN}/admin:/bin/false
noreply@${DOMAIN}:{PLAIN}noreply123:5000:5000:No Reply:/var/mail/vhosts/${DOMAIN}/noreply:/bin/false
support@${DOMAIN}:{PLAIN}support123:5000:5000:Support:/var/mail/vhosts/${DOMAIN}/support:/bin/false
EOF

    # 创建虚拟别名文件
    cat > "$EMAIL_DIR/config/virtual" << EOF
# YYC³ 邮箱别名配置
postmaster@${DOMAIN}    admin@${DOMAIN}
webmaster@${DOMAIN}     admin@${DOMAIN}
abuse@${DOMAIN}         admin@${DOMAIN}
hostmaster@${DOMAIN}    admin@${DOMAIN}
EOF

    # 创建虚拟邮箱文件
    cat > "$EMAIL_DIR/config/vmailbox" << EOF
# YYC³ 虚拟邮箱配置
admin@${DOMAIN}         ${DOMAIN}/admin/
noreply@${DOMAIN}       ${DOMAIN}/noreply/
support@${DOMAIN}       ${DOMAIN}/support/
EOF

    log_success "邮箱服务器配置创建完成"
}

# 创建 Docker Compose 配置
create_docker_compose() {
    log_step "创建 Docker Compose 配置..."
    
    cat > "$EMAIL_DIR/docker-compose.yml" << EOF
version: '3.8'

services:
  # Postfix SMTP 服务器
  postfix:
    image: catatnight/postfix:latest
    container_name: yyc3-postfix
    hostname: mail.${DOMAIN}
    ports:
      - "25:25"
      - "587:587"
    Volumes:
      - ./config/main.cf:/etc/postfix/main.cf:ro
      - ./config/virtual:/etc/postfix/virtual:ro
      - ./config/vmailbox:/etc/postfix/vmailbox:ro
      - ./data/mail:/var/mail
      - ./logs:/var/log/mail
      - /etc/ssl/certs:/etc/ssl/certs:ro
      - /etc/ssl/private:/etc/ssl/private:ro
    environment:
      - maildomain=${DOMAIN}
      - smtp_user=${SMTP_USER}:${SMTP_PASSWORD}
    restart: unless-stopped
    networks:
      - yyc3-network

  # Dovecot IMAP/POP3 服务器
  dovecot:
    image: dovecot/dovecot:latest
    container_name: yyc3-dovecot
    ports:
      - "143:143"   # IMAP
      - "993:993"   # IMAPS
      - "110:110"   # POP3
      - "995:995"   # POP3S
    Volumes:
      - ./config/dovecot.conf:/etc/dovecot/dovecot.conf:ro
      - ./config/users:/etc/dovecot/users:ro
      - ./data/mail:/var/mail
      - ./logs:/var/log/dovecot
      - /etc/ssl/certs:/etc/ssl/certs:ro
      - /etc/ssl/private:/etc/ssl/private:ro
    restart: unless-stopped
    networks:
      - yyc3-network

  # Roundcube 网页邮箱
  roundcube:
    image: roundcube/roundcubemail:latest
    container_name: yyc3-roundcube
    ports:
      - "8081:80"
    Volumes:
      - ./data/roundcube:/var/www/html
      - ./config/roundcube:/var/roundcube/config
    environment:
      - ROUNDCUBEMAIL_DB_TYPE=sqlite
      - ROUNDCUBEMAIL_DB_HOST=sqlite:////var/roundcube/db/sqlite.db
      - ROUNDCUBEMAIL_DEFAULT_HOST=ssl://mail.${DOMAIN}
      - ROUNDCUBEMAIL_DEFAULT_PORT=993
      - ROUNDCUBEMAIL_SMTP_SERVER=tls://mail.${DOMAIN}
      - ROUNDCUBEMAIL_SMTP_PORT=587
    restart: unless-stopped
    networks:
      - yyc3-network

  # 邮件队列监控
  mailqueue-monitor:
    image: alpine:latest
    container_name: yyc3-mailqueue-monitor
    Volumes:
      - ./scripts:/scripts
      - ./logs:/logs
    command: /scripts/monitor-mailqueue.sh
    restart: unless-stopped
    networks:
      - yyc3-network

  # 邮件统计服务
  mail-stats:
    build:
      context: .
      dockerfile: Dockerfile.stats
    container_name: yyc3-mail-stats
    ports:
      - "3003:3000"
    Volumes:
      - ./logs:/app/logs:ro
      - ./data/stats:/app/data
    environment:
      - NODE_ENV=production
      - DOMAIN=${DOMAIN}
    restart: unless-stopped
    networks:
      - yyc3-network

networks:
  yyc3-network:
    external: true
EOF

    log_success "Docker Compose 配置创建完成"
}

# 创建邮件统计服务
create_mail_stats_service() {
    log_step "创建邮件统计服务..."
    
    # 创建 Dockerfile
    cat > "$EMAIL_DIR/Dockerfile.stats" << EOF
FROM node:18-alpine

WORKDIR /app

# 安装依赖
COPY package.json package-lock.json ./
RUN npm ci --only=production

# 复制源代码
COPY src/ ./src/
COPY public/ ./public/

# 创建数据目录
RUN mkdir -p /app/data /app/logs

# 设置权限
RUN addgroup -g 1001 -S nodejs
RUN adduser -S nodejs -u 1001
RUN chown -R nodejs:nodejs /app
USER nodejs

EXPOSE 3000

CMD ["node", "src/server.js"]
EOF

    # 创建 package.json
    cat > "$EMAIL_DIR/package.json" << EOF
{
  "name": "yyc3-mail-stats",
  "version": "1.0.0",
  "description": "YYC³ 邮件统计服务",
  "main": "src/server.js",
  "scripts": {
    "start": "node src/server.js",
    "dev": "nodemon src/server.js",
    "test": "jest"
  },
  "dependencies": {
    "express": "^4.18.0",
    "sqlite3": "^5.1.0",
    "node-cron": "^3.0.0",
    "winston": "^3.11.0",
    "cors": "^2.8.5",
    "helmet": "^7.1.0",
    "compression": "^1.7.4",
    "moment": "^2.29.0"
  },
  "devDependencies": {
    "nodemon": "^3.0.0",
    "jest": "^29.7.0"
  },
  "keywords": ["email", "statistics", "monitoring"],
  "author": "YYC³ Development Team",
  "license": "MIT"
}
EOF

    # 创建统计服务器
    mkdir -p "$EMAIL_DIR/src"
    cat > "$EMAIL_DIR/src/server.js" << EOF
const express = require('express');
const sqlite3 = require('sqlite3').verbose();
const cron = require('node-cron');
const winston = require('winston');
const cors = require('cors');
const helmet = require('helmet');
const compression = require('compression');
const fs = require('fs');
const path = require('path');
const moment = require('moment');

const app = express();
const PORT = process.env.PORT || 3000;
const DOMAIN = process.env.DOMAIN || 'china@0379.pro';

// 日志配置
const logger = winston.createLogger({
  level: 'info',
  format: winston.format.combine(
    winston.format.timestamp(),
    winston.format.json()
  ),
  transports: [
    new winston.transports.File({ filename: '/app/logs/mail-stats.log' }),
    new winston.transports.Console()
  ]
});

// 中间件
app.use(helmet());
app.use(cors());
app.use(compression());
app.use(express.json());
app.use(express.static('public'));

// 数据库初始化
const db = new sqlite3.Database('/app/data/mail-stats.db');

// 创建表
db.serialize(() => {
  db.run(\`CREATE TABLE IF NOT EXISTS mail_stats (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    date TEXT NOT NULL,
    sent_count INTEGER DEFAULT 0,
    received_count INTEGER DEFAULT 0,
    bounced_count INTEGER DEFAULT 0,
    spam_count INTEGER DEFAULT 0,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
  )\`);

  db.run(\`CREATE TABLE IF NOT EXISTS mail_logs (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    timestamp DATETIME,
    type TEXT,
    from_addr TEXT,
    to_addr TEXT,
    subject TEXT,
    status TEXT,
    message_id TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
  )\`);
});

// API 路由
app.get('/api/stats/overview', (req, res) => {
  const today = moment().format('YYYY-MM-DD');
  const yesterday = moment().subtract(1, 'day').format('YYYY-MM-DD');
  const thisWeek = moment().startOf('week').format('YYYY-MM-DD');
  const thisMonth = moment().startOf('month').format('YYYY-MM-DD');

  const queries = {
    today: \`SELECT * FROM mail_stats WHERE date = ?\`,
    yesterday: \`SELECT * FROM mail_stats WHERE date = ?\`,
    thisWeek: \`SELECT SUM(sent_count) as sent, SUM(received_count) as received, 
               SUM(bounced_count) as bounced, SUM(spam_count) as spam 
               FROM mail_stats WHERE date >= ?\`,
    thisMonth: \`SELECT SUM(sent_count) as sent, SUM(received_count) as received, 
                SUM(bounced_count) as bounced, SUM(spam_count) as spam 
                FROM mail_stats WHERE date >= ?\`
  };

  Promise.all([
    new Promise((resolve) => db.get(queries.today, [today], (err, row) => resolve(row || {}))),
    new Promise((resolve) => db.get(queries.yesterday, [yesterday], (err, row) => resolve(row || {}))),
    new Promise((resolve) => db.get(queries.thisWeek, [thisWeek], (err, row) => resolve(row || {}))),
    new Promise((resolve) => db.get(queries.thisMonth, [thisMonth], (err, row) => resolve(row || {})))
  ]).then(([todayStats, yesterdayStats, weekStats, monthStats]) => {
    res.json({
      success: true,
      data: {
        today: todayStats,
        yesterday: yesterdayStats,
        thisWeek: weekStats,
        thisMonth: monthStats,
        domain: DOMAIN
      }
    });
  }).catch(err => {
    logger.error('获取统计概览失败:', err);
    res.status(500).json({ success: false, error: '获取统计数据失败' });
  });
});

app.get('/api/stats/chart/:period', (req, res) => {
  const { period } = req.params;
  let query, params;

  switch (period) {
    case '7days':
      query = \`SELECT date, sent_count, received_count, bounced_count, spam_count 
               FROM mail_stats WHERE date >= ? ORDER BY date\`;
      params = [moment().subtract(7, 'days').format('YYYY-MM-DD')];
      break;
    case '30days':
      query = \`SELECT date, sent_count, received_count, bounced_count, spam_count 
               FROM mail_stats WHERE date >= ? ORDER BY date\`;
      params = [moment().subtract(30, 'days').format('YYYY-MM-DD')];
      break;
    case '12months':
      query = \`SELECT strftime('%Y-%m', date) as month, 
               SUM(sent_count) as sent_count, SUM(received_count) as received_count,
               SUM(bounced_count) as bounced_count, SUM(spam_count) as spam_count
               FROM mail_stats WHERE date >= ? GROUP BY month ORDER BY month\`;
      params = [moment().subtract(12, 'months').format('YYYY-MM-DD')];
      break;
    default:
      return res.status(400).json({ success: false, error: '无效的时间周期' });
  }

  db.all(query, params, (err, rows) => {
    if (err) {
      logger.error('获取图表数据失败:', err);
      return res.status(500).json({ success: false, error: '获取图表数据失败' });
    }

    res.json({
      success: true,
      data: rows
    });
  });
});

app.get('/api/logs/recent', (req, res) => {
  const limit = parseInt(req.query.limit) || 50;
  const offset = parseInt(req.query.offset) || 0;

  db.all(
    \`SELECT * FROM mail_logs ORDER BY timestamp DESC LIMIT ? OFFSET ?\`,
    [limit, offset],
    (err, rows) => {
      if (err) {
        logger.error('获取邮件日志失败:', err);
        return res.status(500).json({ success: false, error: '获取邮件日志失败' });
      }

      res.json({
        success: true,
        data: rows
      });
    }
  );
});

// 健康检查
app.get('/health', (req, res) => {
  res.json({
    status: 'ok',
    timestamp: new Date().toISOString(),
    service: 'YYC³ Mail Stats',
    domain: DOMAIN
  });
});

// 解析邮件日志的函数
function parseMailLogs() {
  const logFile = '/app/logs/mail.log';
  
  if (!fs.existsSync(logFile)) {
    logger.warn('邮件日志文件不存在:', logFile);
    return;
  }

  try {
    const logContent = fs.readFileSync(logFile, 'utf8');
    const lines = logContent.split('\n');
    
    lines.forEach(line => {
      if (line.trim()) {
        parseLogLine(line);
      }
    });
    
    logger.info('邮件日志解析完成');
  } catch (error) {
    logger.error('解析邮件日志失败:', error);
  }
}

function parseLogLine(line) {
  // 简单的日志解析逻辑
  const patterns = {
    sent: /postfix\/smtp.*status=sent/,
    received: /postfix\/smtpd.*client=/,
    bounced: /postfix\/bounce/,
    spam: /postfix.*reject.*spam/
  };

  const today = moment().format('YYYY-MM-DD');
  
  Object.keys(patterns).forEach(type => {
    if (patterns[type].test(line)) {
      updateStats(today, type);
    }
  });
}

function updateStats(date, type) {
  const column = type + '_count';
  
  db.run(
    \`INSERT OR IGNORE INTO mail_stats (date, \${column}) VALUES (?, 0)\`,
    [date],
    function() {
      db.run(
        \`UPDATE mail_stats SET \${column} = \${column} + 1 WHERE date = ?\`,
        [date]
      );
    }
  );
}

// 定时任务：每小时解析一次日志
cron.schedule('0 * * * *', () => {
  logger.info('开始定时解析邮件日志');
  parseMailLogs();
});

// 启动服务器
app.listen(PORT, () => {
  logger.info(\`YYC³ 邮件统计服务启动成功，端口: \${PORT}\`);
  logger.info(\`域名: \${DOMAIN}\`);
  
  // 启动时解析一次日志
  parseMailLogs();
});

// 优雅关闭
process.on('SIGTERM', () => {
  logger.info('收到 SIGTERM 信号，正在关闭服务器...');
  db.close();
  process.exit(0);
});
EOF

    log_success "邮件统计服务创建完成"
}

# 创建前端管理界面
create_frontend_interface() {
    log_step "创建前端管理界面..."
    
    mkdir -p "$EMAIL_DIR/public"/{css,js,images}
    
    # 创建主页面
    cat > "$EMAIL_DIR/public/index.html" << EOF
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>YYC³ 邮箱服务器管理</title>
    <link rel="stylesheet" href="css/style.css">
    <link rel="icon" href="data:image/svg+xml,<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 100 100'><text y='.9em' font-size='90'>📧</text></svg>">
</head>
<body>
    <div class="container">
        <!-- 头部导航 -->
        <header class="header">
            <div class="header-content">
                <div class="logo">
                    <span class="logo-icon">📧</span>
                    <h1>YYC³ 邮箱服务器</h1>
                </div>
                <nav class="nav">
                    <a href="#overview" class="nav-link active">概览</a>
                    <a href="#stats" class="nav-link">统计</a>
                    <a href="#logs" class="nav-link">日志</a>
                    <a href="#settings" class="nav-link">设置</a>
                </nav>
            </div>
        </header>

        <!-- 主要内容 -->
        <main class="main">
            <!-- 概览页面 -->
            <section id="overview" class="page active">
                <div class="page-header">
                    <h2>服务器概览</h2>
                    <p>实时监控邮箱服务器状态和性能</p>
                </div>

                <!-- 状态卡片 -->
                <div class="stats-grid">
                    <div class="stat-card">
                        <div class="stat-icon">📤</div>
                        <div class="stat-content">
                            <h3>今日发送</h3>
                            <div class="stat-number" id="todaySent">-</div>
                            <div class="stat-change positive" id="sentChange">-</div>
                        </div>
                    </div>

                    <div class="stat-card">
                        <div class="stat-icon">📥</div>
                        <div class="stat-content">
                            <h3>今日接收</h3>
                            <div class="stat-number" id="todayReceived">-</div>
                            <div class="stat-change positive" id="receivedChange">-</div>
                        </div>
                    </div>

                    <div class="stat-card">
                        <div class="stat-icon">⚠️</div>
                        <div class="stat-content">
                            <h3>退信数量</h3>
                            <div class="stat-number" id="todayBounced">-</div>
                            <div class="stat-change negative" id="bouncedChange">-</div>
                        </div>
                    </div>

                    <div class="stat-card">
                        <div class="stat-icon">🛡️</div>
                        <div class="stat-content">
                            <h3>垃圾邮件</h3>
                            <div class="stat-number" id="todaySpam">-</div>
                            <div class="stat-change negative" id="spamChange">-</div>
                        </div>
                    </div>
                </div>

                <!-- 服务状态 -->
                <div class="service-status">
                    <h3>服务状态</h3>
                    <div class="status-grid">
                        <div class="status-item">
                            <div class="status-indicator" id="postfixStatus"></div>
                            <span>Postfix SMTP</span>
                        </div>
                        <div class="status-item">
                            <div class="status-indicator" id="dovecotStatus"></div>
                            <span>Dovecot IMAP</span>
                        </div>
                        <div class="status-item">
                            <div class="status-indicator" id="roundcubeStatus"></div>
                            <span>Roundcube</span>
                        </div>
                        <div class="status-item">
                            <div class="status-indicator" id="statsStatus"></div>
                            <span>统计服务</span>
                        </div>
                    </div>
                </div>

                <!-- 快速操作 -->
                <div class="quick-actions">
                    <h3>快速操作</h3>
                    <div class="action-buttons">
                        <button class="btn btn-primary" onclick="sendTestEmail()">
                            <span>📧</span> 发送测试邮件
                        </button>
                        <button class="btn btn-secondary" onclick="checkMailQueue()">
                            <span>📋</span> 检查邮件队列
                        </button>
                        <button class="btn btn-secondary" onclick="restartServices()">
                            <span>🔄</span> 重启服务
                        </button>
                        <button class="btn btn-secondary" onclick="viewLogs()">
                            <span>📄</span> 查看日志
                        </button>
                    </div>
                </div>
            </section>

            <!-- 统计页面 -->
            <section id="stats" class="page">
                <div class="page-header">
                    <h2>邮件统计</h2>
                    <p>详细的邮件收发统计和趋势分析</p>
                </div>

                <!-- 时间选择器 -->
                <div class="time-selector">
                    <button class="time-btn active" data-period="7days">最近7天</button>
                    <button class="time-btn" data-period="30days">最近30天</button>
                    <button class="time-btn" data-period="12months">最近12个月</button>
                </div>

                <!-- 图表容器 -->
                <div class="chart-container">
                    <canvas id="mailChart"></canvas>
                </div>

                <!-- 详细统计 -->
                <div class="detailed-stats">
                    <div class="stat-section">
                        <h3>本周统计</h3>
                        <div class="stat-row">
                            <span>发送邮件:</span>
                            <span id="weekSent">-</span>
                        </div>
                        <div class="stat-row">
                            <span>接收邮件:</span>
                            <span id="weekReceived">-</span>
                        </div>
                        <div class="stat-row">
                            <span>退信数量:</span>
                            <span id="weekBounced">-</span>
                        </div>
                        <div class="stat-row">
                            <span>垃圾邮件:</span>
                            <span id="weekSpam">-</span>
                        </div>
                    </div>

                    <div class="stat-section">
                        <h3>本月统计</h3>
                        <div class="stat-row">
                            <span>发送邮件:</span>
                            <span id="monthSent">-</span>
                        </div>
                        <div class="stat-row">
                            <span>接收邮件:</span>
                            <span id="monthReceived">-</span>
                        </div>
                        <div class="stat-row">
                            <span>退信数量:</span>
                            <span id="monthBounced">-</span>
                        </div>
                        <div class="stat-row">
                            <span>垃圾邮件:</span>
                            <span id="monthSpam">-</span>
                        </div>
                    </div>
                </div>
            </section>

            <!-- 日志页面 -->
            <section id="logs" class="page">
                <div class="page-header">
                    <h2>邮件日志</h2>
                    <p>实时查看邮件服务器日志</p>
                </div>

                <!-- 日志过滤器 -->
                <div class="log-filters">
                    <select id="logType">
                        <option value="all">所有类型</option>
                        <option value="sent">已发送</option>
                        <option value="received">已接收</option>
                        <option value="bounced">退信</option>
                        <option value="spam">垃圾邮件</option>
                    </select>
                    <input type="text" id="logSearch" placeholder="搜索日志...">
                    <button class="btn btn-primary" onclick="refreshLogs()">刷新</button>
                </div>

                <!-- 日志列表 -->
                <div class="log-container">
                    <table class="log-table">
                        <thead>
                            <tr>
                                <th>时间</th>
                                <th>类型</th>
                                <th>发件人</th>
                                <th>收件人</th>
                                <th>主题</th>
                                <th>状态</th>
                            </tr>
                        </thead>
                        <tbody id="logTableBody">
                            <!-- 日志数据将通过 JavaScript 动态加载 -->
                        </tbody>
                    </table>
                </div>

                <!-- 分页 -->
                <div class="pagination">
                    <button class="btn btn-secondary" onclick="prevPage()">上一页</button>
                    <span id="pageInfo">第 1 页</span>
                    <button class="btn btn-secondary" onclick="nextPage()">下一页</button>
                </div>
            </section>

            <!-- 设置页面 -->
            <section id="settings" class="page">
                <div class="page-header">
                    <h2>系统设置</h2>
                    <p>配置邮箱服务器参数和选项</p>
                </div>

                <!-- 基本设置 -->
                <div class="settings-section">
                    <h3>基本设置</h3>
                    <div class="form-group">
                        <label for="serverDomain">服务器域名</label>
                        <input type="text" id="serverDomain" value="${DOMAIN}" readonly>
                    </div>
                    <div class="form-group">
                        <label for="serverIP">服务器IP</label>
                        <input type="text" id="serverIP" value="${SERVER_IP}" readonly>
                    </div>
                    <div class="form-group">
                        <label for="adminEmail">管理员邮箱</label>
                        <input type="email" id="adminEmail" value="${ADMIN_EMAIL:-admin@${DOMAIN}}">
                    </div>
                </div>

                <!-- SMTP 设置 -->
                <div class="settings-section">
                    <h3>SMTP 设置</h3>
                    <div class="form-group">
                        <label for="smtpHost">SMTP 服务器</label>
                        <input type="text" id="smtpHost" value="${SMTP_HOST}">
                    </div>
                    <div class="form-group">
                        <label for="smtpPort">SMTP 端口</label>
                        <input type="number" id="smtpPort" value="${SMTP_PORT}">
                    </div>
                    <div class="form-group">
                        <label for="smtpUser">SMTP 用户名</label>
                        <input type="text" id="smtpUser" value="${SMTP_USER}">
                    </div>
                </div>

                <!-- 安全设置 -->
                <div class="settings-section">
                    <h3>安全设置</h3>
                    <div class="form-group">
                        <label>
                            <input type="checkbox" id="enableTLS" checked>
                            启用 TLS 加密
                        </label>
                    </div>
                    <div class="form-group">
                        <label>
                            <input type="checkbox" id="enableSASL" checked>
                            启用 SASL 认证
                        </label>
                    </div>
                    <div class="form-group">
                        <label>
                            <input type="checkbox" id="enableSpamFilter" checked>
                            启用垃圾邮件过滤
                        </label>
                    </div>
                </div>

                <!-- 保存按钮 -->
                <div class="settings-actions">
                    <button class="btn btn-primary" onclick="saveSettings()">保存设置</button>
                    <button class="btn btn-secondary" onclick="resetSettings()">重置设置</button>
                </div>
            </section>
        </main>

        <!-- 页脚 -->
        <footer class="footer">
            <p>&copy; 2024 YYC³ 邮箱服务器管理系统 | 版本 1.0.0</p>
        </footer>
    </div>

    <!-- 模态框 -->
    <div id="modal" class="modal">
        <div class="modal-content">
            <span class="close" onclick="closeModal()">&times;</span>
            <div id="modalBody"></div>
        </div>
    </div>

    <!-- 加载 JavaScript -->
    <script src="js/chart.min.js"></script>
    <script src="js/app.js"></script>
</body>
</html>
EOF

    # 创建 CSS 样式
    cat > "$EMAIL_DIR/public/css/style.css" << EOF
/* YYC³ 邮箱服务器管理界面样式 */

* {
    margin: 0;
    padding: 0;
    box-sizing: border-box;
}

body {
    font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
    background-color: #f5f7fa;
    color: #333;
    line-height: 1.6;
}

.container {
    min-height: 100vh;
    display: flex;
    flex-direction: column;
}

/* 头部样式 */
.header {
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    color: white;
    padding: 1rem 0;
    box-shadow: 0 2px 10px rgba(0,0,0,0.1);
}

.header-content {
    max-width: 1200px;
    margin: 0 auto;
    padding: 0 2rem;
    display: flex;
    justify-content: space-between;
    align-items: center;
}

.logo {
    display: flex;
    align-items: center;
    gap: 1rem;
}

.logo-icon {
    font-size: 2rem;
}

.logo h1 {
    font-size: 1.5rem;
    font-weight: 600;
}

.nav {
    display: flex;
    gap: 2rem;
}

.nav-link {
    color: white;
    text-decoration: none;
    padding: 0.5rem 1rem;
    border-radius: 0.5rem;
    transition: background-color 0.3s;
}

.nav-link:hover,
.nav-link.active {
    background-color: rgba(255,255,255,0.2);
}

/* 主要内容样式 */
.main {
    flex: 1;
    max-width: 1200px;
    margin: 0 auto;
    padding: 2rem;
    width: 100%;
}

.page {
    display: none;
}

.page.active {
    display: block;
}

.page-header {
    margin-bottom: 2rem;
}

.page-header h2 {
    font-size: 2rem;
    color: #2d3748;
    margin-bottom: 0.5rem;
}

.page-header p {
    color: #718096;
    font-size: 1.1rem;
}

/* 统计卡片样式 */
.stats-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
    gap: 1.5rem;
    margin-bottom: 2rem;
}

.stat-card {
    background: white;
    padding: 1.5rem;
    border-radius: 1rem;
    box-shadow: 0 4px 6px rgba(0,0,0,0.05);
    display: flex;
    align-items: center;
    gap: 1rem;
    transition: transform 0.3s, box-shadow 0.3s;
}

.stat-card:hover {
    transform: translateY(-2px);
    box-shadow: 0 8px 25px rgba(0,0,0,0.1);
}

.stat-icon {
    font-size: 2.5rem;
    width: 60px;
    height: 60px;
    display: flex;
    align-items: center;
    justify-content: center;
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    border-radius: 1rem;
}

.stat-content h3 {
    color: #718096;
    font-size: 0.9rem;
    font-weight: 500;
    margin-bottom: 0.5rem;
}

.stat-number {
    font-size: 2rem;
    font-weight: 700;
    color: #2d3748;
    margin-bottom: 0.25rem;
}

.stat-change {
    font-size: 0.8rem;
    font-weight: 500;
}

.stat-change.positive {
    color: #38a169;
}

.stat-change.negative {
    color: #e53e3e;
}

/* 服务状态样式 */
.service-status {
    background: white;
    padding: 1.5rem;
    border-radius: 1rem;
    box-shadow: 0 4px 6px rgba(0,0,0,0.05);
    margin-bottom: 2rem;
}

.service-status h3 {
    margin-bottom: 1rem;
    color: #2d3748;
}

.status-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
    gap: 1rem;
}

.status-item {
    display: flex;
    align-items: center;
    gap: 0.75rem;
    padding: 0.75rem;
    background: #f7fafc;
    border-radius: 0.5rem;
}

.status-indicator {
    width: 12px;
    height: 12px;
    border-radius: 50%;
    background-color: #e2e8f0;
}

.status-indicator.online {
    background-color: #38a169;
    box-shadow: 0 0 0 2px rgba(56, 161, 105, 0.2);
}

.status-indicator.offline {
    background-color: #e53e3e;
    box-shadow: 0 0 0 2px rgba(229, 62, 62, 0.2);
}

/* 快速操作样式 */
.quick-actions {
    background: white;
    padding: 1.5rem;
    border-radius: 1rem;
    box-shadow: 0 4px 6px rgba(0,0,0,0.05);
}

.quick-actions h3 {
    margin-bottom: 1rem;
    color: #2d3748;
}

.action-buttons {
    display: flex;
    gap: 1rem;
    flex-wrap: wrap;
}

/* 按钮样式 */
.btn {
    padding: 0.75rem 1.5rem;
    border: none;
    border-radius: 0.5rem;
    font-weight: 500;
    cursor: pointer;
    transition: all 0.3s;
    display: inline-flex;
    align-items: center;
    gap: 0.5rem;
    text-decoration: none;
}

.btn-primary {
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    color: white;
}

.btn-primary:hover {
    transform: translateY(-1px);
    box-shadow: 0 4px 12px rgba(102, 126, 234, 0.4);
}

.btn-secondary {
    background: #e2e8f0;
    color: #4a5568;
}

.btn-secondary:hover {
    background: #cbd5e0;
}

/* 时间选择器样式 */
.time-selector {
    display: flex;
    gap: 0.5rem;
    margin-bottom: 2rem;
    background: white;
    padding: 0.5rem;
    border-radius: 0.75rem;
    box-shadow: 0 4px 6px rgba(0,0,0,0.05);
    width: fit-content;
}

.time-btn {
    padding: 0.5rem 1rem;
    border: none;
    background: transparent;
    border-radius: 0.5rem;
    cursor: pointer;
    transition: all 0.3s;
    color: #718096;
    font-weight: 500;
}

.time-btn.active,
.time-btn:hover {
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    color: white;
}

/* 图表容器样式 */
.chart-container {
    background: white;
    padding: 2rem;
    border-radius: 1rem;
    box-shadow: 0 4px 6px rgba(0,0,0,0.05);
    margin-bottom: 2rem;
    height: 400px;
}

/* 详细统计样式 */
.detailed-stats {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
    gap: 1.5rem;
}

.stat-section {
    background: white;
    padding: 1.5rem;
    border-radius: 1rem;
    box-shadow: 0 4px 6px rgba(0,0,0,0.05);
}

.stat-section h3 {
    margin-bottom: 1rem;
    color: #2d3748;
    border-bottom: 2px solid #e2e8f0;
    padding-bottom: 0.5rem;
}

.stat-row {
    display: flex;
    justify-content: space-between;
    padding: 0.5rem 0;
    border-bottom: 1px solid #f7fafc;
}

.stat-row:last-child {
    border-bottom: none;
}

/* 日志样式 */
.log-filters {
    display: flex;
    gap: 1rem;
    margin-bottom: 1.5rem;
    align-items: center;
    flex-wrap: wrap;
}

.log-filters select,
.log-filters input {
    padding: 0.5rem;
    border: 1px solid #e2e8f0;
    border-radius: 0.5rem;
    background: white;
}

.log-container {
    background: white;
    border-radius: 1rem;
    box-shadow: 0 4px 6px rgba(0,0,0,0.05);
    overflow: hidden;
    margin-bottom: 1rem;
}

.log-table {
    width: 100%;
    border-collapse: collapse;
}

.log-table th,
.log-table td {
    padding: 1rem;
    text-align: left;
    border-bottom: 1px solid #e2e8f0;
}

.log-table th {
    background: #f7fafc;
    font-weight: 600;
    color: #4a5568;
}

.log-table tr:hover {
    background: #f7fafc;
}

/* 分页样式 */
.pagination {
    display: flex;
    justify-content: center;
    align-items: center;
    gap: 1rem;
}

/* 设置样式 */
.settings-section {
    background: white;
    padding: 1.5rem;
    border-radius: 1rem;
    box-shadow: 0 4px 6px rgba(0,0,0,0.05);
    margin-bottom: 1.5rem;
}

.settings-section h3 {
    margin-bottom: 1rem;
    color: #2d3748;
    border-bottom: 2px solid #e2e8f0;
    padding-bottom: 0.5rem;
}

.form-group {
    margin-bottom: 1rem;
}

.form-group label {
    display: block;
    margin-bottom: 0.5rem;
    color: #4a5568;
    font-weight: 500;
}

.form-group input[type="text"],
.form-group input[type="email"],
.form-group input[type="number"] {
    width: 100%;
    padding: 0.75rem;
    border: 1px solid #e2e8f0;
    border-radius: 0.5rem;
    background: white;
    transition: border-color 0.3s;
}

.form-group input:focus {
    outline: none;
    border-color: #667eea;
    box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
}

.form-group input[type="checkbox"] {
    margin-right: 0.5rem;
}

.settings-actions {
    display: flex;
    gap: 1rem;
    justify-content: flex-end;
}

/* 模态框样式 */
.modal {
    display: none;
    position: fixed;
    z-index: 1000;
    left: 0;
    top: 0;
    width: 100%;
    height: 100%;
    background-color: rgba(0,0,0,0.5);
}

.modal-content {
    background-color: white;
    margin: 15% auto;
    padding: 2rem;
    border-radius: 1rem;
    width: 80%;
    max-width: 500px;
    position: relative;
}

.close {
    position: absolute;
    right: 1rem;
    top: 1rem;
    font-size: 1.5rem;
    cursor: pointer;
    color: #718096;
}

.close:hover {
    color: #2d3748;
}

/* 页脚样式 */
.footer {
    background: #2d3748;
    color: white;
    text-align: center;
    padding: 1rem;
    margin-top: auto;
}

/* 响应式设计 */
@media (max-width: 768px) {
    .header-content {
        flex-direction: column;
        gap: 1rem;
    }

    .nav {
        gap: 1rem;
    }

    .main {
        padding: 1rem;
    }

    .stats-grid {
        grid-template-columns: 1fr;
    }

    .action-buttons {
        flex-direction: column;
    }

    .log-table {
        font-size: 0.8rem;
    }

    .log-table th,
    .log-table td {
        padding: 0.5rem;
    }

    .detailed-stats {
        grid-template-columns: 1fr;
    }

    .time-selector {
        flex-wrap: wrap;
    }

    .log-filters {
        flex-direction: column;
        align-items: stretch;
    }

    .settings-actions {
        flex-direction: column;
    }
}

/* 动画效果 */
@keyframes fadeIn {
    from { opacity: 0; transform: translateY(20px); }
    to { opacity: 1; transform: translateY(0); }
}

.page.active {
    animation: fadeIn 0.5s ease-out;
}

/* 加载动画 */
.loading {
    display: inline-block;
    width: 20px;
    height: 20px;
    border: 3px solid #f3f3f3;
    border-top: 3px solid #667eea;
    border-radius: 50%;
    animation: spin 1s linear infinite;
}

@keyframes spin {
    0% { transform: rotate(0deg); }
    100% { transform: rotate(360deg); }
}

/* 成功/错误消息样式 */
.message {
    padding: 1rem;
    border-radius: 0.5rem;
    margin-bottom: 1rem;
}

.message.success {
    background: #f0fff4;
    color: #38a169;
    border: 1px solid #9ae6b4;
}

.message.error {
    background: #fed7d7;
    color: #e53e3e;
    border: 1px solid #feb2b2;
}

.message.warning {
    background: #fffbeb;
    color: #d69e2e;
    border: 1px solid #fbd38d;
}

.message.info {
    background: #ebf8ff;
    color: #3182ce;
    border: 1px solid #90cdf4;
}
EOF

    # 创建 JavaScript 应用
    cat > "$EMAIL_DIR/public/js/app.js" << EOF
// YYC³ 邮箱服务器管理界面 JavaScript

class MailServerManager {
    constructor() {
        this.currentPage = 'overview';
        this.currentLogPage = 1;
        this.logPageSize = 50;
        this.chart = null;
        this.refreshInterval = null;
        
        this.init();
    }

    init() {
        this.setupNavigation();
        this.setupEventListeners();
        this.loadOverviewData();
        this.startAutoRefresh();
        
        console.log('YYC³ 邮箱服务器管理界面已初始化');
    }

    // 设置导航
    setupNavigation() {
        const navLinks = document.querySelectorAll('.nav-link');
        const pages = document.querySelectorAll('.page');

        navLinks.forEach(link => {
            link.addEventListener('click', (e) => {
                e.preventDefault();
                const targetPage = link.getAttribute('href').substring(1);
                
                // 更新导航状态
                navLinks.forEach(l => l.classList.remove('active'));
                link.classList.add('active');
                
                // 显示对应页面
                pages.forEach(p => p.classList.remove('active'));
                document.getElementById(targetPage).classList.add('active');
                
                this.currentPage = targetPage;
                this.loadPageData(targetPage);
            });
        });
    }

    // 设置事件监听器
    setupEventListeners() {
        // 时间选择器
        const timeButtons = document.querySelectorAll('.time-btn');
        timeButtons.forEach(btn => {
            btn.addEventListener('click', () => {
                timeButtons.forEach(b => b.classList.remove('active'));
                btn.classList.add('active');
                this.loadChartData(btn.dataset.period);
            });
        });

        // 日志搜索
        const logSearch = document.getElementById('logSearch');
        if (logSearch) {
            logSearch.addEventListener('input', this.debounce(() => {
                this.loadLogs();
            }, 500));
        }

        // 日志类型过滤
        const logType = document.getElementById('logType');
        if (logType) {
            logType.addEventListener('change', () => {
                this.loadLogs();
            });
        }
    }

    // 加载页面数据
    loadPageData(page) {
        switch (page) {
            case 'overview':
                this.loadOverviewData();
                break;
            case 'stats':
                this.loadStatsData();
                break;
            case 'logs':
                this.loadLogs();
                break;
            case 'settings':
                this.loadSettings();
                break;
        }
    }

    // 加载概览数据
    async loadOverviewData() {
        try {
            const response = await fetch('/api/stats/overview');
            const data = await response.json();
            
            if (data.success) {
                this.updateOverviewStats(data.data);
                this.checkServiceStatus();
            }
        } catch (error) {
            console.error('加载概览数据失败:', error);
            this.showMessage('加载概览数据失败', 'error');
        }
    }

    // 更新概览统计
    updateOverviewStats(data) {
        const { today, yesterday, thisWeek, thisMonth } = data;
        
        // 更新今日数据
        document.getElementById('todaySent').textContent = today.sent_count || 0;
        document.getElementById('todayReceived').textContent = today.received_count || 0;
        document.getElementById('todayBounced').textContent = today.bounced_count || 0;
        document.getElementById('todaySpam').textContent = today.spam_count || 0;
        
        // 计算变化百分比
        this.updateChangeIndicator('sentChange', today.sent_count, yesterday.sent_count);
        this.updateChangeIndicator('receivedChange', today.received_count, yesterday.received_count);
        this.updateChangeIndicator('bouncedChange', today.bounced_count, yesterday.bounced_count);
        this.updateChangeIndicator('spamChange', today.spam_count, yesterday.spam_count);
        
        // 更新周月统计
        if (thisWeek) {
            document.getElementById('weekSent').textContent = thisWeek.sent || 0;
            document.getElementById('weekReceived').textContent = thisWeek.received || 0;
            document.getElementById('weekBounced').textContent = thisWeek.bounced || 0;
            document.getElementById('weekSpam').textContent = thisWeek.spam || 0;
        }
        
        if (thisMonth) {
            document.getElementById('monthSent').textContent = thisMonth.sent || 0;
            document.getElementById('monthReceived').textContent = thisMonth.received || 0;
            document.getElementById('monthBounced').textContent = thisMonth.bounced || 0;
            document.getElementById('monthSpam').textContent = thisMonth.spam || 0;
        }
    }

    // 更新变化指示器
    updateChangeIndicator(elementId, current, previous) {
        const element = document.getElementById(elementId);
        if (!element) return;
        
        const change = current - (previous || 0);
        const percentage = previous > 0 ? ((change / previous) * 100).toFixed(1) : 0;
        
        if (change > 0) {
            element.textContent = `+${change} (+${percentage}%)`;
            element.className = 'stat-change positive';
        } else if (change < 0) {
            element.textContent = `${change} (${percentage}%)`;
            element.className = 'stat-change negative';
        } else {
            element.textContent = '无变化';
            element.className = 'stat-change';
        }
    }

    // 检查服务��态
    async checkServiceStatus() {
        const services = [
            { id: 'postfixStatus', url: '/api/service/postfix/status' },
            { id: 'dovecotStatus', url: '/api/service/dovecot/status' },
            { id: 'roundcubeStatus', url: '/api/service/roundcube/status' },
            { id: 'statsStatus', url: '/health' }
        ];

        for (const service of services) {
            try {
                const response = await fetch(service.url);
                const element = document.getElementById(service.id);
                
                if (response.ok) {
                    element.className = 'status-indicator online';
                } else {
                    element.className = 'status-indicator offline';
                }
            } catch (error) {
                document.getElementById(service.id).className = 'status-indicator offline';
            }
        }
    }

    // 加载统计数据
    async loadStatsData() {
        this.loadChartData('7days');
    }

    // 加载图表数据
    async loadChartData(period) {
        try {
            const response = await fetch(`/api/stats/chart/${period}`);
            const data = await response.json();
            
            if (data.success) {
                this.renderChart(data.data, period);
            }
        } catch (error) {
            console.error('加载图表数据失败:', error);
            this.showMessage('加载图表数据失败', 'error');
        }
    }

    // 渲染图表
    renderChart(data, period) {
        const ctx = document.getElementById('mailChart');
        if (!ctx) return;

        // 销毁现有图表
        if (this.chart) {
            this.chart.destroy();
        }

        const labels = data.map(item => {
            if (period === '12months') {
                return item.month;
            } else {
                return new Date(item.date).toLocaleDateString('zh-CN');
            }
        });

        this.chart = new Chart(ctx, {
            type: 'line',
            data: {
                labels: labels,
                datasets: [
                    {
                        label: '发送邮件',
                        data: data.map(item => item.sent_count),
                        borderColor: '#667eea',
                        backgroundColor: 'rgba(102, 126, 234, 0.1)',
                        tension: 0.4
                    },
                    {
                        label: '接收邮件',
                        data: data.map(item => item.received_count),
                        borderColor: '#38a169',
                        backgroundColor: 'rgba(56, 161, 105, 0.1)',
                        tension: 0.4
                    },
                    {
                        label: '退信',
                        data: data.map(item => item.bounced_count),
                        borderColor: '#e53e3e',
                        backgroundColor: 'rgba(229, 62, 62, 0.1)',
                        tension: 0.4
                    },
                    {
                        label: '垃圾邮件',
                        data: data.map(item => item.spam_count),
                        borderColor: '#d69e2e',
                        backgroundColor: 'rgba(214, 158, 46, 0.1)',
                        tension: 0.4
                    }
                ]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    title: {
                        display: true,
                        text: '邮件统计趋势'
                    },
                    legend: {
                        position: 'top'
                    }
                },
                scales: {
                    y: {
                        beginAtZero: true,
                        title: {
                            display: true,
                            text: '邮件数量'
                        }
                    },
                    x: {
                        title: {
                            display: true,
                            text: '时间'
                        }
                    }
                }
            }
        });
    }

    // 加载日志
    async loadLogs() {
        try {
            const logType = document.getElementById('logType')?.value || 'all';
            const search = document.getElementById('logSearch')?.value || '';
            
            const params = new URLSearchParams({
                limit: this.logPageSize,
                offset: (this.currentLogPage - 1) * this.logPageSize,
                type: logType,
                search: search
            });

            const response = await fetch(`/api/logs/recent?${params}`);
            const data = await response.json();
            
            if (data.success) {
                this.renderLogs(data.data);
            }
        } catch (error) {
            console.error('加载日志失败:', error);
            this.showMessage('加载日志失败', 'error');
        }
    }

    // 渲染日志
    renderLogs(logs) {
        const tbody = document.getElementById('logTableBody');
        if (!tbody) return;

        tbody.innerHTML = '';

        if (logs.length === 0) {
            tbody.innerHTML = '<tr><td colspan="6" style="text-align: center;">暂无日志数据</td></tr>';
            return;
        }

        logs.forEach(log => {
            const row = document.createElement('tr');
            row.innerHTML = `
                <td>${this.formatDate(log.timestamp)}</td>
                <td><span class="log-type log-type-${log.type}">${this.getLogTypeText(log.type)}</span></td>
                <td>${log.from_addr || '-'}</td>
                <td>${log.to_addr || '-'}</td>
                <td>${log.subject || '-'}</td>
                <td><span class="log-status log-status-${log.status}">${this.getStatusText(log.status)}</span></td>
            `;
            tbody.appendChild(row);
        });

        // 更新分页信息
        document.getElementById('pageInfo').textContent = `第 ${this.currentLogPage} 页`;
    }

    // 加载设置
    loadSettings() {
        // 设置页面已经通过 HTML 模板预填充了数据
        console.log('设置页面已加载');
    }

    // 工具函数
    formatDate(dateString) {
        if (!dateString) return '-';
        return new Date(dateString).toLocaleString('zh-CN');
    }

    getLogTypeText(type) {
        const types = {
            sent: '已发送',
            received: '已接收',
            bounced: '退信',
            spam: '垃圾邮件'
        };
        return types[type] || type;
    }

    getStatusText(status) {
        const statuses = {
            success: '成功',
            failed: '失败',
            pending: '待处理',
            blocked: '已阻止'
        };
        return statuses[status] || status;
    }

    debounce(func, wait) {
        let timeout;
        return function executedFunction(...args) {
            const later = () => {
                clearTimeout(timeout);
                func(...args);
            };
            clearTimeout(timeout);
            timeout = setTimeout(later, wait);
        };
    }

    // 显示消息
    showMessage(message, type = 'info') {
        const messageDiv = document.createElement('div');
        messageDiv.className = `message ${type}`;
        messageDiv.textContent = message;
        
        document.body.insertBefore(messageDiv, document.body.firstChild);
        
        setTimeout(() => {
            messageDiv.remove();
        }, 5000);
    }

    // 开始自动刷新
    startAutoRefresh() {
        this.refreshInterval = setInterval(() => {
            if (this.currentPage === 'overview') {
                this.loadOverviewData();
            }
        }, 30000); // 每30秒刷新一次
    }

    // 停止自动刷新
    stopAutoRefresh() {
        if (this.refreshInterval) {
            clearInterval(this.refreshInterval);
            this.refreshInterval = null;
        }
    }
}

// 全局函数
function sendTestEmail() {
    const modal = document.getElementById('modal');
    const modalBody = document.getElementById('modalBody');
    
    modalBody.innerHTML = `
        <h3>发送测试邮件</h3>
        <form id="testEmailForm">
            <div class="form-group">
                <label for="testEmailTo">收件人邮箱:</label>
                <input type="email" id="testEmailTo" required>
            </div>
            <div class="form-group">
                <label for="testEmailSubject">邮件主题:</label>
                <input type="text" id="testEmailSubject" value="YYC³ 邮箱服务器测试邮件">
            </div>
            <div class="form-group">
                <label for="testEmailContent">邮件内容:</label>
                <textarea id="testEmailContent" rows="4">这是一封来自 YYC³ 邮箱服务器的测试邮件。如果您收到此邮件，说明邮箱服务器工作正常。</textarea>
            </div>
            <div class="form-group">
                <button type="submit" class="btn btn-primary">发送测试邮件</button>
                <button type="button" class="btn btn-secondary" onclick="closeModal()">取消</button>
            </div>
        </form>
    `;
    
    modal.style.display = 'block';
    
    document.getElementById('testEmailForm').addEventListener('submit', async (e) => {
        e.preventDefault();
        
        const formData = {
            to: document.getElementById('testEmailTo').value,
            subject: document.getElementById('testEmailSubject').value,
            content: document.getElementById('testEmailContent').value
        };
        
        try {
            const response = await fetch('/api/email/test', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify(formData)
            });
            
            const result = await response.json();
            
            if (result.success) {
                mailManager.showMessage('测试邮件发送成功！', 'success');
                closeModal();
            } else {
                mailManager.showMessage('测试邮件发送失败: ' + result.error, 'error');
            }
        } catch (error) {
            mailManager.showMessage('发送测试邮件时出错: ' + error.message, 'error');
        }
    });
}

function checkMailQueue() {
    fetch('/api/mail/queue')
        .then(response => response.json())
        .then(data => {
            if (data.success) {
                const modal = document.getElementById('modal');
                const modalBody = document.getElementById('modalBody');
                
                modalBody.innerHTML = `
                    <h3>邮件队列状态</h3>
                    <div class="queue-info">
                        <p><strong>队列中邮件数量:</strong> ${data.data.count}</p>
                        <p><strong>最后更新时间:</strong> ${new Date(data.data.lastUpdate).toLocaleString('zh-CN')}</p>
                    </div>
                    <button class="btn btn-secondary" onclick="closeModal()">关闭</button>
                `;
                
                modal.style.display = 'block';
            }
        })
        .catch(error => {
            mailManager.showMessage('检查邮件队列失败: ' + error.message, 'error');
        });
}

function restartServices() {
    if (confirm('确定要重启邮件服务吗？这可能会暂时中断邮件服务。')) {
        fetch('/api/service/restart', { method: 'POST' })
            .then(response => response.json())
            .then(data => {
                if (data.success) {
                    mailManager.showMessage('服务重启成功！', 'success');
                    setTimeout(() => {
                        mailManager.loadOverviewData();
                    }, 5000);
                } else {
                    mailManager.showMessage('服务重启失败: ' + data.error, 'error');
                }
            })
            .catch(error => {
                mailManager.showMessage('重启服务时出错: ' + error.message, 'error');
            });
    }
}

function viewLogs() {
    // 切换到日志页面
    document.querySelectorAll('.nav-link').forEach(l => l.classList.remove('active'));
    document.querySelector('a[href="#logs"]').classList.add('active');
    
    document.querySelectorAll('.page').forEach(p => p.classList.remove('active'));
    document.getElementById('logs').classList.add('active');
    
    mailManager.currentPage = 'logs';
    mailManager.loadLogs();
}

function refreshLogs() {
    mailManager.loadLogs();
}

function prevPage() {
    if (mailManager.currentLogPage > 1) {
        mailManager.currentLogPage--;
        mailManager.loadLogs();
    }
}

function nextPage() {
    mailManager.currentLogPage++;
    mailManager.loadLogs();
}

function saveSettings() {
    const settings = {
        adminEmail: document.getElementById('adminEmail').value,
        smtpHost: document.getElementById('smtpHost').value,
        smtpPort: document.getElementById('smtpPort').value,
        smtpUser: document.getElementById('smtpUser').value,
        enableTLS: document.getElementById('enableTLS').checked,
        enableSASL: document.getElementById('enableSASL').checked,
        enableSpamFilter: document.getElementById('enableSpamFilter').checked
    };
    
    fetch('/api/settings', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify(settings)
    })
    .then(response => response.json())
    .then(data => {
        if (data.success) {
            mailManager.showMessage('设置保存成功！', 'success');
        } else {
            mailManager.showMessage('设置保存失败: ' + data.error, 'error');
        }
    })
    .catch(error => {
        mailManager.showMessage('保存设置时出错: ' + error.message, 'error');
    });
}

function resetSettings() {
    if (confirm('确定要重置所有设置吗？')) {
        location.reload();
    }
}

function closeModal() {
    document.getElementById('modal').style.display = 'none';
}

// 初始化应用
let mailManager;
document.addEventListener('DOMContentLoaded', () => {
    mailManager = new MailServerManager();
});

// 点击模态框外部关闭
window.addEventListener('click', (event) => {
    const modal = document.getElementById('modal');
    if (event.target === modal) {
        closeModal();
    }
});
EOF

    log_success "前端管理界面创建完成"
}

# 创建邮件验证服务
create_email_verification_service() {
    log_step "创建邮件验证服务..."
    
    mkdir -p "$EMAIL_DIR/scripts"
    
    cat > "$EMAIL_DIR/scripts/monitor-mailqueue.sh" << 'EOF'
#!/bin/bash

# YYC³ 邮件队列监控脚本

LOG_FILE="/logs/mailqueue-monitor.log"

log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

while true; do
    # 检查邮件队列
    QUEUE_COUNT=$(postqueue -p | tail -n 1 | awk '{print $5}')
    
    if [[ "$QUEUE_COUNT" =~ ^[0-9]+$ ]]; then
        log_message "邮件队列中有 $QUEUE_COUNT 封邮件"
        
        # 如果队列中邮件过多，发送告警
        if [ "$QUEUE_COUNT" -gt 100 ]; then
            log_message "警告: 邮件队列中邮件数量过多 ($QUEUE_COUNT)"
        fi
    else
        log_message "邮件队列为空"
    fi
    
    # 每5分钟检查一次
    sleep 300
done
EOF

    chmod +x "$EMAIL_DIR/scripts/monitor-mailqueue.sh"
    
    log_success "邮件验证服务创建完成"
}

# 创建 SSL 证书
create_ssl_certificates() {
    log_step "创建 SSL 证书..."
    
    # 创建自签名证书（生产环境应使用 Let's Encrypt）
    mkdir -p "$EMAIL_DIR/ssl"
    
    # 生成私钥
    openssl genrsa -out "$EMAIL_DIR/ssl/mail.${DOMAIN}.key" 2048
    
    # 生成证书签名请求
    openssl req -new -key "$EMAIL_DIR/ssl/mail.${DOMAIN}.key" \
        -out "$EMAIL_DIR/ssl/mail.${DOMAIN}.csr" \
        -subj "/C=CN/ST=Henan/L=Luoyang/O=YYC3/OU=IT/CN=mail.${DOMAIN}"
    
    # 生成自签名证书
    openssl x509 -req -days 365 \
        -in "$EMAIL_DIR/ssl/mail.${DOMAIN}.csr" \
        -signkey "$EMAIL_DIR/ssl/mail.${DOMAIN}.key" \
        -out "$EMAIL_DIR/ssl/mail.${DOMAIN}.crt"
    
    # 设置权限
    chmod 600 "$EMAIL_DIR/ssl/mail.${DOMAIN}.key"
    chmod 644 "$EMAIL_DIR/ssl/mail.${DOMAIN}.crt"
    
    log_success "SSL 证书创建完成"
}

# 启动邮箱服务
start_email_services() {
    log_step "启动邮箱服务..."
    
    cd "$EMAIL_DIR"
    
    # 构建并启动服务
    docker-compose up -d
    
    # 等待服务启动
    sleep 10
    
    # 检查服务状态
    if docker-compose ps | grep -q "Up"; then
        log_success "邮箱服务启动成功"
    else
        log_error "邮箱服务启动失败"
        docker-compose logs
        return 1
    fi
}

# 配置防火墙
configure_firewall() {
    log_step "配置防火墙规则..."
    
    # 检查防火墙状态
    if command -v ufw &> /dev/null; then
        # Ubuntu/Debian UFW
        ufw allow 25/tcp    # SMTP
        ufw allow 587/tcp   # SMTP Submission
        ufw allow 143/tcp   # IMAP
        ufw allow 993/tcp   # IMAPS
        ufw allow 110/tcp   # POP3
        ufw allow 995/tcp   # POP3S
        ufw allow 8081/tcp  # Roundcube
        ufw allow 3003/tcp  # Mail Stats
        
        log_success "UFW 防火墙规则配置完成"
    elif command -v firewall-cmd &> /dev/null; then
        # CentOS/RHEL firewalld
        firewall-cmd --permanent --add-port=25/tcp
        firewall-cmd --permanent --add-port=587/tcp
        firewall-cmd --permanent --add-port=143/tcp
        firewall-cmd --permanent --add-port=993/tcp
        firewall-cmd --permanent --add-port=110/tcp
        firewall-cmd --permanent --add-port=995/tcp
        firewall-cmd --permanent --add-port=8081/tcp
        firewall-cmd --permanent --add-port=3003/tcp
        firewall-cmd --reload
        
        log_success "firewalld 防火墙规则配置完成"
    else
        log_warning "未检测到支持的防火墙，请手动配置端口"
    fi
}

# 测试邮箱服务
test_email_services() {
    log_step "测试邮箱服务..."
    
    # 测试 SMTP 连接
    if nc -z localhost 25; then
        log_success "SMTP 服务 (端口 25) 正常"
    else
        log_warning "SMTP 服务 (端口 25) 无法连接"
    fi
    
    if nc -z localhost 587; then
        log_success "SMTP Submission 服务 (端口 587) 正常"
    else
        log_warning "SMTP Submission 服务 (端口 587) 无法连接"
    fi
    
    # 测试 IMAP 连接
    if nc -z localhost 143; then
        log_success "IMAP 服务 (端口 143) 正常"
    else
        log_warning "IMAP 服务 (端口 143) 无法连接"
    fi
    
    if nc -z localhost 993; then
        log_success "IMAPS 服务 (端口 993) 正常"
    else
        log_warning "IMAPS 服务 (端口 993) 无法连接"
    fi
    
    # 测试 Web 界面
    if curl -s http://localhost:8081 > /dev/null; then
        log_success "Roundcube 网页邮箱正常"
    else
        log_warning "Roundcube 网页邮箱无法访问"
    fi
    
    if curl -s http://localhost:3003/health > /dev/null; then
        log_success "邮件统计服务正常"
    else
        log_warning "邮件统计服务无法访问"
    fi
}

# 显示完成信息
show_completion_info() {
    echo ""
    echo "=================================="
    log_success "🎉 邮箱服务器设置完成！"
    echo "=================================="
    echo ""
    
    log_info "📋 服务信息:"
    echo "  • 域名: ${DOMAIN}"
    echo "  • 服务器IP: ${SERVER_IP}"
    echo "  • SMTP 端口: 25, 587"
    echo "  • IMAP 端口: 143, 993"
    echo "  • POP3 端口: 110, 995"
    echo ""
    
    log_info "🌐 Web 界面:"
    echo "  • Roundcube 网页邮箱: http://${SERVER_IP}:8081"
    echo "  • 邮件统计管理: http://${SERVER_IP}:3003"
    echo ""
    
    log_info "📧 测试邮箱账户:"
    echo "  • admin@${DOMAIN} (密码: admin123)"
    echo "  • support@${DOMAIN} (密码: support123)"
    echo "  • noreply@${DOMAIN} (密码: noreply123)"
    echo ""
    
    log_info "🔧 管理命令:"
    echo "  • 查看服务状态: cd $EMAIL_DIR && docker-compose ps"
    echo "  • 查看日志: cd $EMAIL_DIR && docker-compose logs"
    echo "  • 重启服务: cd $EMAIL_DIR && docker-compose restart"
    echo "  • 停止服务: cd $EMAIL_DIR && docker-compose down"
    echo ""
    
    log_info "📚 配置文件位置:"
    echo "  • Postfix 配置: $EMAIL_DIR/config/main.cf"
    echo "  • Dovecot 配置: $EMAIL_DIR/config/dovecot.conf"
    echo "  • 用户配置: $EMAIL_DIR/config/users"
    echo "  • SSL 证书: $EMAIL_DIR/ssl/"
    echo ""
    
    log_info "🔒 安全提醒:"
    echo "  • 请及时修改默认密码"
    echo "  • 建议使用 Let's Encrypt 获取正式 SSL 证书"
    echo "  • 定期备份邮件数据和配置文件"
    echo "  • 监控服务器资源使用情况"
    echo ""
    
    log_info "详细设置日志: $LOG_FILE"
}

# 主函数
main() {
    # 重定向输出到日志文件
    exec > >(tee -a "$LOG_FILE")
    exec 2>&1
    
    show_welcome
    check_environment
    create_email_config
    create_docker_compose
    create_mail_stats_service
    create_frontend_interface
    create_email_verification_service
    create_ssl_certificates
    start_email_services
    configure_firewall
    test_email_services
    show_completion_info
    
    log_success "邮箱服务器设置完成！"
}

# 处理命令行参数
case "${1:-}" in
    "--help"|"-h")
        echo "YYC³ 邮箱服务器设置脚本"
        echo ""
        echo "用法: $0 [选项]"
        echo ""
        echo "选项:"
        echo "  --help, -h     显示帮助信息"
        echo "  --config       仅创建配置文件"
        echo "  --start        仅启动服务"
        echo "  --test         仅测试服务"
        echo "  --stop         停止服务"
        echo ""
        echo "默认执行完整设置流程"
        ;;
    "--config")
        check_environment
        create_email_config
        create_docker_compose
        ;;
    "--start")
        start_email_services
        ;;
    "--test")
        test_email_services
        ;;
    "--stop")
        cd "$EMAIL_DIR"
        docker-compose down
        log_success "邮箱服务已停止"
        ;;
    *)
        main "$@"
        ;;
esac