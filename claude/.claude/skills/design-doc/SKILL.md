---
name: design-doc
description: Use when writing a design doc, RFC, technical proposal, or architecture decision record — structure, tradeoff discipline, and terse style. Keywords: design doc, RFC, proposal, ADR, architecture decision, tradeoffs, options considered.
---

# Design Doc

Write for a skeptical senior reviewer with ten minutes. Short enough to be read — one to two pages; a doc nobody finishes decides nothing. Pair with [[working-style]].

## Structure
1. **Problem** — what breaks or costs today, with numbers where they exist; why now and not later.
2. **Constraints** — hard requirements, and explicit non-goals so scope can't creep back in review.
3. **Options** — two to four real candidates including do-nothing. Tradeoffs must be concrete (latency, complexity, migration cost, operational burden), never adjectives. A comparison table beats paragraphs.
4. **Decision** — the pick and the one or two decisive reasons. Name what would change the decision.
5. **Verification** — how we will know it works: the tests, the metrics to watch, and the rollout/rollback plan.

## Discipline
- State the strongest argument *against* the chosen option yourself; a reviewer finding it first costs the doc its credibility.
- Every rejected option gets its real reason recorded — the doc's second job is stopping re-litigation.
- Open questions go in their own section, not buried in prose; each names who or what resolves it.
- Terse prose, no padding, no restating context the reader already has.

## Save
- Deliverable docs go where the repo already keeps them (docs/, adjacent README) if such a place exists; otherwise `$HOME/claude_notes/scratchpad/<YYYYMMDD>/<topic>-design.md`. Say which you chose and why.
