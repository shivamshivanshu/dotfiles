---
name: concurrency
description: 'Use when writing or reviewing multithreaded or lock-free code, shared-memory IPC, or reasoning about memory ordering and data races. Keywords: concurrency, atomics, false sharing, SPSC, MPSC, ring buffer, mutex, happens-before, TSan.'
---

# Concurrency

For multithreaded, lock-free, and shared-memory code. Pair with [[cpp]] and [[perf-investigation]].

## Default to simple
- Prefer the simplest correct design: a mutex around a critical section, or message passing over queues, before reaching for lock-free — a last resort justified by measurement.
- Confine mutable state to one owner where possible; share by communicating, not by sharing memory.

## Atomics and ordering
- Know the ordering you rely on: default to `seq_cst` for correctness, and relax to `acquire`/`release` only with a clear happens-before argument.
- A release store publishes the writes before it; an acquire load observes them. Pair them deliberately.
- Never race — unsynchronised access to shared non-atomic data is undefined behaviour, not "probably fine".

## Lock-free patterns
- SPSC ring buffer — single producer, single consumer, head/tail indices — is the cheapest safe queue; reach for it before MPSC.
- MPSC and MPMC add real complexity (CAS loops, ABA); use a vetted implementation rather than hand-rolling one.
- Place producer and consumer indices on separate cache lines (`alignas(64)`) to avoid false sharing.

## Shared-memory IPC
- Lay out shared structures explicitly with fixed sizes and alignment; store offsets or indices, never pointers.
- Version or handshake the layout so both sides agree on it.

## Verify
- Test with sanitizers (TSan) and stress under contention. A passing single-threaded test proves nothing about concurrency.
