---
name: doc-reviewer
description: 'Use when a plan, design, or implementation doc is written (working-style gate step 4) or handed over for review — multi-agent review for ambiguity, loopholes and contradictions, a Q&A loop with the user until no open questions remain, a re-audit by the same reviewers, then, for an implementation plan in the gate, implementer brief and plan-vs-code conformance review. Keywords: review doc, review plan, refine plan, find ambiguity, implementation doc, conformance review.'
---

# Doc Reviewer

Turn a draft doc into one an agent can execute without asking. It is the review in the plan gate of [[working-style]]:
- Trivial plan: skip it.
- Any doc: panel, Q&A loop, audit.
- Implementation plan in the gate: continues to implement and conformance once approved. A pending `edits.md` blocks approval until the user applies it and the fan-in confirms the doc matches; otherwise the plan stops unapproved.
- Design doc, RFC or ADR: stops at approval and goes on to the plan gate ([[design-doc]]). An explicit review request outside the gate also stops at approval and reports the doc path, plus `edits.md` if any.

## Audience
- Reader per [[design-doc]] — an LLM agent by default: optimise for zero-ambiguity execution, not for a human skimming. Exact names, paths and commands; each term defined once and used consistently; no hedging, no narrative. When [[design-doc]]'s human-reader triggers apply (this review does not count as one), follow its human style; the lenses still apply.

## 1. Review panel
- The main thread creates `<review-dir>` = `$HOME/claude_notes/scratchpad/<YYYYMMDD>/<topic>-review/`, `<topic>` being the doc's basename without extension (suffix `-2`, `-3` if it exists), and passes it in every brief.
- Named Agent spawns (`dr-<role>`), never Workflow agents — teammates per [[delegation]], so the audit resumes them via SendMessage with their context intact; TaskStop each reviewer once the doc is approved, the fan-in once the pipeline ends. Exception: codex runs `--ephemeral`, so the audit spawns it fresh.
- Every doc gets the full panel, unless the user names a smaller one for the run:
  - Lenses, each given the doc path plus the paths it cites:
    - **Ambiguity/contradiction** — a statement two implementers would read differently; sections that disagree; undefined terms.
    - **Loopholes** — missing cases, failure and error paths, unstated assumptions, steps with no verify command, scope that can creep.
    - **Concision** — cut padding, merge duplicates, tighten for the doc's reader; never cut implementation-plan contents (step 4); flag any cut that would lose information.
  - **Blind**: reads only `<review-dir>/blind-input.md`, a `cat` of the doc, and writes only its output file — catches what context assumes away. Blindness is instruction-only, so it records any other path it opened.
  - **codex**: self-contained brief per its agent definition and [[delegation]], all lenses at once; the brief text, the doc and every cited file outside the repo root are `cat`-assembled into `<review-dir>/codex-brief.md`, since its sandbox cannot read them.
- Reviewers are read-only on the doc. Per [[delegation]]'s output-file rule, each appends to `<review-dir>/<role>.md` as `N. [lens] [severity] <location> — issue — fix — user-call: yes|no` (or `no findings`), `lens` being ambiguity, loopholes or concision per finding. Codex's `-o` file is `codex.md` there.
- **Fan-in** (`dr-fanin`), kept for the whole pipeline, briefed with `<review-dir>`, the doc path and whether Claude wrote it (created by Claude, any file under `$HOME/claude_notes/scratchpad/`, or the user says so); the only agent that edits the doc — in place when Claude wrote it, else as proposed edits in `edits.md` there for the user to apply. It judges every finding on evidence, not vote count, and appends to `fanin.md` there, one section per round: applied, dropped with reason, open questions. Per finding:
  - wording or concision, or settled by the code (read, not assumed), the doc or a convention → apply;
  - a default that is reversible and within scope → apply, recorded as `default: <value> — <why>`;
  - anything else → a question: an assumption to confirm, or 2–4 options with a recommended default.
- Supervise per [[delegation]]. A reviewer still dead after one replacement is noted missing; on a codex auth failure or exhausted quota skip the leg and tell the user once. With no completed Claude reviewer, stop and ask the user.

