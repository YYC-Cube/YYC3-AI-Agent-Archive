#!/usr/bin/env bash

# =============================================================================
# file: stop-server.sh
# description: 头脑风暴服务器停止脚本 · 优雅关闭服务器进程并清理会话资源
# description-en: Brainstorm server stop script · Gracefully shutdown server process and cleanup session resources
# author: YanYuCloudCube Team <admin@0379.email>
# version: v1.0.0
# created: 2026-04-29
# updated: 2026-04-29
# status: active
# tags: [script],[server],[brainstorm],[cleanup]
#
# copyright: YanYuCloudCube Team
# license: MIT
#
# brief: 停止头脑风暴服务器，支持临时目录清理和持久化目录保留
# brief-en: Stop brainstorm server, support temp directory cleanup and persistent directory preservation
#
# details:
# - 通过 PID 文件终止服务器进程
# - 仅删除 /tmp 下的临时会话目录
# - 保留 .superpowers/ 下的持久化目录（供后续审查）
# - 输出 JSON 格式的操作结果
#
# details-en:
# - Terminate server process via PID file
# - Only delete ephemeral session directories under /tmp
# - Keep persistent directories under .superpowers/ (for later review)
# - Output JSON format operation results
#
# usage:
#   stop-server.sh <session_dir>
#
# dependencies: bash, kill command
# notes: 配合 start-server.sh 使用 / Use with start-server.sh
# =============================================================================

# Stop the brainstorm server and clean up
# Usage: stop-server.sh <session_dir>
#
# Kills the server process. Only deletes session directory if it's
# under /tmp (ephemeral). Persistent directories (.superpowers/) are
# kept so mockups can be reviewed later.

SESSION_DIR="$1"

if [[ -z "$SESSION_DIR" ]]; then
  echo '{"error": "Usage: stop-server.sh <session_dir>"}'
  exit 1
fi

STATE_DIR="${SESSION_DIR}/state"
PID_FILE="${STATE_DIR}/server.pid"

if [[ -f "$PID_FILE" ]]; then
  pid=$(cat "$PID_FILE")

  # Try to stop gracefully, fallback to force if still alive
  kill "$pid" 2>/dev/null || true

  # Wait for graceful shutdown (up to ~2s)
  for i in {1..20}; do
    if ! kill -0 "$pid" 2>/dev/null; then
      break
    fi
    sleep 0.1
  done

  # If still running, escalate to SIGKILL
  if kill -0 "$pid" 2>/dev/null; then
    kill -9 "$pid" 2>/dev/null || true

    # Give SIGKILL a moment to take effect
    sleep 0.1
  fi

  if kill -0 "$pid" 2>/dev/null; then
    echo '{"status": "failed", "error": "process still running"}'
    exit 1
  fi

  rm -f "$PID_FILE" "${STATE_DIR}/server.log"

  # Only delete ephemeral /tmp directories
  if [[ "$SESSION_DIR" == /tmp/* ]]; then
    rm -rf "$SESSION_DIR"
  fi

  echo '{"status": "stopped"}'
else
  echo '{"status": "not_running"}'
fi
