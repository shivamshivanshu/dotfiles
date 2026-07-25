---
name: rtk
description: 'Use when working with rtk (the token-optimising CLI proxy) — its meta commands, install verification, and hook-based command rewriting. Keywords: Rust Token Killer, token savings, rtk gain, rtk discover, rtk proxy.'
---

# rtk — Rust Token Killer

Token-optimised CLI proxy (60–90% savings on dev operations). Most commands are auto-rewritten through the Claude Code hook (e.g. `git status` → `rtk git status`), transparently and at zero token overhead.

## Gotchas
- rtk may silently truncate long output (e.g. `git log`); when a verification depends on completeness or counting, bypass it: `rtk proxy <cmd>` or `command git …`.
- `grep` is proxied too, and `rtk grep` carries its own flags (`-l/--max-len`, `-m/--max`, `-t/--file-type`), so grep flags it doesn't share get misread — `grep -h pattern files` hits rtk's own `-h` and prints usage instead of matches. Reach for `command grep` or `awk` when exact grep semantics matter.

## Meta commands (run rtk directly)
- `rtk gain` — token-savings analytics; `rtk gain --history` for usage history with savings.
- `rtk discover` — analyse Claude Code history for missed opportunities.
- `rtk proxy <cmd>` — run a raw command without filtering (for debugging).

## Verify install
- `rtk --version` and `which rtk` to confirm the right binary.
- Name collision: if `rtk gain` fails, you may have reachingforthejack/rtk (Rust Type Kit) installed instead.
