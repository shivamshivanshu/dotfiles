---
name: session-insight
description: 'Use when the wrap command reaches its insight step, or the user explicitly asks for a session retro ("session insight"). Treat wrap-up phrases ("I''m done", "wrap up") as the wrap command, not this skill directly. Reflects on the session, coaches better prompting, and proposes concrete improvements to the skill/knowledge repos. Keywords: session summary, retro, improve skills, capture insight, prompt feedback, better prompts.'
---

# Session Insight

Run at the end of a session to turn what happened into durable improvements — to the skill repos and to how the user prompts.

## Steps

1. **Summarise the session** in a few terse bullets: what was accomplished and what remains open. No narrative.

2. **Extract the one or two highest-value durable insights** — only what generalises beyond this one task. Draw both from what happened and from the prompts given:
   - New preferences revealed (how work should be done).
   - Corrections given (what was wrong, and the right way).
   - Recurring patterns or idioms worth codifying.
   - Tooling or environment gotchas and their workarounds.
   Skip one-off details, ticket specifics, and anything already captured.

3. **Coach the prompting.** Review the prompts given this session. Where a prompt was ambiguous, underspecified, or led to rework, show a concrete **before → after** rewrite with one line on why the sharper version works. Surface only the top 1–3; skip if the prompts were already clear.
   For each, also check whether a CLAUDE.md or skill edit could make the fix automatic — a standing default, or a rule to restate/clarify before acting — and propose that edit alongside the rewrite; config beats coaching when both work.

4. **Route each insight** to the right home:

   | Insight | Target |
   |---|---|
   | Generic behaviour, language, or tooling preference, with no work-internal names | The dotfiles `claude` package — `~/.claude/` skills, `CLAUDE.md`, commands, agents, output-styles, hooks; update an existing file or add one. `settings.json` is copied, not stowed: edit the tracked and the live copy |
   | Fact tied to a specific repo or project | That project's `CLAUDE.md` or `.claude/skills/` (local) |
   | Anything work-internal (internal hostnames, systems, ticket prefixes, proprietary domain) | Rules: project-local `CLAUDE.md` or `.claude/skills/` — each affected repo's, for a rule spanning repos; facts: Claude memory — never the global dotfiles skills |
   | A fact about the user, a project's state, or an external pointer — not a rule for how to work | Claude memory: the per-project harness memory dir |

   Rules for how to work always go to a skill or `CLAUDE.md`, never memory — including `feedback` memories the harness saved mid-session (step 6 sweeps them). When the local-vs-global call is ambiguous, choose local. Global only if the insight is repo- and employer-independent.

5. **Propose concrete changes.** For each, name the exact target file and show the specific edit or new-skill draft. Prefer updating an existing skill over creating one — check existing skills in `~/.claude/skills/` first. Follow the skill-authoring format: frontmatter `name` and a `description` starting with "Use when…", a terse body, and no comment bloat. The description is the whole trigger mechanism and the usual failure is *under*-triggering, so name the situations explicitly instead of trusting keywords to carry it. For the fuller authoring guide, invoke the `skill-creator:skill-creator` skill.
   A new skill or skill change that is generic across projects or needed very frequently — including one from a step-6 `feedback` memory — is also written to `$HOME/claude_notes/proposed_skills/<YYYYMMDD>/<kebab-description>.md` (create the dir); below that bar, write no file. Delete the file once the proposal is applied or rejected.

6. **Audit the library (mechanical — report only if something is found).** Scope: `~/.claude/{skills,agents,commands,output-styles}` and `~/.claude/CLAUDE.md`. Lint for broken `[[wiki-links]]`, leaked work-internal names, and references to files or flags that no longer exist. Strip fenced blocks and inline code spans before matching links — C++ attributes such as `[[nodiscard]]` are identical in form and are not links. Flag each `feedback`-type memory in the current project's memory dir and propose moving the rule into a skill or `CLAUDE.md`, then deleting the memory. Parse every skill's, agent's, command's and output style's frontmatter with a strict YAML loader that also rejects duplicate keys (PyYAML's `safe_load` silently keeps the last): Claude Code's own parser is lenient, so invalid frontmatter (an unquoted `description` containing `Keywords:`, say) loads fine here and breaks only other tooling. Then check the *claims*, not just the links: wherever a skill cites another by name, verify the assertion it makes about that skill still holds. A link that resolves can still describe a rule that has since changed, and this is the most common way the library goes stale — every edit to a rule needs a sweep for who quotes it.

7. **Stop for review.** Present the proposals grouped as Global, Local, and Memory. Apply only what is approved — global edits in the dotfiles repo: the session's dotfiles worktree if it runs in one, else the main checkout `~/.claude` links into — saying so first and letting the user decide on a worktree, per [[working-style]]'s other-repo rule.

## Output shape

```
## Summary
- …

## Insights worth keeping
- …

## Prompting — sharper next time
- before: "…"  →  after: "…"   (why: …)

## Proposed changes
### Global (~/.claude)
- update cpp: …
### Local (this repo)
- add to CLAUDE.md: …
### Memory
- …
```

## Guardrails
- If an insight leaks internal identifiers, route it to local or memory instead and say why.
- Don't over-capture — a few high-value items beat a dump. If nothing durable emerged, say so.
- Sibling end-of-work skill: [[teacher]] grows the user's own knowledge; this one improves the skill repo and prompting.
