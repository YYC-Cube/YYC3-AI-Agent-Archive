# MCP Server Activation - Step-by-Step Guide

> ***YanYuCloudCube***
> 言启象限 | 语枢未来
> ***Words Initiate Quadrants, Language Serves as Core for Future***
> 万象归元于云枢 | 深栈智启新纪元
> ***All things converge in cloud pivot; Deep stacks ignite a new era of intelligence***

---

> **YYC3-Claude MCP Configuration**
> **Created**: 2026-01-29
> **Purpose**: Guide for activating all MCP servers

---

## Overview

This guide walks through activating all 6 MCP servers for YYC3-Claude. Three servers are ready to use immediately, while three require API keys.

## Server Status

| Server | Status | Action Required |
|--------|--------|-----------------|
| yyc3-cn-assistant | ✅ Ready | None |
| mcp-filesystem | ✅ Ready | None |
| mcp-docker | ✅ Ready | None |
| mcp-github-yyc3 | ⚠️ Pending | GitHub Token |
| mcp-brave-search | ⚠️ Pending | Brave API Key |
| mcp-postgres | ⚠️ Optional | Database URL |

---

## Step 1: GitHub Personal Access Token

### Why Needed

The GitHub MCP server requires a token to:

- Access your repositories
- Create pull requests
- Review code
- Manage issues

### How to Create

1. **Visit GitHub Settings**

   ```
   https://github.com/settings/tokens
   ```

2. **Generate New Token**
   - Click "Generate new token" → "Generate new token (classic)"

3. **Configure Token**

   ```
   Name: YYC3-Claude MCP
   Expiration: 90 days (or No expiration for development)

   Scopes (check these boxes):
   ☑ repo (Full control of private repositories)
   ☑ repo:status (Access commit status)
   ☑ repo_deployment (Access deployment status)
   ☑ public_repo (Access public repositories)
   ☑ read:org (Read org and team membership)
   ☑ read:user (Read user profile data)
   ☑ user:email (Read user email)
   ☑ read:gpg_key (Read GPG keys)
   ```

