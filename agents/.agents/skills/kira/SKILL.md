---
name: kira
description: Inspect and manage Kira tickets, workflows, blockers, and branch history in a Git-native Kira repo.
---

# Kira

Run `kira` in the target checkout or use `kira -C <checkout>`. Check command-specific help for the installed version. From a Kira source checkout, `go run ./cmd/kira -C <checkout> ...` runs that source against the target repo.

## Read the backlog

- `kira show <ref> --json` reads a ticket. Use its `id` for references that must survive renumbering. `kira log <ref>` shows field changes and linked commits.
- `kira list --query 'type = ticket AND category = todo AND NOT blocked' --json` finds ready tickets across workflows. `kira blockers <ref>` finds actionable blockers and ranks them for an epic.
- `kira now` identifies the active ticket. `kira review --base <ref>` summarizes committed branch changes and previews closes. Use `git status` for pending worktree edits.

## Read the workflow

Get the subtype from `kira show <ref> --json`. Read state overrides from `ticket_states.<subtype>` in `.kira/config.yaml`. The allowed subtypes are `bug`, `task`, `feature`, and `support`.

Use exact names for moves and categories for cross-workflow queries. The first configured state is the creation state. The last must be in the `done` category and is the automatic close target. Default ticket states are `TODO`, `IN_PROGRESS`, `REVIEW`, `DONE`, and `WONT_DO`. Automatic closure targets `DONE`. Epics use `PLANNED`, `ACTIVE`, and `DONE`.

## Apply requested changes

- Use Kira mutations for validation and Git bookkeeping. Create without an editor with `kira create ticket --subtype task --title 'Descriptive title' --no-edit`. Use `edit --field`, `move`, and `comment -m` for updates.
- Check `commit.mode` with `kira config explain`. Auto mode commits mutations. Manual mode stages them. `kira commit` stages and commits all pending `.kira/` changes.
- Preview a historical restore with `kira restore <ref> --at <git-ref> --dry-run`. The default restores prose and preserves current comments. Use repeatable `--field` selectors for specific fields.
- `Kira-Ticket: <number>` links a commit. `Kira-Closes: <number>` closes the ticket when the commit reaches `git.landed_ref` and can bypass open blockers.
- `kira workon` switches branches or creates a worktree. Pass `--no-move` to keep the ticket's state. `kira sync` can rebase, apply landed closes, and push if configured.
