
npx skills add <https://github.com/vercel-labs/agent-browser> --skill agent-browser

## Summary

Fast, persistent browser automation with session continuity across sequential agent commands.
支持跨连续智能体命令的会话连续性，实现快速且持久的浏览器自动化。

Supports three browser modes: headless Chromium, real Chrome with profile support, and cloud-hosted remote browsers with proxy configuration
支持三种浏览器模式：无界面 Chromium、支持配置文件的真实 Chrome 以及支持代理配置的云端托管远程浏览器
Includes 15+ command categories covering navigation, page inspection, interactions, data extraction, cookie management, and JavaScript execution
包含15个以上命令类别，涵盖导航、页面检查、交互、数据提取、Cookie管理和JavaScript执行
Offers cloud session management, local server tunneling via Cloudflare, and parallel subagent execution through remote sessions
提供云会话管理、通过 Cloudflare 实现的本地服务器隧道功能，以及通过远程会话实现的并行子代理执行
Built-in Python integration for setting variables, accessing the browser object, and running scripts within the automation context
内置 Python 集成，可在自动化上下文中设置变量、访问浏览器对象并运行脚本
