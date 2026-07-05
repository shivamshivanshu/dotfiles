---
name: stochastic-consensus
description: Use when exploring an open problem with a subagent team — independent solutions ranked into consensus + outliers, then structured debate rounds where each agent incorporates all others' reasoning. Keywords: stochastic consensus, debate, subagent team, panel, jury, cross-examine, multi-agent review, approach space.
---

# Stochastic Consensus & Debate

Map the approach space with independent solvers, then let them argue. For identical-prompt sampling see [[fan-n]]; for executing the winning plan see [[agent-team]]. Run the whole pipeline as a background Workflow — only the final synthesis returns to the main context. The main thread scouts context inline first and embeds it in every prompt; only phase-1 agents touch the repo, later phases work purely from passed text.

## Phase 1 — independent solutions
- Each agent solves the problem alone, blind to the others. Distinct lenses when perspectives should differ; identical prompts when only the model's stochasticity should vary.
- Rank the merged results statistically: the solution most agents converged on is the consensus candidate; support count across independent agents is the significance signal.
- Keep outliers as first-class output — they map the *different approaches*, and an outlier regularly ends as the champion once debated. Never let ranking bury them.

## Phase 2 — debate
- Define the number of steps up front. Each step, every agent receives the outcome of all other agents and must incorporate it: answer challenges aimed at it, concede when convinced (log every concession), raise a few sharp challenges, and update its stance (champion/support/skeptical/kill).
- Verify inside the debate: debaters check load-bearing claims against docs or code, not just argue — consensus without verification amplifies shared wrong assumptions.
- Bounded positions via schema (~300 words, capped challenges); pass only the latest round plus the shared ranked list, never full history.
- Push agents to kill weak items — a good debate prunes. Force convergence in the final quarter of steps.
- Concession flow is the convergence signal: concessions drying up early means stop; still flowing at the end means the steps were well spent.

## Fan in
- One synthesizer on the strongest tier gets the ranked list, final positions, and concession log.
- Output: adopt / defer with gating question / rejected **with reasons** (prevents re-litigation) / surviving outliers.
- Each debate step is a barrier by nature; everything else pipelines. Tolerate dead agents — a lost solver still leaves its lens debatable from the shared list.
