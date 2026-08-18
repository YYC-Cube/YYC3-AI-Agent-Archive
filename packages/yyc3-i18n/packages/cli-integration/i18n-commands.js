/**
 * @file i18n-commands.js
 * @description YYC³ CLI i18n 命令集成方案 — 复制到 YYC3-CLI/lib/i18n.js 使用
 * @module cli/i18n
 * @author YYC³
 * @version 1.0.0
 */

const fs = require('fs').promises;
const path = require('path');

/**
 * i18n init — 在项目中初始化 @yyc3/i18n-core 配置
 * 用法: yyc3 i18n init [path] --locales en,zh-CN --react
 */
async function initI18n(projectPath = '.', options = {}) {
  const targetDir = path.resolve(projectPath);
  const localesDir = path.join(targetDir, 'src', 'locales');
  const locales = options.locales
    ? options.locales.split(',').map((l) => l.trim())
    : ['en', 'zh-CN'];

  console.log(`\n🌐 初始化 i18n (语言: ${locales.join(', ')})...`);

  await fs.mkdir(localesDir, { recursive: true });

  for (const locale of locales) {
    const filePath = path.join(localesDir, `${locale}.json`);
    const isEn = locale === 'en';
    const isZh = locale.startsWith('zh');
    const content = {
      common: {
        welcome: isEn ? 'Welcome' : isZh ? '欢迎' : 'Welcome',
        save: isEn ? 'Save' : isZh ? '保存' : 'Save',
        cancel: isEn ? 'Cancel' : isZh ? '取消' : 'Cancel',
      },
      nav: {
        home: isEn ? 'Home' : isZh ? '首页' : 'Home',
        settings: isEn ? 'Settings' : isZh ? '设置' : 'Settings',
      },
    };

    try {
      await fs.access(filePath);
      console.log(`   ⏭️  ${locale}.json 已存在，跳过`);
    } catch {
      await fs.writeFile(filePath, JSON.stringify(content, null, 2) + '\n');
      console.log(`   ✅ 创建 ${locale}.json`);
    }
  }

  // 生成引擎配置文件
  const configPath = path.join(targetDir, 'src', 'lib', 'i18n.ts');
  await fs.mkdir(path.dirname(configPath), { recursive: true });

  const configContent = `/**
 * i18n 配置 — 由 yyc3 i18n init 生成
 * 文档: https://github.com/YYC-Cube/YYC3-i18n-Core
 */
import { I18nEngine } from '@yyc3/i18n-core';

export const i18nEngine = new I18nEngine({
  locale: '${locales[0]}',
  fallbackLocale: '${locales[0]}',
});

export const supportedLocales = ${JSON.stringify(locales, null, 2)};
`;

  await fs.writeFile(configPath, configContent);
  console.log(`   ✅ 创建 src/lib/i18n.ts`);

  console.log('\n🚀 i18n 初始化完成！');
  console.log('   安装依赖: pnpm add @yyc3/i18n-core');
  if (options.react) {
    console.log('   React 集成: pnpm add @yyc3/i18n-react');
  }
  console.log('   MCP Server: 详见 @yyc3/i18n-core/mcp');
}

/**
 * i18n extract — 从源码提取翻译键
 * 用法: yyc3 i18n extract "src/**/*.{ts,tsx}" --output locales/keys.json
 */
async function extractKeys(sourceGlob = 'src/**/*.{ts,tsx}', options = {}) {
  const { glob } = require('glob');
  const files = await glob(sourceGlob.replace(/["']/g, ''), {
    ignore: ['node_modules/**', 'dist/**', 'coverage/**'],
  });

  const keys = new Set();
  // 匹配 t('key') / t("key") / t(`key`) 调用
  const keyPattern = /\bt\(\s*['"`]([^'"`]+)['"`]/g;

  for (const file of files) {
    try {
      const content = await fs.readFile(file, 'utf8');
      let match;
      while ((match = keyPattern.exec(content)) !== null) {
        keys.add(match[1]);
      }
    } catch { /* skip binary files */ }
  }

  const sortedKeys = [...keys].sort();
  const output = options.output || 'locales/extracted-keys.json';
  await fs.mkdir(path.dirname(output), { recursive: true }).catch(() => {});
  await fs.writeFile(output, JSON.stringify({ keys: sortedKeys }, null, 2));

  console.log(`\n✅ 提取了 ${sortedKeys.length} 个翻译键 → ${output}`);
  if (sortedKeys.length > 0 && sortedKeys.length <= 30) {
    console.log('   键列表:');
    sortedKeys.forEach((k) => console.log(`     • ${k}`));
  }
}

/**
 * i18n audit — 审计翻译覆盖率
 * 用法: yyc3 i18n audit src/locales --output report.json
 */
async function auditCoverage(localesDir = 'src/locales', options = {}) {
  const targetDir = path.resolve(localesDir);
  let files;
  try {
    files = await fs.readdir(targetDir);
  } catch {
    console.error(`\n🔴 找不到语言目录: ${targetDir}`);
    process.exit(1);
  }

  const localeFiles = files.filter((f) => f.endsWith('.json'));
  if (localeFiles.length === 0) {
    console.error(`\n🔴 语言目录中没有 .json 文件: ${targetDir}`);
    process.exit(1);
  }

  const localeData = {};
  for (const file of localeFiles) {
    const content = JSON.parse(
      await fs.readFile(path.join(targetDir, file), 'utf8'),
    );
    localeData[file.replace('.json', '')] = content;
  }

  // 扁平化嵌套键
  const flatten = (obj, prefix = '') => {
    const result = {};
    for (const [k, v] of Object.entries(obj)) {
      const key = prefix ? `${prefix}.${k}` : k;
      if (typeof v === 'object' && v !== null) {
        Object.assign(result, flatten(v, key));
      } else {
        result[key] = v;
      }
    }
    return result;
  };

  const flatLocales = {};
  for (const [locale, data] of Object.entries(localeData)) {
    flatLocales[locale] = flatten(data);
  }

  const baseLocale = Object.keys(flatLocales)[0];
  const baseKeys = Object.keys(flatLocales[baseLocale]);

  console.log(`\n📊 i18n 覆盖率审计 (基准: ${baseLocale}, ${baseKeys.length} 键)`);
  console.log('─'.repeat(60));

  const report = {};
  for (const [locale, data] of Object.entries(flatLocales)) {
    const localeKeys = Object.keys(data);
    const missing = baseKeys.filter((k) => !(k in data));
    const extra = localeKeys.filter((k) => !(k in baseKeys));
    const coverage =
      baseKeys.length > 0
        ? (((baseKeys.length - missing.length) / baseKeys.length) * 100).toFixed(1)
        : '100.0';

    const status = parseFloat(coverage) === 100 ? '✅' : parseFloat(coverage) >= 80 ? '⚠️' : '🔴';
    console.log(
      `  ${status} ${locale.padEnd(10)} ${coverage}% (${localeKeys.length}键, ${missing.length}缺失)`,
    );

    report[locale] = { coverage: parseFloat(coverage), missing, extra };
  }

  if (options.output) {
    await fs.writeFile(options.output, JSON.stringify(report, null, 2));
    console.log(`\n📄 报告已保存到 ${options.output}`);
  }
}

module.exports = { initI18n, extractKeys, auditCoverage };
