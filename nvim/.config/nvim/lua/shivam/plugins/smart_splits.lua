local function nav(key, dir)
	return {
		key,
		function()
			require("smart-splits")["move_cursor_" .. dir]()
		end,
		desc = "Tmux nav " .. dir,
	}
end

return {
	"mrjones2014/smart-splits.nvim",
	keys = {
		nav("<c-h>", "left"),
		nav("<c-j>", "down"),
		nav("<c-k>", "up"),
		nav("<c-l>", "right"),
		{
			"<c-\\>",
			function()
				-- smart-splits has no tmux fallback for "previous"; mirror
				-- vim-tmux-navigator: prior nvim window, else last tmux pane
				local win = vim.api.nvim_get_current_win()
				require("smart-splits").move_cursor_previous()
				if vim.api.nvim_get_current_win() == win and vim.env.TMUX then
					vim.system({ "tmux", "select-pane", "-l" })
				end
			end,
			desc = "Tmux nav previous",
		},
	},
}
