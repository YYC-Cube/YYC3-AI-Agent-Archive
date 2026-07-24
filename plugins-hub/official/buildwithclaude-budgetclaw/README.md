# BudgetClaw

Local spend monitor for Claude Code. Watches `~/.claude/projects/*.jsonl`, tracks cost per project and git branch, enforces budget caps via SIGTERM, and pushes phone alerts via ntfy.

**Zero keys. Zero prompts. Zero latency added.**

## Install

```sh
curl -fsSL roninforge.org/get | sh
budgetclaw init
```

## Plugin features

- `/spend` slash command: shows current spend by project/branch, active limits, and breach locks
- Session-start hook: prints a spend summary when you open a new Claude Code session

## Links

- Homepage: https://roninforge.org
- Source: https://github.com/RoninForge/budgetclaw
- License: MIT
