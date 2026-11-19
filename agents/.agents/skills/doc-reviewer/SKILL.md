---
name: doc-reviewer
description: 'Use when a plan, design, or implementation doc is written (AGENTS.md gate step 4) or handed over for review — multi-agent review for ambiguity, loopholes and contradictions, a Q&A loop with the user until no open questions remain, a re-audit by the same reviewers, then, for an implementation plan in the gate, implementer brief and plan-vs-code conformance review. Keywords: review doc, review plan, refine plan, find ambiguity, implementation doc, conformance review.'
---

# Doc Reviewer

Turn a draft doc into one an agent can execute without asking. It is the review in the plan gate (`~/.agents/AGENTS.md` Plan and scope step 4):
- Trivial plan: skip it.
- Any doc: panel, Q&A loop, audit.
- Implementation plan in the gate: continues to implement and conformance once approved. A pending `edits.md` blocks approval until the user applies it and the fan-in confirms the doc matches; otherwise the plan stops unapproved.
- Design doc, RFC or ADR: stops at approval and goes on to the plan gate ([[design-doc]]). An explicit review request outside the gate also stops at approval and reports the doc path, plus `edits.md` if any.

## Audience
- Reader per [[design-doc]] — an LLM agent by default: optimise for zero-ambiguity execution, not for a human skimming. Exact names, paths and commands; each term defined once and used consistently; no hedging, no narrative. When [[design-doc]]'s human-reader triggers apply (this review does not count as one), follow its human style; the lenses still apply.

## 1. Review panel
- The main thread creates `<review-dir>` = `<notes-root>/scratchpad/<YYYYMMDD>/<topic>-review/`, `<topic>` being the doc's basename without extension (suffix `-2`, `-3` if it exists), and passes it in every brief.
- Named agents (`dr_<role>`), never scripted-fan-out agents — per [[delegation]], so the audit resumes them with their context intact; stop each reviewer once the doc is approved, the fan-in once the pipeline ends.
- The main thread picks the panel and states it with its reason in the doc (to the user, for a doc it did not write); a user override wins. The **light panel** is ambiguity, loopholes and blind, the fan-in doing concision itself — for a doc whose misses are cheap to catch later. Otherwise the **full panel**:
  - Lenses, each given the doc path plus the paths it cites:
    - **Ambiguity/contradiction** — a statement two implementers would read differently; sections that disagree; undefined terms.
    - **Loopholes** — missing cases, failure and error paths, unstated assumptions, steps with no verify command, scope that can creep.
    - **Concision** — cut padding, merge duplicates, tighten for the doc's reader; never cut implementation-plan contents (step 4); flag any cut that would lose information.
  - **Blind**: reads only `<review-dir>/blind-input.md`, a `cat` of the doc, and writes only its output file — catches what context assumes away. Blindness is instruction-only, so it records any other path it opened.
