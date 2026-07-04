#!/usr/bin/env python3
"""Claude Code Notification hook: rings the terminal bell and raises a
WezTerm desktop toast, forwarding correctly through tmux."""
import json
import os
import shutil
import subprocess
import sys

ESC = "\x1b"
BELL = "\x07"
DEFAULT_MESSAGE = "needs your attention"
DESKTOP_TOAST_START = f"{ESC}]9;"  # OSC 9: WezTerm desktop notification
DESKTOP_TOAST_END = BELL
TMUX_PASSTHROUGH_START = f"{ESC}Ptmux;"
TMUX_PASSTHROUGH_END = f"{ESC}\\"


def read_event():
    try:
        return json.load(sys.stdin)
    except ValueError:
        return {}


def format_toast(event, label):
    label = label or os.path.basename(event.get("cwd") or "")
    message = event.get("message") or DEFAULT_MESSAGE
    title = f"Claude [{label}]" if label else "Claude"
    return f"{title}: {message}"


def terminal_sequence(toast):
    # An ESC or BELL inside the text would close the escape sequence early.
    toast = toast.replace(ESC, "").replace(BELL, "")
    desktop_toast = f"{DESKTOP_TOAST_START}{toast}{DESKTOP_TOAST_END}"
    inside_tmux = bool(os.environ.get("TMUX"))
    if inside_tmux:
        # tmux only forwards the OSC when wrapped in its passthrough envelope
        # (needs allow-passthrough on), with every inner ESC doubled.
        desktop_toast = (
            TMUX_PASSTHROUGH_START
            + desktop_toast.replace(ESC, ESC + ESC)
            + TMUX_PASSTHROUGH_END
        )
    return BELL + desktop_toast


def display_in_tmux_status(toast):
    if os.environ.get("TMUX") and shutil.which("tmux"):
        subprocess.run(["tmux", "display-message", toast], check=False)


def main():
    label = sys.argv[1] if len(sys.argv) > 1 else None
    toast = format_toast(read_event(), label)
    display_in_tmux_status(toast)
    # Hook stdout is captured by Claude Code, so write to the controlling tty;
    # the bytes travel through tmux/ssh to the local terminal.
    try:
        with open("/dev/tty", "w") as tty:
            tty.write(terminal_sequence(toast))
    except OSError:
        pass


if __name__ == "__main__":
    main()
