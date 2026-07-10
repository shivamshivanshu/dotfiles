#!/usr/bin/env python3
"""Keybind cheatsheet generated live from the dotfiles configs."""

import argparse
import html
import json
import os
import re
import subprocess
import sys
from dataclasses import dataclass, field
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
from typing import Callable, List, Optional, Tuple

Row = Tuple[str, str, str]


@dataclass(frozen=True)
class Section:
    title: str
    rows: List[Row]


@dataclass(frozen=True)
class Tool:
    title: str
    sections: List[Section] = field(default_factory=list)
    notes: List[str] = field(default_factory=list)
    error: Optional[str] = None


def repo_root() -> Path:
    here = Path(__file__).resolve()
    for parent in here.parents:
        if (parent / "tmux" / ".tmux.conf").is_file():
            return parent
    raise FileNotFoundError(f"no ancestor of {here} contains tmux/.tmux.conf")


def _join_continuations(lines: List[str]) -> List[str]:
    out: List[str] = []
    buf = ""
    for line in lines:
        stripped = line.rstrip()
        if stripped.endswith("\\"):
            buf += stripped[:-1] + " "
        else:
            out.append(buf + stripped)
            buf = ""
    if buf:
        out.append(buf)
    return out


_TMUX_SECTION_RE = re.compile(r"^###\s*─+\s*(.+?)\s*─+\s*$")
_TMUX_BIND_RE = re.compile(r"^(?:bind|bind-key)\s+(.*)$")


def _tmux_key_display(flags: List[str], table: Optional[str], key: str) -> str:
    if table:
        prefix = f"{table}: "
    elif "-n" in flags:
        prefix = ""
    else:
        prefix = "prefix "
    suffix = " (repeat)" if "-r" in flags else ""
    return prefix + key + suffix


def parse_tmux(root: Path) -> Tool:
    text = (root / "tmux" / ".tmux.conf").read_text()
    raw_lines = text.splitlines()

    prefix_match = re.search(r"^set\s+-g\s+prefix\s+(\S+)", text, re.M)
    prefix = prefix_match.group(1) if prefix_match else "?"

    sections: List[Section] = []
    current = Section("General", [])
    last_comment: Optional[str] = None
    for line in _join_continuations(raw_lines):
        line = line.strip()
        header = _TMUX_SECTION_RE.match(line)
        if header:
            if current.rows:
                sections.append(current)
            current = Section(header.group(1), [])
            last_comment = None
            continue
        if line.startswith("#"):
            if last_comment is None:
                last_comment = line.lstrip("# ").strip()
            continue
        if not line:
            last_comment = None
            continue
        bind = _TMUX_BIND_RE.match(line)
        if not bind:
            last_comment = None
            continue
        tokens = bind.group(1).split()
        flags: List[str] = []
        table: Optional[str] = None
        while tokens and tokens[0].startswith("-") and len(tokens[0]) > 1:
            flag = tokens.pop(0)
            flags.append(flag)
            if flag == "-T" and tokens:
                table = tokens.pop(0)
        if not tokens:
            continue
        t = tokens[0]
        key = t[1:-1] if len(t) >= 3 and t[0] == t[-1] and t[0] in "'\"" else t
        command = " ".join(tokens[1:])
        trailing = re.search(r"\s#(?!\{)\s*(.+)$", command)
        desc = last_comment or ""
        if trailing:
            command = command[: trailing.start()].rstrip()
            desc = trailing.group(1)
        current.rows.append((_tmux_key_display(flags, table, key), command, desc))
        last_comment = None
    if current.rows:
        sections.append(current)

    return Tool(
        "tmux",
        sections,
        notes=[
            f"prefix: {prefix}",
            "TPM plugin binds (vim-tmux-navigator C-h/j/k/l, extrakto prefix+Tab, resurrect) aren't parsed.",
        ],
    )


_ALIAS_RE = re.compile(r"""alias\s+([\w.-]+)=(['"])(.*?)\2""")
_FUNC_RE = re.compile(r"^([A-Za-z_][\w]*)\(\)\s*\{", re.M)
_USAGE_RE = re.compile(r"usage:\s*([^\"']+)")


