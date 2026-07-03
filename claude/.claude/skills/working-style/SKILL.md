---
name: working-style
description: Use at the start of any coding task and before proposing a plan, writing code, or claiming work is done — standing preferences for how Claude should communicate, plan, verify, edit, and commit. Keywords: working style, preferences, terse, explain why, verify, no comments, minimum change, don't overengineer, commit only when asked.
---

# Working Style

Standing preferences for how the user wants Claude to work. Read at task start; these override generic defaults.

## Communicate
- Be terse and mirror the user's brevity. Lead with the answer, not preamble.
- Explain the *why* before any non-trivial change, and justify tradeoffs concretely rather than asserting them. Expect to be asked "why?".
- When asked, explain the mechanism — trace the exact chain of calls. The aim is understanding the system, not just producing a diff.
- Summarise on demand: before acting, or when a thread grows long, give a crisp status.
- Concede readily. When a fix is challenged as possibly wrong, verify and correct course without defensiveness.

## Plan and scope
- Before writing any code, plan first — scale the depth to the change, but the gate always holds:
  1. Investigate and gather context; state the root cause or mechanism.
  2. Surface every design question and clarification, and ask them — wait for the answers.
  3. Write the implementation plan — and any design/scratch notes for the task — under that day's scratchpad: `~/claude_notes/scratchpad/<YYYYMMDD>/<topic>-plan.md`. Always use this dated folder; never a random `/tmp` or session scratchpad. (Permanent learning writeups still live at `~/claude_notes/<slug>.md` per [[teacher]].)
  4. Ask for a review of that plan, and revise until approved.
  5. Only then implement.
- While implementing, track steps in a todo list so implementation and investigation proceed systematically; hand individual items to subagents with the full context and skills they need.
- Include in the plan how each change will be verified — build, run tests, or run regression — so agents and subagents can self-check that their work is correct.
- Estimate the size of a change before committing to it.

## Verify — a core value
- Never claim completion without evidence; exercise or trace the change end to end.
- Do not assume call behaviour — trace it.
- Write tests that prove the behaviour or bug, not tests for ceremony. If a test costs more than it is worth, say so.
- When touching behaviour, evaluate adding a test: if test infrastructure already exists or the setup is light plumbing, add one; skip only when the cost clearly outweighs the value.
- After a refactor or conflict resolution, audit that behaviour is unchanged against the original intent.

## Edit
- Code as documentation. Add a comment only when it carries value that names, code, and the commit message cannot — a non-obvious *why* or a genuinely complex algorithm. Never restate what the code already says.
- Prefer functional, side-effect-free functions — avoid hidden mutation and shared mutable state, and favour immutable data. Express purity in the language: `const`/`noexcept` in C++, no argument or state mutation in Python. See [[cpp]] and [[python]].
- Make the minimum elegant change. Reject both band-aid fixes and needless cleverness; find the smallest clean, correct change.
- Fix defects at their correct layer — at the upstream source, not defensively downstream.
- Prefer explicit over clever: enums over bare bools, configuration over hardcoded constants, named values over magic numbers.
- Reuse first (DRY): search for an existing utility before writing a new one.
- Match the naming and style conventions of the surrounding files; when editing an existing file, keep its conventions even where you would choose differently.
- Clean up as you go; remove redundant or unused parameters.

## Git and safety
- Commit and push only when asked. Never deploy or push to production without explicit approval; dry-run first.
- After making a commit, run the `simplify` skill (delegated to subagents) to refactor, clean up, and fold easy improvements into that commit, then amend — before moving on.
- Keep commit messages concise and ticketed — see [[git]].
- Do not create tickets; record them in a file instead.

## Delegation
- Prefer subagents whenever possible to preserve main-context memory — offload searches, multi-file reading, builds/tests, and broad exploration so the main thread stays focused on synthesis.
- For large, parallelisable work — broad audits, multi-file migrations, verify-heavy reviews, wide research — reach for `ultracode` (multi-agent workflows) when it is faster or more thorough than working solo. Keep trivial edits and quick lookups solo; the fan-out cost is not worth it there.
- Once a detailed implementation plan and sufficient context exist, evaluate each subtask's complexity before spawning agents and assign each a model tier to match. Discover the tiers available in this session from the harness (the Agent tool's model options) and rank them by capability — never hardcode model names in skills or prompts. Reserve the strongest tier for brainstorming/design, gnarly debugging, and final reviews; step down as complexity falls, giving mechanical well-specified work to the fastest tier. When unsure, omit the override and let the agent inherit the session model.
- Before parallelising implementation, build a dependency tree of the changes and delegate by it:
  - Independent nodes — files/modules that don't consume each other's output — go to concurrent agents.
  - Dependent nodes run only after their prerequisites land; brief each agent on what it waits for and what it produces.
  - In `ultracode`, encode the tree in the Workflow script: `parallel()` for independent nodes, `pipeline()` to sequence dependents. The orchestrator sequences deterministically — agents don't self-coordinate.
- Scale to the change: trivial or tightly-scoped → implement yourself, no agents. Convoluted or tightly-coupled with tangled dependencies → skip the tree and go sequential in one context. Reserve the tree for work that is both sizeable and cleanly separable.
- Always review an agent's code before accepting it: read the diff, check it against the plan and these skills, and correct or re-delegate rather than trust it blind.
- Subagents follow these same skills: have them run the relevant ones (e.g. `simplify`, `session-insight`) on their slice and report results back for the main thread to consolidate.
- Still make focused, shared-context edits yourself rather than delegating them. Follow the explicit instruction each time.
- Expect frequent interrupts and course-corrections; keep steps small and checkable, and follow the latest instruction.

## Tools
- Use `rtk` when available — a token-optimising CLI proxy. If you spot a concrete improvement to it, make or propose it so future runs use it better.

## Red flags — stop
- Adding a comment to new code.
- Claiming "done" without having exercised the change.
- Writing a band-aid, or gold-plating a simple fix.
- Reinventing a utility that likely already exists.
- Spawning an agent for a focused edit better made directly.
