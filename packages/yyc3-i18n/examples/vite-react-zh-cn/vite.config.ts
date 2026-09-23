import react from '@vitejs/plugin-react'
import { defineConfig, type Plugin } from 'vite'

/**
 * Node 内置模块浏览器 stub
 * @yyc3/i18n-core 桶导出含 Node-only 工具（secure-random/backoff），
 * 其 Node API 调用均在函数体内，浏览器端未触达 — 此处以浏览器等价实现替换。
 */
function nodeBuiltinStub(): Plugin {
  const cryptoStub = String.raw`
const webCrypto = globalThis.crypto;
export const randomUUID = () => webCrypto.randomUUID();
export const randomBytes = (bytes) => {
  const buf = new Uint8Array(bytes);
  webCrypto.getRandomValues(buf);
  return { ...buf, toString: (enc) => enc === 'base64url' || enc === 'base64' ? btoa(String.fromCharCode(...buf)).replace(/\+/g, '-').replace(/\//g, '_').replace(/=+$/, '') : Array.from(buf, b => b.toString(16).padStart(2, '0')).join('') };
};
export const randomInt = (min, max) => min + Math.floor(webCrypto.getRandomValues(new Uint32Array(1))[0] / 4294967296 * (max - min));
export const timingSafeEqual = (a, b) => a.length === b.length && a.every((v, i) => v === b[i]);
export const createHash = () => ({ update: () => ({ digest: () => new Uint8Array(32) }) });
`
  const timersStub = `
export const setTimeout = (ms, value) => new Promise((resolve) => globalThis.setTimeout(() => resolve(value), ms));
`
  return {
    name: 'yyc3-node-builtin-stub',
    enforce: 'pre',
    resolveId(id) {
      if (id === 'node:crypto') return '\0yyc3-stub:node:crypto'
      if (id === 'node:timers/promises') return '\0yyc3-stub:node:timers/promises'
      return null
    },
    load(id) {
      if (id === '\0yyc3-stub:node:crypto') return cryptoStub
      if (id === '\0yyc3-stub:node:timers/promises') return timersStub
      return null
    },
  }
}

export default defineConfig({
  plugins: [react(), nodeBuiltinStub()],
  server: {
    port: 3000,
    open: true
  }
})
