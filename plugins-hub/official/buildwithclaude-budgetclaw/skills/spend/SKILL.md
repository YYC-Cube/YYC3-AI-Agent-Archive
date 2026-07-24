---
name: spend
description: Show current Claude Code spend by project and branch via BudgetClaw
category: development-code
version: 1.0.0
user-invocable: true
allowed-tools: Bash(budgetclaw *)
---

Show the current spend status:

!`budgetclaw status`

If the user asks about budget limits, also show:

!`budgetclaw limit list`

If there are active breach locks, show:

!`budgetclaw locks list`