## 2. Q&A loop
- The main thread asks every question in one go: one AskUserQuestion for ≤4 (recommended option first), else a plain numbered message. Include the worktree offer ([[working-style]] Git and safety) when the plan edits another repo — §5 starts without asking.
- It forwards the answers verbatim to the fan-in, which records them as choice + why (design doc: **Decision**, rejected options' reasons under **Options**; else **Decisions**, created if absent), rechecks the doc, and returns follow-ups. "You pick" or unanswered → the recommended default, recorded as `default (user deferred)`. An answer contradicting a recorded decision goes back to the user as a conflict. Repeat until none remain.

## 3. Audit
- SendMessage each reviewer the doc path, `fanin.md` and any `edits.md`; for the blind one, `cat` them into `<review-dir>/blind-audit-input.md` and pass only that path; for the fresh codex, `cat` the brief text, all three and its first-pass `codex.md` into `<review-dir>/codex-audit-brief.md`. Never retype an input through the main thread. Each checks its findings were resolved and the doc for new gaps, writing to `<role>-audit.md`, never over a first-pass file; a dropped or defaulted item is re-raised only with new evidence.
- Fan-in merges. The doc is approved when no finding is unresolved and no user call is open — no separate approval gate. A user call → the Q&A loop. Any doc change in the audit → a re-audit by only the reviewers whose findings touch the changed sections.
- Cap: three Q&A rounds, and the audit plus two re-audits; then list what remains with its defaults and ask once whether to proceed on them — a no means the user decides each, and here silence is not a default. Only explicit acceptance or a decision on every item approves the doc, as the one exception to the rule above: no further re-audit, any residual named in the approval line. Otherwise it stops unapproved.

## 4. Implementation-plan contents
The author writes the plan to this spec before the panel; the lenses check against it. It carries what was already learned so the implementer skips broad discovery — it still reads the files it edits and checks any fact correctness rests on:
- Decisions with rationale; non-goals.
- Interfaces: signatures, class and file names, data flow, ownership, error handling. No implementation bodies — pseudocode only for a genuinely complex algorithm.
- Context map: files to edit; files and symbols to read (line ranges as hints only), and what to take from each; established facts (call paths, invariants) stated outright.
- Skills to follow, as `~/.claude/skills/<name>/SKILL.md` paths the implementer reads first — `simple-implementer` has no Skill tool, and working-style already reaches it via CLAUDE.md. List the language skills ([[cpp]], [[cpp-build]], [[python]], …) and any domain one ([[concurrency]], [[perf-investigation]]) that applies.
- Verify commands per change: build, tests, regression.
- Sizeable separable work: slices with a dependency tree and a verify command each, per [[agent-team]].

## 5. Implement
- If the user gave the autonomous-mode trigger, run [[autonomous-mode]] preparation now, then take `<base>` below inside its branch or worktree.
- In autonomous mode nothing in §5–6 goes to the user; the main thread logs a row in the decisions file instead: a gap needing a user call takes the fan-in's recommended option (the scoped re-audit still runs); a commit-path mismatch commits only paths in `impl.md`'s list and clean at `<base>`, leaving the rest uncommitted; a verify still failing after two returns, or a residual after the fix round, is a `BLOCKED:` row.
- The main thread records `<base>` = the `HEAD` SHA plus `git status --short`, then briefs one implementer (`dr-impl`, output `<review-dir>/impl.md`) with the doc path: `simple-implementer` when every step is mechanical, else `general-developer:code-writer` (`general-purpose` if absent). Sizeable separable work → [[agent-team]], one slice and `impl-<slice>.md` per agent; `<base>` and the diff are then the integration branch's. Exception: a plan whose whole diff is ≤ ~20 lines in files already in the main context — the main thread implements it and writes `impl.md` itself; conformance still runs fresh.
- Its output file holds files changed and verify results; it does not re-plan. On a gap it stops and reports the gap and any partial edits; the main thread forwards that to the fan-in, which amends the doc (a user call goes through the Q&A loop and scoped re-audit), then resumes the implementer via SendMessage — a Workflow slice is re-run instead.

## 6. Conformance review
- Gate: the implementer's verify results all pass — else back to it, at most twice, then the failing command and output go to the user.
- The main thread commits the paths changed since `<base>` per [[git]]; it asks the user first if they differ from `impl.md`'s list or were dirty at `<base>`.
- `dr-conformance` (output `conformance.md`), fresh, checks the doc against `git diff <base>..HEAD`: planned versus done, gaps, drift, unplanned changes, verify commands re-run. Verdict: `PASS`, or `FAIL` with a list.
- Small or mechanical diff: it also runs `simplify`/`code-review` itself and applies the fixes — its only edits. Non-trivial: the main thread runs the [[fan-n]] review fan-out with it as the plan-conformance leg and re-delegates fixes.
- After fixes, `verifier` re-runs the verify commands — plus a conformance re-check for non-trivial fixes — and once those pass, the verdict is `PASS` and the main thread amends the fixes in. One fix round; any residual goes to the user.

## Reporting
Up to approval, report as usual. From approval on, report per [[autonomous-mode]]'s Reporting bullet — it applies here without the trigger — opening with `approved, <N> applied, <doc path>`, N being the applied items across all rounds of `fanin.md`.
