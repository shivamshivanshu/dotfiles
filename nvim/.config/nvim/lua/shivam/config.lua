-- Disable unused providers
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_node_provider = 0
vim.g.loaded_python3_provider = 0

-- UI

vim.o.number = true

vim.o.mouse = "a"

-- Don't show the mode, since it's already in the status line
vim.o.showmode = false

vim.o.breakindent = true

vim.o.undofile = true

-- No swapfiles; persistent undo above covers recovery
vim.o.swapfile = false

-- Rounded borders for all floating windows (LSP hover, completion docs, ...)
vim.o.winborder = "rounded"

-- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
vim.o.ignorecase = true
vim.o.smartcase = true

vim.o.signcolumn = "yes"

vim.o.updatetime = 250

vim.o.timeoutlen = 750

vim.o.splitright = true
vim.o.splitbelow = true

vim.o.list = true
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }

vim.o.cursorline = true

vim.o.scrolloff = 10

-- if performing an operation that would fail due to unsaved changes in the buffer (like `:q`),
-- instead raise a dialog asking if you wish to save the current file(s)
-- See `:help 'confirm'`
vim.o.confirm = true

vim.o.termguicolors = true

vim.opt.guicursor = "a:block-blinkwait300-blinkon500-blinkoff500"

vim.opt.clipboard = "unnamedplus"

-- Without a clipboard tool the provider falls back to `tmux load-buffer`
-- (no -w), so yanks never leave tmux; OSC 52 does reach the OS clipboard
local clipboard_tools = { "pbcopy", "wl-copy", "xclip", "xsel" }
local has_clipboard_tool = vim.iter(clipboard_tools):any(function(tool)
	return vim.fn.executable(tool) == 1
end)
if not has_clipboard_tool then
	vim.g.clipboard = "osc52"
end

vim.opt.relativenumber = true

vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4
vim.opt.expandtab = true

vim.opt.synmaxcol = 240
vim.opt.redrawtime = 1500

-- Session options for tmux-resurrect
vim.opt.sessionoptions = {
	"buffers",
	"curdir",
	"tabpages",
	"winsize",
	"help",
	"globals",
	"skiprtp",
	"folds",
}

-- tmux-resurrect's nvim strategy restores via `nvim -S` only when Session.vim
-- exists in the pane's cwd; :SessionTrack opts a project in, the autocmd keeps it fresh
local actions = require("shivam.util.actions")
actions.add("session.track", function()
	vim.cmd("mksession! Session.vim")
	vim.notify("Session tracking on (Session.vim)")
end, { desc = "Track session for auto-restore (mksession! Session.vim)", cmd = "SessionTrack" })
actions.add("session.untrack", function()
	if vim.v.this_session == "" then
		vim.notify("No session being tracked")
		return
	end
	os.remove(vim.v.this_session)
	vim.v.this_session = ""
	vim.notify("Session tracking off")
end, { desc = "Stop tracking and remove the current session file", cmd = "SessionUntrack" })
vim.api.nvim_create_autocmd("VimLeavePre", {
	group = vim.api.nvim_create_augroup("shivam-session-track", { clear = true }),
	callback = function()
		-- Only the instance that created (:SessionTrack) or loaded (nvim -S)
		-- the session refreshes it; incidental nvim runs must not clobber it
		if vim.v.this_session ~= "" then
			vim.cmd("silent! mksession! " .. vim.fn.fnameescape(vim.v.this_session))
		end
	end,
})

vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking (copying) text",
	group = vim.api.nvim_create_augroup("shivam-highlight-yank", { clear = true }),
	callback = function()
		vim.hl.on_yank()
	end,
})

-- Pick up external edits (Claude/agents write files underneath open buffers)
vim.o.autoread = true
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "TermClose", "TermLeave" }, {
	group = vim.api.nvim_create_augroup("shivam-autoread", { clear = true }),
	callback = function()
		if vim.fn.getcmdwintype() == "" then
			vim.cmd.checktime()
		end
	end,
})

local ok_ui2, ui2 = pcall(require, "vim._core.ui2")
if ok_ui2 then
	ui2.enable({ enable = true })
	actions.add("toggle.ui2", function()
		ui2.enable({ enable = not ui2.cfg.enable })
	end, { desc = "Toggle the experimental message/cmdline UI", cmd = "ToggleUi2" })
end
