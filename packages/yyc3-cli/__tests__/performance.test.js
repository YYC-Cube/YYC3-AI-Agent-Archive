const { exec } = require('child_process');
const util = require('util');
const execPromise = util.promisify(exec);
const path = require('path');

describe('YYC3 CLI - Performance Tests', () => {
  const cliPath = path.join(__dirname, '../bin/yyc3-cli.js');
  const VERSION_THRESHOLD = 500;
  const HELP_THRESHOLD = 1000;

  test('version command responds within threshold', async () => {
    const start = Date.now();
    await execPromise(`node ${cliPath} --version`);
    const elapsed = Date.now() - start;
    console.log(`Version command: ${elapsed}ms`);
    expect(elapsed).toBeLessThan(VERSION_THRESHOLD);
  });

  test('help command responds within threshold', async () => {
    const start = Date.now();
    await execPromise(`node ${cliPath} --help`);
    const elapsed = Date.now() - start;
    console.log(`Help command: ${elapsed}ms`);
    expect(elapsed).toBeLessThan(HELP_THRESHOLD);
  });

  test('concurrent commands all succeed', async () => {
    const promises = Array.from({ length: 5 }, () =>
      execPromise(`node ${cliPath} --version`)
        .then(() => ({ ok: true }))
        .catch(() => ({ ok: false }))
    );
    const results = await Promise.all(promises);
    const successes = results.filter(r => r.ok).length;
    console.log(`Concurrent: ${successes}/5 succeeded`);
    expect(successes).toBe(5);
  });
});
