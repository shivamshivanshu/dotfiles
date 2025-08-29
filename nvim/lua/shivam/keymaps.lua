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

-- Copy cwd to clipboard
vim.keymap.set("n", "<leader>cp", function()
  local path = nil

  -- Try oil.nvim first
  local oil_ok, oil = pcall(require, "oil")
  if oil_ok and oil.get_current_dir and vim.bo.filetype == "oil" then
    path = oil.get_current_dir()
  else
    -- Otherwise use the buffer's file path
    local buf_path = vim.fn.expand("%:p")
    if buf_path ~= "" then
      path = buf_path
    end
  end

  if not path then
    print("No valid path to copy")
    return
  end

  -- Copy to system clipboard
  vim.fn.setreg("+", path)
  print("Copied: " .. path)
end, { desc = "Copy file/dir path to clipboard" })

