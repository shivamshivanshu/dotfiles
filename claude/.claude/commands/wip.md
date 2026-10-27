---
description: Summarise uncommitted changes as terse status bullets and write a crash-safe checkpoint
---
Summarise my uncommitted work. Outside a git repo, say so and stop. Run `git status` and `git diff HEAD` (no commits yet: `git diff --cached` and `git diff`), plus a skim of the untracked files `git status --porcelain` lists (ignored files never appear) — skipping secret-like (`.env`, keys, tokens), binary, and over ~300-line ones — then report:
- Terse bullets of what changed, grouped by concern.
- Anything half-done, risky, or inconsistent with the working-style skill.

Then write a crash-safe checkpoint for the SessionStart hook to surface later:
- Path: `$HOME/claude_notes/scratchpad/$(date +%Y%m%d)/wip-<repo>-<branch>.md`, where `<repo>` is the main repo name — `basename "$(git worktree list --porcelain | sed -n '1s/^worktree //p')"`, the same in every worktree — and `<branch>` has `/` replaced by `-` (filename only). Create the dir. "Same repo+branch" means matching `repo:`/`branch:` frontmatter: overwrite today's such checkpoint and delete its older-day ones — one live checkpoint per branch; if the filename is taken by another branch, append `-2`.
- Frontmatter: `repo:` (`<repo>` above), `branch:` (raw, the output of `git symbolic-ref --short -q HEAD || echo HEAD` — `HEAD` when detached; the SessionStart hook matches on it), `time:` (ISO). Body: the bullets above, then `Next: <the intended next step>`.
- Bullets give intent and status per concern, never file lists or diffs — git holds those.
- When the tree is clean, no commit is unpushed (`git log --oneline HEAD --not --remotes` prints nothing), and no rebase, merge or bisect is in progress, write nothing: delete this branch's checkpoints and say so.
- Confirm the checkpoint path in one line.
