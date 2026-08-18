import { defineConfig } from 'vitest/config';
import { resolve } from 'path';

export default defineConfig({
  resolve: {
    alias: {
      // 测试直接引用 skill-registry 源码，避免先构建 dist
      '@yyc3/skill-registry': resolve(__dirname, '../skill-registry/src/index.ts'),
    },
  },
  test: {
    include: ['tests/**/*.test.ts'],
    environment: 'node',
  },
});
