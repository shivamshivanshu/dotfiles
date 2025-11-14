local map = vim.keymap.set

-- General
-- Note: "-" is mapped to Oil in plugins/oil.lua
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

-- Helper: fetch current path (dir in oil.nvim, file in regular buffers)
local function get_current_path()
  local ok, oil = pcall(require, "oil")
  if ok and oil.get_current_dir and vim.bo.filetype == "oil" then
    local dir = oil.get_current_dir()
    if dir and dir ~= "" then
      return dir
    end
  end
  local buf = vim.fn.expand("%:p")
  if buf ~= "" then
    return buf
  end
  return nil
end

-- Helper: copy path with an optional modifier (":p" absolute, ":." relative)
local function copy_path(mod, label)
  local path = get_current_path()
  if not path then
    local msg = "No valid path to copy"
    if vim.notify then
      vim.notify(msg, vim.log.levels.WARN)
    else
      print(msg)
    end
    return
  end

  local out = mod and vim.fn.fnamemodify(path, mod) or path
  vim.fn.setreg("+", out)

  local msg = string.format("Copied%s: %s", label and (" (" .. label .. ")") or "", out)
  if vim.notify then
    vim.notify(msg)
  else
    print(msg)
  end
end

-- <leader>cp → copy absolute path
vim.keymap.set("n", "<leader>cp", function()
  copy_path(":p", "absolute")
end, { desc = "Copy absolute file/dir path to clipboard" })

-- <leader>cr → copy path relative to current working directory
vim.keymap.set("n", "<leader>cr", function()
  copy_path(":.", "relative")
end, { desc = "Copy relative file/dir path to clipboard" })

-- Formatting
map({"n", "x"}, "<leader>f", function()
	local ok, conform = pcall(require, "conform")
	if ok then
		conform.format({ async = true, lsp_fallback = true })
	else
		vim.lsp.buf.format({ async = true })
	end
end, { desc = "Format" })

