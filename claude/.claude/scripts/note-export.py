#!/usr/bin/env python3
"""Render the current Claude Code session transcript to a dated markdown note.

Usage: note-export.py [name]
Writes $HOME/claude_notes/exports/YYYYMMDD/<name-or-slug-of-first-prompt>.md
"""
import json
import os
import re
import sys
from datetime import datetime
from pathlib import Path


def project_transcript_dir():
    mangled = re.sub(r"[^A-Za-z0-9]", "-", os.getcwd())
    return Path.home() / ".claude" / "projects" / mangled


def latest_transcript(directory):
    files = sorted(directory.glob("*.jsonl"), key=lambda p: p.stat().st_mtime, reverse=True)
    return files[0] if files else None


def load_entries(path):
    entries = []
    with path.open() as f:
        for line in f:
            line = line.strip()
            if not line:
                continue
            try:
                entries.append(json.loads(line))
            except ValueError:
                continue
    return entries


def text_of(content):
    if isinstance(content, str):
        return content
    if not isinstance(content, list):
        return ""
    parts = []
    for block in content:
        if not isinstance(block, dict):
            continue
        kind = block.get("type")
        if kind == "text":
            parts.append(block.get("text", ""))
        elif kind == "tool_use":
            parts.append(f"_[tool: {block.get('name', '?')}]_")
        elif kind == "tool_result":
            parts.append("_[tool result]_")
        # thinking blocks are internal reasoning — omit
    return "\n".join(p for p in parts if p)


def messages(entries):
    for entry in entries:
        msg = entry.get("message") or {}
        role = msg.get("role") or entry.get("type")
        if role not in ("user", "assistant"):
            continue
        body = text_of(msg.get("content")).strip()
        if body:
            yield role, body


def render(entries):
    blocks = []
    for role, body in messages(entries):
        who = "User" if role == "user" else "Claude"
        blocks.append(f"## {who}\n\n{body}\n")
    return "\n".join(blocks)


def first_prompt(entries):
    for role, body in messages(entries):
        if role == "user":
            return body.splitlines()[0]
    return ""


def slugify(text):
    slug = re.sub(r"[^A-Za-z0-9]+", "-", text.lower()).strip("-")
    return slug[:50].strip("-") or "chat"


def unique(path):
    n = 2
    candidate = path
    while candidate.exists():
        candidate = path.with_name(f"{path.stem}-{n}{path.suffix}")
        n += 1
    return candidate


def main():
    transcript_dir = project_transcript_dir()
    transcript = latest_transcript(transcript_dir)
    if not transcript:
        print(f"No session transcript found in {transcript_dir}", file=sys.stderr)
        return 1

    entries = load_entries(transcript)
    name = " ".join(sys.argv[1:]).strip()
    slug = slugify(name) if name else slugify(first_prompt(entries))

    out_dir = Path.home() / "claude_notes" / "exports" / datetime.now().strftime("%Y%m%d")
    out_dir.mkdir(parents=True, exist_ok=True)
    out = unique(out_dir / f"{slug}.md")

    header = f"# {name or slug}\n\n_Exported {datetime.now():%Y-%m-%d %H:%M} from {transcript.name}_\n\n"
    out.write_text(header + render(entries))
    print(f"Exported chat -> {out}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
