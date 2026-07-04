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
- Completeness of substance beats brevity — err toward keeping an important detail.
- Begin the file with one line stating what it is and how to use it (e.g. "Handoff for resuming <topic>; read fully before acting").

## Save
Write with the Write tool to the absolute path the caller specifies. The Write tool does not expand `$HOME` or `~`, so use the absolute path verbatim. Then confirm the saved path in one line.
