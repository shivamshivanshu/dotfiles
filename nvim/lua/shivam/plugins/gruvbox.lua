return {
	"ellisonleao/gruvbox.nvim",
	lazy = false, -- Must load immediately for colorscheme
	priority = 1000,
	config = function()
		require("gruvbox").setup({
			contrast = "hard",      -- or "soft", "medium"
			italic = {
				strings = true,
				comments = true,
				operators = false,
				folds = true,
			},
			transparent_mode = false,
		})
		vim.cmd.colorscheme("gruvbox")

		-- Set all virtual text to bright yellow for visibility
		local vtext_color = "#fabd2f"  -- bright yellow
		local groups = {
			"GitSignsCurrentLineBlame",
			"DiagnosticVirtualTextError",
			"DiagnosticVirtualTextWarn",
			"DiagnosticVirtualTextInfo",
			"DiagnosticVirtualTextHint",
		}
		for _, group in ipairs(groups) do
			vim.api.nvim_set_hl(0, group, { fg = vtext_color })
		end
	end,
}
