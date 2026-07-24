#!/bin/bash
# ============================================================
# 去重校验脚本 dedup_check.sh
# 功能: 检测跨目录的重复技能/插件，确保去重操作的有效性
# 使用: bash dedup_check.sh [--fix]
#   --fix: 自动修复发现的路径引用问题
# ============================================================

set -euo pipefail

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# 项目根目录
ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$ROOT_DIR"

FIX_MODE="${1:-}"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Skills-archive 去重校验脚本${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

ERRORS=0
WARNINGS=0

# ----------------------------------------------------------
# 检查1: 跨目录同名技能检测
# ----------------------------------------------------------
check_cross_dir_duplicates() {
    echo -e "${BLUE}[检查1] 跨目录同名技能检测${NC}"
    echo "----------------------------------------"

    # 收集各目录的技能列表
    local dirs=("skills" "all-skills/skills" "external_plugins" "claude-plugins")
    declare -A skill_dirs  # skill_name -> list of directories

    for dir in "${dirs[@]}"; do
        if [ ! -d "$dir" ]; then
            continue
        fi
        for skill_dir in "$dir"/*/; do
            [ -d "$skill_dir" ] || continue
            local name=$(basename "$skill_dir")
            if [ -z "${skill_dirs[$name]:-}" ]; then
                skill_dirs[$name]="$dir"
            else
                skill_dirs[$name]="${skill_dirs[$name]} $dir"
            fi
        done
    done

    local found=0
    for name in $(echo "${!skill_dirs[@]}" | tr ' ' '\n' | sort); do
        local dirs_list="${skill_dirs[$name]}"
        local count=$(echo "$dirs_list" | wc -w)
        if [ "$count" -gt 1 ]; then
            echo -e "  ${RED}重复: $name -> [$dirs_list]${NC}"
            found=1
            ERRORS=$((ERRORS + 1))
        fi
    done

    if [ "$found" -eq 0 ]; then
        echo -e "  ${GREEN}通过: 无跨目录同名重复${NC}"
    fi
    echo ""
}

# ----------------------------------------------------------
# 检查2: 旧目录名残留检测 (.claude-plugin / .codebuddy-plugin)
# ----------------------------------------------------------
check_old_dir_names() {
    echo -e "${BLUE}[检查2] 旧目录名残留检测${NC}"
    echo "----------------------------------------"

    local old_claude=$(find . -type d -name ".claude-plugin" -not -path "*/node_modules/*" 2>/dev/null | wc -l)
    local old_codebuddy=$(find . -type d -name ".codebuddy-plugin" -not -path "*/node_modules/*" 2>/dev/null | wc -l)
    local new_dir=$(find . -type d -name ".ai-family-plugin" -not -path "*/node_modules/*" 2>/dev/null | wc -l)

    if [ "$old_claude" -gt 0 ]; then
        echo -e "  ${RED}残留 .claude-plugin 目录: $old_claude 个${NC}"
        ERRORS=$((ERRORS + 1))
    else
        echo -e "  ${GREEN}通过: 无 .claude-plugin 残留${NC}"
    fi

    if [ "$old_codebuddy" -gt 0 ]; then
        echo -e "  ${RED}残留 .codebuddy-plugin 目录: $old_codebuddy 个${NC}"
        ERRORS=$((ERRORS + 1))
    else
        echo -e "  ${GREEN}通过: 无 .codebuddy-plugin 残留${NC}"
    fi

    echo -e "  ${BLUE}当前 .ai-family-plugin 目录总数: $new_dir${NC}"
    echo ""
}

# ----------------------------------------------------------
# 检查3: 文件内容中旧目录名引用检测
# ----------------------------------------------------------
check_old_refs_in_content() {
    echo -e "${BLUE}[检查3] 文件内容中旧目录名引用检测${NC}"
    echo "----------------------------------------"

    local claude_refs=$(grep -rl '\.claude-plugin' \
        --include="*.json" --include="*.md" --include="*.ts" --include="*.js" \
        --include="*.cjs" --include="*.mjs" --include="*.py" --include="*.sh" \
        --include="*.yml" --include="*.yaml" --include="*.toml" \
        . 2>/dev/null | grep -v node_modules | grep -v '/target/' | \
        grep -v '\.ai-family-plugin' | wc -l)

    local codebuddy_refs=$(grep -rl '\.codebuddy-plugin' \
        --include="*.json" --include="*.md" --include="*.ts" --include="*.js" \
        --include="*.cjs" --include="*.mjs" --include="*.py" --include="*.sh" \
        --include="*.yml" --include="*.yaml" --include="*.toml" \
        . 2>/dev/null | grep -v node_modules | grep -v '/target/' | \
        grep -v '\.ai-family-plugin' | wc -l)

    if [ "$claude_refs" -gt 0 ]; then
        echo -e "  ${RED}残留 .claude-plugin 引用: $claude_refs 个文件${NC}"
        ERRORS=$((ERRORS + 1))
    else
        echo -e "  ${GREEN}通过: 无 .claude-plugin 文件引用残留${NC}"
    fi

    if [ "$codebuddy_refs" -gt 0 ]; then
        echo -e "  ${RED}残留 .codebuddy-plugin 引用: $codebuddy_refs 个文件${NC}"
        ERRORS=$((ERRORS + 1))
    else
        echo -e "  ${GREEN}通过: 无 .codebuddy-plugin 文件引用残留${NC}"
    fi
    echo ""
}

# ----------------------------------------------------------
# 检查4: marketplace.json 路径有效性验证
# ----------------------------------------------------------
check_marketplace_paths() {
    echo -e "${BLUE}[检查4] marketplace.json 路径有效性验证${NC}"
    echo "----------------------------------------"

    if [ ! -f "marketplace.json" ]; then
        echo -e "  ${YELLOW}跳过: marketplace.json 不存在${NC}"
        echo ""
        return
    fi

    local missing=0
    local ok=0

    # 提取所有本地 source 路径
    local paths=$(grep -o '"source": "\./[^"]*"' marketplace.json | \
        sed 's/"source": "//;s/"$//' | sort -u)

    while IFS= read -r path; do
        [ -z "$path" ] && continue
        if [ -d ".$path" ]; then
            ok=$((ok + 1))
        else
            echo -e "  ${RED}MISSING: $path${NC}"
            missing=$((missing + 1))
            ERRORS=$((ERRORS + 1))
        fi
    done <<< "$paths"

    echo -e "  ${GREEN}有效路径: $ok${NC}"
    if [ "$missing" -gt 0 ]; then
        echo -e "  ${RED}缺失路径: $missing${NC}"
    else
        echo -e "  ${GREEN}通过: 所有路径有效${NC}"
    fi
    echo ""
}

# ----------------------------------------------------------
# 检查5: 重复内容检测 (SKILL.md 完全相同的技能)
# ----------------------------------------------------------
check_duplicate_content() {
    echo -e "${BLUE}[检查5] SKILL.md 内容完全相同的技能检测${NC}"
    echo "----------------------------------------"

    # 收集所有 SKILL.md 文件的 hash
    local found=0
    declare -A hash_map

    while IFS= read -r file; do
        local hash=$(md5 -q "$file" 2>/dev/null || md5sum "$file" 2>/dev/null | awk '{print $1}')
        if [ -z "$hash" ]; then continue; fi
        if [ -z "${hash_map[$hash]:-}" ]; then
            hash_map[$hash]="$file"
        else
            echo -e "  ${YELLOW}内容相同: ${hash_map[$hash]} == $file${NC}"
            found=1
            WARNINGS=$((WARNINGS + 1))
        fi
    done < <(find . -name "SKILL.md" -not -path "*/node_modules/*" -not -path "*/target/*" 2>/dev/null)

    if [ "$found" -eq 0 ]; then
        echo -e "  ${GREEN}通过: 无完全相同的 SKILL.md${NC}"
    fi
    echo ""
}

# ----------------------------------------------------------
# 检查6: .ai-family-plugin/plugin.json 完整性
# ----------------------------------------------------------
check_plugin_json() {
    echo -e "${BLUE}[检查6] .ai-family-plugin/plugin.json 完整性${NC}"
    echo "----------------------------------------"

    local total=0
    local missing_json=0
    local invalid_json=0

    while IFS= read -r plugin_dir; do
        total=$((total + 1))
        local json_file="$plugin_dir/plugin.json"
        if [ ! -f "$json_file" ]; then
            missing_json=$((missing_json + 1))
            echo -e "  ${YELLOW}缺失 plugin.json: $plugin_dir${NC}"
        else
            # 验证 JSON 格式
            if ! python3 -c "import json; json.load(open('$json_file'))" 2>/dev/null; then
                invalid_json=$((invalid_json + 1))
                echo -e "  ${RED}JSON 格式错误: $json_file${NC}"
                ERRORS=$((ERRORS + 1))
            fi
        fi
    done < <(find . -type d -name ".ai-family-plugin" -not -path "*/node_modules/*" 2>/dev/null)

    echo -e "  ${BLUE}总计 .ai-family-plugin 目录: $total${NC}"
    echo -e "  ${GREEN}存在 plugin.json: $((total - missing_json))${NC}"
    if [ "$missing_json" -gt 0 ]; then
        echo -e "  ${YELLOW}缺失 plugin.json: $missing_json${NC}"
        WARNINGS=$((WARNINGS + missing_json))
    fi
    if [ "$invalid_json" -gt 0 ]; then
        echo -e "  ${RED}无效 JSON: $invalid_json${NC}"
    fi
    echo ""
}

# ----------------------------------------------------------
# 汇总报告
# ----------------------------------------------------------
summary() {
    echo "========================================"
    if [ "$ERRORS" -eq 0 ] && [ "$WARNINGS" -eq 0 ]; then
        echo -e "${GREEN}  全部通过! 无错误无警告${NC}"
    else
        echo -e "${RED}  错误: $ERRORS${NC}"
        echo -e "${YELLOW}  警告: $WARNINGS${NC}"
    fi
    echo "========================================"

    if [ "$ERRORS" -gt 0 ]; then
        exit 1
    fi
}

# 执行所有检查
check_cross_dir_duplicates
check_old_dir_names
check_old_refs_in_content
check_marketplace_paths
check_duplicate_content
check_plugin_json
summary
