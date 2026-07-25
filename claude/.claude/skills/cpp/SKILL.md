---
name: cpp
description: 'Use when writing, reviewing, building, testing, or debugging C++ — idioms, Bazel/GoogleTest workflow, low-latency patterns, and debugging habits. Keywords: std::optional, CRTP, constexpr, EXPECT_THAT, gdb, coredump, perf, clangd.'
---

# C++ Insights

For performance-sensitive C++. Prefer the latest standard the code or build tool already targets; when it isn't obvious, default to C++20. Assume Linux x86-64 as the execution target unless the repo says otherwise — development often happens on macOS; don't tune for it. Pair with [[working-style]].

## Idioms
- Prefer pure, side-effect-free functions, and express and enforce it with `const`, `noexcept`, and `[[nodiscard]]`, passing inputs by `const&`.
- Prefer `std::optional` over sentinels or try/catch for "maybe" results, and avoid try/catch as control flow. Return `nullopt` and let the caller decide.
- Enforce invariants with asserts rather than silent fallbacks.
- Prefer compile-time dispatch over runtime polymorphism: CRTP, `if constexpr`, concepts, `static_assert`, and variadic fan-out over `std::function`. Confirm there is no runtime cost.
- Give templates well-thought names and constrain them with concepts where it is straightforward — it makes intent and error messages far clearer.
- When a block inside a function does one logical unit of work, wrap it in a well-named local lambda and call it — readers can treat the lambda as a black box.
- Collapse near-duplicate functions into overloads.
- Pass per-entity data in a dedicated params struct by `const&`; keep feature-specific fields out of shared or common types, defining them in the owning module.
- Verify library-feature availability against the `-std` flag. `-std=c++23` does not guarantee an STL feature exists on the toolchain; check before relying on bleeding-edge STL.
- Run a modernisation and const-correctness sweep as its own pass once code works: add `const`, `noexcept`, `[[nodiscard]]`, `std::to_underlying`, and structured bindings — often a separate commit.

## Build, test, debug
- Bazel: do not pass your own `--config`; the user's `bazelrc` already sets it. Background long builds and tests per [[working-style]] — backgrounding the run itself is the cheap way to satisfy that rule. Route them through an agent only when the verbose output also needs filtering or summarising, since a spawn costs a whole extra context.
- Treat regression and integration simulations as the primary verification loop: run them, then inspect the output data directly — columns populated, values in range. Bless new expected outputs only after verifying them.
- GoogleTest: use modern matchers (`EXPECT_THAT`/`ASSERT_THAT`) over legacy macros. Tests must be meaningful — mock the component to prove the bug, and mirror existing error-path tests. Weigh the cost of writing them first.
- Greppable, tagged debug prints are acceptable during investigation; strip them before finalising.
- Coredump and gdb: distrust the first backtrace; cross-reference crash-time logs to find the thread that actually crashed, and resolve missing symbols before trusting a stack. Report root cause and surrounding state, not just the trace.
- clangd: generate `compile_commands.json` via `bazel aquery`. Known issue — it resolves in the main checkout but breaks in worktrees due to base-path resolution.

## Latency and performance
- Wire-to-wire latency is the primary concern: preserve true source hardware timestamps, and do not blindly reset fields.
- Guard latency arithmetic against stale timestamps where a message and its timing source are not strictly one-to-one; verify per feed and per exchange.
- For measurement discipline and the usual culprits (hot-path work, false sharing, locality), see [[perf-investigation]].
