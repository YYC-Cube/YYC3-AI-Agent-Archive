---
@file: 配置指南.md
@description: YYC³-CLI 配置指南.md
@author: YanYuCloudCube Team
@version: v1.0.0
@created: 2026-02-17
@updated: 2026-02-17
@status: published
@tags: [文档],[YYC³-CLI]
---

> ***YanYuCloudCube***
> 言启象限 | 语枢未来
> ***Words Initiate Quadrants, Language Serves as Core for the Future***
> 万象归元于云枢 | 深栈智启新纪元
> ***All things converge in the cloud pivot; Deep stacks ignite a new era of intelligence***

---

# 补充异常监控与自动告警后的 yyc3-project.sh

以下是完整的升级后脚本，新增 **邮件+钉钉双渠道告警**，覆盖部署/构建/回滚等核心场景的异常监控，管理员邮箱默认配置为 `admin@0379.email`：

```bash
#!/bin/bash
set -e

# ===================== 核心配置（统一管理）=====================
# 团队基础配置
TEAM_NAME="yyc3"
DEFAULT_ENV="dev"
ADMIN_EMAIL="admin@0379.email"  # 管理员邮箱（默认告警接收人）
# 多机服务器列表（按环境划分）
declare -A SERVERS=(
  ["dev"]="localhost"
  ["test"]="test-server.yyc3.com"
  ["prod"]="prod-server-1.yyc3.com prod-server-2.yyc3.com"
)
# 多环境依赖清单（新增告警工具依赖）
declare -A DEPS=(
  ["dev"]="node>=18 docker>=20 git>=2.30 mailx openssl curl"
  ["test"]="node>=18 docker>=20 kubectl>=1.24 mailx openssl curl"
  ["prod"]="node>=18 docker>=20 kubectl>=1.24 sshpass>=1.06 mailx openssl curl"
)
# 多环境部署端口
declare -A DEPLOY_PORTS=(
  ["dev"]="3000"
  ["test"]="3000"
  ["prod"]="3000"
)

# ---------------------- 告警配置（关键！需用户根据实际情况修改）----------------------
# 邮件告警配置（支持SMTP，适配QQ/网易/企业邮箱）
SMTP_FROM="alarm@yyc3.com"          # 发件人邮箱
SMTP_SERVER="smtp.0379.email:587"   # SMTP服务器地址+端口（示例：smtp.qq.com:465）
SMTP_USER="alarm@yyc3.com"          # SMTP认证用户名（通常与发件人一致）
SMTP_PASS="your_smtp_auth_code"     # SMTP授权码（非登录密码，需在邮箱后台开启SMTP获取）

# 钉钉告警配置（需在钉钉群创建「自定义机器人」获取）
DINGTALK_WEBHOOK="https://oapi.dingtalk.com/robot/send"  # 钉钉机器人Webhook前缀
DINGTALK_TOKEN="your_dingtalk_robot_token"               # 机器人Access Token（从Webhook中提取）
DINGTALK_SECRET="your_dingtalk_robot_secret"             # 机器人加签密钥（安全设置开启「加签」后获取）
DINGTALK_AT_MOBILES="138xxxx8888,139xxxx9999"            # 需@的管理员手机号（多个用逗号分隔）

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# ===================== 帮助函数（子命令说明）=====================
show_help() {
  echo -e "${BLUE}===== yyc3团队一站式项目管理脚本（含异常告警）=====${NC}"
  echo "使用方式：./yyc3-project.sh <子命令> [参数1] [参数2]..."
  echo -e "\n子命令列表："
  echo "  init        <env>           初始化指定环境的项目配置（默认：dev）"
  echo "  update      <env> [force]   增量更新指定环境配置（force=强制覆盖）"
  echo "  check-env   <env>           检查指定环境的依赖和连通性（默认：dev）"
  echo "  sync-env    <env>           同步指定环境配置到多机（默认：dev）"
  echo "  ai-gen      <env> <agent> <prompt-file>  调用AI生成代码（agent=MCP/Tongyi/Kimi）"
  echo "  ai-review   <env> <code-file>           AI评审指定代码文件"
  echo "  build       <env>           构建指定环境的代码产物（默认：dev）"
  echo "  build-docker <env>          构建指定环境的Docker镜像（默认：dev）"
  echo "  deploy      <env> [ratio]   部署到指定环境（ratio=灰度比例，仅prod生效）"
  echo "  rollback    <env>           回滚指定环境到上一版本（默认：dev）"
  echo "  test-alert  <type>          测试告警功能（type=email/dingtalk/all）"
  echo "  help                        显示本帮助信息"
  echo -e "\n示例："
  echo "  ./yyc3-project.sh init prod          # 初始化生产环境配置"
  echo "  ./yyc3-project.sh test-alert all     # 测试邮件+钉钉告警"
  echo "  ./yyc3-project.sh deploy prod 50     # 灰度50%部署生产环境"
}

# ===================== 告警核心函数（新增）=====================
### 1. 发送邮件告警
send_email_alert() {
  local alert_title="$1"
  local alert_content="$2"
  local recipient="${3:-$ADMIN_EMAIL}"

  # 构造邮件内容（含详细上下文）
  local email_body="
【yyc3团队项目告警】
告警时间：$(date +"%Y-%m-%d %H:%M:%S")
告警标题：${alert_title}
告警详情：
${alert_content}
脚本路径：$(pwd)/$(basename "$0")
执行用户：$(whoami)
服务器IP：$(hostname -I | awk '{print $1}')
"

  # 使用SMTP发送邮件（兼容不同Linux发行版）
  echo -e "${email_body}" | mailx -v \
    -s "[${TEAM_NAME}告警] ${alert_title}" \
    -r "${SMTP_FROM}" \
    -S smtp="${SMTP_SERVER}" \
    -S smtp-auth=login \
    -S smtp-auth-user="${SMTP_USER}" \
    -S smtp-auth-password="${SMTP_PASS}" \
    -S ssl-verify=ignore \
    "${recipient}" 2>/dev/null

  # 校验邮件发送结果
  if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ 邮件告警已发送至：${recipient}${NC}"
  else
    echo -e "${RED}❌ 邮件告警发送失败，请检查SMTP配置！${NC}"
  fi
}

### 2. 发送钉钉告警（支持加签安全验证）
send_dingtalk_alert() {
  local alert_title="$1"
  local alert_content="$2"

  # 生成钉钉加签参数（毫秒级时间戳+HmacSHA256签名）
  local timestamp=$(date +%s%3N)
  local string_to_sign="${timestamp}\n${DINGTALK_SECRET}"
  # 计算Base64编码的签名并URL编码
  local sign=$(echo -n "${string_to_sign}" | openssl dgst -hmac "${DINGTALK_SECRET}" -sha256 -binary | base64)
  sign=$(echo "${sign}" | sed 's/+/%2B/g' | sed 's/\//%2F/g' | sed 's/=/%3D/g')

  # 构造钉钉消息内容（Markdown格式，支持@指定人）
  local dingtalk_content="#### 【yyc3团队项目告警】\n"
  dingtalk_content+="> 告警时间：$(date +"%Y-%m-%d %H:%M:%S")\n"
  dingtalk_content+="> 告警标题：${alert_title}\n"
  dingtalk_content+="> 告警详情：\n"
  dingtalk_content+="> ${alert_content//$'\n'/'\n>'}\n"
  dingtalk_content+="> 脚本路径：$(pwd)/$(basename "$0")\n"
  dingtalk_content+="> 执行用户：$(whoami)\n"
  dingtalk_content+="> 服务器IP：$(hostname -I | awk '{print $1}')\n"
  dingtalk_content+="@${DINGTALK_AT_MOBILES//,/ @}"  # @多个管理员

  # 构造JSON请求体
  local json_data=$(cat << EOF
{
  "msgtype": "markdown",
  "markdown": {
    "title": "[${TEAM_NAME}告警] ${alert_title}",
    "text": "${dingtalk_content}"
  },
  "at": {
    "atMobiles": ["${DINGTALK_AT_MOBILES//,/","}"],
    "isAtAll": false
  }
}
EOF
  )

  # 调用钉钉机器人API发送告警
  curl -s -X POST \
    "${DINGTALK_WEBHOOK}?access_token=${DINGTALK_TOKEN}&timestamp=${timestamp}&sign=${sign}" \
    -H "Content-Type: application/json" \
    -d "${json_data}" 2>/dev/null

  # 校验钉钉发送结果
  if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ 钉钉告警已发送至指定群聊（@管理员）${NC}"
  else
    echo -e "${RED}❌ 钉钉告警发送失败，请检查Webhook/Secret配置！${NC}"
  fi
}

### 3. 统一告警触发入口（支持双渠道同时发送）
trigger_alert() {
  local alert_type="$1"  # 告警类型：build/deploy/rollback/ai-gen等
  local error_msg="$2"   # 错误详情
  local env="${3:-$DEFAULT_ENV}"  # 关联环境
  local server="${4:-""}" # 关联服务器（多机部署时使用）

  # 构造告警标题和详情
  local alert_title="${alert_type}失败（${env}环境）"
  local alert_content="环境：${env}\n操作：${alert_type}\n错误信息：${error_msg}"
  [ -n "${server}" ] && alert_content+="\n故障服务器：${server}"

  # 发送告警（根据配置选择渠道）
  echo -e "\n${RED}⚠️  触发${alert_title}，启动告警通知...${NC}"
  send_email_alert "${alert_title}" "${alert_content}"
  send_dingtalk_alert "${alert_title}" "${alert_content}"
}

# ===================== 核心功能函数（升级告警触发）=====================

# 1. 初始化项目配置（init子命令）
init_project() {
  local ENV=${1:-$DEFAULT_ENV}
  echo -e "${GREEN}===== 初始化${TEAM_NAME}团队${ENV}环境配置 =====${NC}"

  # 步骤1：创建目录结构
  mkdir -p .vscode .husky .github/workflows scripts/{env,ai,deploy} logs/${ENV} tmp/${ENV}
  echo -e "✅ 目录结构创建完成"

  # 步骤2：生成环境专属配置
  cat > .env.${ENV} << EOF
# ${TEAM_NAME}团队 ${ENV} 环境配置
TEAM_NAME=${TEAM_NAME}
ENV=${ENV}
# AI智能体配置（多智能体适配）
AI_AGENT_TYPE="MCP"
AI_AGENT_URL=http://localhost:8080/${ENV}
AI_AGENT_API_KEY=${TEAM_NAME}_${ENV}_api_key
# 数据库配置（多机适配）
DB_HOST=$(if [ "${ENV}" = "prod" ]; then echo "prod-db.${TEAM_NAME}.com"; else echo "localhost"; fi)
DB_USER=${TEAM_NAME}_${ENV}
# 多机监控配置
MONITOR_HOST=$(if [ "${ENV}" = "prod" ]; then echo "prod-monitor.${TEAM_NAME}.com"; else echo "localhost:9090"; fi)
EOF
  echo -e "✅ ${ENV}环境配置文件生成：.env.${ENV}"

  # 步骤3：生成AI智能体调用脚本
  cat > scripts/ai/ai-config.sh << EOF
#!/bin/bash
# ${TEAM_NAME}团队 AI智能体调用脚本（多智能体适配）
AI_AGENT=\${AI_AGENT_TYPE:-MCP}
case \$AI_AGENT in
  MCP)
    echo "调用MCP智能体：\${AI_AGENT_URL}"
    curl -X POST \${AI_AGENT_URL}/code-completion -H "X-API-KEY: \${AI_AGENT_API_KEY}" -d @-
    ;;
  Copilot)
    echo "调用Copilot智能体"
    ;;
  Tongyi)
    echo "调用通义千问智能体"
    ;;
  Kimi)
    echo "调用Kimi智能体"
    ;;
esac
EOF
  chmod +x scripts/ai/ai-config.sh
  echo -e "✅ AI智能体配置脚本生成：scripts/ai/ai-config.sh"

  # 步骤4：生成基础.gitignore
  cat > .gitignore << EOF
# 多环境敏感文件
.env.*
!/.env.example
# AI缓存
ai-cache/
# 多机部署临时文件
tmp/
logs/
# Docker镜像标签文件
.docker-image-tag.*
EOF
  echo -e "✅ .gitignore生成完成"

  echo -e "${GREEN}===== ${ENV}环境初始化完成 =====${NC}"
}

# 2. 增量更新配置（update子命令）
update_config() {
  local ENV=${1:-$DEFAULT_ENV}
  local FORCE=${2:-false}

  # 增量更新函数
  update_file() {
    local FILE_PATH=\$1
    local CONTENT=\$(cat)
    if [ -f "\$FILE_PATH" ] && [ "\$FORCE" != "force" ]; then
      read -p "📄 文件 \$FILE_PATH 已存在，是否覆盖？(y/N) " -n 1 -r
      echo
      if ! [[ \$REPLY =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}⏭️  跳过：\$FILE_PATH${NC}"
        return
      fi
    fi
    echo "\$CONTENT" > \$FILE_PATH
    echo -e "${GREEN}✅ 更新完成：\$FILE_PATH${NC}"
  }

  echo -e "${GREEN}===== 增量更新${TEAM_NAME}团队${ENV}环境配置 =====${NC}"

  # 更新AI智能体配置
  cat << EOF | update_file scripts/ai/ai-config.sh
#!/bin/bash
# ${TEAM_NAME}团队 AI智能体调用脚本（多智能体适配，已升级支持Kimi）
AI_AGENT=\${AI_AGENT_TYPE:-MCP}
case \$AI_AGENT in
  MCP)
    echo "调用MCP智能体：\${AI_AGENT_URL}"
    curl -X POST \${AI_AGENT_URL}/code-completion -H "X-API-KEY: \${AI_AGENT_API_KEY}" -d @-
    ;;
  Copilot)
    echo "调用Copilot智能体"
    ;;
  Tongyi)
    echo "调用通义千问智能体"
    ;;
  Kimi)
    echo "调用Kimi智能体"
    ;;
esac
EOF

  # 更新环境配置
  cat << EOF | update_file .env.${ENV}
# ${TEAM_NAME}团队 ${ENV} 环境配置（已升级）
TEAM_NAME=${TEAM_NAME}
ENV=${ENV}
AI_AGENT_TYPE="MCP"
AI_AGENT_URL=http://localhost:8080/${ENV}
AI_AGENT_API_KEY=${TEAM_NAME}_${ENV}_api_key
DB_HOST=$(if [ "${ENV}" = "prod" ]; then echo "prod-db.${TEAM_NAME}.com"; else echo "localhost"; fi)
DB_USER=${TEAM_NAME}_${ENV}
# 新增：多机监控配置
MONITOR_HOST=$(if [ "${ENV}" = "prod" ]; then echo "prod-monitor.${TEAM_NAME}.com"; else echo "localhost:9090"; fi)
EOF

  echo -e "${GREEN}===== ${ENV}环境配置增量更新完成 =====${NC}"
}

# 3. 检查环境依赖（check-env子命令，新增告警工具依赖检查）
check_env() {
  local ENV=${1:-$DEFAULT_ENV}
  echo -e "${GREEN}===== 检查${TEAM_NAME}团队${ENV}环境依赖 =====${NC}"

  # 解析依赖清单
  IFS=' ' read -ra DEPS_LIST <<< "\${DEPS[$ENV]}"
  for DEP in "\${DEPS_LIST[@]}"; do
    NAME=\$(echo \$DEP | cut -d'>=' -f1)
    MIN_VER=\$(echo \$DEP | cut -d'>=' -f2)
    
    # 检查是否安装
    if ! command -v \$NAME &> /dev/null; then
      echo -e "${RED}❌ \$NAME 未安装（${ENV}环境必需，告警功能依赖）${NC}"
      # 提示安装命令
      if [ "\$NAME" = "mailx" ]; then
        echo -e "💡 安装命令：CentOS -> yum install mailx；Ubuntu -> apt install heirloom-mailx"
      elif [ "\$NAME" = "openssl" ]; then
        echo -e "💡 安装命令：CentOS/Ubuntu -> yum install openssl / apt install openssl"
      elif [ "\$NAME" = "curl" ]; then
        echo -e "💡 安装命令：CentOS/Ubuntu -> yum install curl / apt install curl"
      fi
      exit 1
    fi
    
    # 检查版本（非核心工具跳过版本校验）
    if [[ ! "\$NAME" =~ ^(mailx|openssl|curl)$ ]]; then
      VER=\$(\$NAME --version 2>&1 | head -n1 | grep -oE '[0-9]+\.[0-9]+(\.[0-9]+)?' | head -n1)
      if [ "\$(echo -e "\$VER\n\$MIN_VER" | sort -V | head -n1)" != "\$MIN_VER" ]; then
        echo -e "${RED}❌ \$NAME 版本过低（当前：\$VER，要求：>=${MIN_VER}）${NC}"
        exit 1
      fi
    fi
    
    echo -e "${GREEN}✅ \$NAME 已安装（满足${ENV}环境要求）${NC}"
  done

  # 检查AI智能体连通性
  if [ -f ".env.${ENV}" ]; then
    AI_AGENT_URL=\$(grep AI_AGENT_URL .env.${ENV} | cut -d'=' -f2)
    if curl -s --head \$AI_AGENT_URL | head -n1 | grep "200 OK" > /dev/null; then
      echo -e "${GREEN}✅ AI智能体 \$AI_AGENT_URL 连通正常${NC}"
    else
      echo -e "${YELLOW}⚠️ AI智能体 \$AI_AGENT_URL 无法连通（非阻塞，仅提醒）${NC}"
    fi
  else
    echo -e "${YELLOW}⚠️ 未找到.env.${ENV}，跳过AI智能体检查${NC}"
  fi

  echo -e "${GREEN}===== ${ENV}环境依赖检查通过 =====${NC}"
}

# 4. 同步环境到多机（sync-env子命令）
sync_env() {
  local ENV=${1:-$DEFAULT_ENV}
  local SERVER_LIST=\${SERVERS[$ENV]}
  local USER="${TEAM_NAME}-admin"

  echo -e "${GREEN}===== 同步${TEAM_NAME}团队${ENV}环境到多机：${SERVER_LIST} =====${NC}"
  for SERVER in \$SERVER_LIST; do
    echo -e "\n📡 同步到服务器：\$SERVER"
    # 同步环境配置文件
    if [ -f ".env.${ENV}" ]; then
      scp .env.${ENV} \${USER}@\${SERVER}:/opt/${TEAM_NAME}-project/.env.${ENV} || {
        trigger_alert "sync-env" "服务器\$SERVER 配置同步失败（SSH连接超时/权限不足）" \$ENV \$SERVER
        exit 1
      }
    else
      echo -e "${YELLOW}⚠️ 未找到.env.${ENV}，跳过配置同步${NC}"
    fi
    # 同步AI脚本
    scp -r scripts/ai/ \${USER}@\${SERVER}:/opt/${TEAM_NAME}-project/scripts/ || {
      trigger_alert "sync-env" "服务器\$SERVER AI脚本同步失败" \$ENV \$SERVER
      exit 1
    }
    # 远程初始化目录
    ssh \${USER}@\${SERVER} "cd /opt/${TEAM_NAME}-project && chmod +x scripts/ai/ai-config.sh && mkdir -p logs/${ENV} tmp/${ENV}" || {
      trigger_alert "sync-env" "服务器\$SERVER 远程目录初始化失败" \$ENV \$SERVER
      exit 1
    }
    echo -e "${GREEN}✅ \$SERVER 同步完成${NC}"
  done

  echo -e "\n${GREEN}===== 所有服务器环境同步完成 =====${NC}"
}

# 5. AI代码生成（ai-gen子命令，新增失败告警）
ai_code_gen() {
  local ENV=${1:-$DEFAULT_ENV}
  local AI_AGENT=${2:-"MCP"}
  local PROMPT_FILE=${3:-"prompt.txt"}

  echo -e "${GREEN}===== 调用${AI_AGENT}智能体生成${ENV}环境代码 =====${NC}"

  # 校验prompt文件
  if [ ! -f "\$PROMPT_FILE" ]; then
    local error_msg="未找到prompt文件：\$PROMPT_FILE（请创建文件并写入生成指令）"
    trigger_alert "ai-gen" "\$error_msg" \$ENV
    echo -e "${RED}❌ \$error_msg${NC}"
    exit 1
  fi

  # 加载环境配置
  if [ -f ".env.${ENV}" ]; then
    source .env.${ENV}
  else
    local error_msg="未找到.env.${ENV}（请先执行init子命令初始化环境）"
    trigger_alert "ai-gen" "\$error_msg" \$ENV
    echo -e "${RED}❌ \$error_msg${NC}"
    exit 1
  fi

  # 读取生成指令
  PROMPT=\$(cat \$PROMPT_FILE)

  # 多智能体调用逻辑
  case \$AI_AGENT in
    MCP)
      RESPONSE=\$(curl -s -X POST \$AI_AGENT_URL/code-completion \
        -H "X-API-KEY: \$AI_AGENT_API_KEY" \
        -H "Content-Type: application/json" \
        -d "{\"prompt\":\"\$PROMPT\", \"team\":\"\$TEAM_NAME\", \"env\":\"\$ENV\"}") || {
        local error_msg="MCP智能体调用失败（URL：\$AI_AGENT_URL，API_KEY：\$AI_AGENT_API_KEY）"
        trigger_alert "ai-gen" "\$error_msg" \$ENV
        exit 1
      }
      ;;
    Tongyi)
      RESPONSE=\$(curl -s -X POST https://dashscope.aliyuncs.com/api/v1/services/aigc/text-generation/generation \
        -H "Authorization: Bearer \$AI_AGENT_API_KEY" \
        -H "Content-Type: application/json" \
        -d "{\"model\":\"qwen-turbo\", \"input\":{\"messages\":[{\"role\":\"user\",\"content\":\"\$PROMPT\"}]}}") || {
        local error_msg="通义千问智能体调用失败（API_KEY无效/网络超时）"
        trigger_alert "ai-gen" "\$error_msg" \$ENV
        exit 1
      }
      ;;
    Kimi)
      echo -e "${YELLOW}⚠️ Kimi智能体调用逻辑待补充${NC}"
      exit 1
      ;;
    *)
      local error_msg="不支持的AI智能体：\$AI_AGENT（仅支持MCP/Tongyi/Kimi）"
      trigger_alert "ai-gen" "\$error_msg" \$ENV
      echo -e "${RED}❌ \$error_msg${NC}"
      exit 1
      ;;
  esac

  # 提取代码并写入文件
  CODE=\$(echo \$RESPONSE | jq -r '.data.code // .output.text // "// 未提取到有效代码"')
  OUTPUT_FILE="src/ai-gen-$(date +%Y%m%d%H%M%S).ts"
  echo "\$CODE" > \$OUTPUT_FILE
  echo -e "✅ 代码已生成到：\$OUTPUT_FILE"

  # 语法校验+格式化
  if command -v npx &> /dev/null; then
    echo -e "🔍 校验生成代码语法..."
    if npx tsc --noEmit \$OUTPUT_FILE; then
      echo -e "${GREEN}✅ 代码语法校验通过${NC}"
    else
      local error_msg="生成代码语法校验失败（文件：\$OUTPUT_FILE）"
      trigger_alert "ai-gen" "\$error_msg" \$ENV
      echo -e "${RED}❌ \$error_msg，请手动调整${NC}"
    fi
    # 格式化代码
    npx prettier --write \$OUTPUT_FILE
    echo -e "${GREEN}✅ 代码已按${TEAM_NAME}规范格式化${NC}"
  else
    echo -e "${YELLOW}⚠️ 未安装npx，跳过语法校验和格式化${NC}"
  fi

  echo -e "${GREEN}===== AI代码生成完成 =====${NC}"
}

# 6. AI代码评审（ai-review子命令，新增失败告警）
ai_code_review() {
  local ENV=${1:-$DEFAULT_ENV}
  local CODE_FILE=${2:-"src/index.ts"}

  echo -e "${GREEN}===== AI评审${ENV}环境代码：\$CODE_FILE =====${NC}"

  # 校验代码文件
  if [ ! -f "\$CODE_FILE" ]; then
    local error_msg="未找到代码文件：\$CODE_FILE"
    trigger_alert "ai-review" "\$error_msg" \$ENV
    echo -e "${RED}❌ \$error_msg${NC}"
    exit 1
  fi

  # 加载环境配置
  if [ -f ".env.${ENV}" ]; then
    source .env.${ENV}
  else
    local error_msg="未找到.env.${ENV}（请先执行init子命令初始化环境）"
    trigger_alert "ai-review" "\$error_msg" \$ENV
    echo -e "${RED}❌ \$error_msg${NC}"
    exit 1
  fi

  # 读取代码内容
  CODE_CONTENT=\$(cat \$CODE_FILE)
  # 构建评审指令
  REVIEW_PROMPT="作为${TEAM_NAME}团队的代码评审专家，请评审以下代码：
1. 是否符合团队ESLint/Prettier规范
2. 是否存在权限漏洞（如硬编码密钥、未校验RBAC权限）
3. 是否符合Docker容器权限规范
4. 输出结构化评审报告（仅JSON格式）

代码内容：
\$CODE_CONTENT"

  # 调用AI评审（失败触发告警）
  RESPONSE=\$(curl -s -X POST \$AI_AGENT_URL/code-review \
    -H "X-API-KEY: \$AI_AGENT_API_KEY" \
    -H "Content-Type: application/json" \
    -d "{\"prompt\":\"\$REVIEW_PROMPT\", \"team\":\"\$TEAM_NAME\"}") || {
    local error_msg="AI评审调用失败（URL：\$AI_AGENT_URL，API_KEY：\$AI_AGENT_API_KEY）"
    trigger_alert "ai-review" "\$error_msg" \$ENV
    exit 1
  }

  # 保存评审报告
  REPORT_FILE="logs/${ENV}/code-review-$(basename \$CODE_FILE)-$(date +%Y%m%d%H%M%S).json"
  mkdir -p logs/${ENV}
  echo \$RESPONSE | jq . > \$REPORT_FILE

  # 输出关键问题
  ERRORS=\$(echo \$RESPONSE | jq -r '.errors | length // 0')
  if [ "\$ERRORS" -gt 0 ]; then
    local error_msg="发现\$ERRORS个严重问题：$(echo \$RESPONSE | jq -r '.errors[] | .message' | tr '\n' '; ')"
    trigger_alert "ai-review" "\$error_msg" \$ENV  # 评审发现严重问题触发告警
    echo -e "${RED}❌ 发现\$ERRORS个严重问题：${NC}"
    echo \$RESPONSE | jq -r '.errors[] | "- \(.message)（行：\(.line)）"'
  else
    echo -e "${GREEN}✅ 代码评审通过，无严重问题${NC}"
  fi

  echo -e "✅ 完整评审报告已保存到：\$REPORT_FILE"
}

# 7. 构建代码（build子命令，新增失败告警）
build_project() {
  local ENV=${1:-$DEFAULT_ENV}
  # 构建参数（多环境差异化）
  declare -A BUILD_ARGS=(
    ["dev"]="--source-map --watch"
    ["test"]="--source-map"
    ["prod"]="--minify --no-source-map"
  )

  echo -e "${GREEN}===== 构建${TEAM_NAME}团队${ENV}环境代码 =====${NC}"
  # 前置检查
  ./\$0 check-env \$ENV

  # 清理旧产物
  rm -rf dist/${ENV}
  mkdir -p dist/${ENV}

  # 差异化构建（失败触发告警）
  if command -v npx &> /dev/null; then
    npx tsc \${BUILD_ARGS[$ENV]} --outDir dist/${ENV} || {
      local error_msg="代码构建失败（TS编译错误，环境：\$ENV，参数：\${BUILD_ARGS[$ENV]}）"
      trigger_alert "build" "\$error_msg" \$ENV
      exit 1
    }
  else
    local error_msg="未安装npx，无法执行构建（环境：\$ENV）"
    trigger_alert "build" "\$error_msg" \$ENV
    echo -e "${RED}❌ \$error_msg${NC}"
    exit 1
  fi

  # 复制配置文件
  if [ -f ".env.${ENV}" ]; then
    cp .env.${ENV} dist/${ENV}/.env
  fi
  cp -r scripts/ai/ dist/${ENV}/scripts/

  # 校验产物（失败触发告警）
  if [ -f "dist/${ENV}/index.js" ]; then
    echo -e "${GREEN}✅ ${ENV}环境构建完成，产物路径：dist/${ENV}${NC}"
  else
    local error_msg="构建产物校验失败（未找到dist/${ENV}/index.js，环境：\$ENV）"
    trigger_alert "build" "\$error_msg" \$ENV
    echo -e "${RED}❌ ${ENV}环境构建失败${NC}"
    exit 1
  fi
}

# 8. 构建Docker镜像（build-docker子命令，新增失败告警）
build_docker() {
  local ENV=${1:-$DEFAULT_ENV}
  local IMAGE_TAG="${TEAM_NAME}-app:${ENV}-$(date +%Y%m%d%H%M%S)"
  local DOCKERFILE="Dockerfile.${ENV}"

  echo -e "${GREEN}===== 构建${TEAM_NAME}团队${ENV}环境Docker镜像 =====${NC}"

  # 兜底使用默认Dockerfile
  if [ ! -f "\$DOCKERFILE" ]; then
    DOCKERFILE="Dockerfile"
    echo -e "${YELLOW}⚠️ 未找到${DOCKERFILE}，使用默认Dockerfile${NC}"
  fi

  # 构建镜像（失败触发告警）
  docker build -t \$IMAGE_TAG -f \$DOCKERFILE \
    --build-arg ENV=\$ENV \
    --build-arg TEAM_NAME=\$TEAM_NAME \
    . || {
    local error_msg="Docker镜像构建失败（Dockerfile：\$DOCKERFILE，环境：\$ENV）"
    trigger_alert "build-docker" "\$error_msg" \$ENV
    exit 1
  }

  # 校验镜像（失败触发告警）
  if docker images | grep "\$IMAGE_TAG" > /dev/null; then
    echo -e "${GREEN}✅ 镜像构建成功：\$IMAGE_TAG${NC}"
    # 推送生产环境镜像（失败触发告警）
    if [ "\$ENV" = "prod" ]; then
      echo -e "📤 推送生产环境镜像到仓库..."
      docker tag \$IMAGE_TAG registry.${TEAM_NAME}.com/${TEAM_NAME}-app:${ENV} || {
        local error_msg="镜像标签失败（镜像：\$IMAGE_TAG，仓库：registry.${TEAM_NAME}.com）"
        trigger_alert "build-docker" "\$error_msg" \$ENV
        exit 1
      }
      docker push registry.${TEAM_NAME}.com/${TEAM_NAME}-app:${ENV} || {
        local error_msg="镜像推送失败（仓库：registry.${TEAM_NAME}.com，网络/权限问题）"
        trigger_alert "build-docker" "\$error_msg" \$ENV
        exit 1
      }
      echo -e "${GREEN}✅ 镜像推送完成${NC}"
    fi
    # 保存镜像标签
    echo \$IMAGE_TAG > .docker-image-tag.${ENV}
    # 备份上一版本标签（用于回滚）
    if [ -f ".docker-image-tag.${ENV}" ]; then
      cp .docker-image-tag.${ENV} .docker-image-tag.${ENV}.prev
    fi
    echo -e "✅ 镜像标签已保存到：.docker-image-tag.${ENV}"
  else
    local error_msg="镜像构建校验失败（未找到镜像：\$IMAGE_TAG，环境：\$ENV）"
    trigger_alert "build-docker" "\$error_msg" \$ENV
    echo -e "${RED}❌ 镜像构建失败${NC}"
    exit 1
  fi
}

# 9. 部署项目（deploy子命令，新增失败告警）
deploy_project() {
  local ENV=${1:-$DEFAULT_ENV}
  local CANARY_RATIO=${2:-100}
  local SERVER_LIST=\${SERVERS[$ENV]}
  local PORT=\${DEPLOY_PORTS[$ENV]}
  local USER="${TEAM_NAME}-admin"

  echo -e "${GREEN}===== 部署${TEAM_NAME}团队${ENV}环境（灰度比例：\$CANARY_RATIO%）=====${NC}"

  # 校验镜像标签（失败触发告警）
  if [ ! -f ".docker-image-tag.${ENV}" ]; then
    local error_msg="未找到镜像标签文件（请先执行build-docker子命令）"
    trigger_alert "deploy" "\$error_msg" \$ENV
    echo -e "${RED}❌ \$error_msg${NC}"
    exit 1
  fi
  local IMAGE_TAG=\$(cat .docker-image-tag.${ENV})

  # 灰度发布处理（仅生产环境）
  if [ "\$ENV" = "prod" ] && [ "\$CANARY_RATIO" -lt 100 ]; then
    SERVER_LIST=\$(echo \$SERVER_LIST | tr ' ' '\n' | shuf -n \$((\$(echo \$SERVER_LIST | wc -w) * CANARY_RATIO / 100)) | tr '\n' ' ')
    echo -e "${YELLOW}⚠️  生产环境灰度发布，部署目标：\$SERVER_LIST${NC}"
  fi

  # 批量部署（单服务器失败触发告警，不中断整体部署）
  for SERVER in \$SERVER_LIST; do
    echo -e "\n📡 部署到：\$SERVER:\$PORT"
    # 停止旧容器
    ssh \${USER}@\${SERVER} "docker stop ${TEAM_NAME}-app-${ENV} || true && docker rm ${TEAM_NAME}-app-${ENV} || true" || {
      trigger_alert "deploy" "旧容器停止失败（服务器：\$SERVER，容器名：${TEAM_NAME}-app-${ENV}）" \$ENV \$SERVER
      continue  # 跳过当前服务器，继续部署其他节点
    }
    # 启动新容器（失败触发告警）
    ssh \${USER}@\${SERVER} "docker run -d --name ${TEAM_NAME}-app-${ENV} \
      -p \$PORT:3000 \
      --env-file /opt/${TEAM_NAME}-project/.env.${ENV} \
      --user 1000:1000 \
      --restart unless-stopped \
      \$IMAGE_TAG" || {
      trigger_alert "deploy" "新容器启动失败（服务器：\$SERVER，镜像：\$IMAGE_TAG）" \$ENV \$SERVER
      continue
    }
    # 健康检查（失败触发告警并回滚）
    sleep 5
    if curl -s http://\$SERVER:\$PORT/health | grep "ok" > /dev/null; then
      echo -e "${GREEN}✅ \$SERVER:\$PORT 部署成功，健康检查通过${NC}"
    else
      local error_msg="健康检查失败（服务器：\$SERVER:\$PORT，未返回ok）"
      trigger_alert "deploy" "\$error_msg" \$ENV \$SERVER
      # 生产环境自动回滚
      if [ "\$ENV" = "prod" ]; then
        echo -e "🔄 生产环境部署失败，执行回滚..."
        ./\$0 rollback \$ENV \$SERVER
      fi
    fi
  done

  echo -e "\n${GREEN}===== ${ENV}环境部署完成（失败节点已触发告警）=====${NC}"
}

# 10. 回滚项目（rollback子命令，新增失败告警）
rollback_project() {
  local ENV=${1:-$DEFAULT_ENV}
  local TARGET_SERVER=${2:-""}  # 可选：指定单个回滚服务器
  local SERVER_LIST=\${TARGET_SERVER:-${SERVERS[$ENV]}}
  local PORT=\${DEPLOY_PORTS[$ENV]}
  local USER="${TEAM_NAME}-admin"

  echo -e "${GREEN}===== 回滚${TEAM_NAME}团队${ENV}环境 =====${NC}"

  # 读取上一版本镜像标签
  if [ -f ".docker-image-tag.${ENV}.prev" ]; then
    local PREV_IMAGE_TAG=\$(cat .docker-image-tag.${ENV}.prev)
  else
    PREV_IMAGE_TAG="registry.${TEAM_NAME}.com/${TEAM_NAME}-app:${ENV}-latest"
    echo -e "${YELLOW}⚠️  无历史镜像标签，使用默认镜像：\$PREV_IMAGE_TAG${NC}"
  fi

  # 批量回滚（失败触发告警）
  for SERVER in \$SERVER_LIST; do
    echo -e "\n🔄 回滚到：\$SERVER:\$PORT"
    # 停止当前容器
    ssh \${USER}@\${SERVER} "docker stop ${TEAM_NAME}-app-${ENV} || true && docker rm ${TEAM_NAME}-app-${ENV} || true" || {
      trigger_alert "rollback" "旧容器停止失败（服务器：\$SERVER）" \$ENV \$SERVER
      continue
    }
    # 启动上一版本（失败触发告警）
    ssh \${USER}@\${SERVER} "docker run -d --name ${TEAM_NAME}-app-${ENV} \
      -p \$PORT:3000 \
      --env-file /opt/${TEAM_NAME}-project/.env.${ENV} \
      --user 1000:1000 \
      --restart unless-stopped \
      \$PREV_IMAGE_TAG" || {
      local error_msg="回滚容器启动失败（服务器：\$SERVER，镜像：\$PREV_IMAGE_TAG）"
      trigger_alert "rollback" "\$error_msg" \$ENV \$SERVER
      continue
    }
    # 健康检查（失败触发告警）
    sleep 5
    if curl -s http://\$SERVER:\$PORT/health | grep "ok" > /dev/null; then
      echo -e "${GREEN}✅ \$SERVER:\$PORT 回滚成功${NC}"
    else
      local error_msg="回滚后健康检查失败（服务器：\$SERVER:\$PORT）"
      trigger_alert "rollback" "\$error_msg" \$ENV \$SERVER
      echo -e "${RED}❌ \$SERVER:\$PORT 回滚失败，请手动处理${NC}"
    fi
  done

  echo -e "\n${GREEN}===== ${ENV}环境回滚完成（失败节点已触发告警）=====${NC}"
}

# 11. 测试告警功能（新增test-alert子命令）
test_alert() {
  local alert_type="${1:-"all"}"
  local test_title="告警功能测试"
  local test_content="这是yyc3-project.sh脚本的告警测试消息，用于验证邮件和钉钉告警通道是否正常。\n测试场景：手动触发测试\n测试时间：$(date +"%Y-%m-%d %H:%M:%S")"

  echo -e "${BLUE}===== 启动告警功能测试（类型：${alert_type}）=====${NC}"
  case "${alert_type}" in
    email)
      send_email_alert "${test_title}" "${test_content}"
      ;;
    dingtalk)
      send_dingtalk_alert "${test_title}" "${test_content}"
      ;;
    all)
      send_email_alert "${test_title}" "${test_content}"
      send_dingtalk_alert "${test_title}" "${test_content}"
      ;;
    *)
      echo -e "${RED}❌ 未知测试类型：${alert_type}（支持：email/dingtalk/all）${NC}"
      exit 1
      ;;
  esac
  echo -e "${GREEN}===== 告警测试完成，请查看接收结果 =====${NC}"
}

# ===================== 主逻辑（子命令解析，新增test-alert）=====================
main() {
  if [ $# -eq 0 ]; then
    show_help
    exit 0
  fi

  # 解析子命令
  case "$1" in
    init)
      init_project "$2"
      ;;
    update)
      update_config "$2" "$3"
      ;;
    check-env)
      check_env "$2"
      ;;
    sync-env)
      sync_env "$2"
      ;;
    ai-gen)
      ai_code_gen "$2" "$3" "$4"
      ;;
    ai-review)
      ai_code_review "$2" "$3"
      ;;
    build)
      build_project "$2"
      ;;
    build-docker)
      build_docker "$2"
      ;;
    deploy)
      deploy_project "$2" "$3"
      ;;
    rollback)
      rollback_project "$2" "$3"
      ;;
    test-alert)
      test_alert "$2"
      ;;
    help)
      show_help
      ;;
    *)
      echo -e "${RED}❌ 未知子命令：$1${NC}"
      show_help
      exit 1
      ;;
  esac
}

# 执行主逻辑
main "$@"
```

