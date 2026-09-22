/**
 * @file skills-mcp-export.js
 * @description MCP Registry server.json 兼容导出引擎（Task G1）
 *
 * 将 skills-hub 技能资产转换为 MCP Registry 官方 server.json 格式
 * （$schema: https://static.modelcontextprotocol.io/schemas/2025-12-11/server.schema.json），
 * 生成静态目录供 GitHub Pages 分发，使本仓库资产可被 MCP 官方生态聚合器消费。
 *
 * 映射规则（skill frontmatter → server.json）:
 *   name        → io.github.yyc-cube/<skill-name>   （反向 DNS namespace）
 *   description → description（多行折叠为单行）
 *   version     → version（缺省 0.0.0）
 *   category    → _meta['io.github.yyc-cube/category']（扩展元数据）
 *   license     → _meta['io.github.yyc-cube/license']
 *   SKILL.md 路径 → _meta['io.github.yyc-cube/source']
 */
const fs = require('fs').promises;
const path = require('path');
const { scanSkillFiles, parseFrontmatter } = require('./skills-indexer');

const ROOT = require('./skills-indexer').ROOT || path.resolve(__dirname, '../..');
const SCHEMA_URL = 'https://static.modelcontextprotocol.io/schemas/2025-12-11/server.schema.json';
const NAMESPACE = 'io.github.yyc-cube';

/** 折叠多行描述为单行并截断（官方 schema: description/title maxLength=100） */
function foldDescription(raw, max = 100) {
  if (!raw) return '';
  return (
    String(raw)
      .split('\n')
      .map((l) => l.trim())
      .filter(Boolean)
      .join(' ')
      .slice(0, max)
  );
}

/** slug 化：反向 DNS name 的最后一段（schema: name maxLength=200，末段留 120 余量） */
function slugify(name) {
  return (
    String(name || '')
      .toLowerCase()
      .replace(/[^a-z0-9]+/g, '-')
      .replace(/^-+|-+$/g, '')
      .slice(0, 120) || 'unnamed'
  );
}

function semverOr(v) {
  const m = String(v || '').match(/\d+\.\d+\.\d+/);
  return m ? m[0] : '0.0.0';
}

/**
 * 单个 skill → server.json 对象
 */
function skillToServer(frontmatter, skillPath) {
  const name = `${NAMESPACE}/${slugify(frontmatter.name)}`;
  const rel = path.relative(ROOT, skillPath).split(path.sep).join('/');
  const title = String(frontmatter.title || frontmatter.name || 'Untitled skill').slice(0, 100);
  return {
    $schema: SCHEMA_URL,
    name,
    title,
    description:
      foldDescription(frontmatter.description) || `YYC3 skill asset: ${rel}`.slice(0, 100),
    version: semverOr(frontmatter.version),
    _meta: {
      [`${NAMESPACE}/category`]: frontmatter.category || 'uncategorized',
      ...(frontmatter.license ? { [`${NAMESPACE}/license`]: String(frontmatter.license) } : {}),
      [`${NAMESPACE}/source`]: rel,
    },
  };
}

/**
 * slug 全局唯一消歧（MCP Registry 要求 name 唯一）：
 * 重复 slug 逐级拼接父目录名，如 community/x 与 aiq/x → x-community / x-aiq
 */
function disambiguateNames(servers) {
  const taken = new Set();
  const bySlug = {};
  for (const s of servers) {
    const slug = s.name.split('/')[1];
    (bySlug[slug] = bySlug[slug] || []).push(s);
  }
  for (const [slug, group] of Object.entries(bySlug)) {
    if (group.length === 1) { taken.add(slug); continue; }
    for (const s of group) {
      const parts = [slug];
      let dir = path.dirname(path.dirname(s._meta[`${NAMESPACE}/source`])); // 跳过与 slug 同名的直接父目录
      while (taken.has(parts.join('-')) && dir && dir !== '.' && dir !== '/') {
        parts.unshift(path.basename(dir));
        dir = path.dirname(dir);
      }
      const final = parts.join('-');
      taken.add(final);
      s.name = `${NAMESPACE}/${final}`;
    }
  }
  return servers;
}

/**
 * 生成聚合 registry 文件（v0.1 servers[] 格式，兼容 AWS Q 等 allow-list 消费方）
 */
async function buildRegistryOutput() {
  const files = await scanSkillFiles();
  const servers = [];
  for (const f of files) {
    const content = await fs.readFile(f, 'utf-8');
    const fm = parseFrontmatter(content);
    if (!fm.name && !fm.description) continue; // 无有效元数据的跳过
    servers.push(skillToServer(fm, f));
  }
  disambiguateNames(servers);
  return { servers, total: files.length };
}

/**
 * 导出主入口：CLI `skills export-mcp`
 * @param {object} options
 * @param {string} [options.out] 输出目录（默认 public/registry）
 */
async function exportMcp(options) {
  options = options || {};
  const outDir = path.resolve(ROOT, options.out || 'public/registry');
  console.log('[skills:export-mcp] Scanning skills...');
  const { servers, total } = await buildRegistryOutput();

  await fs.mkdir(outDir, { recursive: true });
  await fs.writeFile(
    path.join(outDir, 'registry.json'),
    JSON.stringify({ $schema: SCHEMA_URL, servers }, null, 2) + '\n'
  );
  // 逐 server 独立文件（io.github.yyc-cube/<slug> → slug.json）
  for (const s of servers) {
    const slug = s.name.split('/')[1];
    await fs.writeFile(path.join(outDir, `${slug}.json`), JSON.stringify(s, null, 2) + '\n');
  }
  console.log(`[skills:export-mcp] Scanned ${total} skills, exported ${servers.length} servers → ${path.relative(ROOT, outDir)}/`);
  return { total, exported: servers.length, outDir };
}

module.exports = { exportMcp, skillToServer, buildRegistryOutput, NAMESPACE, SCHEMA_URL };
