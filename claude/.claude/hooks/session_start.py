#!/usr/bin/env python3
"""SessionStart hook: provision today's scratchpad and surface resumable state.

Emits additionalContext pointing at scratchpad notes, a fresh handoff, and any
/wip checkpoint matching the current repo+branch — state the native --resume
index never surfaces.
"""
import json
import subprocess
import sys
from datetime import datetime, timedelta
from pathlib import Path

NOTES = Path.home() / "claude_notes"
HANDOFF_MAX_AGE = timedelta(hours=48)
MAX_NOTES = 8


def git(cwd, *args):
    try:
        r = subprocess.run(
            ["git", "-C", cwd, *args], capture_output=True, text=True, timeout=5
        )
    except (OSError, subprocess.TimeoutExpired):
        return None
    if r.returncode != 0:
        return None
    return r.stdout.strip() or None


def frontmatter(path):
    try:
        lines = path.read_text().splitlines()[:8]
    except OSError:
        return {}
    pairs = (line.partition(":") for line in lines)
    return {k.strip(): v.strip() for k, _, v in pairs if v}


def newest_fresh_handoff():
    exports = NOTES / "exports"
    if not exports.is_dir():
        return None
    newest = max(exports.glob("*/*.md"), key=lambda f: f.stat().st_mtime, default=None)
    cutoff = (datetime.now() - HANDOFF_MAX_AGE).timestamp()
    return newest if newest and newest.stat().st_mtime > cutoff else None


def main():
    try:
        payload = json.load(sys.stdin)
    except ValueError:
        payload = {}
    cwd = payload.get("cwd") or "."

    now = datetime.now()
    # 4 days so a Friday checkpoint still surfaces on Monday.
    days = [
        NOTES / "scratchpad" / (now - timedelta(days=n)).strftime("%Y%m%d")
        for n in range(4)
    ]
    days[0].mkdir(parents=True, exist_ok=True)

    repo = git(cwd, "rev-parse", "--show-toplevel")
    repo_name = Path(repo).name if repo else None
    branch = git(cwd, "rev-parse", "--abbrev-ref", "HEAD")

    files = [f for day in days for f in sorted(day.glob("*.md"))]
    checkpoints = [
        f
        for f in files
        if f.name.startswith("wip-")
        and (fm := frontmatter(f)).get("repo") == repo_name
        and fm.get("branch") == branch
    ]
    checkpoint = max(checkpoints, key=lambda f: f.stat().st_mtime, default=None)
    notes = [f for f in files if not f.name.startswith("wip-")]
    handoff = newest_fresh_handoff()

    lines = [f"Today's scratchpad dir (plans/notes go here): {days[0]}"]
    if checkpoint:
        lines.append(f"Wip checkpoint for {repo_name}@{branch}: {checkpoint}")
    if handoff:
        lines.append(f"Recent handoff: {handoff}")
    if notes:
        lines.append(
            "Recent scratchpad notes/plans: " + ", ".join(map(str, notes[:MAX_NOTES]))
        )

    context = (
        "Session-resume pointers (SessionStart hook; read what's relevant before"
        " non-trivial work):\n- " + "\n- ".join(lines)
    )
    print(
        json.dumps(
            {
                "hookSpecificOutput": {
                    "hookEventName": "SessionStart",
                    "additionalContext": context,
                }
            }
        )
    )


if __name__ == "__main__":
    main()
