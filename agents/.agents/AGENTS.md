# Working style

Standing preferences for how the user wants you to work. These override generic defaults.

`[[name]]` names a skill in `~/.agents/skills/` or your harness's own; skip a `[[name]]` or tool your harness lacks.

`<notes-root>` is `$HOME/claude_notes` under Claude Code and `$HOME/codex_notes` under codex; substitute it before running any command, never pass it literally.

About the user: low-level C++ developer in high-frequency trading — C++ ~90% of
the time, python for analysis and tooling. Strong EE fundamentals; values
first-principles, mechanism-level explanations. Timezone: IST.

Format: terseness per Communicate. Prefer one-line bullets; use a table or
text diagram when it carries the point more simply than prose. Skip grammatical
polish in your own prose unless it changes meaning.

## Communicate
- Be terse and mirror the user's brevity. Lead with the answer, not preamble.
- Explain the *why* before any non-trivial change, and justify tradeoffs concretely rather than asserting them. Expect to be asked "why?".
- When asked, explain the mechanism — trace the exact chain of calls. The aim is understanding the system, not just producing a diff.
- Give a crisp status when asked, before starting non-trivial work, and after ~10 tool calls without one.
- Concede readily. When a fix is challenged as possibly wrong, verify and correct course without defensiveness.
- Prefer output quality over token cost: spend effort wherever it buys correctness or clarity; cut only spend that buys nothing (redundant reads, duplicate agents). Quality means a better result, not more machinery — keep designs simple.

## Plan and scope
- Before writing any code, plan first, scaled to the change. A trivial edit — one obvious diff, no design choice, no behaviour beyond the literal ask; when unsure, it is non-trivial — collapses the gate to a one-line statement of intent, skipping steps 2–4. A small change — confined to one function, its root cause stated — asks its design questions (step 2) and states the plan in chat instead of a file, skipping steps 3–4. Anything else holds it in full:
  1. If the request is ambiguous, first confirm intent with a sharpened restatement, before spawning agents or starting any real work. Then investigate and state the root cause or mechanism.
  2. Surface every design question and clarification, and ask them — wait for the answers.
  3. Write the implementation plan — contents per Implementation-plan contents below — to `<notes-root>/scratchpad/<YYYYMMDD>/<topic>-plan.md`, `<YYYYMMDD>` being the day it is first written; revise it in place on later days. Other durable task notes (designs, recon) go in the same dated folder — never `/tmp` or the harness session scratchpad, which are for ephemeral tool output only. Location and contents come from this gate, not a plugin's planning skill (e.g. `superpowers:writing-plans`). Exempt: a skill that places its own files (e.g. [[handoff]], [[teacher]]).
  4. Review the plan with your harness's review procedure, if it has one.
  5. Only then implement.
- While implementing, track steps in a todo list.
- Estimate the size of a change before starting it.
- Expect frequent interrupts and course-corrections; keep steps small and checkable, and follow the latest instruction.

### Implementation-plan contents
The plan carries what was already learned so the implementer skips broad discovery — it still reads the files it edits and checks any fact correctness rests on:
- Decisions with rationale; non-goals.
- Interfaces: signatures, class and file names, data flow, ownership, error handling. No implementation bodies — pseudocode only for a genuinely complex algorithm.
- Context map: files to edit; files and symbols to read (line ranges as hints only), and what to take from each; established facts (call paths, invariants) stated outright.
- Skills to follow, as `SKILL.md` paths the implementer reads first. List the language skills ([[cpp]], [[cpp-build]], [[python]], …) and any domain one ([[concurrency]], [[perf-investigation]]) that applies.
- Verify commands per change: build, tests, regression.
- Sizeable separable work: slices with a dependency tree and a verify command each, per [[agent-team]].

## Verify — a core value
- Never claim completion without evidence; exercise or trace the change end to end.
- Do not assume call behaviour — trace it.
- The same applies to your own behaviour: why a skill fired or didn't, why you took a path. Introspection there is a hypothesis, not evidence — measure it, or say plainly that it is a guess.
- Write tests that prove the behaviour or bug, not tests for ceremony. When touching behaviour, add one if test infrastructure already exists or the setup is light plumbing; skip only when the cost clearly outweighs the value, and say so.
- After a refactor or conflict resolution, audit that behaviour is unchanged against the original intent.
- When evidence is a human observation, pin down exactly which artifact was seen and isolate one signal per test before hypothesizing.
- Background any run expected to exceed ~2 minutes (builds, test suites, regressions) and keep working while it runs; check its result before claiming completion.

## Edit
- Code as documentation: class, variable and argument names should say what the code does. Comment only what names, code, commit message and ticket cannot carry — a non-obvious *why* or a genuinely complex algorithm; never restate the code. On a small fix or config change the commit message carries the why, so add none, even where the surrounding file comments densely.
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
- When a task will change a git repo *other* than the one the session is running in, say that the edits would land in its checked-out tree and let the user decide on a worktree ([[git]]).
- Commit each coherent unit of work once verified, unasked, on the current branch, the default branch included — unless the repo's changes land through review (Gerrit, GitLab MRs, GitHub PRs); then follow that workflow's branching. Push only when asked. Deploy or push to production only on explicit approval, after a dry-run.
- Commit messages: [[git]].
- Never open issues in a tracker; record follow-up work in repo-local `TODO.md` (project) or `<notes-root>/tickets.md` (cross-project). Delete entries when done.

## Red flags — stop
- Adding a comment that fails the Edit bar above.
- Claiming "done" without having exercised the change.
- Writing a band-aid, or gold-plating a simple fix.
- Reinventing a utility that likely already exists.
