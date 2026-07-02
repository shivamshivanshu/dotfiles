---
name: perf-investigation
description: Use when investigating latency, throughput, CPU hotspots, or a performance regression — profiling tools, measurement discipline, and the usual culprits. Keywords: perf, profiling, flamegraph, latency, throughput, hotspot, cache miss, false sharing, TSC, rdtsc, regression, benchmark.
---

# Performance Investigation

A playbook for latency and throughput work. Pair with [[cpp]] and [[concurrency]].

## Approach
- Measure before changing; never optimise on a hunch. Form a hypothesis, then confirm it with data.
- Establish a baseline and a repeatable workload, and compare like for like.
- Find the dominant cost first by profiling, fix that, and re-measure. Don't micro-optimise noise.
- State what a change costs and buys — startup versus hot path, and the measured delta.

## Tools
- CPU hotspots: `perf record` / `perf report` and flamegraphs; `perf stat` for IPC, cache misses, and branch misses.
- Latency accounting: timestamp each stage (hardware/NIC timestamps where available); use TSC/`rdtsc` for cycle-level intervals, but beware unsynchronised or stale TSC across cores.
- Allocation and heap: heap profilers; watch for allocation on the hot path.
- Cache and memory: `perf c2c` for false sharing; check the cache-miss rate before blaming the algorithm.

## Usual culprits
- Work on the hot path that could be precomputed or cached, or a repeated lookup that could be hoisted.
- False sharing — unrelated data on one cache line; separate with padding or `alignas(64)`.
- Poor locality and pointer chasing; unnecessary copies and allocations.
- Lock contention and syscalls on the fast path.
- Branch mispredictions in tight loops.

## Discipline
- Confirm the win with the same measurement that showed the problem.
- Keep the change minimal and readable — a faster hot path still has to be understood.
