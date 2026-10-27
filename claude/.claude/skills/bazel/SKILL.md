---
name: bazel
description: 'Use when creating, entering or removing a git worktree of a Bazel repo, running Bazel builds or tests in a worktree, cleaning orphaned output bases, estimating how many Bazel servers or builds the host can run, or suspecting a bad cache hit. Keywords: output base, user.bazelrc, DO_NOT_BUILD_HERE, bazel shutdown, remote cache.'
---

# Bazel across worktrees (Linux; macOS paths differ and are not covered)

## Model
- Each worktree has its own output base `~/.cache/bazel/_bazel_$USER/<md5 of workspace path>`, server and `bazel-out`; the output base's `DO_NOT_BUILD_HERE` holds the workspace path. Worktrees share only the remote cache.
- Cache keys hash every input's content, so rebases and concurrent worktrees need no invalidation.
- An output base is ~30G after one full build and reaches hundreds of G in a long-lived worktree. Nothing ever cleans the output base of a removed worktree — see Remove.
- `bazel info` and `bazel shutdown` create a missing output base, and `info` starts a server: never use them to find an output base you mean to delete. Never match servers with `pgrep -f`; it matches the shell running the check.

## Create a worktree (agent-created only; never alter a worktree the user made)
- Before its first build, copy main's `user.bazelrc` in, if it has one.
- Cap parallel worktree builds per Estimate.

## Remove a worktree (agent-created, e.g. once its work is merged; the user's on request)
Each Bash call is a fresh shell: carry the printed paths into later commands literally.
1. Find its output base and any server (one call; replace `<worktree>`):
   ```sh
   wt=$(cd <worktree> && pwd -P) || exit 1
   ob=$(find ~/.cache/bazel/_bazel_$USER -mindepth 2 -maxdepth 2 -name DO_NOT_BUILD_HERE -exec grep -lxF -- "$wt" {} + | xargs -r -n1 dirname)
   echo "wt=$wt ob=$ob"; [ -n "$ob" ] && ps -eo pid=,args= | grep '[A]-server.jar' | grep -F -- "--output_base=$ob"
   ```
   More than one `ob` → stop and report. A server listed → `(cd <wt> && bazel shutdown)`.
2. From the main checkout (never from inside the worktree being removed): `git -C <main> worktree remove <wt> && git -C <main> worktree prune`. Only if that succeeds, `ob=<ob>; [ -n "$ob" ] && chmod -R u+w "$ob" && rm -rf "$ob"` — as a background command, since a large base outlasts the Bash timeout.
3. Orphan sweep — list output bases whose workspace no longer exists:
   ```sh
   find ~/.cache/bazel/_bazel_$USER -mindepth 2 -maxdepth 2 -name DO_NOT_BUILD_HERE | while read -r f; do w=$(cat "$f"); [ -e "$w" ] || echo "$(dirname "$f")  $w"; done
   ```
   Show each with `du -sh` and its old workspace path, and ask which to delete. For each approved one, kill any server the `ps` line above finds (its worktree is gone, so `bazel shutdown` cannot reach it), then delete as in step 2. Never touch `install/` or `cache/`.

## Estimate (report only)
- Limits this container may use sit on an ancestor of its cgroup, so walk up and take the smallest numeric `memory.max` and `cpu.max` (quota/period = cores). `memory.current` counts page cache, so free RAM = `memory.max` − (`memory.current` − `inactive_file` from that level's `memory.stat`), the working set the kubelet evicts on:
  ```sh
  d=/sys/fs/cgroup$(sed -n 's/^0:://p' /proc/self/cgroup); while [ "$d" != /sys/fs ]; do [ -r "$d/memory.max" ] && echo "$d $(cat "$d/memory.max") $(cat "$d/memory.current") $(cat "$d/cpu.max" 2>/dev/null)"; d=${d%/*}; done
  ```
  If every level says `max` (or there is no cgroup v2), use `nproc` and `free -g`, and say the figure may be node-wide.
- Per server: RSS of a live server (`ps -eo rss=,args= | grep '[A]-server.jar'`; 6–10G measured). Per build: cpu and memory from `grep -rhE -- '--local_(resources|cpu_resources|ram_resources)' /etc/bazel.bazelrc /etc/bazel .bazelrc user.bazelrc ~/.bazelrc 2>/dev/null` (no globs: an unmatched glob aborts the command in zsh); with none set, Bazel takes all cores and ~67% of RAM per build.
- Report idle servers ≈ free RAM / per server, and full-parallel builds ≈ min(cores / cpu per build, free RAM / (memory per build + per server)).
- Cap parallel worktree builds at the server figure, which assumes mostly cache hits; when builds will compile locally (cold base commit, remote off), cap at max(1, the build figure). Tell the user before exceeding the build figure.

## Suspected bad cache hit
An in-place rebuild is short-circuited by the local action cache, so rebuild in a throwaway base with no cache at all (`--remote_cache=` also stops it uploading to the shared cache) and the suspect build's own flags:
```sh
ob=$(mktemp -d); echo "$ob"; bazel --output_base="$ob" build <same flags as the suspect build> --symlink_prefix=/ --disk_cache= --remote_cache= <target>
```
A full local build. Diff `bazel-bin/<path>` against `<ob>/execroot/_main/bazel-out/<cfg>/bin/<path>`, `<cfg>` being the directory `readlink bazel-bin` names before `/bin`. Then `bazel --output_base=<ob> shutdown; chmod -R u+w <ob>; rm -rf <ob>`, and report a mismatch to the user.
