
Web Interface Guidelines 网页界面指南
Review files for compliance with Web Interface Guidelines.
检查文件是否符合网页界面指南。

How It Works 工作原理
Fetch the latest guidelines from the source URL below
从下方的源 URL 获取最新指南
Read the specified files (or prompt user for files/pattern)
读取指定文件（或提示用户提供文件/模式）
Check against all rules in the fetched guidelines
对照获取到的指南中的所有规则进行检查
Output findings in the terse file:line format
以简洁的file:line格式输出检查结果
Guidelines Source 指南来源
Fetch fresh guidelines before each review:
每次审核前获取最新指南：

<https://raw.githubusercontent.com/vercel-labs/web-interface-guidelines/main/command.md>
Use WebFetch to retrieve the latest rules. The fetched content contains all the rules and output format instructions.
使用 WebFetch 获取最新规则。获取的内容包含所有规则和输出格式说明。

Usage 使用方法
When a user provides a file or pattern argument:
当用户提供文件或模式参数时：

Fetch guidelines from the source URL above
从上方的源网址获取指导方针
Read the specified files 读取指定的文件
Apply all rules from the fetched guidelines
应用从获取的指导方针中得到的所有规则
Output findings using the format specified in the guidelines
按照指南中指定的格式输出发现结果
If no files specified, ask the user which files to review.
如果未指定文件，请询问用户需要查看哪些文件。
