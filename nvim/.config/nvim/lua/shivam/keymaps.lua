local map = vim.keymap.set

-- General
-- Note: "-" is mapped to Oil in plugins/oil.lua
map("n", "<Esc>", "<cmd>nohlsearch<CR>") -- Clear search highlight
map("n", "<C-d>", "<C-d>zz")
map("n", "<C-u>", "<C-u>zz")

-- Buffers
map("n", "<leader>bd", function()
	require("mini.bufremove").delete(0)
end, { desc = "Delete buffer (keep window layout)" })
map("n", "<Tab>", "<cmd>bnext<CR>", { desc = "Next buffer" })
map("n", "<S-Tab>", "<cmd>bprevious<CR>", { desc = "Prev buffer" })

-- Ctrl+Backspace deletes previous word (terminals often deliver it as <C-h>)
map({ "i", "c" }, "<C-BS>", "<C-w>")
map({ "i", "c" }, "<C-h>", "<C-w>")

-- Terminal Mode
map("n", "<leader>t", "<cmd>terminal<CR>", { desc = "Open vim terminal" })
map("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" }) -- Exit terminal mode. May not work with emulators

-- Persistance Copy
local modes = { "n", "x" } -- normal and visual modes
map(modes, "gy", [["ay]], { desc = "Yank to register a" })
map(modes, "gp", [["ap]], { desc = "Paste from register a" })

-- Yanking Keymaps
map("x", "<leader>p", [["_dP]])
map({ "n", "v" }, "<leader>y", [["+y]])
map("n", "<leader>Y", [["+Y]])
-- <leader>c* to avoid shadowing <leader>y + a-textobjects (e.g. <leader>yaw)
map("n", "<leader>cb", function()
	local pos = vim.api.nvim_win_get_cursor(0)
	vim.cmd("silent %yank +")
	vim.api.nvim_win_set_cursor(0, pos)
	vim.notify("Copied buffer to clipboard (" .. vim.api.nvim_buf_line_count(0) .. " lines)")
end, { desc = "Copy entire buffer to clipboard" })

-- Window navigation (nvim splits only, <C-hjkl> used by tmux-navigator)
map("n", "<leader>wh", "<C-w>h", { desc = "Move to left window" })
map("n", "<leader>wj", "<C-w>j", { desc = "Move to bottom window" })
map("n", "<leader>wk", "<C-w>k", { desc = "Move to top window" })
map("n", "<leader>wl", "<C-w>l", { desc = "Move to right window" })

-- Helper: copy path with an optional modifier (":p" absolute, ":." relative)
local function copy_path(mod, label)
	local path = require("shivam.util.paths").current_path()
	if not path then
		vim.notify("No valid path to copy", vim.log.levels.WARN)
		return
	end

	local out = mod and vim.fn.fnamemodify(path, mod) or path
	vim.fn.setreg("+", out)
	vim.notify(string.format("Copied%s: %s", label and (" (" .. label .. ")") or "", out))
end

-- <leader>cp → copy absolute path
vim.keymap.set("n", "<leader>cp", function()
	copy_path(":p", "absolute")
end, { desc = "Copy absolute file/dir path to clipboard" })

-- <leader>cr → copy path relative to current working directory
vim.keymap.set("n", "<leader>cr", function()
	copy_path(":.", "relative")
end, { desc = "Copy relative file/dir path to clipboard" })

-- Epoch converter
require("shivam.util.epoch").setup()

-- Code runner (build/run cpp & py)
require("shivam.util.runner").setup()
