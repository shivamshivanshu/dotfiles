#### Git worktree helpers
# Shared by bash and zsh; symlinked to ~/.config/shell/worktree.sh via `stow shell`.
# Every repo's worktrees live centrally under $LOCAL_WORKTREE_ROOT/<repo>/<name>,
# so they sit in one place instead of scattered beside each repo.
export LOCAL_WORKTREE_ROOT="${LOCAL_WORKTREE_ROOT:-$HOME/worktree}"

gwt() {
  local name="$1"
  if [ -z "$name" ]; then echo "usage: gwt <name>" >&2; return 1; fi
  # "path" is off-limits as a name: in zsh it is tied to PATH, and localizing
  # it empties PATH inside the function.
  local common repo wt_path
  common=$(git rev-parse --path-format=absolute --git-common-dir 2>&1) || { echo "gwt: not in a git repo ($common)" >&2; return 1; }
  repo=$(basename "$(dirname "$common")")
  wt_path="$LOCAL_WORKTREE_ROOT/$repo/${name//\//-}"
  if git show-ref --verify --quiet "refs/heads/$name"; then
    git worktree add "$wt_path" "$name" || return 1
  else
    git worktree add -b "$name" "$wt_path" || return 1
  fi
  cd "$wt_path"
}

gwts() {
  [ -d "$LOCAL_WORKTREE_ROOT" ] || { echo "no worktrees under $LOCAL_WORKTREE_ROOT" >&2; return 1; }
  local wt_path
  wt_path=$(find "$LOCAL_WORKTREE_ROOT" -mindepth 2 -maxdepth 2 -type d 2>/dev/null | fzf) || return
  cd "$wt_path"
}

gwtrm() {
  local wt_path
  wt_path=$(git worktree list --porcelain 2>/dev/null | sed -n 's/^worktree //p' | tail -n +2 | fzf) || return
  git worktree remove "$wt_path" && git worktree prune && echo "removed $wt_path"
}
