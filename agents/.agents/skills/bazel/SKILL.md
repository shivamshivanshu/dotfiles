---
name: bazel
description: 'Use before any local Bazel build, test or run (choosing the debug --config from user.bazelrc, sizing --jobs and the target set), and when creating, entering or removing a git worktree of a Bazel repo, cleaning orphaned output bases, estimating how many Bazel servers or builds the host can run, or suspecting a bad cache hit. Keywords: --jobs, OOM, devenv crash, output base, user.bazelrc, DO_NOT_BUILD_HERE, bazel shutdown, remote cache.'
---

# Bazel: local builds and worktrees (Linux; macOS paths differ and are not covered)

Commands run from the building workspace's root.

## Build config: debug by default
Applies to `build`, `test`, `run`, `coverage`, `cquery`, `aquery`.
- Release only when the user's prompt asks for it, by naming release, a `*Release` config, `-c opt` or "optimized". A perf, latency or benchmark task without one of those → ask. Everything else is debug.
- Reference: the active configs in the building workspace's `user.bazelrc`, else in the main checkout's (first line of `git worktree list`). The file is gitignored, so a worktree may lack it: `grep -E '^[[:space:]]*(build|common)[[:space:]]' user.bazelrc | grep -oE -- '--config=[^[:space:]]+' | cut -d= -f2`.
- Available debug configs: `{ echo .bazelrc; sed -nE 's#^(try-)?import +%workspace%/##p' .bazelrc; } | xargs grep -hoE '^(build|common):[A-Za-z][A-Za-z0-9_]*Debug\b' 2>/dev/null | cut -d: -f2 | sort -u`. It reads only `.bazelrc` and what that file imports, and skips `_` mixins. Per-user rc files elsewhere in the tree are not loaded by Bazel.
- Choose: `user.bazelrc`'s configs ending in `Debug`. Failing that, the first tier with candidates: `*FastDebug`, then other `*Debug`. Exactly one candidate → use it; none or several → ask, listing them. A non-Debug config in `user.bazelrc` (e.g. `GccRelease`) is overridden, not respected. Release: the same order with `Release` for `Debug`.
- Pass `--config=<chosen>` on every command above, unless the building workspace's `user.bazelrc` already activates it. Measured on rr-cuttlefish: a repeat doubles repeatable flags (`--per_file_copt`), so the agent's builds and the user's discard each other's analysis cache. Never pass it to `query`, `info`, `shutdown` or `fetch`: `query` rejects a `build:`-only config (measured).
- Keep one config for the session unless the prompt changes it, since switching discards the server's analysis cache. Name the config and N (next section) in your first status, and in the brief of any agent you delegate a Bazel command to.
- A config's name says nothing about optimization (rr-cuttlefish: `CfClangFastDebug` is `-c opt` with debug info), so always size per the next section.

## Size every local build or test
Default `--jobs` is the core count, and Bazel's RAM budget does not hold back C++ compiles. Measured 2026-11-20 on a DevEnv (128 cores, 384G): 80 concurrent `clang++ -O3` at up to 5.4G each took the container from 197G to 371G in ~90 s. The previous identical run hung and restarted the DevEnv.
- Narrow first: build or test only the targets the change reaches, named explicitly. Don't add wide `//pkg/...` patterns or an `rdeps(//repo/..., ...)` result on top; that is how a check grows to 126 tests and 51k actions. Widen in stages once the narrow set passes.
- Measure the host. Limits sit on ancestors of this cgroup too. At each level with a numeric `memory.max`, free = max − (`memory.current` − `inactive_file`), i.e. minus the working set the kubelet evicts on, not page cache. **The limiting cgroup** is the level with the least free. Cores = the smallest `cpu.max` quota/period:
  ```sh
  d=/sys/fs/cgroup$(sed -n 's/^0:://p' /proc/self/cgroup); while [ "$d" != /sys/fs ]; do m=$(cat "$d/memory.max" 2>/dev/null); [ "${m:-max}" != max ] && echo "$d free=$(( (m - $(cat "$d/memory.current") + $(awk '/^inactive_file /{print $2}' "$d/memory.stat")) >> 30 ))G max=$((m >> 30))G cpu=$(cat "$d/cpu.max" 2>/dev/null)"; d=${d%/*}; done
  ```
  If no level is numeric (or there is no cgroup v2), use `nproc` and `free -g`, and say the figure may be node-wide.
