---
name: teacher
description: 'Use when the wrap command reaches its teacher step, or the user explicitly asks to learn from the session''s work — surface up to three transferable concepts from it, ranked by learning priority, with a one-line agenda each, and offer to deep-dive now, defer, or skip. Never interrupt work in progress. Keywords: teach, study, knowledge base, transferable skill, explain concept, upskill.'
---

# Teacher

Grow the user's transferable software knowledge from real work. Optional and brief.

## Priority (surface higher tiers first)
1. Generic C++ — `std`, common libraries, design patterns, C++-level optimisation idioms.
2. OS, computer architecture (caches, pipelines, memory model), compiler internals, and network concepts — equal weight.
3. Work/domain-specific knowledge.
4. Everything else.

## Steps
1. **Housekeep.** Open `$HOME/claude_notes/backlog.md`; if absent, create it with the format's headings only, not its example lines. Remove every line already checked `[x]` — done means gone, so the file stays small.
2. **Select.** From the session's finished tasks and settled findings — even if the overall task continues — pick at most **three** concepts that are transferable and worth deep knowledge, not task trivia or one-off facts, ranked by the tiers above.
3. **Agenda.** Present them as a bare-minimum list: one line each — the concept and, in a few words, the payoff of diving deep. Tag each with its tier. Nothing more.
4. **Ask** which to dive into now, which to defer, and which to skip.
5. **Deep-dive (now).** Write a clear, intuitive, example-led explanation to `$HOME/claude_notes/<slug>.md` (`<slug>` never `backlog` or `tickets`), following `~/.claude/output-styles/teaching.md`; if the file exists, read and extend it, never overwrite. For currency-sensitive topics (new toolchain releases, stdlib changes, ecosystem shifts), search the web for the current state instead of answering from model knowledge. If the concept is on the backlog, delete its line.
6. **Defer.** Append a single `[ ]` one-liner under its tier heading in `$HOME/claude_notes/backlog.md`, unless the concept is already listed.
7. **Skip.** Drop it — record nothing.

## backlog.md format
```markdown
# Learning backlog

## 1 — C++ (std / libs / patterns / optimisation idioms)
- [ ] std::span — non-owning view over contiguous memory, replaces ptr+len pairs

## 2 — OS / arch / compiler / network
- [ ] false sharing — why unrelated atomics on one cache line wreck throughput

## 3 — Work/domain
## 4 — Other
```

## Guardrails
- If nothing is worth surfacing, say so and stop.
- Tier 1, 2 and 4 deep-dives carry no work-internal names; tier 3 may.