def parse_shell(root: Path) -> Tool:
    shell_dir = root / "shell" / ".config" / "shell"
    sections: List[Section] = []
    notes: List[str] = []

    alias_rows = [
        (name, value, "")
        for name, _, value in _ALIAS_RE.findall((shell_dir / "alias.sh").read_text())
    ]
    sections.append(Section("Aliases (alias.sh)", alias_rows))

    wt_text = (shell_dir / "worktree.sh").read_text()
    header = next(
        (l.lstrip("# ").strip() for l in wt_text.splitlines() if l.startswith("#")), ""
    )
    func_rows: List[Row] = []
    matches = list(_FUNC_RE.finditer(wt_text))
    for i, m in enumerate(matches):
        body_end = matches[i + 1].start() if i + 1 < len(matches) else len(wt_text)
        body = wt_text[m.end() : body_end]
        usage = _USAGE_RE.search(body)
        func_rows.append(
            (m.group(1), usage.group(1).strip() if usage else m.group(1), header)
        )
    sections.append(Section("Functions (worktree.sh)", func_rows))

    fzf_text = (shell_dir / "fzf.sh").read_text()
    fzf_binds = re.findall(r"^\s*(?:bind|bindkey)\s+.*$", fzf_text, re.M)
    if fzf_binds:
        sections.append(Section("fzf binds (fzf.sh)", [(b, "", "") for b in fzf_binds]))
    else:
        fzf_vars = sorted(set(re.findall(r"\b(FZF_\w+)=", fzf_text)))
        notes.append("fzf defaults (fzf.sh sets env only, no key binds): " + ", ".join(fzf_vars))

    return Tool("shell", sections, notes=notes)


def _find_wezterm_leader(root: Path) -> Optional[str]:
    for lua in (root / "wezterm").rglob("*.lua"):
        m = re.search(
            r"""leader\s*=\s*\{\s*key\s*=\s*["'](.+?)["']\s*,\s*mods\s*=\s*["'](.+?)["']""",
            lua.read_text(),
        )
        if m:
            return f"{m.group(2)}+{m.group(1)}"
    return None


def _short_action(action: str) -> str:
    action = re.sub(r"\s+", " ", action).strip().rstrip(",")
    return re.sub(r"^(wezterm\.action|act)\.", "", action)


def parse_wezterm(root: Path) -> Tool:
    path = root / "wezterm" / ".config" / "wezterm" / "shivam" / "keys.lua"
    text = path.read_text()
    rows: List[Row] = []
    for m in re.finditer(r"\{\s*key\s*=", text):
        start = m.start()
        depth = 0
        end = start
        for i in range(start, len(text)):
            if text[i] == "{":
                depth += 1
            elif text[i] == "}":
                depth -= 1
                if depth == 0:
                    end = i + 1
                    break
        entry = text[start:end]
        key_m = re.search(r"""key\s*=\s*(["'])(.+?)\1""", entry)
        mods_m = re.search(r"""mods\s*=\s*(["'])(.+?)\1""", entry, re.S)
        act_m = re.search(r"action\s*=\s*(.+)\}\s*$", entry, re.S)
        if not (key_m and act_m):
            continue
        mods = mods_m.group(2) if mods_m else ""
        combo = f"{mods}+{key_m.group(2)}" if mods else key_m.group(2)
        line_start = text.rfind("\n", 0, start)
        prev_line = text[text.rfind("\n", 0, line_start) + 1 : line_start].strip()
        desc = prev_line.lstrip("- ").strip() if prev_line.startswith("--") else ""
        rows.append((combo, _short_action(act_m.group(1)), desc))

    leader = _find_wezterm_leader(root)
    notes = [f"leader: {leader}" if leader else "leader: not set"]
    return Tool("wezterm", [Section("keys.lua", rows)], notes=notes)


_NVIM_MODES = ["n", "x", "o", "i", "t"]
_NVIM_CMD_LOAD = (
    "+lua pcall(function() local names = {} "
    "for _, p in ipairs(require('lazy').plugins()) do names[#names+1] = p.name end "
    "require('lazy').load({plugins = names}) end)"
)
_NVIM_CMD_DUMP = (
    "+lua local maps = {} "
    "for _, mode in ipairs({'n','x','o','i','t'}) do "
    "for _, m in ipairs(vim.api.nvim_get_keymap(mode)) do "
    "if m.desc and m.desc ~= '' then "
    "maps[#maps+1] = {mode = mode, lhs = m.lhs, desc = m.desc} end end end "
    "local cmds = {} "
    "for name, c in pairs(vim.api.nvim_get_commands({builtin = false})) do "
    "cmds[#cmds+1] = {name = name, desc = type(c.definition) == 'string' "
    "and c.definition:sub(1, 80) or ''} end "
    "io.write(vim.json.encode({maps = maps, cmds = cmds}))"
)


