#!/usr/bin/env python3
"""Claude Code notification hook.

Keeps a per-window tmux state glyph current (busy/waiting/done) and raises a
WezTerm desktop toast — but only when the user isn't already looking at the
window, since the glyph covers the watched case."""
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
STATE_GLYPHS = {"busy": "●", "done": "✓", "waiting": "◐"}
GLYPH_FRAGMENT = "#{?#{@claude_state}, #{@claude_state},}"


def read_event():
    try:
        return json.load(sys.stdin)
    except ValueError:
        return {}


def format_toast(event, message):
    label = os.path.basename(event.get("cwd") or "")
    text = message or event.get("message") or DEFAULT_MESSAGE
    title = f"Claude [{label}]" if label else "Claude"
    return f"{title}: {text}"


def terminal_sequence(toast):
    # An ESC or BELL inside the text would close the escape sequence early.
    safe = toast.replace(ESC, "").replace(BELL, "")
    desktop_toast = f"{DESKTOP_TOAST_START}{safe}{DESKTOP_TOAST_END}"
    if os.environ.get("TMUX"):
        # tmux only forwards the OSC when wrapped in its passthrough envelope
        # (needs allow-passthrough on), with every inner ESC doubled.
        desktop_toast = (
            TMUX_PASSTHROUGH_START
            + desktop_toast.replace(ESC, ESC + ESC)
            + TMUX_PASSTHROUGH_END
        )
    return desktop_toast


def tmux(*args):
    r = subprocess.run(["tmux", *args], capture_output=True, text=True, check=False)
    return r.stdout


def tmux_pane():
    pane = os.environ.get("TMUX_PANE")
    ok = pane and os.environ.get("TMUX") and shutil.which("tmux")
    return pane if ok else None


def user_is_watching():
    pane = tmux_pane()
    if not pane:
        return False
    out = tmux("display", "-p", "-t", pane, "#{window_active} #{session_attached}")
    parts = out.split()
    return len(parts) == 2 and parts[0] == "1" and parts[1] != "0"


def ensure_glyph_rendered():
    # Self-healing: re-appends whenever a theme (re)load resets the formats,
    # so the conf needs no tpm-ordered append and re-sourcing cannot duplicate.
    for opt in ("window-status-format", "window-status-current-format"):
        if "claude_state" not in tmux("show", "-gv", opt):
            tmux("set", "-ga", opt, GLYPH_FRAGMENT)


def set_tmux_window_state(message):
    pane = tmux_pane()
    if pane:
        ensure_glyph_rendered()
        tmux("set-option", "-w", "-t", pane, "@claude_state", STATE_GLYPHS.get(message, ""))


def main():
    message = sys.argv[1] if len(sys.argv) > 1 else None
    set_tmux_window_state(message or "waiting")
    if message == "busy" or user_is_watching():
        return
    toast = format_toast(read_event(), message)
    # Hook stdout is captured by Claude Code, so write to the controlling tty;
    # the bytes travel through tmux/ssh to the local terminal.
    try:
        with open("/dev/tty", "w") as tty:
            tty.write(terminal_sequence(toast))
    except OSError:
        pass


if __name__ == "__main__":
    main()
