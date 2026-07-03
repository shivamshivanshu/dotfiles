#!/usr/bin/env python3
import json
import os
import shutil
import subprocess
import sys


def read_message():
    try:
        return json.load(sys.stdin).get("message") or "needs your attention"
    except (json.JSONDecodeError, ValueError):
        return "needs your attention"


def ring_bell():
    # Hook stdout is captured by Claude Code, so write BEL straight to the
    # controlling terminal; wezterm alerts on it even when the pane is unfocused.
    try:
        with open("/dev/tty", "w") as tty:
            tty.write("\a")
            tty.flush()
    except OSError:
        pass


def show_in_tmux(message):
    if os.environ.get("TMUX") and shutil.which("tmux"):
        subprocess.run(["tmux", "display-message", f"Claude: {message}"], check=False)


def main():
    message = read_message()
    ring_bell()
    show_in_tmux(message)


if __name__ == "__main__":
    main()
