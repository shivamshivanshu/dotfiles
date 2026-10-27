---
name: codebase-recon
description: 'Use when about to change an unfamiliar codebase, or when asked to understand or audit how something works — map the relevant slice and trace the real call path before proposing edits. Keywords: understand codebase, explore, onboarding, how does this work, don''t assume.'
---

# Codebase Recon

Understand before you change. Pair with [[working-style]].

## Map the slice
- Scope to what the task touches; don't read the whole repo. Find the entry points, the key data types, and the boundaries (I/O, config, external calls).
- Follow the real call path end to end — from entry point to effect — naming each hop. Use search and jump-to-definition, and delegate broad exploration per [[delegation]].
- Check how similar features already solve the problem, and prefer an existing pattern over a new one.

## How to trace
- Read the tests alongside the entry points — they encode intended behaviour and show the API in real use.
- Grep the exact error string or log line, then walk callers upward from the hit.
- Trace a config knob from its definition to every consumer before changing its meaning.
- Mine history: `git log --follow <file>` for evolution, `git log -S<symbol>` for when behaviour appeared, blame for the why behind a strange line.
- Check a symbol's fan-in before touching it — the callers you didn't know about are where regressions live. Use clangd find-references/call hierarchy for C++ symbols and `bazel query 'rdeps(//..., //pkg:target)'` for target-level fan-in; grep is the last resort — it misses virtual overrides, template instantiations, macros and callback registration.
- For bugs: reproduce deterministically before fixing — when a race or a one-off production crash makes that infeasible, preserve the crash evidence, build the smallest stress reproducer, and state what evidence the fix rests on; one falsifiable hypothesis per experiment, one variable changed at a time; when a regression window exists, let `git bisect run` do the search.

## Record findings
- For non-trivial work (per the [[working-style]] plan gate), write findings to `$HOME/claude_notes/scratchpad/<YYYYMMDD>/<topic>-recon.md` first: the call path, the key types, the invariants, and the open questions. Carry them into the plan gate from step 2 on; for an audit or how-does-this-work question, the notes are the deliverable — answer in the reply and give the path.
