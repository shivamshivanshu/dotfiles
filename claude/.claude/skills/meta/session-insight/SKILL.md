---
name: session-insight
description: Use when the user signals a session is ending or a task is finished — "I'm done", "that's it", "wrap up", "let's close this out", "session insight". Reflects on the session, coaches better prompting, and proposes concrete improvements to the skill/knowledge repos. Keywords: done, wrap up, session summary, retro, improve skills, capture insight, prompt feedback, better prompts.
---

# Session Insight

Run at the end of a session to turn what happened into durable improvements — to the skill repos and to how the user prompts. Propose changes; do not apply them — the user reviews and commits.

## Steps

1. **Summarise the session** in a few terse bullets: what was accomplished and what remains open. No narrative.

2. **Extract durable insights** — only what generalises beyond this one task. Draw both from what happened and from the prompts given:
   - New preferences revealed (how work should be done).
   - Corrections given (what was wrong, and the right way).
   - Recurring patterns or idioms worth codifying.
   - Tooling or environment gotchas and their workarounds.
   Skip one-off details, ticket specifics, and anything already captured.

3. **Coach the prompting.** Review the prompts given this session (they are in the conversation). Where a prompt was ambiguous, underspecified, or led to rework, show a concrete **before → after** rewrite with one line on why the sharper version works. Surface only the top 1–3; skip if the prompts were already clear.

4. **Route each insight** to the right home:

   | Insight | Target |
   |---|---|
   | Generic behaviour, language, or tooling preference, with no work-internal names | Global personal skill in `~/.claude/skills/` (the dotfiles `claude` package) — update an existing skill or add one |
   | Fact tied to a specific repo or project | That project's `CLAUDE.md` or `.claude/skills/` (local) |
   | Anything work-internal (internal hostnames, systems, ticket prefixes, proprietary domain) | Project-local `CLAUDE.md` or Claude memory — never the global dotfiles skills |
   | A durable fact or correction with no natural skill home | Claude memory file |

5. **Propose concrete changes.** For each, name the exact target file and show the specific edit or new-skill draft. Prefer updating an existing skill over creating one — check `~/.claude/skills/{preferences,insights,meta}/` first. Follow the skill-authoring format: frontmatter `name` and a `description` starting with "Use when…", a terse body, and no comment bloat.

6. **Stop for review.** Present the proposals grouped as Global, Local, and Memory. Apply only what is approved, and commit or push only when asked.

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
- update insights/cpp: …
### Local (this repo)
- add to CLAUDE.md: …
### Memory
- …
```

## Guardrails
- Keep the global skills repo free of work-internal names. If an insight leaks internal identifiers, route it to local or memory instead and say why.
- Don't over-capture — one or two high-value insights (and prompt tips) beat a dump. If nothing durable emerged, say so.
- Don't apply edits, create tickets, or push without explicit approval.
- Sibling end-of-work skill: [[teacher]] grows the user's own knowledge; this one improves the skill repo and prompting.
