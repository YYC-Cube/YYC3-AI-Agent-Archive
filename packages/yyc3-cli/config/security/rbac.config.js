// 团队yyc3 RBAC权限核心配置
module.exports = {
  team: "yyc3",
  roles: ["guest", "developer", "tester", "admin"],
  permissions: [
    { name: "api:user:read", resource: "/api/user" },
    { name: "api:user:write", resource: "/api/user" },
    { name: "config:permissions:modify", resource: "/config/permissions" },
    { name: "mcp:audit:view", resource: "/mcp/audit-logs" }
  ],
  rolePermissions: {
    guest: ["api:user:read"],
    developer: ["api:user:read", "api:user:write"],
    tester: ["api:user:read"],
    admin: ["**"]
  },
  envRules: {
    development: { enforce: false },
    production: { enforce: true }
  }
};
