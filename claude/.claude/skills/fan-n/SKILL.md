---
name: fan-n
description: Use when one sample of a task isn't trustworthy — fan N identical agents over the same prompt to average out run-to-run variance, then a fan-in agent on a stronger model ranks consensus vs outliers. Keywords: fan out, fan in, N agents, sampling, repeated trials, majority vote, averaging.
---

# Fan-N

N identical agents → one fan-in judge. The cheapest way to buy reliability from a stochastic process. For *diverse* perspectives or debate, use [[stochastic-consensus]]; for splitting implementation work, use [[agent-team]].

## When
- The answer varies run to run: broad searches, estimates, reviews, root-cause guesses, "did I miss anything" checks.
- Not for deterministic lookups (one agent suffices) and not for decomposable work (that's sharding, not sampling).

## Fan out
- N identical prompts — same task, same context, no lens differences; variance must come from the model, not the prompt. N of 3–7; raise it only after observing disagreement.
- Structured-output schema so the fan-in compares like with like.
- Cheaper/faster model tier here — sampling breadth is the value, not per-sample depth.
- Run as a background Workflow so the samples never touch the main context; tolerate null results (`.filter(Boolean)`) — a dead sample is noise, not failure.

## Fan in
- One agent on the strongest tier — judgment concentrates here.
- Rank by agreement: what most samples independently produced is the signal.
- Preserve outliers explicitly and judge each: noise, or the one sample that saw further? The fan-in must say which and why — never silently drop a minority answer.
- Only the fan-in's synthesis returns to the main thread.

## Review fan-out (varied prompts)
Code review and simplify passes always use this shape — never a single reviewer:
- Most agents get full context with slightly varied prompts, each emphasising a different concern.
- Spawn a few with no context at all — inferring purely from the diff and commit messages; blind eyes catch what briefed ones assume away.
- Give every agent MCP/tool access.
- Fan in through a strongest-tier dedup agent that merges findings and summarises; the main thread only organises the result and decides.
