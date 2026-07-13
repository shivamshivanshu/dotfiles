#### Git worktree helpers
# Every repo's worktrees live centrally under $LOCAL_WORKTREE_ROOT/<repo>/<name>,
# so they sit in one place instead of scattered beside each repo.
export LOCAL_WORKTREE_ROOT="${LOCAL_WORKTREE_ROOT:-$HOME/worktree}"

_gwt_repo() {
  local common
  common=$(git rev-parse --path-format=absolute --git-common-dir 2>/dev/null) || return 1
  basename "$(dirname "$common")"
}

gwt() {
  local name="$1"
  if [ -z "$name" ]; then echo "usage: gwt <name>" >&2; return 1; fi
  # "path" is off-limits as a name: in zsh it is tied to PATH, and localizing
  # it empties PATH inside the function.
  local repo wt_path
  repo=$(_gwt_repo) || { echo "gwt: not in a git repo" >&2; return 1; }
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
  local repo scope="$LOCAL_WORKTREE_ROOT" depth=2 wt_path
  repo=$(_gwt_repo)
  if [ -n "$repo" ] && [ -d "$LOCAL_WORKTREE_ROOT/$repo" ]; then
    scope="$LOCAL_WORKTREE_ROOT/$repo" depth=1
  fi
  wt_path=$(find "$scope" -mindepth "$depth" -maxdepth "$depth" -type d 2>/dev/null | fzf) || return
  cd "$wt_path"
}

gwtrm() {
  local wt_path
  wt_path=$(git worktree list --porcelain 2>/dev/null | sed -n 's/^worktree //p' | tail -n +2 | fzf) || return
  git worktree remove "$wt_path" && git worktree prune && echo "removed $wt_path"
}
