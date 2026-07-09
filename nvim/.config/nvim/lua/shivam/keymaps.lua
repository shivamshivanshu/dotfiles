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

-- Yanking Keymaps (y/Y already hit the clipboard via clipboard=unnamedplus)
map("x", "<leader>p", [["_dP]])
map("n", "<leader>cb", function()
	local pos = vim.api.nvim_win_get_cursor(0)
	vim.cmd("silent %yank +")
	vim.api.nvim_win_set_cursor(0, pos)
	vim.notify("Copied buffer to clipboard (" .. vim.api.nvim_buf_line_count(0) .. " lines)")
end, { desc = "Copy entire buffer to clipboard" })

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

-- Copy the commit hash of the current line (blames in the file's own repo)
vim.api.nvim_create_user_command("CopyCommitHash", function()
	local file = vim.fn.resolve(vim.fn.expand("%:p"))
	local line = vim.fn.line(".")
	local blame = vim.fn.systemlist({
		"git",
		"-C",
		vim.fn.fnamemodify(file, ":h"),
		"blame",
		"-L",
		line .. "," .. line,
		"--porcelain",
		file,
	})
	if vim.v.shell_error ~= 0 or #blame == 0 then
		vim.notify("git blame failed", vim.log.levels.WARN)
		return
	end
	local hash = blame[1]:match("^(%S+)")
	if not hash or hash:match("^0+$") then
		vim.notify("Line not committed yet", vim.log.levels.WARN)
		return
	end
	vim.fn.setreg("+", hash)
	vim.notify("Copied commit hash: " .. hash)
end, { desc = "Copy commit hash for current line" })

-- Epoch converter
require("shivam.util.epoch").setup()

-- Code runner (build/run cpp & py)
require("shivam.util.runner").setup()
