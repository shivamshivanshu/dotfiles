---
name: codebase-recon
description: Use before changing an unfamiliar codebase, or when asked to understand or audit how something works — map the relevant slice and trace the real call path before proposing edits. Keywords: understand codebase, explore, onboarding, how does this work, don't assume.
---

# Codebase Recon

Understand before you change. Pair with [[working-style]].

## Principle
- Trace, don't assume. Establish how the code actually behaves before touching it — assumptions about call behaviour are the main source of wrong fixes.

## Map the slice
- Scope to what the task touches; don't read the whole repo. Find the entry points, the key data types, and the boundaries (I/O, config, external calls).
- Follow the real call path end to end — from entry point to effect — naming each hop. Use search and jump-to-definition, and delegate broad exploration to parallel subagents.
- Check how similar features already solve the problem, and prefer an existing pattern over a new one.

## Record findings
- For non-trivial work, write findings to that day's scratchpad first (e.g. `~/claude_notes/scratchpad/<YYYYMMDD>/<topic>.md`): the call path, the key types, the invariants, and the open questions. Then implement from the notes.
- State the root cause or mechanism before proposing a change.

## Before editing
- Confirm the change belongs at the correct layer — the upstream source, not a downstream patch.
- Know what the change costs and what it could break, and identify the test or trace that will prove it.
