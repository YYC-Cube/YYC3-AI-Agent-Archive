/**
 * file: helper.js
 * description: WebSocket 客户端辅助脚本 · 头脑风暴服务器实时通信与自动重载
 * description-en: WebSocket client helper script · Real-time communication and auto-reload for brainstorm server
 * author: YanYuCloudCube Team <admin@0379.email>
 * version: v1.0.0
 * created: 2026-04-29
 * updated: 2026-04-29
 * status: active
 * tags: [util],[websocket],[brainstorm],[client]
 *
 * copyright: YanYuCloudCube Team
 * license: MIT
 *
 * brief: 提供 WebSocket 连接管理和事件队列功能
 * brief-en: Provide WebSocket connection management and event queue functionality
 *
 * details:
 * - 自动连接到头脑风暴 WebSocket 服务器
 * - 维护事件队列，断线时缓存事件
 * - 支持页面自动重载（reload 事件）
 * - 自动重连机制（1秒间隔）
 *
 * details-en:
 * - Auto-connect to brainstorm WebSocket server
 * - Maintain event queue, cache events when disconnected
 * - Support page auto-reload (reload event)
 * - Auto-reconnect mechanism (1s interval)
 *
 * dependencies: WebSocket API, JSON
 * exports: connect, sendEvent (IIFE scope)
 * notes: 在浏览器环境中运行 / Runs in browser environment
 */

(function() {
  const WS_URL = 'ws://' + window.location.host;
  let ws = null;
  let eventQueue = [];

  function connect() {
    ws = new WebSocket(WS_URL);

    ws.onopen = () => {
      eventQueue.forEach(e => ws.send(JSON.stringify(e)));
      eventQueue = [];
    };

    ws.onmessage = (msg) => {
      const data = JSON.parse(msg.data);
      if (data.type === 'reload') {
        window.location.reload();
      }
    };

    ws.onclose = () => {
      setTimeout(connect, 1000);
    };
  }

  function sendEvent(event) {
    event.timestamp = Date.now();
    if (ws && ws.readyState === WebSocket.OPEN) {
      ws.send(JSON.stringify(event));
    } else {
      eventQueue.push(event);
    }
  }

  // Capture clicks on choice elements
  document.addEventListener('click', (e) => {
    const target = e.target.closest('[data-choice]');
    if (!target) return;

    sendEvent({
      type: 'click',
      text: target.textContent.trim(),
      choice: target.dataset.choice,
      id: target.id || null
    });

    // Update indicator bar (defer so toggleSelect runs first)
    setTimeout(() => {
      const indicator = document.getElementById('indicator-text');
      if (!indicator) return;
      const container = target.closest('.options') || target.closest('.cards');
      const selected = container ? container.querySelectorAll('.selected') : [];
      if (selected.length === 0) {
        indicator.textContent = 'Click an option above, then return to the terminal';
      } else if (selected.length === 1) {
        const label = selected[0].querySelector('h3, .content h3, .card-body h3')?.textContent?.trim() || selected[0].dataset.choice;
        indicator.innerHTML = '<span class="selected-text">' + label + ' selected</span> — return to terminal to continue';
      } else {
        indicator.innerHTML = '<span class="selected-text">' + selected.length + ' selected</span> — return to terminal to continue';
      }
    }, 0);
  });

  // Frame UI: selection tracking
  window.selectedChoice = null;

  window.toggleSelect = function(el) {
    const container = el.closest('.options') || el.closest('.cards');
    const multi = container && container.dataset.multiselect !== undefined;
    if (container && !multi) {
      container.querySelectorAll('.option, .card').forEach(o => o.classList.remove('selected'));
    }
    if (multi) {
      el.classList.toggle('selected');
    } else {
      el.classList.add('selected');
    }
    window.selectedChoice = el.dataset.choice;
  };

  // Expose API for explicit use
  window.brainstorm = {
    send: sendEvent,
    choice: (value, metadata = {}) => sendEvent({ type: 'choice', value, ...metadata })
  };

  connect();
})();
