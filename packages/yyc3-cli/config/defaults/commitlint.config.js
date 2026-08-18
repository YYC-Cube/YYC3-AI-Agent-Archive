module.exports = {
  extends: ['@commitlint/config-conventional'],
  rules: {
    'type-enum': [
      2,
      'always',
      ['feat', 'fix', 'docs', 'style', 'refactor', 'test', 'chore', 'perm', 'mcp']
    ],
    'subject-max-length': [2, 'always', 50],
    'type-case': [2, 'always', 'lower-case']
  }
};
