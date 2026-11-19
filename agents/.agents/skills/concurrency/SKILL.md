---
name: concurrency
description: 'Use when writing or reviewing multithreaded or lock-free C++, shared-memory IPC, or reasoning about memory ordering and data races. Keywords: concurrency, atomics, false sharing, SPSC, MPSC, ring buffer, mutex, happens-before, TSan.'
---

# Concurrency

For multithreaded, lock-free, and shared-memory code. Pair with [[cpp]] and [[perf-investigation]].

## Choosing a design
- How data is handed between threads — a lock-free structure versus a lock or a message queue — on any cross-thread path, cold handoffs (config reload, logging, shutdown) included, is a user call: present the options with their costs (latency, complexity, verification burden) and ask before committing to one — in the plan gate, or before kickoff in autonomous mode ([[autonomous-mode]]). State no default design. A lone atomic flag or counter ordered per the rules below is not that choice. In review, flag a new or changed choice that the plan or decisions file doesn't record as a user call; don't rewrite it.
- Confine mutable state to one owner where possible.

## Atomics and ordering
- Know the ordering you rely on: default to `seq_cst`; relax to `acquire`/`release` (`acq_rel` on an RMW) only with a clear happens-before argument, and to `relaxed` only for atomicity-only state nothing is published through (counters, stats). Fences (`atomic_thread_fence`) are protocol tools too — derive each op's or fence's order from the argument. Write the argument as a comment at the op, naming its paired op — a non-obvious why, so the comment rule allows it.
- An acquire load synchronizes with a release store only when it reads that store's value (or its release sequence); only then are the writes before the release visible.
- Never race — unsynchronised access to shared non-atomic data is undefined behaviour, not "probably fine".

## Lock-free patterns
- SPSC ring buffer is the cheapest safe queue; reach for it before MPSC. Reference shape: each index written by one side only (release store) and read by the other (acquire load); each side caches the other's index and re-reads it only when the ring looks full or empty; head and tail are unmasked monotonic unsigned counters, masked only to index a power-of-two array, so `head - tail` is the occupancy (0 empty, capacity full) and stays correct across wraparound.
- MPSC and MPMC add real complexity (CAS loops, ABA); use a vetted implementation — the repo's, else an established library (folly, Boost.Lockfree, moodycamel) — rather than hand-rolling one.
- Place producer and consumer indices on separate cache lines to avoid false sharing: the repo's named constant if it has one, else a named 128 on x86 (Intel's adjacent-line prefetcher pairs 64-byte lines); never `std::hardware_destructive_interference_size` across an ABI boundary (GCC `-Winterference-size`).

## Shared-memory IPC
- Lay out shared structures explicitly with fixed sizes and alignment; store offsets or indices, never pointers. `static_assert` each shared type `std::is_trivially_copyable_v` and `std::is_standard_layout_v`, and its `sizeof`/`offsetof`.
- Only `std::atomic<T>` with `static_assert(std::atomic<T>::is_always_lock_free)` in shared memory — a non-lock-free atomic locks a process-local table and synchronises nothing across processes. The standard only recommends that lock-free atomics be address-free; GCC and Clang on Linux deliver it, another platform needs its documented guarantee. `std::mutex`/`condition_variable` are not process-shared; a lock there is a `pthread_mutex` with `PTHREAD_PROCESS_SHARED` (and `PTHREAD_MUTEX_ROBUST` if a holder can die — the next locker gets `EOWNERDEAD`, repairs or reinitialises the protected state, then calls `pthread_mutex_consistent()`, else the mutex becomes `ENOTRECOVERABLE` for everyone; test that path).
- Version or handshake the layout so both sides agree on it, and define the init/lifetime protocol. Ownership is an `flock` on a lock file beside the segment, held by the owner for its whole life — a segment outlives a crash, so `O_EXCL` alone cannot elect after a restart. Whoever acquires the lock knows no owner is alive: it `shm_unlink`s any existing segment (stale, or stuck not-ready from an owner that died mid-init), recreates it with `shm_open(O_CREAT | O_EXCL)`, and immediately `ftruncate`s to the full layout size. Peers wait until `fstat` shows that size before `mmap` (touching a mapping past the file's end raises SIGBUS, not not-ready). The owner constructs the shared object in place (placement new), bumps a generation number, then release-stores a ready word; both live in a fixed header outside that object. Peers acquire-poll only the ready word before touching anything else, record the generation at attach, and re-attach when it changes.

## Verify
- Test with sanitizers (TSan) and stress under contention, threads pinned to distinct physical cores (not SMT siblings). A passing single-threaded test proves nothing about concurrency.
- Neither proves memory ordering. TSan does not model standalone `atomic_thread_fence` (GCC warns `-Wtsan`) and cannot see cross-process shared memory; x86 TSO hides every reordering but store→load, so a missing acquire/release passes x86 stress and breaks on ARM or a new compiler. For relaxed or acquire/release code, the written happens-before argument is the proof; back it with a model checker (GenMC, Relacy) or an aarch64 run where one is available.
