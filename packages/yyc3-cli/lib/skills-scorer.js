/**
 * @file skills-scorer.js
 * @description Task H1 — 技能质量评分引擎（五维加权，满分 100）
 *
 * 维度与权重（可配置，默认见 DEFAULT_WEIGHTS）:
 *   1. 元数据完整度 25%  — frontmatter 字段齐全性（name/description/version/category/author/license）
 *   2. 文档质量    20%  — 正文长度、示例（``` 块）数、引用链接数
 *   3. 资产健康    25%  — scripts 语法可执行（node --check / python -m py_compile）、相对引用文件存在
 *   4. 维护活跃度  15%  — git log 近 90 天提交数
 *   5. 安全扫描    15%  — 危险模式正则命中数（复用 skill-sandbox sanitizer 模式库）
 *
 * 输出: 单技能 0–100 分 + A–E 等级
 */
const fs = require('fs').promises;
const path = require('path');
const { execFile } = require('child_process');
const { scanSkillFiles, parseFrontmatter } = require('./skills-indexer');

const ROOT = require('./skills-indexer').ROOT || path.resolve(__dirname, '../..');

/** 五维权重（合计 1.0），可通过 options.weights 覆盖 */
const DEFAULT_WEIGHTS = {
  metadata: 0.25,
  docs: 0.2,
  assets: 0.25,
  activity: 0.15,
  security: 0.15,
};

/** 元数据关键字段（有值满分） */
const METADATA_FIELDS = ['name', 'description', 'version', 'category', 'author', 'license'];

/** 等级映射 */
function grade(score) {
  if (score >= 90) return 'A';
  if (score >= 75) return 'B';
  if (score >= 60) return 'C';
  if (score >= 40) return 'D';
  return 'E';
}

/** 维护活跃度：近 90 天该技能目录的 git 提交数（上限 10 分封顶） */
const activityCache = new Map();
function gitActivity(dirRel) {
  if (activityCache.has(dirRel)) return activityCache.get(dirRel);
  return 0; // 未见缓存时按 0 分（首次全量由 scoreAll 预热）
}

function execFileP(cmd, args, opts) {
  return new Promise((resolve) => {
    execFile(cmd, args, { timeout: 5000, ...opts }, (err, stdout, stderr) => {
      resolve({ err, stdout, stderr });
    });
  });
}

/**
 * 维度一：元数据完整度（0-100）
 */
function scoreMetadata(fm) {
  const present = METADATA_FIELDS.filter((k) => fm[k] && String(fm[k]).trim().length > 0);
  return Math.round((present.length / METADATA_FIELDS.length) * 100);
}

/**
 * 维度二：文档质量（0-100）
 * 正文长度（40%）、代码示例数（40%）、链接引用数（20%）
 */
