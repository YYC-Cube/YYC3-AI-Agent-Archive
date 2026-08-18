#!/bin/bash
#
# @fileoverview YYC³ AI服务管理脚本
# @description 管理AI模型服务、智能对话、知识库等AI相关功能
# @author YYC³
# @version 1.0.0
# @created 2025-01-30
# @modified 2025-01-30
# @copyright Copyright (c) 2025 YYC³
# @license MIT

set -euo pipefail

# 配置常量
readonly AI_LOG_DIR="/var/log/yyc3-ai"
readonly AI_MODELS_DIR="/Users/yanyu/yyc3-management/ai-models"
readonly OLLAMA_HOST="http://localhost:11434"

# 颜色定义
readonly COLOR_RED='\033[0;31m'
readonly COLOR_GREEN='\033[0;32m'
readonly COLOR_YELLOW='\033[1;33m'
readonly COLOR_BLUE='\033[0;34m'
readonly COLOR_CYAN='\033[0;36m'
readonly COLOR_RESET='\033[0m'

# 显示用法
function show_usage() {
    echo -e "${COLOR_CYAN}用法:${COLOR_RESET}"
    echo "  $0 status        - 检查AI服务状态"
    echo "  $0 start         - 启动AI服务"
    echo "  $0 stop          - 停止AI服务"
    echo "  $0 models        - 管理AI模型"
    echo "  $0 chat          - 启动智能对话"
    echo "  $0 kb            - 管理知识库"
    echo ""
}

# 检查AI服务状态
function check_ai_status() {
    echo -e "${COLOR_CYAN}🤖 检查YYC³ AI服务状态...${COLOR_RESET}"
    
    # 检查Ollama服务
    if curl -s "$OLLAMA_HOST/api/tags" &> /dev/null; then
        echo -e "  ${COLOR_GREEN}✅ Ollama服务运行中${COLOR_RESET}"
        
        # 获取已安装模型
        local models=$(curl -s "$OLLAMA_HOST/api/tags" | jq -r '.models[].name' 2>/dev/null || echo "")
        if [[ -n "$models" ]]; then
            echo -e "  ${COLOR_GREEN}✅ 已安装模型:${COLOR_RESET}"
            echo "$models" | while read model; do
                echo -e "    ${COLOR_BLUE}• $model${COLOR_RESET}"
            done
        else
            echo -e "  ${COLOR_YELLOW}⚠️  未安装AI模型${COLOR_RESET}"
        fi
    else
        echo -e "  ${COLOR_RED}❌ Ollama服务未运行${COLOR_RESET}"
    fi
    
    # 检查AI模型目录
    if [[ -d "$AI_MODELS_DIR" ]]; then
        echo -e "  ${COLOR_GREEN}✅ AI模型目录存在${COLOR_RESET}"
    else
        echo -e "  ${COLOR_YELLOW}⚠️  AI模型目录不存在${COLOR_RESET}"
    fi
    
    # 检查相关脚本
    local ai_scripts=(
        "yyc3-knowledge-base.sh"
        "yyc3-model.sh"
    )
    
    for script in "${ai_scripts[@]}"; do
        if [[ -f "$script" && -x "$script" ]]; then
            echo -e "  ${COLOR_GREEN}✅ $script (可执行)${COLOR_RESET}"
        elif [[ -f "$script" ]]; then
            echo -e "  ${COLOR_YELLOW}⚠️  $script (存在但不可执行)${COLOR_RESET}"
        else
            echo -e "  ${COLOR_RED}❌ $script (不存在)${COLOR_RESET}"
        fi
    done
}

# 启动AI服务
function start_ai_services() {
    echo -e "${COLOR_CYAN}🚀 启动YYC³ AI服务...${COLOR_RESET}"
    
    # 检查并启动Ollama
    if ! curl -s "$OLLAMA_HOST/api/tags" &> /dev/null; then
        echo -e "  ${COLOR_BLUE}启动Ollama服务...${COLOR_RESET}"
        if command -v ollama &> /dev/null; then
            ollama serve &
            sleep 5
            echo -e "  ${COLOR_GREEN}✅ Ollama服务已启动${COLOR_RESET}"
        else
            echo -e "  ${COLOR_RED}❌ Ollama未安装${COLOR_RESET}"
        fi
    else
        echo -e "  ${COLOR_GREEN}✅ Ollama服务已在运行${COLOR_RESET}"
    fi
    
    # 创建必要的目录
    mkdir -p "$AI_MODELS_DIR"
    mkdir -p "$AI_LOG_DIR"
    
    echo -e "${COLOR_GREEN}✅ AI服务启动完成${COLOR_RESET}"
}