4. **Generate and Copy**
   - Click "Generate token"
   - **Copy the token immediately** (you won't see it again)
   - Format: `ghp_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx`

### Store Token

```bash
# Add to .env.mcp
echo "GITHUB_PERSONAL_ACCESS_TOKEN=ghp_YOUR_ACTUAL_TOKEN_HERE" >> .env.mcp
```

---

## Step 2: Brave Search API Key

### Why Needed

The Brave Search MCP server provides:

- Web search capabilities
- Current information retrieval
- Research assistance

### How to Create

1. **Visit Brave Search API**

   ```
   https://api.search.brave.com/app/keys
   ```

2. **Sign Up / Log In**
   - Create account or sign in with existing account

3. **Generate API Key**
   - Click "Create API Key"
   - Name it: `YYC3-Claude MCP`

4. **Copy API Key**
   - Format: `BSxxxxxxxxxxxxxx` or similar

### Store Key

```bash
# Add to .env.mcp
echo "BRAVE_API_KEY=BSYOUR_ACTUAL_API_KEY_HERE" >> .env.mcp
```

---

## Step 3: PostgreSQL (Optional)

### When Needed

Only required if you want to:

- Query databases
- Run data analysis
- Connect to existing PostgreSQL instances

### Options

**Option A: Use Existing Database**

```bash
# Format: postgresql://user:password@host:port/database
echo "DATABASE_URL=postgresql://your_user:your_password@localhost:5432/your_db" >> .env.mcp
```

**Option B: Use Docker (Quick Setup)**

```bash
# Start PostgreSQL in Docker
docker run -d \
  --name yyc3-postgres \
  -e POSTGRES_PASSWORD=yyc3_password \
  -e POSTGRES_DB=yyc3_db \
  -p 5432:5432 \
  postgres:15

# Connection string
echo "DATABASE_URL=postgresql://postgres:yyc3_password@localhost:5432/yyc3_db" >> .env.mcp
```

**Option C: Skip for Now**

```bash
# Leave as placeholder in .env.mcp
# The MCP server will be disabled if URL is not set
```

---

## Step 4: Update Environment File

### Manual Edit

```bash
# Open .env.mcp in editor
nano .env.mcp
```

Replace placeholder values:

```env
# YYC3 MCP Servers Environment Configuration

# GitHub Personal Access Token
GITHUB_PERSONAL_ACCESS_TOKEN=ghp_YOUR_ACTUAL_TOKEN_HERE

# Brave Search API Key
BRAVE_API_KEY=BSYOUR_ACTUAL_API_KEY_HERE

# PostgreSQL Connection String (optional)
DATABASE_URL=postgresql://user:password@localhost:5432/yyc3
```

### Verify File

```bash
cat .env.mcp
```

---

## Step 5: Run Activation Script

```bash
# Navigate to project directory
cd /Users/yanyu/yyc3-claude

# Make script executable (if not already)
chmod +x automation-scripts/activate-mcp.sh

# Run activation script
./automation-scripts/activate-mcp.sh
```

### Expected Output

```
=================================
YYC3 MCP Servers Activation
=================================

Creating .env.mcp file...
✓ Created .env.mcp template
Please edit .env.mcp with your actual API keys

Loading environment variables from .env.mcp...
✓ Environment variables loaded

Checking prerequisites...
✓ Node.js: v25.0.0
✓ npx is available
✓ Docker is available

=================================
MCP Server Status
=================================

✓ yyc3-cn-assistant: Server file exists
✓ mcp-github-yyc3: GitHub token configured
✓ mcp-filesystem: Ready (accessing /Users/yanyu)
✓ mcp-brave-search: Brave API key configured
✓ mcp-postgres: Database URL configured
✓ mcp-docker: Docker is running

=================================
Configuration Files
=================================

MCP Config: /Users/yanyu/yyc3-claude/mcp-servers/mcp-config.json
Environment: /Users/yanyu/yyc3-claude/.env.mcp
```

---

## Step 6: Deploy to Claude Desktop

### Backup Existing Config

```bash
# Create backup
cp ~/Library/Application\ Support/Claude/claude_desktop_config.json \
   ~/Library/Application\ Support/Claude/claude_desktop_config.json.backup
```

### Copy YYC3 MCP Config

```bash
# Copy YYC3 config
cp /Users/yanyu/yyc3-claude/mcp-servers/mcp-config.json \
   ~/Library/Application\ Support/Claude/claude_desktop_config.json
```

### Restart Claude Code

```bash
# Quit Claude Code completely
# Then restart it
claude
```

---

## Step 7: Verify MCP Servers

### Test in Claude Code

After restarting Claude Code, test each MCP server:

```bash
# Test 1: Filesystem (should work immediately)
claude "List files in /Users/yanyu/yyc3-claude"

# Test 2: GitHub (requires token)
claude "List my GitHub repositories"

# Test 3: Brave Search (requires API key)
claude "Search for 'Next.js 16 features'"

# Test 4: Docker (should work)
claude "List running Docker containers"

# Test 5: PostgreSQL (if configured)
claude "Query the yyc3 database"
```

### Expected Behavior

**Successful**:

- Claude responds with actual data from the service
- No error messages about missing connections
- MCP server logs show successful connections

**If Failing**:

- Check API keys are correct (no extra spaces)
- Verify token scopes are correct
- Check MCP server logs for errors
- Restart Claude Code again

---

## Troubleshooting

### GitHub Token Not Working

**Symptom**: "GitHub token not set" error

**Solutions**:

1. Check token has correct scopes
2. Verify no extra spaces in token
3. Ensure token hasn't expired
4. Regenerate token if needed

### Brave Search Errors

**Symptom**: "Brave API key not set" error

**Solutions**:

1. Verify API key is correct
2. Check API quota not exceeded
3. Ensure key is active (not disabled)
4. Contact Brave support if needed

### Docker Permission Issues

**Symptom**: "Permission denied" error

**Solutions**:

```bash
# Fix Docker permissions
sudo chown $USER /var/run/docker.sock

# Or add user to docker group
sudo usermod -aG docker $USER
# Then log out and back in
```

### Config Not Loading

**Symptom**: MCP servers not showing in Claude

**Solutions**:

1. Verify config file path is correct
2. Check JSON syntax is valid
3. Restart Claude Code completely
4. Check Claude logs for errors

---

## Security Best Practices

### Protecting API Keys

1. **Never commit .env.mcp to Git**

   ```bash
   # Already in .gitignore
   .env.mcp
   ```

2. **Rotate Keys Regularly**
   - GitHub tokens: Every 90 days
   - API keys: Every 6 months

3. **Use Minimum Required Scopes**
   - Don't grant more permissions than needed

4. **Monitor Usage**
   - Check GitHub token usage
   - Monitor API quota usage

### If Keys Are Exposed

1. **Revoke Immediately**
   - GitHub: <https://github.com/settings/tokens>
   - Brave: <https://api.search.brave.com/app/keys>

2. **Generate New Keys**
   - Follow creation steps above

3. **Update .env.mcp**
   - Replace old keys with new ones

4. **Restart Claude Code**
   - New keys will be loaded

---

## Next Steps

After successful MCP activation:

1. ✅ **Test All MCP Servers**
   - Verify each server responds correctly

2. ✅ **Integrate with Workflows**
   - Use MCP servers in daily development

3. ✅ **Monitor Performance**
   - Check response times
   - Verify data accuracy

4. ✅ **Document Usage**
   - Note any special configurations
   - Record common commands

---

## Quick Reference

| Command | Purpose |
|---------|---------|
| `./automation-scripts/activate-mcp.sh` | Run activation check |
| `cat .env.mcp` | View environment variables |
| `nano .env.mcp` | Edit API keys |
| `cp mcp-servers/mcp-config.json ~/Library/Application\ Support/Claude/` | Deploy config |
| `claude` | Restart Claude Code |

---

**Last Updated**: 2026-01-29
**Version**: 1.0.0

---

> 「***YanYuCloudCube***」
> 「***<admin@0379.email>***」
> 「***Words Initiate Quadrants, Language Serves as Core for Future***」
> 「***All things converge in cloud pivot; Deep stacks ignite a new era of intelligence***」