def _nvim_leader(root: Path) -> str:
    init = root / "nvim" / ".config" / "nvim" / "init.lua"
    m = re.search(r"""vim\.g\.mapleader\s*=\s*(["'])(.*?)\1""", init.read_text())
    return m.group(2) if m else " "


def parse_nvim(root: Path) -> Tool:
    proc = subprocess.run(
        ["nvim", "--headless", _NVIM_CMD_LOAD, _NVIM_CMD_DUMP, "+qa"],
        capture_output=True,
        text=True,
        timeout=20,
    )
    out = proc.stdout
    start, end = out.find("{"), out.rfind("}")
    if start < 0 or end <= start:
        raise ValueError(f"no JSON object in nvim output (stderr: {proc.stderr[:200]})")
    data = json.loads(out[start : end + 1])

    leader = _nvim_leader(root)
    merged = {}
    for m in data["maps"]:
        lhs = m["lhs"]
        if lhs.startswith(leader):
            lhs = "<leader>" + lhs[len(leader) :]
        lhs = lhs.replace(" ", "<Space>")
        merged.setdefault((lhs, m["desc"]), []).append(m["mode"])

    by_modes = {}
    for (lhs, desc), modes in merged.items():
        combo = " ".join(sorted(set(modes), key=_NVIM_MODES.index))
        by_modes.setdefault(combo, []).append((lhs, desc, ""))

    def mode_rank(combo: str) -> Tuple[int, str]:
        return (_NVIM_MODES.index(combo.split()[0]), combo)

    sections = [
        Section(f"mode: {combo}", rows)
        for combo, rows in sorted(by_modes.items(), key=lambda kv: mode_rank(kv[0]))
    ]
    cmd_rows = sorted((f":{c['name']}", c["desc"], "") for c in data["cmds"])
    sections.append(Section("user commands", cmd_rows))
    leader_name = "Space" if leader == " " else leader
    notes = [
        f"leader: {leader_name}",
        "Buffer-local LSP maps (gd, K, <leader>ca, ...) attach per-buffer and aren't listed.",
    ]
    return Tool("nvim", sections, notes=notes)


