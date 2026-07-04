local M = {}

local function oil_dir()
	local ok, oil = pcall(require, "oil")
	if ok and oil.get_current_dir and vim.bo.filetype == "oil" then
		local dir = oil.get_current_dir(0)
		if dir and dir ~= "" then
			return dir
		end
	end
	return nil
end

function M.current_dir()
	local dir = oil_dir()
	if dir then
		return dir
	end
	local bufname = vim.api.nvim_buf_get_name(0)
	if bufname ~= "" then
		return vim.fn.fnamemodify(bufname, ":h")
	end
	return vim.fn.getcwd()
end

function M.current_path()
	local dir = oil_dir()
	if dir then
		return dir
	end
	local buf = vim.fn.expand("%:p")
	if buf ~= "" then
		return buf
	end
	return nil
end

return M
