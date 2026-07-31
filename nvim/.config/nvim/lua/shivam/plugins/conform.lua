local actions = require("shivam.util.actions")

actions.add("format.buffer", function()
	require("conform").format({ async = true, lsp_format = "fallback" })
end, { desc = "Format buffer (conform, LSP fallback)", cmd = "Format" })

actions.map({ "n", "x" }, "<leader>f", "format.buffer")

return {
	"stevearc/conform.nvim",
	cmd = { "ConformInfo" },
	opts = {
		formatters_by_ft = {
			lua = { "stylua" },
			python = { "ruff_fix", "ruff_organize_imports", "ruff_format" },
			go = { "goimports", "gofumpt" },
			cpp = { "clang-format" },
			c = { "clang-format" },
			cmake = { "cmake_format" },
			javascript = { "prettier" },
			typescript = { "prettier" },
			json = { "prettier" },
			yaml = { "prettier" },
			markdown = { "prettier" },
			html = { "prettier" },
			css = { "prettier" },
		},
	},
}
