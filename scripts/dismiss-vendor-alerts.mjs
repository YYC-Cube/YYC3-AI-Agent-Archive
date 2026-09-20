#!/usr/bin/env node
/**
 * Dismiss Dependabot alerts originating from vendor/reference directories.
 *
 * Vendor assets (agents-hub/, tools-hub/, skills-hub/community/, _external/, …)
 * ship their own lockfiles that are NOT part of this repository's production
 * dependency graph. Their vulnerability alerts are noise.
 *
 * Strategy:
 *  - KEEP alerts for manifests under the core workspace (root + packages/*).
 *  - DISMISS everything else with reason `tolerated_risk` + an explanatory
 *    comment, so the decision is auditable.
 *
 * Idempotent: re-running only processes still-open, still-vendor alerts.
 *
 * Required scope: repo (admin:security_events) — run via `gh auth` or GITHUB_TOKEN.
 *
 * Usage:
 *   node scripts/dismiss-vendor-alerts.mjs            # dry-run (default)
 *   node scripts/dismiss-vendor-alerts.mjs --apply    # actually dismiss
 *   node scripts/dismiss-vendor-alerts.mjs --apply --yes   # skip confirm
 */
import { execFileSync } from 'node:child_process';

// ---------------------------------------------------------------
// Configuration — keep in sync with .github/dependabot.yml
// ---------------------------------------------------------------

/** Manifest paths under these prefixes belong to the CORE workspace. */
const CORE_PREFIXES = ['packages/', 'package.json', 'pnpm-lock.yaml', 'pnpm-workspace.yaml'];

const REPO = process.env.GITHUB_REPOSITORY ?? 'YYC-Cube/YYC3-AI-Agent-Archive';

/** Dismiss reason per GitHub API (fixed set: fix_started | inaccurate | no_bandwidth | not_used | tolerable_risk). */
const REASON = 'tolerable_risk';

// NOTE: GitHub API caps dismissed_comment at 280 chars — keep concise.
const COMMENT =
  '🤖 Auto-dismissed (dismiss-vendor-alerts.mjs): vendor/reference asset with its own lockfile; ' +
  'not in this repo production dep graph (see .github/dependabot.yml). Tolerated risk.';

const sleep = (ms) => new Promise((r) => setTimeout(r, ms));

// ---------------------------------------------------------------
// GitHub API helpers (gh CLI — inherits auth + proxy config)
// ---------------------------------------------------------------

function gh(path, { method = 'GET', body, jq } = {}) {
  const args = ['api', path, '--include'];
  if (method !== 'GET') args.push('-X', method);
  if (jq) args.push('--jq', jq);
  if (body) args.push('--input', '-');
  const out = execFileSync('gh', args, {
    input: body ? JSON.stringify(body) : undefined,
    maxBuffer: 256 * 1024 * 1024,
    encoding: 'utf8',
  });
  // headers first, blank line, then jq-formatted body
  const sep = out.includes('\r\n\r\n') ? '\r\n\r\n' : '\n\n';
  const idx = out.indexOf(sep);
  const headers = idx === -1 ? out : out.slice(0, idx);
  const payload = idx === -1 ? '' : out.slice(idx + sep.length);
  const link = /link:\s*<([^>]+)>\s*;\s*rel="next"/i.exec(headers)?.[1] ?? null;
  return { payload, next: link };
}

/** Fetch ALL open alerts: --include (Link header paging) + --jq '.[]' (one item per line). */
function fetchOpenAlerts(repo) {
  const items = [];
  let url = `/repos/${repo}/dependabot/alerts?state=open&per_page=100`;
  let guard = 0;
  while (url && guard++ < 50) {
    const { payload, next } = gh(url, { jq: '.[]' });
    for (const line of payload.split('\n')) {
      const t = line.trim();
      if (t.startsWith('{')) items.push(JSON.parse(t));
    }
    url = next;
  }
  return items;
}

async function withRetry(fn, { attempts = 5 } = {}) {
  for (let i = 1; ; i++) {
    try {
      return await fn();
    } catch (err) {
      const msg = String(err?.message ?? err);
      const status = err?.status ?? err?.process?.exitCode;
      const retriable = status === 403 && /rate limit/i.test(msg);
      if (!retriable || i === attempts) throw err;
      const wait = Math.min(60_000, 2 ** i * 1_000);
      console.warn(`  ⏳ rate-limited, retry ${i}/${attempts - 1} in ${wait / 1000}s …`);
      await sleep(wait);
    }
  }
}

// ---------------------------------------------------------------
// Main
// ---------------------------------------------------------------

const apply = process.argv.includes('--apply');
const assumeYes = process.argv.includes('--yes');

if (apply && !assumeYes) {
  // require explicit opt-in marker to avoid CI accidents
  console.error('Refusing to dismiss without --yes (add it after --apply).');
  process.exit(1);
}

console.log(`Fetching open Dependabot alerts for ${REPO} …`);
const list = fetchOpenAlerts(REPO);
console.log(`Total open alerts: ${list.length}`);

const isCore = (manifestPath) =>
  typeof manifestPath === 'string' &&
  CORE_PREFIXES.some((p) => manifestPath === p || manifestPath.startsWith(p));

const vendor = list.filter((a) => !isCore(a.dependency.manifest_path));
const kept = list.length - vendor.length;
console.log(`  core (kept):     ${kept}`);
console.log(`  vendor (target): ${vendor.length}`);
if (kept > 0) {
  console.log('\nCore alerts that will REMAIN open:');
  for (const a of list.filter(isCore)) {
    console.log(`  [${a.number}] ${a.dependency.manifest_path} — ${a.dependency.package.name} (${a.security_advisory.severity})`);
  }
}

if (!apply) {
  console.log('\n Dry-run only. Re-run with `--apply --yes` to dismiss.');
  process.exit(0);
}

console.log(`\nDismissing ${vendor.length} vendor alerts (reason=${REASON}) …`);
let ok = 0;
let fail = 0;
for (const a of vendor) {
  const num = a.number;
  const path = a.dependency.manifest_path;
  try {
    await withRetry(() =>
      gh(`/repos/${REPO}/dependabot/alerts/${num}`, {
        method: 'PATCH',
        body: { state: 'dismissed', dismissed_reason: REASON, dismissed_comment: COMMENT },
      })
    );
    ok++;
    process.stdout.write(`  ✅ [${num}] ${path}\n`);
  } catch (err) {
    fail++;
    console.error(`  ❌ [${num}] ${path}: ${String(err?.message ?? err).split('\n')[0]}`);
  }
  await sleep(150); // gentle pacing
}

console.log(`\nDone. dismissed=${ok} failed=${fail}`);
if (fail > 0) process.exit(2);
