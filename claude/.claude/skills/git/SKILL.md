---
name: git
description: Use when committing, amending, rebasing, squashing fixups, resolving rebase/merge conflicts, managing git worktrees, or addressing code-review comments. Keywords: autosquash, Change-Id, Gerrit review, concise commit message.
---

# Git Workflow

Git conventions for any repository.

## Worktrees
- Default to one worktree per feature for isolation; several may be active at once. Prefer a worktree over switching branches in place.
- Keep worktrees in a `worktree/` directory beside the repo — in the repo's parent dir — named `worktree/<repo_name>/<worktree_name>`. If that `worktree/` directory does not exist yet, create it first.

## Commit lifecycle
- Prefer atomic commits — one logical change each. Never combine unrelated work into a large commit; use `git rebase -i` to squash or reorder later.
- Where a review system expects one commit per change (e.g. Gerrit), squash fixups into their logical parent before sending, iterating with `git commit --amend`.
- Update with `git pull -r`, resolving conflicts during the rebase.
- Fixups and autosquash: `git commit --fixup=<sha>`, then `git rebase --autosquash -i <sha>~1` (non-interactive: `GIT_SEQUENCE_EDITOR=true`).
- Squash without interactive rebase (when `-i` is unavailable): note the old head, `git reset --mixed <base>`, re-stage and re-commit in logical groups, then prove content is unchanged with `git diff <old-head> HEAD` (must be empty). Unpushed branches only.
- With several changes in flight, keep each in its correct parent commit so it squashes cleanly, and split unrelated concerns into separate commits.
- Preserve `Change-Id` across every amend and rebase; drop a duplicate when two commits share one ticket.
- `git stash` to shelve unrelated in-progress work before staging, so each commit stays atomic.

## Commit messages
- Concise: capture what and why; cut boilerplate and the obvious.
- Follow Chris Beams' conventions — imperative, capitalised subject of 50 characters or fewer; blank line; body wrapped at 72; explain what and why, not how.
- Prefix with the ticket id when one exists (e.g. `TICKET-123 Subject`). Committing without one and adding it later via reword is fine.
- Never add a `Co-Authored-By` trailer or any AI/tool attribution (e.g. "Generated with…") to commit messages.
- Before committing, run `git diff --cached --stat` to confirm only intended files are staged.
- After an amend or rebase, run `git show --stat HEAD` to confirm the files, a preserved Change-Id, and a message that matches the content.

## Code review
- Treat review as a pass separate from implementation. Pull the review comments, address them one at a time (smallest first), and reply where no code change is needed.
- After addressing feedback, re-audit for correctness and refine the commit message against the ticket.

## Safety
- Commit and push only when explicitly asked. Prepare the commit, then stop.
- Prefer `--amend` or a fixup over `reset` plus a new commit. Never drop commits or Change-Ids.