- N = min(cores, free / per-action peak). If this workspace's server isn't running yet, first take one server RSS off free (6–10G measured; live servers: `ps -eo rss=,args= | grep '[A]-server.jar'`). Per-action peak in KiB, while a build compiles: `ps -eo rss=,comm= | awk '$2 ~ /^(clang|cc1plus)/{print $1}' | sort -n | tail -1`. Nothing measured → assume 6G. E.g. 360G free and a 6G peak → 60.
- Put `--jobs=N` after every `--config`: configs expand in place, and some set their own (rr-cuttlefish `CfRelease`: `--jobs=128`). Tests run within `--jobs`; a test heavier than the per-action peak also needs `--local_test_jobs=M`, M = free / test RSS.
- Parallel builds (worktrees, agents) share the host: split N as `--jobs=N/K` for K concurrent builds, and run at most free / server RSS servers at once. Tell the user before exceeding either.
- Run the build in the background under a watcher (`d` = the limiting cgroup). At 90% working set it SIGINTs only this build's client, once (repeated interrupts kill the server). The build stops cleanly and the server and cache survive (measured); rerun with a smaller N:
  ```sh
  d=<limiting cgroup>; bazel <cmd> [--config=<chosen>] --jobs=<N> <targets> & pid=$!; while kill -0 $pid 2>/dev/null; do u=$(( $(cat $d/memory.current) - $(awk '/^inactive_file /{print $2}' $d/memory.stat) )); [ $((u * 100 / $(cat $d/memory.max))) -ge 90 ] && { pkill -INT -P $pid || kill -INT $pid; break; }; sleep 5; done; wait $pid; echo exit=$?
  ```
  `pkill -P` reaches the real client when `bazel` is bazelisk. The client honours SIGINT even though a background job starts with it ignored: measured in bash and zsh, exit 8, server kept.

## Model
- Each worktree has its own output base `~/.cache/bazel/_bazel_$USER/<md5 of workspace path>`, server and `bazel-out`; the output base's `DO_NOT_BUILD_HERE` holds the workspace path. Worktrees share only the remote cache.
- Cache keys hash every input's content, so rebases and concurrent worktrees need no invalidation.
- An output base is ~30G after one full build and reaches hundreds of G in a long-lived worktree. Nothing ever cleans the output base of a removed worktree — see Remove.
- `bazel info` and `bazel shutdown` create a missing output base, and `info` starts a server: never use them to find an output base you mean to delete. Never match servers with `pgrep -f`; it matches the shell running the check.

## Create a worktree (agent-created only; never alter a worktree the user made)
- Before its first build, copy main's `user.bazelrc` in, if it has one.
- Split `--jobs` across parallel builds per Size.

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

## Suspected bad cache hit
An in-place rebuild is short-circuited by the local action cache, so rebuild in a throwaway base with no cache at all (`--remote_cache=` also stops it uploading to the shared cache) and the suspect build's own flags:
```sh
ob=$(mktemp -d); echo "$ob"; bazel --output_base="$ob" build <same flags as the suspect build> --jobs=<N per Size, less one server RSS> --symlink_prefix=/ --disk_cache= --remote_cache= <target>
```
A full local build. Diff `bazel-bin/<path>` against `<ob>/execroot/_main/bazel-out/<cfg>/bin/<path>`, `<cfg>` being the directory `readlink bazel-bin` names before `/bin`. Then `bazel --output_base=<ob> shutdown; chmod -R u+w <ob>; rm -rf <ob>`, and report a mismatch to the user.
