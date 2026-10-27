---
name: design-doc
description: 'Use when writing a design doc, RFC, technical proposal, or architecture decision record — structure, tradeoff discipline, and terse style. Keywords: design doc, RFC, proposal, ADR, architecture decision, tradeoffs, options considered.'
---

# Design Doc

The default reader is an LLM agent: complete and exact, no padding, length set by content. When the user asks for a doc to read themselves, or it is for the team, a human design review, or to be posted or shared (the [[doc-reviewer]] pass does not count), write for a skeptical senior reviewer with ten minutes — one to two pages; a doc nobody finishes decides nothing. Pair with [[working-style]].

## Brainstorm first
- Invoke `superpowers:brainstorming` before drafting, unprompted, to pin down intent, goals and non-goals with the user — unless the user already stated all three; then confirm them in one line and skip it. Its written design becomes this doc, with three overrides:
  - Structure and save location come from this skill, not `docs/superpowers/specs/`, and the doc is not committed (see Save).
  - [[doc-reviewer]] replaces its builder check (a fresh subagent reading the spec) and the single question round that check produces.
  - After approval, the next step is the working-style plan gate at step 3, not `superpowers:writing-plans`; the approved design stands as steps 1–2, so ask only what it left open.

## Structure
1. **Problem** — what breaks or costs today, with numbers where they exist; why now and not later.
2. **Constraints** — hard requirements; failure modes (how it fails, how that is detected, the safe state); and explicit non-goals so scope can't creep back in review.
3. **Options** — the real candidates, normally two to four, including do-nothing unless a constraint rules it out (say which); one is allowed when constraints rule out the rest, with the reasons recorded. Tradeoffs must be concrete (latency, complexity, migration cost, operational burden), never adjectives. A comparison table beats paragraphs.
4. **Decision** — the pick and the one or two decisive reasons. Name what would change the decision.
5. **Verification** — how we will know it works: the tests, the metrics to watch, and the rollout/rollback plan.
6. **Open questions** (if any) — only items resolved outside this session (another team, a measurement, a later decision), each naming who or what resolves it.

## Discipline
- State the strongest argument *against* the chosen option yourself; a reviewer finding it first costs the doc its credibility.
- Every rejected option gets its real reason recorded — the doc's second job is stopping re-litigation.

## Save
- Always `$HOME/claude_notes/scratchpad/<YYYYMMDD>/<topic>-design.md`. Copy it into the repo's docs (and commit it) only when the user asks.
