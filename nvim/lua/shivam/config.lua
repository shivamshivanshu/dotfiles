-- UI

-- Make line numbers default
vim.o.number = true

-- Enable mouse mode, can be useful for resizing splits for example!
vim.o.mouse = 'a'

-- Don't show the mode, since it's already in the status line
vim.o.showmode = true

-- Enable break indent
vim.o.breakindent = true

-- Save undo history
vim.o.undofile = true

-- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
vim.o.ignorecase = true
vim.o.smartcase = true

-- Keep signcolumn on by default
vim.o.signcolumn = 'yes'

-- Decrease update time
vim.o.updatetime = 250

-- Decrease mapped sequence wait time
vim.o.timeoutlen = 300

-- Configure how new splits should be opened
vim.o.splitright = true
vim.o.splitbelow = true

vim.o.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

-- Show which line your cursor is on
vim.o.cursorline = true

-- Minimal number of screen lines to keep above and below the cursor.
vim.o.scrolloff = 10

-- if performing an operation that would fail due to unsaved changes in the buffer (like `:q`),
-- instead raise a dialog asking if you wish to save the current file(s)
-- See `:help 'confirm'`
vim.o.confirm = true

-- Enable terminal gui
vim.o.termguicolors = true

-- Use system clipboard
vim.opt.clipboard = "unnamedplus"

-- Enable Relative Linenumber
vim.opt.relativenumber = true


-- Indentation settings
vim.opt.autoindent = true      -- Copy indent from current line when starting a new one
vim.opt.smartindent = true     -- Smart autoindenting for code

-- Tab and indentation width
vim.opt.tabstop = 4            -- Display width of a tab character
vim.opt.shiftwidth = 4         -- Spaces used for each step of autoindent
vim.opt.softtabstop = 4        -- Spaces a <Tab> counts for while editing
vim.opt.expandtab = true       -- Convert tabs to spaces

-- Performance optimizations
vim.opt.lazyredraw = false -- Don't set to true, causes issues in Neovim 0.10+
vim.opt.synmaxcol = 240 -- Don't syntax highlight long lines
vim.opt.redrawtime = 1500 -- Time in ms for redrawing display

-- Highlight text when yanking
vim.api.nvim_create_autocmd('TextYankPost', {
	desc = 'Highlight when yanking (copying) text',
	group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
	callback = function()
		vim.highlight.on_yank({
			higroup = "IncSearch", -- One of IncSearch, Visual, Search
			timeout = 150, -- Duration in ms
			on_macro = false, -- Don't run while yanking inside macro
			on_visual = true, -- Highlight visually selected test
		})
	end,
})
