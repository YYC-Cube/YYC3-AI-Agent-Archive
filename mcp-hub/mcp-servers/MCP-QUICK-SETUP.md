# MCP Servers Quick Setup Guide

> ***YanYuCloudCube***
> 言启象限 | 语枢未来
> ***Words Initiate Quadrants, Language Serves as Core for Future***
> 万象归元于云枢 | 深栈智启新纪元
> ***All things converge in cloud pivot; Deep stacks ignite a new era of intelligence***

---

> **YYC3-Claude MCP Configuration**
> **Created**: 2026-01-29
> **Status**: Configuration Complete, Awaiting API Keys

---

## Current Status

| MCP Server | Status | Action Required |
|------------|--------|-----------------|
| **yyc3-cn-assistant** | ✅ Ready | None |
| **mcp-filesystem** | ✅ Ready | None |
| **mcp-docker** | ✅ Ready | None |
| **mcp-github-yyc3** | ⚠️ Pending | Add GitHub Token |
| **mcp-brave-search** | ⚠️ Pending | Add Brave API Key |
| **mcp-postgres** | ⚠️ Pending | Add Database URL |

---

## Quick Setup (3 Steps)

### Step 1: Get Your API Keys

#### GitHub Personal Access Token

```bash
# Visit: https://github.com/settings/tokens
# Create a new token with scopes:
# - repo (full control)
# - read:org
# - read:user
# - user:email
```

#### Brave Search API Key

```bash
# Visit: https://api.search.brave.com/app/keys
# Sign up and get your API key
```

#### PostgreSQL Connection (Optional)

```bash
# Format: postgresql://user:password@host:port/database
# Example: postgresql://yyc3:user:pass@localhost:5432/yyc3
# Or use Docker: docker run -d -p 5432:5432 postgres:15
```

### Step 2: Update Environment File

Edit `.env.mcp` in the project root:

```bash
# Edit the file with your actual keys
nano /Users/yanyu/yyc3-claude/.env.mcp

# Or use VS Code
code /Users/yanyu/yyc3-claude/.env.mcp
```

Replace placeholder values:

```env
GITHUB_PERSONAL_ACCESS_TOKEN=ghp_YOUR_ACTUAL_TOKEN_HERE
BRAVE_API_KEY=BSYOUR_ACTUAL_API_KEY_HERE
DATABASE_URL=postgresql://user:password@localhost:5432/yyc3
```

### Step 3: Activate MCP Servers

Run the activation script:

```bash
/Users/yanyu/yyc3-claude/automation-scripts/activate-mcp.sh
```

Then copy the MCP config to Claude:

```bash
# Backup existing config
cp ~/Library/Application\ Support/Claude/claude_desktop_config.json \
   ~/Library/Application\ Support/Claude/claude_desktop_config.json.backup

# Copy YYC3 MCP config
cp /Users/yanyu/yyc3-claude/mcp-servers/mcp-config.json \
   ~/Library/Application\ Support/Claude/claude_desktop_config.json
```

Restart Claude Code to apply changes.

---

## Verification

Test each MCP server after activation:

```bash
# Test GitHub integration
claude "List my recent repositories"

# Test Brave Search
claude "Search for 'Next.js 16 features'"

# Test Filesystem
claude "List files in /Users/yanyu/yyc3-claude"

# Test Docker
claude "List running Docker containers"
```

---

## Troubleshooting

### GitHub Token Not Working

- ✅ Check token has correct scopes
- ✅ Verify token hasn't expired
- ✅ Ensure no extra spaces in token

### Brave Search Errors

- ✅ Verify API key is valid
- ✅ Check API quota not exceeded
- ✅ Ensure key is copied correctly

### Docker Permission Issues

```bash
# Fix Docker permissions
sudo chown $USER /var/run/docker.sock

# Or add user to docker group
sudo usermod -aG docker $USER
```

---

## Files Reference

| File | Purpose |
|------|---------|
| `.env.mcp` | Environment variables (API keys) |
| `mcp-servers/mcp-config.json` | MCP server configuration |
| `automation-scripts/activate-mcp.sh` | Activation script |
| `mcp-servers/MCP-CONFIG-GUIDE.md` | Full documentation |

---

**Last Updated**: 2026-01-29
**Version**: 1.0.0

---

> 「***YanYuCloudCube***」
> 「***<admin@0379.email>***」
> 「***Words Initiate Quadrants, Language Serves as Core for Future***」
> 「***All things converge in cloud pivot; Deep stacks ignite a new era of intelligence***」
