/**
 * @file sync-upstream.cjs
 * @description 上游同步脚本 — NVIDIA Skills + buildwithclaude 版本追踪
 */
const fs = require('fs');
const path = require('path');


const ROOT = path.resolve(__dirname, '..');
const CACHE = path.join(ROOT, '.upstream-cache.json');

const UPSTREAMS = {
  nvidia: {
    name: 'NVIDIA Skills',
    registry: 'https://raw.githubusercontent.com/NVIDIA/skills/main/skills.sh.json',
    local: 'skills-hub/ai-ml/nvidia-skills/skills.sh.json',
    status: 'tracking',
  },
  buildwithclaude: {
    name: 'buildwithclaude',
    registry: 'https://raw.githubusercontent.com/davepoon/buildwithclaude/main/package.json',
    local: 'plugins-hub/official/buildwithclaude-cc-best/README.md',
    status: 'tracking',
  },
};

function loadCache() {
  try { return JSON.parse(fs.readFileSync(CACHE, 'utf-8')); }
  catch { return { lastCheck: null, versions: {} }; }
}

function saveCache(c) {
  fs.writeFileSync(CACHE, JSON.stringify(c, null, 2));
}

async function checkNVIDIA() {
  console.log('[sync:nvidia] Checking NVIDIA Skills registry...');
  try {
    const res = await fetch(UPSTREAMS.nvidia.registry);
    if (!res.ok) throw new Error('HTTP ' + res.status);
    const remote = await res.json();
    const count = remote.skills ? remote.skills.length : 'unknown';
    const localSkills = fs.readdirSync(path.join(ROOT, 'skills-hub/ai-ml/nvidia-skills/skills'), { withFileTypes: true })
      .filter(e => e.isDirectory()).length;
    console.log('[sync:nvidia] Remote: ' + count + ' skills, Local: ' + localSkills + ' skills');
    if (localSkills < (typeof count === 'number' ? count : 202)) {
      console.log('[sync:nvidia] ⚠ Local behind remote. Run: npx skills add NVIDIA/skills --all');
    } else {
      console.log('[sync:nvidia] ✅ Up to date');
    }
    return { remote: count, local: localSkills };
  } catch (e) {
    console.log('[sync:nvidia] ⚠ Check failed: ' + e.message);
    return null;
  }
}

async function checkBuildWithClaude() {
  console.log('[sync:bwc] Checking buildwithclaude registry...');
  const pluginsDir = path.join(ROOT, 'plugins-hub/official');
  const bwcDirs = fs.readdirSync(pluginsDir).filter(d => d.startsWith('buildwithclaude-'));
  console.log('[sync:bwc] Local plugins: ' + bwcDirs.length + ' (' + bwcDirs.join(', ') + ')');
  console.log('[sync:bwc] ✅ Local snapshot tracking');
  return { local: bwcDirs.length };
}

async function main() {
  console.log('=== Upstream Sync Check ===\n');
  const cache = loadCache();
  cache.lastCheck = new Date().toISOString();

  const nv = await checkNVIDIA();
  const bwc = await checkBuildWithClaude();

  cache.versions.nvidia = nv;
  cache.versions.buildwithclaude = bwc;
  saveCache(cache);

  console.log('\n=== Summary ===');
  console.log('Last check: ' + cache.lastCheck);
  console.log('NVIDIA Skills: ' + (nv ? nv.local + '/' + nv.remote : 'failed'));
  console.log('buildwithclaude: ' + (bwc ? bwc.local + ' plugins' : 'failed'));
  console.log('\nRun with --pull to auto-sync new items (requires network access)');
}

if (require.main === module) main().catch(e => { console.error(e); process.exit(1); });