_PLUGIN_DEFAULTS: List[Tuple[str, List[Row]]] = [
    ("oil.nvim (in oil buffer)", [
        ("<CR>", "open entry under cursor", ""),
        ("-", "go up one directory (keep pressing to ascend)", ""),
        ("edit + :w", "create/rename/delete files by editing lines, save to apply", "oil's core trick"),
        ("<C-s>", "open entry in vertical split", "<C-h> horizontal variant disabled by config"),
        ("<C-p>", "preview entry in a float", ""),
        ("g.", "toggle hidden (dot) files", ""),
        ("gs", "change sort order (interactive)", ""),
        ("g?", "show all oil keybinds", ""),
    ]),
    ("telescope (inside picker, insert mode)", [
        ("<C-q>", "send ALL results to quickfix and open it", ""),
        ("<M-q>", "send only <Tab>-selected results to quickfix", ""),
        ("<Tab> / <S-Tab>", "toggle-select entry and move down/up (multi-select)", ""),
        ("<C-x> / <C-v> / <C-t>", "open result in hsplit / vsplit / new tab", ""),
        ("<C-u> / <C-d>", "scroll the preview window up/down", ""),
        ("<C-r><C-w>", "insert word under cursor into the prompt", ""),
        ("<C-/>", "show all picker mappings", ""),
    ]),
    ("blink.cmp (insert mode, menu visible)", [
        ("<C-y>", "accept selected completion", "<CR> also accepts (config override)"),
        ("<C-e>", "cancel/hide the menu", ""),
        ("<C-Space>", "open menu; again toggles documentation window", ""),
        ("<C-n> / <C-p>", "next/prev item; if snippet active, jump forward/back", ""),
        ("<C-b> / <C-f>", "scroll documentation window up/down", ""),
        ("<C-k>", "toggle signature-help window", ""),
        ("<Tab> / <S-Tab> (in : cmdline)", "show completion menu and cycle candidates", "<C-y> accepts"),
    ]),
    ("mini.ai (2nd char after a/i, an/in, al/il)", [
        ("q", "nearest quotes: '' \"\" ``  (e.g. ciq)", ""),
        ("b", "nearest bracket pair: () [] {}  (e.g. dab)", ""),
        ("( [ { <  vs  ) ] } >", "that specific pair; open form trims inner edge whitespace", "i( vs i)"),
        ("t", "HTML/XML tag pair", ""),
        ("f", "function call name(args)", "plain af/if taken by treesitter function object; reach via anf/inf"),
        ("?", "prompted custom left/right delimiters", ""),
        ("any punct/digit", "pair of that literal char (e.g. ci_ , ci*)", ""),
    ]),
    ("mini.surround (2nd char after ys{motion}/ds/cs)", [
        ("ysiw)", "wrap word in () — closers = tight pair", ""),
        ("ysiw(", "wrap with padding: ( word )", "openers add inner spaces; ds/cs also eat edge whitespace"),
        ("q", "quotes: ds q deletes nearest quotes, cs q ' changes them to '", "add-side q emits \"\""),
        ("f", "function call: ysiwf prompts name -> name(word); dsf unwraps a call", ""),
        ("t", "tag: yst prompts tag; dst / cst work on nearest tag", ""),
        ("cs)]", "replace: input char then output char, e.g. () -> []", ""),
        ("?", "prompted arbitrary left/right pair", ""),
    ]),
    ("markdown.nvim (markdown buffers)", [
        ("gs{motion}{style}", "toggle emphasis: i=*italic* b=**bold** s=~~strike~~ c=`code` (e.g. gsiwb)", ""),
        ("gss{style}", "toggle emphasis on the whole line (e.g. gssb)", ""),
        ("gsd{style} / gsc{style}", "delete / change emphasis at cursor", "config remaps"),
        ("gl{motion}", "add link around motion (prompts for URL)", ""),
        ("gx", "follow link under cursor", "buffer-local; shadows builtin gx in markdown"),
        ("]] / [[", "next / previous heading", "buffer-local in markdown"),
        ("]p", "go to parent heading", "]h (config remap) = current heading"),
    ]),
    ("diffview (inside a Diffview tab)", [
        ("<Tab> / <S-Tab>", "open diff for next / previous file", ""),
        ("<leader>e / <leader>b", "focus / toggle the file panel", ""),
        ("s or - (file panel)", "stage/unstage entry;  S = stage all,  U = unstage all", ""),
        ("X (file panel)", "restore entry to left-side state (discard changes)", ""),
        ("i (file panel)", "toggle list vs tree listing", ""),
        ("[x / ]x", "prev / next merge conflict;  2do/3do = take ours/theirs hunk", "3-way merge view"),
        ("y (file-history panel)", "copy commit hash of entry under cursor", ""),
        ("g?", "per-panel help listing every bind", ""),
    ]),
    ("undotree (panel)", [
        ("J / K", "step to previous / next undo state (applies it live)", ""),
        ("<CR>", "revert buffer to state under cursor", ""),
        ("D", "toggle the diff panel for the hovered state", ""),
        ("< / >", "jump to previous / next saved (written) state", ""),
        ("T", "toggle relative vs absolute timestamps", ""),
        ("? / q / <Tab>", "help / close panel / focus back to editor", ""),
    ]),
    ("grug-far (search/replace buffer)", [
        ("<Tab> / <S-Tab>", "jump between input fields (search/replace/files...)", ""),
        ("<Down> / <Up>", "open next / previous result location in your last window", ""),
        ("<localleader>i", "preview result location in a float", ""),
        ("<leader>ha / <leader>hq", "apply replace all / send results to quickfix", "config remaps"),
        ("<leader>hs / <leader>hl", "sync edited result lines back to files: all / current line", "config remaps"),
        ("g? / q", "help / close", ""),
    ]),
    ("LSP (buffer-local on attach)", [
        ("gd", "go to definition", ""),
        ("K", "hover docs", ""),
        ("gi", "go to implementation", "gri is the builtin twin"),
        ("<leader>rn / <leader>ca", "rename symbol / code action", "grn/gra are the builtin twins"),
    ]),
]


def parse_plugin_defaults(_root: Path) -> Tool:
    return Tool(
        "nvim plugin defaults",
        [Section(ctx, rows) for ctx, rows in _PLUGIN_DEFAULTS],
        notes=["Hand-curated from the pinned plugin versions — the one section not parsed from configs."],
    )


PARSERS: List[Tuple[str, Callable[[Path], Tool]]] = [
    ("tmux", parse_tmux),
    ("shell", parse_shell),
    ("wezterm", parse_wezterm),
    ("nvim", parse_nvim),
    ("nvim plugin defaults", parse_plugin_defaults),
]


def collect(root: Path) -> List[Tool]:
    tools = []
    for name, parser in PARSERS:
        try:
            tools.append(parser(root))
        except Exception as exc:
            tools.append(Tool(name, error=f"{type(exc).__name__}: {exc}"))
    return tools


