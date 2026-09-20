// @ts-check
import eslint from '@eslint/js';

/**
 * 根级 ESLint 9 Flat Config
 *
 * 职责边界：根配置只负责 scripts/ 与仓库级 JS 工具脚本。
 * 各 workspace 包（packages/*）拥有独立的 lint 配置：
 * - packages/yyc3-i18n → eslint.config.js（typescript-eslint）
 * - packages/yyc3-cli → node --check 语法检查
 * - packages/skill-registry / mcp-runtime → 遵循根 tsconfig strict 模式
 */
export default [
  {
    ignores: [
      'packages/**',
      '_external/**',
      '_archive/**',
      'skills-hub/**',
      'agents-hub/**',
      'plugins-hub/**',
      'mcp-hub/**',
      'tools-hub/**',
      'tools/**',
      'docs/**',
      'public/**',
      'skills/**',
      'core/**',
      'locales/**',
      'meta/**',
    ],
  },
  eslint.configs.recommended,
  {
    // CommonJS 仓库脚本（.js/.cjs 默认按 script 解析）
    files: ['**/*.js', '**/*.cjs'],
    languageOptions: {
      ecmaVersion: 2022,
      sourceType: 'script',
      globals: {
        console: 'readonly',
        process: 'readonly',
        Buffer: 'readonly',
        __dirname: 'readonly',
        __filename: 'readonly',
        module: 'readonly',
        require: 'readonly',
        exports: 'readonly',
        setTimeout: 'readonly',
        setInterval: 'readonly',
        clearTimeout: 'readonly',
        clearInterval: 'readonly',
        fetch: 'readonly',
      },
    },
    rules: {
      'no-unused-vars': ['error', { argsIgnorePattern: '^_' }],
    },
  },
  {
    // .mjs 按定义即 ESM（scripts/dismiss-vendor-alerts.mjs 等运维脚本）
    files: ['**/*.mjs'],
    languageOptions: {
      ecmaVersion: 2022,
      sourceType: 'module',
      globals: {
        console: 'readonly',
        process: 'readonly',
        fetch: 'readonly',
        setTimeout: 'readonly',
        clearTimeout: 'readonly',
      },
    },
    rules: {
      'no-unused-vars': ['error', { argsIgnorePattern: '^_' }],
    },
  },
];
