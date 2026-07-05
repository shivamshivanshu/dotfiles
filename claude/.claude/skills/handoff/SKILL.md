---
name: handoff
description: Use when writing a session handoff so a fresh Claude instance (no memory of the conversation) can fully resume the work — preserve every important finding, decision, investigation result, and state, not a terse summary. Keywords: handoff, resume context, context dump, carry over, pick up where we left off.
---

# Handoff

Produce a briefing that lets a fresh Claude instance resume this work with **no memory** of the conversation. The reader is a model, not a human.

Preserve **substance completely** — every important finding, decision, and investigation result — and drop only conversational mechanics (tool retries, restated instructions, small talk, superseded attempts). When unsure whether a detail matters for resuming, keep it. Losing a hard-won finding is far worse than being long.

## Capture (skip a section only if genuinely empty)
- **Goal & scope** — what we're doing, why, and explicit non-goals.
- **Findings & investigation** — what was discovered, and what was tried and *ruled out* (with the reason), so the next instance doesn't repeat dead ends. This is the highest-value part; be thorough and specific.
- **Decisions & rationale** — each choice and the reasoning/tradeoffs behind it, including options rejected.
- **Current state** — what's done, committed, pushed, and verified; what's mid-flight.
- **Key files & paths** — each file that matters and what it holds or how it changed. Exact paths.
- **Exact commands** — the build/test/run/verify invocations discovered, verbatim.
- **Open threads / next steps** — what's unfinished, pending decisions, and the intended next action.
- **Gotchas & constraints** — non-obvious pitfalls, environment quirks, or invariants a fresh instance would otherwise re-learn the hard way.

## Style
- High-signal prose and lists; never a verbatim chat log.
- Concrete over vague: real names, paths, line numbers, numbers, commands.
- Begin the file with one line stating what it is and how to use it (e.g. "Handoff for resuming <topic>; read fully before acting").

## Save
1. Create today's export dir and capture its absolute path (run via Bash so `$HOME` and the date expand):
   `mkdir -p "$HOME/claude_notes/exports/$(date +%Y%m%d)" && printf '%s\n' "$HOME/claude_notes/exports/$(date +%Y%m%d)"`
2. Filename: the name the user gave when invoking, else a short kebab-case slug of the main topic.
3. Write the handoff with the Write tool to `<abs-dir>/<name>.md`, using the absolute path from step 1 verbatim (the Write tool does not expand `$HOME`/`~`).
4. Confirm the saved path in one line.
