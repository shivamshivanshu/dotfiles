local function nav(key, dir)
	return {
		key,
		function()
			require("smart-splits")["move_cursor_" .. dir]()
		end,
		desc = "Tmux nav " .. dir,
	}
end

-- <A-hjkl> belongs to mini.move, so resizing lives on Alt+arrows
local function resize(key, dir)
	return {
		key,
		function()
			require("smart-splits")["resize_" .. dir]()
		end,
		desc = "Resize split " .. dir,
	}
end

return {
	"mrjones2014/smart-splits.nvim",
	keys = {
		nav("<c-h>", "left"),
		nav("<c-j>", "down"),
		nav("<c-k>", "up"),
		nav("<c-l>", "right"),
		resize("<A-Left>", "left"),
		resize("<A-Down>", "down"),
		resize("<A-Up>", "up"),
		resize("<A-Right>", "right"),
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
