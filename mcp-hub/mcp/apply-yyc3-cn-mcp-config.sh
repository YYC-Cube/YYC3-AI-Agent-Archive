#!/bin/bash

# YYC3-CN MCP 服务器配置更新脚本
# 将 yyc3-cn-assistant 移动到稳定位置并更新配置

set -e

echo "🚀 开始更新 YYC3-CN MCP 服务器配置..."

# 备份原配置
echo "📦 备份原配置文件..."
cp ~/Library/Application\ Support/Claude/claude_desktop_config.json \
   ~/Library/Application\ Support/Claude/claude_desktop_config.json.backup.$(date +%Y%m%d_%H%M%S)

echo "✅ 原配置已备份"

# 应用新配置
echo "📝 应用新配置..."
cp "/Users/yanyu/YYC3-Mac-Max/claude_desktop_config_final.json" \
   ~/Library/Application\ Support/Claude/claude_desktop_config.json

echo "✅ 新配置已应用"

# 验证配置
echo "🔍 验证配置..."
if [ -f "/Users/yanyu/YYC3-Mac-Max/YYC3-Mcp/API文档/YYC3-CN/代码/yyc3-cn-mcp-server.js" ]; then
    echo "✅ 服务器文件存在"
else
    echo "❌ 服务器文件不存在"
    exit 1
fi

node -c "/Users/yanyu/YYC3-Mac-Max/YYC3-Mcp/API文档/YYC3-CN/代码/yyc3-cn-mcp-server.js" && \
    echo "✅ 服务器文件语法正确" || echo "❌ 服务器文件语法错误"

python3 -m json.tool ~/Library/Application\ Support/Claude/claude_desktop_config.json > /dev/null && \
    echo "✅ 配置文件JSON格式正确" || echo "❌ 配置文件JSON格式错误"

echo ""
echo "🎉 配置更新完成！"
echo ""
echo "📁 新路径: /Users/yanyu/YYC3-Mac-Max/YYC3-Mcp/API文档/YYC3-CN/代码/yyc3-cn-mcp-server.js"
echo ""
echo "⚠️  请重启 Claude/Trae 应用以使配置生效"
echo ""
echo "📋 验证命令："
echo "   cd '/Users/yanyu/YYC3-Mac-Max/YYC3-Mcp/API文档/YYC3-CN/代码'"
echo "   node yyc3-cn-mcp-server.js"
