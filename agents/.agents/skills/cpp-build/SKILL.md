---
name: cpp-build
description: 'Use when building, testing or debugging C++, including writing GoogleTest tests. Keywords: bazel, bazelrc, -c opt, EXPECT_THAT, gtest, gdb, coredump, backtrace, clangd, compile_commands.json, regression simulation, bless.'
---

# C++ Build, Test and Debug

When editing C++, also load [[cpp]].

- Bazel: the user's `bazelrc` sets the build config. Pass only a named config it defines (`--config=tsan`, `--config=asan`) or `-c opt`, and only when the task needs one. Caches and worktrees: [[bazel]].
- Treat regression and integration simulations as the primary verification loop: run them, then inspect the output data directly — columns populated, values in range. Bless (overwrite the expected outputs) once a diff of old against new explains every changed field; name the bless in the report and the commit message.
- GoogleTest: modern matchers (`EXPECT_THAT`/`ASSERT_THAT`) over legacy macros. Mock the component to prove the bug, and follow the nearest existing test for the same error path.
- Greppable, tagged debug prints are acceptable during investigation; strip them before committing.
- Coredump and gdb: distrust the first backtrace; start from `thread apply all bt`, cross-reference crash-time logs to find the thread that actually crashed, and resolve missing symbols before trusting a stack. Report root cause and surrounding state, not just the trace.
- clangd: generate `compile_commands.json` with the repo's `bazel aquery`-based extractor. It resolves in the main checkout but breaks in worktrees due to base-path resolution: in a worktree, generate it there, then rewrite the main checkout's path prefix to the worktree's: `MAIN=$(git worktree list --porcelain | sed -n '1s/^worktree //p') WT=$(git rev-parse --show-toplevel) perl -pi -e 's#(?:\Q$ENV{WT}\E|\Q$ENV{MAIN}\E)(?=[/"\s]|$)#$ENV{WT}#g' compile_commands.json` (literal, path-boundary anchored, idempotent, safe for a worktree nested in the main checkout).
