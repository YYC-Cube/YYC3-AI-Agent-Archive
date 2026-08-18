#!/bin/bash

# 可疑的 AI 助手扩展列表
SUSPECTS=(
  "tencent-cloud.coding-copilot"
  "continue.continue"
  "google.geminicodeassist"
  "anthropic.claude-code"
)

echo "🔍 开始排查问题扩展..."
echo ""

for ext in "${SUSPECTS[@]}"; do
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "📦 测试扩展: $ext"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""
  echo "❌ 禁用 $ext..."
  code --uninstall-extension "$ext" --force 2>/dev/null || code --disable-extension "$ext"
  
  echo ""
  echo "✅ 已禁用，现在测试..."
  echo "👉 请在 VS Code 中:"
  echo "   1. 按 Cmd+Shift+P"
  echo "   2. 输入 'Developer: Reload Window'"
  echo "   3. 测试能否编辑文件"
  echo ""
  read -p "能否正常编辑了？(y/n) " -n 1 -r
  echo ""
  
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo ""
    echo "🎯 找到问题扩展: $ext"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "建议操作:"
    echo "1. 卸载此扩展: code --uninstall-extension $ext"
    echo "2. 或保持禁用状态"
    echo "3. 考虑只使用 GitHub Copilot"
    exit 0
  else
    echo "⏭️  不是这个扩展，继续测试下一个..."
    echo ""
  fi
done

echo ""
echo "❓ 所有可疑扩展都测试完了"
echo "问题可能出在其他扩展上"
echo ""
echo "其他可能的问题扩展:"
echo "- eamodio.gitlens (GitLens)"
echo "- usernamehw.errorlens (Error Lens)"
echo "- ms-vscode.vscode-speech (语音输入)"
