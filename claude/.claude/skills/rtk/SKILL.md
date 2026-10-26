---
name: rtk
description: 'Use when Bash output looks truncated, empty or garbled under the rtk rewrite hook, or when working with rtk (the token-optimising CLI proxy) — its meta commands, install verification, and hook-based command rewriting. Keywords: Rust Token Killer, token savings, rtk gain, rtk discover, rtk bypass.'
---

# rtk — Rust Token Killer

Token-optimised CLI proxy. The PreToolUse hook `rtk hook claude` rewrites Bash commands (e.g. `git status` → `rtk git status`).

## Reading its output
- Condensed output keeps every signal and drops noise: treat it as the complete result, and batch related commands into one call.
- A truncated result names its own recovery path in the output.
- Re-run as `rtk bypass <cmd>` only when a result is unusable — empty where output was clearly expected, contradicting its exit code, or garbled — or when a check depends on exact, complete output (counting lines, byte-exact diffs).

## Setup
- Hook: settings.json carries the bare `rtk hook claude` — the form `rtk init` recognises, so a later `rtk init -g` does not add a duplicate. Check with `rtk init -g --show`.
- No `RTK.md`/`@RTK.md`: this skill holds that guidance. Decline `rtk init`'s CLAUDE.md injection (`--hook-only`).

## Meta commands (run rtk directly)
- `rtk gain` — token-savings analytics; `rtk gain --history` for usage history with savings.
- `rtk discover` — analyse Claude Code history for missed opportunities.
- `rtk bypass <cmd>` — run a command unfiltered (still tracked).

## Verify install
- `rtk --version` and `which rtk` to confirm the right binary.
- Name collision: if `rtk gain` fails, you may have reachingforthejack/rtk (Rust Type Kit) installed instead.
