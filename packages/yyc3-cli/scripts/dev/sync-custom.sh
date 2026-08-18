#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../utils/common.sh
source "$SCRIPT_DIR/../utils/common.sh"

load_env
section "同步本机自定义配置"
print_device

YES=${YES:-0}

update_ssh_config() {
  local host_alias
  host_alias=$(get_env LOCAL_MBP_HOST_NAME "yyc3-local")
  local ssh_user
  ssh_user=$(get_env LOCAL_MBP_SSH_USER "$USER")
  local ssh_host
  ssh_host=$(get_env LOCAL_MBP_SSH_HOST "127.0.0.1")
  local ssh_port
  ssh_port=$(get_env LOCAL_MBP_SSH_PORT "22")

  local cfg="$HOME/.ssh/config"
  mkdir -p "$HOME/.ssh"
  touch "$cfg"
  chmod 600 "$cfg" || true

  local begin="# BEGIN YYC3-$host_alias"
  local end="# END YYC3-$host_alias"
  local block
  block=$(cat <<EOF
$begin
Host $host_alias
  HostName $ssh_host
  User $ssh_user
  Port $ssh_port
  StrictHostKeyChecking accept-new
$end
EOF
)

  if grep -q "$begin" "$cfg"; then
    awk -v b="$begin" -v e="$end" 'BEGIN{p=1} $0~b{print; p=0} p{print} $0~e{p=1}' "$cfg" > "$cfg.tmp"
    mv "$cfg.tmp" "$cfg"
  fi
  printf "\n%s\n" "$block" >> "$cfg"
  ok "已更新 SSH 配置: $cfg (别名: $host_alias)"
}

install_devctl_symlink() {
  local target_dir="$HOME/bin"
  mkdir -p "$target_dir"
  ln -sf "$REPO_ROOT/devctl" "$target_dir/devctl"
  ok "已创建符号链接: $target_dir/devctl"
  if [[ ":$PATH:" != *":$target_dir:"* ]]; then
    warn "PATH 中未包含 $target_dir，可在 ~/.zshrc 追加: export PATH=\"$target_dir:$PATH\""
  fi
}

install_completion() {
  if command -v zsh >/dev/null 2>&1; then
    bash "$REPO_ROOT/scripts/utils/install-completion.sh"
  else
    warn "未检测到 zsh，跳过补全安装"
  fi
}

maybe_do() {
  local msg=$1
  shift
  if [[ "$YES" == "1" ]]; then
    "$@"
  else
    if confirm "$msg"; then
      "$@"
    else
      warn "跳过：$msg"
    fi
  fi
}

maybe_do "更新 ~/.ssh/config 中的本机别名?" update_ssh_config
maybe_do "在 ~/bin 下创建 devctl 符号链接?" install_devctl_symlink
maybe_do "安装 zsh 自动补全 (_devctl)?" install_completion

ok "同步自定义配置完成"
