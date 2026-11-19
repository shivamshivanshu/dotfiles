---
name: perf-investigation
description: 'Use when investigating latency, throughput, CPU hotspots, or a performance regression — profiling tools, measurement discipline, and the usual culprits. Keywords: perf, flamegraph, cache miss, false sharing, TSC, rdtsc, benchmark.'
---

# Performance Investigation

Pair with [[cpp]], [[cpp-build]] and [[concurrency]].

## Approach
- Measure before changing: form a hypothesis, then confirm it with data.
- Establish a baseline and a repeatable workload, and compare like for like: same box, pinned and isolated cores, fixed frequency governor (turbo and deep C-states off), NUMA-local memory and NIC, IRQs off the measured cores, warm-up done. Set what the box allows; on a shared host ask before changing its governor or isolation with sudo. Record each control's actual state with the result, and mark a result with uncontrolled items not production-comparable.
- Run benchmarks on a quiet box: check load first (`uptime`, `mpstat -P <cores>`), start no builds or agents while one runs (backgrounding it is fine), and in a team run ask the lead to quiesce the other legs first. Interleave baseline and candidate runs (ABAB…) so drift hits both.
- Latency is a distribution: report p50/p99/p99.9/max over N repeated runs, never a mean alone. A delta inside the run-to-run spread is noise.
- Microbenchmarks run warm-cache while a real hot path often runs cold between packets — validate a win in the replay/simulation too; stop dead-code elimination with `benchmark::DoNotOptimize`.
- Profile to find the dominant cost, fix that, and confirm the win with the same measurement that showed the problem. Don't micro-optimise noise.
- State what a change costs and buys — startup versus hot path, and the measured delta.

## Tools
- CPU hotspots: `perf record` / `perf report` and flamegraphs on the optimised build (`-c opt`, never `dbg`); `perf stat` for IPC, cache misses, and branch misses. `-O2` omits frame pointers, so build with `-fno-omit-frame-pointer` or record with `--call-graph dwarf` (or `lbr`), else stacks truncate plausibly. A busy-poll thread samples ~100% in its poll loop — measure per event (TSC spans, `perf stat`), not by sample share.
- Latency accounting: timestamp each stage (hardware/NIC timestamps where available); for cycle-level intervals use serialized TSC reads on a pinned thread — start `lfence; rdtsc; lfence`, end `rdtscp; lfence` (`rdtscp` waits for earlier instructions but lets later ones start) — subtract the reads' own overhead, check invariant TSC (`constant_tsc nonstop_tsc` in `/proc/cpuinfo`), and calibrate to ns — beware unsynchronised or stale TSC across cores. Carry a source or hardware timestamp through every copy and forward untouched — never overwrite or zero it with a local or derived time — and guard latency arithmetic against stale timestamps wherever a message and its timing source are not strictly one-to-one.
- Allocation and heap: heaptrack, or tcmalloc/jemalloc heap profiling. Prove a hot path allocation-free with a test that replaces every replaceable `operator new` form (aligned, nothrow, array) or hooks `malloc`, plus any custom pool or arena the path uses, counts per thread, warms up once, then expects zero across a steady-state call.
- Cache and memory: `perf c2c` for false sharing; check the cache-miss rate before blaming the algorithm.

## Usual culprits
- Work on the hot path that could be precomputed or cached, or a repeated lookup that could be hoisted.
- False sharing — unrelated data on one cache line; separate per [[concurrency]].
- Poor locality and pointer chasing; unnecessary copies and allocations.
- Lock contention and syscalls on the fast path.
- Branch mispredictions in tight loops.
