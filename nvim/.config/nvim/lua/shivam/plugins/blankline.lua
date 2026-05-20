return {
	"lukas-reineke/indent-blankline.nvim",
	event = require("shivam.util.events").BUF_LOADED,
	main = "ibl",
	opts = {
		indent = { char = "│" }, -- character for indent guides
		scope = { enabled = true, show_start = true, show_end = true },
	},
}
