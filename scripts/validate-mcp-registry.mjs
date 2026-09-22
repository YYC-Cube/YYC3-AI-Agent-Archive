#!/usr/bin/env node
/**
 * @file validate-mcp-registry.mjs
 * @description Task G1-5 — 校验 public/registry/*.json 符合 MCP Registry 官方 schema（draft-07）
 *
 * 校验内容：
 *   1. registry.json 聚合文件符合官方 server.schema.json 的 servers[] 结构
 *   2. 每个 server 条目通过 ServerDetail 校验（name 格式、version semver、description 非空）
 *   3. name 全局唯一（无 slug 碰撞）
 *
 * 退出码：0 = 全部通过；1 = 存在违规
 *
 * 用法：node scripts/validate-mcp-registry.mjs [--registry public/registry]
 */
import fs from 'node:fs/promises';
import path from 'node:path';

const ROOT = path.resolve(import.meta.dirname ?? '.', '..');
const SCHEMA_PATH = path.join(ROOT, 'schema/mcp-registry/server.schema.json');
const REGISTRY_DIR = path.resolve(
  ROOT,
  process.argv.includes('--registry')
    ? process.argv[process.argv.indexOf('--registry') + 1]
    : 'public/registry'
);

/**
 * 加载 ajv：pnpm 严格隔离下 ajv 未必链接到根 node_modules，
 * 依次探测根链接 → .pnpm 物理路径
 */
async function loadAjv() {
  const { createRequire } = await import('node:module');
  const require = createRequire(import.meta.url);
  try {
    return require('ajv');
  } catch {
    const pnpmDir = path.join(ROOT, 'node_modules/.pnpm');
    try {
      const entries = await fs.readdir(pnpmDir);
      const ajvDir = entries.find((e) => e.startsWith('ajv@'));
      if (ajvDir) {
        return require(path.join(pnpmDir, ajvDir, 'node_modules/ajv'));
      }
    } catch {
      // fallthrough
    }
    console.error('[validate-mcp-registry] ajv 不可用：请运行 pnpm install（或检查 node_modules）');
    process.exit(1);
  }
}

async function main() {
  const schema = JSON.parse(await fs.readFile(SCHEMA_PATH, 'utf-8'));
  const Ajv = await loadAjv();
  const ajv = new Ajv({ allErrors: true, strict: false });
  const validate = ajv.compile(schema);

  const registryPath = path.join(REGISTRY_DIR, 'registry.json');
  let registry;
  try {
    registry = JSON.parse(await fs.readFile(registryPath, 'utf-8'));
  } catch (e) {
    console.error(`[validate-mcp-registry] 无法读取 ${path.relative(ROOT, registryPath)}: ${e.message}`);
    process.exit(1);
  }

  const servers = Array.isArray(registry.servers) ? registry.servers : [];
  if (servers.length === 0) {
    console.error('[validate-mcp-registry] registry.json 中 servers 为空');
    process.exit(1);
  }

  const errors = [];
  const seen = new Map();
  for (const [i, s] of servers.entries()) {
    const label = s.name ?? `#${i}`;
    if (!validate(s)) {
      for (const err of validate.errors ?? []) {
        errors.push(`${label}: ${err.instancePath} ${err.message}`);
      }
    }
    if (seen.has(s.name)) {
      errors.push(`${label}: name 重复（slug 碰撞）`);
    }
    seen.set(s.name, true);
  }

  if (errors.length) {
    console.error(`[validate-mcp-registry] ✗ ${errors.length} 处违规（前 20 条）：`);
    for (const e of errors.slice(0, 20)) console.error('  -', e);
    process.exit(1);
  }

  console.log(
    `[validate-mcp-registry] ✓ ${servers.length} servers 全部通过官方 schema 校验（${path.relative(ROOT, registryPath)}）`
  );
}

main().catch((e) => {
  console.error('[validate-mcp-registry] 未预期错误:', e.message);
  process.exit(1);
});
