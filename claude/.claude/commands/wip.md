---
description: Summarise uncommitted changes as terse status bullets and write a crash-safe checkpoint
---
Summarise my uncommitted work. Run `git status` and `git diff HEAD`, then report:
- Terse bullets of what changed, grouped by concern.
- Anything half-done, risky, or inconsistent with the working-style skill.

Lead with the summary; no preamble.

Then write a crash-safe checkpoint for the SessionStart hook to surface later:
- Path: `$HOME/claude_notes/scratchpad/$(date +%Y%m%d)/wip-<repo>-<branch>.md`, where `<repo>` is the git-root basename and `<branch>` has `/` replaced by `-` (filename only). Create the dir; overwrite today's checkpoint for the same repo+branch and delete older-day ones — one live checkpoint per branch.
- Frontmatter: `repo:` (git-root basename), `branch:` (raw, exactly as `git rev-parse --abbrev-ref HEAD` prints it — the SessionStart hook matches on it), `time:` (ISO). Body: the bullets above, then `Next: <the intended next step>`.
- Record no state git already holds (no file lists, no diffs).
- Confirm the checkpoint path in one line.
