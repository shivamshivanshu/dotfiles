---
description: Write a full context handoff (via the handoff skill) for a future Claude instance
argument-hint: [name]
allowed-tools: Bash(mkdir:*), Write, Skill
---
Handoff directory (already created): !`mkdir -p "$HOME/claude_notes/exports/$(date +%Y%m%d)" && printf '%s' "$HOME/claude_notes/exports/$(date +%Y%m%d)"`

Use the **handoff** skill to write the handoff to `<dir>/<name>.md`, where `<dir>` is the absolute path printed above and `<name>` is "$ARGUMENTS" if non-empty, otherwise a short kebab-case slug of the main topic. Use the absolute path verbatim (the Write tool does not expand `$HOME`/`~`).
