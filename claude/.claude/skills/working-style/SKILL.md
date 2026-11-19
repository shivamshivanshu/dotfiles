---
name: working-style
description: 'Claude-harness working rules on top of `~/.agents/AGENTS.md` — plan review, autonomous mode, post-commit simplify, delegation, rtk.'
disable-model-invocation: true
---

# Working Style

Claude-harness rules on top of `~/.agents/AGENTS.md`, which CLAUDE.md also loads.

## Plan and scope
- Gate step 4 (AGENTS.md Plan and scope): review the plan with [[doc-reviewer]].
- Auto permission mode does not waive this gate: it removes permission prompts, not the stop-and-ask. Exception: Autonomous mode below.
- Gate step 3 also exempts [[teacher]] and [[session-insight]] (`$HOME/claude_notes/proposed_skills/`), which place their own files.

## Autonomous mode
- Only the user's explicit "autonomous mode" / "kick off autonomous" starts it; auto permission mode and plan approval do not. On the trigger load [[autonomous-mode]]; after compaction reload it while `<topic>-decisions.md` has a `kicked off` and no `ended` line.

## Git and safety
- After a non-trivial commit — a small change per the AGENTS.md gate included —, run `simplify` (review fan-out per [[delegation]]), re-run the plan's verify commands for it (plan-less: the build and tests covering the touched files), and amend the fixes in before moving on — subject to [[git]]'s pushed-history check. Skip it for a commit out of [[doc-reviewer]] conformance, which already ran it. The amend needs no separate approval; the AGENTS.md push rule still holds.

## Delegation
- Before deciding whether to delegate, or spawning any subagent, teammate or Workflow, load [[delegation]].

## Tools
- `rtk` rewrites Bash commands through a hook ([[rtk]]). If you spot a concrete improvement to it, make or propose it so future runs use it better.

## Red flags — stop
- Spawning an agent for a focused edit to files already in the main context.
- Pulling bulk raw output (files you won't edit, long logs, full diffs, broad search results) into the main context instead of delegating it.
