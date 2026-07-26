---
name: agent-team
description: 'Use when executing a sizeable, separable implementation with a team of subagents — dependency-tree delegation, per-agent briefs and verify steps, worktree isolation, tiered models. Keywords: agent team, parallel implementation, delegate, orchestrate, worktree, subagent implementation, migration.'
---

# Agent Team

Deterministic orchestration for implementation. The plan decides; agents execute; the orchestrator sequences — Workflow agents never self-coordinate (native teammates below are the exception: they self-claim from the shared task list). Requires an approved plan first (see [[working-style]]); for exploring *what* to build use [[stochastic-consensus]], for sampling use [[fan-n]].

## Native agent teams (interactive teammates)
Enabled via settings (`CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS`, `teammateMode: in-process` → teammates live in the main TUI: ↑/↓ select, Enter view/message, `x` stop, Ctrl+T task list; tmux split panes proved flaky). Reach for a native team instead of Workflow orchestration when the work is *interactive and long-lived*: parallel development across worktrees/repos where each teammate holds durable context the user converses with. Fire-and-forget stages stay in Workflows.
- Teams provide no filesystem isolation — give each teammate its own worktree (`gwt`, per [[git]]) before it edits anything.
- Coordinate through the shared task list with dependencies; let teammates self-claim; message by name (SendMessage). Keep it stocked and dependency-ordered so members unblock incrementally — an empty or fully-blocked list idles every teammate at once, and each one then notifies.
- Known edges: `/resume` does not restore in-process teammates; one team per session; teammates cannot nest teams or spawn background subagents; all inherit the lead's permission mode at spawn; context cost scales linearly per teammate.
- The lead only synthesizes — per [[working-style]], per-repo context lives in the teammates, not the lead. This is also what makes wake-ups cheap: an idle notification costs the lead's whole context, not a ping.
- Reuse a live teammate for the next slice in its area rather than stopping and respawning — its accumulated context is the whole reason to run a team, and a fresh spawn pays the briefing and the rebuild again. Spawn only for work that exists.
- Stop a teammate (`x`) when nothing in its area is left on the list, or the team is winding down. A member parked with no remaining work only idle-notifies, and each notification is a full lead turn — measured at ~18M tokens, which is the lead's context being re-read. If wake-ups cost that much, the lead is carrying too much; fix that first rather than culling teammates that still have work coming.

## Shape the team from the dependency tree
- Build the tree before spawning anything: files/modules that don't consume each other's output are independent nodes → concurrent agents; dependents run only after their prerequisites land.
- In a Workflow script: `parallel()` for independent nodes, `pipeline()` to sequence dependents.
- Write the tree into the day's scratchpad plan file (per [[working-style]]) with a status per slice and keep it current — it survives a restart, and the stop rule above reads it to tell whether an area still has work coming. This is the lead's record, not a claim file: native teammates already self-claim from the shared task list, and a plain file has no atomicity, so two readers can claim the same slice.
- Scale honestly: per [[working-style]], trivial, tightly-scoped, or tangled work stays in one context (often yourself) — the tree is for work that is both sizeable and cleanly separable.

## Brief each agent completely
- Its plan slice, the context it needs (paths, conventions, constraints) embedded in the prompt, the skills it must follow, what it waits for, and what it must produce.
- Include the verify command in the brief — build, test, or regression — so the agent self-checks before reporting. A report without evidence is not done.
- Assign model tiers by subtask complexity per [[working-style]]; omit the override when unsure.

## Isolation and integration
- Worktree isolation when agents mutate files concurrently — never let two agents edit the same tree.
- For N independent features (no shared plan): one branch+worktree each. When done, ask the user whether to rebase onto origin/main; default is to leave each on its worktree branch. If yes, rebase per [[git]], resolve conflicts, and re-verify after the rebase.
- Review every agent's diff against the plan before accepting ([[working-style]]).
- The team is for breadth, not for one-file fixes.
- After integration, run the verify and simplify passes on the combined result — per-agent green does not prove the composition works.
