# YYC3 MCP 服务器配置指南

> ***YanYuCloudCube***
> 言启象限 | 语枢未来
> ***Words Initiate Quadrants, Language Serves as Core for Future***
> 万象归元于云枢 | 深栈智启新纪元
> ***All things converge in cloud pivot; Deep stacks ignite a new era of intelligence***

---

> Model Context Protocol 配置与使用

## 📋 已安装的MCP服务器

从 `/Users/yanyu/yyc3-claude/claude-prompts-mcp` 发现的MCP服务器:

### 1. Claude Prompts MCP

- **路径**: `/Users/yanyu/yyc3-claude/claude-prompts-mcp`
- **功能**: 提示词模板管理
- **状态**: 已安装

## 🔧 推荐的MCP服务器配置

### 文件系统访问

```json
{
  "mcpServers": {
    "filesystem": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "/Users/yanyu"]
    }
  }
}
```

### GitHub集成

```json
{
  "mcpServers": {
    "github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"]
    },
    "github-auth": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": {
        "GITHUB_TOKEN": "your_github_token"
      }
    }
  }
}
```

### 数据库访问

```json
{
  "mcpServers": {
    "sqlite": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-sqlite", "--db-path", "/path/to/database.db"]
    }
  }
}
```

### Web搜索

```json
{
  "mcpServers": {
    "brave-search": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-brave-search"],
      "env": {
        "BRAVE_API_KEY": "your_brave_api_key"
      }
    }
  }
}
```

### YYC3专用MCP服务器

#### 1. YYC3项目管理器

```typescript
// servers/yyc3-project-manager/src/index.ts
import { Server } from "@modelcontextprotocol/sdk/server/index.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";

const server = new Server({
  name: "yyc3-project-manager",
  version: "1.0.0"
});

// 项目列表工具
server.setRequestHandler("tools/list", async () => ({
  tools: [
    {
      name: "list_yyc3_projects",
      description: "列出所有YYC3项目",
      inputSchema: {
        type: "object",
        properties: {
          category: {
            type: "string",
            description: "项目分类 (management/ai/float/industry)",
            enum: ["management", "ai", "float", "industry", "infra", "tools"]
          }
        }
      }
    },
    {
      name: "get_project_info",
      description: "获取项目详细信息",
      inputSchema: {
        type: "object",
        properties: {
          projectName: {
            type: "string",
            description: "项目名称"
          }
        },
        required: ["projectName"]
      }
    }
  ]
}));

server.setRequestHandler("tools/call", async (request) => {
  const { name, arguments: args } = request.params;

  switch (name) {
    case "list_yyc3_projects":
      // 返回YYC3项目列表
      return {
        content: [{
          type: "text",
          text: JSON.stringify({
            projects: [
              { name: "yyc3-mana", category: "management", tech: "Next.js 14" },
              { name: "YYC3-PortAISys", category: "float", tech: "Five-dimension" },
              { name: "yyc3-learning-platform", category: "ai", tech: "AI Platform" }
            ]
          })
        }]
      };

    case "get_project_info":
      // 返回项目详情
      return {
        content: [{
          type: "text",
          text: `Project: ${args.projectName}\nDetails from ecosystem analysis...`
        }]
      };

    default:
      throw new Error(`Unknown tool: ${name}`);
  }
});

async function main() {
  const transport = new StdioServerTransport();
  await server.connect(transport);
}

main().catch(console.error);
```

#### 2. YYC3代码生成器

```typescript
// servers/yyc3-codegen/src/index.ts
import { Server } from "@modelcontextprotocol/sdk/server/index.js";

const server = new Server({
  name: "yyc3-codegen",
  version: "1.0.0"
});

server.setRequestHandler("tools/list", async () => ({
  tools: [
    {
      name: "generate_component",
      description: "生成YYC3标准React组件",
      inputSchema: {
        type: "object",
        properties: {
          componentName: { type: "string" },
          type: {
            type: "string",
            enum: ["functional", "class", "ai-enhanced"]
          },
          features: {
            type: "array",
            items: { type: "string" }
          }
        },
        required: ["componentName"]
      }
    },
    {
      name: "generate_api_route",
      description: "生成Next.js API路由",
      inputSchema: {
        type: "object",
        properties: {
          path: { type: "string" },
          method: {
            type: "string",
            enum: ["GET", "POST", "PUT", "DELETE"]
          }
        },
        required: ["path", "method"]
      }
    }
  ]
}));
```

#### 3. YYC3部署助手

```typescript
// servers/yyc3-deploy/src/index.ts
server.setRequestHandler("tools/list", async () => ({
  tools: [
    {
      name: "deploy_project",
      description: "部署YYC3项目到各种平台",
      inputSchema: {
        type: "object",
        properties: {
          project: { type: "string" },
          platform: {
            type: "string",
            enum: ["vercel", "ecs", "nas", "docker"]
          },
          environment: {
            type: "string",
            enum: ["dev", "staging", "prod"]
          }
        },
        required: ["project", "platform"]
      }
    }
  ]
}));
```

## 🚀 创建自定义MCP服务器

### 模板结构

```
mcp-servers/
├── yyc3-custom-server/
│   ├── package.json
│   ├── tsconfig.json
│   ├── src/
│   │   └── index.ts
│   └── README.md
```

### 快速创建

```bash
# 进入MCP服务器目录
cd /Users/yanyu/yyc3-claude/mcp-servers

# 创建新服务器
mkdir yyc3-my-server
cd yyc3-my-server

# 初始化项目
bun init -y

# 安装依赖
bun add @modelcontextprotocol/sdk

# 创建服务器模板
cat > src/index.ts << 'EOF'
import { Server } from "@modelcontextprotocol/sdk/server/index.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";

const server = new Server({
  name: "yyc3-my-server",
  version: "1.0.0"
});

// 添加你的工具逻辑

async function main() {
  const transport = new StdioServerTransport();
  await server.connect(transport);
}

main().catch(console.error);
EOF
```

## 📝 配置Claude Code使用MCP

### 编辑Claude配置文件

```bash
# macOS配置路径
~/Library/Application Support/Claude/claude_desktop_config.json

# 添加MCP服务器
{
  "mcpServers": {
    "yyc3-project-manager": {
      "command": "bun",
      "args": ["/Users/yanyu/yyc3-claude/mcp-servers/yyc3-project-manager/src/index.ts"]
    },
    "yyc3-codegen": {
      "command": "bun",
      "args": ["/Users/yanyu/yyc3-claude/mcp-servers/yyc3-codegen/src/index.ts"]
    }
  }
}
```

## 🔍 测试MCP服务器

```bash
# 运行服务器
bun run src/index.ts

# 在Claude Code中测试
# 1. 启动Claude Code
# 2. 使用/调用MCP工具
```

## 📚 参考资源

- [MCP官方文档](https://modelcontextprotocol.io)
- [Claude Code文档](https://docs.anthropic.com/claude-code)
- [YYC3项目仓库](https://github.com/YYC-Cube)

---

**零摩擦AI协同开发**

---

> 「***YanYuCloudCube***」
> 「***<admin@0379.email>***」
> 「***Words Initiate Quadrants, Language Serves as Core for Future***」
> 「***All things converge in cloud pivot; Deep stacks ignite a new era of intelligence***」
