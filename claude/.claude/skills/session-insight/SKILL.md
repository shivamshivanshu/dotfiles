---
name: session-insight
description: 'Use when the wrap command reaches its insight step, or the user explicitly asks for a session retro ("session insight"). Treat wrap-up phrases ("I''m done", "wrap up") as the wrap command, not this skill directly. Reflects on the session, coaches better prompting, and proposes concrete improvements to the skill/knowledge repos. Keywords: session summary, retro, improve skills, capture insight, prompt feedback, better prompts.'
---

# Session Insight

Run at the end of a session to turn what happened into durable improvements — to the skill repos and to how the user prompts. Propose changes; do not apply them — the user reviews first. Normally reached via the `wrap` command; if wrap already ran this skill in this session, don't re-run it.

## Steps

1. **Summarise the session** in a few terse bullets: what was accomplished and what remains open. No narrative.

2. **Extract durable insights** — only what generalises beyond this one task. Draw both from what happened and from the prompts given:
   - New preferences revealed (how work should be done).
   - Corrections given (what was wrong, and the right way).
   - Recurring patterns or idioms worth codifying.
   - Tooling or environment gotchas and their workarounds.
   Skip one-off details, ticket specifics, and anything already captured.

3. **Coach the prompting.** Review the prompts given this session (they are in the conversation). Where a prompt was ambiguous, underspecified, or led to rework, show a concrete **before → after** rewrite with one line on why the sharper version works. Surface only the top 1–3; skip if the prompts were already clear.
   For each, also check whether a CLAUDE.md or skill edit could make the fix automatic — a standing default, or a rule to restate/clarify before acting — and propose that edit alongside the rewrite; config beats coaching when both work.

4. **Route each insight** to the right home:

   | Insight | Target |
   |---|---|
   | Generic behaviour, language, or tooling preference, with no work-internal names | Global personal skill in `~/.claude/skills/` (the dotfiles `claude` package) — update an existing skill or add one |
   | Fact tied to a specific repo or project | That project's `CLAUDE.md` or `.claude/skills/` (local) |
   | Anything work-internal (internal hostnames, systems, ticket prefixes, proprietary domain) | Project-local `CLAUDE.md` or Claude memory — never the global dotfiles skills |
   | A durable fact or correction with no natural skill home | Claude memory file |

   When the local-vs-global call is ambiguous, run a quick 2–3 agent one-round debate ([[stochastic-consensus]]) to categorise; still in doubt → local. Global only if the insight is repo- and employer-independent.

5. **Propose concrete changes.** For each, name the exact target file and show the specific edit or new-skill draft. Prefer updating an existing skill over creating one — check existing skills in `~/.claude/skills/` first (e.g. working-style, git, cpp). Follow the skill-authoring format: frontmatter `name` and a `description` starting with "Use when…", a terse body, and no comment bloat. The description is the whole trigger mechanism and the usual failure is *under*-triggering, so name the situations explicitly instead of trusting keywords to carry it. For the fuller authoring guide — progressive disclosure, bundling resources, explaining *why* over rigid MUSTs — invoke the `skill-creator` skill rather than restating it here.

6. **Audit the library (mechanical — report only if something is found).** Lint the skills for broken `[[wiki-links]]`, leaked work-internal names, and references to files or flags that no longer exist. Strip fenced blocks and inline code spans before matching links — C++ attributes such as `[[nodiscard]]` are identical in form and are not links. Parse every skill's frontmatter with a strict YAML loader too: Claude Code's own parser is lenient, so invalid frontmatter (an unquoted `description` containing `Keywords:`, say) loads fine here and breaks only other tooling. Then check the *claims*, not just the links: wherever a skill cites another by name, verify the assertion it makes about that skill still holds. A link that resolves can still describe a rule that has since changed, and this is the most common way the library goes stale — every edit to a rule needs a sweep for who quotes it. If the session surfaced a repeated unproxied command pattern, propose one `rtk` improvement.

7. **Stop for review.** Present the proposals grouped as Global, Local, and Memory. Apply only what is approved; push only when asked.

## Output shape

```
## Summary
- …

## Insights worth keeping
- …

## Prompting — sharper next time
- before: "…"  →  after: "…"   (why: …)

## Proposed changes
### Global (~/.claude/skills — must stay free of work-internal names)
- update cpp: …
### Local (this repo)
- add to CLAUDE.md: …
### Memory
- …
```

## Guardrails
- Keep the global skills repo free of work-internal names. If an insight leaks internal identifiers, route it to local or memory instead and say why.
- Don't over-capture — one or two high-value insights (and prompt tips) beat a dump. If nothing durable emerged, say so.
- Don't apply edits or push without explicit approval; never create tickets — record them in a file per [[working-style]].
- When run by a subagent, skip the interactive stop-for-review: return the proposals in the report for the main thread to present.
- Sibling end-of-work skill: [[teacher]] grows the user's own knowledge; this one improves the skill repo and prompting.
