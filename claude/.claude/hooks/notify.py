#!/usr/bin/env python3
import json
import os
import shutil
import subprocess
import sys


def read_event():
    try:
        return json.load(sys.stdin)
    except ValueError:
        return {}


def toast_text(event, label):
    label = label or os.path.basename(event.get("cwd") or "")
    message = event.get("message") or "needs your attention"
    title = f"Claude [{label}]" if label else "Claude"
    return f"{title}: {message}"


def notification_bytes(text):
    # BEL for sound, OSC 9 for a wezterm desktop toast; tmux only forwards
    # the OSC when wrapped in its passthrough envelope (allow-passthrough on).
    # ESC/BEL inside the text would terminate the sequence early, so strip them.
    text = text.replace("\x1b", "").replace("\x07", "")
    osc = f"\x1b]9;{text}\a"
    if os.environ.get("TMUX"):
        osc = "\x1bPtmux;" + osc.replace("\x1b", "\x1b\x1b") + "\x1b\\"
    return "\a" + osc


def show_in_tmux(text):
    if os.environ.get("TMUX") and shutil.which("tmux"):
        subprocess.run(["tmux", "display-message", text], check=False)


def main():
    label = sys.argv[1] if len(sys.argv) > 1 else None
    text = toast_text(read_event(), label)
    show_in_tmux(text)
    # Hook stdout is captured by Claude Code, so write to the controlling tty;
    # the bytes travel through tmux/ssh to the local terminal.
    try:
        with open("/dev/tty", "w") as tty:
            tty.write(notification_bytes(text))
    except OSError:
        pass


if __name__ == "__main__":
    main()
