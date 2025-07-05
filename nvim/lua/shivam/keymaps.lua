local map = vim.keymap.set

-- General
map("n", "-", vim.cmd.Ex) -- File explorer view
map("n", "<Esc>", "<cmd>nohlsearch<CR>") -- Clear search highlight

-- Terminal Mode
map("n", "<leader>t", "<cmd>terminal<CR>", { desc = "Open vim terminal" }) -- Exit terminal mode. May not work with emulators
map("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" }) -- Exit terminal mode. May not work with emulators

-- Persistance Copy
local modes = {"n", "x"} -- normal and visual modes
map(modes, "gy", [["ay]], { desc = "Yank to register a" })
map(modes, "gp", [["ap]], { desc = "Paste from register a" })

-- Yanking Keymaps
map("x", "<leader>p", [["_dP]])
map({ "n", "v" }, "<leader>y", [["+y]])
map("n", "<leader>Y", [["+Y]])

-- Move around Neovim panels
map("n", "<leader>h", "<C-w>h")
map("n", "<leader>j", "<C-w>j")
map("n", "<leader>k", "<C-w>k")
map("n", "<leader>l", "<C-w>l")

