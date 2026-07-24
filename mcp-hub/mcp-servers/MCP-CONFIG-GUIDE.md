{
  "mcpServers": {
    "yyc3-cn-assistant": {
      "command": "node",
      "args": [
        "/Users/yanyu/www/API文档/YYC3-CN/代码/yyc3-cn-mcp-server.js"
      ],
      "env": {
        "TRAE_CN_MODE": "development",
        "NODE_ENV": "development"
      }
    },
    "mcp-github-yyc3": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "YOUR_GITHUB_TOKEN_HERE"
      }
    },
    "mcp-filesystem": {
      "command": "npx",
      "args": [
        "-y",
        "@modelcontextprotocol/server-filesystem",
        "/Users/yanyu"
      ]
    },
    "mcp-brave-search": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-brave-search"],
      "env": {
        "BRAVE_API_KEY": "YOUR_BRAVE_API_KEY_HERE"
      }
    },
    "mcp-postgres": {
      "command": "npx",
      "args": [
        "-y",
        "@modelcontextprotocol/server-postgres",
        "postgresql://user:password@localhost:5432/yyc3"
      ]
    },
    "mcp-docker": {
      "command": "docker",
      "args": [
        "run",
        "-i",
        "--rm",
        "-v",
        "/var/run/docker.sock:/var/run/docker.sock",
        "mcp-server-docker"
      ]
    }
  }
}
