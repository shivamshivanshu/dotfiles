---
name: rtk
description: 'Use when Bash output looks truncated, empty or garbled under the rtk rewrite hook, or when working with rtk (the token-optimising CLI proxy) — its meta commands, install verification, and hook-based command rewriting. Keywords: Rust Token Killer, token savings, rtk gain, rtk discover, rtk bypass.'
---

# rtk — Rust Token Killer

Token-optimised CLI proxy. The PreToolUse hook `rtk hook claude` rewrites Bash commands (e.g. `git status` → `rtk git status`).

## Reading its output
- Condensed output is lossy by design: rely on it for status and pass/fail, but recover the full output whenever omitted detail could change the conclusion — and always when it is marked truncated or filtered (e.g. `(4 filtered)`) or meets a bypass trigger below.
- A truncated result names its recovery path in the output — follow it (`rtk recall <hash>`, or `rtk recall <hash> --full` for the whole output) before re-running.
- A "Read of <file> … is blocked" reply is not file content. For full text use the Read tool or `rtk bypass cat <file>`, never `rtk read` (lossy filtering).
- Re-run as `rtk bypass <cmd>` (unfiltered, still tracked) when the full output is needed and no recall hint exists, when a result is unusable — empty where output was clearly expected, contradicting its exit code, or garbled — or when a check depends on exact, complete output or on its structure (counting lines, byte-exact diffs; multi-directory `ls` drops the per-directory headers).
- Batch related commands into one call; the hook rewrites each `&&` segment and can rewrite the left side of a pipe (`git status | head` is), so a count or grep over a piped command may see condensed output — pipe from `rtk bypass <cmd>` instead.

## Setup
- Hook: `~/.claude/settings.json` carries the bare `rtk hook claude` — the form `rtk init` recognises, so a later `rtk init -g` does not add a duplicate. Check with `rtk init -g --show`: it prints `[ok] Hook: rtk hook claude`.
- Config `~/.config/rtk/config.toml` (tracked on Linux) excludes from rewriting, so these run raw: `git diff`/`show`/`log` (incl. `git -C`), `grep`, `rg`, `find`, `jq`, `ssh`, and `ls` with `-l`, sorting or several paths. Recovery store is sqlite: follow `rtk recall <hash>` hints.
- No `RTK.md`/`@RTK.md`: this skill holds that guidance. Decline `rtk init`'s CLAUDE.md injection: run `rtk init -g --hook-only`.

## Meta commands (run rtk directly)
- `rtk gain` — token-savings analytics; `rtk gain --history` for usage history with savings.
- `rtk discover` — analyse Claude Code history for missed opportunities; turn findings into hook or skill improvements.

## Verify install
- `rtk --version` and `which rtk` to confirm the right binary.
- Name collision: if `rtk gain` fails, you may have reachingforthejack/rtk (Rust Type Kit) installed instead.
