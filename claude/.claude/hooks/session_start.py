#!/usr/bin/env python3
"""SessionStart hook: provision today's scratchpad and surface resumable state.

Emits additionalContext pointing at scratchpad notes, a fresh handoff, any
/wip checkpoint matching the current repo+branch, and the installed output
styles — state and capabilities the native --resume index never surfaces.
"""
import json
import subprocess
import sys
from datetime import datetime, timedelta
from pathlib import Path

NOTES = Path.home() / "claude_notes"
STYLES = Path.home() / ".claude" / "output-styles"
# 4 days so Friday's handoff or checkpoint still surfaces on Monday.
RESUME_WINDOW_DAYS = 4
MAX_NOTES = 8


def git(cwd, *args):
    try:
        r = subprocess.run(
            ["git", "-C", cwd, *args], capture_output=True, text=True, timeout=3
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


def newest_fresh_handoff(repo_name):
    exports = NOTES / "exports"
    if not exports.is_dir():
        return None
    cutoff = (datetime.now() - timedelta(days=RESUME_WINDOW_DAYS)).timestamp()
    fresh = [
        f
        for f in exports.glob("*/*.md")
        if f.stat().st_mtime > cutoff and frontmatter(f).get("repo") == repo_name
    ]
    return max(fresh, key=lambda f: f.stat().st_mtime, default=None)


def main():
    try:
        payload = json.load(sys.stdin)
    except ValueError:
        payload = {}
    cwd = payload.get("cwd") or "."

    now = datetime.now()
    days = [
        NOTES / "scratchpad" / (now - timedelta(days=n)).strftime("%Y%m%d")
        for n in range(RESUME_WINDOW_DAYS)
    ]
    days[0].mkdir(parents=True, exist_ok=True)

    worktrees = git(cwd, "worktree", "list", "--porcelain")
    main_worktree = worktrees.splitlines()[0].removeprefix("worktree ") if worktrees else None
    repo_name = Path(main_worktree).name if main_worktree else None
    branch = (git(cwd, "symbolic-ref", "--short", "-q", "HEAD") or "HEAD") if repo_name else None

    files = [f for day in days for f in sorted(day.glob("*.md"))]
    checkpoints = [
        f
        for f in files
        if f.name.startswith("wip-")
        and (fm := frontmatter(f)).get("repo") == repo_name
        and fm.get("branch") == branch
    ]
    checkpoint = max(checkpoints, key=lambda f: f.stat().st_mtime, default=None) if repo_name else None
    notes = sorted(
        (f for f in files if not f.name.startswith("wip-")),
        key=lambda f: f.stat().st_mtime,
        reverse=True,
    )
    handoff = newest_fresh_handoff(repo_name) if repo_name else None

    lines = [f"Today's scratchpad dir (plans/notes go here): {days[0]}"]
    if checkpoint:
        lines.append(f"Wip checkpoint for {repo_name}@{branch}: {checkpoint}")
    if handoff:
        lines.append(f"Recent handoff: {handoff}")
    if notes:
        lines.append(
            "Recent scratchpad notes/plans: " + ", ".join(map(str, notes[:MAX_NOTES]))
        )
    styles = (
        sorted(frontmatter(p).get("name", p.stem) for p in STYLES.glob("*.md"))
        if STYLES.is_dir()
        else []
    )
    if styles:
        lines.append(
            "Output styles installed (switch with /output-style <name>): "
            + ", ".join(styles)
        )

    context = (
        "Session-resume pointers (SessionStart hook; read what's relevant before"
        " non-trivial work):\n- " + "\n- ".join(lines)
    )
    output = {"hookEventName": "SessionStart", "additionalContext": context}
    if repo_name and branch and payload.get("source") == "startup":
        output["sessionTitle"] = f"{repo_name}@{branch}"
    print(json.dumps({"hookSpecificOutput": output}))


if __name__ == "__main__":
    main()
