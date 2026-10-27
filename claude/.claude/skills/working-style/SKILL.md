---
name: working-style
description: 'Use when starting any coding task and before proposing a plan, writing code, or claiming work is done — standing preferences for how Claude should communicate, plan, verify, edit, and commit. Keywords: working style, preferences, terse, explain why, verify, no comments, minimum change, don''t overengineer, auto-commit, autonomous mode, push only when asked.'
disable-model-invocation: true
---

# Working Style

Standing preferences for how the user wants Claude to work. These override generic defaults.

## Communicate
- Be terse and mirror the user's brevity. Lead with the answer, not preamble.
- Explain the *why* before any non-trivial change, and justify tradeoffs concretely rather than asserting them. Expect to be asked "why?".
- When asked, explain the mechanism — trace the exact chain of calls. The aim is understanding the system, not just producing a diff.
- Give a crisp status when asked, before starting non-trivial work, and after ~10 tool calls without one.
- Concede readily. When a fix is challenged as possibly wrong, verify and correct course without defensiveness.
- Prefer output quality over token cost: spend effort wherever it buys correctness or clarity; cut only spend that buys nothing (redundant reads, duplicate agents). Quality means a better result, not more machinery — keep designs simple.

## Plan and scope
- Before writing any code, plan first, scaled to the change. A trivial edit — one obvious diff, no design choice, no behaviour beyond the literal ask; when unsure, it is non-trivial — collapses the gate to a one-line statement of intent, skipping steps 2–4. A small change — confined to one function, its root cause stated — asks its design questions (step 2) and states the plan in chat instead of a file, skipping steps 3–4; the post-commit `simplify` pass (Git and safety) still reviews it. Anything else holds it in full:
  1. If the request is ambiguous, first confirm intent with a sharpened restatement, before spawning agents or starting any real work. Then investigate and state the root cause or mechanism.
  2. Surface every design question and clarification, and ask them — wait for the answers.
  3. Write the implementation plan — contents per [[doc-reviewer]]'s "Implementation-plan contents" — to `$HOME/claude_notes/scratchpad/<YYYYMMDD>/<topic>-plan.md`, `<YYYYMMDD>` being the day it is first written; revise it in place on later days. Other durable task notes (designs, recon) go in the same dated folder — never `/tmp` or the harness session scratchpad, which are for ephemeral tool output only. Location and contents come from this gate, not `superpowers:writing-plans`. Exempt: [[teacher]], [[handoff]] and [[session-insight]] (`$HOME/claude_notes/proposed_skills/`), which place their own files.
  4. Review the plan with [[doc-reviewer]].
  5. Only then implement.
- Auto permission mode does not waive this gate: it removes permission prompts, not the stop-and-ask. Exception: Autonomous mode below.
- While implementing, track steps in a todo list.
- Estimate the size of a change before starting it.
- Expect frequent interrupts and course-corrections; keep steps small and checkable, and follow the latest instruction.

## Autonomous mode
- Only the user's explicit "autonomous mode" / "kick off autonomous" starts it; auto permission mode and plan approval do not. On the trigger load [[autonomous-mode]]; after compaction reload it while `<topic>-decisions.md` has a `kicked off` and no `ended` line.

## Verify — a core value
- Never claim completion without evidence; exercise or trace the change end to end.
- Do not assume call behaviour — trace it.
- The same applies to your own behaviour: why a skill fired or didn't, why you took a path. Introspection there is a hypothesis, not evidence — measure it, or say plainly that it is a guess.
- Write tests that prove the behaviour or bug, not tests for ceremony. When touching behaviour, add one if test infrastructure already exists or the setup is light plumbing; skip only when the cost clearly outweighs the value, and say so.
- After a refactor or conflict resolution, audit that behaviour is unchanged against the original intent.
- When evidence is a human observation, pin down exactly which artifact was seen and isolate one signal per test before hypothesizing.
- Background any run expected to exceed ~2 minutes (builds, test suites, regressions) and keep working while it runs; check its result before claiming completion.

## Edit
- Code as documentation: class, variable and argument names should say what the code does. Comment only what names, code, commit message and ticket cannot carry — a non-obvious *why* or a genuinely complex algorithm; never restate the code.
- One function does one thing. One class per file, named after it; util/free functions are exempt. Types may share a file when they belong together logically (one serves the other: its params or result struct, error enum, iterator, impl detail) or are trivially small; once each carries logic of its own, split them.
- Prefer functional, side-effect-free functions — avoid hidden mutation and shared mutable state, and favour immutable data. Language mechanics: [[cpp]], [[python]]; for a language with no skill of its own, apply the [[cpp]] rules that have an equivalent there (errors as values, strong types, explicit ownership, constrained generics, enforcing what the compiler or type checker can) in that language's idiom, and skip the C++-only mechanics.
- Make the smallest clean, correct change — no band-aids, no needless cleverness.
- Fix defects at their upstream source, not defensively downstream.
- Prefer explicit over clever: enums over bare bools, configuration over hardcoded constants, named values over magic numbers.
- Reuse first (DRY): search for an existing utility before writing a new one.
- Match the naming and style conventions of the surrounding files; when editing an existing file, keep its conventions even where you would choose differently.
- Clean up as you go; remove redundant or unused parameters.
- When the repo pins its formatters/linters (`.pre-commit-config.yaml`, a lint config with a pinned version), run them through that pin (`pre-commit run --files ...`) rather than a globally-installed one; a newer version reformats untouched files and pollutes the diff. With no repo pin, a global tool is fine.
- Shell code meant to run on both macOS (BSD userland) and Linux (dotfiles, personal tooling) must stay portable — `bash -n`/`zsh -n` will not catch divergence. Known traps: `sed -i ''` (BSD) vs `sed -i` (GNU), `stat -f` vs `stat -c`, no `date -d` or `grep -P` on macOS. Prefer portable forms (`perl -pi -e`, `python3`, `$(cd dir && pwd)`) or branch on `uname`.

## Git and safety
- When a task will change a git repo *other* than the one Claude Code is running in, say that the edits would land in its checked-out tree and let the user decide on a worktree ([[git]]).
- Commit each coherent unit of work once verified, unasked, on the current branch, the default branch included — unless the repo's changes land through review (Gerrit, GitLab MRs, GitHub PRs); then follow that workflow's branching. Push only when asked. Deploy or push to production only on explicit approval, after a dry-run.
- After a non-trivial commit, run `simplify` (review fan-out per [[delegation]]), re-run the plan's verify commands for it (plan-less: the build and tests covering the touched files), and amend the fixes in before moving on — subject to [[git]]'s pushed-history check. Skip it for a commit out of [[doc-reviewer]] conformance, which already ran it. The amend needs no separate approval; the push rule above still holds.
- Commit messages: [[git]].
- Never open issues in a tracker; record follow-up work in repo-local `TODO.md` (project) or `$HOME/claude_notes/tickets.md` (cross-project). Delete entries when done.

## Delegation
- Before deciding whether to delegate, or spawning any subagent, teammate, codex leg or Workflow, load [[delegation]].

## Tools
- `rtk` rewrites Bash commands through a hook ([[rtk]]). If you spot a concrete improvement to it, make or propose it so future runs use it better.

## Red flags — stop
- Adding a comment that fails the Edit bar above.
- Claiming "done" without having exercised the change.
- Writing a band-aid, or gold-plating a simple fix.
- Reinventing a utility that likely already exists.
- Spawning an agent for a focused edit to files already in the main context.
- Pulling bulk raw output (files you won't edit, long logs, full diffs, broad search results) into the main context instead of delegating it.
