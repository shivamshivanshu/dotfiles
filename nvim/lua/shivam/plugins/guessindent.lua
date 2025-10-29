return {
	'NMAC427/guess-indent.nvim', -- Detect tabstop and shiftwidth automatically
	event = { "BufReadPre", "BufNewFile" }, -- Load when opening a file
	opts = {},
}
