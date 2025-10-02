return {
	"folke/which-key.nvim",
	event = "VeryLazy",
    init = function()
        vim.o.timeout = true
        vim.o.timeoutlen = 300
    end,
    opts = {
        plugins = {
            spelling = {
                enabled = true,
                suggestions = 20,
            },
        },
        presets = {
            operators = false,
            motions = false,
            text_objects = false,
            windows = false,
            nav = false,
            z = false,
            g = false,
        },
    },
    config = function(opts)
        local wk = require("which-key")
        wk.setup(opts)
    end
}
