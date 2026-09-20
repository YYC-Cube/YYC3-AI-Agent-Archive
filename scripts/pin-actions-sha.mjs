#!/usr/bin/env node
/**
 * Pin all third-party GitHub Actions to their current tag commit SHA.
 * One-off migration helper for Task E2 (supply-chain hardening).
 * Idempotent: already-pinned refs are left untouched.
 */
import { readFileSync, writeFileSync } from 'node:fs';

const pins = {
  'actions/checkout@v7': '3d3c42e5aac5ba805825da76410c181273ba90b1',
  'actions/configure-pages@v5': '983d7736d9b0ae728b81ab479565c72886d7745b',
  'actions/upload-pages-artifact@v3': '56afc609e74202658d3ffba0e8f6dda462b719fa',
  'actions/deploy-pages@v4': 'd6db90164ac5ed86f2b6aed7e0febac5b3c0c03e',
  'pnpm/action-setup@v6': '0977fd99725f1db4007ccb2928dbb4e90d06cc86',
  'actions/setup-node@v4': '49933ea5288caeca8642d1e84afbd3f7d6820020',
  'docker/setup-buildx-action@v3': '8d2750c68a42422c14e847fe6c8ac0403b4cbd6f',
  'docker/login-action@v3': 'c94ce9fb468520275223c153574b00df6fe4bcc9',
  'docker/build-push-action@v6': '10e90e3645eae34f1e60eeb005ba3a3d33f178e8',
  'mikepenz/release-changelog-builder-action@v6': 'cb021f9b36a51a7c6f18e4679b6fa2cb77a1260c',
  'softprops/action-gh-release@v3': 'efb35369e0ad2afab669f228072c1b0d510eae64',
  'gitleaks/gitleaks-action@v3': 'e0c47f4f8be36e29cdc102c57e68cb5cbf0e8d1e',
};

const files = ['ci.yml', 'security.yml', 'release.yml', 'pages.yml'].map(
  (f) => `.github/workflows/${f}`
);

let total = 0;
for (const f of files) {
  let src = readFileSync(f, 'utf8');
  let n = 0;
  for (const [ref, sha] of Object.entries(pins)) {
    const at = ref.lastIndexOf('@');
    const action = ref.slice(0, at);
    const ver = ref.slice(at + 1);
    const re = new RegExp(`uses: ${action.replaceAll('/', '/')}@${ver}(?=[\\s])`, 'g');
    src = src.replace(re, () => {
      n++;
      return `uses: ${action}@${sha} # ${ver}`;
    });
  }
  writeFileSync(f, src);
  console.log(`${f}: ${n} replaced`);
  total += n;
}
console.log(`TOTAL: ${total}`);
