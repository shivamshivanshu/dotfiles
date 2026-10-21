---
name: teacher
description: 'Use when the wrap command reaches its teacher step, or the user explicitly asks to learn from finished work — surface up to three transferable concepts from it, ranked by learning priority, with a one-line agenda each, and offer to deep-dive now, defer, or skip. Never mid-task. Keywords: teach, study, knowledge base, transferable skill, explain concept, upskill.'
---

# Teacher

Grow the user's transferable software knowledge from real work. Optional, brief, and only once a task is finished.

Normally reached via the `wrap` command.

## When
- Surface only concepts that are **transferable and worth deep knowledge**, not task trivia or one-off facts.

## Priority (surface higher tiers first)
1. Generic C++ — `std`, common libraries, design patterns, CPU optimisation.
2. OS, computer architecture, compiler internals, and network concepts — equal weight.
3. Work/domain-specific knowledge.
4. Everything else.

## Steps
1. **Housekeep.** Open `$HOME/claude_notes/backlog.md` (create the folder and file if absent). Remove every line already checked `[x]` — done means gone, so the file stays small.
2. **Select.** From the finished task, pick at most **three** transferable concepts, ranked by the tiers above.
3. **Agenda.** Present them as a bare-minimum list: one line each — the concept and, in a few words, the payoff of diving deep. Tag each with its tier. Nothing more.
4. **Ask** which to dive into now, which to defer, and which to skip.
5. **Deep-dive (now).** Write a clear, intuitive, example-led explanation to `$HOME/claude_notes/<slug>.md` (see style below). For currency-sensitive topics (new toolchain releases, stdlib changes, ecosystem shifts), search the web for the current state instead of answering from model knowledge.
6. **Defer.** Append a single `[ ]` one-liner under its tier heading in `$HOME/claude_notes/backlog.md`, so it isn't lost.
7. **Skip.** Drop it — record nothing.

## Deep-dive writing style
Follow `~/.claude/output-styles/teaching.md` when writing the file.

## backlog.md format
```markdown
# Learning backlog

## 1 — C++ (std / libs / patterns / cpu)
- [ ] std::span — non-owning view over contiguous memory, replaces ptr+len pairs

## 2 — OS / arch / compiler / network
- [ ] false sharing — why unrelated atomics on one cache line wreck throughput

## 3 — Work/domain
## 4 — Other
```

## Guardrails
- Keep it minimal — a short pick-list, never a lecture. If nothing is worth surfacing, say so and stop.
- Keep generic deep-dives free of work-internal names.
