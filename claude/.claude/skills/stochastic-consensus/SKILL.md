---
name: stochastic-consensus
description: 'Use when exploring an open problem with a subagent team — independent solutions ranked into consensus + outliers, then structured debate rounds where each agent incorporates all others'' reasoning. Keywords: stochastic consensus, debate, subagent team, panel, jury, cross-examine, approach space.'
---

# Stochastic Consensus & Debate

Map the approach space with independent solvers, then let them argue. For variance sampling over equivalent prompts see [[fan-n]]; for executing the winning plan see [[agent-team]]. Run the whole pipeline as a background Workflow — only the final synthesis returns to the main context. The main thread scouts context inline first and embeds it in every prompt; only phase-1 agents explore the repo; later phases work from passed text and may read, never edit, the repo only to check a load-bearing claim.

## Phase 1 — independent solutions
- Each agent solves the problem alone, blind to the others. Distinct lenses when perspectives should differ; equivalent prompts, varied only in wording, when the spread should come from the model rather than the framing.
- Rank the merged results by support count: the solution most agents converged on is the consensus candidate.
- Keep outliers as first-class output — they map the *different approaches*, and an outlier can win the debate. Never let ranking bury them.

## Phase 2 — debate
- Run 2–4 steps: after each, the next step is the final one if this one logged no concession or the next is step 4. Each step, every agent receives the outcome of all other agents and must incorporate it: answer challenges aimed at it, concede when convinced (log every concession), raise a few sharp challenges, and update its stance (champion/support/skeptical/kill).
- Verify inside the debate: debaters check load-bearing claims against docs or code, not just argue — consensus without verification amplifies shared wrong assumptions.
- Bounded positions via schema (~300 words, max 3 challenges per agent per step); pass only the latest round plus the shared ranked list, never full history.
- Push agents to kill weak items — a good debate prunes. Force convergence in the final step, briefed as final.

## Fan in
- One fan-in agent gets the ranked list, final positions, and concession log.
- Output: adopt / defer with gating question / rejected **with reasons** (prevents re-litigation) / surviving outliers.
- Each debate step is a barrier by nature; everything else pipelines. Tolerate dead agents — a lost solver still leaves its lens debatable from the shared list.