---

## 核心升级说明

### 1. 新增告警功能亮点

- **双渠道告警**：同时支持邮件（默认`admin@0379.email`）和钉钉，确保告警不遗漏
- **安全加固**：钉钉告警支持「加签」验证，避免机器人被恶意调用
- **精准触发**：覆盖8大核心场景（部署/回滚/构建/镜像构建/AI生成/AI评审/环境同步/代码评审严重问题）
- **详细上下文**：告警信息包含时间、环境、服务器IP、错误详情，无需查日志快速定位问题
- **测试便捷**：新增`test-alert`子命令，可单独测试邮件/钉钉告警通道是否正常

### 2. 关键配置修改（必须操作！）

打开脚本找到「告警配置」区域，根据实际环境修改以下参数：

```bash
# 邮件SMTP配置（示例为0379.email，需替换为实际邮箱信息）
SMTP_FROM="alarm@yyc3.com"          # 发件人邮箱（如：yyc3-alarm@0379.email）
SMTP_SERVER="smtp.0379.email:587"   # SMTP服务器（QQ邮箱：smtp.qq.com:465；网易：smtp.163.com:25）
SMTP_USER="alarm@yyc3.com"          # SMTP认证用户名（与发件人一致）
SMTP_PASS="your_smtp_auth_code"     # SMTP授权码（非登录密码，需在邮箱后台开启SMTP获取）

# 钉钉机器人配置（需在钉钉群创建「自定义机器人」）
DINGTALK_TOKEN="your_dingtalk_robot_token"   # 机器人Access Token（从Webhook中提取：https://oapi.dingtalk.com/robot/send?access_token=XXX）
DINGTALK_SECRET="your_dingtalk_robot_secret" # 机器人加签密钥（安全设置开启「加签」后获取）
DINGTALK_AT_MOBILES="138xxxx8888"   # 需@的管理员手机号（多个用逗号分隔）
```

