const fs = require('fs');
const zh = JSON.parse(fs.readFileSync(process.argv[2] || 'locales/zh-CN.json', 'utf-8'));
const en = {};
for (const k of Object.keys(zh)) {
  const v = zh[k];
  if (k.startsWith('brand.slogan.primary')) en[k] = 'All things converge in cloud pivot';
  else if (k.startsWith('brand.slogan.secondary')) en[k] = 'Deep stacks ignite a new era of intelligence';
  else if (k.startsWith('brand.name.full')) en[k] = 'YYC3 CloudCube';
  else if (k.startsWith('agent') && k.endsWith('.name')) {
    const names = { tianshu: 'Celestial Pivot', qianhang: 'Thousand Voyages', allthings: 'Myriad Things', prophet: 'Foresight Prophet', bole: 'Sage Recommender', guardian: 'Wisdom Guardian', grandmaster: 'Grandmaster', grace: 'Creative Grace' };
    en[k] = names[k.split('.')[1]] || v;
  } else if (k.startsWith('agent') && k.endsWith('.role')) {
    const roles = { tianshu: 'Chief Commander', qianhang: 'Chief Navigator', allthings: 'Chief Analyst', prophet: 'Chief Prophet', bole: 'Chief Recommender', guardian: 'Chief Security Officer', grandmaster: 'Chief Quality Officer', grace: 'Chief Creative Officer' };
    en[k] = roles[k.split('.')[1]] || v;
  } else if (k.startsWith('skill') && k.endsWith('.name')) {
    en[k] = v.replace(/[\u4e00-\u9fff]/g, '').trim() || v;
  } else {
    en[k] = v;
  }
}
const outPath = process.argv[3] || 'locales/en.json';
fs.writeFileSync(outPath, JSON.stringify(en, null, 2));
console.log('Generated ' + Object.keys(en).length + ' keys -> ' + outPath);
