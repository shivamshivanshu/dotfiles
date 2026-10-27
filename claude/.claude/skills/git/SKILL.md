---
name: git
description: 'Use when committing, amending, rebasing, squashing fixups, resolving rebase/merge conflicts, managing git worktrees, or addressing code-review comments. Keywords: autosquash, Change-Id, Gerrit review, concise commit message.'
---

# Git Workflow

## Worktrees
- Worktrees are the user's call: they usually create one and start Claude inside it. Never create one unasked — except in preparation per [[autonomous-mode]], and the throwaway detached worktree a `verifier` base re-run creates and removes.
- Keep all worktrees under one central root, `$LOCAL_WORKTREE_ROOT` (default `$HOME/worktree`), named `<repo_name>/<worktree_name>`. The `gwt` / `gwts` / `gwtrm` shell helpers create, switch, and remove them following this scheme. In a Bazel repo, an agent creating a worktree copies main's `user.bazelrc`, and removing one deletes its output base and sweeps orphans — per [[bazel]].
- `EnterWorktree({name})` hardcodes `<repo>/.claude/worktrees/<name>` with no location knob, so never create with it: create under the root (`gwt`, or `git worktree add "$LOCAL_WORKTREE_ROOT/<repo>/<name>" ...`), then enter with `EnterWorktree({path})` (teammates: [[agent-team]]). Only the first switch from the launch directory accepts a path outside `.claude/worktrees/`; to reach another root worktree after that, start a new session in it. `ExitWorktree` won't remove a path-entered worktree — use `git -C <main> worktree remove` (Bazel repo: [[bazel]] first; `gwtrm` needs a TTY for fzf).

## Commit lifecycle
- Prefer atomic commits — one logical change each; squash or regroup later, non-interactively as below.
- Where a review system expects one commit per change (e.g. Gerrit), squash fixups into their logical parent before sending, iterating with `git commit --amend`.
- When updating from the remote, use `git pull -r`, resolving conflicts during the rebase.
- Fixups and autosquash: `git commit --fixup=<sha>`, then `git rebase --autosquash -i <sha>~1` (non-interactive: `GIT_SEQUENCE_EDITOR=true`).
- Regroup without rebase (when commits need re-splitting, not just fixups folded): on a clean tree (`git status --short` empty) and an unpushed branch only, note the old head, `git reset --mixed <base>`, re-stage and re-commit in logical groups, then prove content is unchanged with `git diff <old-head> HEAD` (must be empty).
- For large refactors: expand–migrate–contract (add the new path, move callers over, remove the old), keeping mechanical and semantic changes in separate commits.
- Preserve `Change-Id` across every amend and rebase; two distinct commits never share one, whatever their tickets.
- Stage only the commit's own paths (`git add <paths>`) and check `git diff --cached --stat` against them; read the full `git diff --cached -- <file>` only for a file that also held edits not meant for this commit. A delegated diff's full read is its reviewer's (conformance, simplify), not the main thread's; never `git stash` work you did not write.
- A commit that aborts because `pre-commit` reformatted files is the hook working, not a failure: re-stage the rewritten files and commit again. Never reach for `--no-verify`, and re-read a rewritten file before editing it further — the formatter has changed it under you.

## Commit messages
- Concise; cut boilerplate and the obvious.
- Follow Chris Beams' conventions — imperative, capitalised subject of 50 characters or fewer; blank line; body wrapped at 72; explain what and why, not how.
- Prefix with the ticket id when one exists (e.g. `TICKET-123 Subject`). Committing without one and adding it later via reword is fine.
- Where an org-specific git skill from a plugin applies to the repo, invoke it; its commit-message and review-workflow rules win over this skill's.
- Never add a `Co-Authored-By` trailer or any AI/tool attribution (e.g. "Generated with…") to commit messages.
- After an amend or rebase, run `git show --stat HEAD` to confirm the files, a preserved Change-Id, and a message that matches the content.

## Code review
- Pull the review comments, address them one at a time (smallest first), and draft a reply where no code change is needed; post replies only on the user's go-ahead.
- After addressing feedback, re-audit for correctness and refine the commit message against the ticket.

## Safety
- Prefer `--amend` or a fixup over `reset` plus a new commit. Never drop commits.
- Before `--amend` or any history rewrite, check the oldest commit being rewritten isn't on a remote branch (`git fetch --all`, then `git branch -r --contains <oldest-sha>` must be empty — a remote holding any later commit also contains it); if it is, make a new commit instead — rewriting pushed history needs a force-push. Exception: Gerrit-style `refs/for/*` reviews, where amending the pushed change is the workflow.