### 3. 钉钉机器人创建步骤

1. 打开钉钉群 → 群设置 → 智能群助手 → 添加机器人 → 自定义机器人
2. 输入机器人名称 → 勾选「我已阅读并同意」→ 点击「完成」
3. 安全设置选择「加签」→ 复制生成的「密钥」（填入`DINGTALK_SECRET`）
4. 复制机器人「Webhook地址」→ 提取`access_token`参数值（填入`DINGTALK_TOKEN`）
5. 点击「完成」，机器人添加成功

### 4. 依赖安装（首次使用）

```bash
# CentOS/RHEL
sudo yum install -y mailx openssl curl

# Ubuntu/Debian
sudo apt install -y heirloom-mailx openssl curl
```

### 5. 核心使用示例

| 需求场景                | 执行命令                                      |
|-------------------------|-----------------------------------------------|
| 测试邮件+钉钉告警       | `./yyc3-project.sh test-alert all`            |
| 仅测试钉钉告警          | `./yyc3-project.sh test-alert dingtalk`       |
| 部署生产环境（失败告警）| `./yyc3-project.sh deploy prod 50`            |
| 回滚测试环境（失败告警）| `./yyc3-project.sh rollback test`             |
| 构建开发环境（失败告警）| `./yyc3-project.sh build dev`                 |

---
