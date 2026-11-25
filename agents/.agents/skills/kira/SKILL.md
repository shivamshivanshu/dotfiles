---
name: kira
description: Inspect and manage Kira tickets, workflows, blockers, and branch history in a Git-native Kira repo.
---

# Kira

Run `kira` in the target checkout or use `kira -C <checkout>`. Run Git checks in the same checkout, for example `git -C <checkout> status`. Run `kira --help` to list commands and `kira <command> --help` for usage and flags, including nested commands such as `kira config set --help`. From a Kira source checkout, `go run ./cmd/kira -C <checkout> ...` runs that source against the target repo.

## Configure a repository

- Run `kira init --key DEMO` in an existing Git repo to scaffold and commit a commented `.kira/config.yaml`.
- Run `kira config explain` in the target checkout to see effective settings and where they came from. Run it again after editing to verify the loaded config.
- Edit `.kira/config.yaml` for project settings such as boards, saved filters, and ticket workflows. For supported scalar keys, use `kira config set <key> <value>`, for example `kira config set project.name 'Demo project'`. This can create a Git commit in auto mode.

In the Kira source checkout, `docs/user_manual/05-configuration-reference.md` documents the config keys and examples.

## Read the backlog

- `kira show <ref> --json` reads a ticket. Use its immutable `id` for CLI references that must survive renumbering. `kira log <ref>` shows field changes and linked commits.
- `kira list --query 'type = ticket AND category = todo AND NOT blocked' --json` finds todo tickets with no detected open blockers across workflows. `kira blockers <ref>` reports actionable blockers and incomplete chains and ranks blockers for an epic.
- `kira now` identifies the active ticket. `kira review --base <ref>` summarizes committed branch changes and previews closes.

## Read the workflow

Get the subtype from `kira show <ref> --json`. State overrides support `bug`, `task`, `feature`, and `support`. Use exact state names for moves and categories for cross-workflow queries.

- For a configured `ticket_states.<subtype>` workflow in `.kira/config.yaml`, the first state is the creation state and the last must have category `done` and is the close target.
- Tickets without an override use `TODO`, `IN_PROGRESS`, `REVIEW`, `DONE`, and `WONT_DO`. They start at `TODO` and close to `DONE`.
- Epics use `PLANNED`, `ACTIVE`, and `DONE`. They start at `PLANNED` and close to `DONE`.

## Apply requested changes

- Use Kira mutations for validation and Git bookkeeping. Create without an editor with `kira create ticket --subtype task --title 'Descriptive title' --no-edit`. Pass `--board <key>` when multiple active boards have no default. Use `edit --field`, `move`, and `comment -m` for updates.
- Check `commit.mode` with `kira config explain` and check Git status before any Kira operation that can commit. Auto mode normally commits the affected paths. Manual mode stages them. Leave those changes staged unless a commit is in scope. Reserve `kira commit` for intentionally staging and committing all pending `.kira/` changes, including unstaged and untracked files.
- During an in-progress merge, cherry-pick, or revert, Kira's commit can include the entire Git index, including staged changes outside `.kira/`. Defer operations that would commit until the Git operation finishes. After a failed mutation, check the ticket and Git status before retrying.
- Preview a historical restore with `kira restore <ref> --at <git-ref> --dry-run`. The default restores prose and preserves current comments. Use repeatable `--field` selectors for specific fields.
- Use the display `number` (e.g. `KIRA-42`) for both trailers. `Kira-Ticket: <number>` links a commit. The installed post-merge hook, `kira sync`, and `kira index --closes` can apply `Kira-Closes: <number>` once the commit is in the history of the effective `git.landed_ref`. The scan skips items in the `done` category and items updated after the trailer commit's committer timestamp. It can close eligible items despite open blockers.
- `kira workon <ref>` switches or creates a branch, or uses a worktree with `--worktree` or `workon.worktree`. It sets the active ticket in that checkout and can move an item outside `doing` to its first `doing` state, including reopening a done item. Use `--no-move` to skip the transition while activating the ticket. Check its warnings if you expected a move.
- Run `kira sync` when requested. It pulls with rebase, reconciles ticket numbers, and can apply landed closes. `--commit` checkpoints dirty `.kira/` paths before pulling. Check `sync.push` with `kira config explain`. Either `--push` or `sync.push: true` enables pushing, and `--push=false` leaves a configured push enabled. Check that pushing is in scope when enabled. Inspect the step report even on exit zero.
