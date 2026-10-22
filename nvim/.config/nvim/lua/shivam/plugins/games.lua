-- Secrets stay out of this repo: the password comes from $NVIM_GAMES_PASSWORD or
-- ~/.config/games.nvim/password, and :Games prompts when neither is set.
local PASSWORD_FILE = vim.fn.expand("~/.config/games.nvim/password")

local function saved_password()
	local from_env = os.getenv("NVIM_GAMES_PASSWORD")
	if from_env and from_env ~= "" then
		return from_env
	end
	if vim.fn.filereadable(PASSWORD_FILE) == 1 then
		local first_line = vim.fn.readfile(PASSWORD_FILE, "", 1)[1]
		return first_line ~= "" and first_line or nil
	end
end

return {
	"shivamshivanshu/games.nvim",
	cmd = "Games",
	opts = function()
		return {
			server = { host = os.getenv("NVIM_GAMES_HOST") or "127.0.0.1", port = 7777 },
			username = "shivam",
			password = saved_password(),
		}
	end,
}
