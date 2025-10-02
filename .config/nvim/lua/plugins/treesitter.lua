return {
	"nvim-treesitter/nvim-treesitter",
	build = ":TSUpdate",
	opts = {
		ensure_installed = {
			"typescript",
			"javascript",
			"c",
			"go",
			"python",
			"html",
			"css",
			"cpp",
			"c_sharp",
			"java",
			"lua",
			"vim",
			"vimdoc",
			"query",
		},
		sync_install = true,
		auto_install = true,
		highlight = {
			enable = true,
			additional_vim_regex_highlighting = false,
		},
	},
	config = function(_opts)
		local configs = require("nvim-treesitter.configs")
		configs.setup(_opts)
	end,
}