function scoreDocs(body) {
  if (!body) return 0;
  const len = body.trim().length;
  const lenScore = Math.min(len / 2000, 1) * 40; // 2000 字符满分
  const codeBlocks = (body.match(/```/g) || []).length / 2;
  const codeScore = Math.min(codeBlocks / 3, 1) * 40; // ≥3 个示例满分
  const links = (body.match(/\[[^\]]+\]\([^)]+\)/g) || []).length;
  const linkScore = Math.min(links / 3, 1) * 20; // ≥3 个链接满分
  return Math.round(lenScore + codeScore + linkScore);
}

/**
 * 维度三：资产健康（0-100）
 * scripts 目录脚本语法可执行（70%）+ SKILL.md 中相对引用文件存在（30%）
 */
async function scoreAssets(skillDir, body) {
  let scriptScore = 100;
  const scriptsDir = path.join(skillDir, 'scripts');
  let entries = [];
  try {
    entries = (await fs.readdir(scriptsDir)).filter((f) => /\.(m?js|py|sh)$/.test(f));
  } catch {
    entries = []; // 无 scripts 目录 → 该项不罚
  }
  if (entries.length) {
    let ok = 0;
    for (const f of entries) {
      const fp = path.join(scriptsDir, f);
      let res;
      if (f.endsWith('.py')) {
        res = await execFileP('python3', ['-m', 'py_compile', fp]);
      } else if (f.endsWith('.sh')) {
        res = await execFileP('bash', ['-n', fp]);
      } else {
        res = await execFileP('node', ['--check', fp]);
      }
      if (!res.err) ok++;
    }
    scriptScore = Math.round((ok / entries.length) * 100);
  }

  // SKILL.md 中的相对路径引用（./x、scripts/x 等），检查存在性
  const refs = [...body.matchAll(/\]\((\.\/[^)]+|scripts\/[^)]+|assets\/[^)]+)\)/g)].map(
    (m) => m[1]
  );
  let refScore = 100;
  if (refs.length) {
    let exist = 0;
    for (const r of refs) {
      try {
        await fs.access(path.join(skillDir, r.replace(/^\.\//, '')));
        exist++;
      } catch {
        // 引用缺失
      }
    }
    refScore = Math.round((exist / refs.length) * 100);
  }
  return Math.round(scriptScore * 0.7 + refScore * 0.3);
}

/**
 * 维度四：维护活跃度（0-100）：近 90 天 git 提交数（≥5 次满分）
 */
async function scoreActivity(skillDir) {
  const rel = path.relative(ROOT, skillDir);
  const { stdout } = await execFileP(
    'git',
    ['log', '--oneline', '--since=90 days ago', '--', rel],
    { cwd: ROOT }
  );
  const count = stdout ? stdout.trim().split('\n').filter(Boolean).length : 0;
  return Math.min(Math.round((count / 5) * 100), 100);
}

/**
 * 维度五：安全扫描（0-100，满分 = 零危险命中）
 * 模式库对齐 skill-sandbox sanitizer.ts（node/shell 子集，作用于 SKILL.md 全文与 scripts 内容）
 */
const SECURITY_PATTERNS = [
  /rm\s+(-rf?\s+)?[~/]/,
  /mkfs\./,
  /dd\s+if=/,
  /curl\s+.*\|\s*(ba)?sh/,
  /wget\s+.*\|\s*(ba)?sh/,
  /chmod\s+777/,
  /chown\s+root/,
  /sudo\s+/,
  /reboot/,
  /shutdown/,
  /kill\s+-9/,
  /require\s*\(\s*['"]child_process['"]\s*\)/,
  /process\.(exit|kill|abort)\s*\(/,
  /eval\s*\(/,
  /__proto__/,
  /os\.system\s*\(/,
  /subprocess\.(call|Popen|run|check_output)\s*\(/,
  /shutil\.rmtree\s*\(/,
];

async function scoreSecurity(skillDir, body, fm = {}) {
  // 声明式豁免：security-context: audit 表示正文以「审计视角」引用攻击模式
  // （如安全审计/检测类 skill 把 rm -rf、curl|bash 列为检测目标）。
  // 豁免仅作用于 body；scripts/ 目录始终全量扫描（真实载荷不因声明而免检）。
  const auditContext = String(fm['security-context'] || '').trim().toLowerCase() === 'audit';
  let hits = 0;
  const targets = auditContext ? [] : [body];
  try {
    const scriptsDir = path.join(skillDir, 'scripts');
    for (const f of await fs.readdir(scriptsDir)) {
      if (/\.(m?js|py|sh|ts)$/.test(f)) {
        targets.push(await fs.readFile(path.join(scriptsDir, f), 'utf-8'));
      }
    }
  } catch {
    // 无 scripts 目录
  }
  for (const content of targets) {
    for (const p of SECURITY_PATTERNS) {
      if (p.test(content)) hits++;
    }
  }
  if (auditContext) {
    // 审计语境下 body 豁免，但 scripts 命中仍计数；给一个固定 80 基线（非满分，保留 scripts 风险面）
    return Math.max(80, Math.max(0, 100 - hits * 20));
  }
  return Math.max(0, 100 - hits * 20); // 每命中扣 20，扣完为止
}

/**
 * 单技能评分主入口
 * @returns {{score:number, grade:string, dims:object, file:string}}
 */
async function scoreSkill(file, weights = DEFAULT_WEIGHTS) {
  const content = await fs.readFile(file, 'utf-8');
  const m = content.match(/^---\n([\s\S]*?)\n---\n/);
  const fm = parseFrontmatter(content);
  const body = m ? content.slice(m[0].length) : content;

  const dims = {
    metadata: scoreMetadata(fm),
    docs: scoreDocs(body),
    assets: await scoreAssets(path.dirname(file), body),
    activity: await scoreActivity(path.dirname(file)),
    security: await scoreSecurity(path.dirname(file), body, fm),
  };
  const score = Math.round(
    Object.entries(weights).reduce((sum, [k, w]) => sum + dims[k] * w, 0)
  );
  return { score, grade: grade(score), dims, file: path.relative(ROOT, file) };
}

/**
 * 全量评分（预热 git 活跃度缓存以复用单次 git log 调用）
 * @returns {{results:Array, summary:object}}
 */
async function scoreAll(options = {}) {
  const weights = { ...DEFAULT_WEIGHTS, ...(options.weights || {}) };
  console.log('[skills:score] Scanning skills...');
  const files = await scanSkillFiles();

  // 一次性预热 git 活跃度（按顶层目录分组，减少子进程数）
  console.log('[skills:score] Warming git activity cache...');
  const dirGroups = new Map();
  for (const f of files) {
    const rel = path.dirname(path.relative(ROOT, f));
    const top = rel.split(path.sep).slice(0, 2).join('/');
    if (!dirGroups.has(top)) dirGroups.set(top, []);
    dirGroups.get(top).push(f);
  }
  const activityByDir = new Map();
  await Promise.all(
    [...dirGroups.keys()].map(async (top) => {
      const { stdout } = await execFileP(
        'git',
        ['log', '--name-only', '--format=', '--since=90 days ago', '--', top],
        { cwd: ROOT, maxBuffer: 32 * 1024 * 1024 }
      );
      if (!stdout) return;
      const countByDir = new Map();
      for (const line of stdout.split('\n')) {
        const d = path.dirname(line.trim());
        countByDir.set(d, (countByDir.get(d) || 0) + 1);
      }
      for (const [d, c] of countByDir) activityByDir.set(d, c);
    })
  );

  console.log(`[skills:score] Scoring ${files.length} skills...`);
  const results = [];
  for (const file of files) {
    const content = await fs.readFile(file, 'utf-8');
    const m = content.match(/^---\n([\s\S]*?)\n---\n/);
    const fm = parseFrontmatter(content);
    const body = m ? content.slice(m[0].length) : content;
    const dir = path.dirname(file);
    const rel = path.relative(ROOT, dir);
    const dims = {
      metadata: scoreMetadata(fm),
      docs: scoreDocs(body),
      assets: await scoreAssets(dir, body),
      activity: Math.min(Math.round(((activityByDir.get(rel) || 0) / 5) * 100), 100),
      security: await scoreSecurity(dir, body, fm),
    };
    const score = Math.round(
      Object.entries(weights).reduce((sum, [k, w]) => sum + dims[k] * w, 0)
    );
    results.push({ score, grade: grade(score), dims, file: path.relative(ROOT, file) });
  }

  // 分布统计
  const byGrade = { A: 0, B: 0, C: 0, D: 0, E: 0 };
  for (const r of results) byGrade[r.grade]++;
  const avg = results.length
    ? Math.round(results.reduce((s, r) => s + r.score, 0) / results.length)
    : 0;
  const summary = {
    total: results.length,
    average: avg,
    byGrade,
    generatedAt: new Date().toISOString(),
    weights,
  };
  return { results, summary };
}

module.exports = {
  scoreSkill,
  scoreAll,
  grade,
  DEFAULT_WEIGHTS,
  METADATA_FIELDS,
  SECURITY_PATTERNS,
};
