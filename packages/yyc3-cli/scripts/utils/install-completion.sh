#!/usr/bin/env bash
set -euo pipefail
# 简易安装器：将 devctl 的 zsh 补全写入 ~/.zfunc/_devctl

if ! command -v zsh >/dev/null 2>&1; then
  echo "zsh 未安装，退出" >&2
  exit 1
fi

"$(cd "$(dirname "${BASH_SOURCE[0]}")" && cd ../.. && pwd)"/devctl completion zsh --install

cat <<'EOF'

[下一步]
1) 若首次启用 zsh 补全，请将以下两行加入 ~/.zshrc：
   fpath=(~/.zfunc $fpath)
   autoload -Uz compinit && compinit
2) 重启终端或执行: source ~/.zshrc
EOF
