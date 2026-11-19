@~/.agents/AGENTS.md
@skills/working-style/SKILL.md

An active output style governs the replies it shapes (a handover, an explanation); AGENTS.md and working-style govern the rest.

In the top-level interactive session, run the `wrap` command when the user signals wrap-up; when their overall ask looks done, offer it once per session in one line instead; after a decline, wait for their signal. Never in a spawned agent (subagent, teammate, fork, Workflow agent).
