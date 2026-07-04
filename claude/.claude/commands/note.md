---
description: Export this chat to $HOME/claude_notes/exports/<date>/<name>.md
argument-hint: [name]
allowed-tools: Bash(python3:*)
---
!`python3 "$HOME/.claude/scripts/note-export.py" "$ARGUMENTS"`

Confirm the export path from the output above in one line. No other action.