- Reviewers are read-only on the doc. Per [[delegation]]'s output-file rule, each appends to `<review-dir>/<role>.md` as `N. [lens] [severity] <location> — issue — fix — user-call: yes|no` (or `no findings`), `lens` being ambiguity, loopholes or concision per finding.
- **Fan-in** (`dr_fanin`), kept for the whole pipeline, briefed with `<review-dir>`, the doc path and whether this harness wrote it (created by this harness's agents, any file under `<notes-root>/scratchpad/`, or the user says so); the only agent that edits the doc — in place when this harness wrote it, else as proposed edits in `edits.md` there for the user to apply. It judges every finding on evidence, not vote count, and appends to `fanin.md` there, one section per round: applied, dropped with reason, open questions. Per finding:
  - wording or concision, or settled by the code (read, not assumed), the doc or a convention → apply;
  - a default that is reversible and within scope → apply, recorded as `default: <value> — <why>`;
  - re-argues a recorded decision without new evidence → drop, naming the decision;
  - anything else → a question: an assumption to confirm, or 2–4 options with a recommended default.
- Supervise per [[delegation]]. A reviewer still dead after one replacement is noted missing. With no completed reviewer, stop and ask the user.

## 2. Q&A loop
- The main thread asks every question in one go (ask the user). Include the worktree offer (`~/.agents/AGENTS.md` Git and safety) when the plan edits another repo — §5 starts without asking.
- It forwards the answers verbatim to the fan-in, which records them as choice + why (design doc: **Decision**, rejected options' reasons under **Options**; else **Decisions**, created if absent), rechecks the doc, and returns follow-ups. "You pick" or unanswered → the recommended default, recorded as `default (user deferred)`. An answer contradicting a recorded decision goes back to the user as a conflict. Repeat until none remain.

## 3. Audit
- First, before resuming the reviewers, the fan-in condenses an implementation plan, verbatim old/new edit text not counted, to ~3× the expected diff it states, merging and cutting repetition; §4's Implementation-plan contents are the floor. The reviewers audit the condensed doc, so this is not a change in the audit.
- Resume each reviewer with the doc path, `fanin.md` and any `edits.md` ((codex) one that has dropped out of `list_agents`, unmeasured: a fresh reviewer briefed with its `<role>.md` and `fanin.md`); for the blind one, `cat` them into `<review-dir>/blind-audit-input.md` and pass only that path. Never retype an input through the main thread. Each checks its findings were resolved and the doc for new gaps, writing to `<role>-audit.md`, never over a first-pass file; a dropped or defaulted item is re-raised only with new evidence.
- Fan-in merges. The doc is approved when no finding is unresolved and no user call is open — no separate approval gate. A user call → the Q&A loop. Any doc change in the audit → a re-audit by only the reviewers whose findings touch the changed sections.
- Cap: three Q&A rounds, and the audit plus two re-audits (light panel: one); then list what remains with its defaults and ask once whether to proceed on them — a no means the user decides each, and here silence is not a default. Only explicit acceptance or a decision on every item approves the doc, as the one exception to the rule above: no further re-audit, any residual named in the approval line. Otherwise it stops unapproved.

## 4. Implementation-plan contents
The author writes the plan per `~/.agents/AGENTS.md` Implementation-plan contents before the panel; the lenses check against it. Skills to follow are `~/.agents/skills/<name>/SKILL.md` paths for shared skills and `~/.claude/skills/<name>/SKILL.md` for Claude-only ones — `simple-implementer` has no Skill tool (Claude), and every agent already has AGENTS.md in context. The plan states its expected diff in changed lines. Whoever writes or edits a verify command runs it once on the unchanged tree, unless it writes tracked files or is a build or test suite, and fixes one that cannot run (syntax, missing path, shell quoting); a count that is off only because the change is absent is expected. That catches broken commands, not checks that can never pass, so each post-change grep or count check names an exact string the edit inserts.

## 5. Implement
- If the user gave the autonomous-mode trigger, run [[autonomous-mode]] preparation now, then take `<base>` below inside its branch or worktree.
- In autonomous mode nothing in §5–6 goes to the user; the main thread logs a row in the decisions file instead: a gap needing a user call takes the fan-in's recommended option (the scoped re-audit still runs); a commit-path mismatch commits only paths in `impl.md`'s list and clean at `<base>`, leaving the rest uncommitted; a verify still failing after two returns, or a residual after the fix round, is a `BLOCKED:` row.
- The main thread records `<base>` = the `HEAD` SHA plus `git status --short`, then briefs one implementer (`dr_impl`, output `<review-dir>/impl.md`) with the doc path, its agent role `simple-implementer` when every step is mechanical, else `general-developer:code-writer` (`general-purpose` if absent). Sizeable separable work → [[agent-team]], one slice and `impl-<slice>.md` per agent; `<base>` and the diff are then the integration branch's. Exception: a plan whose whole diff is ≤ ~20 lines in files already in the main context — the main thread implements it and writes `impl.md` itself; conformance still runs fresh.
- Its output file holds files changed and verify results; it does not re-plan. On a gap it stops and reports the gap and any partial edits; the main thread forwards that to the fan-in, which amends the doc (a user call goes through the Q&A loop and scoped re-audit), then resumes the implementer — (Claude) a Workflow slice is re-run instead.

## 6. Conformance review
- Gate: the implementer's verify results all pass — else back to it, at most twice, then the failing command and output go to the user.
- The main thread commits the paths changed since `<base>` per [[git]]; it asks the user first if they differ from `impl.md`'s list or were dirty at `<base>`.
- `dr_conformance` (output `conformance.md`), fresh, checks the doc against `git diff <base>..HEAD`: planned versus done, gaps, drift, unplanned changes, verify commands re-run. Verdict: `PASS`, or `FAIL` with a list.
- Small or mechanical diff: it also runs `simplify`/`code-review` itself and applies the fixes — its only edits. Non-trivial: the main thread runs the [[fan-n]] review fan-out with it as the plan-conformance leg and re-delegates fixes.
- After fixes, `verifier` re-runs the verify commands — plus a conformance re-check for non-trivial fixes — and once those pass, the verdict is `PASS` and the main thread amends the fixes in. One fix round; any residual goes to the user.

## Reporting
Up to approval, report as usual. From approval on, report per [[autonomous-mode]]'s Reporting bullet — it applies here without the trigger — opening with `approved, <N> applied, <doc path>`, N being the applied items across all rounds of `fanin.md`.