_CSS = """
body { background: #1d2021; color: #ebdbb2; font-family: monospace; margin: 2em auto; max-width: 70em; padding: 0 1em; }
h1 { color: #fabd2f; } h2 { color: #8ec07c; border-bottom: 1px solid #504945; margin-top: 1.5em; }
h3 { color: #83a598; margin-bottom: 0.3em; }
table { border-collapse: collapse; width: 100%; margin-bottom: 1em; }
th, td { text-align: left; padding: 2px 12px 2px 0; vertical-align: top; }
th { color: #928374; font-weight: normal; border-bottom: 1px solid #3c3836; }
td:first-child { color: #fe8019; white-space: nowrap; }
.note { color: #928374; font-size: 0.9em; margin: 0.2em 0; }
.error { color: #fb4934; }
#filter { background: #282828; color: #ebdbb2; border: 1px solid #504945; padding: 6px 10px; width: 100%; font-family: monospace; font-size: 1em; box-sizing: border-box; }
"""

_JS = """
const box = document.getElementById('filter');
box.addEventListener('input', () => {
  const q = box.value.toLowerCase();
  document.querySelectorAll('tbody tr').forEach(tr => {
    tr.style.display = tr.textContent.toLowerCase().includes(q) ? '' : 'none';
  });
  document.querySelectorAll('table').forEach(t => {
    const any = [...t.querySelectorAll('tbody tr')].some(tr => tr.style.display !== 'none');
    t.style.display = any ? '' : 'none';
    if (t.previousElementSibling && t.previousElementSibling.tagName === 'H3')
      t.previousElementSibling.style.display = any ? '' : 'none';
  });
});
box.focus();
"""


def _render_table(section: Section, columns: Tuple[str, ...]) -> List[str]:
    ncols = len(columns)
    out = [f"<h3>{html.escape(section.title)}</h3>", "<table><thead><tr>"]
    out += [f"<th>{html.escape(c)}</th>" for c in columns]
    out.append("</tr></thead><tbody>")
    for row in section.rows:
        cells = "".join(f"<td>{html.escape(c)}</td>" for c in row[:ncols])
        out.append(f"<tr>{cells}</tr>")
    out.append("</tbody></table>")
    return out


def render(tools: List[Tool]) -> str:
    parts = [
        "<!doctype html><html><head><meta charset='utf-8'>",
        "<title>dotfiles cheatsheet</title>",
        f"<style>{_CSS}</style></head><body>",
        "<h1>dotfiles cheatsheet</h1>",
        "<input id='filter' type='text' placeholder='filter keybinds...'>",
    ]
    for tool in tools:
        parts.append(f"<h2>{html.escape(tool.title)}</h2>")
        if tool.error:
            parts.append(f"<p class='note error'>parse failed: {html.escape(tool.error)}</p>")
            continue
        for note in tool.notes:
            parts.append(f"<p class='note'>{html.escape(note)}</p>")
        columns: Tuple[str, ...] = ("Key", "Action", "Desc")
        if all(not row[2] for s in tool.sections for row in s.rows):
            columns = columns[:2]
        for section in tool.sections:
            parts += _render_table(section, columns)
    parts.append(f"<script>{_JS}</script></body></html>")
    return "\n".join(parts)


def build_page() -> str:
    return render(collect(repo_root()))


class Handler(BaseHTTPRequestHandler):
    def log_message(self, *args) -> None:
        pass

    def do_GET(self) -> None:
        if self.path != "/":
            self.send_error(404)
            return
        body = build_page().encode()
        self.send_response(200)
        self.send_header("Content-Type", "text/html; charset=utf-8")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)


def write_cache() -> Path:
    cache_dir = Path(os.environ.get("XDG_CACHE_HOME", Path.home() / ".cache"))
    cache_dir.mkdir(parents=True, exist_ok=True)
    out = cache_dir / "cheatsheet.html"
    out.write_text(build_page())
    return out


def main() -> None:
    ap = argparse.ArgumentParser(description="dotfiles keybind cheatsheet")
    ap.add_argument("--serve", action="store_true", help="run a live HTTP server")
    ap.add_argument("--port", type=int, default=30000)
    ap.add_argument("--dump", action="store_true", help="print HTML to stdout and exit")
    args = ap.parse_args()

    if args.dump:
        print(build_page())
        return
    if args.serve:
        server = ThreadingHTTPServer(("127.0.0.1", args.port), Handler)
        print(f"serving on http://localhost:{args.port}", file=sys.stderr)
        server.serve_forever()
        return
    print(write_cache().as_uri())


if __name__ == "__main__":
    main()
