---
name: python
description: 'Load before writing, editing, reviewing or testing any Python, even a single function or a snippet answered in chat, and in every simplify or code-review pass over Python changes — idioms for pandas, dataclasses/enums, dependency-injection testing, pytest, uv, and datetime/timezone correctness. Keywords: typing, fakeredis, asyncio, GIL.'
---

# Python Insights

Idioms and preferences for Python. Pair with [[working-style]].

## Design
- Write idiomatic Python — express intent with comprehensions, context managers, unpacking, and the standard library rather than manual loops and boilerplate.
- Separate pure logic from I/O: pure `data -> result` functions with a thin adapter layer. For sets expected to grow (plugins, checks, reports), use one file per unit plus a registry (a spec dataclass and an `ALL_*` list).
- Use `@dataclass(frozen=True)` for data carriers and return new values (`dataclasses.replace(...)`, tuples) instead of mutating; wrap loose dicts into dataclasses for a uniform schema.
- Use `Enum` for closed sets, and define explicit ordering where rank matters. For JSON-friendly values that compare equal to plain strings use `StrEnum` (3.11+). Below 3.11 use `class X(str, Enum)`; it formats as `X.A` on 3.11+, so code spanning versions emits `.value` explicitly.
- Compute a derived value once and pass it explicitly to every consumer; don't recompute it in each.

## Typing
- Use PEP 604 unions (`str | None`) and full parameter and return annotations, checked by the repo's mypy/pyright config if it has one. Target the repo's `requires-python`: below 3.14 add `from __future__ import annotations` unless a runtime consumer can't resolve the strings — types defined inside a function, or a library version that reads raw `__annotations__` (check its docs; current pydantic supports the import); 3.14+ defers them natively, so omit it once runtime consumers handle deferred annotations (a name imported only under `TYPE_CHECKING` raises `NameError` on direct `__annotations__` access).
- Use `typing.Protocol` for structural interfaces; add `@runtime_checkable` only when you `isinstance` against it (it checks member presence, not signatures). Remove abstractions that prove unused.

## pandas
- Guard `if df.empty:` before indexing or reducing (`iloc[0]`, `max`, `idxmax`).
- Latest-per-group: `sort_values(sortcol, kind="stable", na_position="first").drop_duplicates(keys, keep="last")` — `groupby().last()` takes the last non-null per column and can stitch one row from several. The default quicksort is unstable, so ties on `sortcol` pick arbitrarily; when input order is not the tie-break, sort on an explicit tie-break column too.
- `.map(fn, na_action="ignore")` skips NaN and keeps the row; filter (`df[df[col].notna()]`) only when the rows should go.
- For JSON use `df.to_json(orient="records", date_format="iso")`: `.to_dict("records")` keeps NaN (`json.dumps` emits invalid `NaN`) and `Timestamp` (not serialisable); use it for Python-side detail only.

## Datetime
- Keep datetimes timezone-aware via `zoneinfo.ZoneInfo(...)`: `datetime.now(tz)`, never `utcnow()`/`utcfromtimestamp()`.
- Represent `date_id` as `int(strftime("%Y%m%d"))`, taken after converting to the zone that defines the business date (venue-local for trading dates). For sessions crossing midnight, take the session's trade date from the exchange calendar, formatted `%Y%m%d`.
- `datetime` holds microseconds; keep exchange nanosecond timestamps as int64, `datetime64[ns]` or `pd.Timestamp`.

## Concurrency and async
- Use `ThreadPoolExecutor` for independent blocking I/O (the GIL is released during network I/O); CPU-bound pure Python → `ProcessPoolExecutor`. When proposing threads, state whether the work is GIL-bound or genuinely parallel.
- Never call a blocking sync API inside a coroutine (sync redis-py `listen()` blocks the loop). With `redis.asyncio`, `async for msg in pubsub.listen()` is fine; use `await pubsub.get_message(timeout=...)` in a loop when the loop must also check shutdown or state. Perform I/O outside the state lock.
- Use atomic Redis `SET NX EX` for locks and cooldowns to avoid TOCTOU. A lock stores a unique token and releases by token-checked delete — use `client.lock(name, timeout=...)`, which returns the sync or `redis.asyncio` Lock matching the client; a plain `DEL` after expiry deletes the next holder's lock. When work may outlive the TTL, renew only through the lock's token-checked `extend()`; where a stale holder could still write, add a fencing token — a monotonic `INCR` taken with the lock, which the downstream store checks and rejects when stale; the Redis `Lock` supplies none. A single-instance lock is not safe across Redis failover.

## Testing
- Prefer dependency injection over mocking frameworks: inject functions and sources, and use `fakeredis`, `types.SimpleNamespace` fakes, and `monkeypatch` for module attributes.
- Use pytest with `# given` / `# when` / `# then` section markers (a sanctioned exception to the no-comment rule), self-documenting names, no docstrings, and functions under roughly 75 lines.
- Keep tests that catch regressions; drop trivial ones and vacuous identity assertions.

## Anti-patterns
- Import-time network side effects, or heavy/optional dependencies imported at module top → `@lru_cache` getters, or import inside the function.
- `eval()` on untrusted content → `json.loads` or `ast.literal_eval`.
- Bare `except:` (also catches `KeyboardInterrupt`/`SystemExit`) → catch the specific exception and let the rest propagate.
- Hardcoded secrets → env or a secret store, never in source. Hardcoded environment constants → a configuration dataclass or module.

## Tooling
- Work in an isolated virtual environment whenever installing dependencies (stdlib-only scripts run on the interpreter the repo already uses); use the repo's existing env tooling, and `uv` for new projects. If the work needs a specific, pre-provisioned conda environment, ask which one rather than assuming or creating it.
- Run subprocesses as `subprocess.run(cmd, check=True, text=True)`, adding `capture_output=True` only when the output is consumed — long-running or streaming commands inherit stdout. Catch `CalledProcessError` only to recover or add context, surfacing `returncode` and, when captured, `stderr` (`stderr=subprocess.PIPE` captures it while stdout streams).
- Stay faithful to the source of truth (reference notebook or spec) unless told to deviate: same outputs and semantics (numbers match); the structure may be idiomatic.
