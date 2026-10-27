---
name: bazel
description: 'Use when running Bazel builds or tests in a git worktree, creating or removing a worktree of a Bazel repo, choosing cache-related bazel flags, or suspecting a bad cache hit. Keywords: bazel, disk cache, remote cache, output base, worktree, remote_download_outputs, seed_disk_cache, user.bazelrc, git worktree remove.'
---

# Bazel caches across worktrees

- Each worktree has its own output base (`bazel info output_base`), server and `bazel-out`; only the disk cache is shared. Entries are keyed by input content, so rebases and concurrent worktrees need no invalidation.
- Before the first build in a worktree, look for the gitignored `user.bazelrc` at its root. Missing there but present in the main checkout → copy it: `cp "$(git worktree list --porcelain | sed -n '1s/^worktree //p')/user.bazelrc" .`. Missing in both → skip the seeding bullets and ask the user whether to add one (a shared `--disk_cache` plus `build:seed_disk_cache --remote_download_outputs=all`).
- By default Bazel downloads only top-level outputs, so most remote-cache hits never reach the disk cache. `--config=seed_disk_cache` downloads them all, so a later fresh worktree builds from disk (measured: 82s against 192s unseeded), at +4–6G per output base. Toggling it costs no re-analysis.
- If `user.bazelrc` has `build --config=seed_disk_cache`, every build already seeds. Otherwise seed on the command line only — never in a bazelrc, never in a worktree the user created (one not created by you or your lead this session): the lead seeds once, on the first build of a base commit other worktrees or agents will build, then starts them. Later builds pass nothing extra.
- Removing a worktree you created: `ob=$(bazel info output_base); bazel shutdown`, then `git worktree remove <path>`, then `chmod -R u+w "$ob"; rm -rf "$ob"` — otherwise its 27–33G output base is orphaned.
- Suspected bad cache hit: an in-place rebuild is short-circuited by the local action cache, so rebuild in a throwaway base — `ob=$(mktemp -d); bazel --output_base="$ob" build --symlink_prefix=/ --disk_cache= --noremote_accept_cached <target>`, a full local build — and diff `bazel-bin/<path>` against `"$ob"/execroot/*/bazel-out/*/bin/<path>`. Then `bazel --output_base="$ob" shutdown; chmod -R u+w "$ob"; rm -rf "$ob"`, and report a mismatch to the user before touching any cache; never delete `~/.cache/bazel/disk` while any worktree builds.
