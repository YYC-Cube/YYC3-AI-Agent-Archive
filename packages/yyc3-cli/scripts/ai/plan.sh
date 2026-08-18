#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../utils/common.sh
source "$SCRIPT_DIR/../utils/common.sh"

section "AI 开发计划生成"
load_env

if [[ $# -eq 0 ]]; then
  warn "用法: devctl ai:plan \"<需求或目标描述>\" [输出文件]"
fi

desc=${1:-"请为我的功能生成开发计划。"}
out=${2:-}

if [[ -f "$REPO_ROOT/ai-code-gen.sh" ]]; then
  if [[ -n "$out" ]]; then
    bash "$REPO_ROOT/ai-code-gen.sh" --plan "$desc" > "$out" || true
    ok "已生成计划: $out"
  else
    bash "$REPO_ROOT/ai-code-gen.sh" --plan "$desc" || true
  fi
else
  cat <<EOF
# 开发计划 (模板)

## 目标
- $desc

## 步骤
1. 需求澄清与边界
2. API/数据结构设计
3. 脚手架与目录
4. 关键路径实现
5. 单元/集成测试
6. 文档与示例
7. 回归与验收

## 风险与对策
- 风险: TODO
- 方案: TODO
EOF
fi