# 停止AI服务
function stop_ai_services() {
    echo -e "${COLOR_CYAN}🛑 停止YYC³ AI服务...${COLOR_RESET}"
    
    # 停止Ollama服务
    pkill -f "ollama serve" 2>/dev/null || true
    
    echo -e "  ${COLOR_GREEN}✅ AI服务已停止${COLOR_RESET}"
}

# 管理AI模型
function manage_models() {
    local action="${1:-list}"
    
    case "$action" in
        list)
            echo -e "${COLOR_CYAN}📋 可用AI模型列表:${COLOR_RESET}"
            if curl -s "$OLLAMA_HOST/api/tags" &> /dev/null; then
                curl -s "$OLLAMA_HOST/api/tags" | jq -r '.models[] | "• " + .name + " (" + (.size|tostring) + " bytes)"' 2>/dev/null || \
                echo -e "  ${COLOR_YELLOW}⚠️  无法获取模型列表${COLOR_RESET}"
            else
                echo -e "  ${COLOR_RED}❌ Ollama服务未运行${COLOR_RESET}"
            fi
            ;;
        pull)
            local model="${2:-llama2}"
            echo -e "${COLOR_CYAN}⬇️  下载AI模型: $model${COLOR_RESET}"
            if command -v ollama &> /dev/null; then
                ollama pull "$model"
                echo -e "${COLOR_GREEN}✅ 模型下载完成${COLOR_RESET}"
            else
                echo -e "${COLOR_RED}❌ Ollama未安装${COLOR_RESET}"
            fi
            ;;
        *)
            echo -e "${COLOR_RED}未知操作: $action${COLOR_RESET}"
            echo -e "可用操作: list, pull <model>"
            ;;
    esac
}

# 智能对话功能
function start_chat() {
    echo -e "${COLOR_CYAN}💬 启动智能对话...${COLOR_RESET}"
    
    if ! curl -s "$OLLAMA_HOST/api/tags" &> /dev/null; then
        echo -e "  ${COLOR_RED}❌ 请先启动AI服务: $0 start${COLOR_RESET}"
        return 1
    fi
    
    echo -e "${COLOR_GREEN}✅ 智能对话已就绪${COLOR_RESET}"
    echo -e "${COLOR_BLUE}输入 'quit' 或 'exit' 退出对话${COLOR_RESET}"
    echo ""
    
    # 简单的对话循环
    while true; do
        read -p "🤔 您: " user_input
        
        if [[ "$user_input" == "quit" || "$user_input" == "exit" ]]; then
            echo -e "${COLOR_GREEN}👋 再见！${COLOR_RESET}"
            break
        fi
        
        # 调用AI接口进行对话
        local response=$(curl -s -X POST "$OLLAMA_HOST/api/generate" \
            -H "Content-Type: application/json" \
            -d "{\"model\": \"llama2\", \"prompt\": \"$user_input\", \"stream\": false}" \
            | jq -r '.response' 2>/dev/null || echo "抱歉，暂时无法响应")
        
        echo -e "${COLOR_CYAN}🤖 AI: $response${COLOR_RESET}"
        echo ""
    done
}

# 知识库管理
function manage_knowledge_base() {
    local action="${1:-status}"
    
    case "$action" in
        status)
            echo -e "${COLOR_CYAN}📚 知识库状态:${COLOR_RESET}"
            if [[ -f "yyc3-knowledge-base.sh" ]]; then
                echo -e "  ${COLOR_GREEN}✅ 知识库脚本可用${COLOR_RESET}"
            else
                echo -e "  ${COLOR_RED}❌ 知识库脚本不存在${COLOR_RESET}"
            fi
            ;;
        update)
            echo -e "${COLOR_CYAN}🔄 更新知识库...${COLOR_RESET}"
            # 这里可以添加知识库更新逻辑
            echo -e "  ${COLOR_GREEN}✅ 知识库更新功能待实现${COLOR_RESET}"
            ;;
        *)
            echo -e "${COLOR_RED}未知操作: $action${COLOR_RESET}"
            echo -e "可用操作: status, update"
            ;;
    esac
}

# 主函数
function main() {
    local command="${1:-status}"
    
    case "$command" in
        status)
            check_ai_status
            ;;
        start)
            start_ai_services
            ;;
        stop)
            stop_ai_services
            ;;
        models)
            manage_models "${@:2}"
            ;;
        chat)
            start_chat
            ;;
        kb)
            manage_knowledge_base "${@:2}"
            ;;
        *)
            echo -e "${COLOR_RED}未知命令: $command${COLOR_RESET}"
            show_usage
            exit 1
            ;;
    esac
}

# 脚本入口
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi