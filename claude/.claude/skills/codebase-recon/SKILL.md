---
name: codebase-recon
description: 'Use when about to change an unfamiliar codebase, or when asked to understand or audit how something works — map the relevant slice and trace the real call path before proposing edits. Keywords: understand codebase, explore, onboarding, how does this work, don''t assume.'
---

# Codebase Recon

Understand before you change. Pair with [[working-style]].

## Map the slice
- Scope to what the task touches; don't read the whole repo. Find the entry points, the key data types, and the boundaries (I/O, config, external calls).
- Follow the real call path end to end — from entry point to effect — naming each hop. Use search and jump-to-definition, and delegate broad exploration to parallel subagents.
- Check how similar features already solve the problem, and prefer an existing pattern over a new one.

## How to trace
- Read the tests first — they encode intended behaviour and show the API in real use.
- Grep the exact error string or log line, then walk callers upward from the hit.
- Trace a config knob from its definition to every consumer before changing its meaning.
- Mine history: `git log --follow <file>` for evolution, `git log -S<symbol>` for when behaviour appeared, blame for the why behind a strange line.
- Check a symbol's fan-in before touching it — the callers you didn't know about are where regressions live.
- For bugs: reproduce deterministically before fixing; one falsifiable hypothesis per experiment, one variable changed at a time; when a regression window exists, let `git bisect run` do the search.

## Record findings
- For non-trivial work, write findings to that day's scratchpad first (e.g. `$HOME/claude_notes/scratchpad/<YYYYMMDD>/<topic>.md`): the call path, the key types, the invariants, and the open questions. Then implement from the notes.
