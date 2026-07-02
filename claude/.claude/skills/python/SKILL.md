---
name: python
description: Use when writing, reviewing, or testing Python — idioms for pandas, dataclasses/enums, dependency-injection testing, pytest, uv, and datetime/timezone correctness. Keywords: typing, fakeredis, asyncio, GIL.
---

# Python Insights

Idioms and preferences for Python. Pair with [[working-style]].

## Design
- Write idiomatic Python — express intent with comprehensions, context managers, unpacking, and the standard library rather than manual loops and boilerplate.
- Prefer pure, side-effect-free functions: don't mutate arguments or shared state; return new values (frozen dataclasses, tuples). This is the Python analogue of C++ `const`/`noexcept`.
- Separate pure logic from I/O: pure `data -> result` functions with a thin adapter layer. For extensible sets, use one file per unit plus a registry (a spec dataclass and an `ALL_*` list).
- Use `@dataclass(frozen=True)` for data carriers and `dataclasses.replace(...)` for immutable updates; wrap loose dicts into dataclasses for a uniform schema.
- Use `Enum` for closed sets (`class X(str, Enum)` for JSON-friendly, identity-comparable values), and define explicit ordering where rank matters.
- Prefer a value passed explicitly and uniformly over the same value recomputed in two places.

## Typing
- Use `from __future__ import annotations`, PEP 604 unions (`str | None`), and full parameter and return annotations.
- Use `typing.Protocol` and `@runtime_checkable` for structural interfaces, but remove abstractions that prove unused.

## pandas
- Guard `if df.empty:` first.
- Latest-per-group: `sort_values(sortcol).groupby(keys, as_index=False).last()` with `na_position="first"`, so a NaN/NaT never reads as most recent.
- Filter NaN rows before `.map(fn)` (`df[df[col].notna()]`), and use `.to_dict("records")` for JSON-safe detail.

## Datetime and concurrency
- Keep datetimes timezone-aware everywhere via `zoneinfo.ZoneInfo(...)`; never use naive datetimes. Represent `date_id` as `int(strftime("%Y%m%d"))`.
- Use `ThreadPoolExecutor` for independent blocking I/O (the GIL is released during network I/O), and be ready to say whether work is GIL-bound or genuinely parallel.
- For async pubsub, prefer non-blocking `get_message()` with `await asyncio.sleep()` over blocking `listen()`, and perform I/O outside the state lock. Use atomic `SET NX EX` for locks and cooldowns to avoid TOCTOU.

## Testing
- Prefer dependency injection over mocking frameworks: inject functions and sources, and use `fakeredis`, `types.SimpleNamespace` fakes, and `monkeypatch` for module attributes.
- Use pytest with given/when/then, self-documenting names, no docstrings, and functions under roughly 75 lines.
- Be pragmatic about coverage: keep tests that catch regressions, drop trivial ones, and avoid vacuous identity assertions.

## Anti-patterns to fix
- Import-time network side effects → wrap in `@lru_cache` getters or lazy imports.
- `eval()` on untrusted content → `json.loads` or `ast.literal_eval`.
- Bare `except:` that silently swallows errors.
- Heavy or optional dependencies imported at module top → import lazily inside the function.
- Hardcoded secrets or environment constants → move to a configuration dataclass or module.

## Tooling
- Always work in an isolated virtual environment; default to `uv` (or `venv`) for new projects. If the work needs a specific, pre-provisioned conda environment, ask which one rather than assuming or creating it.
- Run subprocesses as `subprocess.run(cmd, check=True, capture_output=True, text=True)` and handle `CalledProcessError` (reading `returncode` and `stderr`).
- Expect a pre-commit formatter (black or ruff) that may rewrite and re-stage files.
- Stay faithful to the source of truth (reference notebook or spec) unless told to deviate.
