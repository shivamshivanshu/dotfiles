#### Git worktree helpers
# Shared by bash and zsh; symlinked to ~/.config/shell/worktree.sh via `stow shell`.
# Every repo's worktrees live centrally under $LOCAL_WORKTREE_ROOT/<repo>/<name>,
# so they sit in one place instead of scattered beside each repo.
export LOCAL_WORKTREE_ROOT="${LOCAL_WORKTREE_ROOT:-$HOME/worktree}"

gwt() {
  local name="$1"
  if [ -z "$name" ]; then echo "usage: gwt <name>" >&2; return 1; fi
  local common repo path
  common=$(git rev-parse --git-common-dir 2>&1) || { echo "gwt: not in a git repo ($common)" >&2; return 1; }
  common=$(cd "$common" 2>/dev/null && pwd) || { echo "gwt: cannot resolve git dir '$common'" >&2; return 1; }
  repo=$(basename "$(dirname "$common")")
  path="$LOCAL_WORKTREE_ROOT/$repo/$name"
  if git show-ref --verify --quiet "refs/heads/$name"; then
    git worktree add "$path" "$name" || return 1
  else
    git worktree add -b "$name" "$path" || return 1
  fi
  cd "$path"
}

gwts() {
  [ -d "$LOCAL_WORKTREE_ROOT" ] || { echo "no worktrees under $LOCAL_WORKTREE_ROOT" >&2; return 1; }
  local path
  path=$(find "$LOCAL_WORKTREE_ROOT" -mindepth 2 -maxdepth 2 -type d 2>/dev/null | fzf) || return
  [ -n "$path" ] && cd "$path"
}

gwtrm() {
  local line path
  line=$(git worktree list 2>/dev/null | tail -n +2 | fzf) || return
  [ -z "$line" ] && return
  path=$(printf '%s\n' "$line" | awk '{print $1}')
  git worktree remove "$path" && git worktree prune && echo "removed $path"
}
