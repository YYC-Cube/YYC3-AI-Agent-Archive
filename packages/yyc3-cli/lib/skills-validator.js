/**
 * @file skills-validator.js
 * @description Skills 完整性验证
 */
const fs = require('fs').promises;
const path = require('path');
const { scanSkillFiles, parseFrontmatter } = require('./skills-indexer');
const ROOT = require('./skills-indexer').ROOT || path.resolve(__dirname, '../..');

async function validateFrontmatter(files) {
  const errors = [];
  const required = ['name', 'description', 'version'];
  for (const f of files) {
    const meta = parseFrontmatter(await fs.readFile(f, 'utf-8'));
    for (const field of required) {
      if (!meta[field]) errors.push({ file: path.relative(ROOT, f), field, msg: 'Missing: ' + field });
    }
    if (meta.version && !/^\d+\.\d+\.\d+$/.test(meta.version))
      errors.push({ file: path.relative(ROOT, f), field: 'version', msg: 'Not semver: ' + meta.version, severity: 'warn' });
  }
  return errors;
}

async function validateAll(options) {
  options = options || {};
  console.log('[skills:validate] Scanning...');
  const files = await scanSkillFiles();
  console.log('[skills:validate] Checking frontmatter...');
  const fmErrors = await validateFrontmatter(files);
  const errors = fmErrors.filter(e => e.severity !== 'warn');
  const warns = fmErrors.filter(e => e.severity === 'warn');
  console.log('[skills:validate] Files: ' + files.length + ', Errors: ' + errors.length + ', Warnings: ' + warns.length);
  if (options.verbose) {
    for (const e of errors) console.log('  ERROR: ' + e.file + ' - ' + e.msg);
    for (const w of warns) console.log('  WARN: ' + w.file + ' - ' + w.msg);
  }
  return { errors, warnings: warns, total: files.length };
}

module.exports = { validateAll, validateFrontmatter };
