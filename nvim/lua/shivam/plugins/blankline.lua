return {
    "lukas-reineke/indent-blankline.nvim",
    event = "BufReadPost", -- Load after reading a buffer
    main = "ibl",
    opts = {
        indent = { char = "│" }, -- character for indent guides
        scope = { enabled = true, show_start = true, show_end = true },
    },
}

