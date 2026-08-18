module.exports = {
  // 团队yyc3 仅校验提交的文件
  '*.{js,ts,jsx,tsx}': [
    'eslint --fix',
    'prettier --write'
  ],
  '*.{json,yml,yaml,md}': [
    'prettier --write'
  ],
  '*.{js,ts}': [
    'node -c' // 语法校验
  ],
  'rbac.config.js|mcp-roles.json': [
    'node -c' // 权限配置文件专属校验
  ]
};
