---
name: teacher
description: Use after a task is complete (never mid-task) to grow the user's software knowledge — surface a few transferable, worth-knowing concepts that came up, ranked by the learning priorities below, with a one-line agenda each, and offer to deep-dive now or defer. Keywords: teach, study, knowledge base, transferable skill, explain concept, upskill.
---

# Teacher

Grow the user's transferable software knowledge from real work. Optional, brief, and only once a task is finished.

## When
- After a task completes — never interrupt work in progress.
- Surface only concepts that are **transferable and worth deep knowledge**, not task trivia or one-off facts.

## Priority (surface higher tiers first)
1. Generic C++ — `std`, common libraries, design patterns, CPU optimisation.
2. OS and computer architecture, and compiler internals — equal weight with — network concepts.
3. Work/domain-specific knowledge.
4. Everything else.

## Steps
1. **Housekeep.** Open `$HOME/claude_notes/backlog.md` (create the folder and file if absent). Remove every line already checked `[x]` — done means gone, so the file stays small.
2. **Select.** From the finished task, pick at most **three** transferable concepts, ranked by the tiers above.
3. **Agenda.** Present them as a bare-minimum list: one line each — the concept and, in a few words, the payoff of diving deep. Tag each with its tier. Nothing more.
4. **Ask** which to dive into now, which to defer, and which to skip.
5. **Deep-dive (now).** Write a clear, intuitive, example-led explanation to `$HOME/claude_notes/<slug>.md` (see style below).
6. **Defer.** Append a single `[ ]` one-liner under its tier heading in `$HOME/claude_notes/backlog.md`, so it isn't lost.
7. **Skip.** Drop it — record nothing.

## Deep-dive writing style
- Intuitive, simple wording aimed at a strong engineer new to the topic.
- Lead with the core idea in a sentence or two, then a concrete, runnable example.
- Bare minimum — no padding, no exhaustive enumeration. Enough to genuinely understand and apply it.

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
- Keep the skills repo and any generic deep-dive free of work-internal names; domain-specific notes live only in `$HOME/claude_notes/`.
- Sibling end-of-work skill: [[session-insight]] improves the skill repo; this one grows your knowledge.
