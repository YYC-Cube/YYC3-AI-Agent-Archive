// 团队yyc3 MCP核心配置
module.exports = {
  // 服务连接
  server: {
    url: process.env.MCP_SERVER_URL || 'http://localhost:8080',
    apiKey: process.env.MCP_API_KEY || '',
    timeout: 10000
  },
  // 权限管控
  permissions: {
    role: process.env.MCP_ROLE || 'developer',
    allowPaths: ['/src/**', '/test/**'],
    denyPaths: ['.env', '.access-keys', 'rbac.config.js'],
    audit: true // 开启操作审计
  },
  // 智能协同策略
  strategy: {
    codeCompletion: true,
    codeReview: true,
    testGenerate: true,
    permissionCheck: true // 基于RBAC的权限补全
  },
  // 缓存配置
  cache: {
    enable: true,
    dir: './mcp-cache',
    ttl: 3600
  }
};
